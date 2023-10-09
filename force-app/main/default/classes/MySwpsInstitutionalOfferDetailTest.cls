@IsTest
private class MySwpsInstitutionalOfferDetailTest {
    private static final String TEST_ADMIN_USERNAME = 'iki@admin.invalid';
    private static final String TEST_STUDENT_USERNAME = 'takijedenstudent1990@test.com';
    private static final Id INTERNSHIP_OFFER_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(
        Career_Services_Offer__c.getSObjectType(),
        Constants.CAREER_SERVICES_OFFER_RT_INSTITUTIONAL_INTERNSHIP
    );

    @TestSetup
    private static void testSetup() {
        User adminUser = UserTestDataFactory.createAdminUser(TEST_ADMIN_USERNAME, true);

        System.runAs(adminUser) {
            new CsOfferTestData()
                .withRecordType(INTERNSHIP_OFFER_RECORD_TYPE_ID)
                .save()
                .get();

            Contact studentContact = ContactTestDataFactory.createStudent(true);

            UserTestDataFactory.createCommunityStudentUser(studentContact.Id, TEST_STUDENT_USERNAME, 'stud', true);
        }
    }
    @IsTest
    static void fetchInstitutionalOfferDetailsTest() {
        User studentUser = [SELECT Id FROM User WHERE Username = :TEST_STUDENT_USERNAME];
        Career_Services_Offer__c queriedOffer = [SELECT Id FROM Career_Services_Offer__c WHERE RecordTypeId = :INTERNSHIP_OFFER_RECORD_TYPE_ID LIMIT 1];
        MySwpsInstitutionalOfferDetailCtrl.InternshipOfferWrapper fetchedByMethodWrapper;

        Test.startTest();
        System.runAs(studentUser) {
            fetchedByMethodWrapper = MySwpsInstitutionalOfferDetailCtrl.fetchInternshipOfferDetails(queriedOffer.Id);
        }
        Test.stopTest();

        Assert.areEqual(queriedOffer.Id, fetchedByMethodWrapper.internshipOffer.Id);
    }
}