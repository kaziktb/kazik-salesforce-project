@isTest
private without sharing class TB_ScoreCalculatorTest {
    @TestSetup
    public static void dataFactory(){
        Contact testContact = new Contact();
        testContact.LastName = 'Test';

        insert testContact;

        TB_Offered_Product__c offeredProduct = new TB_Offered_Product__c();
        offeredProduct.Name = 'Test product';
        insert offeredProduct;

        hed__Application__c application = new hed__Application__c();
        application.hed__Applicant__c = testContact.id;
        application.TB_Applying_To_Offered_Product__c = offeredProduct.id;
        application.TB_Applicant_Citizenship__c = 'Poland';

        insert application;
    }

    @isTest
    public static void calculatorTest(){
        List<String> applicationIds = new List<String>();
        applicationIds.add([SELECT Id FROM hed__Application__c].Id);
        test.startTest();
        List<Decimal> scoresList = TB_ScoreCalculator.calculateScores(applicationIds);
        test.stopTest();
        System.assertNotEquals(0, scoresList.size());
    }
}