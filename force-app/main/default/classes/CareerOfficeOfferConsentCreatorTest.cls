@IsTest
private class CareerOfficeOfferConsentCreatorTest {
    private static final String REQUEST_FORM_URL = 'www.google.com';
    private static final String REQUEST_USER_DETAILS = '{"browserVersion":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36"}';

    @TestSetup
    static void setup() {
        DT_DataFactory.createContacts(1, true, null);
        TB_Admissions_Dictionary__c bundle = AdmissionsDictionaryTestDataFactory.createCareerOfficeConsentBundle(1, true)[0];
        AdmissionsDictionaryTestDataFactory.createCareerOfficeConsentDefinition(1, bundle.Id, DT_Utils.ADMISSIONS_DICTIONARY_CONSENT_TYPE_TERMS_AND_CONDITIONS, true);
        AdmissionsDictionaryTestDataFactory.createCareerOfficeConsentDefinition(1, bundle.Id, DT_Utils.ADMISSIONS_DICTIONARY_CONSENT_TYPE_MARKETING, true);
    }

    @IsTest
    static void createConsentsForContactSuccess() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        TB_Admissions_Dictionary__c consentBundle = [SELECT Id FROM TB_Admissions_Dictionary__c WHERE TB_Consents_Bundle__c = NULL LIMIT 1];
        List<Id> consentTemplateIds = new List<Id>();

        for (TB_Admissions_Dictionary__c consentTemplate : [SELECT Id FROM TB_Admissions_Dictionary__c WHERE TB_Consents_Bundle__c = :consentBundle.Id LIMIT 2]) {
            consentTemplateIds.add(consentTemplate.Id);
        }
        
        CareerOfficeOfferConsentCreator.CareerOfficeOfferConsentCreatorRequest request = createRequestWithConsentDefinitionIds(consentTemplateIds, contact);

        Test.startTest();
        CareerOfficeOfferConsentCreator.createConsentsForContact(new List<CareerOfficeOfferConsentCreator.CareerOfficeOfferConsentCreatorRequest>{
            request
        });
        Test.stopTest();

        List<TB_Consent__c> contactConsents = [SELECT Id, TB_Status__c, TB_User_Details__c, TB_Source__c FROM TB_Consent__c WHERE TB_Contact__c = :contact.Id];

        Assert.areEqual(2, contactConsents.size());

        for (TB_Consent__c consent : contactConsents) {
            Assert.areEqual('Opt_In', consent.TB_Status__c);
            Assert.areEqual(REQUEST_USER_DETAILS, consent.TB_User_Details__c);
            Assert.areEqual(REQUEST_FORM_URL, consent.TB_Source__c);
        }

    }

    @IsTest
    static void createConsentsForContactDuplicatedConsentNotCreated() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        TB_Admissions_Dictionary__c consentBundle = [SELECT Id FROM TB_Admissions_Dictionary__c WHERE TB_Consents_Bundle__c = NULL LIMIT 1];
        List<Id> consentTemplateIds = new List<Id>();

        for (TB_Admissions_Dictionary__c consentTemplate : [SELECT Id FROM TB_Admissions_Dictionary__c WHERE TB_Consents_Bundle__c = :consentBundle.Id LIMIT 2]) {
            consentTemplateIds.add(consentTemplate.Id);
        }

        CareerOfficeOfferConsentCreator.CareerOfficeOfferConsentCreatorRequest request = createRequestWithConsentDefinitionIds(consentTemplateIds, contact);
        CareerOfficeOfferConsentCreator.createConsentsForContact(new List<CareerOfficeOfferConsentCreator.CareerOfficeOfferConsentCreatorRequest>{
            request
        });
        List<TB_Consent__c> contactConsentsBeforeAct = [SELECT Id, TB_Consent_Definition__c, TB_Status__c FROM TB_Consent__c WHERE TB_Contact__c = :contact.Id];

        Test.startTest();
        CareerOfficeOfferConsentCreator.createConsentsForContact(new List<CareerOfficeOfferConsentCreator.CareerOfficeOfferConsentCreatorRequest>{
            request
        });
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

        CareerOfficeOfferConsentCreator.CareerOfficeOfferConsentCreatorRequest requestWithOneConsent = createRequestWithConsentDefinitionIds(new List<Id>{consentTemplateIds[0]}, contact);
        CareerOfficeOfferConsentCreator.createConsentsForContact(new List<CareerOfficeOfferConsentCreator.CareerOfficeOfferConsentCreatorRequest>{
            requestWithOneConsent
        });

        List<TB_Consent__c> contactConsentsBeforeAct = [SELECT Id, TB_Consent_Definition__c, TB_Status__c FROM TB_Consent__c WHERE TB_Contact__c = :contact.Id];
        CareerOfficeOfferConsentCreator.CareerOfficeOfferConsentCreatorRequest requestWithTwoConsents = createRequestWithConsentDefinitionIds(consentTemplateIds, contact);

        Test.startTest();
        CareerOfficeOfferConsentCreator.createConsentsForContact(new List<CareerOfficeOfferConsentCreator.CareerOfficeOfferConsentCreatorRequest>{
            requestWithTwoConsents
        });
        Test.stopTest();

        List<TB_Consent__c> contactConsentsAfterAct = [SELECT Id, TB_Consent_Definition__c, TB_Status__c FROM TB_Consent__c WHERE TB_Contact__c = :contact.Id];

        Assert.areEqual(1, contactConsentsBeforeAct.size());
        Assert.areEqual(2, contactConsentsAfterAct.size());
    }

    @IsTest
    static void createConsentsForContactNoDefinitionsProvided() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        List<String> consentDefinitionIds = new List<String>{
        };
        
        CareerOfficeOfferConsentCreator.CareerOfficeOfferConsentCreatorRequest request = createRequestWithConsentDefinitionIds(consentDefinitionIds, contact);
        Test.startTest();
        CareerOfficeOfferConsentCreator.createConsentsForContact(new List<CareerOfficeOfferConsentCreator.CareerOfficeOfferConsentCreatorRequest>{
            request
        });
        Test.stopTest();

        List<TB_Consent__c> contactConsents = [SELECT Id, TB_Status__c FROM TB_Consent__c WHERE TB_Contact__c = :contact.Id];

        Assert.areEqual(0, contactConsents.size());
    }

    @IsTest
    static void createConsentsForContactNoRequestsProvided() {
        Integer consentsCountBeforeAct = [SELECT COUNT() FROM TB_Consent__c];
        List<CareerOfficeOfferConsentCreator.CareerOfficeOfferConsentCreatorRequest> requests = new List<CareerOfficeOfferConsentCreator.CareerOfficeOfferConsentCreatorRequest>{};

        Test.startTest();
        CareerOfficeOfferConsentCreator.createConsentsForContact(requests);
        Test.stopTest();

        Integer consentsCountAfterAct = [SELECT COUNT() FROM TB_Consent__c];

        Assert.areEqual(consentsCountBeforeAct, consentsCountAfterAct);
    }

    private static CareerOfficeOfferConsentCreator.CareerOfficeOfferConsentCreatorRequest createRequestWithConsentDefinitionIds(List<Id> consentDefinitionIds, Contact contact) {
        CareerOfficeOfferConsentCreator.CareerOfficeOfferConsentCreatorRequest request = new CareerOfficeOfferConsentCreator.CareerOfficeOfferConsentCreatorRequest();
        request.formUrl = REQUEST_FORM_URL;
        request.contactId = contact.Id;
        request.consentDefinitionIds = consentDefinitionIds;
        request.userDetails = REQUEST_USER_DETAILS;
        return request;
    }
}