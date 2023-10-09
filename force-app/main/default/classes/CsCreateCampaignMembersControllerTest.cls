@IsTest
public class CsCreateCampaignMembersControllerTest {

    @TestSetup
    static void setup() {
        new CampaignTestData().save();
        new ContactTestData().save();
        new ContactTestData().save();
    }

    @IsTest
    static void queryTest() {
        Id campaignId = [SELECT Id FROM Campaign].Id;
        List<Id> contactIds = new List<Id>();
        
        for (Contact contact : [SELECT Id FROM Contact]) {
            contactIds.add(contact.Id);
        }

        Test.startTest();
        CsCreateCampaignMembersController.createCampaignMembers(campaignId, contactIds);
        Test.stopTest();

        List<CampaignMember> results = [SELECT Id FROM CampaignMember];
        Assert.areEqual(2, results.size(), 'Should return 2 records');
    }

    @IsTest
    static void queryTestErrorCatch() {
        String error;

        Test.startTest();
        try {
            CsCreateCampaignMembersController.createCampaignMembers(null, null);
        } catch (Exception e) {
            error = e.getMessage();
        }
        Test.stopTest();

        Assert.isNotNull(error, 'Error should be thrown');
    }
    
}