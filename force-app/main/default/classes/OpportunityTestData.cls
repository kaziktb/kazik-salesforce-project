@IsTest
public class OpportunityTestData {
    private static final String DEFAULT_NAME = 'Test Opportunity ';

    public static Integer count = 0;
    private final Opportunity record;

    public OpportunityTestData() {
        record = new Opportunity();
        count++;
        applyDefaults();
    }

    public OpportunityTestData(OpportunityTestData testData) {
        record = testData.record.clone(false, true, false, false);
        count++;
        applyDefaults();
    }

    public OpportunityTestData applyDefaults() {
        return this.withName(DEFAULT_NAME + String.valueOf(count))
            .withStageName(Constants.OPPORTUNITY_STAGE_NAME_NEW_API_NAME)
            .withCloseDate(Date.today().addDays(30));
    }

    public OpportunityTestData copy() {
        return new OpportunityTestData(this);
    }

    public Opportunity get() {
        return record;
    }

    public OpportunityTestData save() {
        if (record.Id == null) {
            insert record;
        } else {
            update record;
        }

        return this;
    }

    public OpportunityTestData withName(String value) {
        record.Name = value;
        return this;
    }

    public OpportunityTestData withRecordTypeId(Id value) {
        record.RecordTypeId = value;
        return this;
    }

    public OpportunityTestData withAccountId(Id value) {
        record.AccountId = value;
        return this;
    }

    public OpportunityTestData withStageName(String value) {
        record.StageName = value;
        return this;
    }

    public OpportunityTestData withCloseDate(Date value) {
        record.CloseDate = value;
        return this;
    }

    public OpportunityTestData withAdditionalWaysOfCooperation(String value) {
        record.Additional_Ways_Of_Cooperation__c = value;
        return this;
    }
}