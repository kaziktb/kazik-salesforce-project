@IsTest
public class InternshipSupervisorTestData {

    public static final String DEFAULT_NAME = 'Test InternshipSupervisor';
    public static Integer count = 0;
    private final Internship_Supervisor__c record;

    public InternshipSupervisorTestData() {
        record = new Internship_Supervisor__c();
        count++;
        applyDefaults();
    }

    public InternshipSupervisorTestData(InternshipSupervisorTestData testData) {
        record = testData.record.clone(false, true, false, false);
        count++;
        applyDefaults();
    }

    public InternshipSupervisorTestData applyDefaults() {
        return withName(getDefaultName());
    }

    public InternshipSupervisorTestData copy() {
        return new InternshipSupervisorTestData(this);
    }

    public Internship_Supervisor__c get() {
        return record;
    }

    public InternshipSupervisorTestData save() {
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

    public InternshipSupervisorTestData withName(String value) {
        record.Name = value;
        return this;
    }

    public InternshipSupervisorTestData withContact(Id value) {
        record.Contact__c = value;
        return this;
    }

    public InternshipSupervisorTestData withUser(Id value) {
        record.User__c = value;
        return this;
    }

    public InternshipSupervisorTestData withType(String value) {
        record.Type__c = value;
        return this;
    }

}