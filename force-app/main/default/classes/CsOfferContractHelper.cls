public with sharing class CsOfferContractHelper {
    public static void validatePublishedContractDuplication(Map<Id, Career_Services_Offer_Contract__c> id2OldOfferContracts, List<Career_Services_Offer_Contract__c> newOfferContracts) {
        Set<Id> offerIds = new Set<Id>();

        for (Career_Services_Offer_Contract__c contract : newOfferContracts) {
            if (contract.Status__c == Constants.CAREER_SERVICES_OFFER_CONTRACT_STATUS_PUBLISHED_API_NAME
                && Utils.isFieldChanged(contract, id2OldOfferContracts, Career_Services_Offer_Contract__c.Status__c)) {
                offerIds.add(contract.Career_Services_Offer__c);
            }
        }
        List<Career_Services_Offer_Contract__c> activeContracts = new List<Career_Services_Offer_Contract__c>(
        [
            SELECT Career_Services_Offer__c
            FROM Career_Services_Offer_Contract__c
            WHERE Career_Services_Offer__c IN :offerIds
                AND Status__c = :Constants.CAREER_SERVICES_OFFER_CONTRACT_STATUS_PUBLISHED_API_NAME
        ]);

        Set<Id> offerIdsWithActiveContract = new Set<Id>();

        for (Career_Services_Offer_Contract__c activeContract : activeContracts) {
            offerIdsWithActiveContract.add(activeContract.Career_Services_Offer__c);
        }

        for (Career_Services_Offer_Contract__c newContract : newOfferContracts) {
            if (offerIdsWithActiveContract.contains(newContract.Career_Services_Offer__c)) {
                newContract.addError(Label.Career_Services_Offer_Contract_Published_Dupe_Error);
            }
        }
    }
}