@IsTest
public with sharing class DT_JobOfferTriggerHelperTest {
    private static final String TEST_EMAIL = 'dummy@dummy.dev.org';
    private static final String TEST_JOB_LOCATION = 'Warszawa';
    private static final String TEST_JOB_PLACEMENT_TITLE = 'Test Job Placement Title';

    @TestSetup
    static void prepareData(){
        Id jobPlacementRecordTypeId = DT_Utils.getRecTypeIdByDevName(
            DT_Utils.JOB_OFFER_RECORD_TYPE_DEVELOPER_NAME_JOB_PLACEMENT, 
            DT_Job_Offers__c.getSObjectType().getDescribe().getName()
        );

        List<DT_Job_Offers__c> jobOffers = new List<DT_Job_Offers__c>();
        jobOffers.add(new DT_Job_Offers__c(
            DT_Email__c = TEST_EMAIL,
            DT_Job_Title__c = TEST_JOB_PLACEMENT_TITLE,
            DT_Job_Location__c = TEST_JOB_LOCATION,
            RecordTypeId = jobPlacementRecordTypeId
        ));
        insert jobOffers;
    }

    @IsTest
    private static void sendSummaryEmailAfterJobPlacementAcceptanceTestPolishLanguage() {
        DT_Job_Offers__c jobPlacement = [
            SELECT Id, Name 
            FROM DT_Job_Offers__c 
            WHERE DT_Job_Title__c = :TEST_JOB_PLACEMENT_TITLE 
            LIMIT 1
        ];

        jobPlacement.DT_Confirmed_By_The_Career_Office__c = true;
        jobPlacement.DT_Confirmed_By_The_Employer__c = DT_Utils.JOB_OFFER_CONFIRMED_BY_THE_EMPLOYER_ACCEPTED_VALUE;
        jobPlacement.DT_Offer_Preffered_Language__c = DT_Utils.JOB_OFFER_PREFFERED_LANGUAGE_POLISH;

        Test.startTest();
        update jobPlacement;
        Test.stopTest();

        String fileTitle = jobPlacement.Name + DT_Utils.CONTENT_FILE_EXTENSION_PDF;

        List<ContentDocumentLink> jobPlacementFiles = [
            SELECT Id
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :jobPlacement.Id
                AND ContentDocument.Title = :fileTitle
        ];

        System.assertEquals(1, jobPlacementFiles.size());
    }

    @IsTest
    private static void sendSummaryEmailAfterJobPlacementAcceptanceTestEnglishLanguage() {
        DT_Job_Offers__c jobPlacement = [
            SELECT Id, Name 
            FROM DT_Job_Offers__c 
            WHERE DT_Job_Title__c = :TEST_JOB_PLACEMENT_TITLE 
            LIMIT 1
        ];

        jobPlacement.DT_Confirmed_By_The_Career_Office__c = true;
        jobPlacement.DT_Confirmed_By_The_Employer__c = DT_Utils.JOB_OFFER_CONFIRMED_BY_THE_EMPLOYER_ACCEPTED_VALUE;
        jobPlacement.DT_Offer_Preffered_Language__c = DT_Utils.JOB_OFFER_PREFFERED_LANGUAGE_ENGLISH;

        Test.startTest();
        update jobPlacement;
        Test.stopTest();

        String fileTitle = jobPlacement.Name + DT_Utils.CONTENT_FILE_EXTENSION_PDF;

        List<ContentDocumentLink> jobPlacementFiles = [
            SELECT Id
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :jobPlacement.Id
                AND ContentDocument.Title = :fileTitle
        ];

        System.assertEquals(1, jobPlacementFiles.size());
    }
}