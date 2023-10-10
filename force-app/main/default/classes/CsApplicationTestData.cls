@IsTest
public class CsApplicationTestData {
    public static Integer count = 0;
    private final Career_Services_Application__c record;

    public CsApplicationTestData() {
        record = new Career_Services_Application__c();
        count++;
        applyDefaults();
    }

    public CsApplicationTestData(CsApplicationTestData testData) {
        record = testData.record.clone(false, true, false, false);
        count++;
        applyDefaults();
    }

    public CsApplicationTestData applyDefaults() {
        return this;
    }

    public CsApplicationTestData copy() {
        return new CsApplicationTestData(this);
    }

    public Career_Services_Application__c get() {
        return record;
    }

    public CsApplicationTestData save() {
        if (record.Id == null) {
            insert record;
        } else {
            update record;
        }
        return this;
    }

    public CsApplicationTestData withRecordType(Id value) {
        record.RecordTypeId = value;
        return this;
    }

    public CsApplicationTestData withOffer(Id value) {
        record.Career_Services_Offer__c = value;
        return this;
    }

    public CsApplicationTestData withStatus(String value) {
        record.Status__c = value;
        return this;
    }

    public CsApplicationTestData withStudent(Id value) {
        record.Student__c = value;
        return this;
    }

    public CsApplicationTestData withProgramEnrollment(Id value) {
        record.Program_Enrollment__c = value;
        return this;
    }

    public CsApplicationTestData withPracticeAtWorkplace() {
        record.Is_Practice_At_Workplace__c = true;
        return this;
    }

    public CsApplicationTestData withCommencementDate(Date value) {
        record.Internship_Commencement_Date__c = value;
        return this;
    }

    public CsApplicationTestData withCompletionDate(Date value) {
        record.Internship_Completion_Date__c = value;
        return this;
    }

    public CsApplicationTestData asObligatory() {
        record.Is_Obligatory__c = true;
        return this;
    }

    public CsApplicationTestData withOwner(Id value) {
        record.OwnerId = value;
        return this;
    }
}