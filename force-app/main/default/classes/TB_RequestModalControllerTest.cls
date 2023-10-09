/**
 * Created by Aneta on 05/01/2022.
 */
@IsTest
private class TB_RequestModalControllerTest {

    public static String higherEducationRecordTypeId = Schema.SObjectType.TB_Experience_History__c.getRecordTypeInfosByDeveloperName().get('TB_Higher_Education').getRecordTypeId();

    @TestSetup
    static void testSetup() {
        TB_Offered_Product__c product = TB_TestDataFactory.createOfferedProduct(false);
        insert product;

        Contact contact = new Contact(
            LastName = 'Kowalski'
        );
        insert contact;

        hed__Education_History__c educationHistory = new hed__Education_History__c(
            hed__Contact__c = contact.Id
        );
        insert educationHistory;

        hed__Application__c application = TB_TestDataFactory.createApplication(null,product.Id,false);
        application.hed__Applicant__c = contact.Id;
        application.TB_Product_Group__c = 'Higher_Education';
        insert application;

        TB_Experience_History__c experienceHistory = new TB_Experience_History__c(
            TB_Application__c = application.Id,
            RecordTypeId = higherEducationRecordTypeId,
            TB_Not_Diploma__c = false,
            TB_Educational_Institution_Country__c = 'PL',
            TB_Active__c = true
        );
        insert experienceHistory;

        TB_Admissions_Dictionary__c request = TB_TestDataFactory.createRequest(false);
        request.TB_Request__c = true;
        insert request;
    }

    @IsTest
    static void getApplicationPositive() {
        String result;
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        Test.startTest();
        result = TB_RequestModalController.getApplicationForRequest(application.Id, false);
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
        System.assertEquals(true, result != null);
    }

    @IsTest
    static void getApplicationNegative() {
        String result;
        Test.startTest();
        result = TB_RequestModalController.getApplicationForRequest(null, null);
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM TB_Log__c].size());
        System.assertEquals('EXCEPTION_FROM_GET_APPLICATION_REQUEST', result);
    }

    @IsTest
    static void getApplicationPositiveWithRequest() {
        String result;
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        application.TB_No_Required_Diploma__c = true;
        application.TB_Level_of_Study__c = 'Postgraduate';
        update application;
        Test.startTest();
        result = TB_RequestModalController.getApplicationForRequest(application.Id, true);
        Test.stopTest();
        TB_RequestModalController.ApplicationWrapper wrapper
                = (TB_RequestModalController.ApplicationWrapper) JSON.deserialize(result, TB_RequestModalController.ApplicationWrapper.class);
        System.assertEquals(true, wrapper.isRequiredRequest);
        System.assertEquals(true, wrapper.request != null);
        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void getApplicationPositiveWithMoreThanOneRequest() {
        String result;
        TB_Admissions_Dictionary__c request = TB_TestDataFactory.createRequest(false);
        request.TB_Request__c = true;
        insert request;

        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        application.TB_Level_of_Study__c = 'Postgraduate';
        update application;

        Test.startTest();
        result = TB_RequestModalController.getApplicationForRequest(application.Id, true);
        Test.stopTest();

        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
        System.assertEquals(true, result != null);
    }

    @IsTest
    static void updateApplicationNoDiplomaRequestCheckboxPositive() {
        String result;
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        Test.startTest();
        result = TB_RequestModalController.updateApplicationNoDiplomaRequestCheckbox(application.Id);
        Test.stopTest();
        System.assertEquals('SUCCESS',result);
        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
    }

}