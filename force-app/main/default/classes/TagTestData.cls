@IsTest
public class TagTestData {
    private static final String DEFAULT_NAME = 'Test Tag ';

    public static Integer count = 0;
    private final Tag__c record;

    public TagTestData() {
        record = new Tag__c();
        count++;
        applyDefaults();
    }

    public TagTestData(TagTestData testData) {
        record = testData.record.clone(false, true, false, false);
        count++;
        applyDefaults();
    }

    public TagTestData applyDefaults() {
        return this.withName(DEFAULT_NAME + String.valueOf(count))
            .withEnglishName(DEFAULT_NAME + String.valueOf(count));
    }

    public TagTestData copy() {
        return new TagTestData(this);
    }

    public Tag__c get() {
        return record;
    }

    public TagTestData save() {
        if (record.Id == null) {
            insert record;
        } else {
            update record;
        }

        return this;
    }

    public TagTestData withName(String value) {
        record.Name = value;
        return this;
    }

    public TagTestData withEnglishName(String value) {
        record.English_Name__c = value;
        return this;
    }

    public TagTestData withCategory(String value) {
        record.Category__c = value;
        return this;
    }
}