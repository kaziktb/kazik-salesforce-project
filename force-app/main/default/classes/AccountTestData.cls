@IsTest
public with sharing class AccountTestData {
    public static final String DEFAULT_NAME = 'Test Account';
    public static final String DEFAULT_SPECIALTY_PL = 'Test Specialty PL';
    public static final String DEFAULT_SPECIALTY_EN = 'Test Specialty EN';
    public static final String DEFAULT_FIELD_OF_STUDY_PL = 'Test Field Of Study PL';
    public static final String DEFAULT_FIELD_OF_STUDY_EN = 'Test Field Of Study EN';
    public static Integer count = 0;
    private final Account record;

    public AccountTestData() {
        record = new Account();
        count++;
        applyDefaults();
    }

    public AccountTestData(AccountTestData testData) {
        record = testData.record.clone(false, true, false, false);
        count++;
        applyDefaults();
    }

    public AccountTestData applyDefaults() {
        return withName(getDefaultName());
    }

    public AccountTestData copy() {
        return new AccountTestData(this);
    }

    public Account get() {
        return record;
    }

    public AccountTestData save() {
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

    public AccountTestData withName(String value) {
        record.Name = value;
        return this;
    }

    public AccountTestData withRecordType(Id value) {
        record.RecordTypeId = value;
        return this;
    }

    public AccountTestData withStatus(String value) {
        record.TB_Status__c = value;
        return this;
    }

    public AccountTestData withIndustry(String value) {
        record.Industry = value;
        return this;
    }

    public AccountTestData withSpecialtyPL(String value) {
        record.DT_Specialty_PL__c = value;
        return this;
    }

    public AccountTestData withSpecialtyEN(String value) {
        record.DT_Specialty_EN__c = value;
        return this;
    }

    public AccountTestData withAccountType(String value) {
        record.DT_Account_Type__c = value;
        return this;
    }

    public AccountTestData withFieldOfStudyPL(String value) {
        record.DT_Study_Field_PL__c = value;
        return this;
    }

    public AccountTestData withFieldOfStudyEN(String value) {
        record.DT_Study_Field_EN__c = value;
        return this;
    }

    public AccountTestData withStreet(String value) {
        record.BillingStreet = value;
        return this;
    }

    public AccountTestData withCountry(String value) {
        record.BillingCountry = value;
        return this;
    }

    public AccountTestData withCountryCode(String value) {
        record.BillingCountryCode = value;
        return this;
    }

    public AccountTestData withPostalCode(String value) {
        record.BillingPostalCode = value;
        return this;
    }

    public AccountTestData withCity(String value) {
        record.BillingCity = value;
        return this;
    }

    public AccountTestData withTaxId(String value) {
        record.DT_Company_Tax_Id__c = value;
        return this;
    }

    public AccountTestData withNationalCourtRegister(String value) {
        record.DT_KRS__c = value;
        return this;
    }

    public AccountTestData withOwner(Id value) {
        record.OwnerId = value;
        return this;
    }
}