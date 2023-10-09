@IsTest
private with sharing class DT_JobOfferApplicationTriggerHandlerTest {

    private static final String JOB_PLACEMENT_RECORD_TITLE = 'Test Offer';
    private static final String CAMPAIGN_NAME = 'Test Campaign';

    @TestSetup
    private static void dataInit(){
        User adminUser = DT_DataFactory.createAdminUser();
        User studentUser;
        DT_Job_Offers__c jobPlacement;
        System.runAs(adminUser){
            studentUser = DT_DataFactory.createStudentUser();
            jobPlacement = createJobPlacement();
            createCampaignSetup(studentUser.ContactId, jobPlacement.Id);
        }
    }

    private static void createCampaignSetup(Id contactId, Id jobPlacementId){
        Campaign c = new Campaign(
            DT_Job_Placement__c = jobPlacementId,
            Status = DT_Utils.CAMPAIGN_STATUS_IN_PROGRESS,
            Name = CAMPAIGN_NAME
        );

        insert c;

        insert new CampaignMember(
            CampaignId = c.Id,
            ContactId = contactId,
            Status = DT_Utils.CAMPAIGN_MEMBER_STATUS_SENT
        );
    }

    private static DT_Job_Offers__c createJobPlacement(){
        Id jobPlacementRecordTypeId = DT_Utils.getRecTypeIdByDevName(
                DT_Utils.JOB_OFFER_RECORD_TYPE_DEVELOPER_NAME_JOB_PLACEMENT, DT_Utils.SOBJ_JOB_OFFER
        );
        return DT_DataFactory.createJobOffers(
            1, true, new DT_Job_Offers__c(
                RecordTypeId = jobPlacementRecordTypeId,
                DT_Status__c = DT_Utils.JOB_OFFER_STATUS_PUBLISHED,
                DT_Job_Title__c = JOB_PLACEMENT_RECORD_TITLE
            )
        ).get(0);
    }

    @IsTest
    private static void updateCampaignMembersDataTest(){
        User studentUser = DT_TestClassUtils.getUserByEmail(DT_DataFactory.USER_STUDENT_EMAIL);
        DT_Job_Offers__c jobPlacement = DT_TestClassUtils.getJobOfferByTitle(JOB_PLACEMENT_RECORD_TITLE);
        Campaign campaign = DT_TestClassUtils.fetchCampaignByName(CAMPAIGN_NAME);
        CampaignMember member = DT_TestClassUtils.fetchCampaignMember(campaign.Id, studentUser.ContactId);
        System.assertEquals(true, member.DT_Date_Of_CV_Application__c == null);

        Test.startTest();
            System.runAs(studentUser){
                insert new DT_Job_Offer_Application__c(
                    DT_Contact__c = studentUser.ContactId,
                    DT_Job_Offer__c = jobPlacement.Id
                );
            }
        Test.stopTest();

        member = DT_TestClassUtils.fetchCampaignMember(campaign.Id, studentUser.ContactId);
        System.assertEquals(true, member.DT_Date_Of_CV_Application__c != null);
        System.assertEquals(true, member.DT_Date_Of_CV_Application__c == Date.today());
    }
}