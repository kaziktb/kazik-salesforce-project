/**
 * Created by jakubWrzodek on 12/01/23.
 */
@IsTest
private class TB_MultiContactTriggerHandlerTest {
    static TB_Multi_Contact_Matching_Rule__mdt populateMatchingRule(String matchingField, Integer matchingRuleOrder) {
        return new TB_Multi_Contact_Matching_Rule__mdt(
                TB_Active__c = true,
                TB_Matching_Field_API_Name__c = matchingField,
                TB_Order__c = matchingRuleOrder,
                TB_Is_Triggered__c = true
        );
    }

    static List<TB_Multi_Contact_Matching_Rule__mdt> populateMatchingRuleList(List<String> matchingFields) {
        List<TB_Multi_Contact_Matching_Rule__mdt> result = new List<TB_Multi_Contact_Matching_Rule__mdt>();
        Integer matchingRuleOrder = 0;
        for (Integer i = 0; i < matchingFields.size(); i++) {
            result.add(populateMatchingRule(matchingFields.get(i), matchingRuleOrder));
            matchingRuleOrder += 10;
        }
        return result;
    }

    @IsTest
    private static void getContactsWithAnyFieldsFromTest_OneContact_OneField() {
        TB_StaticTest.setDoNotRunTriggers();
        final List<String> TEST_FIELD_NAMES = new List<String>{'Id', 'LastName'};
        final List<String> TEST_CONDITIONS = new List<String>{'LastName = \'DuplicateLastName\''};
        Contact testContactA = TB_TestDataFactory.createContact();
        testContactA.LastName = 'DuplicateLastName';
        insert testContactA;

        Test.startTest();
        List<Contact> result = TB_MultiContactTriggerHandler.getContactsWithAnyFieldsFrom(TEST_FIELD_NAMES, TEST_CONDITIONS);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Returned number of contacts has to be 1');
    }

    @IsTest
    private static void getContactsWithAnyFieldsFromTest_TwoContacts_OneField() {
        TB_StaticTest.setDoNotRunTriggers();
        final List<String> TEST_FIELD_NAMES = new List<String>{'Id', 'LastName'};
        final List<String> TEST_CONDITIONS = new List<String>{'LastName = \'DuplicateLastName\''};
        Contact testContactA = TB_TestDataFactory.createContact();
        Contact testContactB = TB_TestDataFactory.createContact();
        Contact testContactC = TB_TestDataFactory.createContact();
        testContactA.LastName = 'DuplicateLastName';
        testContactB.LastName = 'DuplicateLastName';
        insert new List<Contact>{testContactA, testContactB, testContactC};

        Test.startTest();
        List<Contact> result = TB_MultiContactTriggerHandler.getContactsWithAnyFieldsFrom(TEST_FIELD_NAMES, TEST_CONDITIONS);
        Test.stopTest();

        System.assertEquals(2, result.size(), 'Returned number of contacts has to be 2');
    }

    @IsTest
    private static void getContactsWithAnyFieldsFromTest_TwoContacts_TwoFields() {
        TB_StaticTest.setDoNotRunTriggers();
        final List<String> TEST_FIELD_NAMES = new List<String>{'Id', 'LastName'};
        final List<String> TEST_CONDITIONS = new List<String>{'LastName = \'DuplicateLastName\'', 'FirstName = \'DuplicateFirstName\''};
        Contact testContactA = TB_TestDataFactory.createContact();
        Contact testContactB = TB_TestDataFactory.createContact();
        testContactA.LastName = 'DuplicateLastName';
        testContactB.FirstName = 'DuplicateFirstName';
        insert new List<Contact>{testContactA, testContactB};

        Test.startTest();
        List<Contact> result = TB_MultiContactTriggerHandler.getContactsWithAnyFieldsFrom(TEST_FIELD_NAMES, TEST_CONDITIONS);
        Test.stopTest();

        System.assertEquals(2, result.size(), 'Returned number of contacts has to be 2');
    }

    @IsTest
    private static void getOtherContactsTest_OneContact_OneMatchingRule() {
        TB_StaticTest.setDoNotRunTriggers();
        final List<String> MATCHING_FIELDS = new List<String>{'LastName'};
        final List<TB_Multi_Contact_Matching_Rule__mdt> MATCHING_RULES = populateMatchingRuleList(MATCHING_FIELDS);
        Contact testContactA = TB_TestDataFactory.createContact();
        testContactA.LastName = 'DuplicateLastName';
        insert testContactA;

        Contact testTriggeredContactA = TB_TestDataFactory.createContact();
        testTriggeredContactA.LastName = 'DuplicateLastName';
        final List<Contact> CONTACTS = new List<Contact>{testTriggeredContactA};

        Test.startTest();
        List<Contact> result = TB_MultiContactTriggerHandler.getOtherContacts(CONTACTS, MATCHING_RULES);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Returned number of contacts has to be 1');
    }

    @IsTest
    private static void getOtherContactsTest_TwoContacts_TwoMatchingRules() {
        TB_StaticTest.setDoNotRunTriggers();
        final List<String> MATCHING_FIELDS = new List<String>{'LastName', 'FirstName'};
        final List<TB_Multi_Contact_Matching_Rule__mdt> MATCHING_RULES = populateMatchingRuleList(MATCHING_FIELDS);
        Contact testContactA = TB_TestDataFactory.createContact();
        testContactA.LastName = 'DuplicateLastName';
        Contact testContactB = TB_TestDataFactory.createContact();
        testContactB.FirstName = 'DuplicateFirstName';
        insert new List<Contact>{testContactA, testContactB};

        Contact testTriggeredContactA = TB_TestDataFactory.createContact();
        testTriggeredContactA.LastName = 'DuplicateLastName';
        Contact testTriggeredContactB = TB_TestDataFactory.createContact();
        testTriggeredContactB.FirstName = 'DuplicateFirstName';
        final List<Contact> CONTACTS = new List<Contact>{testTriggeredContactA, testTriggeredContactB};

        Test.startTest();
        List<Contact> result = TB_MultiContactTriggerHandler.getOtherContacts(CONTACTS, MATCHING_RULES);
        Test.stopTest();

        System.assertEquals(2, result.size(), 'Returned number of contacts has to be 2');
    }

    @IsTest
    private static void searchForDuplicatesTest_OneMatchingRule_WithoutIndividual() {
        TB_StaticTest.setDoNotRunTriggers();
        Set<Id> duplicatedIndividualsIds = new Set<Id>();
        final List<String> MATCHING_FIELDS = new List<String>{'LastName'};
        final List<TB_Multi_Contact_Matching_Rule__mdt> MATCHING_RULES = populateMatchingRuleList(MATCHING_FIELDS);
        Contact testContactA = TB_TestDataFactory.createContact();
        testContactA.LastName = 'DuplicateLastName';
        final List<Contact> OTHER_CONTACTS = new List<Contact>{testContactA};

        Contact contact = TB_TestDataFactory.createContact();
        contact.LastName = 'DuplicateLastName';

        Test.startTest();
        TB_MultiContactTriggerHandler.ContactMatcher result = (TB_MultiContactTriggerHandler.ContactMatcher) TB_MultiContactTriggerHandler.searchForDuplicates(contact, OTHER_CONTACTS, MATCHING_RULES, duplicatedIndividualsIds);
        Test.stopTest();

//        System.assertNotEquals(null, result, 'Returned contact matcher cannot be null');
//        System.assertNotEquals(null, result.otherContact, 'Returned contact matcher other contact cannot be null');
//        System.assertNotEquals(null, result.individual, 'Returned contact matcher individual cannot be null');
    }

    @IsTest
    private static void searchForDuplicatesTest_OneMatchingRule_IncorrectConcatFields() {
        TB_StaticTest.setDoNotRunTriggers();
        Set<Id> duplicatedIndividualsIds = new Set<Id>();
        final List<String> MATCHING_FIELDS = new List<String>{'LastName+FirstName'};
        final List<TB_Multi_Contact_Matching_Rule__mdt> MATCHING_RULES = populateMatchingRuleList(MATCHING_FIELDS);
        Contact testContactA = TB_TestDataFactory.createContact();
        testContactA.FirstName = 'DuplicateFirstName';
        final List<Contact> OTHER_CONTACTS = new List<Contact>{testContactA};

        Contact contact = TB_TestDataFactory.createContact();
        contact.FirstName = 'DuplicateFirstName';
        contact.LastName = 'DuplicateLastName';

        Test.startTest();
        TB_MultiContactTriggerHandler.ContactMatcher result = (TB_MultiContactTriggerHandler.ContactMatcher) TB_MultiContactTriggerHandler.searchForDuplicates(contact, OTHER_CONTACTS, MATCHING_RULES, duplicatedIndividualsIds);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Returned contact matcher cannot be null');
        System.assertEquals(null, result.otherContact, 'Returned contact matcher other contact has to be null');
    }

    @IsTest
    private static void searchForDuplicatesTest_OneMatchingRule_CorrectConcatFields() {
        TB_StaticTest.setDoNotRunTriggers();
        Set<Id> duplicatedIndividualsIds = new Set<Id>();
        final List<String> MATCHING_FIELDS = new List<String>{'LastName+FirstName'};
        final List<TB_Multi_Contact_Matching_Rule__mdt> MATCHING_RULES = populateMatchingRuleList(MATCHING_FIELDS);
        Contact testContactA = TB_TestDataFactory.createContact();
        testContactA.FirstName = 'DuplicateFirstName';
        testContactA.LastName = 'DuplicateLastName';
        final List<Contact> OTHER_CONTACTS = new List<Contact>{testContactA};

        Individual individual = new Individual(
                LastName = testContactA.LastName,
                FirstName = testContactA.FirstName,
                Salutation = testContactA.Salutation,
                BirthDate = testContactA.Birthdate,
                TB_Global_Id__c = testContactA.TB_Global_Id__c,
                TB_VDO_Id__c = testContactA.DT_VDO_ID__c
        );
        insert individual;

        testContactA.IndividualId = individual.Id;

        Contact contact = TB_TestDataFactory.createContact();
        contact.FirstName = 'DuplicateFirstName';
        contact.LastName = 'DuplicateLastName';
        insert new List<Contact>{testContactA, contact};

        Test.startTest();
        TB_MultiContactTriggerHandler.IndividualMatcher result = (TB_MultiContactTriggerHandler.IndividualMatcher) TB_MultiContactTriggerHandler.searchForDuplicates(contact, OTHER_CONTACTS, MATCHING_RULES, duplicatedIndividualsIds);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Returned individual matcher cannot be null');
        System.assertNotEquals(null, result.contact, 'Returned individual matcher other contact cannot be null');
        System.assertNotEquals(null, result.individualId, 'Returned individual matcher individual cannot be null');
    }

    @IsTest
    private static void searchForDuplicatesTest_OneMatchingRule_PartiallyCorrectConcatFields() {
        TB_StaticTest.setDoNotRunTriggers();
        Set<Id> duplicatedIndividualsIds = new Set<Id>();
        final List<String> MATCHING_FIELDS = new List<String>{'LastName+FirstName'};
        final List<TB_Multi_Contact_Matching_Rule__mdt> MATCHING_RULES = populateMatchingRuleList(MATCHING_FIELDS);
        Contact testContactA = TB_TestDataFactory.createContact();
        testContactA.FirstName = 'DuplicateFirstName';
        testContactA.LastName = 'DuplicateLastName';
        final List<Contact> OTHER_CONTACTS = new List<Contact>{
                testContactA
        };

        Contact contact = TB_TestDataFactory.createContact();
        contact.FirstName = 'DuplicateFirstName';

        Test.startTest();
        TB_MultiContactTriggerHandler.ContactMatcher result = (TB_MultiContactTriggerHandler.ContactMatcher) TB_MultiContactTriggerHandler.searchForDuplicates(contact, OTHER_CONTACTS, MATCHING_RULES, duplicatedIndividualsIds);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Returned contact matcher cannot be null');
        System.assertEquals(null, result.otherContact, 'Returned contact matcher other contact has to be null');
    }

    @IsTest
    private static void searchForDuplicatesTest_TwoMatchingRules_WithoutIndividual() {
        TB_StaticTest.setDoNotRunTriggers();
        Set<Id> duplicatedIndividualsIds = new Set<Id>();
        final List<String> MATCHING_FIELDS = new List<String>{'LastName', 'FirstName'};
        final List<TB_Multi_Contact_Matching_Rule__mdt> MATCHING_RULES = populateMatchingRuleList(MATCHING_FIELDS);
        Contact testContactA = TB_TestDataFactory.createContact();
        testContactA.LastName = 'DuplicateLastName';
        Contact testContactB = TB_TestDataFactory.createContact();
        testContactB.FirstName = 'DuplicateFirstName';
        final List<Contact> OTHER_CONTACTS = new List<Contact>{testContactA, testContactB};

        Contact contact = TB_TestDataFactory.createContact();
        contact.LastName = 'DuplicateLastName';

        Test.startTest();
        TB_MultiContactTriggerHandler.ContactMatcher result = (TB_MultiContactTriggerHandler.ContactMatcher) TB_MultiContactTriggerHandler.searchForDuplicates(contact, OTHER_CONTACTS, MATCHING_RULES, duplicatedIndividualsIds);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Returned contact matcher cannot be null');
        System.assertNotEquals(null, result.individual, 'Returned contact matcher individual cannot be null');
        System.assertEquals('FirstName', result.matchingFieldName, 'Returned contact matcher matching field name has be LastName');
    }

    @IsTest
    private static void searchForDuplicatesTest_OneMatchingRule_WithIndividual() {
        TB_StaticTest.setDoNotRunTriggers();
        Set<Id> duplicatedIndividualsIds = new Set<Id>();
        final List<String> MATCHING_FIELDS = new List<String>{'LastName'};
        final List<TB_Multi_Contact_Matching_Rule__mdt> MATCHING_RULES = populateMatchingRuleList(MATCHING_FIELDS);
        Individual testIndividual = new Individual(LastName = 'DuplicateLastName');
        insert testIndividual;

        Contact testContactA = TB_TestDataFactory.createContact();
        testContactA.LastName = 'DuplicateLastName';
        testContactA.IndividualId = testIndividual.Id;
        final List<Contact> OTHER_CONTACTS = new List<Contact>{testContactA};

        Contact contact = TB_TestDataFactory.createContact();
        contact.LastName = 'DuplicateLastName';

        insert new List<Contact>{testContactA, contact};

        Test.startTest();
        TB_MultiContactTriggerHandler.Matcher result = (TB_MultiContactTriggerHandler.Matcher) TB_MultiContactTriggerHandler.searchForDuplicates(contact, OTHER_CONTACTS, MATCHING_RULES, duplicatedIndividualsIds);
        Test.stopTest();

        System.assertEquals(false, result instanceof TB_MultiContactTriggerHandler.ContactMatcher, 'Returned matcher cannot be a contact matcher');
        System.assertNotEquals(null, contact.IndividualId, 'Contact individual id cannot to be null');
    }

    @IsTest
    private static void searchForDuplicatesTest_OneMatchingRule_WithoutDuplicates() {
        TB_StaticTest.setDoNotRunTriggers();
        Set<Id> duplicatedIndividualsIds = new Set<Id>();
        final List<String> MATCHING_FIELDS = new List<String>{'LastName'};
        final List<TB_Multi_Contact_Matching_Rule__mdt> MATCHING_RULES = populateMatchingRuleList(MATCHING_FIELDS);
        Contact testContactA = TB_TestDataFactory.createContact();
        testContactA.LastName = 'OtherLastName';
        final List<Contact> OTHER_CONTACTS = new List<Contact>{testContactA};

        Contact contact = TB_TestDataFactory.createContact();
        contact.LastName = 'DuplicateLastName';

        Test.startTest();
        TB_MultiContactTriggerHandler.ContactMatcher result = (TB_MultiContactTriggerHandler.ContactMatcher) TB_MultiContactTriggerHandler.searchForDuplicates(contact, OTHER_CONTACTS, MATCHING_RULES, duplicatedIndividualsIds);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Returned contact matcher cannot be null');
        System.assertEquals(null, result.otherContact, 'Returned contact matcher other contact has to be null');
        System.assertNotEquals(null, result.individual, 'Returned contact matcher individual cannot be null');
    }

    @IsTest
    private static void performCrudActionsFromTest_OneMatcher_WithoutOtherContact() {
        TB_StaticTest.setDoNotRunTriggers();
        User testUser = TB_DataFactory.createUser('Standard User', true);
        Contact testContactA = TB_TestDataFactory.createContact();
        Contact testContactB = TB_TestDataFactory.createContact();
        testContactA.TB_User__c = testUser.Id;
        insert new List<Contact>{testContactA, testContactB};

        Individual testIndividual = new Individual(LastName = 'DuplicateLastName');
        TB_MultiContactTriggerHandler.ContactMatcher matcher = new TB_MultiContactTriggerHandler.ContactMatcher(testContactA);
        matcher.individual = testIndividual;
        List<TB_MultiContactTriggerHandler.ContactMatcher> matchers = new List<TB_MultiContactTriggerHandler.ContactMatcher>{matcher};

        Test.startTest();
        TB_MultiContactTriggerHandler.performCrudActionsFrom(matchers, new List<Contact>());
        Test.stopTest();

        List<Individual> returnedIndividuals = [SELECT Id FROM Individual];
        List<Contact> returnedOtherContactsWithIndividual = [SELECT Id, IndividualId FROM Contact WHERE IndividualId != null];
        List<User> returnedUserWithIndividual = [SELECT Id FROM User WHERE IndividualId != null AND Id = :testUser.Id];

        System.assertEquals(1, returnedIndividuals.size(), 'Returned number of individual has to be 1');
        System.assertEquals(0, returnedOtherContactsWithIndividual.size(), 'Returned number of other contacts with individuals has to be 0');
        System.assertEquals(1, returnedUserWithIndividual.size(), 'Returned number of users with individuals has to be 1');
    }

    @IsTest
    private static void performCrudActionsFromTest_OneMatcher_WithOtherContact() {
        TB_StaticTest.setDoNotRunTriggers();
        User testUser = TB_DataFactory.createUser('Standard User', true);
        Contact testContactA = TB_TestDataFactory.createContact();
        Contact testContactB = TB_TestDataFactory.createContact();
        testContactA.TB_User__c = testUser.Id;
        insert new List<Contact>{testContactA, testContactB};

        Individual testIndividual = new Individual(LastName = 'DuplicateLastName');
        TB_MultiContactTriggerHandler.ContactMatcher matcher = new TB_MultiContactTriggerHandler.ContactMatcher(testContactA);
        matcher.individual = testIndividual;
        matcher.otherContact = testContactB;
        List<TB_MultiContactTriggerHandler.ContactMatcher> matchers = new List<TB_MultiContactTriggerHandler.ContactMatcher>{matcher};

        Test.startTest();
        TB_MultiContactTriggerHandler.performCrudActionsFrom(matchers, new List<Contact>());
        Test.stopTest();

        List<Individual> returnedIndividuals = [SELECT Id FROM Individual];
        List<Contact> returnedOtherContactsWithIndividual = [SELECT Id, IndividualId FROM Contact WHERE IndividualId != null];
        List<User> returnedUserWithIndividual = [SELECT Id FROM User WHERE IndividualId != null AND Id = :testUser.Id];

        System.assertEquals(1, returnedIndividuals.size(), 'Returned number of individual has to be 1');
        System.assertEquals(1, returnedOtherContactsWithIndividual.size(), 'Returned number of other contacts with individuals has to be 1');
        System.assertEquals(1, returnedUserWithIndividual.size(), 'Returned number of users with individuals has to be 1');
    }

    @IsTest
    private static void performCrudActionsFromTest_NoMatcher() {
        TB_StaticTest.setDoNotRunTriggers();
        User testUser = TB_DataFactory.createUser('Standard User', true);
        Individual testIndividual = new Individual(LastName = 'DuplicateLastName');
        insert testIndividual;
        Contact testContactA = TB_TestDataFactory.createContact();
        Contact testContactB = TB_TestDataFactory.createContact();
        testContactA.TB_User__c = testUser.Id;
        testContactA.IndividualId = testIndividual.Id;
        insert new List<Contact>{testContactA, testContactB};

        Test.startTest();
        TB_MultiContactTriggerHandler.performCrudActionsFrom(new List<TB_MultiContactTriggerHandler.ContactMatcher>(), new List<Contact>{testContactA});
        Test.stopTest();

        List<Individual> returnedIndividuals = [SELECT Id FROM Individual];
        List<Contact> returnedOtherContactsWithIndividual = [SELECT Id, IndividualId FROM Contact WHERE IndividualId != null];
        List<User> returnedUserWithIndividual = [SELECT Id FROM User WHERE IndividualId != null AND Id = :testUser.Id];

        System.assertEquals(1, returnedIndividuals.size(), 'Returned number of individual has to be 1');
        System.assertEquals(1, returnedOtherContactsWithIndividual.size(), 'Returned number of other contacts with individuals has to be 1');
        System.assertEquals(1, returnedUserWithIndividual.size(), 'Returned number of users with individuals has to be 1');
    }

    @IsTest
    private static void checkMulticontactDuplicatesTest() {
        TB_StaticTest.setDoNotRunTriggers();
        User testUser = TB_DataFactory.createUser('Standard User', true);
        final List<TB_Multi_Contact_Matching_Rule__mdt> MATCHING_RULES = new List<TB_Multi_Contact_Matching_Rule__mdt>{populateMatchingRule('FirstName', 10)};

        Contact testContactA = TB_TestDataFactory.createContact();
        Contact testContactB = TB_TestDataFactory.createContact();
        testContactA.TB_User__c = testUser.Id;
        testContactA.FirstName = 'DuplicateFirstName';
        testContactB.TB_User__c = testUser.Id;
        testContactB.FirstName = 'DuplicateFirstName';
        testContactB.LastName = 'OtherLastName';
        insert testContactA;
        final List<Contact> CONTACTS = new List<Contact>{testContactB};

        Test.startTest();
        TB_MultiContactTriggerHandler.checkMultiContactDuplicates(CONTACTS, MATCHING_RULES);
        insert testContactB;
        Test.stopTest();

        List<Individual> returnedIndividuals = [SELECT Id FROM Individual];
        List<Contact> returnedContactsWithIndividual = [SELECT Id, IndividualId FROM Contact WHERE IndividualId != null];
        List<User> returnedUserWithIndividual = [SELECT Id FROM User WHERE IndividualId != null AND Id = :testUser.Id];

        System.assertEquals(1, returnedIndividuals.size(), 'Returned number of individual has to be 1');
        System.assertEquals(2, returnedContactsWithIndividual.size(), 'Returned number of contacts with individuals has to be 2');
        System.assertEquals(1, returnedUserWithIndividual.size(), 'Returned number of users with individuals has to be 1');
    }

    @IsTest
    private static void checkMulticontactDuplicatesForUpdateTest() {
        TB_StaticTest.setDoNotRunTriggers();
        User testUser = TB_DataFactory.createUser('Standard User', true);
        final List<TB_Multi_Contact_Matching_Rule__mdt> MATCHING_RULES = new List<TB_Multi_Contact_Matching_Rule__mdt>{populateMatchingRule('FirstName', 10)};
        Contact testContactA = TB_TestDataFactory.createContact();
        Contact testContactB = TB_TestDataFactory.createContact();
        testContactA.TB_User__c = testUser.Id;
        testContactA.FirstName = 'DuplicateFirstName';
        testContactB.TB_User__c = testUser.Id;
        testContactB.FirstName = 'NotDuplicateFirstName';
        insert testContactA;
        insert testContactB;
        final Map<Id,SObject> OLD_CONTACTS_MAP = new Map<Id,SObject>();
        OLD_CONTACTS_MAP.put(testContactB.Id, testContactB);
        Contact testContactBClone = TB_TestDataFactory.createContact();
        testContactBClone.Id = testContactB.Id;
        testContactBClone.FirstName = 'DuplicateFirstName';
        testContactBClone.TB_User__c = testUser.Id;
        final List<Contact> CONTACTS = new List<Contact>{testContactBClone};

        TB_MultiContactTriggerHandler.IGNORE_TRIGGER = true;
        Test.startTest();
        TB_MultiContactTriggerHandler.checkMultiContactDuplicates(OLD_CONTACTS_MAP, CONTACTS, MATCHING_RULES);
        Test.stopTest();
        TB_MultiContactTriggerHandler.IGNORE_TRIGGER = false;

        List<Individual> returnedIndividuals = [SELECT Id FROM Individual];
        List<Contact> returnedContactsWithIndividual = [SELECT Id, IndividualId FROM Contact WHERE IndividualId != null];
        List<User> returnedUserWithIndividual = [SELECT Id FROM User WHERE IndividualId != null AND Id = :testUser.Id];

        System.assertEquals(1, returnedIndividuals.size(), 'Returned number of individual has to be 1');
        System.assertEquals(1, returnedContactsWithIndividual.size(), 'Returned number of contacts with individuals has to be 2');
        System.assertEquals(1, returnedUserWithIndividual.size(), 'Returned number of users with individuals has to be 1');
    }

    @IsTest
    private static void checkMulticontactDuplicatesTest_AsInsertTrigger() {
        User testUser = TB_DataFactory.createUser('Standard User', true);
        Contact testContactA = TB_TestDataFactory.createContact();
        testContactA.TB_User__c = testUser.Id;

        Test.startTest();
        insert testContactA;
        Test.stopTest();

        List<Individual> returnedIndividuals = [SELECT Id FROM Individual];
        List<Contact> returnedContactsWithIndividual = [SELECT Id, IndividualId FROM Contact WHERE IndividualId != null];
        List<User> returnedUserWithIndividual = [SELECT Id FROM User WHERE IndividualId != null AND Id = :testUser.Id];

        System.assert(returnedIndividuals.size() == 1 || returnedIndividuals.size() == 3, 'Returned number of individual has to be 1 OR 3 since sometimes when insert there are two updates of contact. Only the final individual is committed.');
        System.assertEquals(1, returnedContactsWithIndividual.size(), 'Returned number of contacts with individuals has to be 1');
        System.assertEquals(1, returnedUserWithIndividual.size(), 'Returned number of users with individuals has to be 1');
    }

    @IsTest
    private static void checkMulticontactDuplicatesTest_AsInsertTrigger_CommunityUser() {
        User adminUser = TB_TestDataFactory.createUser('System Administrator', true);
        System.runAs(adminUser) {
            TB_StaticTest.setDoNotRunTriggers();
            User testUser = TB_TestDataFactory.createUser(TB_Constants.PROFILE_NAME_APPLICANT, false);
            testUser.ContactId = TB_TestDataFactory.createContact(true).Id;
            TB_StaticTest.unsetDoNotRunTriggers();

            Contact testContactA = TB_TestDataFactory.createContact();
            testContactA.LastName = 'OtherLastName';
            testContactA.TB_User__c = testUser.Id;

            Test.startTest();
            insert testContactA;
            Test.stopTest();

            List<Individual> returnedIndividuals = [SELECT Id FROM Individual];
            List<Contact> returnedContactsWithIndividual = [SELECT Id, IndividualId FROM Contact WHERE IndividualId != null AND Id = :testContactA.Id];
            List<User> returnedUserWithIndividual = [SELECT Id FROM User WHERE IndividualId != null AND Id = :testUser.Id];

            System.assert(returnedIndividuals.size() == 1 || returnedIndividuals.size() == 3, 'Returned number of individual has to be 1 OR 3 since sometimes when insert there are two updates of contact. Only the final individual is committed.');
            System.assertEquals(1, returnedContactsWithIndividual.size(), 'Returned number of contacts with individuals has to be 1');
            System.assertEquals(0, returnedUserWithIndividual.size(), 'Returned number of users with individuals has to be 0');
        }
    }

    @IsTest
    private static void updateIndividualFieldsTest() {
        System.runAs(TB_re_TestDataFactory.createAdminUser()) {
            User testUser = TB_re_TestDataFactory.createAdminUser();
            Contact testContactA = TB_TestDataFactory.createContact();
            testContactA.TB_User__c = testUser.Id;
            testContactA.DT_PESEL__c = 'Duplicate';
            Contact testContactB = TB_TestDataFactory.createContact();
            testContactB.DT_PESEL__c = 'Duplicate';
            testContactB.TB_Global_Id__c = 1234;
            testContactB.DT_VDO_ID__c = 'vdoId';
            testContactB.TB_IM_Id__c = 'studentImId';
            testContactB.RecordTypeId = TB_re_Utils.getContactRecordTypeId(TB_re_Constants.CONTACT_STUDENT_RT);

            Test.startTest();
            insert testContactA;
            TB_MultiContactTriggerHandler.checkMultiContactDuplicates(new List<Contact>{testContactB}, new List<TB_Multi_Contact_Matching_Rule__mdt>{populateMatchingRule('DT_PESEL__c', 10)});
            Test.stopTest();

            Individual returnedIndividual = [SELECT Id, TB_Student_IM_Id__c, TB_VDO_Id__c, TB_Global_Id__c FROM Individual WHERE TB_Student_IM_Id__c != NULL LIMIT 1];

            System.assertNotEquals(null, returnedIndividual, 'Returned individual cannot be null');
            System.assertNotEquals(null, returnedIndividual.TB_Student_IM_Id__c, 'Returned individual field TB_Student_IM_Id__c cannot be null');
            System.assertNotEquals(null, returnedIndividual.TB_VDO_Id__c, 'Returned individual field TB_VDO_Id__c cannot be null');
            System.assertNotEquals(null, returnedIndividual.TB_Global_Id__c, 'Returned individual field TB_Global_Id__c cannot be null');
        }
    }
}