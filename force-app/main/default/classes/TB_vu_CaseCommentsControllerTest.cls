@isTest
private class TB_vu_CaseCommentsControllerTest {
    private static final String USER_LAST_NAME = 'CaseTest';
    private static final String SWPS_STUDENT_PROFILE = 'SWPS Student';
    private static final String STUDENT_AUTHOR = 'Student';
    private static final String ADMIN_PROFILE = 'System Administrator';
    private static final String ADMIN_ROLE = 'Admin';
    private static final String EXPRESSION_TEST = 'Test';
    private static final String CASE_SUBJECT_CONTRACT = 'Other';
    private static final String CONTENT_VERSION_TITLE = 'Test_Case_Attachment';
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
                Subject = CASE_SUBJECT_CONTRACT,
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

            insert new TB_Operation__c(TB_Case__c = c.Id, TB_Description_Rich_Text__c = EXPRESSION_TEST, TB_Publish__c = true);
            TB_Operation__c operationWithFile = new TB_Operation__c(TB_Case__c = c.Id, TB_Description_Rich_Text__c = EXPRESSION_TEST, TB_Author__c = STUDENT_AUTHOR);
            insert operationWithFile;

            ContentDocumentLink contentDocumentLink = TB_TestDataFactory.createContentDocumentLink(
                true,
                [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :version.Id]
                .ContentDocumentId,
                operationWithFile.Id
            );
        }
    }

    @IsTest
    static void fetchCaseCommentsPositiveTest() {
        Case c = [SELECT Id FROM Case WHERE Subject =: CASE_SUBJECT_CONTRACT];

        Test.startTest();
        List<TB_vu_CaseCommentsController.CommentWrapper> comments = TB_vu_CaseCommentsController.getCaseComments(c.Id);
        Test.stopTest();

        Assert.areEqual(2, comments.size());
    }

    @IsTest
    static void fetchCaseCommentsNegativeTest() {
        Boolean isException = false;

        Test.startTest();
        try {
            TB_vu_CaseCommentsController.getCaseComments('INVALID');
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        Assert.isTrue(isException);
    }
}