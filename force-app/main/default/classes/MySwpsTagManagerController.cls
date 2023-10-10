public without sharing class MySwpsTagManagerController {
    private static final String TAG_ICON = 'utility:topic';
    @AuraEnabled(Cacheable=true Scope='global')
    public static List<LookupSearchResult> searchTags(String searchTerm, List<Id> selectedTagIds, String category, String language, List<String> excludedValues) {
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        searchTerm = '%' + searchTerm + '%';

        for (Tag__c tag : [
            SELECT Name, English_Name__c
            FROM Tag__c
            WHERE Category__c = :category
                AND (
                    Name LIKE :searchTerm
                        OR English_Name__c LIKE :searchTerm
                )
                AND English_Name__c NOT IN :excludedValues
                AND Id NOT IN :selectedTagIds
        ]) {
            LookupSearchResult lookupSearchResult = new LookupSearchResult(
                tag.Id,
                Tag__c.getSObjectType().getDescribe().getName(),
                TAG_ICON,
                language.equals(Constants.LANGUAGE_LOCALE_KEY_POLISH) ? tag.Name : tag.English_Name__c,
                null
            );

            results.add(lookupSearchResult);
        }

        return results;
    }

    @AuraEnabled(Cacheable=true Scope='global')
    public static List<TagWrapper> fetchRecordTags(Id recordId, String category, String language) {
        SObjectType recordSObjectType = recordId.getSobjectType();

        List<PicklistEntry> picklistEntries;
        List<SObject> recordTags;
        List<TagWrapper> tagWrappers = new List<TagWrapper>();
        SObjectField levelField;
        SObjectField tagRelationshipField;

        if (Career_Services_Offer__c.getSObjectType() == recordSObjectType) {
            recordTags = [
                SELECT Level__c, toLabel(Level__c) levelLabel, Tag__r.Name, Tag__r.English_Name__c
                FROM Career_Services_Offer_Tag__c
                WHERE Career_Services_Offer__c = :recordId
                    AND Category__c = :category
            ];
            levelField = Career_Services_Offer_Tag__c.Level__c;
            picklistEntries = Career_Services_Offer_Tag__c.Level__c.getDescribe().getPicklistValues();
            tagRelationshipField = Career_Services_Offer_Tag__c.Tag__c.getDescribe().getSobjectField();
        } else if (Contact.getSObjectType() == recordSObjectType) {
            recordTags = [
                SELECT Level__c, toLabel(Level__c) levelLabel, Tag__r.Name, Tag__r.English_Name__c
                FROM Contact_Tag__c
                WHERE Contact__c = :recordId
                    AND Category__c = :category
            ];
            levelField = Contact_Tag__c.Level__c;
            picklistEntries = Contact_Tag__c.Level__c.getDescribe().getPicklistValues();
            tagRelationshipField = Contact_Tag__c.Tag__c.getDescribe().getSobjectField();
        }

        Map<String, Integer> picklistValue2Index = mapPicklistValueWithIndex(picklistEntries);

        for (SObject recordTag : recordTags) {
            TagWrapper tagWrapper = new TagWrapper();
            tagWrapper.tagId = recordTag.Id;
            tagWrapper.label = language.equals(Constants.LANGUAGE_LOCALE_KEY_POLISH)
                ? (String) recordTag.getSObject(tagRelationshipField).get(Tag__c.Name.getDescribe().getName())
                : (String) recordTag.getSObject(tagRelationshipField).get(Tag__c.English_Name__c.getDescribe().getName());

            LevelWrapper levelWrapper = new LevelWrapper();
            levelWrapper.label = (String) recordTag.get('levelLabel');
            levelWrapper.value = (String) recordTag.get(levelField);
            levelWrapper.index = picklistValue2Index.get(levelWrapper.value);
            tagWrapper.level = levelWrapper;

            tagWrappers.add(tagWrapper);
        }

        return tagWrappers;
    }

    private static Map<String, Integer> mapPicklistValueWithIndex(List<PicklistEntry> picklistEntries) {
        Map<String, Integer> picklistValue2Index = new Map<String, Integer>();

        for (Integer i = 0; i < picklistEntries.size(); i++) {
            picklistValue2Index.put(picklistEntries[i].getValue(), i);
        }

        return picklistValue2Index;
    }

    public class TagWrapper {
        @AuraEnabled
        public Id tagId {get; set;}
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public LevelWrapper level {get; set;}
    }

    public class LevelWrapper {
        @AuraEnabled
        public Integer index {get; set;}
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get; set;}
    }
}