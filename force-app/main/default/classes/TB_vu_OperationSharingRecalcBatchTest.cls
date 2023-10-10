/**
 * Created by adampeczkowski on 27/07/2023.
 */

@IsTest
private class TB_vu_OperationSharingRecalcBatchTest
{
    private static final String ADMIN_PROFILE = 'System Administrator';
    private static final String ADMIN_ROLE = 'Admin';
    private static final String STUDENT_LAST_NAME = 'StudentLastName';
    private static final String DM_LAST_NAME = 'DMLastName';
    private static final String ACTIVE_DM_LAST_NAME = 'ActiveDMLastName';
    private static final String APPLICATION_RT_DEVNAME = 'TB_Student_Application_HE';
    
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
        List<Case> cases = TB_TestDataFactory.createCases(1, 'test', studentContact.Id, false);
        cases[0].RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(APPLICATION_RT_DEVNAME).getRecordTypeId();
        insert cases;
        TB_Operation__c operation = TB_TestDataFactory.createOperation(studentContact.Id, cases[0].Id, '', false);
        TB_Operation__c operation2 = TB_TestDataFactory.createOperation(studentContact.Id, cases[0].Id, '', false);
        operation.TB_Decision_Maker__c = dmContact.Id;
        TB_TriggerHandler.bypassAllTriggers = true;
        insert new List<TB_Operation__c>{operation,operation2};
        
        Test.startTest();
        Id jobId = Database.executeBatch(new TB_vu_OperationSharingRecalcBatch(),100);
        Test.stopTest();
        
        Assert.areEqual('Completed',[SELECT Id, Status FROM AsyncApexJob WHERE Id = :jobId].Status);
    }
}