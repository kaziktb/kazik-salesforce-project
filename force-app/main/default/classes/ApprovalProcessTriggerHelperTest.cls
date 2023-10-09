@IsTest
public with sharing class ApprovalProcessTriggerHelperTest {

    @TestSetup
    public static void setup() {
        Career_Services_Offer__c offer = CsOfferTestDataFactory.createInstitutionalInternshipOffer(true);
        Id institutionalInternshipApprovalProcessRecordTypeId = Utils.getRecordTypeIdByDevName(
            Approval_Process__c.getSObjectType(),
            Constants.CAREER_SERVICES_APPROVAL_PROCESS_RECORD_TYPE_INTERNSHIP_OFFER
        );
        ApprovalProcessTestDataFactory.createActiveApprovalProcessForRecord(offer.Id, institutionalInternshipApprovalProcessRecordTypeId, true);
    }

    @IsTest
    public static void validateActiveApprovalProcessDuplicationOnInsert() {
        Career_Services_Offer__c offer = [SELECT Id FROM Career_Services_Offer__c LIMIT 1];
        Id institutionalInternshipApprovalProcessRecordTypeId = Utils.getRecordTypeIdByDevName(
            Approval_Process__c.getSObjectType(),
            Constants.CAREER_SERVICES_APPROVAL_PROCESS_RECORD_TYPE_INTERNSHIP_OFFER
        );

        Approval_Process__c approvalProcess = ApprovalProcessTestDataFactory.createActiveApprovalProcessForRecord(offer.Id, institutionalInternshipApprovalProcessRecordTypeId, false);

        Test.startTest();
        Database.SaveResult result = Database.insert(approvalProcess, false);
        Test.stopTest();

        Assert.isFalse(result.success);
        Assert.isFalse(result.errors.isEmpty());
        Assert.areEqual(Label.Career_Services_Approval_Process_Active_Dupe_Error, result.errors[0].message);
    }

    @IsTest
    public static void validateActiveApprovalProcessDuplicationOnUpdate() {
        Career_Services_Offer__c offer = [SELECT Id FROM Career_Services_Offer__c LIMIT 1];
        Id institutionalInternshipApprovalProcessRecordTypeId = Utils.getRecordTypeIdByDevName(
            Approval_Process__c.getSObjectType(),
            Constants.CAREER_SERVICES_APPROVAL_PROCESS_RECORD_TYPE_INTERNSHIP_OFFER
        );

        Approval_Process__c approvalProcess = ApprovalProcessTestDataFactory.createFinishedApprovalProcessForRecord(offer.Id, institutionalInternshipApprovalProcessRecordTypeId, true);
        approvalProcess.Status__c = Constants.CAREER_SERVICES_APPROVAL_PROCESS_STATUS_ACTIVE;

        Test.startTest();
        Database.SaveResult result = Database.update(approvalProcess, false);
        Test.stopTest();

        Assert.isFalse(result.success);
        Assert.isFalse(result.errors.isEmpty());
        Assert.areEqual(Label.Career_Services_Approval_Process_Active_Dupe_Error, result.errors[0].message);
    }

    @IsTest
    public static void validateActiveApprovalProcessDuplicationOnBatchInsert() {
        Career_Services_Offer__c offer = CsOfferTestDataFactory.createInstitutionalInternshipOffer(true);
        Id institutionalInternshipApprovalProcessRecordTypeId = Utils.getRecordTypeIdByDevName(
            Approval_Process__c.getSObjectType(),
            Constants.CAREER_SERVICES_APPROVAL_PROCESS_RECORD_TYPE_INTERNSHIP_OFFER
        );

        List<Approval_Process__c> approvalProcesses = new List<Approval_Process__c>{
            ApprovalProcessTestDataFactory.createActiveApprovalProcessForRecord(offer.Id, institutionalInternshipApprovalProcessRecordTypeId, false),
            ApprovalProcessTestDataFactory.createActiveApprovalProcessForRecord(offer.Id, institutionalInternshipApprovalProcessRecordTypeId, false),
            ApprovalProcessTestDataFactory.createActiveApprovalProcessForRecord(offer.Id, institutionalInternshipApprovalProcessRecordTypeId, false)
        };

        Test.startTest();
        List<Database.SaveResult> results = Database.insert(approvalProcesses, false);
        Test.stopTest();

        Assert.isFalse(results.isEmpty());
        Assert.isTrue(results[0].success);

        for (Integer i = 1; i < results.size(); i++) {
            Database.SaveResult result = results[i];

            Assert.isFalse(result.errors.isEmpty());
            Assert.areEqual(Label.Career_Services_Approval_Process_Active_Dupe_Error, result.errors[0].message);
        }
    }

}