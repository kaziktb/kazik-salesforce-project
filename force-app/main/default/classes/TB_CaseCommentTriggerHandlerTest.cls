/**
 * Created by Marcin Kozub on 19/10/2022.
 */

@IsTest
private class TB_CaseCommentTriggerHandlerTest {
    private static final String USER_LAST_NAME = 'CaseTest';
    private static final String EXPRESSION_TEST = 'Test';
    private static final String MODIFIED_EXPRESSION_TEST = 'Modified Test';
    private static final Datetime POSITIVE_TEST_DATETIME = Datetime.newInstance(2022, 02, 02, 21, 0, 0);
    private static final Datetime NEGATIVE_TEST_DATETIME = Datetime.newInstance(2021, 02, 02, 12, 0, 0);

    @TestSetup
    private static void setupTest(){
        System.runAs(TB_DataFactory.createUser(TB_Constants.PROFILE_NAME_ADMINISTRATOR, TB_Constants.ROLE_DEV_NAME_ADMIN, false)){
            Contact contact = new Contact(LastName = USER_LAST_NAME);
            insert contact;
            Case c = new Case(ContactId = contact.Id);
            insert c;
        }
    }

    @IsTest
    static void insertCommentCasePositiveTest() {
        Case c = [
                SELECT TB_Last_Activity_Date__c
                FROM Case
                LIMIT 1
        ];
        CaseComment comment = new CaseComment(ParentId = c.Id, CommentBody = EXPRESSION_TEST);

        Test.startTest();
        insert comment;
        Test.stopTest();

        Case c2 = [
                SELECT TB_Last_Activity_Date__c
                FROM Case
                WHERE Id =: c.Id
        ];
        System.assertEquals(POSITIVE_TEST_DATETIME, c2.TB_Last_Activity_Date__c, 'Last activity date should be returned.');
    }

    @IsTest
    static void insertCommentCaseNegativeTest() {
        Case c = [
                SELECT TB_Last_Activity_Date__c
                FROM Case
                LIMIT 1
        ];
        CaseComment comment = new CaseComment(ParentId = c.Id, CommentBody = EXPRESSION_TEST);

        Test.startTest();
        insert comment;
        Test.stopTest();

        Case c2 = [
                SELECT TB_Last_Activity_Date__c
                FROM Case
                WHERE Id =: c.Id
        ];
        System.assertNotEquals(NEGATIVE_TEST_DATETIME, c2.TB_Last_Activity_Date__c, 'Last activity date should be returned.');
    }

    @IsTest
    static void updateCommentCasePositiveTest() {
        Case c = [
                SELECT TB_Last_Activity_Date__c
                FROM Case
                LIMIT 1
        ];
        CaseComment comment = new CaseComment(ParentId = c.Id, CommentBody = EXPRESSION_TEST);
        insert comment;
        comment.CommentBody = MODIFIED_EXPRESSION_TEST;

        Test.startTest();
        update comment;
        Test.stopTest();

        Case c2 = [
                SELECT TB_Last_Activity_Date__c
                FROM Case
                WHERE Id =: c.Id
        ];
        System.assertEquals(POSITIVE_TEST_DATETIME, c2.TB_Last_Activity_Date__c, 'Last activity date should be returned.');
    }

    @IsTest
    static void updateCommentCaseNegativeTest() {
        Case c = [
                SELECT TB_Last_Activity_Date__c
                FROM Case
                LIMIT 1
        ];
        CaseComment comment = new CaseComment(ParentId = c.Id, CommentBody = EXPRESSION_TEST);
        insert comment;
        comment.CommentBody = MODIFIED_EXPRESSION_TEST;

        Test.startTest();
        update comment;
        Test.stopTest();

        Case c2 = [
                SELECT TB_Last_Activity_Date__c
                FROM Case
                WHERE Id =: c.Id
        ];
        System.assertNotEquals(NEGATIVE_TEST_DATETIME, c2.TB_Last_Activity_Date__c, 'Last activity date should be returned.');
    }

    @IsTest
    static void deleteCommentCasePositiveTest() {
        Case c = [
                SELECT TB_Last_Activity_Date__c
                FROM Case
                LIMIT 1
        ];
        CaseComment comment = new CaseComment(ParentId = c.Id, CommentBody = EXPRESSION_TEST);
        insert comment;

        Test.startTest();
        delete comment;
        Test.stopTest();

        Case c2 = [
                SELECT TB_Last_Activity_Date__c
                FROM Case
                WHERE Id =: c.Id
        ];
        System.assertEquals(POSITIVE_TEST_DATETIME, c2.TB_Last_Activity_Date__c, 'Last activity date should be returned.');
    }

    @IsTest
    static void deleteCommentCaseNegativeTest() {
        Case c = [
                SELECT TB_Last_Activity_Date__c
                FROM Case
                LIMIT 1
        ];
        CaseComment comment = new CaseComment(ParentId = c.Id, CommentBody = EXPRESSION_TEST);
        insert comment;

        Test.startTest();
        delete comment;
        Test.stopTest();

        Case c2 = [
                SELECT TB_Last_Activity_Date__c
                FROM Case
                WHERE Id =: c.Id
        ];
        System.assertNotEquals(NEGATIVE_TEST_DATETIME, c2.TB_Last_Activity_Date__c, 'Last activity date should be returned.');
    }

    @IsTest
    static void undeleteCommentCasePositiveTest() {
        Case c = [
                SELECT TB_Last_Activity_Date__c
                FROM Case
                LIMIT 1
        ];
        CaseComment comment = new CaseComment(ParentId = c.Id, CommentBody = EXPRESSION_TEST);
        insert comment;
        delete comment;

        Test.startTest();
        undelete comment;
        Test.stopTest();

        Case c2 = [
                SELECT TB_Last_Activity_Date__c
                FROM Case
                WHERE Id =: c.Id
        ];
        System.assertEquals(POSITIVE_TEST_DATETIME, c2.TB_Last_Activity_Date__c, 'Last activity date should be returned.');
    }

    @IsTest
    static void undeleteCommentCaseNegativeTest() {
        Case c = [
                SELECT TB_Last_Activity_Date__c
                FROM Case
                LIMIT 1
        ];
        CaseComment comment = new CaseComment(ParentId = c.Id, CommentBody = EXPRESSION_TEST);
        insert comment;
        delete comment;

        Test.startTest();
        undelete comment;
        Test.stopTest();

        Case c2 = [
                SELECT TB_Last_Activity_Date__c
                FROM Case
                WHERE Id =: c.Id
        ];
        System.assertNotEquals(NEGATIVE_TEST_DATETIME, c2.TB_Last_Activity_Date__c, 'Last activity date should be returned.');
    }
}