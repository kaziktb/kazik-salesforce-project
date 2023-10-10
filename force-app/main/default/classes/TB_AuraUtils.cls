public without sharing class TB_AuraUtils {

    private static final String errorException = 'Disconnected or Canceled';

    @AuraEnabled
    public static TB_Log__c createLog (String message) {
        TB_Log__c log = TB_LogUtils.registerLog(message,TB_AuraUtils.class);

        insert log;
        return log;
    }

    @AuraEnabled
    public static TB_Log__c createLogWithParams(String message){
        return TB_LogUtils.createAuraLog(message);
    }

    @AuraEnabled
    public static TB_Log__c createLogFromLWC(String message, String componentName, String stackTrace, String lineNumber) {
        if (!message.contains(errorException)) {
            TB_Log__c log = new TB_Log__c(
                TB_Class_Name__c = componentName,
                TB_Message__c = message,
                TB_Stack_Trace__c = stackTrace,
                TB_Line_Number__c = lineNumber
            );
            insert log;
            return log;
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static String getCurrentContact() {
        Id userId = UserInfo.getUserId();
        Contact con;
        if (String.isNotBlank(userId)) {
            User u = [SELECT Id, ContactId, Contact.TB_Test__c FROM User WHERE Id = :userId];
            if (String.isNotBlank(u.ContactId)) {
                con = [SELECT Id, TB_Test__c FROM Contact WHERE Id = :u.ContactId];
            }
        }

        return JSON.serialize(con);
    }

    @AuraEnabled
    public static String getCurrentApplicant(String applicationId) {
        hed__Application__c application = [
            SELECT hed__Applicant__c
            FROM hed__Application__c
            WHERE Id = :applicationId
        ];
        return application.hed__Applicant__c;
    }

}