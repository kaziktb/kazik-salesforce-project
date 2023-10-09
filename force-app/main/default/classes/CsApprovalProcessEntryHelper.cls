public with sharing class CsApprovalProcessEntryHelper {

    public static Approval_Process_Entry__c createDecisionEntry(Id approvalProcessId, String stage, String value, Boolean withInsert) {
        return createEntryCore(
            approvalProcessId,
            stage,
            Constants.CAREER_SERVICES_APPROVAL_PROCESS_ENTRY_DECISION_RECORD_TYPE,
            value,
            null,
            withInsert);
    }

    public static Approval_Process_Entry__c createCommentEntry(Id approvalProcessId, String stage, String value, Id parentEntry, Boolean withInsert) {
        return createEntryCore(
            approvalProcessId,
            stage,
            Constants.CAREER_SERVICES_APPROVAL_PROCESS_ENTRY_COMMENT_RECORD_TYPE,
            value,
            parentEntry,
            withInsert);
    }

    public static Approval_Process_Entry__c createReminderEntry(Id approvalProcessId, String stage, String value, Boolean withInsert) {
        return createEntryCore(
            approvalProcessId,
            stage,
            Constants.CAREER_SERVICES_APPROVAL_PROCESS_ENTRY_REMINDER_RECORD_TYPE,
            value,
            null,
            withInsert);
    }

    private static Approval_Process_Entry__c createEntryCore(Id approvalProcessId, String stage, String recordTypeDevName, String value, Id parentEntry, Boolean withInsert) {
        Approval_Process_Entry__c entry = new Approval_Process_Entry__c(
            Approval_Process__c = approvalProcessId,
            Stage__c = stage,
            Value__c = value,
            Parent_Entry__c = parentEntry);

        entry.RecordTypeId = Utils.getRecordTypeIdByDevName(entry, recordTypeDevName);

        if (withInsert) {
            insert entry;
        }

        return entry;
    }

}