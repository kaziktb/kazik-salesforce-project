@IsTest
public class ApprovalProcessEntryTestData {
    public static Integer count = 0;
    private final Approval_Process_Entry__c record;

    public ApprovalProcessEntryTestData() {
        record = new Approval_Process_Entry__c();
        count++;
    }

    public ApprovalProcessEntryTestData(ApprovalProcessEntryTestData testData) {
        record = testData.record.clone(false, true, false, false);
        count++;
    }

    public ApprovalProcessEntryTestData copy() {
        return new ApprovalProcessEntryTestData(this);
    }

    public Approval_Process_Entry__c get() {
        return record;
    }

    public ApprovalProcessEntryTestData save() {
        if (record.Id == null) {
            insert record;
        } else {
            update record;
        }

        return this;
    }

    public ApprovalProcessEntryTestData withRecordTypeId(Id value) {
        record.RecordTypeId = value;
        return this;
    }

    public ApprovalProcessEntryTestData withApprovalProcess(Id value) {
        record.Approval_Process__c = value;
        return this;
    }

    public ApprovalProcessEntryTestData withParentEntry(Id value) {
        record.Parent_Entry__c = value;
        return this;
    }

    public ApprovalProcessEntryTestData withStage(String value) {
        record.Stage__c = value;
        return this;
    }

    public ApprovalProcessEntryTestData withValue(String value) {
        record.Value__c = value;
        return this;
    }
}