@IsTest
public with sharing class ContactTestDataFactory {
    public static Contact createStudent(Boolean withInsert) {
        Id contactStudentRecordTypeId = Utils.getRecordTypeIdByDevName(
            Contact.getSObjectType(),
            Constants.CONTACT_STUDENT_RECORD_TYPE_DEV_NAME
        );

        return withInsert
            ? new ContactTestData().withRecordType(contactStudentRecordTypeId).save().get()
            : new ContactTestData().withRecordType(contactStudentRecordTypeId).get();
    }

    public static Contact createStudent(String lastName, Boolean withInsert) {
        Id contactStudentRecordTypeId = Utils.getRecordTypeIdByDevName(
            Contact.getSObjectType(),
            Constants.CONTACT_STUDENT_RECORD_TYPE_DEV_NAME
        );

        return withInsert
            ? new ContactTestData().withRecordType(contactStudentRecordTypeId).withLastName(lastName).save().get()
            : new ContactTestData().withRecordType(contactStudentRecordTypeId).withLastName(lastName).get();
    }
}