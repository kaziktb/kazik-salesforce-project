@IsTest
public class InternshipIssuanceTestData {
    public static final String DEFAULT_NAME = 'Internship Issuance';
    public static Integer count = 0;
    private final Internship_Issuance__c record;

    public InternshipIssuanceTestData() {
        record = new Internship_Issuance__c();
        count++;
        applyDefaults();
    }

    public InternshipIssuanceTestData(InternshipIssuanceTestData testData) {
        record = testData.record.clone(false, true, false, false);
        count++;
        applyDefaults();
    }

    public InternshipIssuanceTestData applyDefaults() {
        return withName(getDefaultName());
    }

    public InternshipIssuanceTestData copy() {
        return new InternshipIssuanceTestData(this);
    }

    public Internship_Issuance__c get() {
        return record;
    }

    public InternshipIssuanceTestData save() {
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

    public InternshipIssuanceTestData withName(String value) {
        record.Name = value;
        return this;
    }

    public InternshipIssuanceTestData withRequiredECTS(Decimal value) {
        record.Required_ECTS__c = value;
        return this;
    }

    public InternshipIssuanceTestData withRequiredHours(Decimal value) {
        record.Required_Hours__c = value;
        return this;
    }
}