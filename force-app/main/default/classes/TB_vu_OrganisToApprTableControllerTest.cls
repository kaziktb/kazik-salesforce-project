@IsTest
private class TB_vu_OrganisToApprTableControllerTest {
    private static final String LANGUAGE_PL = 'PL';
    private static final Integer NUMBER_OF_DRAFT_ACCOUNTS = 4;
    private static final Integer NUMBER_OF_PENDING_APPROVAL_ACCOUNTS = 5;

    @TestSetup
    static void testSetup() {
        Test.startTest();
        List<Account> accsToInsert = new List<Account>();
        List<Account> accs = TB_TestDataFactory.createAccounts(
            NUMBER_OF_DRAFT_ACCOUNTS,
            TB_Constants.STUDENTS_ORGANIZATION_REC_TYPE_ID,
            false
        );
        for (Account a : accs) {
            a.TB_Status__c = 'Draft';
        }
        accsToInsert.addAll(accs);
        accs = TB_TestDataFactory.createAccounts(
            NUMBER_OF_PENDING_APPROVAL_ACCOUNTS,
            TB_Constants.STUDENTS_ORGANIZATION_REC_TYPE_ID,
            false
        );
        for (Account a : accs) {
            a.TB_Status__c = 'Pending_Approval';
        }
        accsToInsert.addAll(accs);
        insert accsToInsert;

        Contact cont = TB_TestDataFactory.createContact(false);
        cont.TB_User__c = UserInfo.getUserId();
        insert cont;
        
        Task task = new Task(WhatId=accs[0].Id, WhoId = cont.Id, TB_Active__c = true, Status='In Progress');
        insert task;
        Test.stopTest();
    }

    @IsTest
    static void shouldNotReturnAccountRecords_WithoutContactLinkedToCurrentUser() {
        // given
        delete [SELECT Id FROM Contact WHERE TB_User__c = :UserInfo.getUserId()];

        // when
        Test.startTest();
        List<TB_vu_OrganisToApprTableController.AccountWrapper> accsWrapper = TB_vu_OrganisToApprTableController.getAccounts(
            LANGUAGE_PL
        );
        Test.stopTest();

        // then
        System.assertEquals(
            0,
            accsWrapper.size(),
            ('Should return 0 records when there is no contact associated with the current user')
        );
    }

    @IsTest
    static void shouldReturnAccountRecords_WithContactLinedToCurrentUser() {
        // given
        Integer predefinedNumberOfAccounts = NUMBER_OF_DRAFT_ACCOUNTS + NUMBER_OF_PENDING_APPROVAL_ACCOUNTS;
        Contact c = [SELECT Id FROM Contact];
        List<Account> accs = [SELECT Id, hed__Primary_Contact__c FROM Account];
        for (Account a : accs) {
            a.hed__Primary_Contact__c = c.Id;
        }
        update accs;

        // when
        Test.startTest();
        List<TB_vu_OrganisToApprTableController.AccountWrapper> accsWrapper = TB_vu_OrganisToApprTableController.getAccounts(
            LANGUAGE_PL
        );
        Test.stopTest();

        // then
        System.assertEquals(
            predefinedNumberOfAccounts,
            accsWrapper.size(),
            ('Should return predefined number of records')
        );
    }
}