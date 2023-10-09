public without sharing class TB_vu_Utils {
    public static String registerLog(String errorMessage, String className, String stackTrace, String relatedRecord) {
        TB_vu_InsertLog__e insertLogEvent = new TB_vu_InsertLog__e(
            TB_vu_errorMessage__c = errorMessage,
            TB_vu_className__c = className,
            TB_vu_stackTrace__c = stackTrace,
            TB_vu_relatedRecord__c = relatedRecord,
            TB_vu_user__c = UserInfo.getUserId()
        );

        EventBus.publish(insertLogEvent);

        return errorMessage + TB_Constants.TB_AURA_ERROR_SEPARATOR + className + TB_Constants.TB_AURA_ERROR_SEPARATOR + stackTrace + TB_Constants.TB_AURA_ERROR_SEPARATOR + relatedRecord;
    }
    
    public static String registerLog(Exception e, Type apexClass, String relatedRecord) {
        TB_vu_InsertLog__e insertLogEvent = new TB_vu_InsertLog__e(
            TB_vu_errorMessage__c = e.getMessage(),
            TB_vu_className__c = apexClass.getName(),
            TB_vu_stackTrace__c = e.getStackTraceString(),
            TB_vu_relatedRecord__c = relatedRecord,
            TB_vu_user__c = UserInfo.getUserId()
        );

        EventBus.publish(insertLogEvent);

        return insertLogEvent.TB_vu_errorMessage__c + TB_Constants.TB_AURA_ERROR_SEPARATOR + insertLogEvent.TB_vu_className__c + TB_Constants.TB_AURA_ERROR_SEPARATOR + insertLogEvent.TB_vu_stackTrace__c + TB_Constants.TB_AURA_ERROR_SEPARATOR + relatedRecord;
    }
}