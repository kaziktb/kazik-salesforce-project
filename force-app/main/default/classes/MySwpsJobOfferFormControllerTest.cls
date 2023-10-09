@IsTest
private class MySwpsJobOfferFormControllerTest {
    private static final String TEST_ADMIN_USER_USERNAME = 'add.mine@example.test.mail';
    private static final String TEST_EXISTING_COMPANY_TAX_ID = '2145684321';
    private static final String TEST_EXISTING_CONTACT_EMAIL = 'Chuck@testa.example.mail';
    private static final String POLISH_TAG_NAME_EN = 'Polish';
    private static final String POLISH_TAG_NAME_PL = 'Polski';
    private static final String ENGLISH_TAG_NAME_EN = 'English';
    private static final String ENGLISH_TAG_NAME_PL = 'Angielski';
    private static final Id ACCOUNT_BUSINESS_ORGANIZATION_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(Account.getSObjectType(), Constants.ACCOUNT_RECORD_TYPE_BUSINESS_ORGANIZATION_API_NAME);
    private static final Id ADMISSIONS_DICTIONARY_CONSENT_DEFINITION_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(TB_Admissions_Dictionary__c.getSObjectType(), TB_Constants.TB_CONSENT_CONSENT_DEFINITION_RT_DEVNAME);
    private static final Id CONTACT_PARTNER_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(Contact.getSObjectType(), Constants.CONTACT_PARTNER_RECORD_TYPE_DEV_NAME);
    private static final Id JOB_OFFER_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(Career_Services_Offer__c.getSObjectType(), Constants.CAREER_SERVICES_OFFER_RT_JOB_OFFER);
    @TestSetup
    private static void testSetup() {
        User admin = UserTestDataFactory.createAdminUser(TEST_ADMIN_USER_USERNAME, true);

        System.runAs(admin) {
            Account company = new AccountTestData()
                .withName('Sultan Consulting')
                .withCountryCode('PL')
                .withPostalCode('00-496')
                .withCity('Warszawa')
                .withStreet('Nowy Świat 4A')
                .withTaxId(TEST_EXISTING_COMPANY_TAX_ID)
                .withNationalCourtRegister('1000500100900')
                .withRecordType(ACCOUNT_BUSINESS_ORGANIZATION_RECORD_TYPE_ID)
                .save()
                .get();

            new ContactTestData()
                .withFirstName('Andrzej')
                .withLastName('Golgota')
                .withRecordType(CONTACT_PARTNER_RECORD_TYPE_ID)
                .withWorkPhone('555444333')
                .withWorkEmail(TEST_EXISTING_CONTACT_EMAIL)
                .withCompany(company.Id)
                .save()
                .get();

            TB_Admissions_Dictionary__c bundle = AdmissionsDictionaryTestDataFactory.createCareerOfficeConsentBundle(1, true)[0];
            AdmissionsDictionaryTestDataFactory.createCareerOfficeConsentDefinition(
                1,
                bundle.Id,
                Constants.ADMISSIONS_DICTIONARY_CONSENT_TYPE_TERMS_AND_CONDITIONS,
                true
            );

            List<Tag__c> tags = new List<Tag__c>{
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
            insert tags;
        }
    }

    @IsTest
    private static void fetchRecordTypesIdWrapperTest() {
        User adminUser = [SELECT Id FROM User WHERE Username = :TEST_ADMIN_USER_USERNAME];

        MySwpsJobOfferFormController.JobOfferRecordTypeIdsWrapper recordTypeIdsWrapper = new MySwpsJobOfferFormController.JobOfferRecordTypeIdsWrapper();

        Test.startTest();
        System.runAs(adminUser) {
            recordTypeIdsWrapper = MySwpsJobOfferFormController.fetchRecordTypesIdWrapper();
        }
        Test.stopTest();

        Assert.isNotNull(recordTypeIdsWrapper.companyAccountRecordTypeId);
        Assert.isNotNull(recordTypeIdsWrapper.jobOfferCareerServicesOfferRecordTypeId);
        Assert.isNotNull(recordTypeIdsWrapper.recruiterContactRecordTypeId);
    }

    @IsTest
    private static void formSubmissionHandlerSuccessJobPlacementWithoutDuplicatesWithFilesTest() {
        User adminUser = [SELECT Id FROM User WHERE Username = :TEST_ADMIN_USER_USERNAME];
        Tag__c tag = [SELECT Id FROM Tag__c WHERE Name = :POLISH_TAG_NAME_PL];

        Account companyAccount = new AccountTestData()
            .withName('WRP')
            .withCountryCode('PL')
            .withPostalCode('42-500')
            .withCity('Będzin')
            .withStreet('Henryka Sienkiewicza 31D')
            .withNationalCourtRegister('0428529103')
            .withTaxId('7584930210')
            .withRecordType(ACCOUNT_BUSINESS_ORGANIZATION_RECORD_TYPE_ID)
            .get();
        Contact recruiterContact = new ContactTestData()
            .withFirstName('Kamil')
            .withLastName('Ślimak')
            .withRecordType(CONTACT_PARTNER_RECORD_TYPE_ID)
            .withWorkPhone('555444333')
            .withWorkEmail('kamil.s@s.limak.test')
            .get();
        Career_Services_Offer__c jobOffer = new CsOfferTestData()
            .withInstitutionWebsite('https://salesforce.com')
            .withOfferTitle('Success Engineer')
            .withDescriptionOfCompletedTasks('200 Success')
            .withExternalSupervisorEducation(Constants.CAREER_SERVICES_OFFER_EXTERNAL_SUPERVISOR_EDUCATION_OTHER)
            .withRecordType(JOB_OFFER_RECORD_TYPE_ID)
            .withCompanyDescription('Description')
            .withOfferExpirationDate(Date.today().addDays(30))
            .get();

        MySwpsJobOfferFormController.JobOfferConsentsWrapper consentWrapper = fetchConsentWrappers(true);

        MySwpsJobOfferFormController.JobOfferTagWrapper tagWrapper = new MySwpsJobOfferFormController.JobOfferTagWrapper();
        tagWrapper.id = tag.Id;
        tagWrapper.level = Constants.TAG_LEVEL_ADVANCED_API_NAME;
        List<MySwpsJobOfferFormController.JobOfferTagWrapper> tagWrappers = new List<MySwpsJobOfferFormController.JobOfferTagWrapper>{
            tagWrapper
        };

        List<String> cooperationWays = new List<String>{
            Constants.OPPORTUNITY_ADDITIONAL_WAYS_OF_COOPERATION_JOB_FAIRS_API_NAME
        };

        MySwpsFileInputController.FileWrapper fileWrapper = new MySwpsFileInputController.FileWrapper();
        fileWrapper.base64 = EncodingUtil.base64Encode(Blob.valueOf('Mock'));
        fileWrapper.fileName = 'Test.pdf';

        Id createdJobOfferId;

        Test.startTest();
        System.runAs(adminUser) {
            createdJobOfferId = MySwpsJobOfferFormController.formSubmissionHandler(
                companyAccount,
                recruiterContact,
                consentWrapper,
                jobOffer,
                true,
                cooperationWays,
                tagWrappers
            );

            MySwpsFileInputController.fileHandler(fileWrapper, createdJobOfferId);
        }
        Test.stopTest();

        Account createdCompany = [
            SELECT Id, (
                SELECT Id FROM Opportunities
            )
            FROM Account
            WHERE DT_Company_Tax_Id__c = :companyAccount.DT_Company_Tax_Id__c
        ];

        Career_Services_Offer__c createdOffer = [
            SELECT Id, (
                SELECT Id FROM Tags__r
            ), (
                SELECT Id FROM ContentDocumentLinks
            )
            FROM Career_Services_Offer__c
            WHERE Id = :createdJobOfferId
        ];

        Assert.isNotNull(createdJobOfferId);
        Assert.areEqual(2, createdCompany.Opportunities.size());
        Assert.areEqual(1, createdOffer.Tags__r.size());
        Assert.areEqual(1, createdOffer.ContentDocumentLinks.size());
    }

    @IsTest
    private static void formSubmissionHandlerSuccessJobPlacementWithDuplicatedAccountAndOtherContactTest() {
        User adminUser = [SELECT Id FROM User WHERE Username = :TEST_ADMIN_USER_USERNAME];
        Tag__c tag = [SELECT Id FROM Tag__c WHERE Name = :POLISH_TAG_NAME_PL];

        Account companyAccount = new AccountTestData()
            .withName('WRP')
            .withCountryCode('PL')
            .withPostalCode('42-500')
            .withCity('Będzin')
            .withStreet('Henryka Sienkiewicza 31D')
            .withNationalCourtRegister('0428529103')
            .withTaxId(TEST_EXISTING_COMPANY_TAX_ID)
            .withRecordType(ACCOUNT_BUSINESS_ORGANIZATION_RECORD_TYPE_ID)
            .get();
        Contact recruiterContact = new ContactTestData()
            .withFirstName('Kamil')
            .withLastName('Ślimak')
            .withRecordType(CONTACT_PARTNER_RECORD_TYPE_ID)
            .withWorkPhone('555444333')
            .withWorkEmail('kamil.s@s.limak.test')
            .get();
        Career_Services_Offer__c jobOffer = new CsOfferTestData()
            .withInstitutionWebsite('https://salesforce.com')
            .withOfferTitle('Success Engineer')
            .withDescriptionOfCompletedTasks('200 Success')
            .withExternalSupervisorEducation(Constants.CAREER_SERVICES_OFFER_EXTERNAL_SUPERVISOR_EDUCATION_OTHER)
            .withRecordType(JOB_OFFER_RECORD_TYPE_ID)
            .withCompanyDescription('Description')
            .withOfferExpirationDate(Date.today().addDays(30))
            .get();

        MySwpsJobOfferFormController.JobOfferConsentsWrapper consentWrapper = fetchConsentWrappers(true);

        MySwpsJobOfferFormController.JobOfferTagWrapper tagWrapper = new MySwpsJobOfferFormController.JobOfferTagWrapper();
        tagWrapper.id = tag.Id;
        tagWrapper.level = Constants.TAG_LEVEL_ADVANCED_API_NAME;
        List<MySwpsJobOfferFormController.JobOfferTagWrapper> tagWrappers = new List<MySwpsJobOfferFormController.JobOfferTagWrapper>{
            tagWrapper
        };

        List<String> cooperationWays = new List<String>{
            Constants.OPPORTUNITY_ADDITIONAL_WAYS_OF_COOPERATION_JOB_FAIRS_API_NAME
        };

        Id createdJobOfferId;

        Test.startTest();
        System.runAs(adminUser) {
            createdJobOfferId = MySwpsJobOfferFormController.formSubmissionHandler(
                companyAccount,
                recruiterContact,
                consentWrapper,
                jobOffer,
                true,
                cooperationWays,
                tagWrappers
            );
        }
        Test.stopTest();

        Account createdCompany = [
            SELECT Id, (
                SELECT Id FROM Opportunities
            ), (
                SELECT Id FROM AccountContactRelations
            )
            FROM Account
            WHERE DT_Company_Tax_Id__c = :companyAccount.DT_Company_Tax_Id__c
        ];

        Assert.isNotNull(createdJobOfferId);
        Assert.areEqual(2, createdCompany.Opportunities.size());
        Assert.areEqual(2, createdCompany.AccountContactRelations.size());
    }

    @IsTest
    private static void formSubmissionHandlerSuccessJobPlacementWithDuplicatedContactAndOtherAccountTest() {
        User adminUser = [SELECT Id FROM User WHERE Username = :TEST_ADMIN_USER_USERNAME];
        Tag__c tag = [SELECT Id FROM Tag__c WHERE Name = :POLISH_TAG_NAME_PL];

        Account companyAccount = new AccountTestData()
            .withName('WRP')
            .withCountryCode('PL')
            .withPostalCode('42-500')
            .withCity('Będzin')
            .withStreet('Henryka Sienkiewicza 31D')
            .withNationalCourtRegister('0428529103')
            .withTaxId('8579386478')
            .withRecordType(ACCOUNT_BUSINESS_ORGANIZATION_RECORD_TYPE_ID)
            .get();
        Contact recruiterContact = new ContactTestData()
            .withFirstName('Kamil')
            .withLastName('Ślimak')
            .withRecordType(CONTACT_PARTNER_RECORD_TYPE_ID)
            .withWorkPhone('555444333')
            .withWorkEmail(TEST_EXISTING_CONTACT_EMAIL)
            .get();
        Career_Services_Offer__c jobOffer = new CsOfferTestData()
            .withInstitutionWebsite('https://salesforce.com')
            .withOfferTitle('Success Engineer')
            .withDescriptionOfCompletedTasks('200 Success')
            .withExternalSupervisorEducation(Constants.CAREER_SERVICES_OFFER_EXTERNAL_SUPERVISOR_EDUCATION_OTHER)
            .withRecordType(JOB_OFFER_RECORD_TYPE_ID)
            .withCompanyDescription('Description')
            .withOfferExpirationDate(Date.today().addDays(30))
            .get();

        MySwpsJobOfferFormController.JobOfferConsentsWrapper consentWrapper = fetchConsentWrappers(true);

        MySwpsJobOfferFormController.JobOfferTagWrapper tagWrapper = new MySwpsJobOfferFormController.JobOfferTagWrapper();
        tagWrapper.id = tag.Id;
        tagWrapper.level = Constants.TAG_LEVEL_ADVANCED_API_NAME;
        List<MySwpsJobOfferFormController.JobOfferTagWrapper> tagWrappers = new List<MySwpsJobOfferFormController.JobOfferTagWrapper>{
            tagWrapper
        };

        List<String> cooperationWays = new List<String>{
            Constants.OPPORTUNITY_ADDITIONAL_WAYS_OF_COOPERATION_JOB_FAIRS_API_NAME
        };

        Id createdJobOfferId;

        Test.startTest();
        System.runAs(adminUser) {
            createdJobOfferId = MySwpsJobOfferFormController.formSubmissionHandler(
                companyAccount,
                recruiterContact,
                consentWrapper,
                jobOffer,
                true,
                cooperationWays,
                tagWrappers
            );
        }
        Test.stopTest();

        Account createdCompany = [
            SELECT Id, (
                SELECT Id FROM Opportunities
            )
            FROM Account
            WHERE DT_Company_Tax_Id__c = :companyAccount.DT_Company_Tax_Id__c
        ];

        Contact createdContact = [
            SELECT Id, (
                SELECT Id FROM AccountContactRelations
            )
            FROM Contact
            WHERE hed__Work_Address__c = :recruiterContact.hed__Work_Address__c
        ];

        Assert.isNotNull(createdJobOfferId);
        Assert.areEqual(2, createdCompany.Opportunities.size());
        Assert.areEqual(2, createdContact.AccountContactRelations.size());
    }

    @IsTest
    private static void formSubmissionHandlerSuccessJobPlacementWithDuplicatedAccountAndCooperationWayTest() {
        User adminUser = [SELECT Id FROM User WHERE Username = :TEST_ADMIN_USER_USERNAME];
        Tag__c tag = [SELECT Id FROM Tag__c WHERE Name = :POLISH_TAG_NAME_PL];
        Account existingAccount = [SELECT Id FROM Account WHERE DT_Company_Tax_Id__c = :TEST_EXISTING_COMPANY_TAX_ID];

        Id opportunityRecordTypeCareerOfficeId = Utils.getRecordTypeIdByDevName(
            Opportunity.getSObjectType(),
            Constants.OPPORTUNITY_RECORD_TYPE_CAREER_OFFICE_DEVELOPER_NAME
        );

        new OpportunityTestData()
            .withAccountId(existingAccount.Id)
            .withRecordTypeId(opportunityRecordTypeCareerOfficeId)
            .withAdditionalWaysOfCooperation(Constants.OPPORTUNITY_ADDITIONAL_WAYS_OF_COOPERATION_JOB_PLACEMENT_API_NAME)
            .save()
            .get();

        Account companyAccount = new AccountTestData()
            .withName('WRP')
            .withCountryCode('PL')
            .withPostalCode('42-500')
            .withCity('Będzin')
            .withStreet('Henryka Sienkiewicza 31D')
            .withNationalCourtRegister('0428529103')
            .withTaxId(TEST_EXISTING_COMPANY_TAX_ID)
            .withRecordType(ACCOUNT_BUSINESS_ORGANIZATION_RECORD_TYPE_ID)
            .get();
        Contact recruiterContact = new ContactTestData()
            .withFirstName('Kamil')
            .withLastName('Ślimak')
            .withRecordType(CONTACT_PARTNER_RECORD_TYPE_ID)
            .withWorkPhone('555444333')
            .withWorkEmail('kamil.s@s.limak.test')
            .get();
        Career_Services_Offer__c jobOffer = new CsOfferTestData()
            .withInstitutionWebsite('https://salesforce.com')
            .withOfferTitle('Success Engineer')
            .withDescriptionOfCompletedTasks('200 Success')
            .withExternalSupervisorEducation(Constants.CAREER_SERVICES_OFFER_EXTERNAL_SUPERVISOR_EDUCATION_OTHER)
            .withRecordType(JOB_OFFER_RECORD_TYPE_ID)
            .withCompanyDescription('Description')
            .withOfferExpirationDate(Date.today().addDays(30))
            .get();

        MySwpsJobOfferFormController.JobOfferConsentsWrapper consentWrapper = fetchConsentWrappers(true);

        MySwpsJobOfferFormController.JobOfferTagWrapper tagWrapper = new MySwpsJobOfferFormController.JobOfferTagWrapper();
        tagWrapper.id = tag.Id;
        tagWrapper.level = Constants.TAG_LEVEL_ADVANCED_API_NAME;
        List<MySwpsJobOfferFormController.JobOfferTagWrapper> tagWrappers = new List<MySwpsJobOfferFormController.JobOfferTagWrapper>{
            tagWrapper
        };

        List<String> cooperationWays = new List<String>{
            Constants.OPPORTUNITY_ADDITIONAL_WAYS_OF_COOPERATION_JOB_FAIRS_API_NAME
        };

        Id createdJobOfferId;

        Test.startTest();
        System.runAs(adminUser) {
            createdJobOfferId = MySwpsJobOfferFormController.formSubmissionHandler(
                companyAccount,
                recruiterContact,
                consentWrapper,
                jobOffer,
                true,
                cooperationWays,
                tagWrappers
            );
        }
        Test.stopTest();

        Account createdCompany = [
            SELECT Id, (
                SELECT Id FROM Opportunities
            )
            FROM Account
            WHERE DT_Company_Tax_Id__c = :companyAccount.DT_Company_Tax_Id__c
        ];

        Assert.isNotNull(createdJobOfferId);
        Assert.areEqual(2, createdCompany.Opportunities.size());
    }

    private static MySwpsJobOfferFormController.JobOfferConsentsWrapper fetchConsentWrappers(Boolean withCheckedConsentIds) {
        MySwpsJobOfferFormController.JobOfferConsentsWrapper consentWrapper = new MySwpsJobOfferFormController.JobOfferConsentsWrapper();
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