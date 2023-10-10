public with sharing class MySwpsInstitutionalOfferDetailCtrl {

    @AuraEnabled(Cacheable=true)
    public static InternshipOfferWrapper fetchInternshipOfferDetails(Id recordId) {
        Id studentContactId = MySwpsUtils.fetchCustomerUserContactIdOrThrow(UserInfo.getUserId());
        String cvKnowledgeBaseArticleNumber = MySWPS_Settings__c.getInstance().CV_Knowledge_Base_Article_Number__c;
        Boolean doesOfferMatchRequirements = MySwpsUtils.checkInternshipOfferAssignmentsMatch(recordId);
        return new InternshipOfferWrapper([
            SELECT
                Offer_Title__c,
                Company__r.Name,
                Internship_Period_From__c,
                Internship_Period_To__c,
                Workplace__c,
                toLabel(Workplace_Type__c),
                toLabel(Business_Categories__c),
                toLabel(Salary__c),
                Is_Polish_Required__c,
                toLabel(Required_Recruitment_Documents__c),
                GDPR_Clause__c,
                Company_Description__c,
                Description_Of_Completed_Tasks__c,
                Requirements__c,
                Offer_Expiration_Date__c, (
                    SELECT Id FROM Career_Services_Applications__r WHERE Student__c = :studentContactId
                )
            FROM Career_Services_Offer__c WHERE Id = :recordId
        ], cvKnowledgeBaseArticleNumber, doesOfferMatchRequirements);
    }

    public class InternshipOfferWrapper {
        @AuraEnabled
        public Career_Services_Offer__c internshipOffer;
        @AuraEnabled
        public Id applicationId;
        @AuraEnabled
        public String cvKnowledgeBaseArticleNumber;
        @AuraEnabled
        public Boolean doesOfferMatchRequirements;

        public InternshipOfferWrapper(Career_Services_Offer__c offer, String cvArticleNumber, Boolean doesOfferMatchRequirements) {
            this.internshipOffer = offer;
            this.doesOfferMatchRequirements = doesOfferMatchRequirements;
            this.cvKnowledgeBaseArticleNumber = cvArticleNumber;
            if (offer.Career_Services_Applications__r.isEmpty()) {
                return;
            }

            applicationId = offer.Career_Services_Applications__r[0].Id;
        }
    }
}