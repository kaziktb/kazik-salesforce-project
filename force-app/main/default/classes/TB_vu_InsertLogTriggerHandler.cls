public class TB_vu_InsertLogTriggerHandler {
    public static void insertLog(TB_vu_InsertLog__e logEventData) {
        insert new TB_Log__c(
            TB_Message__c = logEventData.TB_vu_errorMessage__c,
            TB_Class_Name__c = logEventData.TB_vu_className__c,
            TB_Stack_Trace__c = logEventData.TB_vu_stackTrace__c,
            TB_Related_Record_ID__c = logEventData.TB_vu_relatedRecord__c
        );
    }
}