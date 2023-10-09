@IsTest
public class CsOfferAssignmentModalControllerTest {

    @TestSetup
    static void setup() {
        Contact contact = new ContactTestData().save().get();
        User user = UserTestDataFactory.createCareerServicesUser('user@test.abc', true);
        InternshipSupervisorTestDataFactory.createInternshipSupervisor(contact.Id, user.Id, Constants.INTERNSHIP_SUPERVISOR_TYPE_SUPERVISOR, 'Supervisor', true);

        Account mainDepartment = AccountTestDataFactory.createDepartment(false);
        mainDepartment.Name = Constants.ACCOUNT_DEPARTMENT_ACCOUNT_NAME;
        insert mainDepartment;

        Account department = AccountTestDataFactory.createDepartment(false);
        department.Name = 'Department';
        department.ParentId = mainDepartment.Id;
        insert department;

        Account academicProgram = AccountTestDataFactory.createAcademicProgram(false);
        academicProgram.Name = 'Academic Program';
        academicProgram.ParentId = department.Id;
        insert academicProgram;

        Account specialty = AccountTestDataFactory.createSpecialty(false);
        specialty.Name = 'Specialty';
        specialty.ParentId = academicProgram.Id;
        specialty.DT_Has_Active_Students__c = true;
        insert specialty;
        
        Account pathway = AccountTestDataFactory.createPathway(false);
        pathway.Name = 'Pathway';
        pathway.ParentId = specialty.Id;
        insert pathway;
    }

    @IsTest
    static void fetchInitialDataTest() {
        Test.startTest();
        CsOfferAssignmentModalController.InitialDataWrapper wrapper = CsOfferAssignmentModalController.fetchInitialData();
        Test.stopTest();

        Assert.isTrue(wrapper.supervisors.size() == 1, 'There should be exactly one Internship Supervisor record');
        Assert.isTrue(wrapper.departments.size() == 1, 'There should be exactly one department Account with parent Account ' + Constants.ACCOUNT_DEPARTMENT_ACCOUNT_NAME);
    }

    @IsTest
    static void fetchOfferAssignmentDataTestDepartment() {
        Account department = [SELECT Id FROM Account WHERE Name = 'Department'];
        String type = 'department';

        CsOfferAssignmentModalController.OfferAssignmentWrapper wrapper = new CsOfferAssignmentModalController.OfferAssignmentWrapper();
        wrapper.supervisor = 'supervisor';
        wrapper.department = 'department';
        wrapper.academicProgram = 'academicProgram';
        wrapper.specialty = 'specialty';

        Test.startTest();
        wrapper = CsOfferAssignmentModalController.fetchOfferAssignmentData(type, department.Id, wrapper);
        Test.stopTest();

        Assert.areEqual(1, wrapper.academicProgramOptions.size(), 'There should be exactly one academic program Account with provided parent Account');
        Assert.areEqual(null, wrapper.academicProgram);
        Assert.areEqual(null, wrapper.specialty);
    }

    @IsTest
    static void fetchOfferAssignmentDataTestAcademicProgram() {
        Account academicProgram = [SELECT Id FROM Account WHERE Name = 'Academic Program'];
        String type = 'academicProgram';

        CsOfferAssignmentModalController.OfferAssignmentWrapper wrapper = new CsOfferAssignmentModalController.OfferAssignmentWrapper();
        wrapper.specialty = 'specialty';

        Test.startTest();
        wrapper = CsOfferAssignmentModalController.fetchOfferAssignmentData(type, academicProgram.Id, wrapper);
        Test.stopTest();

        Assert.areEqual(1, wrapper.specialtyOptions.size(), 'There should be exactly one specialty Account with provided parent Account');
        Assert.areEqual(null, wrapper.specialty);
    }

    @IsTest
    static void fetchOfferAssignmentDataTestSpecialty() {
        Account specialty = [SELECT Id FROM Account WHERE Name = 'Specialty'];
        String type = 'specialty';

        CsOfferAssignmentModalController.OfferAssignmentWrapper wrapper = new CsOfferAssignmentModalController.OfferAssignmentWrapper();

        Test.startTest();
        wrapper = CsOfferAssignmentModalController.fetchOfferAssignmentData(type, specialty.Id, wrapper);
        Test.stopTest();

        Assert.areEqual(1, wrapper.pathwayOptions.size(), 'There should be exactly one pathway Account with provided parent Account');
    }

}