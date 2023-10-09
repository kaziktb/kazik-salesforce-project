@IsTest
private class TB_vu_ApplicationApprovalTest {
    private static final String DECISION_TYPE = 'Decision';
    private static final String INTERNAL_COMMENT_TYPE = 'Internal_Comment';
    private static final String INVALID_PARAMETER = 'INVALID';
    private static final String TEST_VALUE = 'TEST';
    private static final String RECORD_TYPE_DEVELOPER_NAME = 'TB_Conversation';
    private static final String AUTHOR_DECISION = 'Decision_Maker';
    private static final String TYPE_OPERATION = 'Request_For_A_Decision';
    private static final String DECISION_OPERATION_RT = 'TB_Decision';
    private static final String SUBJECT_VALUE = 'TEST SUBJECT';

    @TestSetup
    static void testSetup(){
        User user = [
            SELECT 
                Id 
            FROM 
                User 
            WHERE Id =: UserInfo.getUserId()];
    
        Contact contact = TB_TestDataFactory.createContact(false);
        contact.TB_User__c = user.Id;
        contact.TB_SS_Decision_Maker__c = true;
        insert contact;

        List<Account> account = TB_TestDataFactory.createAccounts(
            1, 
            TB_Constants.UNIVERSITY_DEPARTMENT_REC_TYPE_ID,
            true
        );

        System.runAs(user){
            Case parentCase = new Case(
                Contact = contact, 
                Account = account[0],
                Description = TEST_VALUE
            );   

            insert parentCase;

            TB_Operation__c operation = new TB_Operation__c();

            insert operation;
        }

        Case caseForOperations = new Case(
            ContactId = contact.Id,
            Subject = SUBJECT_VALUE
        );
        insert caseForOperations;
        
        TB_Operation__c initialOperation = new TB_Operation__c(
            TB_Initial__c = true,
            TB_Case__c = caseForOperations.Id,
            TB_Awaiting_CSS__c = true
        );

        TB_Operation__c decisionOperation = new TB_Operation__c(
            TB_Case__c = caseForOperations.Id,
            TB_Type__c = TYPE_OPERATION,
            TB_Decision_Maker__c = contact.Id,
            RecordTypeId = Schema.SObjectType.TB_Operation__c.getRecordTypeInfosByDeveloperName().get(DECISION_OPERATION_RT).getRecordTypeId()
        );

        insert new List<TB_Operation__c>{
            initialOperation,
            decisionOperation
        };
    }

    @isTest
    static void shouldSendOperationForDecisionType(){
        String returnedOperationId = '';

        TB_vu_ApplicationApproval.OperationParameters parameters = new TB_vu_ApplicationApproval.OperationParameters();
        parameters.comment = TEST_VALUE;
        parameters.type = DECISION_TYPE;
        parameters.parentCaseId = [
            SELECT
                Id
            FROM
                Case
            WHERE
                OwnerId =: UserInfo.getUserId() AND
                Subject !=: SUBJECT_VALUE 
            LIMIT 1
        ].Id;
        parameters.contactId = [
            SELECT
                Id
            FROM
                Contact
            WHERE
                TB_User__c =: UserInfo.getUserId()
        ].Id;

        Test.startTest();
        returnedOperationId = TB_vu_ApplicationApproval.sendOperation(parameters);
        Test.stopTest();

        TB_Operation__c result = [
                SELECT 
                    Id, 
                    TB_Case__c, 
                    TB_Contact__c, 
                    TB_Type__c, 
                    TB_Is_Decision__c, 
                    TB_Publish__c
                FROM 
                    TB_Operation__c
                WHERE
                    Id =: returnedOperationId];

        System.assert(result != null, 'Value doesnt match with expected value');
    }

    @isTest
    static void shouldSendOperationForInternalCommentType(){
        String returnedOperationId;

        TB_vu_ApplicationApproval.OperationParameters parameters = new TB_vu_ApplicationApproval.OperationParameters();
        parameters.comment = TEST_VALUE;
        parameters.type = INTERNAL_COMMENT_TYPE;
        parameters.parentCaseId = [
            SELECT
                Id
            FROM
                Case
            WHERE
                OwnerId =: UserInfo.getUserId() AND
                Subject !=: SUBJECT_VALUE 
            LIMIT 1
        ].Id;
        parameters.contactId = [
            SELECT
                Id
            FROM
                Contact
            WHERE
                TB_User__c =: UserInfo.getUserId()
        ].Id;

        Test.startTest();
        returnedOperationId = TB_vu_ApplicationApproval.sendOperation(parameters);
        Test.stopTest();

        TB_Operation__c result = [
                SELECT 
                    Id, 
                    TB_Case__c, 
                    TB_Contact__c, 
                    TB_Type__c, 
                    TB_Is_Decision__c, 
                    TB_Publish__c
                FROM 
                    TB_Operation__c
                WHERE
                    Id =: returnedOperationId];

        System.assert(result != null, 'Value doesnt match with expected value');
    }

    @isTest
    static void throwAnError_whenInvalidParametersPassed(){
        TB_vu_ApplicationApproval.OperationParameters parameters = new TB_vu_ApplicationApproval.OperationParameters();
        parameters.comment = TEST_VALUE;
        parameters.type = INTERNAL_COMMENT_TYPE;
        parameters.parentCaseId = INVALID_PARAMETER;

        Boolean isException = false;

        Test.startTest();
        try {
            TB_vu_ApplicationApproval.sendOperation(parameters);
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        System.assert(isException, 'Test should thrown an exception');
    }

    @IsTest
    static void shouldReturnCaseInfo() {
        Case c = [SELECT Id, ContactId FROM Case WHERE Subject =: SUBJECT_VALUE LIMIT 1];
        TB_vu_ApplicationApproval.CaseWrapper result;

        Test.startTest();
        result = TB_vu_ApplicationApproval.getCaseInfo(c.Id, c.ContactId);
        Test.stopTest();

        Assert.isTrue(result.isAccessible);
        Assert.isTrue(result.decisionUnavailable);
    }
    
}