@IsTest
public class CsSupervisorApprovalsControllerTest {
    private static final String SUPERVISOR_USER_USERNAME = 'supervisoruser@test.invalid';
    private static final String CONTACT_WORK_EMAIL = 'workemail@test.invalid';

    @TestSetup
    static void setup() {
        User supervisorUser = UserTestDataFactory.createCareerServicesUserWithPermissionSetAssigned(SUPERVISOR_USER_USERNAME);

        System.runAs(supervisorUser) {
            Contact contact = new ContactTestData().withWorkEmail(CONTACT_WORK_EMAIL).save().get();
            Internship_Supervisor__c internshipSupervisor = InternshipSupervisorTestDataFactory.createInternshipSupervisor(contact.Id, supervisorUser.Id, Constants.INTERNSHIP_SUPERVISOR_TYPE_SUPERVISOR, 'Supervisor', true);

            Account academicProgram = AccountTestDataFactory.createAcademicProgram(true);

            Career_Services_Offer__c offer = CsOfferTestDataFactory.createInstitutionalInternshipOffer(true);
            CsOfferAssignmentTestDataFactory.createAssignment(academicProgram.Id, offer.Id, internshipSupervisor.Id, true);

            Career_Services_Application__c application = CsApplicationTestDataFactory.createApplicationWithRecordTypeAndOffer(Constants.CAREER_SERVICES_APPLICATION_RT_INDIVIDUAL_INTERNSHIP, offer.Id, false);
            application.Status__c = Constants.CAREER_SERVICES_APPLICATION_STATUS_SENT_FOR_SUPERVISOR_ACCEPTANCE;
            application.Internal_Supervisor__c = internshipSupervisor.Id;
            insert application;
        }
    }

    @IsTest
    static void fetchInitialDataTest() {
        User supervisorUser = [SELECT Id FROM User WHERE Username = :SUPERVISOR_USER_USERNAME];
        CsSupervisorApprovalsController.InitialDataWrapper wrapper;

        Test.startTest();
        System.runAs(supervisorUser) {
            wrapper = CsSupervisorApprovalsController.fetchInitialData();
        }
        Test.stopTest();

        Assert.isTrue(wrapper.internshipOfferApprovals.size() == 1);
        Assert.isTrue(wrapper.individualApplicationApprovals.size() == 1);
    }

}