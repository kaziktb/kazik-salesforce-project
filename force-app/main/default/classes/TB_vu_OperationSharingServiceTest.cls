@IsTest
private class TB_vu_OperationSharingServiceTest
{
    private static final String ADMIN_PROFILE = 'System Administrator';
    private static final String ADMIN_ROLE = 'Admin';
    private static final String STUDENT_LAST_NAME = 'StudentLastName';
    private static final String DM_LAST_NAME = 'DMLastName';
    private static final String ACTIVE_DM_LAST_NAME = 'ActiveDMLastName';
    
    @TestSetup
    static void testSetup()
    {
        User user = TB_DataFactory.createUser(ADMIN_PROFILE, ADMIN_ROLE, false);
        user.LastName = DM_LAST_NAME;
        user.IsActive = false;
        insert user;
        User activeUser = TB_DataFactory.createUser(ADMIN_PROFILE, ADMIN_ROLE, false);
        activeUser.LastName = ACTIVE_DM_LAST_NAME;
        insert activeUser;
    }
    
    @IsTest
    static void shouldShareOperationsByCaseIds() {
        User user = [SELECT Id FROM User WHERE LastName = :DM_LAST_NAME];
        Contact dmContact = TB_TestDataFactory.createContact(false);
        dmContact.TB_User__c = user.Id;
        dmContact.TB_SS_Decision_Maker__c = true;
        Contact studentContact = new Contact(LastName = STUDENT_LAST_NAME);
        insert new List<Contact>{dmContact,studentContact};
        List<Case> cases = TB_TestDataFactory.createCases(1, 'test', studentContact.Id, true);
        TB_Operation__c operation = TB_TestDataFactory.createOperation(studentContact.Id, cases[0].Id, '', false);
        TB_Operation__c operation2 = TB_TestDataFactory.createOperation(studentContact.Id, cases[0].Id, '', false);
        operation.TB_Decision_Maker__c = dmContact.Id;
        TB_TriggerHandler.bypassAllTriggers = true;
        insert new List<TB_Operation__c>{operation,operation2};
        
        Test.startTest();
        Integer numberOfFutureCalls = Limits.getFutureCalls();
        TB_vu_OperationSharingService.shareOperationsByCaseIds(new Set<Id>{cases[0].Id});
        numberOfFutureCalls = Limits.getFutureCalls() - numberOfFutureCalls;
        Test.stopTest();
        
        Assert.areEqual(1,numberOfFutureCalls);
    }
    
    @IsTest
    static void shouldShareOperationsByCaseIdsSync() {
        User user = [SELECT Id FROM User WHERE LastName = :DM_LAST_NAME];
        Contact dmContact = TB_TestDataFactory.createContact(false);
        dmContact.TB_User__c = user.Id;
        dmContact.TB_SS_Decision_Maker__c = true;
        Contact studentContact = new Contact(LastName = STUDENT_LAST_NAME);
        insert new List<Contact>{dmContact,studentContact};
        List<Case> cases = TB_TestDataFactory.createCases(1, 'test', studentContact.Id, true);
        TB_Operation__c operation = TB_TestDataFactory.createOperation(studentContact.Id, cases[0].Id, '', false);
        TB_Operation__c operation2 = TB_TestDataFactory.createOperation(studentContact.Id, cases[0].Id, '', false);
        operation.TB_Decision_Maker__c = dmContact.Id;
        TB_TriggerHandler.bypassAllTriggers = true;
        insert new List<TB_Operation__c>{operation,operation2};
        
        Test.startTest();
        Integer numberOfQueueableJobs = Limits.getQueueableJobs();
        TB_vu_OperationSharingService.shareOperationsByCaseIdsSync(new Set<Id>{cases[0].Id});
        numberOfQueueableJobs = Limits.getQueueableJobs() - numberOfQueueableJobs;
        Test.stopTest();
        
        Assert.areEqual(1,numberOfQueueableJobs);
    }
    
    @IsTest
    static void shouldActivateUsers() {
        User user = [SELECT Id FROM User WHERE LastName = :DM_LAST_NAME];
        Contact dmContact = TB_TestDataFactory.createContact(false);
        dmContact.TB_User__c = user.Id;
        dmContact.TB_SS_Decision_Maker__c = true;
        Contact studentContact = new Contact(LastName = STUDENT_LAST_NAME);
        insert new List<Contact>{dmContact,studentContact};
        List<Case> cases = TB_TestDataFactory.createCases(1, 'test', studentContact.Id, true);
        TB_Operation__c operation = TB_TestDataFactory.createOperation(studentContact.Id, cases[0].Id, '', false);
        TB_Operation__c operation2 = TB_TestDataFactory.createOperation(studentContact.Id, cases[0].Id, '', false);
        operation.TB_Decision_Maker__c = dmContact.Id;
        TB_TriggerHandler.bypassAllTriggers = true;
        insert new List<TB_Operation__c>{operation,operation2};
        
        Test.startTest();
        List<TB_Operation__c> operationsToShare = [SELECT Id, TB_Case__c, TB_Decision_Maker__r.TB_User__c FROM TB_Operation__c];
        System.enqueueJob(new TB_vu_OperationSharingService.OperationSharingQueueable(operationsToShare));
        Test.stopTest();
        
        Assert.isTrue([SELECT Id, IsActive FROM User WHERE Id = :user.Id].IsActive);
    }
    
    @IsTest
    static void shouldShareOperations() {
        User user = [SELECT Id FROM User WHERE LastName = :ACTIVE_DM_LAST_NAME];
        Contact dmContact = TB_TestDataFactory.createContact(false);
        dmContact.TB_User__c = user.Id;
        dmContact.TB_SS_Decision_Maker__c = true;
        Contact studentContact = new Contact(LastName = STUDENT_LAST_NAME);
        insert new List<Contact>{dmContact,studentContact};
        List<Case> cases = TB_TestDataFactory.createCases(1, 'test', studentContact.Id, true);
        TB_Operation__c operation = TB_TestDataFactory.createOperation(studentContact.Id, cases[0].Id, '', false);
        TB_Operation__c operation2 = TB_TestDataFactory.createOperation(studentContact.Id, cases[0].Id, '', false);
        operation.TB_Decision_Maker__c = dmContact.Id;
        TB_TriggerHandler.bypassAllTriggers = true;
        insert new List<TB_Operation__c>{operation,operation2};
        
        Test.startTest();
        List<TB_Operation__c> operationsToShare = [SELECT Id, TB_Case__c, TB_Decision_Maker__r.TB_User__c FROM TB_Operation__c];
        TB_vu_OperationSharingService.OperationSharingQueueable queueable = new TB_vu_OperationSharingService.OperationSharingQueueable(operationsToShare);
        queueable.usersActivated=true;
        System.enqueueJob(queueable);
        Test.stopTest();
        
        List<TB_Operation__Share> operationShares = [SELECT Id FROM TB_Operation__Share WHERE RowCause = :TB_vu_OperationSharingService.ROW_CAUSE_DECISION_MAKER];
        
        Assert.areEqual(2,operationShares.size());
    }
}