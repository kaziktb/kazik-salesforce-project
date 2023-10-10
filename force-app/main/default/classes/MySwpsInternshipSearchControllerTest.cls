@IsTest
private class MySwpsInternshipSearchControllerTest {
    private final static String TEST_STUDENT_NICKNAME = 'Super Student';
    private final static String TEST_ADMIN_USER_NAME = 'superadmin@test.invalid';
    
    private final static MySwpsInternshipSearchController.FilterWrapper EMPTY_FILTERS_WRAPPER = new MySwpsInternshipSearchController.FilterWrapper();
    private final static Integer OFFSET_ZERO = 0;
    private final static Integer RECORDS_TO_RETURN = 3;
    private final static Id CAREER_SERVICES_OFFER_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP = Utils.getRecordTypeIdByDevName(Career_Services_Offer__c.getSObjectType(), Constants.CAREER_SERVICES_OFFER_RT_INSTITUTIONAL_INTERNSHIP);
    @TestSetup
    private static void setup() {
        User adminUser = UserTestDataFactory.createAdminUser(TEST_ADMIN_USER_NAME, true);

        System.runAs(adminUser) {
            Account contractAccount = AccountTestDataFactory.createBaseBusinessOrganizationAccount(Constants.ACCOUNT_STATUS_ACTIVE_API_NAME, false);
            contractAccount.Industry = Constants.ACCOUNT_INDUSTRY_OTHER;

            insert contractAccount;

            Tag__c polishLanguageTag = new TagTestData().withCategory(Constants.TAG_CATEGORY_LANGUAGE_API_NAME).withEnglishName(Constants.TAG_ENGLISH_NAME_VALUE_POLISH).get();
            Tag__c englishLanguageTag = new TagTestData().withCategory(Constants.TAG_CATEGORY_LANGUAGE_API_NAME).withEnglishName(Constants.TAG_ENGLISH_NAME_VALUE_ENGLISH).get();

            Account academicProgram = AccountTestDataFactory.createAcademicProgram(false);
            Account department = AccountTestDataFactory.createDepartment(false);
            Account specialty = AccountTestDataFactory.createSpecialty(false);
            Account pathway = AccountTestDataFactory.createPathway(false);
            Internship_Issuance__c issuance = InternshipIssuanceTestDataFactory.create(100, 1, false).get(0);
            Contact studentContact = ContactTestDataFactory.createStudent(false);
            hed__Program_Plan__c programPlan = ProgramPlanTestDataFactory.createCurrent(1, false).get(0);
            Contract contract = ContractTestDataFactory.createContract(contractAccount.Id, Constants.CONTRACT_STATUS_NOT_IMPLEMENTED_API_NAME, false);

            insert new SObject[] {
                academicProgram, department, specialty, pathway, issuance, studentContact, programPlan, contract, polishLanguageTag, englishLanguageTag
            };

            academicProgram.DT_Department__c = department.Id;
            update academicProgram;

            UserTestDataFactory.createCommunityStudentUser(studentContact.Id, 'communityStudentOne@test.invalid', TEST_STUDENT_NICKNAME, true);
            hed__Education_History__c educationHistory = EducationHistoryTestDataFactory.createWithStatusStudying(studentContact.Id, 1, true).get(0);
            hed__Program_Enrollment__c programEnrollment = ProgramEnrollmentTestDataFactory.createWithProgramPlan(
                studentContact.Id,
                academicProgram.Id,
                educationHistory.Id,
                programPlan.Id,
                1,
                true
            ).get(0);

            Internship_Group__c internshipGroup = InternshipGroupTestDataFactory.create(academicProgram.Id, issuance.Id, 1, false).get(0);
            internshipGroup.Specialty__c = specialty.Id;
            internshipGroup.Pathway__c = pathway.Id;
            insert internshipGroup;

            Internship_Requirement__c requirement = InternshipRequirementTestDataFactory.create(educationHistory.Id, internshipGroup.Id, 1, false).get(0);
            requirement.Program_Enrollment__c = programEnrollment.Id;
            insert requirement;
        }
    }

    @IsTest
    private static void fetchOffersSuccess() {
        final Integer EXPECTED_FETCHED_OFFERS_COUNT = 1;

        User studentUser = [SELECT ContactId FROM User WHERE CommunityNickname = :TEST_STUDENT_NICKNAME LIMIT 1];
        Contract contract = [SELECT Id FROM Contract LIMIT 1];
        Account pathway = [
            SELECT Id
            FROM Account
            WHERE RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_SPECIALTY_API_NAME
                AND DT_Account_Type__c = :Constants.ACCOUNT_TYPE_PATHWAY_API_NAME LIMIT 1
        ];

        Career_Services_Offer__c offer = new CsOfferTestData()
            .withRecordType(CAREER_SERVICES_OFFER_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP)
            .withStatus(Constants.CAREER_SERVICES_OFFER_STATUS_PUBLISHED_API_NAME)
            .save()
            .get();

        Career_Services_Offer_Assignment__c offerAssignment = new CsOfferAssignmentTestData()
            .withOffer(offer.Id)
            .withAccount(pathway.Id)
            .asAccepted()
            .get();

        Career_Services_Offer_Contract__c offerContract = CsOfferContractTestDataFactory.createPublishedOfferContract(contract.Id, offer.Id, false);

        insert new List<SObject>{offerAssignment, offerContract};

        MySwpsInternshipSearchController.SearchWrapper searchWrapper;

        Test.startTest();
        System.runAs(studentUser) {
            searchWrapper = MySwpsInternshipSearchController.fetchOffers(EMPTY_FILTERS_WRAPPER, OFFSET_ZERO, RECORDS_TO_RETURN, CAREER_SERVICES_OFFER_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP);
        }
        Test.stopTest();

        Assert.areEqual(EXPECTED_FETCHED_OFFERS_COUNT, searchWrapper.offers.size());
    }

    @IsTest
    private static void fetchOffersNotAcceptedSuccess() {
        final Integer EXPECTED_FETCHED_OFFERS_COUNT = 0;

        User studentUser = [SELECT ContactId FROM User WHERE CommunityNickname = :TEST_STUDENT_NICKNAME LIMIT 1];
        Contract contract = [SELECT Id FROM Contract LIMIT 1];
        Account pathway = [
            SELECT Id
            FROM Account
            WHERE RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_SPECIALTY_API_NAME
                AND DT_Account_Type__c = :Constants.ACCOUNT_TYPE_PATHWAY_API_NAME LIMIT 1
        ];

        Career_Services_Offer__c offer = new CsOfferTestData()
            .withRecordType(CAREER_SERVICES_OFFER_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP)
            .withStatus(Constants.CAREER_SERVICES_OFFER_STATUS_PUBLISHED_API_NAME)
            .save()
            .get();

        Career_Services_Offer_Assignment__c offerAssignment = new CsOfferAssignmentTestData()
            .withOffer(offer.Id)
            .withAccount(pathway.Id)
            .get();

        Career_Services_Offer_Contract__c offerContract = CsOfferContractTestDataFactory.createPublishedOfferContract(contract.Id, offer.Id, false);

        insert new List<SObject>{offerAssignment, offerContract};

        MySwpsInternshipSearchController.SearchWrapper searchWrapper;

        Test.startTest();
        System.runAs(studentUser) {
            searchWrapper = MySwpsInternshipSearchController.fetchOffers(EMPTY_FILTERS_WRAPPER, OFFSET_ZERO, RECORDS_TO_RETURN, CAREER_SERVICES_OFFER_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP);
        }
        Test.stopTest();

        Assert.areEqual(EXPECTED_FETCHED_OFFERS_COUNT, searchWrapper.offers.size());
    }

    @IsTest
    private static void fetchOffersNoOffersForStudentPathwaySuccess() {
        final Integer EXPECTED_FETCHED_OFFERS_COUNT = 0;

        User studentUser = [SELECT ContactId FROM User WHERE CommunityNickname = :TEST_STUDENT_NICKNAME LIMIT 1];
        Contract contract = [SELECT Id FROM Contract LIMIT 1];

        Account pathway = AccountTestDataFactory.createPathway(false);
        Account specialty = AccountTestDataFactory.createSpecialty(false);

        Career_Services_Offer__c offerOne = new CsOfferTestData()
            .withRecordType(CAREER_SERVICES_OFFER_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP)
            .withStatus(Constants.CAREER_SERVICES_OFFER_STATUS_PUBLISHED_API_NAME)
            .get();

        Career_Services_Offer__c offerTwo = new CsOfferTestData()
            .withRecordType(CAREER_SERVICES_OFFER_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP)
            .withStatus(Constants.CAREER_SERVICES_OFFER_STATUS_PUBLISHED_API_NAME)
            .get();

        insert new List<SObject>{pathway, specialty, offerOne, offerTwo};

        Career_Services_Offer_Assignment__c pathwayAssignment = new CsOfferAssignmentTestData()
            .withOffer(offerOne.Id)
            .withAccount(pathway.Id)
            .asAccepted()
            .get();

        Career_Services_Offer_Assignment__c specialtyAssignment = new CsOfferAssignmentTestData()
            .withOffer(offerOne.Id)
            .withAccount(pathway.Id)
            .asAccepted()
            .get();

        Career_Services_Offer_Contract__c offerContractOne = CsOfferContractTestDataFactory.createPublishedOfferContract(contract.Id, offerOne.Id, false);
        Career_Services_Offer_Contract__c offerContractTwo = CsOfferContractTestDataFactory.createPublishedOfferContract(contract.Id, offerTwo.Id, false);

        insert new List<SObject>{pathwayAssignment, specialtyAssignment, offerContractOne, offerContractTwo};

        MySwpsInternshipSearchController.SearchWrapper searchWrapper;

        Test.startTest();
        System.runAs(studentUser) {
            searchWrapper = MySwpsInternshipSearchController.fetchOffers(EMPTY_FILTERS_WRAPPER, OFFSET_ZERO, RECORDS_TO_RETURN, CAREER_SERVICES_OFFER_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP);
        }
        Test.stopTest();

        Assert.areEqual(EXPECTED_FETCHED_OFFERS_COUNT, searchWrapper.offers.size());
    }

    @IsTest
    private static void fetchOffersOfferNotPublishedSuccess() {
        final Integer EXPECTED_FETCHED_OFFERS_COUNT = 0;

        User studentUser = [SELECT ContactId FROM User WHERE CommunityNickname = :TEST_STUDENT_NICKNAME LIMIT 1];

        new CsOfferTestData()
            .withRecordType(CAREER_SERVICES_OFFER_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP)
            .withStatus(Constants.CAREER_SERVICES_OFFER_STATUS_NEW_OFFER)
            .save()
            .get();

        MySwpsInternshipSearchController.SearchWrapper searchWrapper;

        Test.startTest();
        System.runAs(studentUser) {
            searchWrapper = MySwpsInternshipSearchController.fetchOffers(EMPTY_FILTERS_WRAPPER, OFFSET_ZERO, RECORDS_TO_RETURN, CAREER_SERVICES_OFFER_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP);
        }
        Test.stopTest();

        Assert.areEqual(EXPECTED_FETCHED_OFFERS_COUNT, searchWrapper.offers.size());
    }

    @IsTest
    private static void fetchOffersOfferContractNotPublishedSuccess() {
        final Integer EXPECTED_FETCHED_OFFERS_COUNT = 0;

        User studentUser = [SELECT ContactId FROM User WHERE CommunityNickname = :TEST_STUDENT_NICKNAME LIMIT 1];
        Contract contract = [SELECT Id FROM Contract LIMIT 1];

        Account pathway = [
            SELECT Id
            FROM Account
            WHERE RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_SPECIALTY_API_NAME
                AND DT_Account_Type__c = :Constants.ACCOUNT_TYPE_PATHWAY_API_NAME LIMIT 1
        ];

        Career_Services_Offer__c offer = new CsOfferTestData()
            .withRecordType(CAREER_SERVICES_OFFER_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP)
            .withStatus(Constants.CAREER_SERVICES_OFFER_STATUS_PUBLISHED_API_NAME)
            .save()
            .get();

        Career_Services_Offer_Assignment__c offerAssignment = new CsOfferAssignmentTestData()
            .withOffer(offer.Id)
            .withAccount(pathway.Id)
            .get();

        Career_Services_Offer_Contract__c offerContract = CsOfferContractTestDataFactory.createPublishedOfferContract(contract.Id, offer.Id, false);

        insert new List<SObject>{offerAssignment, offerContract};

        MySwpsInternshipSearchController.SearchWrapper searchWrapper;

        Test.startTest();
        System.runAs(studentUser) {
            searchWrapper = MySwpsInternshipSearchController.fetchOffers(EMPTY_FILTERS_WRAPPER, OFFSET_ZERO, RECORDS_TO_RETURN, CAREER_SERVICES_OFFER_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP);
        }
        Test.stopTest();

        Assert.areEqual(EXPECTED_FETCHED_OFFERS_COUNT, searchWrapper.offers.size());
    }

    @IsTest
    private static void fetchOffersOnlyDeepestInRequirementHierarchyFetchedSuccess() {
        final Integer EXPECTED_FETCHED_OFFERS_COUNT = 1;

        User studentUser = [SELECT ContactId FROM User WHERE CommunityNickname = :TEST_STUDENT_NICKNAME LIMIT 1];
        Contract contract = [SELECT Id FROM Contract LIMIT 1];

        Account pathway = [
            SELECT Id
            FROM Account
            WHERE RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_SPECIALTY_API_NAME
                AND DT_Account_Type__c = :Constants.ACCOUNT_TYPE_PATHWAY_API_NAME LIMIT 1
        ];

        Account specialty = [
            SELECT Id
            FROM Account
            WHERE RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_SPECIALTY_API_NAME
                AND DT_Account_Type__c = :Constants.ACCOUNT_TYPE_SPECIALTY_API_NAME LIMIT 1
        ];

        Career_Services_Offer__c offerOne = new CsOfferTestData()
            .withRecordType(CAREER_SERVICES_OFFER_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP)
            .withStatus(Constants.CAREER_SERVICES_OFFER_STATUS_PUBLISHED_API_NAME)
            .get();

        Career_Services_Offer__c offerTwo = new CsOfferTestData()
            .withRecordType(CAREER_SERVICES_OFFER_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP)
            .withStatus(Constants.CAREER_SERVICES_OFFER_STATUS_PUBLISHED_API_NAME)
            .get();

        insert new List<SObject>{offerOne, offerTwo};

        Career_Services_Offer_Assignment__c pathwayAssignment = new CsOfferAssignmentTestData()
            .withOffer(offerOne.Id)
            .withAccount(pathway.Id)
            .asAccepted()
            .get();

        Career_Services_Offer_Assignment__c specialtyAssignment = new CsOfferAssignmentTestData()
            .withOffer(offerOne.Id)
            .withAccount(specialty.Id)
            .asAccepted()
            .get();

        Career_Services_Offer_Contract__c offerContractOne = CsOfferContractTestDataFactory.createPublishedOfferContract(contract.Id, offerOne.Id, false);
        Career_Services_Offer_Contract__c offerContractTwo = CsOfferContractTestDataFactory.createPublishedOfferContract(contract.Id, offerTwo.Id, false);

        insert new List<SObject>{pathwayAssignment, specialtyAssignment, offerContractOne, offerContractTwo};

        MySwpsInternshipSearchController.SearchWrapper searchWrapper;

        Test.startTest();
        System.runAs(studentUser) {
            searchWrapper = MySwpsInternshipSearchController.fetchOffers(EMPTY_FILTERS_WRAPPER, OFFSET_ZERO, RECORDS_TO_RETURN, CAREER_SERVICES_OFFER_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP);
        }
        Test.stopTest();

        Assert.areEqual(EXPECTED_FETCHED_OFFERS_COUNT, searchWrapper.offers.size());
    }

    @IsTest
    private static void fetchOffersWithLanguageFilterSuccess() {
        final Integer EXPECTED_FETCHED_OFFERS_COUNT = 1;

        User studentUser = [SELECT ContactId FROM User WHERE CommunityNickname = :TEST_STUDENT_NICKNAME LIMIT 1];
        Contract contract = [SELECT Id FROM Contract LIMIT 1];
        Tag__c englishLanguageTag = [SELECT Id FROM Tag__c WHERE English_Name__c = :Constants.TAG_ENGLISH_NAME_VALUE_ENGLISH LIMIT 1];

        MySwpsInternshipSearchController.FilterWrapper filtersWrapper = new MySwpsInternshipSearchController.FilterWrapper();
        filtersWrapper.languages = englishLanguageTag.Id;

        Account pathway = [
            SELECT Id
            FROM Account
            WHERE RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_SPECIALTY_API_NAME
                AND DT_Account_Type__c = :Constants.ACCOUNT_TYPE_PATHWAY_API_NAME LIMIT 1
        ];

        Career_Services_Offer__c offer = new CsOfferTestData()
            .withRecordType(CAREER_SERVICES_OFFER_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP)
            .withStatus(Constants.CAREER_SERVICES_OFFER_STATUS_PUBLISHED_API_NAME)
            .save()
            .get();

        Career_Services_Offer_Assignment__c offerAssignment = new CsOfferAssignmentTestData()
            .withOffer(offer.Id)
            .withAccount(pathway.Id)
            .asAccepted()
            .get();

        Career_Services_Offer_Contract__c offerContract = CsOfferContractTestDataFactory.createPublishedOfferContract(contract.Id, offer.Id, false);

        Career_Services_Offer_Tag__c englishTagAssignment = new Career_Services_Offer_Tag__c(Career_Services_Offer__c = offer.Id, Tag__c = englishLanguageTag.Id, Category__c = Constants.TAG_CATEGORY_LANGUAGE_API_NAME);

        insert new List<SObject>{offerAssignment, offerContract, englishTagAssignment};

        MySwpsInternshipSearchController.SearchWrapper searchWrapper;

        Test.startTest();
        System.runAs(studentUser) {
            searchWrapper = MySwpsInternshipSearchController.fetchOffers(filtersWrapper, OFFSET_ZERO, RECORDS_TO_RETURN, CAREER_SERVICES_OFFER_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP);
        }
        Test.stopTest();

        Assert.areEqual(EXPECTED_FETCHED_OFFERS_COUNT, searchWrapper.offers.size());
    }

    @IsTest
    private static void fetchOffersWithLanguageFilterNoResults() {
        final Integer EXPECTED_FETCHED_OFFERS_COUNT = 0;

        MySwpsInternshipSearchController.FilterWrapper filtersWrapper = new MySwpsInternshipSearchController.FilterWrapper();
        filtersWrapper.isPolishRequired = String.valueOf(true);

        User studentUser = [SELECT ContactId FROM User WHERE CommunityNickname = :TEST_STUDENT_NICKNAME LIMIT 1];
        Contract contract = [SELECT Id FROM Contract LIMIT 1];
        Account pathway = [
            SELECT Id
            FROM Account
            WHERE RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_SPECIALTY_API_NAME
                AND DT_Account_Type__c = :Constants.ACCOUNT_TYPE_PATHWAY_API_NAME LIMIT 1
        ];

        Career_Services_Offer__c offer = new CsOfferTestData()
            .withRecordType(CAREER_SERVICES_OFFER_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP)
            .withStatus(Constants.CAREER_SERVICES_OFFER_STATUS_PUBLISHED_API_NAME)
            .save()
            .get();

        Career_Services_Offer_Assignment__c offerAssignment = new CsOfferAssignmentTestData()
            .withOffer(offer.Id)
            .withAccount(pathway.Id)
            .asAccepted()
            .get();

        Career_Services_Offer_Contract__c offerContract = CsOfferContractTestDataFactory.createPublishedOfferContract(contract.Id, offer.Id, false);

        insert new List<SObject>{offerAssignment, offerContract};

        MySwpsInternshipSearchController.SearchWrapper searchWrapper;

        Test.startTest();
        System.runAs(studentUser) {
            searchWrapper = MySwpsInternshipSearchController.fetchOffers(filtersWrapper, OFFSET_ZERO, RECORDS_TO_RETURN, CAREER_SERVICES_OFFER_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP);
        }
        Test.stopTest();

        Assert.areEqual(EXPECTED_FETCHED_OFFERS_COUNT, searchWrapper.offers.size());
    }

    @IsTest
    private static void fetchOffersWithAllFiltersSuccess() {
        final Integer EXPECTED_FETCHED_OFFERS_COUNT = 1;

        MySwpsInternshipSearchController.FilterWrapper filtersWrapper = new MySwpsInternshipSearchController.FilterWrapper();
        filtersWrapper.industry = Constants.ACCOUNT_INDUSTRY_OTHER;
        filtersWrapper.sector = Constants.CAREER_SERVICES_OFFER_SECTOR_PRIVATE;
        filtersWrapper.workplaceType = Constants.CAREER_SERVICES_OFFER_WORKPLACE_TYPE_REMOTE;
        filtersWrapper.isPaid = String.valueOf(true);

        List<String> languageEnglishNames = new List<String> {
            Constants.TAG_ENGLISH_NAME_VALUE_ENGLISH,
            Constants.TAG_ENGLISH_NAME_VALUE_POLISH
        };
        User studentUser = [SELECT ContactId FROM User WHERE CommunityNickname = :TEST_STUDENT_NICKNAME LIMIT 1];
        Contract contract = [SELECT Id FROM Contract LIMIT 1];
        Account company = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_BUSINESS_ORGANIZATION_API_NAME LIMIT 1];
        Account pathway = [
            SELECT Id
            FROM Account
            WHERE RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_SPECIALTY_API_NAME
                AND DT_Account_Type__c = :Constants.ACCOUNT_TYPE_PATHWAY_API_NAME LIMIT 1
        ];

        Career_Services_Offer__c offer = new CsOfferTestData()
            .withRecordType(CAREER_SERVICES_OFFER_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP)
            .withStatus(Constants.CAREER_SERVICES_OFFER_STATUS_PUBLISHED_API_NAME)
            .withSector(Constants.CAREER_SERVICES_OFFER_SECTOR_PRIVATE)
            .withWorkplaceType(Constants.CAREER_SERVICES_OFFER_WORKPLACE_TYPE_REMOTE)
            .withPaidInternship()
            .withCompany(company.Id)
            .save()
            .get();

        Career_Services_Offer_Assignment__c offerAssignment = new CsOfferAssignmentTestData()
            .withOffer(offer.Id)
            .withAccount(pathway.Id)
            .asAccepted()
            .get();

        Career_Services_Offer_Contract__c offerContract = CsOfferContractTestDataFactory.createPublishedOfferContract(contract.Id, offer.Id, false);

        for (Tag__c tag : [SELECT Id FROM Tag__c WHERE English_Name__c IN :languageEnglishNames]) {
            CsOfferTagTestDataFactory.createOfferTag(offer.Id, tag.Id, Constants.TAG_CATEGORY_LANGUAGE_API_NAME, Constants.TAG_LEVEL_ADVANCED_API_NAME, true);
        }

        insert new List<SObject>{offerAssignment, offerContract};

        MySwpsInternshipSearchController.SearchWrapper searchWrapper;

        Test.startTest();
        System.runAs(studentUser) {
            searchWrapper = MySwpsInternshipSearchController.fetchOffers(EMPTY_FILTERS_WRAPPER, OFFSET_ZERO, RECORDS_TO_RETURN, CAREER_SERVICES_OFFER_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP);
        }
        Test.stopTest();

        Assert.areEqual(EXPECTED_FETCHED_OFFERS_COUNT, searchWrapper.offers.size());
    }
}