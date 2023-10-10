/**
 * Created by annaseveryna on 06/12/2021.
 */
@IsTest
public with sharing class TB_RequestsSubmittedControllerTest {

    private static final String CAMPUS_RECORD_TYPE_NAME = 'University_Department';
    private static final String FACULTY_RECORD_TYPE_NAME = 'Academic_Program';
    private static final String CONTACT_WITH_CASE_REQUESTS_LAST_NAME = 'Kowalski';
    private static final String CONTACT_WITH_NO_CASE_LAST_NAME = 'Smith';
    private static final String NEW_POLISH_EXAM = 'New_Polish_HS_Exam_Since_2005';

    @TestSetup
    static void testSetup() {
        List<Contact> contacts = new List<Contact>();

        Contact contact = new Contact(
                LastName = CONTACT_WITH_CASE_REQUESTS_LAST_NAME
        );
        contacts.add(contact);

        Contact contactWithNoRequests = new Contact(
                LastName = CONTACT_WITH_NO_CASE_LAST_NAME
        );
        contacts.add(contactWithNoRequests);

        insert contacts;

        List<Account> accounts = new List<Account>();

        Id campusRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get(CAMPUS_RECORD_TYPE_NAME).getRecordTypeId();
        Account campus = new Account(Name = 'Test Campus', RecordTypeId = campusRecordTypeId);
        accounts.add(campus);

        Id facultyRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get(FACULTY_RECORD_TYPE_NAME).getRecordTypeId();
        Account faculty = new Account(Name = 'Test Faculty', RecordTypeId = facultyRecordTypeId);
        accounts.add(faculty);

        insert accounts;

        TB_Offered_Product__c studies = new TB_Offered_Product__c(
                Name = 'Test Studies',
                TB_Campus__c = campus.Id,
                TB_Faculty__c = faculty.Id,
                TB_Mode_of_Study__c = 'Full_Time',
                TB_Level_of_Study__c = 'Bachelor'
        );

        insert studies;

        List<hed__Application__c> applications = new List<hed__Application__c>();

        hed__Application__c application = new hed__Application__c(
                TB_Applying_To_Offered_Product__c = studies.Id,
                TB_Applicant_Citizenship__c = 'Angola',
                TB_HS_Exam_Date__c = Date.newInstance(2020, 07, 20),
                TB_HS_Exam_Score_Top_3__c = 220,
                TB_HS_Exam_Type__c = NEW_POLISH_EXAM,
                TB_Active__c = true,
                hed__Applicant__c = contact.Id
        );
        applications.add(application);

        hed__Application__c applicationWithNoRequests = new hed__Application__c(
                TB_Applying_To_Offered_Product__c = studies.Id,
                TB_Applicant_Citizenship__c = 'Poland',
                TB_HS_Exam_Date__c = Date.newInstance(2020, 07, 20),
                TB_HS_Exam_Score_Top_3__c = 220,
                TB_HS_Exam_Type__c = NEW_POLISH_EXAM,
                TB_Active__c = true,
                hed__Applicant__c = contact.Id
        );
        applications.add(applicationWithNoRequests);

        insert applications;

        List<Case> submittedRequests = new List<Case>();

        for(hed__Application__c app : applications){
            submittedRequests.add(new Case(
                    Subject = 'Test' + app.Id,
                    Status = 'New',
                    TB_Application__c = app.Id,
                    RecordTypeId = TB_Constants.CASE_APPLICATION_REQUEST_RT_ID,
                    ContactId = contact.Id
            ));
        }

        insert submittedRequests;

        List<CaseComment> comments = new List<CaseComment>();

        for(Case c : submittedRequests){
            comments.add(new CaseComment(ParentId = c.Id, CommentBody = 'This is a test comment for request' + c.Id));
        }

        insert comments;
    }

    @IsTest
    public static void loadSubmittedRequestsTestPositive() {
        Contact applicant = [SELECT Id FROM Contact WHERE LastName = :CONTACT_WITH_CASE_REQUESTS_LAST_NAME];

        Test.startTest();
        List<Case> loadedSubmittedRequests = TB_RequestsSubmittedController.loadSubmittedRequests(applicant.Id);
        Test.stopTest();

        System.assertEquals(2, loadedSubmittedRequests.size());
    }

    @IsTest
    public static void getCaseCommentsPositive() {
        Contact applicant = [SELECT Id FROM Contact WHERE LastName = :CONTACT_WITH_CASE_REQUESTS_LAST_NAME];
        hed__Application__c application = [SELECT Id FROM hed__Application__c WHERE hed__Applicant__c = :applicant.Id LIMIT 1];
        Case request = [SELECT Id FROM Case WHERE RecordTypeId = :TB_Constants.CASE_APPLICATION_REQUEST_RT_ID AND TB_Application__c = :application.Id LIMIT 1];

        Test.startTest();
        List<TB_RequestsSubmittedController.CaseCommentWrapper> caseComments = TB_RequestsSubmittedController.getCaseComments(request.Id);
        Test.stopTest();

        System.assertEquals(1, caseComments.size());
    }

    @IsTest
    public static void insertCommentPositive() {
        Contact applicant = [SELECT Id FROM Contact WHERE LastName = :CONTACT_WITH_CASE_REQUESTS_LAST_NAME];
        hed__Application__c application = [SELECT Id FROM hed__Application__c WHERE hed__Applicant__c = :applicant.Id LIMIT 1];
        Case request = new Case(Subject = 'Test', Status = 'New', TB_Application__c = application.Id, ContactId = applicant.Id,
                RecordTypeId = TB_Constants.CASE_APPLICATION_REQUEST_RT_ID);
        insert request;
        String comment = 'Test comment';

        Test.startTest();
        TB_RequestsSubmittedController.insertComment(request.Id, comment);
        Test.stopTest();

        List<CaseComment> insertedComments = [SELECT CommentBody FROM CaseComment WHERE ParentId = :request.Id];
        System.assertEquals(1, insertedComments.size());
        System.assertEquals('Test comment', insertedComments[0].CommentBody);
    }

    @IsTest
    public static void userIdToInboundUserPositive() {
        User internalUser = TB_DataFactory.createUser(TB_Constants.PROFILE_NAME_ADMINISTRATOR, TB_Constants.ROLE_DEV_NAME_ADMIN, true);
        User externalUser = TB_DataFactory.createUser(TB_Constants.PROFILE_NAME_APPLICANT, false);
        Contact contact = [SELECT Id FROM Contact WHERE LastName = :CONTACT_WITH_CASE_REQUESTS_LAST_NAME];
        System.runAs(internalUser) {
            contact.OwnerId = internalUser.Id;
            update contact;

            externalUser.ContactId = contact.Id;
            insert externalUser;
        }

        Set<Id> userIds = new Set<Id>();
        userIds.add(externalUser.Id);
        userIds.add(internalUser.Id);

        Test.startTest();
        Map<Id, Boolean> userIdToIsOutboundUserMap = TB_RequestSubmittedControllerSharingSkip.userIdToIsOutboundUser(userIds);
        Test.stopTest();

        System.assertEquals(false, userIdToIsOutboundUserMap.get(internalUser.Id));
        System.assertEquals(true, userIdToIsOutboundUserMap.get(externalUser.Id));
    }

    @IsTest
    public static void loadSubmittedRequestsTestNegative() {
        Contact applicant = [SELECT Id FROM Contact WHERE LastName = :CONTACT_WITH_NO_CASE_LAST_NAME];

        Test.startTest();
        List<Case> loadedSubmittedRequests = TB_RequestsSubmittedController.loadSubmittedRequests(applicant.Id);
        Test.stopTest();

        System.assertEquals(0, loadedSubmittedRequests.size());
    }

    @IsTest
    public static void loadSubmittedRequestsTestNegativeNull() {
        Boolean isException = false;

        Test.startTest();
        try {
            TB_RequestsSubmittedController.loadSubmittedRequests(null);
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        System.assertEquals(true, isException);
    }

    @IsTest
    public static void getCaseCommentsNegative() {
        Boolean isException = false;

        Test.startTest();
        try {
            List<TB_RequestsSubmittedController.CaseCommentWrapper> caseComments = TB_RequestsSubmittedController.getCaseComments(null);
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        System.assertEquals(true, isException);
    }

    @IsTest
    public static void insertCommentNegative() {
        Contact applicant = [SELECT Id FROM Contact WHERE LastName = :CONTACT_WITH_CASE_REQUESTS_LAST_NAME];
        hed__Application__c application = [SELECT Id FROM hed__Application__c WHERE hed__Applicant__c = :applicant.Id LIMIT 1];
        Case request = new Case(Subject = 'Test', Status = 'New', TB_Application__c = application.Id,
                RecordTypeId = TB_Constants.CASE_APPLICATION_REQUEST_RT_ID);
        insert request;
        Boolean isException = false;

        Test.startTest();
        try {
            TB_RequestsSubmittedController.insertComment(request.Id, null);
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        List<CaseComment> insertedComments = [SELECT CommentBody FROM CaseComment WHERE ParentId = :request.Id];
        System.assertEquals(0, insertedComments.size());
        System.assertEquals(true, isException);
    }
}