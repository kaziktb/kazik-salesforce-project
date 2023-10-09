@IsTest
private class ApplicantsLicenseUpgradeBatchTest {

    @IsTest
    private static void executionTest() {
        User preBatchUser;

        Id studentProfileId = DT_Utils.getProfileIdByName(DT_Utils.SWPS_STUDENT_PROFILE_NAME);
        User admin = UserTestDataFactory.createAdminUser(true);
        Contact studentContact = ContactTestDataFactory.createStudent(true);

        System.runAs(admin) {
            preBatchUser = UserTestDataFactory.createApplicantUser(true, studentContact);
        }

        Test.startTest();
        ApplicantsLicenseUpgradeBatch batch = new ApplicantsLicenseUpgradeBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        User postBatchUser = [SELECT Id, ProfileId FROM User WHERE Id = :preBatchUser.Id LIMIT 1];

        Assert.areNotEqual(preBatchUser.ProfileId, postBatchUser.ProfileId);
        Assert.areEqual(studentProfileId, postBatchUser.ProfileId);
    }

}