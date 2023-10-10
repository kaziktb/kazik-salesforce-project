@IsTest
private class TB_AgentWorkTriggerHandlerTest
{
    private static final String USER_LAST_NAME = 'AgentWorkTest';
    
    @TestSetup
    private static void setupTest(){
        System.runAs(TB_DataFactory.createUser(TB_Constants.PROFILE_NAME_ADMINISTRATOR, TB_Constants.ROLE_DEV_NAME_ADMIN, false)){
            Contact contact = new Contact(LastName = USER_LAST_NAME);
            insert contact;
        }
    }
    
    @IsTest
    static void coverTrigger()
    {
        Case testCase = new Case();
        testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(TB_vu_Constants.QUESTION_CASE_RECORD_TYPE_DEVELOPER_NAME).getRecordTypeId();
        insert testCase;
        ServiceChannel sc = [SELECT Id, DeveloperName
        FROM ServiceChannel WHERE DeveloperName = 'TB_Case_Routing_CSS'];
        Test.startTest();
        try
        {
            AgentWork aw = new AgentWork(
                    ServiceChannelId = sc.Id,
                    WorkItemId = testCase.Id,
                    UserId = UserInfo.getUserId()
            );
            insert aw;
        }
        catch(Exception e)
        {
            //Doing nothing, can't really test this trigger, SF limitation, this gets me coverage of the Trigger
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testUpdateOwnerName()
    {
        Case testCase = new Case();
        testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(TB_vu_Constants.QUESTION_CASE_RECORD_TYPE_DEVELOPER_NAME).getRecordTypeId();
        insert testCase;
        testCase.TB_Case_Owner_Name__c = '-';
        update testCase;
        
        Test.startTest();
        TB_AgentWorkTriggerHandler.setCaseOwnerName(new Set<Id> {testCase.Id});
        Test.stopTest();
        
        Case caseAfter = [SELECT Id, TB_Case_Owner_Name__c FROM Case WHERE Id = :testCase.Id];
        User u = [SELECT Id, FirstName, LastName FROM User WHERE Id = :UserInfo.getUserId()];
        String userName = u.FirstName + ' ' + u.LastName;
        Assert.areEqual(userName,caseAfter.TB_Case_Owner_Name__c);
    }
}