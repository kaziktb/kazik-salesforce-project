@IsTest
private class TB_vu_MeetingsControllerTest {
    private static final String USER_LAST_NAME = 'CaseTest';
    private static final String SWPS_STUDENT_PROFILE = 'SWPS Student';
    private static final String STUDENT_AUTHOR = 'Student';
    private static final String COMMENT_RECORD_TYPE = 'TB_Conversation';
    private static final String COMMENT_TYPE = 'External_Comment';
    private static final String ADMIN_PROFILE = 'System Administrator';
    private static final String ADMIN_ROLE = 'Admin';
    private static final String EXPRESSION_TEST = 'Test';
    private static final String CASE_SUBJECT_CONTRACT = 'Other';
    private static final String INVALID_ID_PARAM = 'invalid_id';
    private static final String STUDENT_MEETING_RECORD_TYPE = 'TB_Student_Meeting_HE';
    private static final String VIRTUAL_UNIVERSITY_ORIGIN = 'Virtual_University';
    private static final String UNIVERSITY_MAIL = 'test.tester@st.swps.edu.pl';
    private static final String STATUS_FOR_STUDENT_NEW = 'New';

    @TestSetup
    static void setupMethod() {
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
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(STUDENT_MEETING_RECORD_TYPE).getRecordTypeId();
        Case c = new Case(
                ContactId = contact.Id,
                Subject = CASE_SUBJECT_CONTRACT,
                Description = EXPRESSION_TEST,
                RecordTypeId = recordTypeId,
                Origin = VIRTUAL_UNIVERSITY_ORIGIN,
                TB_Status_For_Student__c = 'New');
        insert c;
        Id conversationRecordTypeId = Schema.SObjectType.TB_Operation__c.getRecordTypeInfosByDeveloperName().get(COMMENT_RECORD_TYPE).getRecordTypeId();
        List<TB_Operation__c> operationsList = new List<TB_Operation__c>();
        operationsList.add(new TB_Operation__c(TB_Case__c = c.Id, TB_Description_Rich_Text__c = EXPRESSION_TEST, TB_Author__c = STUDENT_AUTHOR, TB_Type__c = COMMENT_TYPE, RecordTypeId = conversationRecordTypeId, TB_Publish__c = true));
        operationsList.add(new TB_Operation__c(TB_Case__c = c.Id, TB_Description_Rich_Text__c = EXPRESSION_TEST, TB_Publish__c = true));
        insert operationsList;
    }

    @IsTest
    private static void fetchCasesPositiveTest() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
        List<Case> cases = TB_vu_MeetingsController.fetchCases(contact.Id);
        Test.stopTest();

        Assert.areEqual(1, cases.size());
    }

    @IsTest
    private static void fetchCasesNegativeTest() {
        Boolean isException = false;

        Test.startTest();
        try {
            TB_vu_MeetingsController.fetchCases(INVALID_ID_PARAM);
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        Assert.isTrue(isException);
    }

    @IsTest
    private static void fetchCaseCommentsPositiveTest() {
        Case c = [SELECT Id FROM Case];

        Test.startTest();
        List<TB_vu_MeetingsController.CommentWrapper> comments = TB_vu_MeetingsController.fetchCaseComments(c.Id);
        Test.stopTest();

        Assert.areEqual(2, comments.size());
    }

    @IsTest
    private static void fetchCaseCommentsNegativeTest() {
        Boolean isException = false;

        Test.startTest();
        try {
            TB_vu_MeetingsController.fetchCaseComments(INVALID_ID_PARAM);
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        Assert.isTrue(isException);
    }

    @IsTest
    private static void createCaseCommentPositiveTest() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Case c = new Case(ContactId = contact.Id);
        insert c;

        Test.startTest();
        TB_vu_MeetingsController.createCaseComment(c.Id, contact.Id, EXPRESSION_TEST);
        Test.stopTest();

        List<TB_Operation__c> comments = [SELECT Id FROM TB_Operation__c WHERE TB_Case__c = :c.Id];
        Assert.areEqual(1, comments.size());
    }

    @IsTest
    private static void createCaseCommentNegativeTest() {
        Boolean isException = false;

        Test.startTest();
        try {
            TB_vu_MeetingsController.createCaseComment(INVALID_ID_PARAM, INVALID_ID_PARAM, EXPRESSION_TEST);
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        Assert.isTrue(isException);
    }

    @IsTest
    private static void userIdToIsStudentTest() {
        List<User> users = [
                SELECT Id, Profile.Name, ProfileId
                FROM User
                WHERE LastName = :USER_LAST_NAME
        ];

        Test.startTest();
        Map<Id, Boolean> userIdToIsStudent = new TB_vu_MeetingsController.WithoutSharing().userIdToIsStudent(new List<Id>{
                users[0].Id
        });
        Test.stopTest();

        Assert.areEqual(true, userIdToIsStudent.get(users[0].Id));
    }

    @IsTest
    private static void userIdToNameTest() {
        List<User> users = [
                SELECT Id
                FROM User
                WHERE LastName = :USER_LAST_NAME
        ];

        Test.startTest();
        Map<Id, String> userIdToName = new TB_vu_MeetingsController.WithoutSharing().userIdToName(new List<Id>{
                users[0].Id
        });
        Test.stopTest();

        Assert.areEqual('Test CaseTest', userIdToName.get(users[0].Id));
    }

    @IsTest
    private static void fetchCaseWrappersTest() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
        List<TB_vu_MeetingsController.CaseWrapper> wrappers = TB_vu_MeetingsController.fetchCaseWrappers(contact.Id);
        Test.stopTest();

        System.assertEquals(1, wrappers.size());
        Assert.areEqual(STATUS_FOR_STUDENT_NEW, wrappers[0].status);
    }

    @IsTest
    private static void contentVersionWithCommentTest() {
        Case c = [
                SELECT Id
                FROM Case
                LIMIT 1
        ];
        List<ContentVersion> versions = new List<ContentVersion>();
        for (TB_Operation__c comment : [
                SELECT Id
                FROM TB_Operation__c
                WHERE TB_Case__c =: c.Id
        ]) {
            for (Integer i = 0; i < 2; i++) {
                ContentVersion version = TB_TestDataFactory.createContentVersion(false, EXPRESSION_TEST, EXPRESSION_TEST, EXPRESSION_TEST);
                version.TB_Case_Comment__c = comment.Id;
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
        List<TB_vu_MeetingsController.CommentWrapper> commentWrapper = TB_vu_MeetingsController.fetchCaseComments(c.Id);
        Test.stopTest();

        Assert.areEqual(2, commentWrapper.size());
    }
}