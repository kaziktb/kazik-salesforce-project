/**
 * @description       :
 * @author            : slawek.wojcik@avalonsolutions.com
 * @group             :
 * @last modified on  : 12-10-2021
 * @last modified by  : aleksandra.gonta-kacperska@devoteam.com
 * Modifications Log
 * Ver   Date         Author                              Modification
 * 1.0   11-25-2020   slawek.wojcik@avalonsolutions.com   Initial Version
**/
public without sharing class DT_CTTagsCtrl {
    public static String contactId;
    public static final String CONTACT_API_NAME = 'Contact';
    public static final String USER_API_NAME = 'User';

    @AuraEnabled
    public static Map<Id, SObject> getRecordTags(String objName, String recordId, Boolean booleanFlag) {
        String query;

        if (String.isBlank(objName)) {
            throw new AuraHandledException('Object name is empty.');
        }
        if (String.isBlank(recordId)) {
            throw new AuraHandledException('RecordId name is empty.');
        }

        if (objName == USER_API_NAME) {
            matchContactReferenceToCurrentCommunityUser();
            objName = CONTACT_API_NAME;
            recordId = contactId;
        }

        if (objName.equals(DT_Utils.SOBJ_CONTACT)) {
            query = 'SELECT Id, DT_Tag__c, DT_TagName__c, DT_English_Name__c FROM DT_Contact_Tag__c WHERE DT_isProposed__c = :booleanFlag AND DT_Contact__c=\'';
        } else if (objName.equals(DT_Utils.SOBJ_OPPORTUNITY)) {
            query = 'SELECT Id, DT_Tag__c, DT_TagName__c, DT_English_Name__c, DT_Primary__c FROM DT_Opportunity_Tag__c WHERE DT_Opportunity__c=\'';
        } else if (objName.equals(DT_Utils.SOBJ_JOB_OFFER)) {
            query = 'SELECT Id, DT_Tag__c, DT_TagName__c, DT_English_Name__c FROM DT_Job_Offer_Tags__c WHERE DT_Job_Offers__c=\'';
        } else if (objName.equals(DT_Utils.SOBJ_INTERNSHIP)) {
            query = 'SELECT Id, DT_Tag__c, DT_TagName__c, DT_English_Name__c FROM DT_Internship_Tag__c WHERE DT_Internship__c=\'';
        } else {
            throw new AuraHandledException('Object not Supported');
        }
        query += recordId + '\' ORDER BY CreatedDate ASC';
        //implement: escapeSingleQuotes 
        return new Map<Id, Sobject>(Database.query(query));
    }

    private static String getTagObjectName(String componentLocationObjectApiName) {

        List<DT_Tag_Mapping__mdt> tagMappingList = [SELECT ComponentLocationObject__c, DatabaseTargetObject__c FROM DT_Tag_Mapping__mdt WHERE ComponentLocationObject__c = :componentLocationObjectApiName LIMIT 1];

        if (String.isNotBlank(componentLocationObjectApiName) && tagMappingList.size() > 0) {
            return tagMappingList[0].DatabaseTargetObject__c;
        } else {
            throw new AuraHandledException(Label.DT_UnSupported_Object_ErrorMsg);
        }
    }

    @AuraEnabled
    public static void save(String objName, String recordId, List<String> idsToRemove, List<String> idsToCreate, Boolean booleanFlag) {
        if (objName == USER_API_NAME) {
            matchContactReferenceToCurrentCommunityUser();
            objName = CONTACT_API_NAME;
            recordId = contactId;
        }

        String objToUpdate = getTagObjectName(objName);

        Type objNameType = Type.forName(objToUpdate);
        if (objNameType == null) {
            throw new AuraHandledException(Label.DT_Missing_Object_ErrorMsg);
        }

        if (!idsToRemove.isEmpty()) {
            List<SObject> listToDelete = new List<SObject>();

            for (String recId : idsToRemove) {
                SObject genericObject = (SObject) Schema.getGlobalDescribe().get(objToUpdate).newSObject(recId);
                listToDelete.add(genericObject);
            }
            try {
                delete listToDelete;
            } catch (Exception exp) {

            }

        }
        if (!idsToCreate.isEmpty()) {
            List<SObject> listToCreate = new List<SObject>();

            for (String recId : idsToCreate) {
                SObject genericObject = (SObject) Schema.getGlobalDescribe().get(objToUpdate).newSObject();
                if (objToUpdate.equals('DT_Contact_Tag__c')) {
                    genericObject.put('DT_Contact__c', recordId);
                    genericObject.put('DT_isProposed__c', booleanFlag);
                } else if (objToUpdate.equals('DT_Opportunity_Tag__c')) {
                    genericObject.put('DT_Opportunity__c', recordId);
                    genericObject.put('DT_Primary__c', booleanFlag);
                } else if (objToUpdate.equals('DT_Job_Offer_Tags__c')) {
                    genericObject.put('DT_Job_Offers__c', recordId);
                } else if (objToUpdate.equals('DT_Internship_Tag__c')) {
                    genericObject.put('DT_Internship__c', recordId);
                }
                genericObject.put('DT_Tag__c', recId);
                listToCreate.add(genericObject);
            }
            insert listToCreate;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getAvailableCategories() {
        List<String> result = new List<String>();
        for (Schema.PicklistEntry pe : DT_Tag__c.DT_Category__c.getDescribe().getPicklistValues()) {
            result.add(pe.getLabel());
        }
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getAvailableTypes() {
        List<String> result = new List<String>();
        for (Schema.PicklistEntry pe : DT_Tag__c.DT_Type__c.getDescribe().getPicklistValues()) {
            result.add(pe.getLabel());
        }
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static List<DT_Tag__c> searchTags(String category, String type, String searchTerm, List<String> currentTagSet, String guestLanguage) {

        String query = 'SELECT Id, Name, DT_English_Name__c FROM DT_Tag__c WHERE ';
        if (String.isNotBlank(category) && !'All'.equalsIgnoreCase(category)) {
            query += 'toLabel(DT_Category__c) = :category AND ';
        }

        if (String.isNotBlank(type) && !'All'.equalsIgnoreCase(type)) {
            query += 'toLabel(DT_Type__c) = :type AND ';
        }

        if (!currentTagSet.isEmpty()) {
            query += 'Id NOT IN :currentTagSet AND ';
        }
        if (String.isNotBlank(searchTerm)) {
            query += '(Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\' OR DT_English_Name__c LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\')';
        }
        query = query.removeEnd(' WHERE ');
        query = query.removeEnd(' AND ');
        if (DT_Utils.getCurrentUserLanguage()=='pl' || guestLanguage=='pl') {
            query += ' ORDER BY Name ASC';  
        } else {
            query += ' ORDER BY DT_English_Name__c ASC';
        }
        return Database.query(query);
    }

    public static User getCurrentUserDetails() {
        return [
                SELECT Id, ContactId
                FROM User
                WHERE Id = :UserInfo.getUserId()
        ];
    }

    private static void matchContactReferenceToCurrentCommunityUser() {
        if (contactId == null) {
            contactId = getCurrentUserDetails().ContactId;
        }
    }
}