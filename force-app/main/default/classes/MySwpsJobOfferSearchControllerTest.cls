@IsTest
private class MySwpsJobOfferSearchControllerTest {
    private static final String EXISTING_OFFER_BUSINESS_CATEGORY = Constants.CAREER_SERVICES_OFFER_BUSINESS_CATEGORY_DESIGN_API_NAME;
    private static final String EXISTING_OFFER_LOCATION_OF_SWPS = Constants.CAREER_SERVICES_OFFER_LOCATION_OF_SWPS_UNIVERSITY_WARSZAWA_API_NAME;
    private static final String EXISTING_OFFER_POSITION_LEVEL = Constants.CAREER_SERVICES_OFFER_POSITION_LEVEL_SPECIALIST_API_NAME;
    private static final String EXISTING_OFFER_EMPLOYMENT_TYPE = Constants.CAREER_SERVICES_OFFER_EMPLOYMENT_TYPE_B2B_API_NAME;
    private static final String EXISTING_OFFER_POLISH_REQUIRED = 'true';
    private static final String EXISTING_OFFER_WORKPLACE_TYPE = Constants.CAREER_SERVICES_OFFER_WORKPLACE_TYPE_REMOTE;
    private static final Integer EXISTING_OFFER_MIN_WORKING_HOURS = 20;
    private static final Integer EXISTING_OFFER_MAX_WORKING_HOURS = 30;
    private static final Id JOB_OFFER_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(
        Career_Services_Offer__c.getSObjectType(),
        Constants.CAREER_SERVICES_OFFER_RT_JOB_OFFER
    );
    private static final String TAG_NAME_VALUE_ENGLISH = 'angielski';
    private static final String TAG_NAME_VALUE_POLISH = 'polski';
    private static final String TEST_ADMIN_USERNAME = 'Artu@ditu.test.com';
    private static final String TEST_STUDENT_USERNAME = 'osoba@studencka.test.com';
    @TestSetup
    private static void testSetup() {
        User adminUser = UserTestDataFactory.createAdminUser(TEST_ADMIN_USERNAME, true);

        System.runAs(adminUser) {
            AccountTestDataFactory.createBaseBusinessOrganizationAccount(Constants.ACCOUNT_STATUS_ACTIVE_API_NAME, true);

            List<Tag__c> tags = new List<Tag__c>{
                new TagTestData()
                    .withCategory(Constants.TAG_CATEGORY_LANGUAGE_API_NAME)
                    .withName(TAG_NAME_VALUE_POLISH)
                    .withEnglishName(Constants.TAG_ENGLISH_NAME_VALUE_POLISH)
                    .get(),
                new TagTestData()
                    .withCategory(Constants.TAG_CATEGORY_LANGUAGE_API_NAME)
                    .withName(TAG_NAME_VALUE_ENGLISH)
                    .withEnglishName(Constants.TAG_ENGLISH_NAME_VALUE_ENGLISH)
                    .get()
            };
            insert tags;

            Contact studentContact = ContactTestDataFactory.createStudent(true);

            Career_Services_Offer__c existingOffer = new CsOfferTestData()
                .withRecordType(JOB_OFFER_RECORD_TYPE_ID)
                .withLocationsOfSWPS(EXISTING_OFFER_LOCATION_OF_SWPS)
                .withBusinessCategories(EXISTING_OFFER_BUSINESS_CATEGORY)
                .withPolishLanguageRequired()
                .withPositionLevel(EXISTING_OFFER_POSITION_LEVEL)
                .withEmploymentType(EXISTING_OFFER_EMPLOYMENT_TYPE)
                .withWorkplaceType(EXISTING_OFFER_WORKPLACE_TYPE)
                .withWeeklyWorkingHoursMinimum(EXISTING_OFFER_MIN_WORKING_HOURS)
                .withWeeklyWorkingHoursMaximum(EXISTING_OFFER_MAX_WORKING_HOURS)
                .save()
                .get();

            new CsOfferTagTestData().withTagId(tags[0].Id).withCareerServicesOfferId(existingOffer.Id)
                .withCategory(Constants.TAG_CATEGORY_LANGUAGE_API_NAME)
                .withLevel(Constants.TAG_LEVEL_ADVANCED_API_NAME)
                .save();

            UserTestDataFactory.createCommunityStudentUser(studentContact.Id, TEST_STUDENT_USERNAME, 'stud', true);
        }
    }

    @IsTest
    private static void fetchInitialDataTest() {
        Integer availableLanguagesCountWithoutPolish = [SELECT COUNT() FROM Tag__c WHERE Category__c = :Constants.TAG_CATEGORY_LANGUAGE_API_NAME AND English_Name__c != :Constants.TAG_ENGLISH_NAME_VALUE_POLISH];
        User studentUser = [SELECT Id FROM User WHERE Username = :TEST_STUDENT_USERNAME];
        MySwpsJobOfferSearchController.InitialDataWrapper initialDataWrapper = new MySwpsJobOfferSearchController.InitialDataWrapper();

        Test.startTest();
        System.runAs(studentUser) {
            initialDataWrapper = MySwpsJobOfferSearchController.fetchInitialData(Constants.LANGUAGE_LOCALE_KEY_POLISH);
        }
        Test.stopTest();

        Assert.areEqual(availableLanguagesCountWithoutPolish, initialDataWrapper.languages.size());
        Assert.isNotNull(initialDataWrapper.jobOfferRecordTypeId);
    }

    @IsTest
    private static void fetchSearchResultsNoPublishedOffersTest() {
        User studentUser = [SELECT Id FROM User WHERE Username = :TEST_STUDENT_USERNAME];
        Tag__c polishLanguageTag = [SELECT Id FROM Tag__c WHERE Name = :TAG_NAME_VALUE_POLISH];
        MySwpsJobOfferSearchController.FilterWrapper filterWrapper = new MySwpsJobOfferSearchController.FilterWrapper();
        MySwpsJobOfferSearchController.SearchResultWrapper searchWrapper = new MySwpsJobOfferSearchController.SearchResultWrapper();

        filterWrapper.businessCategory = EXISTING_OFFER_BUSINESS_CATEGORY;
        filterWrapper.employmentType = EXISTING_OFFER_EMPLOYMENT_TYPE;
        filterWrapper.isPolishRequired = EXISTING_OFFER_POLISH_REQUIRED;
        filterWrapper.languages = polishLanguageTag.Id;
        filterWrapper.nearestCampus = EXISTING_OFFER_LOCATION_OF_SWPS;
        filterWrapper.positionLevel = EXISTING_OFFER_POSITION_LEVEL;
        filterWrapper.weeklyWorkingHoursMax = '30';
        filterWrapper.weeklyWorkingHoursMin = '25';
        filterWrapper.workplaceType = EXISTING_OFFER_WORKPLACE_TYPE;

        Test.startTest();
        System.runAs(studentUser) {
            searchWrapper = MySwpsJobOfferSearchController.fetchSearchResults(
                filterWrapper,
                0,
                3,
                JOB_OFFER_RECORD_TYPE_ID
            );
        }
        Test.stopTest();

        Assert.isFalse(searchWrapper.hasNext);
        Assert.areEqual(0, searchWrapper.offers.size());
        Assert.areEqual(0, searchWrapper.offset);
    }

    @IsTest
    private static void fetchSearchResultsSuccessTest() {
        User studentUser = [SELECT Id FROM User WHERE Username = :TEST_STUDENT_USERNAME];
        Tag__c polishLanguageTag = [SELECT Id FROM Tag__c WHERE Name = :TAG_NAME_VALUE_POLISH];
        Career_Services_Offer__c existingJobOffer = [SELECT Id FROM Career_Services_Offer__c WHERE RecordTypeId = :JOB_OFFER_RECORD_TYPE_ID];
        MySwpsJobOfferSearchController.FilterWrapper filterWrapper = new MySwpsJobOfferSearchController.FilterWrapper();
        MySwpsJobOfferSearchController.SearchResultWrapper searchWrapper = new MySwpsJobOfferSearchController.SearchResultWrapper();

        existingJobOffer.Status__c = Constants.CAREER_SERVICES_OFFER_STATUS_PUBLISHED_API_NAME;
        update existingJobOffer;

        filterWrapper.businessCategory = EXISTING_OFFER_BUSINESS_CATEGORY;
        filterWrapper.employmentType = EXISTING_OFFER_EMPLOYMENT_TYPE;
        filterWrapper.isPolishRequired = EXISTING_OFFER_POLISH_REQUIRED;
        filterWrapper.languages = polishLanguageTag.Id;
        filterWrapper.nearestCampus = EXISTING_OFFER_LOCATION_OF_SWPS;
        filterWrapper.positionLevel = EXISTING_OFFER_POSITION_LEVEL;
        filterWrapper.weeklyWorkingHoursMax = '32';
        filterWrapper.weeklyWorkingHoursMin = '16';
        filterWrapper.workplaceType = EXISTING_OFFER_WORKPLACE_TYPE;

        Test.startTest();
        System.runAs(studentUser) {
            searchWrapper = MySwpsJobOfferSearchController.fetchSearchResults(
                filterWrapper,
                0,
                3,
                JOB_OFFER_RECORD_TYPE_ID
            );
        }
        Test.stopTest();

        Assert.isFalse(searchWrapper.hasNext);
        Assert.areEqual(1, searchWrapper.offers.size());
        Assert.areEqual(1, searchWrapper.offset);
    }
}