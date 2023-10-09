@IsTest
public with sharing class ContactTagTestData {
    private final Contact_Tag__c record;

    public ContactTagTestData() {
        record = new Contact_Tag__c();
    }

    public ContactTagTestData(ContactTagTestData testData) {
        record = testData.record.clone(false, true, false, false);
    }

    public ContactTagTestData copy() {
        return new ContactTagTestData(this);
    }

    public Contact_Tag__c get() {
        return record;
    }

    public ContactTagTestData save() {
        if (record.Id == null) {
            insert record;
        } else {
            update record;
        }

        return this;
    }

    public ContactTagTestData withContactId(Id value) {
        record.Contact__c = value;
        return this;
    }

    public ContactTagTestData withTagId(Id value) {
        record.Tag__c = value;
        return this;
    }

    public ContactTagTestData withLevel(String value) {
        record.Level__c = value;
        return this;
    }

    public ContactTagTestData withCategory(String value) {
        record.Category__c = value;
        return this;
    }
}