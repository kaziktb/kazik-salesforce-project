@IsTest
private class MySwpsInstitutionalApplicationDetailTest {
    private static final String TEST_ADMIN_USERNAME = 'mega@admin.invalid';
    private static final String TEST_STUDENT_USERNAME = 'studencik@test.com';
    private static final Id INSTITUTIONAL_INTERNSHIP_APPLICATION_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(
        Career_Services_Application__c.getSObjectType(),
        Constants.CAREER_SERVICES_APPLICATION_RT_INSTITUTIONAL_INTERNSHIP
    );

    @TestSetup
    private static void testSetup() {
        User adminUser = UserTestDataFactory.createAdminUser(TEST_ADMIN_USERNAME, true);

        System.runAs(adminUser) {
            Contact studentContact = ContactTestDataFactory.createStudent(true);

            User communityStudentUser = UserTestDataFactory.createCommunityStudentUser(studentContact.Id, TEST_STUDENT_USERNAME, 'stud', true);

            new CsApplicationTestData()
                .withRecordType(INSTITUTIONAL_INTERNSHIP_APPLICATION_RECORD_TYPE_ID)
                .withOwner(communityStudentUser.Id)
                .save();
        }
    }
    @IsTest
    static void fetchInstitutionalApplicationDetailsTest() {
        User studentUser = [SELECT Id FROM User WHERE Username = :TEST_STUDENT_USERNAME];
        Career_Services_Application__c internshipApplication;
        MySwpsInstitutionalApplicationDetailCtrl.InstitutionalApplicationDetailsWrapper fetchedByMethodWrapper;

        Test.startTest();
        System.runAs(studentUser) {
            internshipApplication = new CsApplicationTestData()
                .withRecordType(INSTITUTIONAL_INTERNSHIP_APPLICATION_RECORD_TYPE_ID)
                .withStatus(Constants.CAREER_SERVICES_APPLICATION_STATUS_NEW_APPLICATION)
                .save()
                .get();

            fetchedByMethodWrapper = MySwpsInstitutionalApplicationDetailCtrl.fetchInstitutionalApplicationDetails(internshipApplication.Id, Constants.LANGUAGE_LOCALE_KEY_POLISH);
        }
        Test.stopTest();

        Assert.areEqual(internshipApplication.Id, fetchedByMethodWrapper.internshipApplication.Id);
    }
}