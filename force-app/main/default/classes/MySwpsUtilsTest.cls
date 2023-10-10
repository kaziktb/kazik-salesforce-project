@IsTest
private class MySwpsUtilsTest {

    private static final String TEST_STUDENT_USER_COMMUNITY_NICKNAME = 'Super Test Nickname';
    private static final String EXISTING_SUPERVISOR_CONTACT_WORK_EMAIL = 'peter@parker.invalid';
    private static final String TEST_ADMIN_USERNAME = 'super@admin.invalid';
    private static final Id CONTACT_PARTNER_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(Contact.getSObjectType(), Constants.CONTACT_PARTNER_RECORD_TYPE_DEV_NAME);
    private static final Id ACCOUNT_BUSINESS_ORGANIZATION_RECORD_TYPE_ID = Utils.getRecordTypeIdByDevName(Account.getSObjectType(), Constants.ACCOUNT_RECORD_TYPE_BUSINESS_ORGANIZATION_API_NAME);
    private final static Id CAREER_SERVICES_OFFER_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP = Utils.getRecordTypeIdByDevName(Career_Services_Offer__c.getSObjectType(), Constants.CAREER_SERVICES_OFFER_RT_INSTITUTIONAL_INTERNSHIP);

    @TestSetup
    private static void setup() {
        User admin = UserTestDataFactory.createAdminUserWithPermissionSetAssigned(TEST_ADMIN_USERNAME);

        System.runAs(admin) {
            Account company = new AccountTestData()
                .withName('Cena Wodny Dom Bednarze')
                .withCountryCode('PL')
                .withPostalCode('00-001')
                .withCity('Warsaw')
                .withStreet('Polna 11')
                .withTaxId('4445556662')
                .withNationalCourtRegister('0000385144')
                .withRecordType(ACCOUNT_BUSINESS_ORGANIZATION_RECORD_TYPE_ID)
                .save()
                .get();

            new ContactTestData()
                .withFirstName('Peter')
                .withLastName('Parker')
                .withRecordType(CONTACT_PARTNER_RECORD_TYPE_ID)
                .withWorkPhone('888777566')
                .withWorkEmail(EXISTING_SUPERVISOR_CONTACT_WORK_EMAIL)
                .withCompany(company.Id)
                .save();

            Contract contract = ContractTestDataFactory.createContract(company.Id, Constants.CONTRACT_STATUS_NOT_IMPLEMENTED_API_NAME, false);
            Account academicProgram = AccountTestDataFactory.createAcademicProgram(false);
            Account department = AccountTestDataFactory.createDepartment(false);
            Account specialty = AccountTestDataFactory.createSpecialty(false);
            Account pathway = AccountTestDataFactory.createPathway(false);

            Contact studentContact = ContactTestDataFactory.createStudent(false);
            hed__Program_Plan__c programPlan = ProgramPlanTestDataFactory.createCurrent(1, false).get(0);

            insert new SObject[]{
                contract, academicProgram, department, specialty, pathway, studentContact, programPlan
            };
            academicProgram.DT_Department__c = department.Id;
            update academicProgram;

            UserTestDataFactory.createCommunityStudentUser(studentContact.Id, 'communityStudent@test.invalid', TEST_STUDENT_USER_COMMUNITY_NICKNAME, true);
            hed__Education_History__c educationHistory = EducationHistoryTestDataFactory.createWithStatusStudying(studentContact.Id, 1, true).get(0);
            ProgramEnrollmentTestDataFactory.createWithProgramPlan(studentContact.Id, academicProgram.Id, educationHistory.Id, programPlan.Id, 1, true);
        }
    }

    @IsTest
    private static void createFormContactsWithRelations() {
        User adminUser = [SELECT Id FROM User WHERE Username = :TEST_ADMIN_USERNAME];

        Account company = new AccountTestData()
            .withName('Test company')
            .withCountryCode('PL')
            .withPostalCode('00-001')
            .withCity('Warsaw')
            .withStreet('Andersena 3')
            .withTaxId('1231231231')
            .withNationalCourtRegister('0000385161')
            .withRecordType(ACCOUNT_BUSINESS_ORGANIZATION_RECORD_TYPE_ID)
            .save()
            .get();

        Contact representative = new ContactTestData()
            .withFirstName('Peter')
            .withLastName('Parker')
            .withRecordType(CONTACT_PARTNER_RECORD_TYPE_ID)
            .withWorkPhone('888777566')
            .withWorkEmail(EXISTING_SUPERVISOR_CONTACT_WORK_EMAIL)
            .get();

        Contact supervisor = new ContactTestData()
            .withFirstName('Kaniel')
            .withLastName('Outis')
            .withRecordType(CONTACT_PARTNER_RECORD_TYPE_ID)
            .withWorkPhone('765543321')
            .withWorkEmail('kaniel@outis.invalid')
            .get();

        Map<String, Contact> workEmail2FormContact = new Map<String, Contact>{
            representative.hed__WorkEmail__c => representative,
            supervisor.hed__WorkEmail__c => supervisor
        };

        Integer preSubmitAccountContactRelationCount = [SELECT Id FROM AccountContactRelation WHERE AccountId = :company.Id].size();

        Test.startTest();
        System.runAs(adminUser) {
            MySwpsUtils.createFormContactsWithAccountRelation(workEmail2FormContact, company.Id);
        }
        Test.stopTest();

        Integer postSubmitAccountContactRelationCount = [SELECT Id FROM AccountContactRelation WHERE AccountId = :company.Id].size();

        Assert.isTrue(postSubmitAccountContactRelationCount > preSubmitAccountContactRelationCount);
    }

    @IsTest
    private static void createFormContactsWithRelationsWhenOneAlreadyExists() {
        User adminUser = [SELECT Id FROM User WHERE Username = :TEST_ADMIN_USERNAME];
        Account company = [SELECT Id FROM Account LIMIT 1];

        Contact supervisor = new ContactTestData()
            .withFirstName('Kaniel')
            .withLastName('Outis')
            .withRecordType(CONTACT_PARTNER_RECORD_TYPE_ID)
            .withWorkPhone('765543321')
            .withWorkEmail('kaniel@outis.invalid')
            .withCompany(company.Id)
            .save()
            .get();

        Map<String, Contact> workEmail2FormContact = new Map<String, Contact>{
            supervisor.hed__WorkEmail__c => supervisor
        };

        Integer preSubmitAccountContactRelationCount = [SELECT Id FROM AccountContactRelation WHERE AccountId = :company.Id].size();

        Test.startTest();
        System.runAs(adminUser) {
            MySwpsUtils.createFormContactsWithAccountRelation(workEmail2FormContact, company.Id);
        }
        Test.stopTest();

        Integer postSubmitAccountContactRelationCount = [SELECT Id FROM AccountContactRelation WHERE AccountId = :company.Id].size();

        Assert.areEqual(preSubmitAccountContactRelationCount, postSubmitAccountContactRelationCount);
    }

    @IsTest
    public static void checkInternshipOfferAssignmentsMatchSuccessTest() {
        User admin = [SELECT Id FROM User WHERE ProfileId = :Utils.getProfileIdByName(Label.System_Administrator_Profile_Name) AND IsActive = TRUE LIMIT 1];
        Account company = [SELECT Id FROM Account WHERE RecordTypeId = :ACCOUNT_BUSINESS_ORGANIZATION_RECORD_TYPE_ID LIMIT 1];
        Contact supervisor = [SELECT Id FROM Contact WHERE RecordTypeId = :CONTACT_PARTNER_RECORD_TYPE_ID AND AccountId = :company.Id LIMIT 1];
        User studentUser = [SELECT ContactId FROM User WHERE CommunityNickname = :TEST_STUDENT_USER_COMMUNITY_NICKNAME LIMIT 1];
        Career_Services_Offer__c offer;

        System.runAs(admin) {
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

            offer = new CsOfferTestData()
                .withRecordType(CAREER_SERVICES_OFFER_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP)
                .withStatus(Constants.CAREER_SERVICES_OFFER_STATUS_PUBLISHED_API_NAME)
                .withCompany(company.Id)
                .withOrganisationContact(supervisor.Id)
                .withExternalSupervisor(supervisor.Id)
                .save()
                .get();

            Career_Services_Offer_Contract__c offerContract = CsOfferContractTestDataFactory.createPublishedOfferContract(contract.Id, offer.Id, false);

            Career_Services_Offer_Assignment__c offerAssignment = new CsOfferAssignmentTestData()
                .withOffer(offer.Id)
                .withAccount(pathway.Id)
                .withIsObligatory(true)
                .asAccepted()
                .get();

            insert new List<SObject>{
                offerAssignment, offerContract
            };

            Internship_Issuance__c issuance = InternshipIssuanceTestDataFactory.create(100, 1, false).get(0);
            Internship_Group__c internshipGroup = InternshipGroupTestDataFactory.create(academicProgram.Id, issuance.Id, 1, false).get(0);
            internshipGroup.Specialty__c = specialty.Id;
            internshipGroup.Pathway__c = pathway.Id;
            insert internshipGroup;

            Internship_Requirement__c requirement = InternshipRequirementTestDataFactory.create(educationHistory.Id, internshipGroup.Id, 1, false).get(0);
            requirement.Program_Enrollment__c = programEnrollment.Id;
            insert requirement;
        }
        Test.startTest();
        System.runAs(studentUser) {
            Assert.isTrue(MySwpsUtils.checkInternshipOfferAssignmentsMatch(offer.Id));
        }
        Test.stopTest();
    }

    @IsTest
    public static void checkInternshipOfferAssignmentsMatchFailTest() {
        User admin = [SELECT Id FROM User WHERE ProfileId = :Utils.getProfileIdByName(Label.System_Administrator_Profile_Name) AND IsActive = TRUE LIMIT 1];
        Account company = [SELECT Id FROM Account WHERE RecordTypeId = :ACCOUNT_BUSINESS_ORGANIZATION_RECORD_TYPE_ID LIMIT 1];
        Contact supervisor = [SELECT Id FROM Contact WHERE RecordTypeId = :CONTACT_PARTNER_RECORD_TYPE_ID AND AccountId = :company.Id LIMIT 1];
        User studentUser = [SELECT ContactId FROM User WHERE CommunityNickname = :TEST_STUDENT_USER_COMMUNITY_NICKNAME LIMIT 1];
        Career_Services_Offer__c offer;

        System.runAs(admin) {
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

            offer = new CsOfferTestData()
                .withRecordType(CAREER_SERVICES_OFFER_RECORD_TYPE_ID_INSTITUTIONAL_INTERNSHIP)
                .withStatus(Constants.CAREER_SERVICES_OFFER_STATUS_PUBLISHED_API_NAME)
                .withCompany(company.Id)
                .withOrganisationContact(supervisor.Id)
                .withExternalSupervisor(supervisor.Id)
                .save()
                .get();

            Career_Services_Offer_Contract__c offerContract = CsOfferContractTestDataFactory.createPublishedOfferContract(contract.Id, offer.Id, false);

            Career_Services_Offer_Assignment__c offerAssignment = new CsOfferAssignmentTestData()
                .withOffer(offer.Id)
                .withAccount(pathway.Id)
                .withIsObligatory(true)
                .asAccepted()
                .get();

            insert new List<SObject>{
                offerAssignment, offerContract
            };

        }
        Test.startTest();
        System.runAs(studentUser) {
            Assert.isFalse(MySwpsUtils.checkInternshipOfferAssignmentsMatch(offer.Id));
        }
        Test.stopTest();
    }
}