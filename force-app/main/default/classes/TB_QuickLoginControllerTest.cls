@IsTest
private with sharing class TB_QuickLoginControllerTest {

    @IsTest
    private static void getQuickLoginUrlNegative() {
        String result;
        Test.startTest();
        result = TB_QuickLoginController.getQuickLoginUrl(null);
        Test.stopTest();
        System.assertEquals(null, result);
        System.assertEquals(1, [SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    private static void getQuickLoginUrlPositive() {
        String result;
        Id applicationId = TB_TestDataFactory.createApplicationWithRelatedObjects(true).Id;
        Test.startTest();
        result = TB_QuickLoginController.getQuickLoginUrl(applicationId);
        Test.stopTest();
        System.assertEquals(true, result != null);
        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    private static void getQuickLoginUrlFromContactPositive() {
        String result;
        Id contactId = TB_TestDataFactory.createContact(true).Id;
        Test.startTest();
        result = TB_QuickLoginController.getQuickLoginUrl(contactId);
        Test.stopTest();
        System.assertEquals(true, result != null);
        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
    }
}