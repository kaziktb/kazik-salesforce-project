@IsTest
public class ContractTestData {
    public static Integer count = 0;
    private final Contract record;

    public ContractTestData() {
        record = new Contract();
        count++;
        applyDefaults();
    }

    public ContractTestData(ContractTestData testData) {
        record = testData.record.clone(false, true, false, false);
        count++;
        applyDefaults();
    }

    public ContractTestData applyDefaults() {
        return this;
    }

    public ContractTestData copy() {
        return new ContractTestData(this);
    }

    public Contract get() {
        return record;
    }

    public ContractTestData save() {
        if (record.Id == null) {
            insert record;
        } else {
            update record;
        }
        return this;
    }

    public ContractTestData withAccount(Id value) {
        record.AccountId = value;
        return this;
    }

    public ContractTestData withStartDate(Date value) {
        record.StartDate = value;
        return this;
    }

    public ContractTestData withEndDate(Date value) {
        record.EndDate = value;
        return this;
    }

    public ContractTestData withStatus(String value) {
        record.Status = value;
        return this;
    }

    public ContractTestData withDTAccount(String value) {
        record.DT_Account__c = value;
        return this;
    }

    public ContractTestData withName(String value) {
        record.Name = value;
        return this;
    }

}