@IsTest
private class MySwpsInternshipOfferFormControllerTest {
    private static final String TEST_ADMIN_USER_USERNAME = 'superadmin@test.invalid';
    private static final String EXISTING_SUPERVISOR_CONTACT_WORK_EMAIL = 'luke@cage.invalid';
    private static final String POLISH_TAG_NAME_EN = 'Polish';
    private static final String POLISH_TAG_NAME_PL = 'Polski';
    private static final String ENGLISH_TAG_NAME_EN = 'English';
    private static final String ENGLISH_TAG_NAME_PL = 'Angielski';
    private static final Id INSTITUTIONAL_INTERNSHIP_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(Career_Services_Offer__c.getSObjectType(), Constants.CAREER_SERVICES_OFFER_RT_INSTITUTIONAL_INTERNSHIP);
    private static final Id CONTACT_PARTNER_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(Contact.getSObjectType(), Constants.CONTACT_PARTNER_RECORD_TYPE_DEV_NAME);
    private static final Id ACCOUNT_BUSINESS_ORGANIZATION_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(Account.getSObjectType(), Constants.ACCOUNT_RECORD_TYPE_BUSINESS_ORGANIZATION_API_NAME);
    private static final Id ADMISSIONS_DICTIONARY_CONSENT_DEFINITION_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(TB_Admissions_Dictionary__c.getSObjectType(), TB_Constants.TB_CONSENT_CONSENT_DEFINITION_RT_DEVNAME);

    @TestSetup
    private static void setup() {
        User admin = UserTestDataFactory.createAdminUserWithPermissionSetAssigned(TEST_ADMIN_USER_USERNAME);

        System.runAs(admin) {
            Account company = new AccountTestData()
                .withName('In Hot Water Company')
                .withCountryCode('PL')
                .withPostalCode('00-001')
                .withCity('Warsaw')
                .withStreet('Andersena 6')
                .withTaxId('3211233211')
                .withNationalCourtRegister('0000385162')
                .withRecordType(ACCOUNT_BUSINESS_ORGANIZATION_RECORD_TYPE_ID)
                .save()
                .get();

            Contact supervisor = new ContactTestData()
                .withFirstName('Łukasz')
                .withLastName('Klatka')
                .withRecordType(CONTACT_PARTNER_RECORD_TYPE_ID)
                .withWorkPhone('555444333')
                .withWorkEmail(EXISTING_SUPERVISOR_CONTACT_WORK_EMAIL)
                .withCompany(company.Id)
                .get();

            TB_Admissions_Dictionary__c bundle = AdmissionsDictionaryTestDataFactory.createCareerOfficeConsentBundle(1, true)[0];
            TB_Admissions_Dictionary__c consentDefinition = AdmissionsDictionaryTestDataFactory.createCareerOfficeConsentDefinition(
                1,
                bundle.Id,
                Constants.ADMISSIONS_DICTIONARY_CONSENT_TYPE_TERMS_AND_CONDITIONS,
                false
            ).get(0);

            String careerServicesOfferSObjectTypeName = Career_Services_Offer__c.getSObjectType().getDescribe().getName();
            Group careerServicesQueueGroup = [
                SELECT Id, (
                    SELECT SobjectType FROM QueueSobjects WHERE SobjectType = :careerServicesOfferSObjectTypeName
                )
                FROM Group
                WHERE DeveloperName = :Constants.GROUP_CAREER_OFFICE_QUEUE_DEVELOPER_NAME
                LIMIT 1];

            if (careerServicesQueueGroup.QueueSobjects.isEmpty()) {
                insert new QueueSobject(QueueId = careerServicesQueueGroup.Id, SobjectType = careerServicesOfferSObjectTypeName);
            }

            insert new List<SObject>{
                supervisor, consentDefinition,
                new TagTestData()
                    .withCategory(Constants.TAG_CATEGORY_LANGUAGE_API_NAME)
                    .withName(POLISH_TAG_NAME_PL)
                    .withEnglishName(POLISH_TAG_NAME_EN)
                    .get(),
                new TagTestData()
                    .withCategory(Constants.TAG_CATEGORY_LANGUAGE_API_NAME)
                    .withName(ENGLISH_TAG_NAME_PL)
                    .withEnglishName(ENGLISH_TAG_NAME_EN)
                    .get()
            };
        }
    }

    @IsTest
    private static void fetchInitialDataSuccess() {
        Test.startTest();
        MySwpsInternshipOfferFormController.FormInitialDataWrapper wrapper = MySwpsInternshipOfferFormController.fetchFormInitialData();
        Test.stopTest();

        Assert.isNotNull(wrapper);
        Assert.isNotNull(wrapper.internshipOfferRecordTypeId);
        Assert.isNotNull(wrapper.partnerContactRecordTypeId);
        Assert.isNotNull(wrapper.companyAccountRecordTypeId);
    }

    @IsTest
    public static void submitOfferSuccess() {
        User admin = [SELECT Id FROM User WHERE Username = :TEST_ADMIN_USER_USERNAME LIMIT 1];
        Group careerServicesQueueGroup = [SELECT Id FROM Group WHERE DeveloperName = :Constants.GROUP_CAREER_OFFICE_QUEUE_DEVELOPER_NAME LIMIT 1];
        Tag__c tag = [SELECT Id FROM Tag__c LIMIT 1];

        Account company = new AccountTestData()
            .withName('Test company')
            .withCountryCode('PL')
            .withPostalCode('00-001')
            .withCity('Warsaw')
            .withStreet('Andersena 3')
            .withTaxId('1231231231')
            .withNationalCourtRegister('0000385161')
            .withRecordType(ACCOUNT_BUSINESS_ORGANIZATION_RECORD_TYPE_ID)
            .get();

        Contact representative = new ContactTestData()
            .withFirstName('Mariusz')
            .withLastName('Pudzianowski')
            .withRecordType(CONTACT_PARTNER_RECORD_TYPE_ID)
            .withWorkPhone('123123123')
            .withWorkEmail('pudzian@test.invalid')
            .get();

        Contact supervisor = new ContactTestData()
            .withFirstName('Franciszek')
            .withLastName('Zamek')
            .withRecordType(CONTACT_PARTNER_RECORD_TYPE_ID)
            .withWorkPhone('333444555')
            .withWorkEmail('frank@castle.invalid')
            .get();

        Contact recruiter = new ContactTestData()
            .withFirstName('Rick')
            .withLastName('Router')
            .withRecordType(CONTACT_PARTNER_RECORD_TYPE_ID)
            .withWorkPhone('888777444')
            .withWorkEmail('rick@router.invalid')
            .get();

        Career_Services_Offer__c offer = new CsOfferTestData()
            .withInstitutionWebsite('https://www.test.pl')
            .withOfferTitle('Salesforce Developer')
            .withDescriptionOfCompletedTasks('24/7 CRUDS')
            .withInternshipClockHours(100)
            .withExternalSupervisorEducation(Constants.CAREER_SERVICES_OFFER_EXTERNAL_SUPERVISOR_EDUCATION_OTHER)
            .withRecordType(INSTITUTIONAL_INTERNSHIP_RECORD_TYPE_ID)
            .withCompanyDescription('Test description')
            .hasInternshipSupervisorAssistance()
            .get();

        MySwpsInternshipOfferFormController.InternshipOfferConsentsWrapper consentWrapper = getConsentWrapper(true);
        MySwpsInternshipOfferFormController.InternshipOfferTagWrapper tagWrapper = new MySwpsInternshipOfferFormController.InternshipOfferTagWrapper();
        tagWrapper.id = tag.Id;
        tagWrapper.level = Constants.TAG_LEVEL_ADVANCED_API_NAME;

        List<MySwpsInternshipOfferFormController.InternshipOfferTagWrapper> tags = new List<MySwpsInternshipOfferFormController.InternshipOfferTagWrapper>{
            tagWrapper
        };

        Test.startTest();
        System.runAs(admin) {
            MySwpsInternshipOfferFormController.submitOffer(company, representative, supervisor, recruiter, offer, consentWrapper, tags);
        }
        Test.stopTest();

        Assert.isNotNull(recruiter.Id);
        List<TB_Consent__c> createdConsents = [SELECT Id FROM TB_Consent__c WHERE TB_Contact__c = :recruiter.Id];
        Integer offerTagsCount = [SELECT COUNT() FROM Career_Services_Offer_Tag__c];

        Assert.isNotNull(offer.Id);
        Assert.isNotNull(company.Id);
        Assert.isNotNull(representative.Id);
        Assert.isNotNull(supervisor.Id);
        Assert.areEqual(1, createdConsents.size());
        Assert.areEqual(representative.Id, offer.Organisation_Contact__c);
        Assert.areEqual(recruiter.Id, offer.Recruiter__c);
        Assert.areEqual(supervisor.Id, offer.External_Supervisor__c);
        Assert.areEqual(careerServicesQueueGroup.Id, offer.OwnerId);
        Assert.areEqual(tags.size(), offerTagsCount);
    }

    @IsTest
    public static void submitOfferPartnerExistsForOtherCompanySuccess() {
        User admin = [SELECT Id FROM User WHERE Username = :TEST_ADMIN_USER_USERNAME LIMIT 1];
        Integer preSubmitAccountContactRelationCount = [SELECT Id FROM AccountContactRelation WHERE Contact.hed__WorkEmail__c = :EXISTING_SUPERVISOR_CONTACT_WORK_EMAIL].size();

        Account company = new AccountTestData()
            .withName('Test company')
            .withCountryCode('PL')
            .withPostalCode('00-001')
            .withCity('Warsaw')
            .withStreet('Andersena 3')
            .withTaxId('2223331116')
            .withNationalCourtRegister('0000385161')
            .withRecordType(ACCOUNT_BUSINESS_ORGANIZATION_RECORD_TYPE_ID)
            .get();

        Contact representative = new ContactTestData()
            .withFirstName('Mariusz')
            .withLastName('Pudzianowski')
            .withRecordType(CONTACT_PARTNER_RECORD_TYPE_ID)
            .withWorkPhone('123123123')
            .withWorkEmail('pudzian@test.invalid')
            .get();

        Contact supervisor = new ContactTestData()
            .withFirstName('Łukasz')
            .withLastName('Klatka')
            .withRecordType(CONTACT_PARTNER_RECORD_TYPE_ID)
            .withWorkPhone('555444333')
            .withWorkEmail(EXISTING_SUPERVISOR_CONTACT_WORK_EMAIL)
            .get();

        Contact recruiter = new ContactTestData()
            .withFirstName('Rick')
            .withLastName('Router')
            .withRecordType(CONTACT_PARTNER_RECORD_TYPE_ID)
            .withWorkPhone('888777444')
            .withWorkEmail('rick@router.invalid')
            .get();

        Career_Services_Offer__c offer = new CsOfferTestData()
            .withInstitutionWebsite('https://www.test.pl')
            .withOfferTitle('Salesforce Developer')
            .withDescriptionOfCompletedTasks('24/7 CRUDS')
            .withInternshipClockHours(100)
            .withExternalSupervisorEducation(Constants.CAREER_SERVICES_OFFER_EXTERNAL_SUPERVISOR_EDUCATION_OTHER)
            .withRecordType(INSTITUTIONAL_INTERNSHIP_RECORD_TYPE_ID)
            .withCompanyDescription('Test description')
            .hasInternshipSupervisorAssistance()
            .get();

        MySwpsInternshipOfferFormController.InternshipOfferConsentsWrapper consentWrapper = getConsentWrapper(false);
        List<MySwpsInternshipOfferFormController.InternshipOfferTagWrapper> tagWrapper = new List<MySwpsInternshipOfferFormController.InternshipOfferTagWrapper>();

        Test.startTest();
        System.runAs(admin) {
            MySwpsInternshipOfferFormController.submitOffer(company, representative, supervisor, recruiter, offer, consentWrapper, tagWrapper);
        }
        Test.stopTest();

        Integer postSubmitAccountContactRelationCount = [SELECT Id FROM AccountContactRelation WHERE Contact.hed__WorkEmail__c = :EXISTING_SUPERVISOR_CONTACT_WORK_EMAIL].size();

        Assert.isTrue(postSubmitAccountContactRelationCount > preSubmitAccountContactRelationCount);
    }

    @IsTest
    public static void submitOfferCompanyAlreadyExistsSuccess() {
        User admin = [SELECT Id FROM User WHERE Username = :TEST_ADMIN_USER_USERNAME LIMIT 1];
        Integer preSubmitAccountCount = [SELECT COUNT() FROM Account];

        Account company = new AccountTestData()
            .withName('In Hot Water Company')
            .withCountryCode('PL')
            .withPostalCode('00-001')
            .withCity('Warsaw')
            .withStreet('Andersena 6')
            .withTaxId('3211233211')
            .withNationalCourtRegister('0000385162')
            .withRecordType(ACCOUNT_BUSINESS_ORGANIZATION_RECORD_TYPE_ID)
            .get();

        Contact representative = new ContactTestData()
            .withFirstName('Mariusz')
            .withLastName('Pudzianowski')
            .withRecordType(CONTACT_PARTNER_RECORD_TYPE_ID)
            .withWorkPhone('123123123')
            .withWorkEmail('pudzian@test.invalid')
            .get();

        Contact supervisor = new ContactTestData()
            .withFirstName('Franciszek')
            .withLastName('Zamek')
            .withRecordType(CONTACT_PARTNER_RECORD_TYPE_ID)
            .withWorkPhone('333444555')
            .withWorkEmail(EXISTING_SUPERVISOR_CONTACT_WORK_EMAIL)
            .get();

        Contact recruiter = new ContactTestData()
            .withFirstName('Rick')
            .withLastName('Router')
            .withRecordType(CONTACT_PARTNER_RECORD_TYPE_ID)
            .withWorkPhone('888777444')
            .withWorkEmail('rick@router.invalid')
            .get();

        Career_Services_Offer__c offer = new CsOfferTestData()
            .withInstitutionWebsite('https://www.test.pl')
            .withOfferTitle('Salesforce Developer')
            .withDescriptionOfCompletedTasks('24/7 CRUDS')
            .withInternshipClockHours(100)
            .withExternalSupervisorEducation(Constants.CAREER_SERVICES_OFFER_EXTERNAL_SUPERVISOR_EDUCATION_OTHER)
            .withRecordType(INSTITUTIONAL_INTERNSHIP_RECORD_TYPE_ID)
            .withCompanyDescription('Test description')
            .hasInternshipSupervisorAssistance()
            .get();

        MySwpsInternshipOfferFormController.InternshipOfferConsentsWrapper consentWrapper = getConsentWrapper(false);
        List<MySwpsInternshipOfferFormController.InternshipOfferTagWrapper> tagWrapper = new List<MySwpsInternshipOfferFormController.InternshipOfferTagWrapper>();

        Test.startTest();
        System.runAs(admin) {
            MySwpsInternshipOfferFormController.submitOffer(company, representative, supervisor, recruiter, offer, consentWrapper, tagWrapper);
        }
        Test.stopTest();

        Integer postSubmitAccountCount = [SELECT COUNT() FROM Account];

        Assert.isNotNull(offer.Id);
        Assert.areEqual(preSubmitAccountCount, postSubmitAccountCount);
    }

    private static MySwpsInternshipOfferFormController.InternshipOfferConsentsWrapper getConsentWrapper(Boolean withCheckedConsentIds) {
        MySwpsInternshipOfferFormController.InternshipOfferConsentsWrapper consentWrapper = new MySwpsInternshipOfferFormController.InternshipOfferConsentsWrapper();
        consentWrapper.formUrl = 'www.test-url.pl';
        consentWrapper.userDetails = 'testUserDetails';
        consentWrapper.checkedConsentIds = new List<Id>();

        if (withCheckedConsentIds) {
            for (TB_Admissions_Dictionary__c dictionary : [SELECT Id FROM TB_Admissions_Dictionary__c WHERE RecordTypeId = :ADMISSIONS_DICTIONARY_CONSENT_DEFINITION_RECORD_TYPE_ID]) {
                consentWrapper.checkedConsentIds.add(dictionary.Id);
            }
        }

        return consentWrapper;
    }
}