@IsTest
private class MySwpsCsOfferDetailControllerTest {
    private static final String TEST_ADMIN_USERNAME = 'test.admin@nimda.tset';
    private static final String TEST_STUDENT_USERNAME = 'osoba@studencka.test.com';
    @TestSetup
    private static void testSetup() {
        User adminUser = UserTestDataFactory.createAdminUser(TEST_ADMIN_USERNAME, true);

        System.runAs(adminUser) {
            Contact studentContact = ContactTestDataFactory.createStudent(true);

            UserTestDataFactory.createCommunityStudentUser(studentContact.Id, TEST_STUDENT_USERNAME, 'stud', true);
        }
    }

    @IsTest
    private static void fetchRecordTypes() {
        Career_Services_Offer__c jobOffer;
        final Id jobOfferRecordTypeId = Utils.getRecordTypeIdByDevName(Career_Services_Offer__c.getSObjectType(), Constants.CAREER_SERVICES_OFFER_RT_JOB_OFFER);
        User adminUser = [SELECT Id FROM User WHERE Username = :TEST_ADMIN_USERNAME];
        User studentUser = [SELECT Id FROM User WHERE Username = :TEST_STUDENT_USERNAME];

        System.runAs(adminUser) {
            jobOffer = new CsOfferTestData()
                .withRecordType(jobOfferRecordTypeId)
                .save()
                .get();
        }

        MySwpsCsOfferDetailController.RecordTypesWrapper recordTypesWrapper;

        Test.startTest();
        System.runAs(studentUser) {
            recordTypesWrapper = MySwpsCsOfferDetailController.fetchRecordTypes(jobOffer.Id);
        }
        Test.stopTest();

        Assert.isFalse(recordTypesWrapper.isIndividualInternship);
        Assert.isFalse(recordTypesWrapper.isInstitutionalInternship);
        Assert.isTrue(recordTypesWrapper.isJobOffer);
    }
}