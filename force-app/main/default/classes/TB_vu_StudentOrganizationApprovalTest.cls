@isTest
private class TB_vu_StudentOrganizationApprovalTest {
    private static final String PL_LANG = 'PL';
    private static final String EN_LANG = 'EN';

    @TestSetup
    static void testSetup(){
        Contact contact = TB_TestDataFactory.createContact(false);
        contact.TB_User__c = UserInfo.getUserId();
        insert contact;

        List<Account> acc = TB_TestDataFactory.createAccounts(1, TB_Constants.STUDENTS_ORGANIZATION_REC_TYPE_ID, false);
        acc[0].TB_Account_Name_EN__c = 'TestEN';
        acc[0].TB_Account_Name_PL__c = 'TestPL';
        acc[0].hed__Primary_Contact__c = contact.Id;
        insert acc;

        Task task = new Task(
            WhatId=acc[0].Id, 
            WhoId = contact.Id,
            TB_Active__c = true, 
            Possible_Approval_Decisions__c='Approved');
        insert task;
    }

    @isTest
    static void shouldSetADecisionOnTask(){
        Account acc = [SELECT Id,TB_Account_Name_EN__c FROM Account WHERE TB_Account_Name_PL__c ='TestPL'];
        Contact c = [SELECT Id, LastName FROM Contact WHERE LastName = 'testContact'];

        Test.startTest();
        TB_vu_StudentOrganizationApproval.makeADecision(c.Id, acc.Id , 'Approved', 'test comment');
        Test.stopTest();

        Task task = [SELECT Id, Description, TB_Decision__c, WhatId FROM Task WHERE WhatId =: acc.Id];
        System.assertEquals('Approved', task.TB_Decision__c, 'TB_Decision__c doesnt have expected value');
        
    }

    @isTest
    static void throwAnError_whenInvalidIdPassedToMakeADecision(){
        Boolean errorOccurred = false;
        Account acc = [SELECT Id,TB_Account_Name_PL__c FROM Account WHERE TB_Account_Name_PL__c ='TestPL'];

        Test.startTest();
        try {
            TB_vu_StudentOrganizationApproval.makeADecision('INVALID', 'INVALID', 'INVALID', 'test comment');
        } catch (Exception e) {
            errorOccurred = true;
        }
        Test.stopTest();

        System.assertEquals(true, errorOccurred,'Query should return exception');
    }

    @isTest
    static void shouldReturnWrapperWithProperValues(){
        Account acc = [SELECT Id,TB_Account_Name_EN__c FROM Account WHERE TB_Account_Name_PL__c ='TestPL'];
        Contact c = [SELECT Id, LastName FROM Contact WHERE LastName = 'testContact'];
        TB_vu_StudentOrganizationApproval.StudentOrganizationApproveWrapper result;

        Test.startTest();
        result = TB_vu_StudentOrganizationApproval.getStartData(acc.Id, c.Id, 'PL');
        Test.stopTest();

        System.assertEquals('TestPL', result.OrganizationName, 'Result doesnt match with expected value');
    }

    @isTest
    static void throwAnError_whenInvalidIdPassedGetApprovalDecisions(){
        Boolean errorOccurred = false;
        TB_vu_StudentOrganizationApproval.StudentOrganizationApproveWrapper result;

        Test.startTest();
        try {
            result = TB_vu_StudentOrganizationApproval.getStartData('INVALID','INVALID','PL');
        } catch (Exception e) {
            errorOccurred = true;
        }
        Test.stopTest();

        System.assertEquals(true, errorOccurred,'Query should return exception');
    }

    @isTest
    static void shouldReturnActiveValueOnTask(){
        Account acc = [SELECT Id,TB_Account_Name_EN__c FROM Account WHERE TB_Account_Name_PL__c ='TestPL'];
        Contact c = [SELECT Id, LastName FROM Contact WHERE LastName = 'testContact'];
        Task result;

        Test.startTest();
        result = TB_vu_StudentOrganizationApproval.getTask(c.Id, acc.Id);
        Test.stopTest();

        System.assertEquals(true, result.TB_Active__c, 'Result doesnt match with expected value');
    }
    
    @isTest
    static void throwAnError_whenInvalidIdPassedGetActiveValueOnTask(){
        Boolean errorOccurred = false;
        Task result;

        Test.startTest();
        try {
            result = TB_vu_StudentOrganizationApproval.getTask('INVALID','INVALID');
        } catch (Exception e) {
            errorOccurred = true;
        }
        Test.stopTest();

        System.assertEquals(true, errorOccurred,'Query should return exception');
    }

}