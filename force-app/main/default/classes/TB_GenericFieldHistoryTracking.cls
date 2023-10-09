/**
 * Created by kacperjachowicz on 25/08/2021.
 */

public with sharing class TB_GenericFieldHistoryTracking {
    private static final String TB_CUSTOM_FIELD_HISTORY_TRACKING = 'TB_Custom_Field_History_Tracking';

    public static void setFieldHistoryTracking(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        String objectName = retrieveObjectNameById(newMap.keySet());
        Map<Id,User> users = retrieveUsers(newMap);
        List<String> trackedFields = retrieveFieldSet(TB_CUSTOM_FIELD_HISTORY_TRACKING, objectName);
        if(trackedFields == null){
            return;
        }
        List<TB_Data_History__c> dataHistoriesToInsert = new List<TB_Data_History__c>();
        for (SObject record : newMap.values()) {
            for (String trackedField : trackedFields) {
                if (record.get(trackedField) != oldMap.get(record.Id).get(trackedField)) {
                    dataHistoriesToInsert.add(
                            createDataHistoryRecord(
                                    String.valueOf(record.get(trackedField)),
                                    String.valueOf(oldMap.get(record.Id).get((String)trackedField)),
                                    String.valueOf(users.get((Id)record.get('LastModifiedById')).Name),
                                    String.valueOf(objectName),
                                    String.valueOf(trackedField),
                                    String.valueOf(record.Id),
                                    String.valueOf(record.get('Name')),
                                    String.valueOf(Schema.getGlobalDescribe().get(objectName).getDescribe()
                                            .fields.getMap().get(trackedField).getDescribe().getLabel()),
                                    String.valueOf(Schema.getGlobalDescribe().get(objectName).getDescribe().getLabel())
                            )
                    );
                }
            }
        }
        insert dataHistoriesToInsert;
    }

    private static String retrieveObjectNameById(Set<Id> newMapIds) {
        String objectName;
        for (Id objectId : newMapIds) {
            objectName = objectId.getSobjectType().getDescribe().getName();
            break;
        }
        return objectName;
    }

    private static List<String> retrieveFieldSet(String fieldSetName, String ObjectName) {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        try {
            Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.fieldSets.getMap().get(fieldSetName);
            List<String> trackedFields = new List<String>();
            for (Schema.FieldSetMember fieldSetMember : fieldSetObj.getFields()) {
                trackedFields.add(fieldSetMember.getFieldPath());
            }
            return trackedFields;
        }catch(Exception e){
            System.debug(e);
        }
        return null;
    }

    private static TB_Data_History__c createDataHistoryRecord(
            String newValue,
            String oldValue,
            String whoChanged,
            String objectName,
            String fieldName,
            String recordId,
            String recordName,
            String fieldLabel,
            String objectLabel
    ) {
        if (String.isNotBlank(newValue) && newValue.length() > 255) {
            newValue = newValue.substring(0,255);
        }
        if (String.isNotBlank(oldValue) && oldValue.length() > 255) {
            oldValue = oldValue.substring(0,255);
        }
        return new TB_Data_History__c(
            TB_New_Value__c = newValue,
            TB_Prior_Value__c = oldValue,
            TB_User__c = whoChanged,
            TB_Object__c = objectName,
            TB_Field__c = fieldName,
            TB_Record_Id__c = recordId,
            TB_Record_Name__c = recordName,
            TB_Field_Label__c = fieldLabel,
            TB_Object_Label__c = objectLabel,
            TB_Date_of_Change__c = Datetime.now()
        );
    }

    private static Map<Id,User> retrieveUsers(Map<Id,SObject> newMap){
        Set<Id> userIds = new Set<Id>();
        for(SObject currentObject : newMap.values()){
            userIds.add((Id) currentObject.get('LastModifiedById'));
        }
        return new Map<Id, User>([SELECT Id,Name FROM User WHERE Id IN :userIds]);
    }
}