@IsTest
private class CareerOfficeApprovalControllerTest {
    private static final String CS_EMPLOYEE_USER_EMAIL = 'csEmployee@swps.edu.pl.approval.test';
    private static final String DEANS_OFFICE_USER_EMAIL = 'deansOfficeEmployee@swps.edu.pl.approval.test';
    private static final String GENERIC_INTERNSHIP_EMAIL = 'genericInternship@swsp.edu.pl.approval.test';
    private static final String BASIC_APPROVE_JSON_DATA = '{"isApproved":true,"rejectionJustification":""}';
    private static final String BASIC_REJECT_JSON_DATA = '{"isApproved":false,"rejectionJustification":"test"}';
    private static final String APPROVE_JSON_DATA_WITH_SUPERVISOR_TEMPLATE = '{"isApproved":true,"rejectionJustification":"","fieldsToUpdate":{"DT_University_Internship_Supervisor__c":"{0}"}}';
    private static final String REJECT_JSON_DATA_WITH_SUPERVISOR_TEMPLATE = '{"isApproved":false,"rejectionJustification":"test","fieldsToUpdate":{"DT_University_Internship_Supervisor__c":"{0}"}}';

    @TestSetup
    private static void setup() {
        User adminUser = DT_DataFactory.createAdminUser();

        System.runAs(adminUser) {
            User studentUser = DT_DataFactory.createStudentUser();
            User careerOfficeUser = DT_DataFactory.createUserWithProfile(CS_EMPLOYEE_USER_EMAIL, DT_Utils.SWPS_CAREER_OFFICE_PROFILE_NAME);
            DT_Internship_Supervisor__c supervisor = DT_DataFactory.createInternshipSupervisors(1, true, new DT_Internship_Supervisor__c(DT_Is_Active__c = true))[0];

            DT_DataFactory.createUserWithProfile(DEANS_OFFICE_USER_EMAIL, DT_Utils.SWPS_DEANS_OFFICE_EMPLOYEE_PROFILE_NAME);
            Account companyAccount = DT_DataFactory.createAccounts(1, true, null)[0];
            List<DT_Internship__c> internships = DT_DataFactory.createInternships(4, false, new DT_Internship__c(DT_Company_Name__c = companyAccount.Id));
            internships[0].DT_Status_Of_The_Offer__c = DT_Utils.INTERNSHIP_STATUS_REJECTED;
            internships[1].DT_University_Internship_Supervisor__c = supervisor.Id;
            internships[1].DT_Status_Of_The_Offer__c = DT_Utils.INTERNSHIP_STATUS_IN_PROGRESS;
            internships[2].DT_Email__c = GENERIC_INTERNSHIP_EMAIL;

            List<DT_Internship_Application__c> internshipApplications = DT_DataFactory.createIndividualInternshipApplications(
                internships[1].Id, studentUser.ContactId, careerOfficeUser.Id, supervisor.Id,  3, false);
            internshipApplications[0].DT_Status__c = DT_Utils.INTERNSHIP_APPLICATION_STATUS_DRAFT;
            internshipApplications[1].DT_Status__c = DT_Utils.INTERNSHIP_APPLICATION_STATUS_IN_PROGRESS;
            internshipApplications[2].DT_Status__c = DT_Utils.INTERNSHIP_APPLICATION_STATUS_SUPERVISORS_ACCEPTANCE;
            internshipApplications[2].DT_University_Internship_Supervisor__c = supervisor.Id;

            insert new List<SObject> {internships[0], internships[1], internships[2], internships[3], internshipApplications[0], internshipApplications[1], internshipApplications[2]};
        }
    }

    @IsTest
    private static void fetchApprovalProcessDataInternshipOfferNewOfferAsAdmin() {
        DT_Internship__c internship = [SELECT Id FROM DT_Internship__c WHERE DT_Email__c = :GENERIC_INTERNSHIP_EMAIL LIMIT 1];

        Test.startTest();
        CareerOfficeApprovalController.ApprovalProcessData approvalProcessData = CareerOfficeApprovalController.fetchApprovalProcessData(internship.Id, internship.getSObjectType().getDescribe().name);
        Test.stopTest();

        Assert.areEqual(CareerOfficeApprovalController.ApprovalProcessType.InternshipOffer.name(), approvalProcessData.processType);
        Assert.areEqual(CareerOfficeApprovalController.ApprovalProcessStep.CSAcceptance.name(), approvalProcessData.processStep);
        Assert.isTrue(approvalProcessData.canCurrentUserPerformAction);
        Assert.isFalse(approvalProcessData.isStudentEN);
        Assert.areEqual(internship.Id, approvalProcessData.record.Id);
    }

    @IsTest
    private static void fetchApprovalProcessDataInternshipOfferNewOfferAsCSEmployee() {
        CareerOfficeApprovalController.ApprovalProcessData approvalProcessData;

        DT_Internship__c internship = [SELECT Id FROM DT_Internship__c WHERE DT_Email__c = :GENERIC_INTERNSHIP_EMAIL LIMIT 1];
        User csEmployeeUser = [SELECT Id FROM User WHERE Email = :CS_EMPLOYEE_USER_EMAIL LIMIT 1];

        Test.startTest();
        System.runAs(csEmployeeUser) {
            approvalProcessData = CareerOfficeApprovalController.fetchApprovalProcessData(internship.Id, internship.getSObjectType().getDescribe().name);
        }
        Test.stopTest();

        Assert.areEqual(CareerOfficeApprovalController.ApprovalProcessType.InternshipOffer.name(), approvalProcessData.processType);
        Assert.areEqual(CareerOfficeApprovalController.ApprovalProcessStep.CSAcceptance.name(), approvalProcessData.processStep);
        Assert.isTrue(approvalProcessData.canCurrentUserPerformAction);
        Assert.isFalse(approvalProcessData.isStudentEN);
        Assert.areEqual(internship.Id, approvalProcessData.record.Id);
    }

    @IsTest
    private static void fetchApprovalProcessDataInternshipOfferNewOfferAsNotAllowedUser() {
        CareerOfficeApprovalController.ApprovalProcessData approvalProcessData;

        DT_Internship__c internship = [SELECT Id FROM DT_Internship__c WHERE DT_Email__c = :GENERIC_INTERNSHIP_EMAIL LIMIT 1];
        User deansOfficeUser = [SELECT Id FROM User WHERE Email = :DEANS_OFFICE_USER_EMAIL LIMIT 1];

        Test.startTest();
        System.runAs(deansOfficeUser) {
            approvalProcessData = CareerOfficeApprovalController.fetchApprovalProcessData(internship.Id, internship.getSObjectType().getDescribe().name);
        }
        Test.stopTest();

        Assert.areEqual(CareerOfficeApprovalController.ApprovalProcessType.InternshipOffer.name(), approvalProcessData.processType);
        Assert.areEqual(CareerOfficeApprovalController.ApprovalProcessStep.CSAcceptance.name(), approvalProcessData.processStep);
        Assert.isFalse(approvalProcessData.canCurrentUserPerformAction);
        Assert.isFalse(approvalProcessData.isStudentEN);
        Assert.areEqual(internship.Id, approvalProcessData.record.Id);
    }

    @IsTest
    private static void executeLogicInternshipOfferCSAcceptanceStepApprove() {

        DT_Internship__c preExecuteInternship = [SELECT Id FROM DT_Internship__c WHERE DT_Email__c = :GENERIC_INTERNSHIP_EMAIL LIMIT 1];
        DT_Internship_Supervisor__c internshipSupervisor = [SELECT Id FROM DT_Internship_Supervisor__c LIMIT 1];
        String processType = CareerOfficeApprovalController.ApprovalProcessType.InternshipOffer.name();
        String processStep = CareerOfficeApprovalController.ApprovalProcessStep.CSAcceptance.name();
        String dataAsJson = APPROVE_JSON_DATA_WITH_SUPERVISOR_TEMPLATE.replace('{0}', internshipSupervisor.Id);

        Test.startTest();
        CareerOfficeApprovalController.executeLogic(processType, processStep, preExecuteInternship.Id, dataAsJson);
        Test.stopTest();
        DT_Internship__c postExecuteInternship = [
            SELECT
                Id,
                OwnerId,
                DT_University_Internship_Supervisor__c,
                DT_Status_Of_The_Offer__c,
                Career_Office_Rejection_Reason__c
            FROM DT_Internship__c
            WHERE Id = :preExecuteInternship.Id];

        Assert.areEqual(UserInfo.getUserId(), postExecuteInternship.OwnerId);
        Assert.areEqual(internshipSupervisor.Id, postExecuteInternship.DT_University_Internship_Supervisor__c);
        Assert.areEqual(postExecuteInternship.DT_Status_Of_The_Offer__c, DT_Utils.INTERNSHIP_STATUS_IN_PROGRESS);
        Assert.isNull(postExecuteInternship.Career_Office_Rejection_Reason__c);
    }

    @IsTest
    private static void executeLogicInternshipOfferCSAcceptanceStepReject() {

        DT_Internship__c preExecuteInternship = [SELECT Id FROM DT_Internship__c WHERE DT_Email__c = :GENERIC_INTERNSHIP_EMAIL LIMIT 1];
        DT_Internship_Supervisor__c internshipSupervisor = [SELECT Id FROM DT_Internship_Supervisor__c LIMIT 1];
        String processType = CareerOfficeApprovalController.ApprovalProcessType.InternshipOffer.name();
        String processStep = CareerOfficeApprovalController.ApprovalProcessStep.CSAcceptance.name();
        String dataAsJson = (REJECT_JSON_DATA_WITH_SUPERVISOR_TEMPLATE).replace('{0}', internshipSupervisor.Id);

        Test.startTest();
        CareerOfficeApprovalController.executeLogic(processType, processStep, preExecuteInternship.Id, dataAsJson);
        Test.stopTest();
        DT_Internship__c postExecuteInternship = [
            SELECT
                Id,
                OwnerId,
                DT_University_Internship_Supervisor__c,
                DT_Status_Of_The_Offer__c,
                Career_Office_Rejection_Reason__c
            FROM DT_Internship__c
            WHERE Id = :preExecuteInternship.Id];

        Assert.areEqual(UserInfo.getUserId(), postExecuteInternship.OwnerId);
        Assert.areEqual(internshipSupervisor.Id, postExecuteInternship.DT_University_Internship_Supervisor__c);
        Assert.areEqual(postExecuteInternship.DT_Status_Of_The_Offer__c, DT_Utils.INTERNSHIP_STATUS_REJECTED);
        Assert.isNotNull(postExecuteInternship.Career_Office_Rejection_Reason__c);
    }

    @IsTest
    private static void fetchApprovalProcessDataInternshipOfferInProgressAsInternshipSupervisor() {
        CareerOfficeApprovalController.ApprovalProcessData approvalProcessData;

        DT_Internship_Supervisor__c internshipSupervisor = [SELECT Id, DT_User__c FROM DT_Internship_Supervisor__c LIMIT 1];
        User supervisorUser = [SELECT Id FROM User WHERE Id = :internshipSupervisor.DT_User__c];
        DT_Internship__c internship = [SELECT Id FROM DT_Internship__c WHERE DT_University_Internship_Supervisor__c = :internshipSupervisor.Id LIMIT 1];

        Test.startTest();
        System.runAs(supervisorUser) {
            approvalProcessData = CareerOfficeApprovalController.fetchApprovalProcessData(internship.Id, internship.getSObjectType().getDescribe().name);
        }
        Test.stopTest();

        Assert.areEqual(CareerOfficeApprovalController.ApprovalProcessType.InternshipOffer.name(), approvalProcessData.processType);
        Assert.areEqual(CareerOfficeApprovalController.ApprovalProcessStep.SupervisorAcceptance.name(), approvalProcessData.processStep);
        Assert.isTrue(approvalProcessData.canCurrentUserPerformAction);
        Assert.isFalse(approvalProcessData.isStudentEN);
        Assert.areEqual(internship.Id, approvalProcessData.record.Id);
    }

    @IsTest
    private static void fetchApprovalProcessDataInternshipOfferInProgressAsNotAllowedUser() {

        CareerOfficeApprovalController.ApprovalProcessData approvalProcessData;
        DT_Internship_Supervisor__c internshipSupervisor = [SELECT Id FROM DT_Internship_Supervisor__c LIMIT 1];
        DT_Internship__c internship = [SELECT Id FROM DT_Internship__c WHERE DT_University_Internship_Supervisor__c = :internshipSupervisor.Id LIMIT 1];

        User deansOfficeUser = [SELECT Id FROM User WHERE Email = :DEANS_OFFICE_USER_EMAIL LIMIT 1];

        Test.startTest();
        System.runAs(deansOfficeUser) {
            approvalProcessData = CareerOfficeApprovalController.fetchApprovalProcessData(internship.Id, internship.getSObjectType().getDescribe().name);
        }
        Test.stopTest();

        Assert.areEqual(CareerOfficeApprovalController.ApprovalProcessType.InternshipOffer.name(), approvalProcessData.processType);
        Assert.areEqual(CareerOfficeApprovalController.ApprovalProcessStep.SupervisorAcceptance.name(), approvalProcessData.processStep);
        Assert.isFalse(approvalProcessData.canCurrentUserPerformAction);
        Assert.isFalse(approvalProcessData.isStudentEN);
        Assert.areEqual(internship.Id, approvalProcessData.record.Id);
    }

    @IsTest
    private static void fetchApprovalProcessDataFromNotAllowedStatus() {

        DT_Internship__c internship = [SELECT Id FROM DT_Internship__c WHERE DT_Status_Of_The_Offer__c = :DT_Utils.INTERNSHIP_STATUS_REJECTED LIMIT 1];

        Test.startTest();
        CareerOfficeApprovalController.ApprovalProcessData approvalProcessData = CareerOfficeApprovalController.fetchApprovalProcessData(internship.Id, internship.getSObjectType().getDescribe().name);
        Test.stopTest();

        Assert.areEqual(CareerOfficeApprovalController.ApprovalProcessType.InternshipOffer.name(), approvalProcessData.processType);
        Assert.isNull(approvalProcessData.processStep);
        Assert.isFalse(approvalProcessData.canCurrentUserPerformAction);
        Assert.isFalse(approvalProcessData.isStudentEN);
        Assert.areEqual(internship.Id, approvalProcessData.record.Id);
    }

    @IsTest
    private static void executeLogicInternshipSupervisorAcceptanceStepApprove() {

        DT_Internship_Supervisor__c internshipSupervisor = [SELECT Id, DT_User__c FROM DT_Internship_Supervisor__c LIMIT 1];
        User supervisorUser = [SELECT Id FROM User WHERE Id = :internshipSupervisor.DT_User__c];
        DT_Internship__c preExecuteInternship = [SELECT Id FROM DT_Internship__c WHERE DT_University_Internship_Supervisor__c = :internshipSupervisor.Id LIMIT 1];
        String processType = CareerOfficeApprovalController.ApprovalProcessType.InternshipOffer.name();
        String processStep = CareerOfficeApprovalController.ApprovalProcessStep.SupervisorAcceptance.name();
        String dataAsJson = BASIC_APPROVE_JSON_DATA;

        Test.startTest();
        System.runAs(supervisorUser) {
            CareerOfficeApprovalController.executeLogic(processType, processStep, preExecuteInternship.Id, dataAsJson);
        }
        Test.stopTest();
        DT_Internship__c postExecuteInternship = [
            SELECT Id,
                DT_University_Internship_Supervisor__c,
                DT_Status_Of_The_Offer__c,
                Career_Office_Rejection_Reason__c,
                Internship_Supervisor_Rejection_Reason__c
            FROM DT_Internship__c
            WHERE Id = :preExecuteInternship.Id];

        Assert.areEqual(internshipSupervisor.Id, postExecuteInternship.DT_University_Internship_Supervisor__c);
        Assert.areEqual(postExecuteInternship.DT_Status_Of_The_Offer__c, DT_Utils.INTERNSHIP_STATUS_PUBLISHED);
        Assert.isNull(postExecuteInternship.Career_Office_Rejection_Reason__c);
        Assert.isNull(postExecuteInternship.Internship_Supervisor_Rejection_Reason__c);
    }

    @IsTest
    private static void executeLogicInternshipSupervisorAcceptanceStepReject() {

        DT_Internship_Supervisor__c internshipSupervisor = [SELECT Id, DT_User__c FROM DT_Internship_Supervisor__c LIMIT 1];
        User supervisorUser = [SELECT Id FROM User WHERE Id = :internshipSupervisor.DT_User__c];
        DT_Internship__c preExecuteInternship = [SELECT Id FROM DT_Internship__c WHERE DT_University_Internship_Supervisor__c = :internshipSupervisor.Id LIMIT 1];
        String processType = CareerOfficeApprovalController.ApprovalProcessType.InternshipOffer.name();
        String processStep = CareerOfficeApprovalController.ApprovalProcessStep.SupervisorAcceptance.name();
        String dataAsJson = BASIC_REJECT_JSON_DATA;

        Test.startTest();
        System.runAs(supervisorUser) {
            CareerOfficeApprovalController.executeLogic(processType, processStep, preExecuteInternship.Id, dataAsJson);
        }
        Test.stopTest();
        DT_Internship__c postExecuteInternship = [
            SELECT Id,
                DT_University_Internship_Supervisor__c,
                DT_Status_Of_The_Offer__c,
                Career_Office_Rejection_Reason__c,
                Internship_Supervisor_Rejection_Reason__c
            FROM DT_Internship__c
            WHERE Id = :preExecuteInternship.Id];

        Assert.areEqual(internshipSupervisor.Id, postExecuteInternship.DT_University_Internship_Supervisor__c);
        Assert.areEqual(postExecuteInternship.DT_Status_Of_The_Offer__c, DT_Utils.INTERNSHIP_STATUS_REJECTED);
        Assert.isNull(postExecuteInternship.Career_Office_Rejection_Reason__c);
        Assert.isNotNull(postExecuteInternship.Internship_Supervisor_Rejection_Reason__c);
    }

    @IsTest
    private static void fetchApprovalProcessDataInternshipApplicationNotAllowedStatus() {
        DT_Internship_Application__c internshipApplication = [SELECT Id FROM DT_Internship_Application__c WHERE DT_Status__c = :DT_Utils.INTERNSHIP_APPLICATION_STATUS_DRAFT LIMIT 1];

        Test.startTest();
        CareerOfficeApprovalController.ApprovalProcessData approvalProcessData = CareerOfficeApprovalController.fetchApprovalProcessData(internshipApplication.Id, internshipApplication.getSObjectType().getDescribe().name);
        Test.stopTest();

        Assert.areEqual(CareerOfficeApprovalController.ApprovalProcessType.InternshipApplicationIndividual.name(), approvalProcessData.processType);
        Assert.isNull(approvalProcessData.processStep);
        Assert.isFalse(approvalProcessData.canCurrentUserPerformAction);
        Assert.isFalse(approvalProcessData.isStudentEN);
        Assert.areEqual(internshipApplication.Id, approvalProcessData.record.Id);
    }

    @IsTest
    private static void fetchApprovalProcessDataInternshipApplicationAsAdmin() {
        DT_Internship_Application__c internshipApplication = [SELECT Id FROM DT_Internship_Application__c WHERE DT_Status__c = :DT_Utils.INTERNSHIP_APPLICATION_STATUS_IN_PROGRESS LIMIT 1];

        Test.startTest();
        CareerOfficeApprovalController.ApprovalProcessData approvalProcessData = CareerOfficeApprovalController.fetchApprovalProcessData(internshipApplication.Id, internshipApplication.getSObjectType().getDescribe().name);
        Test.stopTest();

        Assert.areEqual(CareerOfficeApprovalController.ApprovalProcessType.InternshipApplicationIndividual.name(), approvalProcessData.processType);
        Assert.areEqual(CareerOfficeApprovalController.ApprovalProcessStep.CSAcceptance.name(), approvalProcessData.processStep);
        Assert.isTrue(approvalProcessData.canCurrentUserPerformAction);
        Assert.isFalse(approvalProcessData.isStudentEN);
        Assert.areEqual(internshipApplication.Id, approvalProcessData.record.Id);
    }

    @IsTest
    private static void fetchApprovalProcessDataInternshipApplicationSupervisorAcceptanceNotAllowedUser() {
        CareerOfficeApprovalController.ApprovalProcessData approvalProcessData;

        DT_Internship_Application__c internshipApplication = [SELECT Id FROM DT_Internship_Application__c WHERE DT_Status__c = :DT_Utils.INTERNSHIP_APPLICATION_STATUS_SUPERVISORS_ACCEPTANCE LIMIT 1];
        User deansOfficeUser = [SELECT Id FROM User WHERE Email = :DEANS_OFFICE_USER_EMAIL LIMIT 1];

        Test.startTest();
        System.runAs(deansOfficeUser) {
            approvalProcessData = CareerOfficeApprovalController.fetchApprovalProcessData(internshipApplication.Id, internshipApplication.getSObjectType().getDescribe().name);
        }
        Test.stopTest();

        Assert.areEqual(CareerOfficeApprovalController.ApprovalProcessType.InternshipApplicationIndividual.name(), approvalProcessData.processType);
        Assert.areEqual(CareerOfficeApprovalController.ApprovalProcessStep.SupervisorAcceptance.name(), approvalProcessData.processStep);
        Assert.isFalse(approvalProcessData.canCurrentUserPerformAction);
        Assert.isFalse(approvalProcessData.isStudentEN);
        Assert.areEqual(internshipApplication.Id, approvalProcessData.record.Id);
    }

    @IsTest
    private static void fetchApprovalProcessDataInternshipApplicationStudentEN() {
        CareerOfficeApprovalController.ApprovalProcessData approvalProcessData;
        DT_Internship_Application__c internshipApplication = [SELECT Id FROM DT_Internship_Application__c WHERE DT_Status__c = :DT_Utils.INTERNSHIP_APPLICATION_STATUS_SUPERVISORS_ACCEPTANCE LIMIT 1];
        DT_Internship_Supervisor__c internshipSupervisor = [SELECT Id, DT_User__c FROM DT_Internship_Supervisor__c LIMIT 1];
        User supervisorUser = [SELECT Id, ContactId FROM User WHERE Id = :internshipSupervisor.DT_User__c];
        User studentUser = [SELECT Id, ContactId FROM User WHERE Email = :DT_DataFactory.USER_STUDENT_EMAIL];

        Account academicProgram;
        hed__Program_Plan__c programPlan;

        academicProgram = DT_DataFactory.createTestAcademicProgram(
            true, null, null
        );

        programPlan = DT_DataFactory.createProgramPlans(
            1, true, new hed__Program_Plan__c(
                hed__Account__c = academicProgram.Id,
                DT_Language_of_Instruction__c = DT_Utils.PROGRAM_PLAN_LANGUAGE_OF_INSTRUCTION_EN
            )
        ).get(0);

        hed__Program_Enrollment__c programEnrollment = DT_DataFactory.createProgramEnrollments(
            1, true, new hed__Program_Enrollment__c(
                hed__Account__c = academicProgram.Id,
                hed__Program_Plan__c = programPlan.Id,
                hed__Contact__c = studentUser.ContactId
            )
        ).get(0);

        internshipApplication.DT_Program_Enrollment__c = programEnrollment.Id;

        update internshipApplication;

        Test.startTest();
        System.runAs(supervisorUser) {
            approvalProcessData = CareerOfficeApprovalController.fetchApprovalProcessData(internshipApplication.Id, internshipApplication.getSObjectType().getDescribe().name);
        }
        Test.stopTest();

        Assert.areEqual(CareerOfficeApprovalController.ApprovalProcessType.InternshipApplicationIndividual.name(), approvalProcessData.processType);
        Assert.areEqual(CareerOfficeApprovalController.ApprovalProcessStep.SupervisorAcceptance.name(), approvalProcessData.processStep);
        Assert.isFalse(approvalProcessData.canCurrentUserPerformAction);
        Assert.isTrue(approvalProcessData.isStudentEN);
        Assert.areEqual(internshipApplication.Id, approvalProcessData.record.Id);
    }

    @IsTest
    private static void fetchApprovalProcessDataInternshipApplicationCSAcceptanceNotAllowedUser() {
        CareerOfficeApprovalController.ApprovalProcessData approvalProcessData;

        DT_Internship_Application__c internshipApplication = [SELECT Id FROM DT_Internship_Application__c WHERE DT_Status__c = :DT_Utils.INTERNSHIP_APPLICATION_STATUS_IN_PROGRESS LIMIT 1];
        User deansOfficeUser = [SELECT Id FROM User WHERE Email = :DEANS_OFFICE_USER_EMAIL LIMIT 1];

        Test.startTest();
        System.runAs(deansOfficeUser) {
            approvalProcessData = CareerOfficeApprovalController.fetchApprovalProcessData(internshipApplication.Id, internshipApplication.getSObjectType().getDescribe().name);
        }
        Test.stopTest();

        Assert.areEqual(CareerOfficeApprovalController.ApprovalProcessType.InternshipApplicationIndividual.name(), approvalProcessData.processType);
        Assert.areEqual(CareerOfficeApprovalController.ApprovalProcessStep.CSAcceptance.name(), approvalProcessData.processStep);
        Assert.isFalse(approvalProcessData.canCurrentUserPerformAction);
        Assert.isFalse(approvalProcessData.isStudentEN);
        Assert.areEqual(internshipApplication.Id, approvalProcessData.record.Id);
    }

    @IsTest
    private static void executeLogicInternshipApplicationCSAcceptanceStepApprove() {
        DT_Internship_Application__c preExecuteInternshipApplication = [SELECT Id FROM DT_Internship_Application__c WHERE DT_Status__c = :DT_Utils.INTERNSHIP_APPLICATION_STATUS_IN_PROGRESS LIMIT 1];
        User careerOfficeEmployeeUser = [SELECT Id FROM User WHERE Email = :CS_EMPLOYEE_USER_EMAIL LIMIT 1];
        DT_Internship_Supervisor__c internshipSupervisor = [SELECT Id FROM DT_Internship_Supervisor__c LIMIT 1];
        String processType = CareerOfficeApprovalController.ApprovalProcessType.InternshipApplicationIndividual.name();
        String processStep = CareerOfficeApprovalController.ApprovalProcessStep.CSAcceptance.name();
        String dataAsJson = APPROVE_JSON_DATA_WITH_SUPERVISOR_TEMPLATE.replace('{0}', internshipSupervisor.Id);

        Test.startTest();
        System.runAs(careerOfficeEmployeeUser) {
            CareerOfficeApprovalController.executeLogic(processType, processStep, preExecuteInternshipApplication.Id, dataAsJson);
        }
        Test.stopTest();
        DT_Internship_Application__c postExecuteInternshipApplication = [
            SELECT
                Id,
                DT_Career_Office_Employee__c,
                DT_University_Internship_Supervisor__c,
                DT_Status__c,
                Career_Office_Rejection_Reason__c
            FROM DT_Internship_Application__c
            WHERE Id = :preExecuteInternshipApplication.Id];

        Assert.areEqual(careerOfficeEmployeeUser.Id, postExecuteInternshipApplication.DT_Career_Office_Employee__c);
        Assert.areEqual(internshipSupervisor.Id, postExecuteInternshipApplication.DT_University_Internship_Supervisor__c);
        Assert.areEqual(postExecuteInternshipApplication.DT_Status__c, DT_Utils.INTERNSHIP_APPLICATION_STATUS_SUPERVISORS_ACCEPTANCE);
        Assert.isNull(postExecuteInternshipApplication.Career_Office_Rejection_Reason__c);
    }

    @IsTest
    private static void executeLogicInternshipApplicationCSAcceptanceStepReject() {

        DT_Internship_Application__c preExecuteInternshipApplication = [SELECT Id FROM DT_Internship_Application__c WHERE DT_Status__c = :DT_Utils.INTERNSHIP_APPLICATION_STATUS_IN_PROGRESS LIMIT 1];
        User careerOfficeEmployeeUser = [SELECT Id FROM User WHERE Email = :CS_EMPLOYEE_USER_EMAIL LIMIT 1];
        DT_Internship_Supervisor__c internshipSupervisor = [SELECT Id FROM DT_Internship_Supervisor__c LIMIT 1];
        String processType = CareerOfficeApprovalController.ApprovalProcessType.InternshipApplicationIndividual.name();
        String processStep = CareerOfficeApprovalController.ApprovalProcessStep.CSAcceptance.name();
        String dataAsJson = REJECT_JSON_DATA_WITH_SUPERVISOR_TEMPLATE.replace('{0}', internshipSupervisor.Id);

        Test.startTest();
        System.runAs(careerOfficeEmployeeUser) {
            CareerOfficeApprovalController.executeLogic(processType, processStep, preExecuteInternshipApplication.Id, dataAsJson);
        }
        Test.stopTest();
        DT_Internship_Application__c postExecuteInternshipApplication = [
            SELECT
                Id,
                DT_Career_Office_Employee__c,
                DT_University_Internship_Supervisor__c,
                DT_Status__c,
                Career_Office_Rejection_Reason__c
            FROM DT_Internship_Application__c
            WHERE Id = :preExecuteInternshipApplication.Id];

        Assert.areEqual(careerOfficeEmployeeUser.Id, postExecuteInternshipApplication.DT_Career_Office_Employee__c);
        Assert.areEqual(internshipSupervisor.Id, postExecuteInternshipApplication.DT_University_Internship_Supervisor__c);
        Assert.areEqual(postExecuteInternshipApplication.DT_Status__c, DT_Utils.INTERNSHIP_APPLICATION_STATUS_CS_REJECTION);
        Assert.isNotNull(postExecuteInternshipApplication.Career_Office_Rejection_Reason__c);
    }

    @IsTest
    private static void executeLogicInternshipApplicationSupervisorAcceptanceStepApprove() {
        DT_Internship_Application__c preExecuteInternshipApplication = [SELECT Id FROM DT_Internship_Application__c WHERE DT_Status__c = :DT_Utils.INTERNSHIP_APPLICATION_STATUS_IN_PROGRESS LIMIT 1];
        DT_Internship_Supervisor__c internshipSupervisor = [SELECT Id, DT_User__c FROM DT_Internship_Supervisor__c LIMIT 1];
        String processType = CareerOfficeApprovalController.ApprovalProcessType.InternshipApplicationIndividual.name();
        String processStep = CareerOfficeApprovalController.ApprovalProcessStep.SupervisorAcceptance.name();
        User supervisorUser = [SELECT Id FROM User WHERE Id = :internshipSupervisor.DT_User__c];

        String dataAsJson = BASIC_APPROVE_JSON_DATA;

        Test.startTest();
        System.runAs(supervisorUser) {
            CareerOfficeApprovalController.executeLogic(processType, processStep, preExecuteInternshipApplication.Id, dataAsJson);
        }
        Test.stopTest();
        DT_Internship_Application__c postExecuteInternshipApplication = [
            SELECT Id,
                DT_University_Internship_Supervisor__c,
                DT_Status__c,
                Career_Office_Rejection_Reason__c,
                Internship_Supervisor_Rejection_Reason__c
            FROM DT_Internship_Application__c
            WHERE Id = :preExecuteInternshipApplication.Id];

        Assert.areEqual(internshipSupervisor.Id, postExecuteInternshipApplication.DT_University_Internship_Supervisor__c);
        Assert.areEqual(postExecuteInternshipApplication.DT_Status__c, DT_Utils.INTERNSHIP_APPLICATION_STATUS_READY_TO_PROCEED);
        Assert.isNull(postExecuteInternshipApplication.Career_Office_Rejection_Reason__c);
        Assert.isNull(postExecuteInternshipApplication.Internship_Supervisor_Rejection_Reason__c);
    }

    @IsTest
    private static void executeLogicInternshipApplicationSupervisorAcceptanceStepReject() {
        DT_Internship_Application__c preExecuteInternshipApplication = [SELECT Id FROM DT_Internship_Application__c WHERE DT_Status__c = :DT_Utils.INTERNSHIP_APPLICATION_STATUS_IN_PROGRESS LIMIT 1];
        DT_Internship_Supervisor__c internshipSupervisor = [SELECT Id, DT_User__c FROM DT_Internship_Supervisor__c LIMIT 1];
        User supervisorUser = [SELECT Id FROM User WHERE Id = :internshipSupervisor.DT_User__c];
        String processType = CareerOfficeApprovalController.ApprovalProcessType.InternshipApplicationIndividual.name();
        String processStep = CareerOfficeApprovalController.ApprovalProcessStep.SupervisorAcceptance.name();

        String dataAsJson = BASIC_REJECT_JSON_DATA;

        Test.startTest();
        System.runAs(supervisorUser) {
            CareerOfficeApprovalController.executeLogic(processType, processStep, preExecuteInternshipApplication.Id, dataAsJson);
        }
        Test.stopTest();
        DT_Internship_Application__c postExecuteInternshipApplication = [
            SELECT Id,
                DT_University_Internship_Supervisor__c,
                DT_Status__c,
                Career_Office_Rejection_Reason__c,
                Internship_Supervisor_Rejection_Reason__c
            FROM DT_Internship_Application__c
            WHERE Id = :preExecuteInternshipApplication.Id];

        Assert.areEqual(internshipSupervisor.Id, postExecuteInternshipApplication.DT_University_Internship_Supervisor__c);
        Assert.areEqual(postExecuteInternshipApplication.DT_Status__c, DT_Utils.INTERNSHIP_APPLICATION_STATUS_SUPERVISORS_REJECTION);
        Assert.isNull(postExecuteInternshipApplication.Career_Office_Rejection_Reason__c);
        Assert.isNotNull(postExecuteInternshipApplication.Internship_Supervisor_Rejection_Reason__c);
    }
}