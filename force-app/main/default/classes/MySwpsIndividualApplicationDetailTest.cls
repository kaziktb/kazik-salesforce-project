@IsTest
private class MySwpsIndividualApplicationDetailTest {
    private static final String TEST_ADMIN_USERNAME = 'mega@admin.invalid';
    private static final String TEST_STUDENT_USERNAME = 'studencik@test.com';
    private static final Id INDIVIDUAL_INTERNSHIP_APPLICATION_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(
        Career_Services_Application__c.getSObjectType(),
        Constants.CAREER_SERVICES_APPLICATION_RT_INDIVIDUAL_INTERNSHIP
    );

    @TestSetup
    private static void testSetup() {
        User adminUser = UserTestDataFactory.createAdminUser(TEST_ADMIN_USERNAME, true);

        System.runAs(adminUser) {
            Contact studentContact = ContactTestDataFactory.createStudent(true);

            UserTestDataFactory.createCommunityStudentUser(studentContact.Id, TEST_STUDENT_USERNAME, 'stud', true);

            new CsOfferTestData().withExternalSupervisorEducation(Constants.CAREER_SERVICES_OFFER_EXTERNAL_SUPERVISOR_EDUCATION_OTHER).save();
        }
    }
    @IsTest
    static void fetchIndividualApplicationDetailsTestCanNotEdit() {
        User studentUser = [SELECT Id FROM User WHERE Username = :TEST_STUDENT_USERNAME];
        Career_Services_Offer__c offer = [SELECT Id FROM Career_Services_Offer__c LIMIT 1];
        Career_Services_Application__c internshipApplication;
        MySwpsIndividualApplicationDetailCtrl.IndividualApplicationDetailsWrapper fetchedByMethodWrapper;

        Test.startTest();
        System.runAs(studentUser) {
            internshipApplication = new CsApplicationTestData()
                .withRecordType(INDIVIDUAL_INTERNSHIP_APPLICATION_RECORD_TYPE_ID)
                .withStatus(Constants.CAREER_SERVICES_APPLICATION_STATUS_NEW_APPLICATION)
                .withOffer(offer.Id)
                .save()
                .get();

            fetchedByMethodWrapper = MySwpsIndividualApplicationDetailCtrl.fetchIndividualApplicationDetails(internshipApplication.Id, Constants.LANGUAGE_LOCALE_KEY_POLISH);
        }
        Test.stopTest();

        Assert.areEqual(internshipApplication.Id, fetchedByMethodWrapper.internshipApplication.Id);
        Assert.isFalse(fetchedByMethodWrapper.canEdit);
    }

    @IsTest
    static void fetchIndividualApplicationDetailsTestCanEdit() {
        User studentUser = [SELECT Id FROM User WHERE Username = :TEST_STUDENT_USERNAME];
        Career_Services_Offer__c offer = [SELECT Id FROM Career_Services_Offer__c LIMIT 1];
        Career_Services_Application__c internshipApplication;
        MySwpsIndividualApplicationDetailCtrl.IndividualApplicationDetailsWrapper fetchedByMethodWrapper;

        Test.startTest();
        System.runAs(studentUser) {
            internshipApplication = new CsApplicationTestData()
                .withRecordType(INDIVIDUAL_INTERNSHIP_APPLICATION_RECORD_TYPE_ID)
                .withStatus(Constants.CAREER_SERVICES_APPLICATION_STATUS_CORRECTION_NEEDED)
                .withOffer(offer.Id)
                .save()
                .get();
            fetchedByMethodWrapper = MySwpsIndividualApplicationDetailCtrl.fetchIndividualApplicationDetails(internshipApplication.Id, Constants.LANGUAGE_LOCALE_KEY_POLISH);
        }
        Test.stopTest();

        Assert.areEqual(internshipApplication.Id, fetchedByMethodWrapper.internshipApplication.Id);
        Assert.isTrue(fetchedByMethodWrapper.canEdit);
    }

    @IsTest
    static void changeStatusToReverification() {
        User studentUser = [SELECT Id FROM User WHERE Username = :TEST_STUDENT_USERNAME];
        Id applicationId = new CsApplicationTestData()
            .withRecordType(INDIVIDUAL_INTERNSHIP_APPLICATION_RECORD_TYPE_ID)
            .withStatus(Constants.CAREER_SERVICES_APPLICATION_STATUS_CORRECTION_NEEDED)
            .withOwner(studentUser.Id)
            .save()
            .get()
            .Id;

        Test.startTest();
        System.runAs(studentUser) {
            MySwpsIndividualApplicationDetailCtrl.changeStatusToReverification(applicationId);
        }
        Test.stopTest();

        Career_Services_Application__c application = [SELECT Status__c FROM Career_Services_Application__c WHERE Id = :applicationId];

        Assert.areEqual(Constants.CAREER_SERVICES_APPLICATION_STATUS_REVERIFICATION, application.Status__c);
    }
}