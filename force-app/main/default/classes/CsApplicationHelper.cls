public without sharing class CsApplicationHelper {
    private static final Id APPLICATION_JOB_PLACEMENT_RECORD_TYPE_ID =
        Utils.getRecordTypeIdByDevName(Career_Services_Application__c.getSObjectType(), Constants.CAREER_SERVICES_APPLICATION_RT_JOB_PLACEMENT_APPLICATION);
    private static final Id APPLICATION_INSTITUTIONAL_INTERNSHIP_RECORD_TYPE_ID =
        Utils.getRecordTypeIdByDevName(Career_Services_Application__c.getSObjectType(), Constants.CAREER_SERVICES_APPLICATION_RT_INSTITUTIONAL_INTERNSHIP);
    private static final Id APPLICATION_INDIVIDUAL_INTERNSHIP_RECORD_TYPE_ID =
        Utils.getRecordTypeIdByDevName(Career_Services_Application__c.getSObjectType(), Constants.CAREER_SERVICES_APPLICATION_RT_INDIVIDUAL_INTERNSHIP);

    public static void countApplications(Map<Id, Career_Services_Application__c> id2oldApplication, List<Career_Services_Application__c> newApplications) {
        List<Id> applicationRecordTypeIds = new List<Id>{
            APPLICATION_JOB_PLACEMENT_RECORD_TYPE_ID,
            APPLICATION_INSTITUTIONAL_INTERNSHIP_RECORD_TYPE_ID
        };
        List<String> acceptedStatuses = new List<String>{
            Constants.CAREER_SERVICES_APPLICATION_STATUS_APPLICATION_ACCEPTED,
            Constants.CAREER_SERVICES_APPLICATION_STATUS_INTERNSHIP_READY_TO_PROCEED
        };
        List<String> csOfferContractRecordTypeNames = new List<String>{
            Constants.CAREER_SERVICES_OFFER_CONTRACT_RECORD_TYPE_JOB_OFFER_API_NAME,
            Constants.CAREER_SERVICES_OFFER_CONTRACT_RT_INTERNSHIP
        };
        List<String> offerRecordTypeNames = new List<String>{
            Constants.CAREER_SERVICES_OFFER_RT_JOB_OFFER,
            Constants.CAREER_SERVICES_OFFER_RT_INSTITUTIONAL_INTERNSHIP
        };
        Set<Id> offerIds = new Set<Id>();

        for (Career_Services_Application__c application : newApplications) {
            if (applicationRecordTypeIds.contains(application.RecordTypeId)) {
                offerIds.add(application.Career_Services_Offer__c);
            }

            Boolean hasStatusChanged = id2oldApplication != null
                && Utils.isFieldChanged(application, id2oldApplication, Career_Services_Application__c.Status__c)
                && (
                    acceptedStatuses.contains(id2oldApplication.get(application.Id).Status__c)
                    || acceptedStatuses.contains(application.Status__c));

            Boolean hasRecordTypeChanged = id2oldApplication != null && Utils.isFieldChanged(application, id2oldApplication, Career_Services_Application__c.RecordTypeId);

            if (hasStatusChanged || hasRecordTypeChanged) {
                offerIds.add(application.Career_Services_Offer__c);
            }
        }

        List<Career_Services_Offer__c> offers = [
            SELECT
                Id,
                (
                    SELECT Status__c, CreatedDate, Career_Services_Offer__c
                    FROM Career_Services_Applications__r
                    WHERE RecordTypeId IN :applicationRecordTypeIds
                ),
                (
                    SELECT Start_Date__c, End_Date__c
                    FROM Career_Services_Offer_Contracts__r
                    WHERE Status__c = :Constants.CAREER_SERVICES_OFFER_CONTRACT_STATUS_PUBLISHED_API_NAME
                        AND RecordType.DeveloperName IN :csOfferContractRecordTypeNames
                )
            FROM Career_Services_Offer__c
            WHERE Id IN :offerIds
                AND RecordType.DeveloperName IN :offerRecordTypeNames
        ];

        Map<Id, Career_Services_Offer_Contract__c> offerId2OfferContract = new Map<Id, Career_Services_Offer_Contract__c>();
        List<Career_Services_Application__c> applications = new List<Career_Services_Application__c>();

        for (Career_Services_Offer__c offer : offers) {
            if (!offer.Career_Services_Offer_Contracts__r.isEmpty()) {
                Career_Services_Offer_Contract__c offerContract = offer.Career_Services_Offer_Contracts__r[0];
                offerContract.Candidates__c = 0;
                offerContract.Candidates_Accepted__c = 0;
                offerId2OfferContract.put(offer.Id, offerContract);
                applications.addAll(offer.Career_Services_Applications__r);
            }
        }

        for (Career_Services_Application__c application : applications) {
            Career_Services_Offer_Contract__c publishedOfferContract = offerId2OfferContract.get(application.Career_Services_Offer__c);

            if (publishedOfferContract != null
                && application.CreatedDate >= publishedOfferContract.Start_Date__c
                && (
                    publishedOfferContract.End_Date__c == null
                    || application.CreatedDate <= publishedOfferContract.End_Date__c)
            ) {
                publishedOfferContract.Candidates__c++;

                if (acceptedStatuses.contains(application.Status__c)) {
                    publishedOfferContract.Candidates_Accepted__c++;
                }
            }
        }

        update offerId2OfferContract.values();
    }

    public static void blockIndividualApplicationsWithoutAgreement(Map<Id, Career_Services_Application__c> id2oldApplication, List<Career_Services_Application__c> newApplications) {
        List<Career_Services_Application__c> applicationsToBlock = new List<Career_Services_Application__c>();
        Map<Id, List<Career_Services_Application__c>> offerId2Applications = new Map<Id, List<Career_Services_Application__c>>();
        Set<Id> existingAgreementOfferIds = new Set<Id>();
        
        for (Career_Services_Application__c application : newApplications) {
            if (application.Status__c == Constants.CAREER_SERVICES_APPLICATION_STATUS_INTERNSHIP_READY_TO_PROCEED
                && application.RecordTypeId == APPLICATION_INDIVIDUAL_INTERNSHIP_RECORD_TYPE_ID
                && Utils.isFieldChanged(application, id2oldApplication, Career_Services_Application__c.Status__c)
            ) {
                if (String.isBlank(application.Career_Services_Offer__c)) {
                    applicationsToBlock.add(application);
                } else if (offerId2Applications.containsKey(application.Career_Services_Offer__c)) {
                    offerId2Applications.get(application.Career_Services_Offer__c).add(application);
                } else {
                    offerId2Applications.put(application.Career_Services_Offer__c, new List<Career_Services_Application__c>{application});
                }
            }
        }

        for (Career_Services_Offer_Contract__c offerContract : [
            SELECT Career_Services_Offer__c
            FROM Career_Services_Offer_Contract__c
            WHERE Career_Services_Offer__c IN :offerId2Applications.keySet()
        ]) {
            existingAgreementOfferIds.add(offerContract.Career_Services_Offer__c);
        }

        for (Id offerId : offerId2Applications.keySet()) {
            if (!existingAgreementOfferIds.contains(offerId)) {
                applicationsToBlock.addAll(offerId2Applications.get(offerId));
            }
        }

        for (Career_Services_Application__c application : applicationsToBlock) {
            application.addError(System.Label.Block_Individual_Applications_Without_Agreement_Error_Message);
        }
    }

}