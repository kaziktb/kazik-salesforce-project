/**
 * Created by jowitakozlak on 22/06/2021.
 */

public without sharing class TB_LogUtils {

    public static TB_Log__c registerLog(Exception e, Type classx) {
        TB_Log__c log = registerLog(e);
        log.TB_Class_Name__c = classx.getName();
        return log;
    }

    public static TB_Log__c registerLog(Exception e) {

        TB_Log__c log = new TB_Log__c();
        log.TB_Cause__c = String.valueOf(e.getCause());
        log.TB_Message__c = String.valueOf(e.getMessage());
        log.TB_Line_Number__c = String.valueOf(e.getLineNumber());
        log.TB_Stack_Trace__c = String.valueOf(e.getStackTraceString());

        return log;
    }

    public static TB_Log__c registerLog(Exception e, SObject sObj) {
        return registerLog(e, (String) sObj.Id, sObj.getSObjectType());
    }

    public static TB_Log__c registerLog(Exception e, String recordId, SObjectType recordType) {

        TB_Log__c log = registerLog(e);
        log.TB_Related_Record_Type__c = String.valueOf(recordType);
        log.TB_Related_Record_ID__c = String.valueOf(recordId);

        return log;
    }

    public static TB_Log__c registerLog(Exception e, String recordId, Type classx) {

        TB_Log__c log = registerLog(e);
        log.TB_Class_Name__c = classx.getName();
        log.TB_Related_Record_ID__c = String.valueOf(recordId);

        return log;
    }

    public static List<TB_Log__c> registerLogs(List<String> errors, string source) {

        List<TB_Log__c> logs = new List<TB_Log__c>();

        for(String error: errors) {
            TB_Log__c log = new TB_Log__c();
            log.TB_Message__c = error;
            log.TB_Class_Name__c = source;
        }

        return logs;
    }

    public static TB_Log__c errorRequest(String errorRequest) {
        TB_Log__c log = new TB_Log__c();
        log.TB_Message__c = String.valueOf(errorRequest);

        return log;
    }

    public static TB_Log__c errorMailMessage(String errorMessage, Type classx) {
        TB_Log__c log = new TB_Log__c();
        log.TB_Message__c = String.valueOf(errorMessage);
        log.TB_Class_Name__c = classx.getName();

        return log;
    }

    public static TB_Log__c registerLog(String errorMessage, Type classx) {
        TB_Log__c log = new TB_Log__c();
        log.TB_Message__c = String.valueOf(errorMessage);
        log.TB_Class_Name__c = classx.getName();

        return log;
    }

    public static void registerLogFuture(String errorMessage, String classx){
        TB_Log__c log = new TB_Log__c();
        log.TB_Message__c = String.valueOf(errorMessage);
        log.TB_Class_Name__c = classx;

        insert log;
    }

    public static String composeErrorMessageFromException(Exception e, String recordId, Type classx) {
        String errorMessage = '';
        errorMessage = errorMessage + 'RecordId: ' + recordId;
        errorMessage = errorMessage + ' Class: ' + classx;
        errorMessage = errorMessage + ' Message: ' + e.getMessage();
        errorMessage = errorMessage + ' Stack Trace: ' + e.getStackTraceString();
        errorMessage = errorMessage + ' Cause: ' + e.getCause();
        return errorMessage;
    }

  public static String prepareAuraLog(String message, String className, String stackTrace, String relatedRecord) {
    return message + TB_Constants.TB_AURA_ERROR_SEPARATOR + className + TB_Constants.TB_AURA_ERROR_SEPARATOR + stackTrace + TB_Constants.TB_AURA_ERROR_SEPARATOR + relatedRecord;
  }
    public static TB_Log__c createAuraLog(String message){
        List<String> splitValues = message.split(TB_Constants.TB_AURA_ERROR_SEPARATOR_SPLIT);
        TB_Log__c log = new TB_Log__c();
        log.TB_Message__c = splitValues.get(0);
        log.TB_Class_Name__c =splitValues.get(1);
        log.TB_Stack_Trace__c =splitValues.get(2);
        log.TB_Related_Record_ID__c =splitValues.get(3);
        insert log;
        return log;
    }

}