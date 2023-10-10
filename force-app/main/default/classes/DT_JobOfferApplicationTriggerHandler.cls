/**
 *  Without sharing decorator is required to handle issue caused by
 *  missing Student sharing access to the campaign and campaign member objects
 **/

public without sharing class DT_JobOfferApplicationTriggerHandler {

    public static void updateCampaignMembersData(Map<Id, DT_Job_Offer_Application__c> ids2newApplications) {
        Map<Id, Set<Id>> jobOfferIds2SetOfRelatedContactIds = new Map<Id, Set<Id>>();
        Set<Id> allRelatedContacts = new Set<Id>();
        List<DT_Job_Offer_Application__c> jobPlacementApplications = fetchJobOfferApplicationsForJobPlacement(ids2newApplications.keySet());
        if (jobPlacementApplications != null && !jobPlacementApplications.isEmpty()) {
            for (DT_Job_Offer_Application__c application : jobPlacementApplications) {
                if (jobOfferIds2SetOfRelatedContactIds.containsKey(application.DT_Job_Offer__c)) {
                    jobOfferIds2SetOfRelatedContactIds.get(application.DT_Job_Offer__c).add(application.DT_Contact__c);
                } else {
                    jobOfferIds2SetOfRelatedContactIds.put(application.DT_Job_Offer__c, new Set<Id>{
                            application.DT_Contact__c
                    });
                }
                allRelatedContacts.add(application.DT_Contact__c);
            }

            List<Campaign> campaigns = fetchCampaignWithMembers(jobOfferIds2SetOfRelatedContactIds.keySet(), allRelatedContacts);

            List<CampaignMember> campaignMembersToUpdate = new List<CampaignMember>();
            for (Campaign campaign : campaigns) {
                for (CampaignMember member : campaign.CampaignMembers) {
                    member.DT_Date_Of_CV_Application__c = Date.today();
                    campaignMembersToUpdate.add(member);
                }
            }

            if (!campaignMembersToUpdate.isEmpty()) {
                update campaignMembersToUpdate;
            }
        }
    }

    public static List<Campaign> fetchCampaignWithMembers(Set<Id> jobOfferIds, Set<Id> allRelatedContacts) {
        return [
            SELECT Id, Name, Status, (
                SELECT Id, DT_Date_Of_CV_Application__c
                FROM CampaignMembers
                WHERE ContactId IN :allRelatedContacts
            )
            FROM Campaign
            WHERE DT_Job_Placement__c IN :jobOfferIds
        ];
    }

    public static List<DT_Job_Offer_Application__c> fetchJobOfferApplicationsForJobPlacement(Set<Id> newApplicationIds) {
        return [
            SELECT Id, DT_Contact__c, DT_Job_Offer__c, DT_Job_Offer__r.RecordType.Name
            FROM DT_Job_Offer_Application__c
            WHERE DT_Job_Offer__r.RecordType.DeveloperName = :DT_Utils.JOB_OFFER_RECORD_TYPE_DEVELOPER_NAME_JOB_PLACEMENT
                AND Id IN :newApplicationIds
        ];
    }
}