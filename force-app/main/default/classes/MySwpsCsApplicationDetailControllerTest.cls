@IsTest
private class MySwpsCsApplicationDetailControllerTest {
    private static final String TEST_ADMIN_USERNAME = 'admin@test.invalid';
    private static final String TEST_STUDENT_USERNAME = 'mike@wazowski.invalid';
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
    private static void fetchRecordTypes() {
        Career_Services_Application__c internshipApplication = [SELECT Id FROM Career_Services_Application__c LIMIT 1];
        User studentUser = [SELECT Id FROM User WHERE Username = :TEST_STUDENT_USERNAME];

        MySwpsCsApplicationDetailController.RecordTypesWrapper recordTypesWrapper;

        Test.startTest();
        System.runAs(studentUser) {
            recordTypesWrapper = MySwpsCsApplicationDetailController.fetchRecordTypes(internshipApplication.Id);
        }
        Test.stopTest();

        Assert.isFalse(recordTypesWrapper.isIndividualInternshipApplication);
        Assert.isTrue(recordTypesWrapper.isInstitutionalInternshipApplication);
    }
}