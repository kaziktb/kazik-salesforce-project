@IsTest
public with sharing class ContactTagTestDataFactory {
    public static Contact_Tag__c createContactTag(Id contactId, Id tagId, String category, String level, Boolean withInsert) {
        return withInsert
            ? new ContactTagTestData()
                .withContactId(contactId)
                .withTagId(tagId)
                .withCategory(category)
                .withLevel(level)
                .save()
                .get()
            : new ContactTagTestData()
                .withContactId(contactId)
                .withTagId(tagId)
                .withCategory(category)
                .withLevel(level)
                .get();
    }
}