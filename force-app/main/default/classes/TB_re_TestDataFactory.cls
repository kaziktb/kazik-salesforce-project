@IsTest
public with sharing class TB_re_TestDataFactory {
    public static String generateUniqueText() {
        return generateUniqueText('');
    }

    public static String generateUniqueText(String prefix) {
        return prefix + System.currentTimeMillis();
    }

    public static String generateUniqueText(String prefix, Integer length) {
        String result = prefix;
        while (result.length() < length) {
            result = generateUniqueText(result);
        }
        return result.substring(0, length);
    }

    private static UserRole createUserRole(String roleName) {
        UserRole role = new UserRole(DeveloperName = roleName, Name = roleName);
        insert role;
        return role;
    }

    private static User createUser(String profileName, String lastName, Boolean withInsert) {
        User user = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = :profileName].Id,
                LastName = lastName,
                Email = lastName + '@test.com.invalid',
                Username = generateUniqueText(lastName + '@test.com.invalid'),
                CompanyName = lastName + 'TestCompany',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                Alias = 'alias'
        );
        if (withInsert) {
            insert user;
        }
        return user;
    }

    private static Contact createContact(Boolean withInsert) {
        Contact contact = new Contact(
                LastName = 'testContact',
                FirstName = 'testContact',
                TB_Communication_Language__c = 'English',
                Email = 'test@test.com'
        );
        if (withInsert) {
            insert contact;
        }
        return contact;
    }

    public static Contact createContact() {
        return createContact(false);
    }

    public static Contact createContactWithInsert() {
        return createContact(true);
    }

    public static Contact createContactFromLastName(String lastName) {
        Contact result = createContact(false);
        result.LastName = lastName;
        result.Email = 'test' + lastName + '@test.com';
        return result;
    }

    public static List<Contact> createContactList(Integer numberOfRecords) {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            contacts.add(createContact());
        }
        return contacts;
    }

    public static List<Contact> createContactListWithInsert(Integer numberOfRecords) {
        List<Contact> contacts = createContactList(numberOfRecords);
        insert contacts;
        return contacts;
    }

    public static Map<Id, Contact> createContactMap(Integer numberOfRecords) {
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        contactMap.putAll(createContactListWithInsert(numberOfRecords));
        return contactMap;
    }

    private static User createUser(String profileName, Boolean withInsert) {
        return createUser(profileName, generateUniqueText('testLastName'), withInsert);
    }

    public static User createUser(String profileName) {
        return createUser(profileName, generateUniqueText('testLastName'), false);
    }

    public static User createUserWithInsert(String profileName) {
        return createUser(profileName, generateUniqueText('testLastName'), true);
    }

    public static User createAdminUser() {
        return createUser(TB_re_Constants.PROFILE_NAME_ADMINISTRATOR, generateUniqueText('testAdminLastName'), false);
    }

    public static User createAdminUserWithInsert() {
        return createUser(TB_re_Constants.PROFILE_NAME_ADMINISTRATOR, generateUniqueText('testAdminLastName'), true);
    }

    public static User createCommunityUser() {
        User user = createUser(TB_re_Constants.PROFILE_NAME_APPLICANT);
        user.ContactId = createContact(true).Id;
        return user;
    }

    public static User createCommunityUserWithInsert() {
        User user = createCommunityUser();
        insert user;
        return user;
    }

    private static Account createAccount(Boolean withInsert) {
        Account account = new Account(
                    Name = generateUniqueText('testAccountName'),
                    TB_Email__c = generateUniqueText('testAccountName@test.com.invalid.'),
                    TB_Active__c = true
        );
        if (withInsert) {
            insert account;
        }
        return account;
    }

    public static Account createAccount() {
        return createAccount(false);
    }

    public static Account createAccountWithInsert() {
        return createAccount(true);
    }

    public static List<Account> createAccountList(Integer numberOfRecords) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            accounts.add(createAccount());
        }
        return accounts;
    }

    public static List<Account> createAccountListWithInsert(Integer numberOfRecords) {
        List<Account> accounts = createAccountList(numberOfRecords);
        insert accounts;
        return accounts;
    }

    public static Map<Id, Account> createAccountMap(Integer numberOfRecords) {
        Map<Id, Account> accountMap = new Map<Id, Account>();
        accountMap.putAll(createAccountListWithInsert(numberOfRecords));
        return accountMap;
    }

    private static hed__Affiliation__c createAffiliation(Contact contactToPass, Account accountToPass, Boolean toInsert) {
        hed__Affiliation__c affiliation = new hed__Affiliation__c(
            hed__Contact__c = contactToPass.Id,
            hed__Account__c = accountToPass.Id,
            hed__StartDate__c = Date.today(),
            hed__Role__c = 'SO_Member'
        );
        if(toInsert){
            insert affiliation;
        }
        return affiliation;
    }

    public static hed__Affiliation__c createAffiliation(Contact contactToPass, Account accountToPass) {
        return createAffiliation(contactToPass, accountToPass, false);
    }

    public static hed__Affiliation__c createAffiliationWithInsert(Contact contactToPass, Account accountToPass) {
        return createAffiliation(contactToPass, accountToPass, true);
    }

    public static hed__Affiliation__c createAffiliationWithContactAndAccount() {
        return createAffiliation(createContactWithInsert(), createAccountWithInsert(), true);
    }

    public static hed__Affiliation__c createAffiliationWithInsertWithContactAndAccount() {
        return createAffiliation(createContactWithInsert(), createAccountWithInsert(), true);
    }

    public static List<hed__Affiliation__c> createAffiliationList(Contact contactToPass, Account accountToPass, Integer numberOfRecords) {
        List<hed__Affiliation__c> affiliations = new List<hed__Affiliation__c>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            affiliations.add(createAffiliation(contactToPass, accountToPass));
        }
        return affiliations;
    }

    public static List<hed__Affiliation__c> createAffiliationListWithInsert(Contact contactToPass, Account accountToPass, Integer numberOfRecords) {
        List<hed__Affiliation__c> affiliations = createAffiliationList(contactToPass, accountToPass, numberOfRecords);
        insert affiliations;
        return affiliations;
    }

    public static List<hed__Affiliation__c> createAffiliationList(List<Contact> contactsToPass, List<Account> accountsToPass) {
        List<hed__Affiliation__c> affiliations = new List<hed__Affiliation__c>();
        for (Integer i = 0; i < contactsToPass.size(); i++) {
            affiliations.add(createAffiliation(contactsToPass[i], accountsToPass[i]));
        }
        return affiliations;
    }

    public static List<hed__Affiliation__c> createAffiliationListWithInsert(List<Contact> contactsToPass, List<Account> accountsToPass) {
        List<hed__Affiliation__c> affiliations = createAffiliationList(contactsToPass, accountsToPass);
        insert affiliations;
        return affiliations;
    }

    public static Map<Id, hed__Affiliation__c> createAffiliationMap(List<Contact> contactsToPass, List<Account> accountsToPass) {
        Map<Id, hed__Affiliation__c> affiliationMap = new Map<Id, hed__Affiliation__c>();
        affiliationMap.putAll(createAffiliationListWithInsert(contactsToPass, accountsToPass));
        return affiliationMap;
    }

    private static hed__Attribute__c createAttribute(Contact contact, Boolean toInsert) {
        hed__Attribute__c attribute = new hed__Attribute__c(
            hed__Contact__c = contact.Id
        );
        if(toInsert){
            insert attribute;
        }
        return attribute;
    }

    public static hed__Attribute__c createAttribute(Contact contact) {
        return createAttribute(contact, false);
    }

    public static hed__Attribute__c createAttributeWithInsert(Contact contact) {
        return createAttribute(contact, true);
    }

    public static List<hed__Attribute__c> createAttributeList(Contact contact, Integer numberOfRecords) {
        List<hed__Attribute__c> attributes = new List<hed__Attribute__c>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            attributes.add(createAttribute(contact));
        }
        return attributes;
    }

    public static List<hed__Attribute__c> createAttributeListWithInsert(Contact contact, Integer numberOfRecords) {
        List<hed__Attribute__c> attributes = createAttributeList(contact, numberOfRecords);
        insert attributes;
        return attributes;
    }


    @TestVisible
    private static List<TB_Admissions_Dictionary__c> createHSExamSubjectsDictionaryWithCode(Boolean withInsert, Map<String, String> subjectNameToCode) {
        List<TB_Admissions_Dictionary__c> dictionaries = new List<TB_Admissions_Dictionary__c>();
        for(String singleName : subjectNameToCode.keySet()) {
            dictionaries.add(new TB_Admissions_Dictionary__c(
                    Name = singleName,
                    TB_KReM_Subject_Code__c = subjectNameToCode.get(singleName),
                    RecordTypeId = TB_re_Constants.ADMISSIONS_DICTIONARY_RT_HS_EXAM_SUBJECT,
                    TB_Available_For_HS_Exams__c = TB_re_Constants.TB_APP_EXAM_TYPE_POLISH_SINCE_2005,
                    TB_Active__c = true
            ));
        }

        if(withInsert) {
            insert dictionaries;
        }
        return dictionaries;
    }

    @TestVisible
    private static TB_Admissions_Dictionary__c createHSExamSubjectDictionary(Boolean withInsert, String name, String availableFor) {
        TB_Admissions_Dictionary__c subjectDictionary = new TB_Admissions_Dictionary__c(
                Name = name,
                RecordTypeId = TB_re_Constants.ADMISSIONS_DICTIONARY_RT_HS_EXAM_SUBJECT,
                TB_Available_For_HS_Exams__c = availableFor,
                TB_Active__c = true
        );

        if(withInsert) {
            insert subjectDictionary;
        }
        return subjectDictionary;
    }

    @TestVisible
    private static TB_Admissions_Dictionary__c createHSExamSubjectDictionary(Boolean withInsert) {
        return createHSExamSubjectDictionary(withInsert, 'matematyka', TB_re_Constants.TB_APP_EXAM_TYPE_POLISH_SINCE_2005);
    }
}