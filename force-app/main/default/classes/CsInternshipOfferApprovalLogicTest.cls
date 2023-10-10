@IsTest
public class CsInternshipOfferApprovalLogicTest {
    private static final String CAREER_SERVICES_USER_USERNAME = 'careerservicesuser@test.invalid';
    private static final String SUPERVISOR_USER_USERNAME = 'supervisoruser@test.invalid';
    private static final String CONTACT_WORK_EMAIL = 'workemail@test.invalid';

    @TestSetup
    static void setup() {
        User careerServicesUser = UserTestDataFactory.createCareerServicesUserWithPermissionSetAssigned(CAREER_SERVICES_USER_USERNAME);
        User supervisorUser = UserTestDataFactory.createCareerServicesUserWithPermissionSetAssigned(SUPERVISOR_USER_USERNAME);

        System.runAs(careerServicesUser) {
            Career_Services_Offer__c offer = CsOfferTestDataFactory.createInstitutionalInternshipOffer(true);

            Approval_Process__c approvalProcess = ApprovalProcessTestDataFactory.createActiveApprovalProcessForRecord(offer.Id, Utils.getRecordTypeIdByDevName(Approval_Process__c.getSObjectType(), Constants.CAREER_SERVICES_APPROVAL_PROCESS_RECORD_TYPE_INTERNSHIP_OFFER), true);

            ApprovalProcessEntryTestDataFactory.createReminderEntry(approvalProcess.Id, Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_SUPERVISOR_ACCEPTANCE, CONTACT_WORK_EMAIL, true);

            Contact contact = new ContactTestData().withWorkEmail(CONTACT_WORK_EMAIL).save().get();
            InternshipSupervisorTestDataFactory.createInternshipSupervisor(contact.Id, supervisorUser.Id, Constants.INTERNSHIP_SUPERVISOR_TYPE_SUPERVISOR, 'Supervisor', true);

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
    }

    @IsTest
    static void constructorTest() {
        Test.startTest();
        CsInternshipOfferApprovalLogic logic = new CsInternshipOfferApprovalLogic();
        Test.stopTest();

        Map<String, String> stagesMap = logic.STAGE_NAME_2_STAGE_IMPLEMENTOR_CLASS_NAME;
        Assert.areEqual(2, stagesMap.size());
        Assert.isTrue(stagesMap.containsKey(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_CAREER_SERVICES_ACCEPTANCE));
        Assert.isTrue(stagesMap.containsKey(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_SUPERVISOR_ACCEPTANCE));
    }

    @IsTest
    static void careerServicesAcceptanceStageLogicExecuteTestReject() {
        User careerServicesUser = [SELECT Id FROM User WHERE Username = :CAREER_SERVICES_USER_USERNAME];

        Approval_Process__c approvalProcess = [SELECT Related_Record_Id__c, Stage__c, Status__c FROM Approval_Process__c];

        String decision = 'Reject';
        String comment = 'Comment';
        Map<String, String> dataMap = new Map<String, String>{
            'decision' => decision,
            'comment' => comment
        };
        String jsonData = JSON.serialize(dataMap);

        Test.startTest();
        System.runAs(careerServicesUser) {
            new CsInternshipOfferApprovalLogic.CareerServicesAcceptanceStageLogic().execute(approvalProcess, jsonData);
        }
        Test.stopTest();
    
        Career_Services_Offer__c assertOffer = [SELECT Status__c, OwnerId FROM Career_Services_Offer__c];
        Assert.areEqual(careerServicesUser.Id, assertOffer.OwnerId);
        Assert.areEqual(Constants.CAREER_SERVICES_OFFER_STATUS_REJECTED, assertOffer.Status__c);

        Approval_Process__c assertApprovalProcess = [SELECT Status__c FROM Approval_Process__c];
        Assert.areEqual(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STATUS_FINISHED, assertApprovalProcess.Status__c);

        for (Approval_Process_Entry__c assertEntry : [SELECT Value__c, Stage__c, RecordType.DeveloperName FROM Approval_Process_Entry__c WHERE Approval_Process__c = :approvalProcess.Id]) {
            if (assertEntry.RecordType.DeveloperName == Constants.CAREER_SERVICES_APPROVAL_PROCESS_ENTRY_DECISION_RECORD_TYPE) {
                Assert.areEqual(decision, assertEntry.Value__c);
                Assert.areEqual(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_CAREER_SERVICES_ACCEPTANCE, assertEntry.Stage__c);
            } else if (assertEntry.RecordType.DeveloperName == Constants.CAREER_SERVICES_APPROVAL_PROCESS_ENTRY_COMMENT_RECORD_TYPE) {
                Assert.areEqual(comment, assertEntry.Value__c);
                Assert.areEqual(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_CAREER_SERVICES_ACCEPTANCE, assertEntry.Stage__c);
            }
        }
        
    }

    @IsTest
    static void careerServicesAcceptanceStageLogicExecuteTestApprove() {
        User careerServicesUser = [SELECT Id FROM User WHERE Username = :CAREER_SERVICES_USER_USERNAME];

        Approval_Process__c approvalProcess = [SELECT Related_Record_Id__c, Stage__c, Status__c FROM Approval_Process__c];

        Internship_Supervisor__c supervisor = [SELECT Id FROM Internship_Supervisor__c];

        Account pathway = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_SPECIALTY_API_NAME AND DT_Account_Type__c = :Constants.ACCOUNT_TYPE_PATHWAY_API_NAME];

        String decision = 'Approve';
        String jsonData = '{"decision":"' + decision + '","offerAssignmentsToCreate":[{"supervisorId":"' + supervisor.Id + '","accountId":"' + pathway.Id + '"}]}';

        Test.startTest();
        System.runAs(careerServicesUser) {
            new CsInternshipOfferApprovalLogic.CareerServicesAcceptanceStageLogic().execute(approvalProcess, jsonData);
        }
        Test.stopTest();

        Career_Services_Offer__c assertOffer = [SELECT Status__c, OwnerId FROM Career_Services_Offer__c];
        Assert.areEqual(careerServicesUser.Id, assertOffer.OwnerId);
        Assert.areEqual(Constants.CAREER_SERVICES_OFFER_STATUS_SUPERVISOR_VERIFICATION, assertOffer.Status__c);

        Approval_Process__c assertApprovalProcess = [SELECT Stage__c FROM Approval_Process__c];
        Assert.areEqual(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_SUPERVISOR_ACCEPTANCE, assertApprovalProcess.Stage__c);

        for (Approval_Process_Entry__c assertEntry : [SELECT Value__c, Stage__c, RecordType.DeveloperName FROM Approval_Process_Entry__c WHERE Approval_Process__c = :approvalProcess.Id]) {
            if (assertEntry.RecordType.DeveloperName == Constants.CAREER_SERVICES_APPROVAL_PROCESS_ENTRY_DECISION_RECORD_TYPE) {
                Assert.areEqual(decision, assertEntry.Value__c);
                Assert.areEqual(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_CAREER_SERVICES_ACCEPTANCE, assertEntry.Stage__c);
            }
        }

        Career_Services_Offer_Assignment__c assertAssignment = [SELECT Account__c, Internship_Supervisor__c, Career_Services_Offer__c FROM Career_Services_Offer_Assignment__c];
        Assert.areEqual(supervisor.Id, assertAssignment.Internship_Supervisor__c);
        Assert.areEqual(pathway.Id, assertAssignment.Account__c);
        Assert.areEqual(assertOffer.Id, assertAssignment.Career_Services_Offer__c);
    }

    @IsTest
    static void careerServicesAcceptanceStageLogicRetrieveStageDataTest() {
        User careerServicesUser = [SELECT Id FROM User WHERE Username = :CAREER_SERVICES_USER_USERNAME];
        
        Approval_Process__c approvalProcess = [SELECT Related_Record_Id__c, Stage__c, Status__c FROM Approval_Process__c];

        System.runAs(careerServicesUser) {
            Test.startTest();
            CsApprovalProcessStageBaseData stageData = new CsInternshipOfferApprovalLogic.CareerServicesAcceptanceStageLogic().retrieveStageData(approvalProcess);
            Test.stopTest();

            Assert.areEqual(true, stageData.canPerformAction);
        }
    }

    @IsTest
    static void supervisorAcceptanceStageLogicExecuteTestWithoutDecison() {
        User supervisorUser = [SELECT Id FROM User WHERE Username = :SUPERVISOR_USER_USERNAME];
        
        Approval_Process__c approvalProcess = [SELECT Related_Record_Id__c, Stage__c, Status__c FROM Approval_Process__c];
        approvalProcess.Stage__c = Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_SUPERVISOR_ACCEPTANCE;
        update approvalProcess;

        Account pathway = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_SPECIALTY_API_NAME AND DT_Account_Type__c = :Constants.ACCOUNT_TYPE_PATHWAY_API_NAME];
        
        Internship_Supervisor__c supervisor = [SELECT Id FROM Internship_Supervisor__c];

        Career_Services_Offer__c offer = [SELECT Id FROM Career_Services_Offer__c];
        offer.Status__c = Constants.CAREER_SERVICES_OFFER_STATUS_SUPERVISOR_VERIFICATION;
        update offer;

        Career_Services_Offer_Assignment__c offerAssignment = CsOfferAssignmentTestDataFactory.createAssignment(pathway.Id, offer.Id, supervisor.Id, true);

        String jsonData = '{"offerAssignmentsToUpdate":[]}';

        Test.startTest();
        System.runAs(supervisorUser) {
            new CsInternshipOfferApprovalLogic.SupervisorAcceptanceStageLogic().execute(approvalProcess, jsonData);
        }
        Test.stopTest();

        Career_Services_Offer_Assignment__c assertAssignment = [SELECT Is_Accepted__c, Has_Decision_Been_Made__c FROM Career_Services_Offer_Assignment__c];
        Assert.areEqual(false, assertAssignment.Is_Accepted__c);
        Assert.areEqual(false, assertAssignment.Has_Decision_Been_Made__c);

        Approval_Process__c assertApprovalProcess = [SELECT Status__c FROM Approval_Process__c];
        Assert.areEqual(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STATUS_ACTIVE, assertApprovalProcess.Status__c);

        Career_Services_Offer__c assertOffer = [SELECT Status__c FROM Career_Services_Offer__c];
        Assert.areEqual(Constants.CAREER_SERVICES_OFFER_STATUS_SUPERVISOR_VERIFICATION, assertOffer.Status__c);
    }

    @IsTest
    static void supervisorAcceptanceStageLogicExecuteTestRejectedByAll() {
        User supervisorUser = [SELECT Id FROM User WHERE Username = :SUPERVISOR_USER_USERNAME];
        
        Approval_Process__c approvalProcess = [SELECT Related_Record_Id__c, Stage__c, Status__c FROM Approval_Process__c];
        approvalProcess.Stage__c = Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_SUPERVISOR_ACCEPTANCE;
        update approvalProcess;

        Account pathway = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_SPECIALTY_API_NAME AND DT_Account_Type__c = :Constants.ACCOUNT_TYPE_PATHWAY_API_NAME];
        
        Internship_Supervisor__c supervisor = [SELECT Id FROM Internship_Supervisor__c];

        Career_Services_Offer__c offer = [SELECT Id FROM Career_Services_Offer__c];
        offer.Status__c = Constants.CAREER_SERVICES_OFFER_STATUS_SUPERVISOR_VERIFICATION;
        update offer;

        Career_Services_Offer_Assignment__c offerAssignment = CsOfferAssignmentTestDataFactory.createAssignment(pathway.Id, offer.Id, supervisor.Id, true);

        String decision = 'Reject';
        String comment = 'Comment';
        String jsonData = '{"offerAssignmentsToUpdate":[{"id":"' + offerAssignment.Id + '","decision":"' + decision + '","comment":"' + comment + '"}]}';

        Test.startTest();
        System.runAs(supervisorUser) {
            new CsInternshipOfferApprovalLogic.SupervisorAcceptanceStageLogic().execute(approvalProcess, jsonData);
        }
        Test.stopTest();

        Career_Services_Offer_Assignment__c assertAssignment = [SELECT Is_Accepted__c, Has_Decision_Been_Made__c FROM Career_Services_Offer_Assignment__c];
        Assert.areEqual(false, assertAssignment.Is_Accepted__c);
        Assert.areEqual(true, assertAssignment.Has_Decision_Been_Made__c);

        for (Approval_Process_Entry__c assertEntry : [SELECT Value__c, Stage__c, RecordType.DeveloperName FROM Approval_Process_Entry__c WHERE Approval_Process__c = :approvalProcess.Id]) {
            if (assertEntry.RecordType.DeveloperName == Constants.CAREER_SERVICES_APPROVAL_PROCESS_ENTRY_DECISION_RECORD_TYPE) {
                Assert.areEqual(decision, assertEntry.Value__c);
                Assert.areEqual(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_SUPERVISOR_ACCEPTANCE, assertEntry.Stage__c);
            } else if (assertEntry.RecordType.DeveloperName == Constants.CAREER_SERVICES_APPROVAL_PROCESS_ENTRY_COMMENT_RECORD_TYPE) {
                Assert.areEqual(comment, assertEntry.Value__c);
                Assert.areEqual(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_SUPERVISOR_ACCEPTANCE, assertEntry.Stage__c);
            }
        }

        Approval_Process__c assertApprovalProcess = [SELECT Status__c FROM Approval_Process__c];
        Assert.areEqual(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STATUS_FINISHED, assertApprovalProcess.Status__c);

        Career_Services_Offer__c assertOffer = [SELECT Status__c FROM Career_Services_Offer__c];
        Assert.areEqual(Constants.CAREER_SERVICES_OFFER_STATUS_REJECTED, assertOffer.Status__c);
    }

    @IsTest
    static void supervisorAcceptanceStageLogicExecuteTestApprovedByAll() {
        User supervisorUser = [SELECT Id FROM User WHERE Username = :SUPERVISOR_USER_USERNAME];
        
        Approval_Process__c approvalProcess = [SELECT Related_Record_Id__c, Stage__c, Status__c FROM Approval_Process__c];
        approvalProcess.Stage__c = Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_SUPERVISOR_ACCEPTANCE;
        update approvalProcess;

        Account pathway = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_SPECIALTY_API_NAME AND DT_Account_Type__c = :Constants.ACCOUNT_TYPE_PATHWAY_API_NAME];
        
        Internship_Supervisor__c supervisor = [SELECT Id FROM Internship_Supervisor__c];

        Career_Services_Offer__c offer = [SELECT Id FROM Career_Services_Offer__c];
        offer.Status__c = Constants.CAREER_SERVICES_OFFER_STATUS_SUPERVISOR_VERIFICATION;
        update offer;

        Career_Services_Offer_Assignment__c offerAssignment = CsOfferAssignmentTestDataFactory.createAssignment(pathway.Id, offer.Id, supervisor.Id, true);

        String decision = 'Approve';
        String jsonData = '{"offerAssignmentsToUpdate":[{"id":"' + offerAssignment.Id + '","decision":"' + decision + '"}]}';

        Test.startTest();
        System.runAs(supervisorUser) {
            new CsInternshipOfferApprovalLogic.SupervisorAcceptanceStageLogic().execute(approvalProcess, jsonData);
        }
        Test.stopTest();

        Career_Services_Offer_Assignment__c assertAssignment = [SELECT Is_Accepted__c, Has_Decision_Been_Made__c FROM Career_Services_Offer_Assignment__c];
        Assert.areEqual(true, assertAssignment.Is_Accepted__c);
        Assert.areEqual(true, assertAssignment.Has_Decision_Been_Made__c);

        for (Approval_Process_Entry__c assertEntry : [SELECT Value__c, Stage__c, RecordType.DeveloperName FROM Approval_Process_Entry__c WHERE Approval_Process__c = :approvalProcess.Id]) {
            if (assertEntry.RecordType.DeveloperName == Constants.CAREER_SERVICES_APPROVAL_PROCESS_ENTRY_DECISION_RECORD_TYPE) {
                Assert.areEqual(decision, assertEntry.Value__c);
                Assert.areEqual(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_SUPERVISOR_ACCEPTANCE, assertEntry.Stage__c);
            }
        }

        Career_Services_Offer__c assertOffer = [SELECT Status__c FROM Career_Services_Offer__c];
        Assert.areEqual(Constants.CAREER_SERVICES_OFFER_STATUS_AGREEMENT_CREATION, assertOffer.Status__c);

        Approval_Process__c assertApprovalProcess = [SELECT Status__c FROM Approval_Process__c];
        Assert.areEqual(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STATUS_FINISHED, assertApprovalProcess.Status__c);
    }

    @IsTest
    static void supervisorAcceptanceStageLogicRetrieveStageDataTest() {
        User supervisorUser = [SELECT Id FROM User WHERE Username = :SUPERVISOR_USER_USERNAME];
        
        Approval_Process__c approvalProcess = [SELECT Related_Record_Id__c, Stage__c, Status__c FROM Approval_Process__c];
        approvalProcess.Stage__c = Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_SUPERVISOR_ACCEPTANCE;
        update approvalProcess;

        Account pathway = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_SPECIALTY_API_NAME AND DT_Account_Type__c = :Constants.ACCOUNT_TYPE_PATHWAY_API_NAME];
        
        Internship_Supervisor__c supervisor = [SELECT Name, Contact__r.hed__WorkEmail__c FROM Internship_Supervisor__c];

        Career_Services_Offer__c offer = [SELECT Id FROM Career_Services_Offer__c];
        offer.Status__c = Constants.CAREER_SERVICES_OFFER_STATUS_SUPERVISOR_VERIFICATION;
        update offer;

        CsOfferAssignmentTestDataFactory.createAssignment(pathway.Id, offer.Id, supervisor.Id, true);

        System.runAs(supervisorUser) {
            Test.startTest();
            CsApprovalProcessStageBaseData stageData = new CsInternshipOfferApprovalLogic.SupervisorAcceptanceStageLogic().retrieveStageData(approvalProcess);
            Test.stopTest();

            Assert.areEqual(true, stageData.canPerformAction);

            Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(stageData.jsonData);
            Assert.areEqual(false, jsonData.get('isAllowedToSendReminder'));

            List<Object> reminders = (List<Object>) jsonData.get('reminders');
            Map<String, Object> reminder = (Map<String, Object>) reminders[0];
            Assert.areEqual(supervisor.Name, reminder.get('supervisorName'));
            Assert.areEqual(supervisor.Contact__r.hed__WorkEmail__c, reminder.get('supervisorEmail'));
            Assert.areEqual(true, reminder.get('isSendDisabled'));
        }
    }
}