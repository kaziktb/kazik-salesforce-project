@IsTest
private class DT_InternshipApplicationHelperTest {
    private static final Integer NUMBER_OF_INTERNSHIPS = 2;
    private static final String CAREER_OFFICE_EMPLOYEE_EMAIL = 'co_employee@swps.test.pl';
    private static final String TEST_SPECIALTY_NAME = 'Computer Science';

    @TestSetup
    private static void prepareData() {
        Account specialty;
        User adminUser = DT_DataFactory.createAdminUser();
        User studentUser;
        User careerOfficeUser;
        DT_Internship_Supervisor__c supervisor;
        System.runAs(adminUser) {
            careerOfficeUser = DT_DataFactory.createUsers(
                1,true,  new User(
                        Email = CAREER_OFFICE_EMPLOYEE_EMAIL,
                        ProfileId = DT_Utils.getProfileIdByName(DT_Utils.SWPS_CAREER_OFFICE_PROFILE_NAME)
                )
            ).get(0);

            specialty = DT_DataFactory.createTestSpecialty(TEST_SPECIALTY_NAME, true, true);

            supervisor = DT_DataFactory.createInternshipSupervisors(
                    1,true,  new DT_Internship_Supervisor__c(
                            DT_Is_Active__c = true,
                            DT_Specialty__c = specialty.Id
                    )
            ).get(0);

            studentUser = DT_DataFactory.createStudentUser();

            List<DT_Internship__c> internshipOffers = DT_DataFactory.createInternships(1, false, null);
            internshipOffers[0].DT_Internships_Number__c = NUMBER_OF_INTERNSHIPS;
            internshipOffers[0].Vacancies__c = NUMBER_OF_INTERNSHIPS;
            insert internshipOffers;

            List<DT_Internship_Application__c> internshipApplications = DT_DataFactory.createInstitutionalInternshipApplications(
                    internshipOffers[0].Id, studentUser.ContactId, careerOfficeUser.Id, supervisor.Id,  1, false
            );
            internshipApplications[0].DT_Status__c = DT_Utils.INTERNSHIP_APPLICATION_STATUS_DRAFT;
            insert internshipApplications;
        }
    }

    @IsTest
    private static void recalculateInternshipVacanciesUpdateTest() {
        DT_Internship_Application__c internshipApplication = [SELECT DT_Internship__c FROM DT_Internship_Application__c LIMIT 1];

        internshipApplication.DT_Status__c = DT_Utils.INTERNSHIP_APPLICATION_STATUS_READY_TO_PROCEED;

        Test.startTest();
        update internshipApplication;
        Test.stopTest();

        DT_Internship__c internshipOffer = [SELECT Vacancies__c FROM DT_Internship__c WHERE Id = :internshipApplication.DT_Internship__c];

        System.assertEquals(NUMBER_OF_INTERNSHIPS - 1, internshipOffer.Vacancies__c);
    }

    @IsTest
    private static void recalculateInternshipVacanciesDeleteTest() {
        DT_Internship_Application__c internshipApplication = [SELECT DT_Internship__c FROM DT_Internship_Application__c LIMIT 1];

        internshipApplication.DT_Status__c = DT_Utils.INTERNSHIP_APPLICATION_STATUS_READY_TO_PROCEED;
        update internshipApplication;

        DT_Internship__c internshipOffer = [SELECT Vacancies__c FROM DT_Internship__c WHERE Id = :internshipApplication.DT_Internship__c];
        System.assertEquals(NUMBER_OF_INTERNSHIPS - 1, internshipOffer.Vacancies__c);

        Test.startTest();
        delete internshipApplication;
        Test.stopTest();

        internshipOffer = [SELECT Vacancies__c FROM DT_Internship__c WHERE Id = :internshipApplication.DT_Internship__c];

        System.assertEquals(NUMBER_OF_INTERNSHIPS, internshipOffer.Vacancies__c);
    }
}