@IsTest
public with sharing class LoggerTest {
    @IsTest
    public static void logException() {
        final String THIS_METHOD_NAME = 'logException';
        DmlException dmlException = new DmlException();

        Test.startTest();
        try {
            throw dmlException;
        } catch (DmlException ex) {
            Logger.saveLog(ex);
        }
        Test.stopTest();

        Logger__c log =
        [
            SELECT
                Exception_Message__c,
                Stack_Trace__c,
                Apex_Class_Name__c,
                Apex_Method_Name__c,
                Exception_Type__c
            FROM Logger__c
            WHERE Apex_Method_Name__c = :THIS_METHOD_NAME
            LIMIT 1
        ];

        Assert.isNotNull(log);
        Assert.isNotNull(log.Exception_Message__c);
        Assert.isNotNull(log.Stack_Trace__c);
        Assert.areEqual('LoggerTest', log.Apex_Class_Name__c);
        Assert.areEqual(THIS_METHOD_NAME, log.Apex_Method_Name__c);
        Assert.areEqual(dmlException.getTypeName(), log.Exception_Type__c);
    }
}