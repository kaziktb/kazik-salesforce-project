public without sharing class MySwpsJobOfferDetailController {
    @AuraEnabled(Cacheable=true)
    public static Career_Services_Offer__c fetchJobOfferDetails(Id recordId) {
        User studentUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];

        Career_Services_Offer__c jobOffer = [
            SELECT Company__r.Name, Offer_Expiration_Date__c, toLabel(Employment_Type__c), toLabel(Salary__c), Is_Polish_Required__c,
                toLabel(Business_Categories__c), toLabel(Position_Level__c), Workplace__c, toLabel(Workplace_Type__c), Weekly_Working_Hours_Minimum__c,
                Weekly_Working_Hours_Maximum__c, toLabel(Required_Recruitment_Documents__c), GDPR_Clause__c, Company_Description__c,
                Requirements__c, Position_Offer__c, Offer_Title__c, Offer_Origin_URL__c, (
                    SELECT Id
                    FROM Career_Services_Offer_Contracts__r
                    WHERE Status__c = :Constants.CAREER_SERVICES_OFFER_CONTRACT_STATUS_PUBLISHED_API_NAME
                ), (
                    SELECT Id
                    FROM Career_Services_Applications__r
                    WHERE Student__c = :studentUser.ContactId
                )
            FROM Career_Services_Offer__c
            WHERE Id = :recordId
        ];

        return jobOffer;
    }
}