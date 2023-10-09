public with sharing class MySwpsCsOfferDetailController {
    private static final Id individualInternshipId = Utils.getRecordTypeIdByDevName(Career_Services_Offer__c.getSObjectType(), Constants.CAREER_SERVICES_OFFER_RT_INDIVIDUAL_INTERNSHIP);
    private static final Id institutionalInternshipId = Utils.getRecordTypeIdByDevName(Career_Services_Offer__c.getSObjectType(), Constants.CAREER_SERVICES_OFFER_RT_INSTITUTIONAL_INTERNSHIP);
    private static final Id jobOfferId = Utils.getRecordTypeIdByDevName(Career_Services_Offer__c.getSObjectType(), Constants.CAREER_SERVICES_OFFER_RT_JOB_OFFER);
    @AuraEnabled(Cacheable=true)
    public static RecordTypesWrapper fetchRecordTypes(Id recordId) {
        if (String.isBlank(recordId)) {
            return null;
        }

        Career_Services_Offer__c offer = [SELECT RecordTypeId FROM Career_Services_Offer__c WHERE Id = :recordId];

        RecordTypesWrapper wrapper = new RecordTypesWrapper(offer);

        return wrapper;
    }

    public class RecordTypesWrapper {
        @AuraEnabled
        public Boolean isIndividualInternship {get; set;}
        @AuraEnabled
        public Boolean isInstitutionalInternship {get; set;}
        @AuraEnabled
        public Boolean isJobOffer {get; set;}

        public RecordTypesWrapper(Career_Services_Offer__c offer) {
            isIndividualInternship = offer.RecordTypeId == individualInternshipId;
            isInstitutionalInternship = offer.RecordTypeId == institutionalInternshipId;
            isJobOffer = offer.RecordTypeId == jobOfferId;
        }
    }
}