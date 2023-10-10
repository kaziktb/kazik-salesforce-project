global class TB_MultiContactDuplicateSearchScheduler implements Schedulable {
    final static String CONTACT_API_NAME = 'Contact';
    final static Integer BATCH_SIZE = 2000;
    public Boolean doNotRunBatches = false;

    global void execute() {
        execute(null, getMatchingRules());
    }

    global void execute(SchedulableContext context) {
        execute(context, getMatchingRules());
    }

    global void execute(SchedulableContext context, List<TB_Multi_Contact_Matching_Rule__mdt> matchingRules) {
        List<ObjectMatcher> matchers = getObjectMatchers(matchingRules);
        for (ObjectMatcher matcher : matchers) {
            TB_MultiContactDuplicateSearchBatch batch = matcher.wrapToBatch();
            if (!doNotRunBatches) {
                database.executeBatch(batch, BATCH_SIZE);
            }
        }
    }

    @TestVisible
    private static List<ObjectMatcher> getObjectMatchers(List<TB_Multi_Contact_Matching_Rule__mdt> matchingRules) {
        Map<String, ObjectMatcher> objectNameToMatcherMap = new Map<String, ObjectMatcher>();
        for (TB_Multi_Contact_Matching_Rule__mdt matchingRule : matchingRules) {
            String objectName = matchingRule.TB_Object_API_Name__c != null && matchingRule.TB_Object_API_Name__c != '' ?
                matchingRule.TB_Object_API_Name__c :
                CONTACT_API_NAME;
            String matchingFieldName = matchingRule.TB_Object_API_Name__c != null && matchingRule.TB_Object_API_Name__c != '' ?
                matchingRule.TB_Object_Matching_Field_API_Name__c :
                matchingRule.TB_Matching_Field_API_Name__c;
            ObjectMatcher matcher = objectNameToMatcherMap.get(objectName) != null ?
                objectNameToMatcherMap.get(objectName) :
                new ObjectMatcher(objectName, matchingRule.TB_Object_Contact_Field_API_Name__c);
            matcher.matchingFields.add(matchingFieldName);
            if (matchingRule.TB_Object_Contact_Field_API_Name__c != null) {
                matcher.relatedContactMatchingFields.add(matchingRule.TB_Matching_Field_API_Name__c);
            }
            objectNameToMatcherMap.put(matchingRule.TB_Object_API_Name__c, matcher);
        }
        return objectNameToMatcherMap.values();
    }

    private static List<TB_Multi_Contact_Matching_Rule__mdt> getMatchingRules() {
        return [
            SELECT TB_Matching_Field_API_Name__c, TB_Object_Matching_Field_API_Name__c, TB_Object_Contact_Field_API_Name__c, TB_Object_API_Name__c
            FROM TB_Multi_Contact_Matching_Rule__mdt 
            WHERE 
                TB_Active__c = true
            ORDER BY TB_Order__c
        ];
    }

    public class ObjectMatcher {
        public String objectName;
        public String contactRelationName;
        public List<String> matchingFields;
        public List<String> relatedContactMatchingFields;

        public ObjectMatcher(String objectName, String contactRelationName) {
            this.objectName = objectName;
            this.contactRelationName = contactRelationName;
            this.matchingFields = new List<String>();
            this.relatedContactMatchingFields = new List<String>();
        }

        public TB_MultiContactDuplicateSearchBatch wrapToBatch() {
            TB_MultiContactDuplicateSearchBatch result = new TB_MultiContactDuplicateSearchBatch(
                objectName,
                contactRelationName,
                matchingFields,
                relatedContactMatchingFields
            );
            return result;
        }
    }
}