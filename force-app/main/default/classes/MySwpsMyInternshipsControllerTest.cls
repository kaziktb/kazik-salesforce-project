@IsTest
private class MySwpsMyInternshipsControllerTest {
    private static final String TEST_ADMIN_USERNAME = 'php@my.admin';
    private static final String TEST_STUDENT_USERNAME = 'stu@dent.invalid';
    private static final Id INSTITUTIONAL_INTERNSHIP_APPLICATION_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(
        Career_Services_Application__c.getSObjectType(),
        Constants.CAREER_SERVICES_APPLICATION_RT_INSTITUTIONAL_INTERNSHIP
    );
    private static final Id INDIVIDUAL_INTERNSHIP_APPLICATION_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(
        Career_Services_Application__c.getSObjectType(),
        Constants.CAREER_SERVICES_APPLICATION_RT_INDIVIDUAL_INTERNSHIP
    );

    private static final Integer DEFAULT_OFFSET = 0;
    private static final Integer DEFAULT_RECORDS_COUNT_TO_RETURN = 3;

    @TestSetup
    private static void testSetup() {
        User adminUser = UserTestDataFactory.createAdminUser(TEST_ADMIN_USERNAME, true);

        System.runAs(adminUser) {
            Contact studentContact = ContactTestDataFactory.createStudent(true);

            UserTestDataFactory.createCommunityStudentUser(studentContact.Id, TEST_STUDENT_USERNAME, 'stud', true);
        }
    }
    @IsTest
    static void fetchInternshipApplicationsTest() {
        User studentUser = [SELECT ContactId FROM User WHERE Username = :TEST_STUDENT_USERNAME];
        MySwpsMyInternshipsController.ResultWrapper resultWrapper;

        Test.startTest();
        System.runAs(studentUser) {
            new CsApplicationTestData()
                .withRecordType(INSTITUTIONAL_INTERNSHIP_APPLICATION_RECORD_TYPE_ID)
                .withStudent(studentUser.ContactId)
                .save()
                .get();

            new CsApplicationTestData()
                .withRecordType(INDIVIDUAL_INTERNSHIP_APPLICATION_RECORD_TYPE_ID)
                .withStudent(studentUser.ContactId)
                .save()
                .get();

            resultWrapper = MySwpsMyInternshipsController.fetchInternshipApplications(DEFAULT_OFFSET, DEFAULT_RECORDS_COUNT_TO_RETURN);
        }
        Test.stopTest();

        Assert.areEqual(2, resultWrapper.applications.size());
    }
}