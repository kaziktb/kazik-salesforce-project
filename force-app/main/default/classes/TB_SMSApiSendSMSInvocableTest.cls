@IsTest
public with sharing class TB_SMSApiSendSMSInvocableTest {

    @IsTest
    public static void sendSMSTestPositive () {
        Test.setMock(HttpCalloutMock.class, new TB_SMSApiSendSMSInvocableMock('success'));
        TB_SMSApiSendSMSInvocable.SendSMSWrapperClass sendSMSWrapperClass
                = new TB_SMSApiSendSMSInvocable.SendSMSWrapperClass();

        sendSMSWrapperClass.phoneNumbers = '000111222';
        sendSMSWrapperClass.textMessage = 'Test message';

        Test.startTest();
        TB_SMSApiSendSMSInvocable.sendSMS(new List<TB_SMSApiSendSMSInvocable.SendSMSWrapperClass>{sendSMSWrapperClass});
        Test.stopTest();

        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    public static void sendSMSTestNegative () {
        Test.setMock(HttpCalloutMock.class, new TB_SMSApiSendSMSInvocableMock('fail'));
        TB_SMSApiSendSMSInvocable.SendSMSWrapperClass sendSMSWrapperClass
                = new TB_SMSApiSendSMSInvocable.SendSMSWrapperClass();

        sendSMSWrapperClass.phoneNumbers = '000111222';
        sendSMSWrapperClass.textMessage = 'Test message';

        Test.startTest();
        TB_SMSApiSendSMSInvocable.sendSMS(new List<TB_SMSApiSendSMSInvocable.SendSMSWrapperClass>{sendSMSWrapperClass});
        Test.stopTest();

        System.assertEquals(1, [SELECT Id FROM TB_Log__c].size());
    }
}