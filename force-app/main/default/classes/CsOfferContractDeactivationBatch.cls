public without sharing class CsOfferContractDeactivationBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext context) {
        if (!AutomationBypass__c.getInstance().Bypass_Automations__c && !Test.isRunningTest()) {
            throw new CustomException.MissingBypassException('Cannot execute this batch while ' + AutomationBypass__c.Bypass_Automations__c.getDescribe().name + ' is not set to true').saveLog();
        }

        String query = 'SELECT Id, Start_Date__c, End_Date__c, Status__c, Candidates_Accepted__c, Candidates_To_Submit__c, Career_Services_Offer__r.Status__c ' +
            'FROM Career_Services_Offer_Contract__c ' +
            'WHERE (Start_Date__c = TODAY AND Status__c = \'' + Constants.CAREER_SERVICES_OFFER_CONTRACT_STATUS_DRAFT_API_NAME + '\')' +
            'OR Status__c = \'' + Constants.CAREER_SERVICES_OFFER_CONTRACT_STATUS_PUBLISHED_API_NAME + '\'';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<Career_Services_Offer_Contract__c> offerContracts) {
        final List<String> CAREER_SERVICES_OFFER_CONTRACT_DEACTIVATED_STATUSES = new List<String>{
            Constants.CAREER_SERVICES_OFFER_CONTRACT_STATUS_COMPLETED_API_NAME,
            Constants.CAREER_SERVICES_OFFER_CONTRACT_STATUS_EXPIRED_API_NAME
        };

        List<Career_Services_Offer_Contract__c> offerContractsToUpdate = new List<Career_Services_Offer_Contract__c>();
        List<Career_Services_Offer__c> offersToUpdate = new List<Career_Services_Offer__c>();
        Map<Id, Boolean> offerId2HasNextContract = new Map<Id, Boolean>();

        for (Career_Services_Offer_Contract__c offerContract : offerContracts) {
            Boolean hasNextContract = offerContract.Status__c == Constants.CAREER_SERVICES_OFFER_CONTRACT_STATUS_DRAFT_API_NAME;

            offerId2HasNextContract.put(offerContract.Career_Services_Offer__c, hasNextContract);
        }

        for (Career_Services_Offer_Contract__c offerContract : offerContracts) {
            String newStatus = determineOfferContractNewStatus(offerContract);

            if (String.isBlank(newStatus)) {
                continue;
            }

            if (CAREER_SERVICES_OFFER_CONTRACT_DEACTIVATED_STATUSES.contains(newStatus)
                && offerId2HasNextContract.containsKey(offerContract.Career_Services_Offer__c)
                && !offerId2HasNextContract.get(offerContract.Career_Services_Offer__c)
            ) {
                offerContract.Career_Services_Offer__r.Status__c = Constants.CAREER_SERVICES_OFFER_STATUS_ARCHIVED_API_NAME;
                offersToUpdate.add(offerContract.Career_Services_Offer__r);
            }

            offerContract.Status__c = newStatus;
            offerContractsToUpdate.add(offerContract);
        }

        update offerContractsToUpdate;

        if (offersToUpdate.isEmpty()) {
            return;
        }

        update offersToUpdate;
    }

    public void finish(Database.BatchableContext context) {
    }

    private static String determineOfferContractNewStatus(Career_Services_Offer_Contract__c careerServicesOfferContract) {
        if (shouldBeActivated(careerServicesOfferContract)) {
            return Constants.CAREER_SERVICES_OFFER_CONTRACT_STATUS_PUBLISHED_API_NAME;
        }

        if (shouldBeDeactivatedAsCompleted(careerServicesOfferContract)) {
            return Constants.CAREER_SERVICES_OFFER_CONTRACT_STATUS_COMPLETED_API_NAME;
        }

        if (shouldBeDeactivatedAsExpired(careerServicesOfferContract)) {
            return Constants.CAREER_SERVICES_OFFER_CONTRACT_STATUS_EXPIRED_API_NAME;
        }

        return '';
    }

    private static Boolean shouldBeActivated(Career_Services_Offer_Contract__c offerContract) {
        return offerContract.Start_Date__c == Date.today();
    }

    private static Boolean shouldBeDeactivatedAsCompleted(Career_Services_Offer_Contract__c offerContract) {
        return offerContract.Candidates_To_Submit__c != null && offerContract.Candidates_Accepted__c == offerContract.Candidates_To_Submit__c;
    }

    private static Boolean shouldBeDeactivatedAsExpired(Career_Services_Offer_Contract__c offerContract) {
        return offerContract.End_Date__c < Date.today();
    }
}