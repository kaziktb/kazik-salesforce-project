@IsTest
private class MySwpsJobOfferDetailControllerTest {
    private static final String TEST_ADMIN_USERNAME = 'wielki.admin@umnie.dziala';
    private static final String TEST_STUDENT_USERNAME = 'osoba@studencka.test.com';
    private static final Id JOB_OFFER_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(
        Career_Services_Offer__c.getSObjectType(),
        Constants.CAREER_SERVICES_OFFER_RT_JOB_OFFER
    );

    @TestSetup
    private static void testSetup() {
        User adminUser = UserTestDataFactory.createAdminUser(TEST_ADMIN_USERNAME, true);

        System.runAs(adminUser) {
            new CsOfferTestData()
                .withRecordType(JOB_OFFER_RECORD_TYPE_ID)
                .save()
                .get();

            Contact studentContact = ContactTestDataFactory.createStudent(true);

            UserTestDataFactory.createCommunityStudentUser(studentContact.Id, TEST_STUDENT_USERNAME, 'stud', true);
        }
    }
    @IsTest
    static void fetchJobOfferDetailsTest() {
        User studentUser = [SELECT Id FROM User WHERE Username = :TEST_STUDENT_USERNAME];
        Career_Services_Offer__c queriedOffer = [SELECT Id FROM Career_Services_Offer__c WHERE RecordTypeId = :JOB_OFFER_RECORD_TYPE_ID LIMIT 1];
        Career_Services_Offer__c fetchedByMethodOffer;

        Test.startTest();
        System.runAs(studentUser) {
            fetchedByMethodOffer = MySwpsJobOfferDetailController.fetchJobOfferDetails(queriedOffer.Id);
        }
        Test.stopTest();

        Assert.areEqual(queriedOffer.Id, fetchedByMethodOffer.Id);
    }
}