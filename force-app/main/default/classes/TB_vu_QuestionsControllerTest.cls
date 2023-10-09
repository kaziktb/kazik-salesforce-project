@IsTest
private class TB_vu_QuestionsControllerTest {
    private static final String USER_LAST_NAME = 'CaseTest';
    private static final String SWPS_STUDENT_PROFILE = 'SWPS Student';
    private static final String STUDENT_AUTHOR = 'Student';
    private static final String ADMIN_PROFILE = 'System Administrator';
    private static final String ADMIN_ROLE = 'Admin';
    private static final String EXPRESSION_TEST = 'Test';
    private static final String CASE_SUBJECT_CONTRACT = 'Other';
    private static final String CONTENT_VERSION_TITLE = 'Test_Case_Attachment';
    private static final Integer NUMBER_OF_INSERTED_RECORDS = 3;
    private static final String INVALID_ID_PARAM = 'invalid_id';
    private static final String STUDENT_QUESTION_RECORD_TYPE = 'TB_Student_Question_HE';
    private static final String VIRTUAL_UNIVERSITY_ORIGIN = 'Virtual_University';
    private static final String UNIVERSITY_MAIL = 'test.tester@st.swps.edu.pl';

    @TestSetup
    private static void setupMethod() {
        System.runAs(TB_DataFactory.createUser(ADMIN_PROFILE, ADMIN_ROLE, false)) {
            Contact contact = new Contact(
                LastName = USER_LAST_NAME, 
                hed__UniversityEmail__c = UNIVERSITY_MAIL);
            insert contact;
            User u = TB_DataFactory.createUser(SWPS_STUDENT_PROFILE, false);
            u.FirstName = EXPRESSION_TEST;
            u.LastName = USER_LAST_NAME;
            u.ContactId = contact.Id;
            insert u;
            contact.TB_User__c = u.Id;
            update contact;
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(STUDENT_QUESTION_RECORD_TYPE).getRecordTypeId();
            Case c = new Case(
                ContactId = contact.Id,
                Subject = CASE_SUBJECT_CONTRACT,
                RecordTypeId = recordTypeId,
                Origin = VIRTUAL_UNIVERSITY_ORIGIN,
                Status = 'New');
            insert c;
            insert new TB_Operation__c(TB_Case__c = c.Id, TB_Description_Rich_Text__c = EXPRESSION_TEST, TB_Author__c = STUDENT_AUTHOR);
            insert new TB_Operation__c(TB_Case__c = c.Id, TB_Description_Rich_Text__c = EXPRESSION_TEST, TB_Publish__c = true);
        }
    }

    @IsTest
    private static void fetchCasesPositiveTest() {
        Contact contact = [SELECT Id FROM Contact];

        Test.startTest();
        List<Case> cases = TB_vu_QuestionsController.fetchCases(contact.Id);
        Test.stopTest();

        System.assertEquals(1, cases.size());
    }

    @IsTest
    private static void fetchCasesNegativeTest() {
        Boolean isException = false;

        Test.startTest();
        try {
            TB_vu_QuestionsController.fetchCases(INVALID_ID_PARAM);
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        System.assert(isException);
    }

    @IsTest
    private static void fetchCaseCommentsPositiveTest() {
        Case c = [SELECT Id FROM Case];

        Test.startTest();
        List<TB_vu_QuestionsController.CommentWrapper> comments = TB_vu_QuestionsController.fetchCaseComments(c.Id);
        Test.stopTest();

        System.assertEquals(2, comments.size());
    }

    @IsTest
    private static void fetchCaseCommentsNegativeTest() {
        Boolean isException = false;

        Test.startTest();
        try {
            TB_vu_QuestionsController.fetchCaseComments(INVALID_ID_PARAM);
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        System.assert(isException);
    }

    @IsTest
    private static void createCaseCommentPositiveTest() {
        Contact contact = [SELECT Id FROM Contact];
        Case c = new Case(ContactId = contact.Id);
        insert c;

        Test.startTest();
        TB_vu_QuestionsController.createCaseComment(c.Id, contact.Id, EXPRESSION_TEST);
        Test.stopTest();

        List<TB_Operation__c> comments = [SELECT Id FROM TB_Operation__c WHERE TB_Case__c = :c.Id];
        System.assertEquals(1, comments.size());
    }

    @IsTest
    private static void createCaseCommentNegativeTest() {
        Boolean isException = false;

        Test.startTest();
        try {
            TB_vu_QuestionsController.createCaseComment(INVALID_ID_PARAM, INVALID_ID_PARAM, EXPRESSION_TEST);
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        System.assert(isException);
    }

    @IsTest
    private static void userIdToIsStudentTest() {
        List<User> users = [
            SELECT Id, Profile.Name, ProfileId
            FROM User
            WHERE LastName = :USER_LAST_NAME
        ];

        Test.startTest();
        Map<Id, Boolean> userIdToIsStudent = TB_vu_QuestionsControllerSharingSkip.userIdToIsStudent(new List<Id>{
            users[0].Id
        });
        Test.stopTest();

        System.assertEquals(true, userIdToIsStudent.get(users[0].Id));
    }

    @IsTest
    private static void userIdToNameTest() {
        List<User> users = [
            SELECT Id
            FROM User
            WHERE LastName = :USER_LAST_NAME
        ];

        Test.startTest();
        Map<Id, String> userIdToName = TB_vu_QuestionsControllerSharingSkip.userIdToName(new List<Id>{
            users[0].Id
        });
        Test.stopTest();

        System.assertEquals('Test CaseTest', userIdToName.get(users[0].Id));
    }

    @IsTest
    private static void fetchCaseWrappersTest() {
        Contact contact = [SELECT Id FROM Contact];

        Test.startTest();
        List<TB_vu_QuestionsController.CaseWrapper> wrappers = TB_vu_QuestionsController.fetchCaseWrappers(contact.Id);
        Test.stopTest();

        System.assertEquals(1, wrappers.size());
        System.assertEquals(CASE_SUBJECT_CONTRACT, wrappers[0].subject);
    }

    @IsTest
    private static void contentVersionWithCommentTest() {
        Case c = [
            SELECT Id
            FROM Case
        ];
        List<ContentVersion> versions = new List<ContentVersion>();
        for (TB_Operation__c comment : [
            SELECT Id
            FROM TB_Operation__c
        ]) {
            for (Integer i = 0; i < 2; i++) {
                ContentVersion version = TB_TestDataFactory.createContentVersion(false, EXPRESSION_TEST, EXPRESSION_TEST, EXPRESSION_TEST);
                versions.add(version);
            }
        }
        insert versions;

        List<ContentDocumentLink> links = new List<ContentDocumentLink>();

        for (ContentDocument document : [SELECT Id FROM ContentDocument]) {
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink(LinkedEntityId = c.Id, ContentDocumentId = document.Id);
            links.add(contentDocumentLink);
        }
        insert links;

        Test.startTest();
        List<TB_vu_QuestionsController.CommentWrapper> commentWrappers = TB_vu_QuestionsController.fetchCaseComments(c.Id);
        Test.stopTest();

        System.assertEquals(2, commentWrappers.size());
    }
}