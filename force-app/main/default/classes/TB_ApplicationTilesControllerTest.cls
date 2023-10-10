/**
 * Created by Aneta on 25/08/2021.
 */

@IsTest
private class TB_ApplicationTilesControllerTest {
    @TestSetup
    private static void testSetup() {

        Contact contact = TB_TestDataFactory.createContact(false);
        contact.TB_Test__c = true;
        insert contact;

        TB_Offered_Product__c offeredProduct = new TB_Offered_Product__c(
            Name = 'offeredProduct'
        );
        insert offeredProduct;

        Account faculty = new Account(
            Name = 'Faculty',
            TB_Account_Name_PL__c = 'Faculty_PL',
            TB_Account_Name_EN__c = 'Faculty_EN'
        );
        insert faculty;

        Account campus = new Account(
            Name = 'Campus',
            TB_Account_Name_PL__c = 'Campus_PL',
            TB_Account_Name_EN__c = 'Campus_EN'
        );
        insert campus;

        hed__Application__c applicationInformation
            = TB_TestDataFactory.createApplicationWithComments(faculty.Id, campus.Id, offeredProduct.Id, contact.Id, 'Information', false);
       insert applicationInformation;

        hed__Application__c applicationStop
            = TB_TestDataFactory.createApplicationWithComments(faculty.Id, campus.Id, offeredProduct.Id, contact.Id, 'Stop', false);
        applicationStop.TB_Comments_To_Applicant__c = '<h2>Test</h2>';
        insert applicationStop;

        hed__Application__c applicationWarning
            = TB_TestDataFactory.createApplicationWithComments(faculty.Id, campus.Id, offeredProduct.Id, contact.Id, 'Warning', false);
        insert applicationWarning;

        hed__Application__c application = new hed__Application__c(
            TB_Active__c = true,
            TB_Archived__c = false,
            hed__Application_Status__c = 'Verification',
            TB_Comments_To_Applicant__c = 'Test',
            TB_Faculty__c = faculty.Id,
            TB_Campus__c = campus.Id,
            TB_Mode_of_Study__c = 'Full_Time',
            TB_Level_of_Study__c = 'Master',
            hed__Applicant__c = contact.Id,
            TB_Applying_To_Offered_Product__c = offeredProduct.Id
        );
        insert application;
    }

    @IsTest
    private static void getContact() {
        Test.startTest();
        String contactId = TB_ApplicationTilesController.getContact();
        Test.stopTest();
        System.assertEquals(null,contactId);
    }

    @IsTest
    private static void getApplicationWrappersPositive() {
        Contact contact = [SELECT Id, TB_Test__c FROM Contact LIMIT 1];
        Test.startTest();
        String wrappers = TB_ApplicationTilesController.getApplicationWrappers('EN',contact.Id,true);
        Test.stopTest();

        List<TB_ApplicationTilesController.ApplicationWrapper> applicationWrappers
            = (List<TB_ApplicationTilesController.ApplicationWrapper>) JSON.deserialize(wrappers, List<TB_ApplicationTilesController.ApplicationWrapper>.class);
        System.assertEquals(4, applicationWrappers.size());
    }

    @IsTest
    private static void getApplicationWrappersPositivePL() {
        Contact contact = [SELECT Id, TB_Test__c FROM Contact LIMIT 1];
        Test.startTest();
        String wrappers = TB_ApplicationTilesController.getApplicationWrappers('PL',contact.Id,true);
        Test.stopTest();
        List<TB_ApplicationTilesController.ApplicationWrapper> applicationWrappers
            = (List<TB_ApplicationTilesController.ApplicationWrapper>) JSON.deserialize(wrappers, List<TB_ApplicationTilesController.ApplicationWrapper>.class);
        System.assertEquals(4, applicationWrappers.size());
    }

    @IsTest
    private static void getApplicationWrappersPositiveTestFalse() {
        Contact contact = [SELECT Id, TB_Test__c FROM Contact LIMIT 1];
        contact.TB_Test__c = false;
        update  contact;
        Test.startTest();
        String wrappers = TB_ApplicationTilesController.getApplicationWrappers('EN',contact.Id,false);
        Test.stopTest();
        List<TB_ApplicationTilesController.ApplicationWrapper> applicationWrappers
            = (List<TB_ApplicationTilesController.ApplicationWrapper>) JSON.deserialize(wrappers, List<TB_ApplicationTilesController.ApplicationWrapper>.class);
        System.assertEquals(4, applicationWrappers.size());
    }

    @IsTest
    private static void getApplicationWrappersNegative() {
        Test.startTest();
        String wrappers = TB_ApplicationTilesController.getApplicationWrappers('EN',null,true);
        Test.stopTest();
        System.assertEquals(null, wrappers);
    }

    @IsTest
    private static void getApplicationWrappersNegativeLanguage() {
        Test.startTest();
        String wrappers = TB_ApplicationTilesController.getApplicationWrappers('failed',null,true);
        Test.stopTest();
        System.assertEquals(null, wrappers);
    }

}