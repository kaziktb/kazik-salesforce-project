/**
 * Created by Aneta on 06/12/2021.
 */

@IsTest
private class TB_EducationHistoryControllerTest {

    public static String higherEducationRecordTypeId = Schema.SObjectType.TB_Experience_History__c.getRecordTypeInfosByDeveloperName().get('TB_Higher_Education').getRecordTypeId();

    @TestSetup
    static void testSetup() {
        TB_Offered_Product__c product = TB_TestDataFactory.createOfferedProduct(false);
        insert product;

        Contact contact = TB_TestDataFactory.createContact(false);
        insert contact;

        hed__Education_History__c educationHistory = new hed__Education_History__c(
            hed__Contact__c = contact.Id,
            TB_SWPS_Education__c = true
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

        TB_Application_Document__c applicationDocument = new TB_Application_Document__c(
            TB_Experience__c = experienceHistory.Id,
            TB_Active__c = true,
            TB_Application__c = application.Id,
            TB_Document_Type__c = 'Scan',
            TB_Status__c = 'Rejected'
        );
        insert applicationDocument;

        TB_Application_Document__c applicationDocumentEmpty = new TB_Application_Document__c(
            TB_Experience__c = experienceHistory.Id,
            TB_Active__c = true,
            TB_Application__c = application.Id,
            TB_Document_Type__c = 'Scan',
            TB_Status__c = 'Empty'
        );
        insert applicationDocumentEmpty;

        TB_Application_Document__c applicationDocumentToVerify = new TB_Application_Document__c(
            TB_Experience__c = experienceHistory.Id,
            TB_Active__c = true,
            TB_Application__c = application.Id,
            TB_Document_Type__c = 'Scan',
            TB_Status__c = 'To_Verify'
        );
        insert applicationDocumentToVerify;

        TB_Application_Document__c applicationDocumentVerified = new TB_Application_Document__c(
            TB_Experience__c = experienceHistory.Id,
            TB_Active__c = true,
            TB_Application__c = application.Id,
            TB_Document_Type__c = 'Scan',
            TB_Status__c = 'Verified'
        );
        insert applicationDocumentVerified;

        TB_Application_Document__c applicationDocumentToCorrect = new TB_Application_Document__c(
            TB_Experience__c = experienceHistory.Id,
            TB_Active__c = true,
            TB_Application__c = application.Id,
            TB_Document_Type__c = 'Scan',
            TB_Status__c = 'To_Correct'
        );
        insert applicationDocumentToCorrect;

        TB_Admissions_Dictionary__c request = TB_TestDataFactory.createRequest(false);
        request.TB_Request__c = true;
        insert request;
    }

    @IsTest
    static void getApplicationPositive() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        Test.startTest();
        TB_EducationHistoryController.getApplication(application.Id);
        Test.stopTest();
    }

    @IsTest
    static void getApplicationPositiveWithRequest() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        application.TB_No_Diploma__c = true;
        application.TB_Level_of_Study__c = 'Postgraduate';
        update application;
        Test.startTest();
        TB_EducationHistoryController.getApplication(application.Id);
        Test.stopTest();
    }

    @IsTest
    static void getApplicationPositiveWithMoreThanOneRequest() {
        TB_Admissions_Dictionary__c request = TB_TestDataFactory.createRequest(false);
        request.TB_Request__c = true;
        insert request;

        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        application.TB_No_Diploma__c = true;
        application.TB_Level_of_Study__c = 'Postgraduate';
        update application;

        Test.startTest();
        TB_EducationHistoryController.getApplication(application.Id);
        Test.stopTest();
    }

    @IsTest
    static void getEducationHistories() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        TB_EducationHistoryController.getEducationHistories(contact.Id);
        Test.stopTest();
    }

    @IsTest
    static void getExperienceHistory() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        Test.startTest();
        TB_EducationHistoryController.getExperienceHistoryWithDocuments(application.Id);
        Test.stopTest();
    }

    @IsTest
    static void updateNewExperienceHistoryNewExperience() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        TB_Experience_History__c experienceHistory = new TB_Experience_History__c(
            TB_Application__c = application.Id,
            RecordTypeId = higherEducationRecordTypeId,
            TB_Active__c = true
        );
        Test.startTest();
        TB_EducationHistoryController.updateNewExperienceHistory(JSON.serialize(experienceHistory),
            'Higher_Education', contact.Id, application.Id, false);
        Test.stopTest();
    }

    @IsTest
    static void updateNewExperienceHistoryEditExperience() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        TB_Experience_History__c experienceHistory = [SELECT Id, TB_Educational_Institution_Country__c, TB_Not_Diploma__c FROM TB_Experience_History__c LIMIT 1];
        Test.startTest();
        TB_EducationHistoryController.updateNewExperienceHistory(JSON.serialize(experienceHistory),
            'Higher_Education', contact.Id, application.Id, false);
        Test.stopTest();
    }

    @IsTest
    static void updateNewExperienceHistoryChangeGroup() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        TB_Experience_History__c experienceHistory = [SELECT Id, TB_Not_Diploma__c, TB_Educational_Institution_Country__c FROM TB_Experience_History__c LIMIT 1];
        Test.startTest();
        TB_EducationHistoryController.updateNewExperienceHistory(JSON.serialize(experienceHistory),
            'Higher_Education', contact.Id, application.Id, true);
        Test.stopTest();
    }

    @IsTest
    static void deactivateExperienceHistoryPositive() {
        TB_Experience_History__c experienceHistory = [SELECT Id, TB_Not_Diploma__c, TB_Educational_Institution_Country__c FROM TB_Experience_History__c LIMIT 1];
        TB_EducationHistoryController.ExperienceHistoryWrapper experienceWrapper = new TB_EducationHistoryController.ExperienceHistoryWrapper(experienceHistory);
        Test.startTest();
        TB_EducationHistoryController.deleteExperienceHistory(JSON.serialize(experienceWrapper));
        Test.stopTest();
    }

    @IsTest
    static void deactivateExperienceHistoryNegative() {
        Test.startTest();
        TB_EducationHistoryController.deleteExperienceHistory(null);
        Test.stopTest();
    }

    @IsTest
    static void getEarnedTitlePicklistPL() {
        Test.startTest();
        TB_EducationHistoryController.getEarnedTitlePicklistPL();
        Test.stopTest();
    }

    @IsTest
    static void getEarnedTitlePicklistEN() {
        Test.startTest();
        TB_EducationHistoryController.getEarnedTitlePicklistEN();
        Test.stopTest();
    }

    @IsTest
    static void getPicklistByApiName() {
        Test.startTest();
        TB_EducationHistoryController.getPicklistByApiName('TB_Experience_History__c','TB_Educational_Institution_Country__c');
        Test.stopTest();
    }

    @IsTest
    static void deleteApplicationDocument() {
        TB_Application_Document__c document = [SELECT Id FROM TB_Application_Document__c WHERE TB_Status__c = 'Rejected' LIMIT 1];
        Test.startTest();
        TB_EducationHistoryController.deleteApplicationDocument(document.Id);
        Test.stopTest();
    }

    @IsTest
    static void updateApplicationCheckboxes() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        Test.startTest();
        TB_EducationHistoryController.updateApplicationCheckboxes(application.Id, true, true);
        Test.stopTest();
        hed__Application__c applicationAfter = [SELECT Id, TB_No_Other_Education__c FROM hed__Application__c LIMIT 1];
        System.assertEquals(true, applicationAfter.TB_No_Other_Education__c);
    }

    @IsTest
    static void updateApplicationCheckboxesNegative() {
        Test.startTest();
        String result = TB_EducationHistoryController.updateApplicationCheckboxes(null, false, true);
        Test.stopTest();
        System.assertEquals('FAILED', result);
    }

    @IsTest
    static void getApplicationNoRequiredStatusNegative() {
        Test.startTest();
        Boolean result = TB_EducationHistoryController.getApplicationNoRequiredStatus(null);
        Test.stopTest();
        System.assertEquals(null, result);
    }

    @IsTest
    static void getApplicationNoRequiredStatusPositive() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        Test.startTest();
        Boolean result = TB_EducationHistoryController.getApplicationNoRequiredStatus(application.Id);
        Test.stopTest();
        System.assertEquals(false, result);
    }
}