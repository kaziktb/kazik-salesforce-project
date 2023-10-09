@IsTest
public with sharing class TB_IC_ExtendedAccessControllerTest {
    private static final String PARTNER_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();
    private static final String PARTNER_CONTACT_RECORD_TYPE_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('TB_Partner').getRecordTypeId();
    private static final String TEST_NAME = 'TEST_TEST';

    @TestSetup
    private static void setupMethod() {
        Id currUserId = UserInfo.getUserId();
        System.runAs(TB_DataFactory.createUser('System Administrator', 'Admin', false)) {
            
            Account partner = new Account(Name = TEST_NAME, RecordTypeId = PARTNER_RECORD_TYPE_ID);
            insert partner;

            AccountTeamMember atm = new AccountTeamMember (
                AccountId = partner.Id,
                AccountAccessLevel = 'Read',
                CaseAccessLevel = 'Read',
                ContactAccessLevel = 'Read',
                UserId  = currUserId,
                TeamMemberRole = 'Community Viewer Full Access'
            );
            insert atm;

            Contact contact = new Contact(
                firstName = 'TEST',
                lastName = 'TEST',
                TB_Full_Access_Approval_Process_Name__c = 'test',
                TB_User__c = currUserId
                );
            insert contact;
        }
    }

    @IsTest
    static void isUserWithExtendedAccessPositive() {
        Account partner = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        Boolean hasExtendedAccess = TB_IC_ExtendedAccessController.isUserWithExtendedAccess(partner.Id);
        Test.stopTest();

        System.assertEquals(true, hasExtendedAccess, 'Error! Expected: true!');
    }

    @IsTest
    static void isUserWithExtendedAccessNegative() {
        Account partner = [SELECT Id FROM Account LIMIT 1];
        List<AccountTeamMember> atm = [SELECT Id FROM AccountTeamMember];
        delete atm;

        Test.startTest();
        Boolean hasExtendedAccess = TB_IC_ExtendedAccessController.isUserWithExtendedAccess(partner.Id);
        Test.stopTest();

        System.assertEquals(false, hasExtendedAccess, 'Error! Expected: false!');
    }

   @IsTest
    static void checkIsUserInApprovalProcessPositive() {

        Test.startTest();
        String partnerAccountName = TB_IC_ExtendedAccessController.isUserInApprovalProcess();
        Test.stopTest();

        System.assertEquals('test', partnerAccountName, 'Error! Expected: test');
    }

    @IsTest
    static void checkIsUserInApprovalProcessNegative() {
        User userId = [SELECT Id FROM User LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        contact.TB_Full_Access_Approval_Process_Name__c = null;
        update contact;
        
        Test.startTest();
        String partnerAccountName = TB_IC_ExtendedAccessController.isUserInApprovalProcess();
        Test.stopTest();

        System.assertEquals(null, partnerAccountName, 'Error! Expected: null');
    }
    
}