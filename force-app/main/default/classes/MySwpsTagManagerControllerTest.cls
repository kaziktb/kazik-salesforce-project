@IsTest
private class MySwpsTagManagerControllerTest {
    private static final String POLISH_TAG_NAME_EN = 'Polish';
    private static final String POLISH_TAG_NAME_PL = 'Polski';
    private static final String ENGLISH_TAG_NAME_EN = 'English';
    private static final String ENGLISH_TAG_NAME_PL = 'Angielski';
    private static final String TEST_ADMIN_USER_USERNAME = 'SysAdmin@example.com.test';
    private static final String TEST_STUDENT_CONTACT_LAST_NAME = 'Testownik';
    private static final Id JOB_OFFER_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(Career_Services_Offer__c.getSObjectType(), Constants.CAREER_SERVICES_OFFER_RT_JOB_OFFER);

    @TestSetup
    private static void testSetup() {
        User admin = UserTestDataFactory.createAdminUser(TEST_ADMIN_USER_USERNAME, true);

        System.runAs(admin) {
            List<Tag__c> languageTags = new List<Tag__c>{
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
            insert languageTags;

            Career_Services_Offer__c jobOffer = CsOfferTestDataFactory.createOfferWithRecordType(Constants.CAREER_SERVICES_OFFER_RT_JOB_OFFER, true);
            CsOfferTagTestDataFactory.createOfferTag(
                jobOffer.Id,
                languageTags[0].Id,
                Constants.TAG_CATEGORY_LANGUAGE_API_NAME,
                Constants.TAG_LEVEL_ADVANCED_API_NAME,
                true
            );

            Contact student = ContactTestDataFactory.createStudent(TEST_STUDENT_CONTACT_LAST_NAME, true);
            ContactTagTestDataFactory.createContactTag(
                student.Id,
                languageTags[0].Id,
                Constants.TAG_CATEGORY_LANGUAGE_API_NAME,
                Constants.TAG_LEVEL_ADVANCED_API_NAME,
                true
            );
        }
    }

    @IsTest
    private static void searchTagsTest() {
        User admin = [SELECT Id FROM User WHERE Username = :TEST_ADMIN_USER_USERNAME];
        List<LookupSearchResult> searchResults;

        Test.startTest();
        System.runAs(admin) {
            searchResults = MySwpsTagManagerController.searchTags(
                POLISH_TAG_NAME_EN.substring(1,3),
                new List<Id>(),
                Constants.TAG_CATEGORY_LANGUAGE_API_NAME,
                Constants.LANGUAGE_LOCALE_KEY_POLISH,
                new List<String>()
            );
        }
        Test.stopTest();

        Assert.areEqual(1, searchResults.size());
        Assert.areEqual(POLISH_TAG_NAME_PL, searchResults[0].getTitle());
    }

    @IsTest
    private static void fetchRecordTagsContactTest() {
        List<MySwpsTagManagerController.TagWrapper> tagWrappers;
        Contact studentContact = [
            SELECT Id, (
                SELECT Id, Level__c
                FROM Tags__r
                WHERE Category__c = :Constants.TAG_CATEGORY_LANGUAGE_API_NAME
            )
            FROM Contact
            WHERE LastName = :TEST_STUDENT_CONTACT_LAST_NAME
            LIMIT 1
        ];

        Test.startTest();
        tagWrappers = MySwpsTagManagerController.fetchRecordTags(studentContact.Id, Constants.TAG_CATEGORY_LANGUAGE_API_NAME, Constants.LANGUAGE_LOCALE_KEY_POLISH);
        Test.stopTest();

        Assert.areEqual(studentContact.Tags__r.size(), tagWrappers.size());
        Assert.areEqual(studentContact.Tags__r[0].Level__c, tagWrappers[0].level.value);
        Assert.areEqual(studentContact.Tags__r[0].Id, tagWrappers[0].tagId);
    }

    @IsTest
    private static void fetchRecordTagsCsOfferTest() {
        List<MySwpsTagManagerController.TagWrapper> tagWrappers;
        Career_Services_Offer__c jobOffer = [
            SELECT Id, (
                SELECT Id, Level__c
                FROM Tags__r
                WHERE Category__c = :Constants.TAG_CATEGORY_LANGUAGE_API_NAME
            )
            FROM Career_Services_Offer__c
            WHERE RecordTypeId = :JOB_OFFER_RECORD_TYPE_ID
            LIMIT 1
        ];

        Test.startTest();
        tagWrappers = MySwpsTagManagerController.fetchRecordTags(jobOffer.Id, Constants.TAG_CATEGORY_LANGUAGE_API_NAME, Constants.LANGUAGE_LOCALE_KEY_POLISH);
        Test.stopTest();

        Assert.areEqual(jobOffer.Tags__r.size(), tagWrappers.size());
        Assert.areEqual(jobOffer.Tags__r[0].Level__c, tagWrappers[0].level.value);
        Assert.areEqual(jobOffer.Tags__r[0].Id, tagWrappers[0].tagId);
    }

    @IsTest
    private static void searchTagsWithExcludedValueTest() {
        User admin = [SELECT Id FROM User WHERE Username = :TEST_ADMIN_USER_USERNAME];
        List<LookupSearchResult> searchResults;

        Test.startTest();
        System.runAs(admin) {
            searchResults = MySwpsTagManagerController.searchTags(
                POLISH_TAG_NAME_EN.substring(1,3),
                new List<Id>(),
                Constants.TAG_CATEGORY_LANGUAGE_API_NAME,
                Constants.LANGUAGE_LOCALE_KEY_POLISH,
                new List<String>{POLISH_TAG_NAME_EN}
            );
        }
        Test.stopTest();

        Assert.areEqual(0, searchResults.size());
    }
}