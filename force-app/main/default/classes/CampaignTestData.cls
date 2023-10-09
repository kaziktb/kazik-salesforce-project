@IsTest
public class CampaignTestData {
    public static final String DEFAULT_NAME = 'Test';
    public static Integer count = 0;
    private Campaign record;

    public CampaignTestData() {
        this.record = new Campaign();
        count++;
        this.applyDefaults();
    }

    public CampaignTestData(CampaignTestData testData) {
        this.record = testData.record.clone(false, true, false, false);
        count++;
        this.applyDefaults();
    }

    public CampaignTestData applyDefaults() {
        return this.withName(getDefaultName());
    }

    public CampaignTestData copy() {
        return new CampaignTestData(this);
    }

    public Campaign get() {
        return record;
    }

    public CampaignTestData save() {
        if (record.Id == null) {
            insert record;
        } else {
            update record;
        }
        return this;
    }

    public String getDefaultName() {
        return String.join(new List<String>{ DEFAULT_NAME, String.valueOf(count) }, '');
    }

    public CampaignTestData withName(String value) {
        record.Name = value;
        return this;
    }
    
}