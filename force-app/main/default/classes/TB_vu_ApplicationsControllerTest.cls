@IsTest
private class TB_vu_ApplicationsControllerTest {
    private static final String USER_LAST_NAME = 'CaseTest';
    private static final String SWPS_STUDENT_PROFILE = 'SWPS Student';
    private static final String STUDENT_AUTHOR = 'Student';
    private static final String ADMIN_PROFILE = 'System Administrator';
    private static final String ADMIN_ROLE = 'Admin';
    private static final String EXPRESSION_TEST = 'Test';
    private static final String CATEGORY_CASE = 'Finances';
    private static final String CONTENT_VERSION_TITLE = 'Test_Case_Attachment';
    private static final String INVALID_ID_PARAM = 'invalid_id';
    private static final String STUDENT_APPLICATION_RECORD_TYPE = 'TB_Student_Application_HE';
    private static final String VIRTUAL_UNIVERSITY_ORIGIN = 'Virtual_University';
    private static final String CONTENT_VERSION_CATEGORY = 'Student_Application_Decision';
    private static final String UNIVERSITY_MAIL = 'test.tester@st.swps.edu.pl';

    @TestSetup
    static void setupMethod() {
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
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(STUDENT_APPLICATION_RECORD_TYPE).getRecordTypeId();
            Case c = new Case(
                ContactId = contact.Id,
                TB_Category__c = CATEGORY_CASE,
                RecordTypeId = recordTypeId,
                Origin = VIRTUAL_UNIVERSITY_ORIGIN,
                Status = 'New');
            insert c;
            ContentVersion version = TB_TestDataFactory.createContentVersion(
                false, 
                CONTENT_VERSION_TITLE, 
                CONTENT_VERSION_TITLE + '.pdf', 
                'Test');
            version.TB_Category__c = CONTENT_VERSION_CATEGORY;
            insert version;
            ContentDocumentLink contentDocumentLink = TB_TestDataFactory.createContentDocumentLink(
                true,
                [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :version.Id]
                .ContentDocumentId,
                c.Id
            );
            insert new TB_Operation__c(TB_Case__c = c.Id, TB_Description_Rich_Text__c = EXPRESSION_TEST, TB_Author__c = STUDENT_AUTHOR);
            insert new TB_Operation__c(TB_Case__c = c.Id, TB_Description_Rich_Text__c = EXPRESSION_TEST, TB_Publish__c = true);
        }
    }

    @IsTest
    static void fetchCasesPositiveTest() {
        Contact contact = [SELECT Id FROM Contact];

        Test.startTest();
        List<Case> cases = TB_vu_ApplicationsController.fetchCases(contact.Id);
        Test.stopTest();

        System.assertEquals(1, cases.size());
    }

    @IsTest
    static void fetchCasesNegativeTest() {
        Boolean isException = false;

        Test.startTest();
        try {
            TB_vu_ApplicationsController.fetchCases(INVALID_ID_PARAM);
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        System.assert(isException);
    }

    @IsTest
    static void fetchCaseCommentsPositiveTest() {
        Case c = [SELECT Id FROM Case];

        Test.startTest();
        List<TB_vu_ApplicationsController.CommentWrapper> comments = TB_vu_ApplicationsController.fetchCaseComments(c.Id);
        Test.stopTest();

        System.assertEquals(2, comments.size());
    }

    @IsTest
    static void fetchCaseCommentsNegativeTest() {
        Boolean isException = false;

        Test.startTest();
        try {
            TB_vu_ApplicationsController.fetchCaseComments(INVALID_ID_PARAM);
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        System.assert(isException);
    }

    @IsTest
    static void userIdToIsStudentTest() {
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
    static void userIdToNameTest() {
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
    static void fetchCaseWrappersTest() {
        Contact contact = [SELECT Id FROM Contact];

        Test.startTest();
        List<TB_vu_ApplicationsController.CaseWrapper> wrappers = TB_vu_ApplicationsController.fetchCaseWrappers(contact.Id);
        Test.stopTest();

        System.assertEquals(1, wrappers.size());
        System.assertEquals(CATEGORY_CASE, wrappers[0].subject);
    }

    @IsTest
    static void fetchCaseWrappersTestWithContentVersion() {
        Contact contact = [SELECT Id FROM Contact];
        Case c = [SELECT Id, Status, TB_Decision_Issued__c FROM Case LIMIT 1];
        c.Status = 'Closed';
        c.TB_Decision_Issued__c = true;
        update c;

        Test.startTest();
        List<TB_vu_ApplicationsController.CaseWrapper> wrappers = TB_vu_ApplicationsController.fetchCaseWrappers(contact.Id);
        Test.stopTest();

        System.assertEquals(1, wrappers.size());
        System.assertEquals(CATEGORY_CASE, wrappers[0].subject);
    }

}