@IsTest
public with sharing class TB_IC_RelatedContactsControllerTest {
    private static final String PARTNER_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();
    private static final String DEPARTMENT_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('University_Department').getRecordTypeId();
    private static final String PARTNER_CONTACT_RECORD_TYPE_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('TB_Partner').getRecordTypeId();
    private static final String TEST_NAME = 'TEST_TEST';


    @TestSetup
    private static void setupMethod() {
        Id currUserId = UserInfo.getUserId();
        System.runAs(TB_DataFactory.createUser('System Administrator', 'Admin', false)) {
            Account partner = new Account(Name = TEST_NAME, RecordTypeId = PARTNER_RECORD_TYPE_ID);
            Account department = new Account(Name = TEST_NAME, RecordTypeId = DEPARTMENT_RECORD_TYPE_ID);
            
            insert new List<Account>{partner, department};

            AccountTeamMember atm = new AccountTeamMember (
                AccountId = partner.Id,
                AccountAccessLevel = 'Read',
                CaseAccessLevel = 'Read',
                ContactAccessLevel = 'Read',
                UserId  = currUserId,
                TeamMemberRole = 'Account Manager'
            );
            insert atm;

            Contact contact = new Contact(
                firstName = 'TEST',
                lastName = 'TEST',
                TB_Profession__c = 'TEST',
                hed__WorkEmail__c = 'test@test.test',
                hed__WorkPhone__c ='987654321',
                TB_x_Record_Type__c = 'TB_Employee',
                TB_User__c = currUserId
            );

            Contact contact2 = new Contact(
                firstName = 'TEST2',
                lastName = 'TEST2',
                TB_Profession__c = 'TEST2',
                hed__WorkEmail__c = 'test2@test.test',
                hed__WorkPhone__c ='123456789',
                TB_x_Record_Type__c = 'TB_Partner',
                RecordTypeId = PARTNER_CONTACT_RECORD_TYPE_ID, 
                AccountId = partner.Id
            );

            Contact contactSignedBy = new Contact(
                firstName = 'contactSignedBy',
                lastName = 'TEST3',
                TB_Profession__c = 'TEST3',
                hed__WorkEmail__c = 'test3@test.test',
                hed__WorkPhone__c ='12345678',
                TB_x_Record_Type__c = 'TB_Partner',
                RecordTypeId = PARTNER_CONTACT_RECORD_TYPE_ID
            );

            Contact contactAdditionalSWPS = new Contact(
                firstName = 'contactAdditionalSWPS',
                lastName = 'TEST4',
                TB_Profession__c = 'TEST4',
                hed__WorkEmail__c = 'test4@test.test',
                hed__WorkPhone__c ='1234567',
                TB_x_Record_Type__c = 'TB_Partner',
                RecordTypeId = PARTNER_CONTACT_RECORD_TYPE_ID
            );

            Contact contactPersonSWPS = new Contact(
                firstName = 'contactPersonSWPS',
                lastName = 'TEST5',
                TB_Profession__c = 'TEST5',
                hed__WorkEmail__c = 'test5@test.test',
                hed__WorkPhone__c ='123456',
                TB_x_Record_Type__c = 'TB_Partner',
                RecordTypeId = PARTNER_CONTACT_RECORD_TYPE_ID 
            );

            Contact contactAdditionalPartner = new Contact(
                firstName = 'contactAdditionalPartner',
                lastName = 'TEST6',
                TB_Profession__c = 'TEST6',
                hed__WorkEmail__c = 'test6@test.test',
                hed__WorkPhone__c ='1234567891',
                TB_x_Record_Type__c = 'TB_Partner',
                RecordTypeId = PARTNER_CONTACT_RECORD_TYPE_ID
            );

            Contact contactParnerPerson = new Contact(
                firstName = 'contactParnerPerson',
                lastName = 'TEST7',
                TB_Profession__c = 'TEST7',
                hed__WorkEmail__c = 'test7@test.test',
                hed__WorkPhone__c ='1234567891',
                TB_x_Record_Type__c = 'TB_Partner',
                RecordTypeId = PARTNER_CONTACT_RECORD_TYPE_ID
            );                
            insert new List<Contact> {contact, contact2, contactSignedBy, contactAdditionalSWPS, contactPersonSWPS, contactAdditionalPartner, contactParnerPerson};

            Contract contractTEST = new Contract(
                AccountId = partner.Id,
                DT_Company_Signed_By_Contact__c = contactSignedBy.Id, 
                DT_Additional_SWPS_Contact_Person__c = contactAdditionalSWPS.Id,
                DT_SWPS_Contact_Person__c = contactPersonSWPS.Id, 
                DT_Additional_Partner_Contact_Person__c = contactAdditionalPartner.Id,
                DT_Partner_Contact_Person__c = contactParnerPerson.Id,
                DT_Document_Type__c = 'Annex',
                Status = 'Not_Implemented',
                DT_Scope_of_Cooperation__c = 'testowy test',
                DT_Department__c = department.Id,
                OwnerId = currUserId
            );
            insert contractTEST;
        }
    }

    @IsTest
    static void fetchRelatedPartnerContactsNonEmptyListReturnedWithExtendedAccess() {
        Account partner = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        List<TB_IC_RelatedContactsController.ContactWrapper> partnerContactWrappers = TB_IC_RelatedContactsController.fetchRelatedPartnerContact(partner.Id, true);
        Test.stopTest();

        System.assertEquals(2, partnerContactWrappers.size(), 'Error! Any contacts found, Expected: 2');
    }

    @IsTest
    static void fetchRelatedPartnerContactsEmptyListReturnedWithExtendedAccess() {
        Account partner = [SELECT Id FROM Account LIMIT 1];
        List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId = :partner.Id];
        for (Contact c : contacts) {
            c.AccountId = null;
        }
        update contacts;

        Test.startTest();
        List<TB_IC_RelatedContactsController.ContactWrapper> partnerContactWrappers = TB_IC_RelatedContactsController.fetchRelatedPartnerContact(partner.Id, true);
        Test.stopTest();

        System.assertEquals(1, partnerContactWrappers.size(), 'Error! Any contacts found, Expected: 1');
    }

    @IsTest
    static void fetchRelatedPartnerContactsNonEmptyListReturnedWithoutExtendedAccess() {
        Account partner = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        List<TB_IC_RelatedContactsController.ContactWrapper> partnerContactWrappers = TB_IC_RelatedContactsController.fetchRelatedPartnerContact(partner.Id, false);
        Test.stopTest();

        System.assertEquals(1, partnerContactWrappers.size(), 'Error! Any contacts found, Expected: 1');
    }

    @IsTest
    static void fetchRelatedPartnerContactsEmptyListReturnedWithExtendedAccessWithoutExtendedAccess() {
        Account partner = [SELECT Id FROM Account LIMIT 1];
        List<AccountTeamMember> atm = [SELECT Id FROM AccountTeamMember];
        delete atm;

        Test.startTest();
        List<TB_IC_RelatedContactsController.ContactWrapper> partnerContactWrappers = TB_IC_RelatedContactsController.fetchRelatedPartnerContact(partner.Id, false);
        Test.stopTest();

        System.assertEquals(0, partnerContactWrappers.size(), 'Error! Contacts found. Expected: 0');
    }

    @IsTest
    static void fetchRelatedContactsForContractListReturnedWithExtendedAccess() {
        Account partner = [SELECT Id FROM Account LIMIT 1];
        Contract contract = [SELECT Id FROM Contract WHERE AccountId = :partner.Id];

        Test.startTest();
        List<TB_IC_RelatedContactsController.ContractContactWrapper> contractContactWrappers = TB_IC_RelatedContactsController.fetchRelatedContractContacts(contract.Id, true);
        Test.stopTest();

        System.assertEquals(6, contractContactWrappers.size(), 'Error! Any contacts found, Expected: 6');
    }

    @IsTest
    static void fetchRelatedContactsForContractListReturnedWithoutExtendedAccess() {
        Account partner = [SELECT Id FROM Account LIMIT 1];
        Contract contract = [SELECT Id FROM Contract WHERE AccountId = :partner.Id];

        Test.startTest();
        List<TB_IC_RelatedContactsController.ContractContactWrapper> contractContactWrappers = TB_IC_RelatedContactsController.fetchRelatedContractContacts(contract.Id, false);
        Test.stopTest();

        System.assertEquals(1, contractContactWrappers.size(), 'Error! Expected: 1');
    }
}