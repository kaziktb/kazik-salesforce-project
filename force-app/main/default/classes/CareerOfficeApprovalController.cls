public without sharing class CareerOfficeApprovalController {
    private static final String APPROVAL_PROCESS_FLOW_REJECTION_JUSTIFICATION_PARAM_NAME = 'RejectionJustification';
    private static final String APPROVAL_PROCESS_FLOW_PROCESS_TYPE_PARAM_NAME = 'ProcessType';
    private static final String APPROVAL_PROCESS_FLOW_PROCESS_STEP_PARAM_NAME = 'ProcessStep';
    private static final String APPROVAL_PROCESS_FLOW_RECORD_ID_PARAM_NAME = 'RecordId';
    private static final String APPROVAL_PROCESS_FLOW_IS_APPROVED_PARAM_NAME = 'IsApproved';

    private static Flow.Interview.Career_Office_Approval_Process approvalProcessFlow;

    private static Map<String, ApprovalProcessType> objectApiName2ProcessType = new Map<String, ApprovalProcessType>{
        'DT_Internship__c' => ApprovalProcessType.InternshipOffer,
        'DT_Internship_Application__c' => ApprovalProcessType.InternshipApplicationIndividual
    };

    private static Map<String, ApprovalProcessStep> status2ProcessStep = new Map<String, ApprovalProcessStep>{
        'New Offer' => ApprovalProcessStep.CSAcceptance,
        'In Progress' => ApprovalProcessStep.SupervisorAcceptance,

        'In_progress' => ApprovalProcessStep.CSAcceptance,
        'Re_verification' => ApprovalProcessStep.CSAcceptance,
        'CS_Acceptance' => ApprovalProcessStep.CSAcceptance,
        'Supervisors_Acceptance' => ApprovalProcessStep.SupervisorAcceptance
    };

    //tests12345

    @AuraEnabled
    public static ApprovalProcessData fetchApprovalProcessData(String recordId, String objectApiName) {
        ApprovalProcessData data = new ApprovalProcessData();
        Id currentUserId = UserInfo.getUserId();
        ApprovalProcessType processType = objectApiName2ProcessType.get(objectApiName);

        switch on processType {
            when InternshipOffer {
                data.processType = processType.name();

                DT_Internship__c record = [
                    SELECT Id,
                        Name,
                        DT_Status_Of_The_Offer__c,
                        DT_University_Internship_Supervisor_User__c,
                        DT_Full_Name_Of_The_Organization__c,
                        DT_Internship_Period_From__c,
                        DT_Internship_Period_To__c
                    FROM DT_Internship__c
                    WHERE Id = :recordId
                ];

                ApprovalProcessStep processStep = status2ProcessStep.get(record.DT_Status_Of_The_Offer__c);
                data.record = record;

                switch on processStep {
                    when CSAcceptance {
                        data.processStep = processStep.name();

                        if (isCareerOfficeEmployeeOrAdmin()) {
                            data.canCurrentUserPerformAction = true;
                        }
                    }

                    when SupervisorAcceptance {
                        data.processStep = processStep.name();

                        if (record.DT_University_Internship_Supervisor_User__c == currentUserId) {
                            data.canCurrentUserPerformAction = true;
                        }
                    }
                    when else {
                        data.canCurrentUserPerformAction = false;
                    }
                }
            }

            when InternshipApplicationIndividual {
                data.processType = processType.name();

                DT_Internship_Application__c record = [
                    SELECT Id,
                        Name,
                        RecordTypeId,
                        DT_University_Internship_Supervisor_User__c,
                        DT_Status__c,
                        DT_Program_Enrollment__r.hed__Program_Plan__r.DT_Language_of_Instruction__c
                    FROM DT_Internship_Application__c
                    WHERE Id = :recordId
                ];

                ApprovalProcessStep processStep = status2ProcessStep.get(record.DT_Status__c);
                data.record = record;

                switch on processStep {
                    when CSAcceptance {
                        data.processStep = processStep.name();

                        if (isCareerOfficeEmployeeOrAdmin()) {
                            data.canCurrentUserPerformAction = true;
                        }
                    }

                    when SupervisorAcceptance {
                        data.processStep = processStep.name();

                        if (record.DT_Program_Enrollment__r.hed__Program_Plan__r.DT_Language_of_Instruction__c != null &&
                            record.DT_Program_Enrollment__r.hed__Program_Plan__r.DT_Language_of_Instruction__c == DT_Utils.PROGRAM_PLAN_LANGUAGE_OF_INSTRUCTION_EN) {
                            data.isStudentEN = true;
                        }

                        if (record.DT_University_Internship_Supervisor_User__c == currentUserId) {
                            data.canCurrentUserPerformAction = true;
                        }
                    }

                    when else {
                        data.canCurrentUserPerformAction = false;
                    }
                }
            }
        }

        return data;
    }

    @AuraEnabled
    public static void executeLogic(String processTypeAsString, String processStepAsString, Id recordId, String data) {
        ApprovalProcessType processType = ApprovalProcessType.valueOf(processTypeAsString);
        ApprovalProcessStep processStep = ApprovalProcessStep.valueOf(processStepAsString);

        Map<String, Object> flowParams = createFlowParams(processTypeAsString, processStepAsString, recordId);

        switch on processType {
            when InternshipOffer {
                DT_Internship__c record = [SELECT Id, DT_Status_Of_The_Offer__c FROM DT_Internship__c WHERE Id = :recordId];

                switch on processStep {
                    when CSAcceptance {
                        ApprovalProcessDecisionWithInitSetupResultData parsedData = (ApprovalProcessDecisionWithInitSetupResultData) JSON.deserialize(data, ApprovalProcessDecisionWithInitSetupResultData.class);

                        executeInternshipCareerOfficeEmployeeAcceptanceStepLogic(record, parsedData, flowParams);
                    }

                    when SupervisorAcceptance {
                        ApprovalProcessDecisionResultData parsedData = (ApprovalProcessDecisionResultData) JSON.deserialize(data, ApprovalProcessDecisionResultData.class);
                        flowParams.put(APPROVAL_PROCESS_FLOW_REJECTION_JUSTIFICATION_PARAM_NAME, parsedData.rejectionJustification);

                        executeInternshipSupervisorAcceptanceStepLogic(record, parsedData, flowParams);
                    }
                }
            }

            when InternshipApplicationIndividual {
                DT_Internship_Application__c record = [SELECT Id, DT_Status__c FROM DT_Internship_Application__c WHERE Id = :recordId];

                switch on processStep {
                    when CSAcceptance {
                        ApprovalProcessDecisionWithInitSetupResultData parsedData = (ApprovalProcessDecisionWithInitSetupResultData) JSON.deserialize(data, ApprovalProcessDecisionWithInitSetupResultData.class);

                        executeInternshipApplicationCareerOfficeEmployeeAcceptanceStepLogic(record, parsedData, flowParams);
                    }

                    when SupervisorAcceptance {
                        ApprovalProcessDecisionResultData parsedData = (ApprovalProcessDecisionResultData) JSON.deserialize(data, ApprovalProcessDecisionResultData.class);

                        executeInternshipApplicationSupervisorAcceptanceStepLogic(record, parsedData, flowParams);
                    }
                }
            }
        }

        if (!Test.isRunningTest()) {
            approvalProcessFlow = new Flow.Interview.Career_Office_Approval_Process(flowParams);
            approvalProcessFlow.start();
        }
    }

    private static Map<String, Object> createFlowParams(String processType, String processStep, Id recordId) {
        return new Map<String, Object>{
            APPROVAL_PROCESS_FLOW_PROCESS_TYPE_PARAM_NAME => processType,
            APPROVAL_PROCESS_FLOW_PROCESS_STEP_PARAM_NAME => processStep,
            APPROVAL_PROCESS_FLOW_RECORD_ID_PARAM_NAME => recordId
        };
    }

    private static void executeInternshipCareerOfficeEmployeeAcceptanceStepLogic(DT_Internship__c record, ApprovalProcessDecisionWithInitSetupResultData resultData, Map<String, Object> flowParams) {
        String destinationStatus = DT_Utils.INTERNSHIP_STATUS_IN_PROGRESS;

        flowParams.put(APPROVAL_PROCESS_FLOW_IS_APPROVED_PARAM_NAME, resultData.isApproved);
        resultData.fieldsToUpdate.put(DT_Internship__c.OwnerId.getDescribe().name, UserInfo.getUserId());

        if (!resultData.isApproved) {
            destinationStatus = DT_Utils.INTERNSHIP_STATUS_REJECTED;
            resultData.fieldsToUpdate.put(DT_Internship__c.Career_Office_Rejection_Reason__c.getDescribe().name, resultData.rejectionJustification);
            flowParams.put(APPROVAL_PROCESS_FLOW_REJECTION_JUSTIFICATION_PARAM_NAME, resultData.rejectionJustification);
        }
        resultData.fieldsToUpdate.put(DT_Internship__c.DT_Status_Of_The_Offer__c.getDescribe().name, destinationStatus);

        assignRecordFields(record, resultData.fieldsToUpdate);

        update record;
    }

    private static void executeInternshipSupervisorAcceptanceStepLogic(DT_Internship__c record, ApprovalProcessDecisionResultData resultData, Map<String, Object> flowParams) {
        flowParams.put(APPROVAL_PROCESS_FLOW_IS_APPROVED_PARAM_NAME, resultData.isApproved);

        if (resultData.isApproved) {
            record.DT_Status_Of_The_Offer__c = DT_Utils.INTERNSHIP_STATUS_PUBLISHED;
        } else {
            record.DT_Status_Of_The_Offer__c = DT_Utils.INTERNSHIP_STATUS_REJECTED;
            record.Internship_Supervisor_Rejection_Reason__c = resultData.rejectionJustification;
            flowParams.put(APPROVAL_PROCESS_FLOW_REJECTION_JUSTIFICATION_PARAM_NAME, resultData.rejectionJustification);
        }

        update record;
    }

    private static void executeInternshipApplicationCareerOfficeEmployeeAcceptanceStepLogic(DT_Internship_Application__c record, ApprovalProcessDecisionWithInitSetupResultData resultData, Map<String, Object> flowParams) {
        String destinationStatus = DT_Utils.INTERNSHIP_APPLICATION_STATUS_SUPERVISORS_ACCEPTANCE;

        flowParams.put(APPROVAL_PROCESS_FLOW_IS_APPROVED_PARAM_NAME, resultData.isApproved);
        resultData.fieldsToUpdate.put(DT_Internship_Application__c.DT_Career_Office_Employee__c.getDescribe().name, UserInfo.getUserId());

        if (!resultData.isApproved) {
            destinationStatus = DT_Utils.INTERNSHIP_APPLICATION_STATUS_CS_REJECTION;
            resultData.fieldsToUpdate.put(DT_Internship_Application__c.Career_Office_Rejection_Reason__c.getDescribe().name, resultData.rejectionJustification);
            flowParams.put(APPROVAL_PROCESS_FLOW_REJECTION_JUSTIFICATION_PARAM_NAME, resultData.rejectionJustification);
        }
        resultData.fieldsToUpdate.put(DT_Internship_Application__c.DT_Status__c.getDescribe().name, destinationStatus);

        assignRecordFields(record, resultData.fieldsToUpdate);

        update record;
    }

    private static void executeInternshipApplicationSupervisorAcceptanceStepLogic(DT_Internship_Application__c record, ApprovalProcessDecisionResultData resultData, Map<String, Object> flowParams) {
        flowParams.put(APPROVAL_PROCESS_FLOW_IS_APPROVED_PARAM_NAME, resultData.isApproved);

        if (resultData.isApproved) {
            record.DT_Status__c = DT_Utils.INTERNSHIP_APPLICATION_STATUS_READY_TO_PROCEED;
        } else {
            record.DT_Status__c = DT_Utils.INTERNSHIP_APPLICATION_STATUS_SUPERVISORS_REJECTION;
            record.Internship_Supervisor_Rejection_Reason__c = resultData.rejectionJustification;
            flowParams.put(APPROVAL_PROCESS_FLOW_REJECTION_JUSTIFICATION_PARAM_NAME, resultData.rejectionJustification);
        }

        update record;
    }

    private static Boolean isCareerOfficeEmployeeOrAdmin() {
        return UserInfo.getProfileId() == DT_Utils.getProfileIdByName(DT_Utils.SWPS_CAREER_OFFICE_PROFILE_NAME) ||
            UserInfo.getProfileId() == DT_Utils.getProfileIdByName(Label.System_Administrator_Profile_Name);
    }

    private static void assignRecordFields(SObject record, Map<String, String> fieldsToUpdate) {
        for (String fieldName : fieldsToUpdate.keySet()) {
            record.put(fieldName, fieldsToUpdate.get(fieldName));
        }
    }

    @TestVisible
    private class ApprovalProcessData {
        @AuraEnabled
        public SObject record;
        @AuraEnabled
        public String processType;
        @AuraEnabled
        public String processStep;
        @AuraEnabled
        public Boolean canCurrentUserPerformAction = false;
        @AuraEnabled
        public Boolean isStudentEN = false;
    }

    @TestVisible
    private enum ApprovalProcessType {
        InternshipOffer,
        InternshipApplicationIndividual
    }

    @TestVisible
    private enum ApprovalProcessStep {
        CSAcceptance,
        SupervisorAcceptance
    }

    @TestVisible
    private virtual class ApprovalProcessDecisionResultData {
        Boolean isApproved;
        String rejectionJustification;
    }

    @TestVisible
    private class ApprovalProcessDecisionWithInitSetupResultData extends ApprovalProcessDecisionResultData {
        Map<String, String> fieldsToUpdate;
    }
}