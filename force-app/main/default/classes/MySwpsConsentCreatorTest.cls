@IsTest
private class MySwpsConsentCreatorTest {
    private static final String REQUEST_FORM_URL = 'www.google.com';
    private static final String REQUEST_USER_DETAILS = '{"browserVersion":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36"}';

    @TestSetup
    private static void testSetup() {
        ContactTestDataFactory.createStudent(true);
        TB_Admissions_Dictionary__c bundle = AdmissionsDictionaryTestDataFactory.createCareerOfficeConsentBundle(1, true)[0];
        AdmissionsDictionaryTestDataFactory.createCareerOfficeConsentDefinition(1, bundle.Id, Constants.ADMISSIONS_DICTIONARY_CONSENT_TYPE_TERMS_AND_CONDITIONS, true);
        AdmissionsDictionaryTestDataFactory.createCareerOfficeConsentDefinition(1, bundle.Id, Constants.ADMISSIONS_DICTIONARY_CONSENT_TYPE_MARKETING, true);
    }

    @IsTest
    static void createConsentsForContactSuccess() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        TB_Admissions_Dictionary__c consentBundle = [SELECT Id FROM TB_Admissions_Dictionary__c WHERE TB_Consents_Bundle__c = NULL LIMIT 1];
        Set<Id> consentTemplateIds = new Set<Id>();

        for (TB_Admissions_Dictionary__c consentTemplate : [SELECT Id FROM TB_Admissions_Dictionary__c WHERE TB_Consents_Bundle__c = :consentBundle.Id LIMIT 2]) {
            consentTemplateIds.add(consentTemplate.Id);
        }

        Test.startTest();
        MySwpsConsentCreator.createConsentsForContact(consentTemplateIds, REQUEST_USER_DETAILS, REQUEST_FORM_URL, contact.Id);
        Test.stopTest();

        List<TB_Consent__c> contactConsents = [SELECT Id, TB_Status__c, TB_User_Details__c, TB_Source__c FROM TB_Consent__c WHERE TB_Contact__c = :contact.Id];

        Assert.areEqual(2, contactConsents.size());

        for (TB_Consent__c consent : contactConsents) {
            Assert.areEqual(Constants.CONSENT_STATUS_OPT_IN_API_NAME, consent.TB_Status__c);
            Assert.areEqual(REQUEST_USER_DETAILS, consent.TB_User_Details__c);
            Assert.areEqual(REQUEST_FORM_URL, consent.TB_Source__c);
        }

    }

    @IsTest
    static void createConsentsForContactDuplicatedConsentNotCreated() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        TB_Admissions_Dictionary__c consentBundle = [SELECT Id FROM TB_Admissions_Dictionary__c WHERE TB_Consents_Bundle__c = NULL LIMIT 1];
        Set<Id> consentTemplateIds = new Set<Id>();

        for (TB_Admissions_Dictionary__c consentTemplate : [SELECT Id FROM TB_Admissions_Dictionary__c WHERE TB_Consents_Bundle__c = :consentBundle.Id LIMIT 2]) {
            consentTemplateIds.add(consentTemplate.Id);
        }

        MySwpsConsentCreator.createConsentsForContact(consentTemplateIds, REQUEST_USER_DETAILS, REQUEST_FORM_URL, contact.Id);

        List<TB_Consent__c> contactConsentsBeforeAct = [SELECT Id, TB_Consent_Definition__c, TB_Status__c FROM TB_Consent__c WHERE TB_Contact__c = :contact.Id];

        Test.startTest();
        MySwpsConsentCreator.createConsentsForContact(consentTemplateIds, REQUEST_USER_DETAILS, REQUEST_FORM_URL, contact.Id);
        Test.stopTest();

        List<TB_Consent__c> contactConsentsAfterAct = [SELECT Id, TB_Consent_Definition__c, TB_Status__c FROM TB_Consent__c WHERE TB_Contact__c = :contact.Id];

        Assert.areEqual(2, contactConsentsAfterAct.size());
        Assert.areEqual(contactConsentsBeforeAct[0].Id, contactConsentsAfterAct[0].Id);
        Assert.areEqual(contactConsentsBeforeAct[1].Id, contactConsentsAfterAct[1].Id);
    }

    @IsTest
    static void createConsentsForContactOnlyNotDuplicatedConsentCreated() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        TB_Admissions_Dictionary__c consentBundle = [SELECT Id FROM TB_Admissions_Dictionary__c WHERE TB_Consents_Bundle__c = NULL LIMIT 1];
        List<Id> consentTemplateIds = new List<Id>();

        for (TB_Admissions_Dictionary__c consentTemplate : [SELECT Id FROM TB_Admissions_Dictionary__c WHERE TB_Consents_Bundle__c = :consentBundle.Id LIMIT 2]) {
            consentTemplateIds.add(consentTemplate.Id);
        }

        MySwpsConsentCreator.createConsentsForContact(new Set<Id>{consentTemplateIds[0]}, REQUEST_USER_DETAILS, REQUEST_FORM_URL, contact.Id);

        List<TB_Consent__c> contactConsentsBeforeAct = [SELECT Id, TB_Consent_Definition__c, TB_Status__c FROM TB_Consent__c WHERE TB_Contact__c = :contact.Id];

        Test.startTest();
        MySwpsConsentCreator.createConsentsForContact(new Set<Id>(consentTemplateIds), REQUEST_USER_DETAILS, REQUEST_FORM_URL, contact.Id);
        Test.stopTest();

        List<TB_Consent__c> contactConsentsAfterAct = [SELECT Id, TB_Consent_Definition__c, TB_Status__c FROM TB_Consent__c WHERE TB_Contact__c = :contact.Id];

        Assert.areEqual(1, contactConsentsBeforeAct.size());
        Assert.areEqual(2, contactConsentsAfterAct.size());
    }
}