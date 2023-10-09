public without sharing class MySwpsJobPlacementApplicationModalCtrl {
    @AuraEnabled
    public static Id createJobPlacementApplication(
        Id jobPlacementId,
        Id jobPlacementContractId,
        JobPlacementApplicationConsentsWrapper consentsWrapper
    ) {
        Id studentUserId = UserInfo.getUserId();
        User studentUser = [SELECT ContactId FROM User WHERE Id = :studentUserId];

        Id jobPlacementApplicationRecordTypeId = Utils.getRecordTypeIdByDevName(
            Career_Services_Application__c.getSObjectType(),
            Constants.CAREER_SERVICES_APPLICATION_RT_JOB_PLACEMENT_APPLICATION
        );

        Career_Services_Offer_Contract__c careerServicesOfferContract = [
            SELECT Campaign__c
            FROM Career_Services_Offer_Contract__c
            WHERE Id = :jobPlacementContractId
        ];

        Career_Services_Application__c jobPlacementApplication = new Career_Services_Application__c(
            Career_Services_Offer__c = jobPlacementId,
            Career_Services_Offer_Contract__c = jobPlacementContractId,
            RecordTypeId = jobPlacementApplicationRecordTypeId,
            Status__c = Constants.CAREER_SERVICES_APPLICATION_STATUS_NEW_APPLICATION,
            Student__c = studentUser.ContactId
        );

        insert jobPlacementApplication;

        MySwpsConsentCreator.createConsentsForContact(
            new Set<Id>(consentsWrapper.checkedConsentIds),
            consentsWrapper.userDetails,
            consentsWrapper.formUrl,
            studentUser.ContactId
        );

        if (String.isBlank(careerServicesOfferContract.Campaign__c)) {
            return jobPlacementApplication.Id;
        }

        List<CampaignMember> campaignMembers = [
            SELECT Id
            FROM CampaignMember
            WHERE ContactId = :studentUser.ContactId
                AND CampaignId = :careerServicesOfferContract.Campaign__c
                AND Status != :Constants.CAMPAIGN_MEMBER_STATUS_RESPONDED_API_NAME
        ];

        if (campaignMembers.isEmpty()) {
            return jobPlacementApplication.Id;
        }

        for (CampaignMember campaignMember : campaignMembers) {
            campaignMember.Status = Constants.CAMPAIGN_MEMBER_STATUS_RESPONDED_API_NAME;
        }

        update campaignMembers;

        return jobPlacementApplication.Id;
    }

    public class JobPlacementApplicationConsentsWrapper {
        @AuraEnabled
        public List<Id> checkedConsentIds {get; set;}
        @AuraEnabled
        public String formUrl {get; set;}
        @AuraEnabled
        public String userDetails {get; set;}
    }
}