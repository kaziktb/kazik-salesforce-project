public with sharing class Logger {
    public static Logger__c saveLog(Exception ex) {
        String stackTrace = ex.getStackTraceString();

        Logger__c logger = new Logger__c(
            Apex_Class_Name__c = getClassNameFromStackTrace(stackTrace),
            Apex_Method_Name__c = getMethodNameFromStackTrace(stackTrace),
            Exception_Message__c = ex.getMessage(),
            Exception_Type__c = ex.getTypeName(),
            Stack_Trace__c = stackTrace
        );

        insert logger;

        return logger;
    }
    private static String getClassNameFromStackTrace(String stackTrace) {
        return stackTrace.substringAfter('Class.').substringBefore('.');
    }

    private static String getMethodNameFromStackTrace(String stackTrace) {
        return stackTrace.substringBefore(':').substringAfterLast('.');
    }
}