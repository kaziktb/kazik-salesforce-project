@IsTest
public with sharing class CsOfferTagTestDataFactory {
    public static Career_Services_Offer_Tag__c createOfferTag(Id offerId, Id tagId, String category, String level, Boolean withInsert) {
        return withInsert
            ? new CsOfferTagTestData()
                .withCareerServicesOfferId(offerId)
                .withTagId(tagId)
                .withCategory(category)
                .withLevel(level)
                .save()
                .get()
            : new CsOfferTagTestData()
                .withCareerServicesOfferId(offerId)
                .withTagId(tagId)
                .withCategory(category)
                .withLevel(level)
                .get();
    }
}