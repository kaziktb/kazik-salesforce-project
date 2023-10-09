public with sharing class Utils {
    public static Boolean isFieldChanged(SObject obj, Map<Id, SObject> objectId2OldObject, SObjectField field) {
        if (objectId2OldObject == null) {
            return true;
        }

        SObject oldObject = objectId2OldObject.get(obj.Id);

        Object oldFieldValue = oldObject.get(field);
        Object newFieldValue = obj.get(field);

        return oldFieldValue != newFieldValue;
    }

    public static Id getRecordTypeIdByDevName(SObject obj, String recordTypeDeveloperName) {
        return obj.getSObjectType()
            .getDescribe()
            .getRecordTypeInfosByDeveloperName()
            .get(recordTypeDeveloperName)
            .getRecordTypeId();
    }

    public static Id getRecordTypeIdByDevName(SObjectType objectType, String recordTypeDeveloperName) {
        return objectType
            .getDescribe()
            .getRecordTypeInfosByDeveloperName()
            .get(recordTypeDeveloperName)
            .getRecordTypeId();
    }

    public static User retrieveProcessAutomationUser() {
        return [SELECT Id FROM User WHERE Name =: Constants.CAREER_SERVICES_PROCESS_AUTOMATION_USER_NAME];
    }

    public static Id getUserRoleIdByName(String roleName){
        return [SELECT Id FROM UserRole WHERE Name =: roleName LIMIT 1].Id;
    }

    public static Id getProfileIdByName(String profileName){
        return [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1].Id;
    }

    public static Id getPermissionSetIdByName(String permissionSetName){
        return [SELECT Id FROM PermissionSet WHERE Name = :permissionSetName LIMIT 1].Id;
    }

    public static PermissionSetAssignment createPermissionSetAssignment(Id userId, Id permissionSetId) {
        return new PermissionSetAssignment(
            AssigneeId = userId,
            PermissionSetId = permissionSetId
        );
    }

    public static String buildMultiselectOrCondition(String multiselectString) {
        return '(\'' + String.join(multiselectString.split(';'), '\',\'') + '\') ';
    }

    public static String buildMultiselectOrCondition(Iterable<String> collection) {
        return '(\'' + String.join(collection, '\',\'') + '\') ';
    }
        
    public static void assignRecordFields(SObject record, Map<String, String> fieldsToUpdate) {
        for (String fieldName : fieldsToUpdate.keySet()) {
            record.put(fieldName, fieldsToUpdate.get(fieldName));
        }
    }

    public static Boolean isPermissionSetAssigned(String permissionSetName, Id userId) {
       return ![SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :userId AND PermissionSetId = :getPermissionSetIdByName(permissionSetName)].isEmpty();
    }
}