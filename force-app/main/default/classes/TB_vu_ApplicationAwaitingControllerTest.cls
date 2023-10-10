@IsTest
public with sharing class TB_vu_ApplicationAwaitingControllerTest {
    static final String TEST_EXPRESSION = 'Test';
    static final String TEST_LAST_NAME = 'DecisionMaker';
    static final String TEST_USER_EMAIL = 'puser000@amamama.com';
    static final String DECISION_TYPE = 'Request_For_A_Decision';
    static final String OPERATION_RECORD_TYPE_NAME = 'TB_Decision';    
    private final static String CASE_STATUS = 'Awaiting_Decision_Maker';

    
    @TestSetup
    static void makeData(){
        System.runAs(TB_DataFactory.createUser(TB_re_Constants.PROFILE_NAME_ADMINISTRATOR, TB_re_Constants.ROLE_DEV_NAME_ADMIN, false)) {
            Id recordTypeId = Schema.SObjectType.TB_Operation__c.getRecordTypeInfosByDeveloperName().get(OPERATION_RECORD_TYPE_NAME).getRecordTypeId();
            User adminUser = TB_TestDataFactory.createUser(TB_re_Constants.PROFILE_NAME_ADMINISTRATOR, false);

            Contact contact = TB_TestDataFactory.createContact(true);
            Contact decisionMaker = TB_TestDataFactory.createContact(false);
            decisionMaker.LastName = TEST_LAST_NAME;
            decisionMaker.TB_SS_Decision_Maker__c = TRUE;
            insert decisionMaker;
            
            Case operationCase = TB_TestDataFactory.createCases(1, TEST_EXPRESSION, contact.Id, false)[0];
            operationCase.Status = CASE_STATUS;
            insert operationCase;

            TB_Operation__c operation = TB_TestDataFactory.createOperation(contact.Id, operationCase.Id, TEST_EXPRESSION, false);
            operation.TB_Type__c = DECISION_TYPE;
            operation.TB_Is_Decision__c = FALSE;
            operation.TB_Decision_Maker__c = decisionMaker.Id; 
            operation.recordTypeId = recordTypeId;
            insert operation;
        }

    }

    @IsTest
    static void testGetRelatedOperations() {
        User usr = [SELECT Id FROM User WHERE Email =: TEST_USER_EMAIL LIMIT 1];
        Contact decisionmaker = [SELECT Id FROM Contact WHERE LastName =: TEST_LAST_NAME LIMIT 1];
        TB_vu_ApplicationAwaitingController controller = new TB_vu_ApplicationAwaitingController();
        controller.ownerId = decisionmaker.Id;

        List<TB_Operation__c> relatedOperations = controller.getRelatedOperations();

        Assert.isNotNull(relatedOperations);
        Assert.isTrue(relatedOperations.size() == 1);
        Assert.isTrue(relatedOperations[0].TB_Decision_Maker__c == decisionmaker.Id);
    }
}