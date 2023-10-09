/**
 * Created by Aneta on 05/10/2021.
 */

@IsTest
private class TB_AdmissionFormsDetailsControllerTest {

    public static TB_AdmissionFormsDetailsController.ApplicationWrapper wrapper;

    @TestSetup
    static void testSetup() {

        TB_Offered_Product__c product = TB_TestDataFactory.createOfferedProduct(false);
        insert product;

        Contact contact = new Contact(
            LastName = 'Kowalski'
        );
        insert contact;

        hed__Application__c application = TB_TestDataFactory.createApplication(null,product.Id,false);
        application.hed__Applicant__c = contact.Id;
        insert application;
    }

    @IsTest
    static void getApplicationWrappersPositive() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];

        Test.startTest();
        wrapper = TB_AdmissionFormsDetailsController.getApplicationWrappers(application.Id);
        Test.stopTest();

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void getApplicationWrappersNegative() {
        Contact contact = [SELECT Id FROM Contact WHERE LastName = 'Kowalski'];

        Test.startTest();
        wrapper = TB_AdmissionFormsDetailsController.getApplicationWrappers(contact.Id);
        Test.stopTest();

        System.assertEquals(null,wrapper);
        System.assertEquals(1,[SELECT Id FROM TB_Log__c].size());
    }
}