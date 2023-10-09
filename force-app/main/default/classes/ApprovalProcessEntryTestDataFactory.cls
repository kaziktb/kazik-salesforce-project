@IsTest
public class ApprovalProcessEntryTestDataFactory {
    public static Approval_Process_Entry__c createReminderEntry(Id approvalProcessId, String stage, String value, Boolean withInsert) {
        ApprovalProcessEntryTestData testData = new ApprovalProcessEntryTestData()
            .withApprovalProcess(approvalProcessId)
            .withRecordTypeId(Utils.getRecordTypeIdByDevName(Approval_Process_Entry__c.getSObjectType(), Constants.CAREER_SERVICES_APPROVAL_PROCESS_ENTRY_REMINDER_RECORD_TYPE))
            .withStage(stage)
            .withValue(value);

        return withInsert ? testData.save().get() : testData.get();
    }
}