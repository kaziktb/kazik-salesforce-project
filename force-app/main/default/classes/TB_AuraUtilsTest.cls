@IsTest
private class TB_AuraUtilsTest {
    private static final String USER_ROLE = 'Admin';
    private static final String USER_LAST_NAME = 'CaseTest';
    private static final String PROFILE_CONTRACT_TEACHERS = 'SWPS Employee Community User';
    private static final String EXPRESSION_TEST = 'Test';
    private static final String APP_LAST_NAME = 'App Test Name';
    @TestSetup
    private static void setupMethod() {
        System.runAs(TB_DataFactory.createUser('System Administrator', 'Admin', false)){
            Contact contact = new Contact(LastName = USER_LAST_NAME);
            insert contact;
            Case c = new Case(ContactId = contact.Id);
            insert c;
            insert new CaseComment(ParentId = c.Id, CommentBody = EXPRESSION_TEST);
            User u = TB_DataFactory.createUser(PROFILE_CONTRACT_TEACHERS, false);
            u.FirstName = EXPRESSION_TEST;
            u.LastName = USER_LAST_NAME;
            u.ContactId = contact.Id;
            insert u;
            hed__Application__c application = TB_TestDataFactory.createApplicationWithRelatedObjectsAndNestedLookup(false);
            Contact applicant = new Contact(
                LastName = APP_LAST_NAME
            );
            insert applicant;
            application.hed__Applicant__c = applicant.Id;
            insert application;
        }
    }
   @isTest
   private static void createLogTest(){
    TB_Log__c log = TB_AuraUtils.createLog('Test Log');
    System.assertNotEquals(null, log.Id, 'Created log should have an Id value');
   }
   @isTest
   private static void createLogWithParamsTest(){
    TB_Log__c log = TB_AuraUtils.createLogWithParams('Test Log \\| TEST LOF \\| POLOAWDO \\| adawdawd \\| TEST');
    System.assertNotEquals(null, log.Id, 'Created log should have an Id value');
   }

   @isTest
   private static void getCurrentContactTest(){
    Contact cont = [SELECT Id FROM Contact WHERE LastName =:USER_LAST_NAME Limit 1];
    User u = [SELECT Id FROM User WHERE ContactId = :cont.Id];
    String outputUser;
    Test.startTest();
    System.runAs(u){
        outputUser = TB_AuraUtils.getCurrentContact();
    }
    Test.stopTest();

    System.assertNotEquals(null, outputUser, 'Output String JSON User Should not be empty');

   }

   @isTest
   private static void getCurrentApplicantTest(){
    hed__Application__c application =  [SELECT ID FROM hed__Application__c LIMIT 1];
    String output;
    output = TB_AuraUtils.getCurrentApplicant(application.Id);

    System.assertNotEquals(null, output, 'Output String JSON User Should not be empty');
   }
}