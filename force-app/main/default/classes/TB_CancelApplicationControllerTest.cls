/**
 * Created by Aneta on 18/10/2021.
 */

@IsTest
private class TB_CancelApplicationControllerTest {

    @TestSetup
    static void testSetup() {
        insert new TB_Marketing_Cloud_API__c(
            TB_Auth_End_Point__c = 'https://test.com',
            TB_POST_End_Point__c = 'https://test.com'
        );

        TB_Admissions_Dictionary__c dictionary = new TB_Admissions_Dictionary__c(
            Name = 'Inny',
            RecordTypeId = TB_Constants.ADMISSIONS_DICTIONARY_RT_RESIGNATION_REASON_ID
        );
        insert dictionary;

        TB_Offered_Product__c product = TB_TestDataFactory.createOfferedProduct(false);
        insert product;

        Contact contact = new Contact(
            LastName = 'Kowalski'
        );
        insert contact;

        hed__Application__c application = TB_TestDataFactory.createApplication(null, product.Id,false);
        application.hed__Applicant__c = contact.Id;
        insert application;
    }

    @IsTest
    static void getResignationReasons() {
        List<TB_CancelApplicationController.AdmissionReasonWrapper> wrappers;
        Test.startTest();
        wrappers = TB_CancelApplicationController.getResignationReasons();
        Test.stopTest();
        System.assertEquals(1,wrappers.size());
    }

    @IsTest
    static void cancelApplicationNegative() {
        hed__Application__c application = [
            SELECT Id
            FROM hed__Application__c
            LIMIT 1
        ];
        Test.startTest();
        String result = TB_CancelApplicationController.cancelApplication(application.Id,'fakeReasonId','testResignationInfo');
        Test.stopTest();
        System.assertEquals('CANCEL_APPLICATION.EXCEPTION',result);
    }

    @IsTest
    static void cancelApplicationPositive() {
        Test.setMock(HttpCalloutMock.class, new TB_MCClientQueueableBatchMock());
        hed__Application__c application = [
            SELECT Id
            FROM hed__Application__c
            LIMIT 1
        ];
        TB_Admissions_Dictionary__c reason = [
            SELECT Id
            FROM TB_Admissions_Dictionary__c
            WHERE  Name = 'Inny'
        ];

        Test.startTest();
        String result = TB_CancelApplicationController.cancelApplication(application.Id, reason.Id,'testResignationInfo');
        Test.stopTest();

        System.assertEquals('CANCEL_APPLICATION.SUCCESS',result);
    }

}