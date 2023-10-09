@IsTest
private class StudentsDeactivationBatchTest {
    @TestSetup
    private static void prepareData() {
        User admin = UserTestDataFactory.createAdminUser(true);

        System.runAs(admin) {
            Contact studentContact = ContactTestDataFactory.createStudent(true);
            UserTestDataFactory.createStudentUser(true, studentContact);
            UserTestDataFactory.createPlatformUser(true, 'PlatformTestUser@tests.com');
        }
    }

    @IsTest
    private static void executionTest() {
        Id contactStudentRecordTypeId = DT_Utils.getRecTypeIdByDevName(
            DT_Utils.CONTACT_STUDENT_RECORD_TYPE_DEV_NAME,
            Contact.getSObjectType().getDescribe().getName()
        );
        Id studentProfileId = DT_Utils.getProfileIdByName(DT_Utils.SWPS_STUDENT_PROFILE_NAME);

        List<User> preBatchUsers = [
            SELECT Id
            FROM User
            WHERE IsActive = TRUE
                AND
                (
                    (
                        ContactId != NULL
                        AND Contact.RecordTypeId = :contactStudentRecordTypeId
                        AND ProfileId = :studentProfileId
                    )
                    OR Profile.UserLicense.Name = 'Salesforce Platform'
                )
        ];

        Test.startTest();
            Database.executeBatch(new StudentsDeactivationBatch());
        Test.stopTest();

        List<User> postBatchUsers = [
            SELECT Id
            FROM User
            WHERE IsActive = TRUE
                AND
                (
                    (
                        ContactId != NULL
                        AND Contact.RecordTypeId = :contactStudentRecordTypeId
                        AND ProfileId = :studentProfileId
                    )
                    OR Profile.UserLicense.Name = 'Salesforce Platform'
                )
        ];

        Assert.isTrue(postBatchUsers.size() <= preBatchUsers.size() - 2);
    }

}