@IsTest
private class CsApprovalProcessHelperTest {
    private static final String RECIPIENT_EMAIL = 'recipient@test.test';

    @TestSetup
    static void setup() {
        Career_Services_Offer__c offer = CsOfferTestDataFactory.createOffer(true);
        Id individualApprovalProcessRecordTypeId = Utils.getRecordTypeIdByDevName(
            Approval_Process__c.getSObjectType(),
            Constants.CAREER_SERVICES_APPROVAL_PROCESS_RECORD_TYPE_INDIVIDUAL_APPLICATION
        );
        ApprovalProcessTestDataFactory.createActiveApprovalProcessForRecord(offer.Id, individualApprovalProcessRecordTypeId, true);
        CsApplicationTestDataFactory.createApplicationWithRecordType(Constants.CAREER_SERVICES_APPLICATION_RT_INDIVIDUAL_INTERNSHIP, true);
    }

    @IsTest
    static void retrieveCurrentStageData() {
        CsApprovalProcessHelper.RECORD_TYPE_NAME_2_IMPLEMENTOR_CLASS_NAME = new Map<String, String>{
            Constants.CAREER_SERVICES_APPROVAL_PROCESS_RECORD_TYPE_INDIVIDUAL_APPLICATION => CsApprovalProcessTestLogic.class.getName()
        };
        Approval_Process__c approvalProcess = [SELECT RecordType.DeveloperName FROM Approval_Process__c LIMIT 1];

        Test.startTest();
        CsApprovalProcessStageBaseData testStageData = CsApprovalProcessHelper.retrieveCurrentStageData(Constants.CAREER_SERVICES_APPROVAL_PROCESS_RECORD_TYPE_INDIVIDUAL_APPLICATION, approvalProcess.Id);
        Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(testStageData.jsonData);
        Test.stopTest();

        Assert.areEqual(CsApprovalProcessTestLogic.TEST_STAGE_DATA_TEST_INTEGER_VALUE, data.get(CsApprovalProcessTestLogic.TEST_STAGE_DATA_TEST_INTEGER_FIELD_NAME));
        Assert.isTrue(testStageData.canPerformAction);
        Assert.areEqual(approvalProcess.RecordType.DeveloperName, Constants.CAREER_SERVICES_APPROVAL_PROCESS_RECORD_TYPE_INDIVIDUAL_APPLICATION);
    }

    @IsTest
    static void executeCurrentStage() {
        CsApprovalProcessHelper.RECORD_TYPE_NAME_2_IMPLEMENTOR_CLASS_NAME = new Map<String, String>{
            Constants.CAREER_SERVICES_APPROVAL_PROCESS_RECORD_TYPE_INDIVIDUAL_APPLICATION => CsApprovalProcessTestLogic.class.getName()
        };
        Approval_Process__c preExecutionApprovalProcess = [SELECT Status__c, RecordType.DeveloperName FROM Approval_Process__c LIMIT 1];

        Test.startTest();
        CsApprovalProcessStageExecutionResult executionResult = CsApprovalProcessHelper.executeCurrentStage(Constants.CAREER_SERVICES_APPROVAL_PROCESS_RECORD_TYPE_INDIVIDUAL_APPLICATION, preExecutionApprovalProcess.Id, null);
        Test.stopTest();

        Approval_Process__c postExecutionApprovalProcess = [SELECT Status__c, RecordType.DeveloperName FROM Approval_Process__c WHERE Id = :preExecutionApprovalProcess.Id];

        Assert.isTrue(executionResult.isSuccess);
        Assert.isTrue(executionResult.errors.isEmpty());
        Assert.areNotEqual(preExecutionApprovalProcess.Status__c, postExecutionApprovalProcess.Status__c);
        Assert.areEqual(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STATUS_FINISHED, postExecutionApprovalProcess.Status__c);
    }

    @IsTest
    static void retrieveCurrentStageDataNotAllowed() {
        CsApprovalProcessHelper.RECORD_TYPE_NAME_2_IMPLEMENTOR_CLASS_NAME = new Map<String, String>{
            Constants.CAREER_SERVICES_APPROVAL_PROCESS_RECORD_TYPE_INDIVIDUAL_APPLICATION => CsApprovalProcessTestLogic.class.getName()
        };

        Approval_Process__c approvalProcess = [SELECT RecordType.DeveloperName FROM Approval_Process__c LIMIT 1];
        approvalProcess.Stage__c = Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_SUPERVISOR_ACCEPTANCE;

        update approvalProcess;

        Test.startTest();
        CsApprovalProcessStageBaseData testStageData = CsApprovalProcessHelper.retrieveCurrentStageData(Constants.CAREER_SERVICES_APPROVAL_PROCESS_RECORD_TYPE_INDIVIDUAL_APPLICATION, approvalProcess.Id);
        Test.stopTest();

        Assert.isFalse(testStageData.canPerformAction);
    }

    @IsTest
    static void abandonApprovalProcess() {
        Approval_Process__c approvalProcess = [SELECT Id FROM Approval_Process__c LIMIT 1];
        Career_Services_Offer__c offer = [SELECT Id FROM Career_Services_Offer__c];

        Test.startTest();
        CsApprovalProcessHelper.abandonApprovalProcess(offer.Id);
        Test.stopTest();

        Approval_Process__c assertApprovalProcess = [SELECT Status__c, Stage__c FROM Approval_Process__c LIMIT 1];
        Assert.areEqual(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STATUS_ABANDONED, assertApprovalProcess.Status__c);

        Approval_Process_Entry__c assertEntry = [SELECT Value__c, Stage__c FROM Approval_Process_Entry__c WHERE Approval_Process__c = :approvalProcess.Id AND RecordType.DeveloperName = :Constants.CAREER_SERVICES_APPROVAL_PROCESS_ENTRY_DECISION_RECORD_TYPE];
        Assert.areEqual('Abandon', assertEntry.Value__c);
        Assert.areEqual(assertApprovalProcess.Stage__c, assertEntry.Stage__c);
    }

    @IsTest
    static void sendReminder() {
        Approval_Process__c approvalProcess = [SELECT Stage__c FROM Approval_Process__c LIMIT 1];
        Career_Services_Offer__c offer = [SELECT Id FROM Career_Services_Offer__c];

        Test.startTest();
        CsApprovalProcessHelper.sendReminder(offer.Id, RECIPIENT_EMAIL);
        Test.stopTest();

        Approval_Process_Entry__c assertEntry = [SELECT Value__c, Stage__c FROM Approval_Process_Entry__c WHERE Approval_Process__c = :approvalProcess.Id AND RecordType.DeveloperName = :Constants.CAREER_SERVICES_APPROVAL_PROCESS_ENTRY_REMINDER_RECORD_TYPE];
        Assert.areEqual(RECIPIENT_EMAIL, assertEntry.Value__c);
        Assert.areEqual(approvalProcess.Stage__c, assertEntry.Stage__c);
    }

    @IsTest
    static void updateRequestingRecordOwnershipOffer() {
        Career_Services_Offer__c offer = [SELECT Id FROM Career_Services_Offer__c];

        Test.startTest();
        CsApprovalProcessHelper.updateRequestingRecordOwnership(offer.Id);
        Test.stopTest();

        Career_Services_Offer__c assertOffer = [SELECT OwnerId FROM Career_Services_Offer__c];
        Assert.areEqual(UserInfo.getUserId(), assertOffer.OwnerId);
    }

    @IsTest
    static void updateRequestingRecordOwnershipApplication() {
        Career_Services_Application__c application = [SELECT Id FROM Career_Services_Application__c];

        Test.startTest();
        CsApprovalProcessHelper.updateRequestingRecordOwnership(application.Id);
        Test.stopTest();

        User user = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        Career_Services_Application__c assertApplication = [SELECT Career_Services_Employee__c FROM Career_Services_Application__c];
        Assert.areEqual(user.ContactId, assertApplication.Career_Services_Employee__c);
    }
    
}