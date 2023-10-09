public with sharing class TB_vu_ApplicationAppealController {
    private static final String AUTHOR_STUDENT='Student';
    private static final String TYPE_EXTERNAL_COMMENT='External_Comment';
    private static final String TYPE_NEW='New';
    private static final String RECORD_TYPE_CONVERSATION='TB_Conversation';

    @AuraEnabled
    public static String getApplicationComment(String operationId){
        try {
            return [SELECT Id, TB_Description_Rich_Text__c FROM TB_Operation__c WHERE Id =: operationId].TB_Description_Rich_Text__c;
        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_ApplicationAppealController.class.getName(),e.getStackTraceString(),''));
        }
    }

    @AuraEnabled
    public static void sendApplicationAppeal(String operationId, String description){
        try {
            String caseId = [SELECT Id, TB_Case__c FROM TB_Operation__c WHERE Id =: operationId].TB_Case__c;

            Case parentCase = [
                SELECT
                    Id,
                    TB_Category__c,
                    TB_Subcategory__c,
                    TB_Program_Enrollment__c,
                    Subject,
                    TB_Description_Rich_Text__c,
                    Language,
                    ContactId,
                    AccountId,
                    Priority,
                    Status,
                    Origin,
                    RecordTypeId,
                    TB_Appeal__c,
                    TB_Program_Enrollment__r.TB_Study_Name_With_Attributes_PL__c,
                    TB_Program_Enrollment__r.TB_Study_Name_With_Attributes_EN__c
                FROM
                    Case
                WHERE
                    Id =: caseId];
                    
            parentCase.TB_Appeal__c = true;
            update parentCase;

            Case caseAppeal = parentCase.clone(false, true, false, true);
            caseAppeal.Status = TYPE_NEW;
            caseAppeal.ParentId = parentCase.Id;
            caseAppeal.TB_Description_Rich_Text__c = description;
            insert caseAppeal;

            TB_Operation__c newOperation = new TB_Operation__c(
                TB_Author__c = AUTHOR_STUDENT,
                TB_Case__c = caseAppeal.Id,
                TB_Description_Rich_Text__c = description,
                TB_Contact__c = caseAppeal.ContactId,
                TB_Publish__c = true,
                RecordTypeId = Schema.SObjectType.TB_Operation__c.getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_CONVERSATION).getRecordTypeId(),
                TB_Type__c = TYPE_EXTERNAL_COMMENT,
                TB_Initial__c = true,
                TB_Case_Study_Name_With_Attributes_PL__c = caseAppeal.TB_Program_Enrollment__r.TB_Study_Name_With_Attributes_PL__c,
                TB_Case_Study_Name_With_Attributes_EN__c = caseAppeal.TB_Program_Enrollment__r.TB_Study_Name_With_Attributes_EN__c
            );

            insert newOperation;

        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_ApplicationAppealController.class.getName(),e.getStackTraceString(),''));
        }
    }
}