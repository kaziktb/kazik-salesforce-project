public with sharing class ApprovalProcessTriggerHelper {
    public static void checkActiveProcessDuplication(Map<Id, Approval_Process__c> id2OldApprovalProcesses, List<Approval_Process__c> newApprovalProcesses) {
        Set<String> relatedRecordIds = new Set<String>();

        for (Approval_Process__c approvalProcess : newApprovalProcesses) {
            if (approvalProcess.Status__c == Constants.CAREER_SERVICES_APPROVAL_PROCESS_STATUS_ACTIVE
                && Utils.isFieldChanged(approvalProcess, id2OldApprovalProcesses, Approval_Process__c.Status__c)) {
                relatedRecordIds.add(approvalProcess.Related_Record_Id__c);
            }
        }

        List<Approval_Process__c> activeApprovalProcessesForRelatedRecords = new List<Approval_Process__c>([
            SELECT Related_Record_Id__c FROM Approval_Process__c WHERE Status__c = :Constants.CAREER_SERVICES_APPROVAL_PROCESS_STATUS_ACTIVE AND Related_Record_Id__c IN :relatedRecordIds
        ]);

        Set<String> activeApprovalProcessRelatedRecordId = new Set<String>();

        for (Approval_Process__c activeApprovalProcess : activeApprovalProcessesForRelatedRecords) {
            activeApprovalProcessRelatedRecordId.add(activeApprovalProcess.Related_Record_Id__c);
        }

        for (Approval_Process__c newApprovalProcess : newApprovalProcesses) {
            if (activeApprovalProcessRelatedRecordId.contains(newApprovalProcess.Related_Record_Id__c)) {
                newApprovalProcess.addError(Label.Career_Services_Approval_Process_Active_Dupe_Error);
            } else {
                activeApprovalProcessRelatedRecordId.add(newApprovalProcess.Related_Record_Id__c);
            }
        }
    }
}