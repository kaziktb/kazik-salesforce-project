public with sharing class ApprovalProcessTestData {
    public static Integer count = 0;
    private final Approval_Process__c record;

    public ApprovalProcessTestData() {
        record = new Approval_Process__c();
        count++;
    }

    public ApprovalProcessTestData(ApprovalProcessTestData testData) {
        record = testData.record.clone(false, true, false, false);
        count++;
    }

    public ApprovalProcessTestData copy() {
        return new ApprovalProcessTestData(this);
    }

    public Approval_Process__c get() {
        return record;
    }

    public ApprovalProcessTestData save() {
        if (record.Id == null) {
            insert record;
        } else {
            update record;
        }

        return this;
    }

    public ApprovalProcessTestData withRelatedRecordId(String value) {
        record.Related_Record_Id__c = value;
        return this;
    }

    public ApprovalProcessTestData withRecordType(Id value) {
        record.RecordTypeId = value;
        return this;
    }

    public ApprovalProcessTestData withStatus(String value) {
        record.Status__c = value;
        return this;
    }

    public ApprovalProcessTestData withStage(String value) {
        record.Stage__c = value;
        return this;
    }
}