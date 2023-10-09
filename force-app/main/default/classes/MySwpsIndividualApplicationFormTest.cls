@IsTest
private class MySwpsIndividualApplicationFormTest {

    private static final String TEST_STUDENT_USER_COMMUNITY_NICKNAME = 'Super Test Nickname';
    private static final String EXISTING_SUPERVISOR_CONTACT_WORK_EMAIL = 'luke@cage.invalid';
    private static final Id OFFER_INDIVIDUAL_INTERNSHIP_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(Career_Services_Offer__c.getSObjectType(), Constants.CAREER_SERVICES_OFFER_RT_INDIVIDUAL_INTERNSHIP);
    private static final Id CONTACT_PARTNER_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(Contact.getSObjectType(), Constants.CONTACT_PARTNER_RECORD_TYPE_DEV_NAME);
    private static final Id ACCOUNT_BUSINESS_ORGANIZATION_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(Account.getSObjectType(), Constants.ACCOUNT_RECORD_TYPE_BUSINESS_ORGANIZATION_API_NAME);
    private static final Id APPLICATION_INDIVIDUAL_INTERNSHIP_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(Career_Services_Application__c.getSObjectType(), Constants.CAREER_SERVICES_APPLICATION_RT_INDIVIDUAL_INTERNSHIP);
    private static final Id ADMISSIONS_DICTIONARY_CONSENT_DEFINITION_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(TB_Admissions_Dictionary__c.getSObjectType(), TB_Constants.TB_CONSENT_CONSENT_DEFINITION_RT_DEVNAME);

    @TestSetup
    public static void setup() {
        User admin = UserTestDataFactory.createAdminUser(true);

        System.runAs(admin) {

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

            Contact supervisor = new ContactTestData()
                .withFirstName('Łukasz')
                .withLastName('Klatka')
                .withRecordType(CONTACT_PARTNER_RECORD_TYPE_ID)
                .withWorkPhone('555444333')
                .withWorkEmail(EXISTING_SUPERVISOR_CONTACT_WORK_EMAIL)
                .withCompany(company.Id)
                .get();

            Account academicProgram = AccountTestDataFactory.createAcademicProgram(false);
            Account department = AccountTestDataFactory.createDepartment(false);
            Account specialty = AccountTestDataFactory.createSpecialty(false);
            Account pathway = AccountTestDataFactory.createPathway(false);
            Internship_Issuance__c issuance = InternshipIssuanceTestDataFactory.create(100, 1, false).get(0);
            Contact studentContact = ContactTestDataFactory.createStudent(false);
            hed__Program_Plan__c programPlan = ProgramPlanTestDataFactory.createCurrent(1, false).get(0);
            TB_Admissions_Dictionary__c bundle = AdmissionsDictionaryTestDataFactory.createCareerOfficeConsentBundle(1, true)[0];
            TB_Admissions_Dictionary__c consentDefinition = AdmissionsDictionaryTestDataFactory.createCareerOfficeConsentDefinition(
                1,
                bundle.Id,
                Constants.ADMISSIONS_DICTIONARY_CONSENT_TYPE_TERMS_AND_CONDITIONS,
                false
            ).get(0);

            insert new SObject[]{
                academicProgram, department, specialty, pathway, issuance, studentContact, programPlan, consentDefinition, supervisor
            };
            academicProgram.DT_Department__c = department.Id;
            update academicProgram;

            UserTestDataFactory.createCommunityStudentUser(studentContact.Id, 'communityStudent@test.invalid', TEST_STUDENT_USER_COMMUNITY_NICKNAME, true);
            hed__Education_History__c educationHistory = EducationHistoryTestDataFactory.createWithStatusStudying(studentContact.Id, 1, true).get(0);
            hed__Program_Enrollment__c programEnrollment = ProgramEnrollmentTestDataFactory.createWithProgramPlan(
                studentContact.Id,
                academicProgram.Id,
                educationHistory.Id,
                programPlan.Id,
                1,
                true
            ).get(0);

            Internship_Group__c internshipGroup = InternshipGroupTestDataFactory.create(academicProgram.Id, issuance.Id, 1, false).get(0);
            internshipGroup.Specialty__c = specialty.Id;
            internshipGroup.Pathway__c = pathway.Id;
            insert internshipGroup;

            Internship_Requirement__c requirement = InternshipRequirementTestDataFactory.create(educationHistory.Id, internshipGroup.Id, 1, false).get(0);
            requirement.Program_Enrollment__c = programEnrollment.Id;
            insert requirement;
        }
    }

    @IsTest
    public static void fetchInitialDataSuccess() {
        User studentUser = [SELECT Id, ContactId FROM User WHERE CommunityNickname = :TEST_STUDENT_USER_COMMUNITY_NICKNAME LIMIT 1];
        MySwpsIndividualApplicationFormCtrl.FormInitialDataWrapper wrapper;

        Test.startTest();
        System.runAs(studentUser) {
            wrapper = MySwpsIndividualApplicationFormCtrl.fetchFormInitialData(Constants.LANGUAGE_LOCALE_KEY_POLISH);
        }
        Test.stopTest();

        Assert.isNotNull(wrapper);
        Assert.isTrue(wrapper.hasAnyRequirement);
        Assert.areNotEqual(0, wrapper.educationHistories.size());
        Assert.areEqual(studentUser.ContactId, wrapper.studentContactId);
        Assert.isNotNull(wrapper.companyAccountRecordTypeId);
        Assert.isNotNull(wrapper.partnerContactRecordTypeId);
    }

    @IsTest
    public static void fetchStudentDataWithProgramEnrollmentSuccess() {
        User studentUser = [SELECT Id, ContactId FROM User WHERE CommunityNickname = :TEST_STUDENT_USER_COMMUNITY_NICKNAME LIMIT 1];
        hed__Program_Enrollment__c programEnrollment = [SELECT Id FROM hed__Program_Enrollment__c WHERE hed__Contact__c = :studentUser.ContactId LIMIT 1];
        MySwpsIndividualApplicationFormCtrl.StudentDataWrapper wrapper;

        Test.startTest();
        System.runAs(studentUser) {
            wrapper = MySwpsIndividualApplicationFormCtrl.fetchStudentData(studentUser.ContactId, programEnrollment.Id, Constants.LANGUAGE_LOCALE_KEY_POLISH);
        }
        Test.stopTest();

        Assert.isNotNull(wrapper);
        Assert.isFalse(String.isBlank(wrapper.firstName));
        Assert.isFalse(String.isBlank(wrapper.lastName));
        Assert.isFalse(String.isBlank(wrapper.studyField));
        Assert.isFalse(String.isBlank(wrapper.languageOfInstruction));
        Assert.isFalse(String.isBlank(wrapper.albumNumber));
        Assert.isFalse(String.isBlank(wrapper.specialty));
        Assert.isFalse(String.isBlank(wrapper.department));
        Assert.isFalse(String.isBlank(wrapper.studyLevel));
        Assert.isFalse(String.isBlank(wrapper.studyMode));
    }

    @IsTest
    public static void fetchStudentDataWithoutProgramEnrollmentSuccess() {
        User studentUser = [SELECT Id, ContactId FROM User WHERE CommunityNickname = :TEST_STUDENT_USER_COMMUNITY_NICKNAME LIMIT 1];
        MySwpsIndividualApplicationFormCtrl.StudentDataWrapper wrapper;

        Test.startTest();
        System.runAs(studentUser) {
            wrapper = MySwpsIndividualApplicationFormCtrl.fetchStudentData(studentUser.ContactId, null, Constants.LANGUAGE_LOCALE_KEY_POLISH);
        }
        Test.stopTest();

        Assert.isNotNull(wrapper);
        Assert.isFalse(String.isBlank(wrapper.firstName));
        Assert.isFalse(String.isBlank(wrapper.lastName));
        Assert.isTrue(String.isBlank(wrapper.studyField));
        Assert.isTrue(String.isBlank(wrapper.languageOfInstruction));
        Assert.isTrue(String.isBlank(wrapper.albumNumber));
        Assert.isTrue(String.isBlank(wrapper.specialty));
        Assert.isTrue(String.isBlank(wrapper.department));
        Assert.isTrue(String.isBlank(wrapper.studyLevel));
        Assert.isTrue(String.isBlank(wrapper.studyMode));
    }

    @IsTest
    public static void submitNonObligatoryApplicationSuccess() {
        Account company = new AccountTestData()
            .withName('Test company')
            .withCountryCode('PL')
            .withPostalCode('00-001')
            .withCity('Warsaw')
            .withStreet('Andersena 3')
            .withTaxId('1231231231')
            .withNationalCourtRegister('0000385161')
            .withRecordType(ACCOUNT_BUSINESS_ORGANIZATION_RECORD_TYPE_ID)
            .get();

        Contact representative = new ContactTestData()
            .withFirstName('Mariusz')
            .withLastName('Pudzianowski')
            .withRecordType(CONTACT_PARTNER_RECORD_TYPE_ID)
            .withWorkPhone('123123123')
            .withWorkEmail('pudzian@test.invalid')
            .get();

        Contact supervisor = new ContactTestData()
            .withFirstName('Franciszek')
            .withLastName('Zamek')
            .withRecordType(CONTACT_PARTNER_RECORD_TYPE_ID)
            .withWorkPhone('333444555')
            .withWorkEmail('frank@castle.invalid')
            .get();

        Career_Services_Offer__c offer = new CsOfferTestData()
            .withInstitutionWebsite('https://www.test.pl')
            .withOfferTitle('Salesforce Developer')
            .withDescriptionOfCompletedTasks('24/7 CRUDS')
            .withInternshipClockHours(100)
            .withExternalSupervisorEducation(Constants.CAREER_SERVICES_OFFER_EXTERNAL_SUPERVISOR_EDUCATION_OTHER)
            .withRecordType(OFFER_INDIVIDUAL_INTERNSHIP_RECORD_TYPE_ID)
            .withCompanyDescription('Test description')
            .get();

        Career_Services_Application__c application = new CsApplicationTestData()
            .withCommencementDate(Date.today())
            .withCompletionDate(Date.today().addDays(1))
            .withRecordType(APPLICATION_INDIVIDUAL_INTERNSHIP_RECORD_TYPE_ID)
            .get();

        MySwpsIndividualApplicationFormCtrl.InternshipApplicationConsentsWrapper consentWrapper = getConsentWrapper(true);

        User studentUser = [SELECT Id, ContactId FROM User WHERE CommunityNickname = :TEST_STUDENT_USER_COMMUNITY_NICKNAME LIMIT 1];
        hed__Program_Enrollment__c programEnrollment = [SELECT Id FROM hed__Program_Enrollment__c WHERE hed__Contact__c = :studentUser.ContactId LIMIT 1];

        Test.startTest();
        System.runAs(studentUser) {
            MySwpsIndividualApplicationFormCtrl.submitApplication(company, representative, supervisor, offer, consentWrapper, application, new List<Id>(), studentUser.ContactId, programEnrollment.Id);
        }
        Test.stopTest();

        List<TB_Consent__c> createdConsents = [SELECT Id FROM TB_Consent__c WHERE TB_Contact__c = :studentUser.ContactId];
        Career_Services_Application__c postInsertApplication = [SELECT Id, (SELECT Id FROM Internship_Settlements__r) FROM Career_Services_Application__c WHERE Student__c = :studentUser.ContactId];

        Assert.isNotNull(application.Id);
        Assert.isNotNull(offer.Id);
        Assert.isNotNull(company.Id);
        Assert.isNotNull(representative.Id);
        Assert.isNotNull(supervisor.Id);
        Assert.areEqual(1, createdConsents.size());
        Assert.areEqual(representative.Id, offer.Organisation_Contact__c);
        Assert.areEqual(0, postInsertApplication.Internship_Settlements__r.size());
    }

    @IsTest
    public static void submitObligatoryApplicationSuccess() {
        Account company = new AccountTestData()
            .withName('Test company')
            .withCountryCode('PL')
            .withPostalCode('00-001')
            .withCity('Warsaw')
            .withStreet('Andersena 3')
            .withTaxId('1231231231')
            .withNationalCourtRegister('0000385161')
            .withRecordType(ACCOUNT_BUSINESS_ORGANIZATION_RECORD_TYPE_ID)
            .get();

        Contact representative = new ContactTestData()
            .withFirstName('Mariusz')
            .withLastName('Pudzianowski')
            .withRecordType(CONTACT_PARTNER_RECORD_TYPE_ID)
            .withWorkPhone('123123123')
            .withWorkEmail('pudzian@test.invalid')
            .get();

        Contact supervisor = new ContactTestData()
            .withFirstName('Franciszek')
            .withLastName('Zamek')
            .withRecordType(CONTACT_PARTNER_RECORD_TYPE_ID)
            .withWorkPhone('333444555')
            .withWorkEmail('frank@castle.invalid')
            .get();

        Career_Services_Offer__c offer = new CsOfferTestData()
            .withInstitutionWebsite('https://www.test.pl')
            .withOfferTitle('Salesforce Developer')
            .withDescriptionOfCompletedTasks('24/7 CRUDS')
            .withInternshipClockHours(100)
            .withExternalSupervisorEducation(Constants.CAREER_SERVICES_OFFER_EXTERNAL_SUPERVISOR_EDUCATION_OTHER)
            .withRecordType(OFFER_INDIVIDUAL_INTERNSHIP_RECORD_TYPE_ID)
            .get();

        Career_Services_Application__c application = new CsApplicationTestData()
            .withCommencementDate(Date.today())
            .withCompletionDate(Date.today().addDays(1))
            .withRecordType(APPLICATION_INDIVIDUAL_INTERNSHIP_RECORD_TYPE_ID)
            .asObligatory()
            .get();

        MySwpsIndividualApplicationFormCtrl.InternshipApplicationConsentsWrapper consentWrapper = getConsentWrapper(true);

        User studentUser = [SELECT Id, ContactId FROM User WHERE CommunityNickname = :TEST_STUDENT_USER_COMMUNITY_NICKNAME LIMIT 1];
        hed__Program_Enrollment__c programEnrollment = [SELECT Id FROM hed__Program_Enrollment__c WHERE hed__Contact__c = :studentUser.ContactId LIMIT 1];

        List<Id> selectedRequirementIds = new List<Id>();
        for (Internship_Requirement__c requirement : [SELECT Id FROM Internship_Requirement__c WHERE Program_Enrollment__c = :programEnrollment.Id]) {
            selectedRequirementIds.add(requirement.Id);
        }

        Test.startTest();
        System.runAs(studentUser) {
            MySwpsIndividualApplicationFormCtrl.submitApplication(company, representative, supervisor, offer, consentWrapper, application, selectedRequirementIds, studentUser.ContactId, programEnrollment.Id);
        }
        Test.stopTest();

        List<TB_Consent__c> createdConsents = [SELECT Id FROM TB_Consent__c WHERE TB_Contact__c = :studentUser.ContactId];
        Career_Services_Application__c postInsertApplication = [SELECT Id, (SELECT Id FROM Internship_Settlements__r) FROM Career_Services_Application__c WHERE Student__c = :studentUser.ContactId];

        Assert.isNotNull(application.Id);
        Assert.isNotNull(offer.Id);
        Assert.isNotNull(company.Id);
        Assert.isNotNull(representative.Id);
        Assert.isNotNull(supervisor.Id);
        Assert.areEqual(1, createdConsents.size());
        Assert.areEqual(representative.Id, offer.Organisation_Contact__c);
        Assert.areEqual(selectedRequirementIds.size(), postInsertApplication.Internship_Settlements__r.size());
    }

    @IsTest
    public static void submitApplicationPartnerExistsForOtherCompanySuccess() {
        Account company = new AccountTestData()
            .withName('Test company')
            .withCountryCode('PL')
            .withPostalCode('00-001')
            .withCity('Warsaw')
            .withStreet('Andersena 3')
            .withTaxId('1231231231')
            .withNationalCourtRegister('0000385161')
            .withRecordType(ACCOUNT_BUSINESS_ORGANIZATION_RECORD_TYPE_ID)
            .get();

        Contact representative = new ContactTestData()
            .withFirstName('Mariusz')
            .withLastName('Pudzianowski')
            .withRecordType(CONTACT_PARTNER_RECORD_TYPE_ID)
            .withWorkPhone('123123123')
            .withWorkEmail('pudzian@test.invalid')
            .get();

        Contact supervisor = new ContactTestData()
            .withFirstName('Łukasz')
            .withLastName('klatka')
            .withRecordType(CONTACT_PARTNER_RECORD_TYPE_ID)
            .withWorkPhone('555444333')
            .withWorkEmail(EXISTING_SUPERVISOR_CONTACT_WORK_EMAIL)
            .get();

        Career_Services_Offer__c offer = new CsOfferTestData()
            .withInstitutionWebsite('https://www.test.pl')
            .withOfferTitle('Salesforce Developer')
            .withDescriptionOfCompletedTasks('24/7 CRUDS')
            .withInternshipClockHours(100)
            .withExternalSupervisorEducation(Constants.CAREER_SERVICES_OFFER_EXTERNAL_SUPERVISOR_EDUCATION_OTHER)
            .withRecordType(OFFER_INDIVIDUAL_INTERNSHIP_RECORD_TYPE_ID)
            .get();

        Career_Services_Application__c application = new CsApplicationTestData()
            .withCommencementDate(Date.today())
            .withCompletionDate(Date.today().addDays(1))
            .withRecordType(APPLICATION_INDIVIDUAL_INTERNSHIP_RECORD_TYPE_ID)
            .get();


        MySwpsIndividualApplicationFormCtrl.InternshipApplicationConsentsWrapper consentWrapper = getConsentWrapper(false);

        User studentUser = [SELECT Id, ContactId FROM User WHERE CommunityNickname = :TEST_STUDENT_USER_COMMUNITY_NICKNAME LIMIT 1];
        hed__Program_Enrollment__c programEnrollment = [SELECT Id FROM hed__Program_Enrollment__c WHERE hed__Contact__c = :studentUser.ContactId LIMIT 1];

        Integer preSubmitAccountContactRelationCount = [SELECT Id FROM AccountContactRelation WHERE Contact.hed__WorkEmail__c = :EXISTING_SUPERVISOR_CONTACT_WORK_EMAIL].size();

        Test.startTest();
        System.runAs(studentUser) {
            MySwpsIndividualApplicationFormCtrl.submitApplication(company, representative, supervisor, offer, consentWrapper, application, new List<Id>(), studentUser.ContactId, programEnrollment.Id);
        }
        Test.stopTest();

        Integer postSubmitAccountContactRelationCount = [SELECT Id FROM AccountContactRelation WHERE Contact.hed__WorkEmail__c = :EXISTING_SUPERVISOR_CONTACT_WORK_EMAIL].size();

        Assert.isTrue(postSubmitAccountContactRelationCount > preSubmitAccountContactRelationCount);
    }

    private static MySwpsIndividualApplicationFormCtrl.InternshipApplicationConsentsWrapper getConsentWrapper(Boolean withCheckedConsentIds) {
        MySwpsIndividualApplicationFormCtrl.InternshipApplicationConsentsWrapper consentWrapper = new MySwpsIndividualApplicationFormCtrl.InternshipApplicationConsentsWrapper();
        consentWrapper.formUrl = 'www.test-url.pl';
        consentWrapper.userDetails = 'testUserDetails';
        consentWrapper.checkedConsentIds = new List<Id>();

        if (withCheckedConsentIds) {
            for (TB_Admissions_Dictionary__c dictionary : [SELECT Id FROM TB_Admissions_Dictionary__c WHERE RecordTypeId = :ADMISSIONS_DICTIONARY_CONSENT_DEFINITION_RECORD_TYPE_ID]) {
                consentWrapper.checkedConsentIds.add(dictionary.Id);
            }
        }

        return consentWrapper;
    }
}