@IsTest
public class EducationHistoryTestData {
    public static final String DEFAULT_FIELD_OF_STUDY = 'Test Field Of Study';
    public static Integer count = 0;
    private final hed__Education_History__c record;

    public EducationHistoryTestData() {
        record = new hed__Education_History__c();
        count++;
        applyDefaults();
    }

    public EducationHistoryTestData(EducationHistoryTestData testData) {
        record = testData.record.clone(false, true, false, false);
        count++;
        applyDefaults();
    }

    public EducationHistoryTestData applyDefaults() {
        return withFieldOfStudy(DEFAULT_FIELD_OF_STUDY);
    }

    public EducationHistoryTestData copy() {
        return new EducationHistoryTestData(this);
    }

    public hed__Education_History__c get() {
        return record;
    }

    public EducationHistoryTestData save() {
        if (record.Id == null) {
            insert record;
        } else {
            update record;
        }
        return this;
    }

    public EducationHistoryTestData withContact(Id value) {
        record.hed__Contact__c = value;
        return this;
    }

    public EducationHistoryTestData withFieldOfStudy(String value) {
        record.DT_Field_of_study__c = value;
        return this;
    }

    public EducationHistoryTestData withStatus(String status) {
        record.hed__Status__c = status;
        return this;
    }
}