@IsTest
private class MySwpsIndividualApplicationEditTest {
    private static final String TEST_ADMIN_USERNAME = 'mega@admin.invalid';
    private static final String TEST_STUDENT_USERNAME = 'studencik@test.com';
    private static final Id CONTACT_PARTNER_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(Contact.getSObjectType(), Constants.CONTACT_PARTNER_RECORD_TYPE_DEV_NAME);
    private static final Id ACCOUNT_BUSINESS_ORGANIZATION_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(Account.getSObjectType(), Constants.ACCOUNT_RECORD_TYPE_BUSINESS_ORGANIZATION_API_NAME);
    private static final Id INDIVIDUAL_INTERNSHIP_APPLICATION_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(
        Career_Services_Application__c.getSObjectType(),
        Constants.CAREER_SERVICES_APPLICATION_RT_INDIVIDUAL_INTERNSHIP
    );
    private static final Id INDIVIDUAL_INTERNSHIP_OFFER_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(
        Career_Services_Offer__c.getSObjectType(),
        Constants.CAREER_SERVICES_OFFER_RT_INDIVIDUAL_INTERNSHIP
    );

    @TestSetup
    private static void testSetup() {
        User adminUser = UserTestDataFactory.createAdminUserWithPermissionSetAssigned(TEST_ADMIN_USERNAME);

        System.runAs(adminUser) {
            Contact studentContact = ContactTestDataFactory.createStudent(true);

            User studentUser = UserTestDataFactory.createCommunityStudentUser(studentContact.Id, TEST_STUDENT_USERNAME, 'stud', true);

            Account company = new AccountTestData()
                .withName('In Hot Water Company')
                .withCountryCode('PL')
                .withPostalCode('00-001')
                .withCity('Warsaw')
                .withStreet('Andersena 6')
                .withTaxId('3211233211')
                .withNationalCourtRegister('0000385162')
                .withRecordType(ACCOUNT_BUSINESS_ORGANIZATION_RECORD_TYPE_ID)
                .save()
                .get();

            Contact representative = new ContactTestData()
                .withFirstName('Repp')
                .withLastName('Ressentant')
                .withRecordType(CONTACT_PARTNER_RECORD_TYPE_ID)
                .withWorkPhone('443322553')
                .withWorkEmail('repp@resent.invalid')
                .withCompany(company.Id)
                .save()
                .get();

            Career_Services_Offer__c offer = new CsOfferTestData()
                .withRecordType(INDIVIDUAL_INTERNSHIP_OFFER_RECORD_TYPE_ID)
                .withCompany(company.Id)
                .withOrganisationContact(representative.Id)
                .withExternalSupervisorEducation(Constants.CAREER_SERVICES_OFFER_EXTERNAL_SUPERVISOR_EDUCATION_OTHER)
                .save()
                .get();

            new CsApplicationTestData()
                .withRecordType(INDIVIDUAL_INTERNSHIP_APPLICATION_RECORD_TYPE_ID)
                .withOwner(studentUser.Id)
                .withCommencementDate(Date.today().addDays(-1))
                .withCompletionDate(Date.today().addDays(1))
                .withOffer(offer.Id)
                .withStatus(Constants.CAREER_SERVICES_APPLICATION_STATUS_CORRECTION_NEEDED)
                .save();
        }
    }

    @IsTest
    static void updateApplicationWithSupervisorCreationTest() {
        User studentUser = [SELECT Id FROM User WHERE Username = :TEST_STUDENT_USERNAME];
        Career_Services_Application__c application =
        [
            SELECT
                Internship_Commencement_Date__c,
                Internship_Completion_Date__c,
                Career_Services_Offer__c,
                Career_Services_Offer__r.Id,
                Career_Services_Offer__r.Offer_Title__c,
                Career_Services_Offer__r.Description_Of_Completed_Tasks__c,
                Career_Services_Offer__r.External_Supervisor_Education__c,
                Career_Services_Offer__r.External_Supervisor__c,
                Career_Services_Offer__r.External_Supervisor__r.FirstName,
                Career_Services_Offer__r.External_Supervisor__r.LastName,
                Career_Services_Offer__r.External_Supervisor__r.hed__WorkEmail__c,
                Career_Services_Offer__r.External_Supervisor__r.hed__WorkPhone__c,
                Career_Services_Offer__r.Organisation_Contact__c,
                Career_Services_Offer__r.Organisation_Contact__r.FirstName,
                Career_Services_Offer__r.Organisation_Contact__r.LastName,
                Career_Services_Offer__r.Organisation_Contact__r.hed__WorkEmail__c,
                Career_Services_Offer__r.Organisation_Contact__r.hed__WorkPhone__c,
                Career_Services_Offer__r.Company__c,
                Career_Services_Offer__r.Company__r.Website
            FROM Career_Services_Application__c
            LIMIT 1
        ];

        MySwpsIndividualApplicationEditCtrl.UpdateModel updateModel = mapApplicationToUpdateModel(application);
        updateModel.supervisorFirstName = 'Łukasz';
        updateModel.supervisorLastName = 'Klatka';
        updateModel.supervisorWorkEmail = 'luke@cage.invalid';
        updateModel.supervisorWorkPhone = '555444333';
        updateModel.hasSupervisorData = true;

        Test.startTest();
        System.runAs(studentUser) {
            MySwpsIndividualApplicationEditCtrl.updateApplication(updateModel);
        }
        Test.stopTest();

        Career_Services_Offer__c postUpdateInternshipApplication = [SELECT External_Supervisor__c FROM Career_Services_Offer__c WHERE Id = :application.Career_Services_Offer__c];

        Assert.isNotNull(postUpdateInternshipApplication.External_Supervisor__c);
    }

    @IsTest
    static void updateApplicationEditNoLongerAvailableTest() {
        User studentUser = [SELECT Id FROM User WHERE Username = :TEST_STUDENT_USERNAME];
        Career_Services_Application__c application = [SELECT Id FROM Career_Services_Application__c LIMIT 1];

        application.Status__c = Constants.CAREER_SERVICES_APPLICATION_STATUS_REVERIFICATION;

        update application;

        MySwpsIndividualApplicationEditCtrl.UpdateModel updateModel = new MySwpsIndividualApplicationEditCtrl.UpdateModel();
        updateModel.applicationId = application.Id;

        MySwpsIndividualApplicationEditCtrl.UpdateResult result;

        Test.startTest();
        System.runAs(studentUser) {
            result = MySwpsIndividualApplicationEditCtrl.updateApplication(updateModel);
        }
        Test.stopTest();

        Assert.areEqual(false, result.canEdit);
    }

    private static MySwpsIndividualApplicationEditCtrl.UpdateModel mapApplicationToUpdateModel(Career_Services_Application__c application) {
        MySwpsIndividualApplicationEditCtrl.UpdateModel updateModel = new MySwpsIndividualApplicationEditCtrl.UpdateModel();

        updateModel.applicationId = application.Id;
        updateModel.supervisorId = application.Career_Services_Offer__r.External_Supervisor__c;
        updateModel.companyId = application.Career_Services_Offer__r.Company__c;
        updateModel.offerId = application.Career_Services_Offer__c;
        updateModel.representativeId = application.Career_Services_Offer__r.Organisation_Contact__c;
        updateModel.offerTitle = application.Career_Services_Offer__r.Offer_Title__c;
        updateModel.representativeFirstName = application.Career_Services_Offer__r.Organisation_Contact__r.FirstName;
        updateModel.representativeLastName = application.Career_Services_Offer__r.Organisation_Contact__r.LastName;
        updateModel.representativeWorkEmail = application.Career_Services_Offer__r.Organisation_Contact__r.hed__WorkEmail__c;
        updateModel.representativeWorkPhone = application.Career_Services_Offer__r.Organisation_Contact__r.hed__WorkPhone__c;
        updateModel.supervisorFirstName = application.Career_Services_Offer__r.External_Supervisor__r.FirstName;
        updateModel.supervisorLastName = application.Career_Services_Offer__r.External_Supervisor__r.LastName;
        updateModel.supervisorWorkEmail = application.Career_Services_Offer__r.External_Supervisor__r.hed__WorkEmail__c;
        updateModel.supervisorWorkPhone = application.Career_Services_Offer__r.External_Supervisor__r.hed__WorkPhone__c;
        updateModel.supervisorEducation = application.Career_Services_Offer__r.External_Supervisor_Education__c;
        updateModel.descriptionOfCompletedTasks = application.Career_Services_Offer__r.Description_Of_Completed_Tasks__c;
        updateModel.website = application.Career_Services_Offer__r.Company__r.Website;
        updateModel.startDate = application.Internship_Commencement_Date__c;
        updateModel.endDate = application.Internship_Completion_Date__c;

        return updateModel;
    }
}