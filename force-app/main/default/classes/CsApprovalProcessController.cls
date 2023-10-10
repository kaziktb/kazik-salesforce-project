public with sharing class CsApprovalProcessController {
    @AuraEnabled
    public static ApprovalProcessData retrieveCurrentStageData(Id requestingRecordId) {

        Approval_Process__c[] approvalProcesses = [
            SELECT
                RecordType.DeveloperName,
                Status__c,
                Stage__c
            FROM Approval_Process__c
            WHERE Status__c = :Constants.CAREER_SERVICES_APPROVAL_PROCESS_STATUS_ACTIVE
                AND Related_Record_Id__c = :requestingRecordId
        ];

        if (approvalProcesses.isEmpty()) {
            return new ApprovalProcessData();
        }

        Approval_Process__c approvalProcess = approvalProcesses[0];

        return prepareStageData(approvalProcess, approvalProcess.RecordType.DeveloperName);
    }

    @AuraEnabled
    public static ApprovalProcessData initApprovalProcess(Id requestingRecordId, String recordTypeDeveloperName) {
        Approval_Process__c approvalProcess = new Approval_Process__c(
            Stage__c = Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_CAREER_SERVICES_ACCEPTANCE,
            Status__c = Constants.CAREER_SERVICES_APPROVAL_PROCESS_STATUS_ACTIVE,
            Related_Record_Id__c = requestingRecordId,
            RecordTypeId = Utils.getRecordTypeIdByDevName(Approval_Process__c.getSObjectType(), recordTypeDeveloperName)
        );

        insert approvalProcess;

        CsApprovalProcessHelper.updateRequestingRecordOwnership(requestingRecordId);

        return prepareStageData(approvalProcess, recordTypeDeveloperName);
    }

    @AuraEnabled
    public static void executeCurrentStage(Id approvalProcessId, String recordTypeDeveloperName, String jsonData) {
        CsApprovalProcessHelper.executeCurrentStage(recordTypeDeveloperName, approvalProcessId, jsonData);
    }

    @AuraEnabled
    public static void abandonApprovalProcess(Id requestingRecordId) {
        CsApprovalProcessHelper.abandonApprovalProcess(requestingRecordId);
    }

    @AuraEnabled
    public static void sendReminder(Id requestingRecordId, String recipientEmail) {
        CsApprovalProcessHelper.sendReminder(requestingRecordId, recipientEmail);
    }

    private static ApprovalProcessData prepareStageData(Approval_Process__c approvalProcess, String recordTypeDeveloperName) {
        ApprovalProcessData data = new ApprovalProcessData();

        data.isActive = true;
        data.approvalProcessId = approvalProcess.Id;
        data.status = approvalProcess.Status__c;
        data.stage = approvalProcess.Stage__c;
        data.stageData = CsApprovalProcessHelper.retrieveCurrentStageData(recordTypeDeveloperName, approvalProcess.Id);

        return data;
    }

    @TestVisible
    private class ApprovalProcessData {
        @AuraEnabled
        public Boolean isActive = false;
        @AuraEnabled
        public Id approvalProcessId;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String stage;
        @AuraEnabled
        public CsApprovalProcessStageBaseData stageData;
    }
}