@IsTest
public with sharing class CsOfferTagTestData {
    private final Career_Services_Offer_Tag__c record;

    public CsOfferTagTestData() {
        record = new Career_Services_Offer_Tag__c();
    }

    public CsOfferTagTestData(CsOfferTagTestData testData) {
        record = testData.record.clone(false, true, false, false);
    }

    public CsOfferTagTestData copy() {
        return new CsOfferTagTestData(this);
    }

    public Career_Services_Offer_Tag__c get() {
        return record;
    }

    public CsOfferTagTestData save() {
        if (record.Id == null) {
            insert record;
        } else {
            update record;
        }

        return this;
    }

    public CsOfferTagTestData withCareerServicesOfferId(Id value) {
        record.Career_Services_Offer__c = value;
        return this;
    }

    public CsOfferTagTestData withTagId(Id value) {
        record.Tag__c = value;
        return this;
    }

    public CsOfferTagTestData withLevel(String value) {
        record.Level__c = value;
        return this;
    }

    public CsOfferTagTestData withCategory(String value) {
        record.Category__c = value;
        return this;
    }
}