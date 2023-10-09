@IsTest
private class CsOfferHelperTest {
    private static final String TEST_ADMIN_USER_USERNAME = 'edd.min@test.invalid';

    @TestSetup
    private static void setup() {
        User admin = UserTestDataFactory.createAdminUserWithPermissionSetAssigned(TEST_ADMIN_USER_USERNAME);

        System.runAs(admin) {
            new TagTestData()
                .withName('polski')
                .withEnglishName(Constants.TAG_ENGLISH_NAME_VALUE_POLISH)
                .withCategory(Constants.TAG_CATEGORY_LANGUAGE_API_NAME)
                .save();
        }
    }

    @IsTest
    private static void checkIsPolishRequired() {
        User adminUser = [SELECT Id FROM User WHERE Username = :TEST_ADMIN_USER_USERNAME];
        Career_Services_Offer__c offer = new CsOfferTestData().save().get();

        Test.startTest();
        System.runAs(adminUser) {
            offer.Is_Polish_Required__c = true;
            update offer;
        }
        Test.stopTest();

        List<Career_Services_Offer_Tag__c> offerTags = [
            SELECT Id, Tag__r.English_Name__c, Category__c, Level__c, Career_Services_Offer__r.Is_Polish_Required__c
            FROM Career_Services_Offer_Tag__c
            WHERE Career_Services_Offer__c = :offer.Id
        ];

        Assert.areEqual(1, offerTags.size());
        Assert.areEqual(Constants.TAG_LEVEL_INTERMEDIATE_API_NAME, offerTags[0].Level__c);
        Assert.areEqual(Constants.TAG_CATEGORY_LANGUAGE_API_NAME, offerTags[0].Category__c);
        Assert.areEqual(Constants.TAG_ENGLISH_NAME_VALUE_POLISH, offerTags[0].Tag__r.English_Name__c);
        Assert.areEqual(true, offerTags[0].Career_Services_Offer__r.Is_Polish_Required__c);
    }

    @IsTest
    private static void uncheckIsPolishRequired() {
        User adminUser = [SELECT Id FROM User WHERE Username = :TEST_ADMIN_USER_USERNAME];
        Career_Services_Offer__c offer = new CsOfferTestData().withPolishLanguageRequired().save().get();

        Integer tagsCountBeforeUpdate = [
            SELECT (
                SELECT Id FROM Tags__r WHERE Tag__r.English_Name__c = :Constants.TAG_ENGLISH_NAME_VALUE_POLISH
            ) FROM Career_Services_Offer__c
            WHERE Id = :offer.Id
        ].Tags__r.size();

        Test.startTest();
        System.runAs(adminUser) {
            offer.Is_Polish_Required__c = false;
            update offer;
        }
        Test.stopTest();

        Integer tagsCountAfterUpdate = [
            SELECT (
                SELECT Id FROM Tags__r WHERE Tag__r.English_Name__c = :Constants.TAG_ENGLISH_NAME_VALUE_POLISH
            ) FROM Career_Services_Offer__c
            WHERE Id = :offer.Id
        ].Tags__r.size();

        Assert.areEqual(1, tagsCountBeforeUpdate);
        Assert.areEqual(0, tagsCountAfterUpdate);
    }

    @IsTest
    private static void checkIsPolishRequiredWhenTagAlreadyExists() {
        User adminUser = [SELECT Id FROM User WHERE Username = :TEST_ADMIN_USER_USERNAME];
        Tag__c polishTag = [SELECT Id FROM Tag__c WHERE English_Name__c = :Constants.TAG_ENGLISH_NAME_VALUE_POLISH AND Category__c = :Constants.TAG_CATEGORY_LANGUAGE_API_NAME];
        Career_Services_Offer__c offer = new CsOfferTestData().save().get();

        CsOfferTagTestDataFactory.createOfferTag(offer.Id, polishTag.Id, Constants.TAG_CATEGORY_LANGUAGE_API_NAME, Constants.TAG_LEVEL_INTERMEDIATE_API_NAME, true);

        Integer tagsCountBeforeUpdate = [
            SELECT (
                SELECT Id FROM Tags__r WHERE Tag__r.English_Name__c = :Constants.TAG_ENGLISH_NAME_VALUE_POLISH
            ) FROM Career_Services_Offer__c
            WHERE Id = :offer.Id
        ].Tags__r.size();

        Test.startTest();
        System.runAs(adminUser) {
            offer.Is_Polish_Required__c = true;
            update offer;
        }
        Test.stopTest();

        Integer tagsCountAfterUpdate = [
            SELECT (
                SELECT Id FROM Tags__r WHERE Tag__r.English_Name__c = :Constants.TAG_ENGLISH_NAME_VALUE_POLISH
            ) FROM Career_Services_Offer__c
            WHERE Id = :offer.Id
        ].Tags__r.size();

        Assert.areEqual(tagsCountBeforeUpdate, tagsCountAfterUpdate);
    }

    @IsTest
    private static void uncheckIsPolishRequiredWhenTagAlreadyDeleted() {
        User adminUser = [SELECT Id FROM User WHERE Username = :TEST_ADMIN_USER_USERNAME];
        Tag__c polishTag = [SELECT Id FROM Tag__c WHERE English_Name__c = :Constants.TAG_ENGLISH_NAME_VALUE_POLISH AND Category__c = :Constants.TAG_CATEGORY_LANGUAGE_API_NAME];
        Career_Services_Offer__c offer = new CsOfferTestData().withPolishLanguageRequired().save().get();

        Career_Services_Offer_Tag__c offerTag = [SELECT Id FROM Career_Services_Offer_Tag__c WHERE Career_Services_Offer__c = :offer.Id AND Tag__c = :polishTag.Id];

        delete offerTag;

        Integer tagsCountBeforeUpdate = [
            SELECT (
                SELECT Id FROM Tags__r WHERE Tag__r.English_Name__c = :Constants.TAG_ENGLISH_NAME_VALUE_POLISH
            ) FROM Career_Services_Offer__c
            WHERE Id = :offer.Id
        ].Tags__r.size();

        Test.startTest();
        System.runAs(adminUser) {
            offer.Is_Polish_Required__c = false;
            update offer;
        }
        Test.stopTest();

        Integer tagsCountAfterUpdate = [
            SELECT (
                SELECT Id FROM Tags__r WHERE Tag__r.English_Name__c = :Constants.TAG_ENGLISH_NAME_VALUE_POLISH
            ) FROM Career_Services_Offer__c
            WHERE Id = :offer.Id
        ].Tags__r.size();

        Assert.areEqual(0, tagsCountBeforeUpdate);
        Assert.areEqual(tagsCountBeforeUpdate, tagsCountAfterUpdate);
    }
}