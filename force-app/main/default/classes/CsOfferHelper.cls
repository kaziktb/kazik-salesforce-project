public with sharing class CsOfferHelper {
    public static void adjustPolishLanguageTag(Map<Id, Career_Services_Offer__c> oldOffersMap, List<Career_Services_Offer__c> newOffers) {
        Set<Id> offerIdsWithTagToDelete = new Set<Id>();
        Set<Id> offerIdsWithTagToInsert = new Set<Id>();

        for (Career_Services_Offer__c newOffer : newOffers) {
            if (!Utils.isFieldChanged(newOffer, oldOffersMap, Career_Services_Offer__c.Is_Polish_Required__c)) {
                continue;
            }

            if (newOffer.Is_Polish_Required__c) {
                offerIdsWithTagToInsert.add(newOffer.Id);
            } else if (oldOffersMap != null) {
                offerIdsWithTagToDelete.add(newOffer.Id);
            }
        }

        if (offerIdsWithTagToInsert.isEmpty() && offerIdsWithTagToDelete.isEmpty()) {
            return;
        }

        List<Id> offerIdsWithExistingPolishTags = new List<Id>();
        Id polishTagId = [SELECT Id FROM Tag__c WHERE Category__c = :Constants.TAG_CATEGORY_LANGUAGE_API_NAME AND English_Name__c = :Constants.TAG_ENGLISH_NAME_VALUE_POLISH].Id;

        for (Career_Services_Offer_Tag__c offerTag : [SELECT Career_Services_Offer__c FROM Career_Services_Offer_Tag__c WHERE Tag__c = :polishTagId]) {
            offerIdsWithExistingPolishTags.add(offerTag.Career_Services_Offer__c);
        }

        List<Career_Services_Offer_Tag__c> offerTagsToInsert = new List<Career_Services_Offer_Tag__c>();
        for (Id offerIdWithTagToInsert : offerIdsWithTagToInsert) {
            if (offerIdsWithExistingPolishTags.contains(offerIdWithTagToInsert)) {
                continue;
            }

            Career_Services_Offer_Tag__c offerTag = new Career_Services_Offer_Tag__c(
                Career_Services_Offer__c = offerIdWithTagToInsert,
                Category__c = Constants.TAG_CATEGORY_LANGUAGE_API_NAME,
                Tag__c = polishTagId,
                Level__c = Constants.TAG_LEVEL_INTERMEDIATE_API_NAME
            );

            offerTagsToInsert.add(offerTag);
        }

        if (!offerTagsToInsert.isEmpty()) {
            SObjectWithoutSharingUtils.insertSObjectList((List<SObject>) offerTagsToInsert, AccessLevel.SYSTEM_MODE);
        }

        List<Career_Services_Offer_Tag__c> offerTagsToDelete = [
            SELECT Id
            FROM Career_Services_Offer_Tag__c
            WHERE Career_Services_Offer__c IN :offerIdsWithTagToDelete
                AND Tag__r.English_Name__c = :Constants.TAG_ENGLISH_NAME_VALUE_POLISH
                AND Category__c = :Constants.TAG_CATEGORY_LANGUAGE_API_NAME
        ];

        if (!offerTagsToDelete.isEmpty()) {
            SObjectWithoutSharingUtils.deleteSObjectList((List<SObject>) offerTagsToDelete, AccessLevel.SYSTEM_MODE);
        }
    }
}