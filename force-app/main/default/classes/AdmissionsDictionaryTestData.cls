@IsTest
public class AdmissionsDictionaryTestData {
    public static final String DEFAULT_NAME = 'Test';
    public static final String DEFAULT_DESCRIPTION_PL = 'Description PL';
    public static final String DEFAULT_DESCRIPTION_EN = 'Description EN';
    public Integer count = 0;

    private TB_Admissions_Dictionary__c record;

    public AdmissionsDictionaryTestData() {
        record = new TB_Admissions_Dictionary__c();
        count++;
        applyDefaults();
    }

    public AdmissionsDictionaryTestData applyDefaults() {
        return this.withName(DEFAULT_NAME + count).asActive();
    }

    public TB_Admissions_Dictionary__c get() {
        return record;
    }

    public AdmissionsDictionaryTestData save() {
        if (record.Id == null) {
            insert record;
        } else {
            update record;
        }
        return this;
    }

    public AdmissionsDictionaryTestData withName(String name) {
        record.Name = name;
        return this;
    }

    public AdmissionsDictionaryTestData withUsedOn(String name) {
        record.TB_Used_On__c = name;
        return this;
    }

    public AdmissionsDictionaryTestData asActive() {
        record.TB_Active__c = true;
        return this;
    }

    public AdmissionsDictionaryTestData withRecordTypeId(Id recordTypeId) {
        record.RecordTypeId = recordTypeId;
        return this;
    }

    public AdmissionsDictionaryTestData withConsentBundle(Id consentBundleId) {
        record.TB_Consents_Bundle__c = consentBundleId;
        return this;
    }
    public AdmissionsDictionaryTestData withConsentType(String consentType) {
        record.TB_Consent_Type__c = consentType;
        return this;
    }

    public AdmissionsDictionaryTestData withDescriptionPL(String descriptionPL) {
        record.TB_Description_PL__c = descriptionPL;
        return this;
    }

    public AdmissionsDictionaryTestData withDescriptionEN(String descriptionEN) {
        record.TB_Description_EN__c = descriptionEN;
        return this;
    }

}