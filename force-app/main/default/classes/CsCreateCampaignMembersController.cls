public without sharing class CsCreateCampaignMembersController {
    
    @AuraEnabled
    public static void createCampaignMembers(String campaignId, List<String> contactIds) {
        try {
            Set<Id> existingMembersContactIds = new Set<Id>();
            List<CampaignMember> campaignMembers = new List<CampaignMember>();

            for (CampaignMember campaignMember : [SELECT ContactId FROM CampaignMember WHERE CampaignId = :campaignId]) {
                existingMembersContactIds.add(campaignMember.ContactId);
            }

            for (String Id : contactIds) {
                if (!existingMembersContactIds.contains(Id)) {
                    campaignMembers.add(new CampaignMember(CampaignId = campaignId, ContactId = Id));
                }
            }

            insert campaignMembers;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}