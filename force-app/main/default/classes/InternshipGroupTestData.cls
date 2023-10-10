@IsTest
public class InternshipGroupTestData {
    public static final String DEFAULT_NAME = 'Internship Group';
    public static Integer count = 0;
    private final Internship_Group__c record;

    public InternshipGroupTestData() {
        record = new Internship_Group__c();
        count++;
        applyDefaults();
    }

    public InternshipGroupTestData(InternshipGroupTestData testData) {
        record = testData.record.clone(false, true, false, false);
        count++;
        applyDefaults();
    }

    public InternshipGroupTestData applyDefaults() {
        return withName(getDefaultName());
    }

    public InternshipGroupTestData copy() {
        return new InternshipGroupTestData(this);
    }

    public Internship_Group__c get() {
        return record;
    }

    public InternshipGroupTestData save() {
        if (record.Id == null) {
            insert record;
        } else {
            update record;
        }
        return this;
    }

    public String getDefaultName() {
        return String.join(new List<String>{DEFAULT_NAME, String.valueOf(count)}, '');
    }

    public InternshipGroupTestData withName(String value) {
        record.Name = value;
        return this;
    }

    public InternshipGroupTestData withAcademicProgram(Id value) {
        record.Academic_Program__c = value;
        return this;
    }

    public InternshipGroupTestData withInternshipIssuance(Id value) {
        record.Internship_Issuance__c = value;
        return this;
    }
}