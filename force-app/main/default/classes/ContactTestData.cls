@IsTest
public class ContactTestData {
    public static final String DEFAULT_FIRST_NAME = 'First';
    public static final String DEFAULT_LAST_NAME = 'Last';
    public static Integer count = 0;
    private Contact record;

    public ContactTestData() {
        this.record = new Contact();
        count++;
        this.applyDefaults();
    }

    public ContactTestData(ContactTestData testData) {
        this.record = testData.record.clone(false, true, false, false);
        count++;
        this.applyDefaults();
    }

    public ContactTestData applyDefaults() {
        return this.withFirstName(DEFAULT_FIRST_NAME)
            .withLastName(getDefaultLastName());
    }

    public ContactTestData copy() {
        return new ContactTestData(this);
    }

    public Contact get() {
        return record;
    }

    public ContactTestData save() {
        if (record.Id == null) {
            insert record;
        } else {
            update record;
        }
        return this;
    }

    public String getDefaultLastName() {
        return String.join(new List<String>{ DEFAULT_LAST_NAME, String.valueOf(count) }, '');
    }

    public ContactTestData withFirstName(String value) {
        record.FirstName = value;
        return this;
    }

    public ContactTestData withLastName(String value) {
        record.LastName = value;
        return this;
    }

    public ContactTestData withRecordType(Id value) {
        record.RecordTypeId = value;
        return this;
    }

    public ContactTestData withWorkEmail(String value) {
        record.hed__WorkEmail__c = value;
        return this;
    }

    public ContactTestData withWorkPhone(String value) {
        record.hed__WorkPhone__c = value;
        return this;
    }

    public ContactTestData withCompany(Id value) {
        record.AccountId = value;
        return this;
    }
}