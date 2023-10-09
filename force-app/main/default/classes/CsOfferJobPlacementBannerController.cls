public with sharing class CsOfferJobPlacementBannerController {

    private static final List<String> OFFER_CONTRACT_FINISHED_STATUSES = new List<String> {
        Constants.CAREER_SERVICES_OFFER_CONTRACT_STATUS_COMPLETED_API_NAME,
        Constants.CAREER_SERVICES_OFFER_CONTRACT_STATUS_EXPIRED_API_NAME
    };

    @AuraEnabled(Cacheable=true)
    public static OfferContractWrapper fetchRelatedOfferContracts(Id offerId) {
        OfferContractWrapper wrapper = new OfferContractWrapper();
        Career_Services_Offer__c offer = [
            SELECT Id, (
                SELECT Id, Start_Date__c, End_Date__c, Status__c
                FROM Career_Services_Offer_Contracts__r
                WHERE Status__c = :Constants.CAREER_SERVICES_OFFER_CONTRACT_STATUS_PUBLISHED_API_NAME
                    OR Status__c IN :OFFER_CONTRACT_FINISHED_STATUSES
                    OR (
                        Start_Date__c > TODAY
                            AND Status__c = :Constants.CAREER_SERVICES_OFFER_CONTRACT_STATUS_DRAFT_API_NAME
                    )
                ORDER BY Start_Date__c
            )
            FROM Career_Services_Offer__c
            WHERE Id = :offerId
        ];

        for (Career_Services_Offer_Contract__c offerContract : offer.Career_Services_Offer_Contracts__r) {
            processOfferContract(offerContract, wrapper);
        }

        return wrapper;
    }

    private static void processOfferContract(Career_Services_Offer_Contract__c careerServicesOfferContract, OfferContractWrapper wrapper) {
        Boolean isFinishedContract = OFFER_CONTRACT_FINISHED_STATUSES.contains(careerServicesOfferContract.Status__c);

        if (isFinishedContract) {
            wrapper.completedOfferContractsCount++;
            return;
        }

        OfferContractWrapperItem wrapperItem = new OfferContractWrapperItem();
        wrapperItem.isActive = careerServicesOfferContract.Start_Date__c <= Date.today() && careerServicesOfferContract.End_Date__c >= Date.today();
        wrapperItem.periodFrom = careerServicesOfferContract.Start_Date__c.format();
        wrapperItem.periodTo = careerServicesOfferContract.End_Date__c.format();
        wrapperItem.recordId = careerServicesOfferContract.Id;
        wrapperItem.label = wrapperItem.periodFrom + ' - ' + wrapperItem.periodTo;

        if (wrapperItem.isActive) {
            wrapper.currentContractActiveDays = Date.today().daysBetween(careerServicesOfferContract.End_Date__c);
            wrapper.isJobPlacementActive = true;
        }

        wrapper.items.add(wrapperItem);
    }

    private class OfferContractWrapper {
        public OfferContractWrapper() {
            items = new List<OfferContractWrapperItem>();
            completedOfferContractsCount = 0;
            currentContractActiveDays = 0;
        }

        @AuraEnabled
        public Integer completedOfferContractsCount;
        @AuraEnabled
        public Integer currentContractActiveDays;
        @AuraEnabled
        public Boolean isJobPlacementActive;
        @AuraEnabled
        public List<OfferContractWrapperItem> items;
    }

    private class OfferContractWrapperItem {
        @AuraEnabled
        public Id recordId;
        @AuraEnabled
        public String periodFrom;
        @AuraEnabled
        public String periodTo;
        @AuraEnabled
        public Boolean isActive;
        @AuraEnabled
        public String label;
    }
}