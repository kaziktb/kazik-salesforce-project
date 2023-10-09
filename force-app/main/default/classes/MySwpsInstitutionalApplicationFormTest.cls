@IsTest
private class MySwpsInstitutionalApplicationFormTest {
    private static final String TEST_STUDENT_USER_COMMUNITY_NICKNAME = 'Super Test Nickname';
    private static final String EXISTING_SUPERVISOR_CONTACT_WORK_EMAIL = 'luke@cage.invalid';
    private static final String TEST_COMPANY_NAME = 'In Hot Water Company';
    private static final Id CONTACT_PARTNER_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(Contact.getSObjectType(), Constants.CONTACT_PARTNER_RECORD_TYPE_DEV_NAME);
    private static final Id ACCOUNT_BUSINESS_ORGANIZATION_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(Account.getSObjectType(), Constants.ACCOUNT_RECORD_TYPE_BUSINESS_ORGANIZATION_API_NAME);
    private static final Id ADMISSIONS_DICTIONARY_CONSENT_DEFINITION_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(TB_Admissions_Dictionary__c.getSObjectType(), TB_Constants.TB_CONSENT_CONSENT_DEFINITION_RT_DEVNAME);
    private static final Id CAREER_SERVICES_OFFER_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP = Utils.getRecordTypeIdByDevName(Career_Services_Offer__c.getSObjectType(), Constants.CAREER_SERVICES_OFFER_RT_INSTITUTIONAL_INTERNSHIP);
    private static final Id CAREER_SERVICES_APPLICATION_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP = Utils.getRecordTypeIdByDevName(Career_Services_Application__c.getSObjectType(), Constants.CAREER_SERVICES_APPLICATION_RT_INSTITUTIONAL_INTERNSHIP);

    @TestSetup
    public static void setup() {
        User admin = UserTestDataFactory.createAdminUser(true);

        System.runAs(admin) {

            Account company = new AccountTestData()
                .withName(TEST_COMPANY_NAME)
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

            Career_Services_Offer__c offer = new CsOfferTestData()
                .withRecordType(CAREER_SERVICES_OFFER_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP)
                .withStatus(Constants.CAREER_SERVICES_OFFER_STATUS_PUBLISHED_API_NAME)
                .withCompany(company.Id)
                .withOrganisationContact(supervisor.Id)
                .withExternalSupervisor(supervisor.Id)
                .save()
                .get();

            Contract contract = ContractTestDataFactory.createContract(company.Id, Constants.CONTRACT_STATUS_NOT_IMPLEMENTED_API_NAME, false);

            Account academicProgram = AccountTestDataFactory.createAcademicProgram(false);
            Account department = AccountTestDataFactory.createDepartment(false);
            Account specialty = AccountTestDataFactory.createSpecialty(false);
            Account pathway = AccountTestDataFactory.createPathway(false);

            Contact studentContact = ContactTestDataFactory.createStudent(false);
            hed__Program_Plan__c programPlan = ProgramPlanTestDataFactory.createCurrent(1, false).get(0);
            TB_Admissions_Dictionary__c bundle = AdmissionsDictionaryTestDataFactory.createCareerOfficeConsentBundle(1, true)[0];
            List<TB_Admissions_Dictionary__c> consentDefinitions = AdmissionsDictionaryTestDataFactory.createCareerOfficeConsentDefinition(
                2,
                bundle.Id,
                Constants.ADMISSIONS_DICTIONARY_CONSENT_TYPE_TERMS_AND_CONDITIONS,
                true
            );

            insert new SObject[]{
                academicProgram, contract, department, specialty, pathway, studentContact, programPlan, supervisor
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
        }
    }

    @IsTest
    public static void submitNonObligatoryApplicationSuccess() {
        Id applicationId;
        User studentUser = [SELECT ContactId FROM User WHERE CommunityNickname = :TEST_STUDENT_USER_COMMUNITY_NICKNAME LIMIT 1];

        hed__Education_History__c educationHistory = [
            SELECT Id, Name, (
                SELECT Id
                FROM hed__Program_Enrollments__r
                ORDER BY hed__Start_Date__c DESC
                LIMIT 1
            )
            FROM hed__Education_History__c
            WHERE hed__Contact__c = :studentUser.ContactId
            AND hed__Status__c = :Constants.EDUCATION_HISTORY_STATUS_STUDYING
            LIMIT 1
        ];
        hed__Program_Enrollment__c programEnrollment = educationHistory.hed__Program_Enrollments__r.get(0);

        Contract contract = [SELECT Id FROM Contract LIMIT 1];

        Account academicProgram = [
            SELECT Id
            FROM Account
            WHERE RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_ACADEMIC_PROGRAM_API_NAME
            AND DT_Account_Type__c = :Constants.ACCOUNT_TYPE_ACADEMIC_PROGRAM_API_NAME
            LIMIT 1
        ];

        Account specialty = [
            SELECT Id
            FROM Account
            WHERE RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_SPECIALTY_API_NAME
            AND DT_Account_Type__c = :Constants.ACCOUNT_TYPE_SPECIALTY_API_NAME
            LIMIT 1
        ];

        Account pathway = [
            SELECT Id
            FROM Account
            WHERE RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_SPECIALTY_API_NAME
            AND DT_Account_Type__c = :Constants.ACCOUNT_TYPE_PATHWAY_API_NAME
            LIMIT 1
        ];

        Account company = [SELECT Id FROM Account WHERE Name = :TEST_COMPANY_NAME LIMIT 1];
        Career_Services_Offer__c offer = [SELECT Id FROM Career_Services_Offer__c WHERE Company__c = :company.Id LIMIT 1];

        Career_Services_Offer_Assignment__c offerAssignment = new CsOfferAssignmentTestData()
            .withOffer(offer.Id)
            .withAccount(pathway.Id)
            .withIsObligatory(false)
            .asAccepted()
            .get();

        Career_Services_Offer_Contract__c offerContract = CsOfferContractTestDataFactory.createPublishedOfferContract(contract.Id, offer.Id, false);
        insert new List<SObject>{
            offerAssignment, offerContract
        };

        Test.startTest();
        MySwpsInstitutionalApplicationFormCtrl.InternshipApplicationConsentsWrapper consentWrapper = getConsentWrapper(true);
        MySwpsInstitutionalApplicationFormCtrl.FormInitialDataWrapper wrapper;
        System.runAs(studentUser) {
            Assert.isTrue(MySwpsUtils.checkInternshipOfferAssignmentsMatch(offer.Id));
            wrapper = MySwpsInstitutionalApplicationFormCtrl.fetchFormInitialData(Constants.LANGUAGE_LOCALE_KEY_POLISH, offer.Id);
            applicationId = MySwpsInstitutionalApplicationFormCtrl.submitApplication(offer.Id, consentWrapper, null, studentUser.ContactId, programEnrollment.Id, false);

            MySwpsFileInputController.FileWrapper fileWrapper = new MySwpsFileInputController.FileWrapper();
            fileWrapper.base64 = EncodingUtil.base64Encode(Blob.valueOf('Mock'));
            fileWrapper.fileName = 'Test.pdf';
            MySwpsFileInputController.fileHandler(fileWrapper, applicationId);
        }
        Test.stopTest();
        Assert.isNotNull(wrapper);
        Assert.isFalse(wrapper.hasAnyRequirement);
        Assert.areNotEqual(0, wrapper.educationHistories.size());
        Assert.areEqual(studentUser.ContactId, wrapper.studentContactId);

        List<TB_Consent__c> createdConsents = [SELECT Id FROM TB_Consent__c WHERE TB_Contact__c = :studentUser.ContactId];
        Career_Services_Application__c postInsertApplication = [
            SELECT Id, RecordTypeId, (SELECT Id FROM Internship_Settlements__r), (SELECT Id FROM ContentDocumentLinks)
            FROM Career_Services_Application__c
            WHERE Student__c = :studentUser.ContactId
        ];

        Assert.isNotNull(applicationId);
        Assert.areEqual(postInsertApplication.RecordTypeId, CAREER_SERVICES_APPLICATION_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP);
        Assert.isNotNull(offer.Id);
        Assert.areEqual(2, createdConsents.size());
        Assert.areEqual(0, postInsertApplication.Internship_Settlements__r.size());
        Assert.areEqual(1, postInsertApplication.ContentDocumentLinks.size());

    }

    @IsTest
    public static void submitObligatoryApplicationSuccess() {
        Id applicationId;
        User studentUser = [SELECT ContactId FROM User WHERE CommunityNickname = :TEST_STUDENT_USER_COMMUNITY_NICKNAME LIMIT 1];

        hed__Education_History__c educationHistory = [
            SELECT Id, Name, (
                SELECT Id FROM hed__Program_Enrollments__r ORDER BY hed__Start_Date__c DESC LIMIT 1
            )
            FROM hed__Education_History__c
            WHERE hed__Contact__c = :studentUser.ContactId
            AND hed__Status__c = :Constants.EDUCATION_HISTORY_STATUS_STUDYING
            LIMIT 1
        ];
        hed__Program_Enrollment__c programEnrollment = educationHistory.hed__Program_Enrollments__r.get(0);

        Contract contract = [SELECT Id FROM Contract LIMIT 1];

        Account academicProgram = [
            SELECT Id
            FROM Account
            WHERE RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_ACADEMIC_PROGRAM_API_NAME
            AND DT_Account_Type__c = :Constants.ACCOUNT_TYPE_ACADEMIC_PROGRAM_API_NAME LIMIT 1
        ];

        Account specialty = [
            SELECT Id
            FROM Account
            WHERE RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_SPECIALTY_API_NAME
            AND DT_Account_Type__c = :Constants.ACCOUNT_TYPE_SPECIALTY_API_NAME LIMIT 1
        ];

        Account pathway = [
            SELECT Id
            FROM Account
            WHERE RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_SPECIALTY_API_NAME
            AND DT_Account_Type__c = :Constants.ACCOUNT_TYPE_PATHWAY_API_NAME LIMIT 1
        ];

        Account company = [SELECT Id FROM Account WHERE Name = :TEST_COMPANY_NAME LIMIT 1];
        Career_Services_Offer__c offer = [SELECT Id FROM Career_Services_Offer__c WHERE Company__c = :company.Id LIMIT 1];

        Internship_Issuance__c issuance = InternshipIssuanceTestDataFactory.create(100, 1, false).get(0);
        Internship_Group__c internshipGroup = InternshipGroupTestDataFactory.create(academicProgram.Id, issuance.Id, 1, false).get(0);
        internshipGroup.Specialty__c = specialty.Id;
        internshipGroup.Pathway__c = pathway.Id;
        insert internshipGroup;

        Internship_Requirement__c requirement = InternshipRequirementTestDataFactory.create(educationHistory.Id, internshipGroup.Id, 1, false).get(0);
        requirement.Program_Enrollment__c = programEnrollment.Id;
        insert requirement;

        Career_Services_Offer_Assignment__c offerAssignment = new CsOfferAssignmentTestData()
            .withOffer(offer.Id)
            .withAccount(pathway.Id)
            .withIsObligatory(true)
            .asAccepted()
            .get();

        Career_Services_Offer_Contract__c offerContract = CsOfferContractTestDataFactory.createPublishedOfferContract(contract.Id, offer.Id, false);
        insert new List<SObject>{offerAssignment, offerContract};

        Test.startTest();
        MySwpsInstitutionalApplicationFormCtrl.InternshipApplicationConsentsWrapper consentWrapper = getConsentWrapper(true);
        List<Id> selectedRequirementIds = new List<Id>{requirement.Id};

        MySwpsInstitutionalApplicationFormCtrl.FormInitialDataWrapper wrapper;
        System.runAs(studentUser) {
            Assert.isTrue(MySwpsUtils.checkInternshipOfferAssignmentsMatch(offer.Id));
            wrapper = MySwpsInstitutionalApplicationFormCtrl.fetchFormInitialData(Constants.LANGUAGE_LOCALE_KEY_POLISH, offer.Id);
            applicationId = MySwpsInstitutionalApplicationFormCtrl.submitApplication(offer.Id, consentWrapper, selectedRequirementIds, studentUser.ContactId, programEnrollment.Id, true);

            MySwpsFileInputController.FileWrapper fileWrapper = new MySwpsFileInputController.FileWrapper();
            fileWrapper.base64 = EncodingUtil.base64Encode(Blob.valueOf('Mock'));
            fileWrapper.fileName = 'Test.pdf';
            MySwpsFileInputController.fileHandler(fileWrapper, applicationId);
        }
        Test.stopTest();
        Assert.isNotNull(wrapper);
        Assert.isTrue(wrapper.hasAnyRequirement);
        Assert.areNotEqual(0, wrapper.educationHistories.size());
        Assert.areEqual(studentUser.ContactId, wrapper.studentContactId);

        List<TB_Consent__c> createdConsents = [SELECT Id FROM TB_Consent__c WHERE TB_Contact__c = :studentUser.ContactId];
        Career_Services_Application__c postInsertApplication = [
            SELECT Id, RecordTypeId, (SELECT Id FROM Internship_Settlements__r), (SELECT Id FROM ContentDocumentLinks)
            FROM Career_Services_Application__c
            WHERE Student__c = :studentUser.ContactId
        ];

        Assert.isNotNull(applicationId);
        Assert.areEqual(postInsertApplication.RecordTypeId, CAREER_SERVICES_APPLICATION_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP);
        Assert.isNotNull(offer.Id);
        Assert.areEqual(2, createdConsents.size());
        Assert.areEqual(selectedRequirementIds.size(), postInsertApplication.Internship_Settlements__r.size());
        Assert.areEqual(1, postInsertApplication.ContentDocumentLinks.size());
    }

    private static MySwpsInstitutionalApplicationFormCtrl.InternshipApplicationConsentsWrapper getConsentWrapper(Boolean withCheckedConsentIds) {
        MySwpsInstitutionalApplicationFormCtrl.InternshipApplicationConsentsWrapper consentWrapper = new MySwpsInstitutionalApplicationFormCtrl.InternshipApplicationConsentsWrapper();
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