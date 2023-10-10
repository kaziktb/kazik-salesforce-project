/**
 * Created by annaseveryna on 08/12/2021.
 */
@IsTest
public with sharing class TB_RequestControllerTest {

    @TestSetup
    static void requestSetup() {
        Contact contact = TB_TestDataFactory.createContact(false);
        contact.LastName = 'Kowalski';
        contact.hed__Citizenship__c = 'Angola';
        insert contact;

        TB_Offered_Product__c studies = new TB_Offered_Product__c(
                Name = 'Test Studies',
                TB_Language_of_Study__c = 'English',
                TB_Mode_of_Study__c = 'Full_Time',
                TB_Level_of_Study__c = 'Bachelor',
                TB_Product_Name_PL__c = 'Name'
        );
        insert studies;

        hed__Application__c application = new hed__Application__c(
                TB_Applying_To_Offered_Product__c = studies.Id,
                TB_Applicant_Citizenship__c = 'Angola',
                TB_HS_Exam_Type__c = 'New_Polish_HS_Exam_Since_2005',
                TB_Active__c = true,
                TB_Agreement_Type__c = 'Paper',
                hed__Applicant__c = contact.Id
        );
        insert application;

        List<TB_Admissions_Dictionary__c> requests = new List<TB_Admissions_Dictionary__c>();
        for (Integer i = 0; i < 3; i++) {
            requests.add(TB_TestDataFactory.createRequest(false));
        }
        insert requests;

        ContentVersion contentVersion = TB_TestDataFactory.createContentVersion(false,'title','testPath','test');
        insert contentVersion;
    }

    @IsTest
    static void getAllContactApplicationsWrapperPositive() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        String jsonWrappers = TB_RequestController.getAllContactApplicationsWrapper(contact.Id);
        List<TB_RequestController.ApplicationWrapper> wrappers
                = (List<TB_RequestController.ApplicationWrapper>) JSON.deserialize(jsonWrappers, List<TB_RequestController.ApplicationWrapper>.class);
        Test.stopTest();
        System.assertEquals(1, wrappers.size());
    }

    @IsTest
    static void connectFileWithCasePositive() {
        Case caseRecord = new Case(
                Origin = 'Web',
                Status = 'New'
        );
        insert caseRecord;
        ContentVersion contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];

        Test.startTest();
        String result = TB_RequestController.connectFileWithCase(caseRecord.Id, contentVersion.Id);
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
        System.assertEquals('SUCCESS', result);
    }

    @IsTest
    static void connectFileWithCaseNegative() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        String result = TB_RequestController.connectFileWithCase(contact.Id, contact.Id);
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM TB_Log__c].size());
        System.assertEquals('FAILED', result);
    }

    @IsTest
    static void createCasePositiveTest() {
        String jsonRequestWrapper = prepareRequestWrapper();
        Test.startTest();
        String resultRequest = TB_RequestController.createNewCase(jsonRequestWrapper, false);
        Case newCase = (Case) JSON.deserialize(resultRequest, Case.class);
        Test.stopTest();
        System.assertEquals('subject Value',newCase.subject);
    }

    @IsTest
    static void createCasePositiveWithFileTest() {
        String jsonRequestWrapper = prepareRequestWrapper();
        Test.startTest();
        String resultRequest = TB_RequestController.createNewCase(jsonRequestWrapper, true);
        Case newCase = (Case) JSON.deserialize(resultRequest, Case.class);
        Test.stopTest();
        System.assertEquals(true, (newCase.TB_Document__c != null));
    }

    @IsTest
    public static void matchRequestsPositive() {
        Contact contact = [SELECT Id FROM Contact];

        Test.startTest();
        String applicationWrappersJSON = TB_RequestController.getAllContactApplicationsWrapper(contact.Id);
        Test.stopTest();

        List<TB_RequestController.ApplicationWrapper> wrappers = (List<TB_RequestController.ApplicationWrapper>)
                JSON.deserialize(applicationWrappersJSON, List<TB_RequestController.ApplicationWrapper>.class);
        System.assertEquals(3,  wrappers[0].availableRequests.size());
    }

    @IsTest
    public static void matchRequestsNegative() {
        Contact contact = [SELECT Id FROM Contact];
        contact.hed__Citizenship__c = 'Poland';
        update contact;
        hed__Application__c application = [
                SELECT TB_Level_of_Study__c, TB_Mode_of_Study__c,
                        TB_Applying_To_Offered_Product__r.TB_Language_of_Study__c,
                        TB_Applicant_Citizenship__c, hed__Application_Status__c,
                        TB_Agreement_Type__c
                FROM hed__Application__c LIMIT 1];
        application.TB_Applicant_Citizenship__c = 'Poland';
        update application;

        Test.startTest();
        String applicationWrappersJSON = TB_RequestController.getAllContactApplicationsWrapper(contact.Id);
        Test.stopTest();

        List<TB_RequestController.ApplicationWrapper> wrappers = (List<TB_RequestController.ApplicationWrapper>)
                JSON.deserialize(applicationWrappersJSON, List<TB_RequestController.ApplicationWrapper>.class);
        System.assertEquals(0,  wrappers[0].availableRequests.size());
    }

    private static String prepareRequestWrapper() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        TB_Admissions_Dictionary__c request = [SELECT Id FROM TB_Admissions_Dictionary__c LIMIT 1];

        TB_RequestController.RequestWrapper requestWrapper = new TB_RequestController.RequestWrapper();
        requestWrapper.subject = 'subject Value';
        requestWrapper.subjectId = request.Id;
        requestWrapper.contact = contact;
        requestWrapper.contactId = contact.Id;
        requestWrapper.application = application;
        requestWrapper.applicationId = application.Id;
        requestWrapper.contentValue = 'content Value';
        return JSON.serialize(requestWrapper);
    }
}