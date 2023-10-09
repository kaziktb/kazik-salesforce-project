public with sharing class ApprovalProcessTestDataFactory {
    public static Approval_Process__c createActiveApprovalProcessForRecord(String relatedRecordId, Id recordTypeId, Boolean withInsert) {
        return withInsert
            ? new ApprovalProcessTestData()
                .withRelatedRecordId(relatedRecordId)
                .withRecordType(recordTypeId)
                .withStatus(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STATUS_ACTIVE)
                .withStage(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_CAREER_SERVICES_ACCEPTANCE)
                .save()
                .get()
            : new ApprovalProcessTestData()
                .withRelatedRecordId(relatedRecordId)
                .withRecordType(recordTypeId)
                .withStatus(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STATUS_ACTIVE)
                .withStage(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_CAREER_SERVICES_ACCEPTANCE)
                .get();
    }

    public static Approval_Process__c createFinishedApprovalProcessForRecord(String relatedRecordId, Id recordTypeId, Boolean withInsert) {
        return withInsert
            ? new ApprovalProcessTestData()
                .withRelatedRecordId(relatedRecordId)
                .withRecordType(recordTypeId)
                .withStatus(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STATUS_FINISHED)
                .withStage(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_CAREER_SERVICES_ACCEPTANCE)
                .save()
                .get()
            : new ApprovalProcessTestData()
                .withRelatedRecordId(relatedRecordId)
                .withRecordType(recordTypeId)
                .withStatus(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STATUS_FINISHED)
                .withStage(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_CAREER_SERVICES_ACCEPTANCE)
                .get();
    }
}