@IsTest
private class GenerateInternshipReferralControllerTest {
    private static final String CAREER_OFFICE_EMPLOYEE_EMAIL = 'co_employee@swps.test.pl';
    private static final String TEST_SPECIALTY_NAME = 'Test specialty';

    @TestSetup
    private static void prepareData() {
        User adminUser = DT_DataFactory.createAdminUser();
        User careerOfficeUser;

        System.runAs(adminUser) {
            List<Contact> contacts = DT_DataFactory.createContacts(
                1, true, new Contact(
                    RecordTypeId = DT_Utils.getRecTypeIdByDevName(
                        DT_Utils.CONTACT_STUDENT_RECORD_TYPE_DEV_NAME, Contact.getSObjectType().getDescribe().getName()
                    )
                )
            );

            List<DT_Internship__c> internships = DT_DataFactory.createInternships(1, true, null);

            careerOfficeUser = DT_DataFactory.createUsers(
                1,true,  new User(
                    Email = CAREER_OFFICE_EMPLOYEE_EMAIL,
                    ProfileId = DT_Utils.getProfileIdByName(DT_Utils.SWPS_CAREER_OFFICE_PROFILE_NAME)
                )
            ).get(0);

            Account specialty = DT_DataFactory.createTestSpecialty(TEST_SPECIALTY_NAME, true, true);

            DT_Internship_Supervisor__c supervisor = DT_DataFactory.createInternshipSupervisors(
                1,true,  new DT_Internship_Supervisor__c(
                    DT_Is_Active__c = true,
                    DT_Specialty__c = specialty.Id
                )
            ).get(0);

            DT_DataFactory.createInstitutionalInternshipApplications(internships[0].Id, contacts[0].Id, careerOfficeUser.Id, supervisor.Id, 1, true);
        }
    }

    @IsTest
    private static void isInternshipApplicationReadyToProceedTest() {
        DT_Internship_Application__c internshipApplication = [SELECT Id FROM DT_Internship_Application__c LIMIT 1];
        internshipApplication.DT_Status__c = DT_Utils.INTERNSHIP_APPLICATION_STATUS_READY_TO_PROCEED;
        update internshipApplication;

        Boolean methodResult = false;

        Test.startTest();
        methodResult = GenerateInternshipReferralController.isInternshipApplicationReadyToProceed(internshipApplication.Id);
        Test.stopTest();

        Assert.isTrue(methodResult);
    }

    @IsTest
    private static void generateApplicationNumberTest() {
        DT_Internship_Application__c internshipApplicationBefore = [SELECT Application_Number__c FROM DT_Internship_Application__c LIMIT 1];

        Test.startTest();
        GenerateInternshipReferralController.generateApplicationNumber(internshipApplicationBefore.Id);
        Test.stopTest();

        DT_Internship_Application__c internshipApplicationAfter = [SELECT Application_Number__c FROM DT_Internship_Application__c LIMIT 1];

        Assert.isNull(internshipApplicationBefore.Application_Number__c);
        Assert.isNotNull(internshipApplicationAfter.Application_Number__c);
    }

    @IsTest
    private static void generateReferralSuccessPolishTest() {
        DT_Internship_Application__c internshipApplication = [SELECT Id FROM DT_Internship_Application__c LIMIT 1];
        internshipApplication.DT_Status__c = DT_Utils.INTERNSHIP_APPLICATION_STATUS_READY_TO_PROCEED;
        update internshipApplication;

        GenerateInternshipReferralController.generateApplicationNumber(internshipApplication.Id);

        String resultUrl;

        Test.startTest();
        resultUrl = GenerateInternshipReferralController.generateReferral(internshipApplication.Id, Label.Language_Polish);
        Test.stopTest();

        Assert.isNotNull(resultUrl);
    }

    @IsTest
    private static void generateReferralSuccessEnglishTest() {
        DT_Internship_Application__c internshipApplication = [SELECT Id FROM DT_Internship_Application__c LIMIT 1];
        internshipApplication.DT_Status__c = DT_Utils.INTERNSHIP_APPLICATION_STATUS_READY_TO_PROCEED;
        update internshipApplication;

        GenerateInternshipReferralController.generateApplicationNumber(internshipApplication.Id);

        String resultUrl;

        Test.startTest();
        resultUrl = GenerateInternshipReferralController.generateReferral(internshipApplication.Id, Label.Language_English);
        Test.stopTest();

        Assert.isNotNull(resultUrl);
    }

    @IsTest
    private static void generateReferralSuccessAlreadyExistingReferralTest() {
        DT_Internship_Application__c internshipApplication = [SELECT Application_Number__c FROM DT_Internship_Application__c LIMIT 1];
        internshipApplication.DT_Status__c = DT_Utils.INTERNSHIP_APPLICATION_STATUS_READY_TO_PROCEED;
        update internshipApplication;

        GenerateInternshipReferralController.generateApplicationNumber(internshipApplication.Id);

        GenerateInternshipReferralController.generateReferral(internshipApplication.Id, Label.Language_Polish);

        List<ContentDocumentLink> existingContentDocumentLinks = [
            SELECT Id
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :internshipApplication.Id
        ];

        String resultUrl;

        Test.startTest();
        resultUrl = GenerateInternshipReferralController.generateReferral(internshipApplication.Id, Label.Language_Polish);
        Test.stopTest();

        List<ContentDocumentLink> postTestContentDocumentLinks = [
            SELECT Id
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :internshipApplication.Id
        ];

        Assert.isNotNull(resultUrl);
        Assert.areEqual(existingContentDocumentLinks.size(), postTestContentDocumentLinks.size());
    }

    @IsTest
    private static void generateReferralMissingParamTest() {
        DT_Internship_Application__c internshipApplication = [SELECT Id FROM DT_Internship_Application__c LIMIT 1];
        internshipApplication.DT_Status__c = DT_Utils.INTERNSHIP_APPLICATION_STATUS_READY_TO_PROCEED;
        update internshipApplication;

        String resultUrl;

        Test.startTest();
        resultUrl = GenerateInternshipReferralController.generateReferral(internshipApplication.Id, null);
        Test.stopTest();

        Assert.isNull(resultUrl);
    }
}