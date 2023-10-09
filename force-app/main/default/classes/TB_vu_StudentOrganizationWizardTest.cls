@IsTest
private class TB_vu_StudentOrganizationWizardTest {

    private static final String TEST_EMAIL_ADDRESS = 'test@swps.edu.pl';
    private static final String TEST_EMAIL_ADDRESS_MEMBER = 'test@st.swps.edu.pl';
    private static final String TEST_LAST_NAME = 'lastNameTest123';
    private static final String TEST_ACC_UNIT_TYPE = 'WYDZIAL';
    private static final Id STUDENTS_ORGANISATIONS_REC_TYPE_ID =
            Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TB_Students_Organisation').getRecordTypeId();

    @TestSetup
    static void testSetup() {
        Test.startTest();
        User user = TB_TestDataFactory.createUser(TB_TestDataFactory.SYSTEM_ADMINISTRATOR, false);
        user.TimeZoneSidKey = 'Europe/Warsaw';
        user.email = TEST_EMAIL_ADDRESS_MEMBER;
        user.LastName = TEST_LAST_NAME;
        insert user;

        List<Contact> contacts = TB_TestDataFactory.prepareContacts(10, false, null);
        List<Contact> newOrganisationMembers = TB_TestDataFactory.prepareContacts(20, false, 'member');
        contacts.addAll(newOrganisationMembers);

        Contact c = TB_TestDataFactory.prepareContact(false);
        c.FirstName = null;
        c.hed__UniversityEmail__c = TEST_EMAIL_ADDRESS;
        c.TB_Active__c = true;
        c.TB_Duplicate__c = false;
        c.TB_Anonymization_Status__c = null;
        c.LastName = TEST_LAST_NAME;
        c.RecordTypeId = Contact.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('TB_Student').getRecordTypeId();
        contacts.add(c);
        insert contacts;

        Account acc = TB_TestDataFactory.prepareAccounts(1, STUDENTS_ORGANISATIONS_REC_TYPE_ID)[0];
        acc.DT_Unit_Type__c = TEST_ACC_UNIT_TYPE;
        insert acc;

        Test.stopTest();
    }

    @IsTest
    static void shouldReturnContactWrapper_onValidEmailAddress() {
        // given
        Contact c = [SELECT Id, DT_Is_Employee__c FROM Contact WHERE hed__UniversityEmail__c =: TEST_EMAIL_ADDRESS];
        c.DT_Is_Employee__c = true;
        c.hed__UniversityEmail__c = TEST_EMAIL_ADDRESS_MEMBER;
        update c;

        //when
        Test.startTest();
        TB_vu_StudentOrganizationWizard.ContactWrapper cw = TB_vu_StudentOrganizationWizard.getContactDataBasedOnEmail(TEST_EMAIL_ADDRESS_MEMBER, false);
        Test.stopTest();

        //then
        System.assertEquals(cw.name, TEST_LAST_NAME, ('Should return contact wrapper with predefined university last name'));
        System.assertEquals(cw.email, TEST_EMAIL_ADDRESS_MEMBER, ('Should return contact with predefined university email address'));
    }

    @IsTest
    static void shouldReturnContactWrapper_onValidEmailAddressAndSupervisor() {
        Contact c = [SELECT Id, TB_Didactic_Employee_Counter_HE__c FROM Contact WHERE hed__UniversityEmail__c =: TEST_EMAIL_ADDRESS];
        c.TB_Didactic_Employee_Counter_HE__c = 1;
        c.RecordTypeId = Contact.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('TB_Employee').getRecordTypeId();
        update c;
        // given

        //when
        Test.startTest();
        TB_vu_StudentOrganizationWizard.ContactWrapper cw = TB_vu_StudentOrganizationWizard.getContactDataBasedOnEmail(TEST_EMAIL_ADDRESS, true);
        Test.stopTest();

        //then
        System.assertEquals(cw.name, TEST_LAST_NAME, ('Should return contact wrapper with predefined university last name'));
        System.assertEquals(cw.email, TEST_EMAIL_ADDRESS, ('Should return contact with predefined university email address'));
    }

    @IsTest
    static void shouldReturnContactWrapper_onValidUser() {
        // given
        Contact c = [SELECT Id, DT_Is_Employee__c FROM Contact WHERE hed__UniversityEmail__c =: TEST_EMAIL_ADDRESS];
        c.DT_Is_Employee__c = true;
        c.hed__UniversityEmail__c = TEST_EMAIL_ADDRESS_MEMBER;
        update c;
        User user = [SELECT Id, Name FROM User WHERE Email =: TEST_EMAIL_ADDRESS_MEMBER LIMIT 1];

        //when
        System.runAs(user) {
            Test.startTest();
            TB_vu_StudentOrganizationWizard.ContactWrapper cw = TB_vu_StudentOrganizationWizard.getContactDataBasedOnEmail('', false);
            Test.stopTest();


            //then
            System.assertEquals(cw.name, TEST_LAST_NAME, ('Should return contact wrapper with predefined university last name'));
            System.assertEquals(cw.email, TEST_EMAIL_ADDRESS_MEMBER, ('Should return contact with predefined university email address'));
        }
    }

    @IsTest
    static void shouldNotReturnContactWrapper_onContactsWithSameEmailAddress() {
        // given
        Boolean err = false;
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        Contact c = TB_TestDataFactory.prepareContact(false);
        c.hed__WorkEmail__c = TEST_EMAIL_ADDRESS;
        c.TB_Active__c = true;
        c.TB_Duplicate__c = false;
        c.TB_Anonymization_Status__c = null;
        Database.SaveResult sr = Database.insert(c, dml);

        //when
        Test.startTest();
        try {
            TB_vu_StudentOrganizationWizard.ContactWrapper cw = TB_vu_StudentOrganizationWizard.getContactDataBasedOnEmail('', false);
        } catch(Exception e) {
            if(e instanceof AuraHandledException){
                err = true;
            }
        }
        Test.stopTest();

        //then
        System.assert(err, 'Should return aura exception');
    }

    @IsTest
    static void shouldReturnContact_onValidUser() {
        // given
        User user = [SELECT Id, Name FROM User WHERE Email =: TEST_EMAIL_ADDRESS_MEMBER LIMIT 1];
        Contact c = [SELECT Id, TB_User__c FROM Contact WHERE hed__UniversityEmail__c =: TEST_EMAIL_ADDRESS];
        c.TB_User__c = user.Id;
        update c;

        //when
        System.runAs(user) {
            Test.startTest();
            c = TB_vu_StudentOrganizationWizard.getContactDataBasedOnCurrentUserId();
            Test.stopTest();


            //then
            System.assertEquals(c.Name, TEST_LAST_NAME, ('Should return contact wrapper with predefined university last name'));
            System.assertEquals(c.hed__UniversityEmail__c, TEST_EMAIL_ADDRESS, ('Should return contact with predefined university email address'));
        }
    }

    @IsTest
    static void shouldInsertNewOrganisationAndAffiliations_onSaveOrganisation(){
        //given
        Contact chairman = [SELECT Id FROM Contact LIMIT 1][0];
        Contact supervisor = [SELECT Id FROM Contact LIMIT 2][1];
        Account parentAcc = [SELECT Id FROM Account WHERE DT_Unit_Type__c =: TEST_ACC_UNIT_TYPE];
        TB_vu_StudentOrganizationWizard.Organization organizationWrapper = new TB_vu_StudentOrganizationWizard.Organization();
        organizationWrapper.status = 'Draft';
        organizationWrapper.chairman = chairman.Id;
        organizationWrapper.supervisor = supervisor.Id;
        organizationWrapper.name = 'test name123';
        organizationWrapper.shortName = 'test short name';
        organizationWrapper.department = parentAcc.Id;
        organizationWrapper.startDate = Date.today();
        organizationWrapper.description = 'description';

        //when
        Test.startTest();
        String newOrganisationId = TB_vu_StudentOrganizationWizard.saveOrganization(organizationWrapper, new List<String>());
        Test.stopTest();

        //then
        System.assertEquals(chairman.Id, [SELECT hed__Contact__c FROM hed__Affiliation__c WHERE hed__Role__c =: TB_Constants.AFFILIATION_ROLE_CHAIRMAN]?.hed__Contact__c, 'Should match to chairman\'s Id');
        System.assertEquals(supervisor.Id, [SELECT hed__Contact__c FROM hed__Affiliation__c WHERE hed__Role__c =: TB_Constants.AFFILIATION_ROLE_SUPERVISOR]?.hed__Contact__c, 'Should match to supervisor\'s Id');
    }

    @IsTest
    static void shouldDeleteOldAndInsertNewAffiliationForSupervisor_onSaveOrganisation() {
        //given
        List<Contact> contacts = [SELECT Id FROM Contact WHERE LastName LIKE 'member%'];
        Contact chairman = contacts[0];
        Contact supervisor = contacts[1];
        Account parentAcc = [SELECT Id FROM Account WHERE DT_Unit_Type__c =: TEST_ACC_UNIT_TYPE];
        TB_vu_StudentOrganizationWizard.Organization organizationWrapper = new TB_vu_StudentOrganizationWizard.Organization();
        organizationWrapper.status = 'Draft';
        organizationWrapper.chairman = chairman.Id;
        organizationWrapper.supervisor = supervisor.Id;
        organizationWrapper.name = 'test name123';
        organizationWrapper.shortName = 'test short name';
        organizationWrapper.department = parentAcc.Id;
        organizationWrapper.startDate = Date.today();
        organizationWrapper.description = 'description';

        String newOrganisationId = TB_vu_StudentOrganizationWizard.saveOrganization(organizationWrapper, new List<String>());

        supervisor = contacts[2];

        organizationWrapper.recordId = newOrganisationId;
        organizationWrapper.supervisor = supervisor.Id;

        Id previousChairmanAffiliationId = [SELECT Id FROM hed__Affiliation__c WHERE hed__Role__c =: TB_Constants.AFFILIATION_ROLE_CHAIRMAN]?.Id;
        Id previousSupervisorAffiliationId = [SELECT Id FROM hed__Affiliation__c WHERE hed__Role__c =: TB_Constants.AFFILIATION_ROLE_SUPERVISOR]?.Id;

        //when
        Test.startTest();
        newOrganisationId = TB_vu_StudentOrganizationWizard.saveOrganization(organizationWrapper, new List<String>());
        Test.stopTest();

        //then
        hed__Affiliation__c currentChairmanAffiliation = [SELECT Id, hed__Contact__c FROM hed__Affiliation__c WHERE hed__Role__c =: TB_Constants.AFFILIATION_ROLE_CHAIRMAN];
        hed__Affiliation__c currentSupervisorAffiliation = [SELECT Id, hed__Contact__c FROM hed__Affiliation__c WHERE hed__Role__c =: TB_Constants.AFFILIATION_ROLE_SUPERVISOR];
        System.assertEquals(chairman.Id, currentChairmanAffiliation?.hed__Contact__c, 'Should match to chairman\'s Id');
        System.assertEquals(supervisor.Id, currentSupervisorAffiliation?.hed__Contact__c, 'Should match to supervisor\'s Id');
        System.assertNotEquals(previousChairmanAffiliationId, currentSupervisorAffiliation?.Id, 'Provided Ids should not match');
        System.assertNotEquals(previousSupervisorAffiliationId, currentSupervisorAffiliation?.Id, 'Provided Ids should not match');
    }

    @IsTest
    static void shouldDeleteAllAffiliationsForSupervisorAndInsertNewOne_onSaveOrganisation() {
        //given
        List<Contact> contacts = [SELECT Id FROM Contact WHERE LastName LIKE 'member%'];
        Contact chairman = contacts[0];
        Contact supervisor = contacts[1];
        Account parentAcc = [SELECT Id FROM Account WHERE DT_Unit_Type__c =: TEST_ACC_UNIT_TYPE];
        TB_vu_StudentOrganizationWizard.Organization organizationWrapper = new TB_vu_StudentOrganizationWizard.Organization();
        organizationWrapper.status = 'Draft';
        organizationWrapper.chairman = chairman.Id;
        organizationWrapper.supervisor = supervisor.Id;
        organizationWrapper.name = 'test name123';
        organizationWrapper.shortName = 'test short name';
        organizationWrapper.department = parentAcc.Id;
        organizationWrapper.startDate = Date.today();
        organizationWrapper.description = 'description';

        String newOrganisationId = TB_vu_StudentOrganizationWizard.saveOrganization(organizationWrapper, new List<String>());

        supervisor = contacts[2];
        hed__Affiliation__c aff = TB_TestDataFactory.createAffiliation(supervisor, new Account(id=newOrganisationId), false);
        aff.hed__Role__c = TB_Constants.AFFILIATION_ROLE_SUPERVISOR;
        aff.hed__Status__c = TB_Constants.AFFILIATION_STATUS_AWAITING;
        insert aff;

        supervisor = contacts[3];

        organizationWrapper.recordId = newOrganisationId;
        organizationWrapper.supervisor = supervisor.Id;

        Id previousChairmanAffiliationId = [SELECT Id FROM hed__Affiliation__c WHERE hed__Role__c =: TB_Constants.AFFILIATION_ROLE_CHAIRMAN]?.Id;
        List<hed__Affiliation__c> previousSupervisorAffiliations = [SELECT Id FROM hed__Affiliation__c WHERE hed__Role__c =: TB_Constants.AFFILIATION_ROLE_SUPERVISOR];

        //when
        Test.startTest();
        newOrganisationId = TB_vu_StudentOrganizationWizard.saveOrganization(organizationWrapper, new List<String>());
        Test.stopTest();

        //then
        hed__Affiliation__c currentChairmanAffiliation = [SELECT Id, hed__Contact__c FROM hed__Affiliation__c WHERE hed__Role__c =: TB_Constants.AFFILIATION_ROLE_CHAIRMAN];
        List<hed__Affiliation__c> currentSupervisorAffiliation = [SELECT Id, hed__Contact__c FROM hed__Affiliation__c WHERE hed__Role__c =: TB_Constants.AFFILIATION_ROLE_SUPERVISOR];
        System.assertEquals(chairman.Id, currentChairmanAffiliation?.hed__Contact__c, 'Should match to chairman\'s Id');
        System.assertEquals(supervisor.Id, currentSupervisorAffiliation[0]?.hed__Contact__c, 'Should match to supervisor\'s Id');
        System.assertNotEquals(previousChairmanAffiliationId, currentSupervisorAffiliation[0]?.Id, 'Provided Ids should not match');
        System.assertNotEquals(previousSupervisorAffiliations[0]?.Id, currentSupervisorAffiliation[0]?.Id, 'Affiliations ids should not match');
        System.assertEquals(2, previousSupervisorAffiliations.size(), 'Should return 2 affiliations');
        System.assertEquals(1, currentSupervisorAffiliation.size(), 'Should return 1 affiliations');
    }

    @IsTest
    static void shouldAddAffiliationsForMembers() {
        //given
        List<Contact> contacts = [SELECT Id FROM Contact WHERE LastName LIKE 'member%'];
        Contact chairman = contacts[0];
        Contact supervisor = contacts[1];
        Account parentAcc = [SELECT Id FROM Account WHERE DT_Unit_Type__c =: TEST_ACC_UNIT_TYPE];
        TB_vu_StudentOrganizationWizard.Organization organizationWrapper = new TB_vu_StudentOrganizationWizard.Organization();
        organizationWrapper.status = 'Draft';
        organizationWrapper.chairman = chairman.Id;
        organizationWrapper.supervisor = supervisor.Id;
        organizationWrapper.name = 'test name123';
        organizationWrapper.shortName = 'test short name';
        organizationWrapper.department = parentAcc.Id;
        organizationWrapper.startDate = Date.today();
        organizationWrapper.description = 'description';

        //when
        Test.startTest();
        String newOrganisationId = TB_vu_StudentOrganizationWizard.saveOrganization(organizationWrapper, new List<String>{contacts[2].Id, contacts[3].Id, contacts[4].Id, contacts[5].Id, contacts[6].Id});
        Test.stopTest();

        //then
        System.assertEquals(5, [SELECT Id FROM hed__Affiliation__c WHERE hed__Account__c =: newOrganisationId AND hed__Role__c =: TB_Constants.AFFILIATION_ROLE_MEMBER].size(), 'Should return number of passed contacts');
    }

    @IsTest
    static void shouldDeleteOldAndInsertNewAffiliation() {
        //given
        Boolean contactFound = false;
        List<Contact> contacts = [SELECT Id FROM Contact WHERE LastName LIKE 'member%'];
        Contact chairman = contacts[0];
        Contact supervisor = contacts[1];
        Account parentAcc = [SELECT Id FROM Account WHERE DT_Unit_Type__c =: TEST_ACC_UNIT_TYPE];
        TB_vu_StudentOrganizationWizard.Organization organizationWrapper = new TB_vu_StudentOrganizationWizard.Organization();
        organizationWrapper.status = 'Draft';
        organizationWrapper.chairman = chairman.Id;
        organizationWrapper.supervisor = supervisor.Id;
        organizationWrapper.name = 'test name123';
        organizationWrapper.shortName = 'test short name';
        organizationWrapper.department = parentAcc.Id;
        organizationWrapper.startDate = Date.today();
        organizationWrapper.description = 'description';

        String newOrganisationId = TB_vu_StudentOrganizationWizard.saveOrganization(organizationWrapper, new List<String>{contacts[2].Id, contacts[3].Id, contacts[4].Id, contacts[5].Id, contacts[6].Id, contacts[7].Id, contacts[8].Id});
        organizationWrapper.recordId = newOrganisationId;
        Set<Id> oldAffiliationIds = new Set<Id>();
        for(hed__Affiliation__c aff : [SELECT Id, hed__Contact__c FROM hed__Affiliation__c WHERE hed__Account__c =: newOrganisationId AND hed__Role__c =: TB_Constants.AFFILIATION_ROLE_MEMBER]){
            oldAffiliationIds.add(aff.hed__Contact__c);
        }

        //when
        Test.startTest();
        newOrganisationId = TB_vu_StudentOrganizationWizard.saveOrganization(organizationWrapper,
                new List<String>{contacts[9].Id, contacts[10].Id, contacts[11].Id, contacts[12].Id, contacts[13].Id, contacts[14].Id, contacts[15].Id, contacts[16].Id, contacts[17].Id});
        Test.stopTest();

        //then
        Set<Id> newAffiliationIds = new Set<Id>();
        for(hed__Affiliation__c aff : [SELECT Id, hed__Contact__c FROM hed__Affiliation__c WHERE hed__Account__c =: newOrganisationId AND hed__Role__c =: TB_Constants.AFFILIATION_ROLE_MEMBER]){
            newAffiliationIds.add(aff.hed__Contact__c);
        }
        for(Id affId : newAffiliationIds){
            if(oldAffiliationIds.contains(affId)){
                contactFound = true;
                break;
            }
        }
        System.assertEquals(9, [SELECT Id FROM hed__Affiliation__c WHERE hed__Account__c =: newOrganisationId AND hed__Role__c =: TB_Constants.AFFILIATION_ROLE_MEMBER].size(), 'Should return number of passed contacts');
        System.assertEquals(false, contactFound, 'Compared sets should not return a match');

    }

    @IsTest
    static void shouldDeleteNotMatchedAndInsertNewAffiliation() {
        //given
        Integer matchedContactsCount = 0;
        List<Contact> contacts = [SELECT Id FROM Contact WHERE LastName LIKE 'member%'];
        Contact chairman = contacts[0];
        Contact supervisor = contacts[1];
        Account parentAcc = [SELECT Id FROM Account WHERE DT_Unit_Type__c =: TEST_ACC_UNIT_TYPE];
        TB_vu_StudentOrganizationWizard.Organization organizationWrapper = new TB_vu_StudentOrganizationWizard.Organization();
        organizationWrapper.status = 'Draft';
        organizationWrapper.chairman = chairman.Id;
        organizationWrapper.supervisor = supervisor.Id;
        organizationWrapper.name = 'test name123';
        organizationWrapper.shortName = 'test short name';
        organizationWrapper.department = parentAcc.Id;
        organizationWrapper.startDate = Date.today();
        organizationWrapper.description = 'description';

        String newOrganisationId = TB_vu_StudentOrganizationWizard.saveOrganization(organizationWrapper, new List<String>{contacts[2].Id, contacts[3].Id, contacts[4].Id,
                contacts[5].Id, contacts[6].Id, contacts[7].Id, contacts[8].Id, contacts[9].Id, contacts[10].Id});
        organizationWrapper.recordId = newOrganisationId;
        Set<Id> oldAffiliationIds = new Set<Id>();
        for(hed__Affiliation__c aff : [SELECT Id, hed__Contact__c FROM hed__Affiliation__c WHERE hed__Account__c =: newOrganisationId AND hed__Role__c =: TB_Constants.AFFILIATION_ROLE_MEMBER]){
            oldAffiliationIds.add(aff.hed__Contact__c);
        }


        //when
        Test.startTest();
        // contacts [9] and [10] are passed again
        newOrganisationId = TB_vu_StudentOrganizationWizard.saveOrganization(organizationWrapper,
                new List<String>{contacts[9].Id, contacts[10].Id, contacts[11].Id, contacts[12].Id, contacts[13].Id, contacts[14].Id, contacts[15].Id, contacts[16].Id, contacts[17].Id});
        Test.stopTest();

        //then
        Set<Id> newAffiliationIds = new Set<Id>();
        for(hed__Affiliation__c aff : [SELECT Id, hed__Contact__c FROM hed__Affiliation__c WHERE hed__Account__c =: newOrganisationId AND hed__Role__c =: TB_Constants.AFFILIATION_ROLE_MEMBER]){
            newAffiliationIds.add(aff.hed__Contact__c);
        }
        for(Id affId : newAffiliationIds){
            if(oldAffiliationIds.contains(affId)){
                matchedContactsCount++;
            }
        }

        System.assertEquals(9, [SELECT Id FROM hed__Affiliation__c WHERE hed__Account__c =: newOrganisationId AND hed__Role__c =: TB_Constants.AFFILIATION_ROLE_MEMBER].size(), 'Should return number of passed contacts');
        System.assertEquals(2, matchedContactsCount, 'Should return number of the same contacts used in manageOrganisationMembersAffiliations function calls');

    }
}