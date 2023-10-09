public with sharing class CsIndividualApplicationApprovalLogic extends CsApprovalProcessLogicImplementor {
    public enum DecisionValue {
        Approve,
        Reject,
        Reverification,
        CsReverification
    }

    public CsIndividualApplicationApprovalLogic() {
        super.registerStage(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_CAREER_SERVICES_ACCEPTANCE, CareerServicesAcceptanceStageLogic.class.getName());
        super.registerStage(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_SUPERVISOR_ACCEPTANCE, SupervisorAcceptanceStageLogic.class.getName());
    }

    public class StageExecutionData {
        public String decision;
        public String comment;
        public Map<String, String> fieldsToUpdate;
    }

    public class CareerServicesAcceptanceStageLogic extends CsApprovalProcessStageLogicImplementor {
        public override CsApprovalProcessStageExecutionResult execute(Approval_Process__c approvalProcess, String jsonData) {
            StageExecutionData data = (StageExecutionData) JSON.deserializeStrict(jsonData, StageExecutionData.class);
            Career_Services_Application__c application = [SELECT Id, Status__c FROM Career_Services_Application__c WHERE Id = :approvalProcess.Related_Record_Id__c];
            DecisionValue decision = DecisionValue.valueOf(data.decision);
            Boolean hasComment = data.comment != null && data.comment.length() > 0;

            switch on decision {
                when Approve {
                    application.Status__c = Constants.CAREER_SERVICES_APPLICATION_STATUS_SENT_FOR_SUPERVISOR_ACCEPTANCE;

                    Approval_Process_Entry__c decisionEntry = CsApprovalProcessEntryHelper.createDecisionEntry(approvalProcess.Id, approvalProcess.Stage__c, data.decision, true);

                    if (hasComment) {
                        CsApprovalProcessEntryHelper.createCommentEntry(approvalProcess.Id, approvalProcess.Stage__c, data.comment, decisionEntry.Id, true);
                    }

                    approvalProcess.Stage__c = Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_SUPERVISOR_ACCEPTANCE;

                    Utils.assignRecordFields(application, data.fieldsToUpdate);
                }
                when Reject {
                    application.Status__c = Constants.CAREER_SERVICES_APPLICATION_STATUS_CS_REJECTION;
                    application.Career_Services_Rejection_Reason__c = data.comment;

                    Approval_Process_Entry__c decisionEntry = CsApprovalProcessEntryHelper.createDecisionEntry(approvalProcess.Id, approvalProcess.Stage__c, data.decision, true);
                    CsApprovalProcessEntryHelper.createCommentEntry(approvalProcess.Id, approvalProcess.Stage__c, data.comment, decisionEntry.Id, true);

                    approvalProcess.Status__c = Constants.CAREER_SERVICES_APPROVAL_PROCESS_STATUS_FINISHED;
                }
                when Reverification {
                    application.Status__c = Constants.CAREER_SERVICES_APPLICATION_STATUS_CORRECTION_NEEDED;
                    Approval_Process_Entry__c decisionEntry = CsApprovalProcessEntryHelper.createDecisionEntry(approvalProcess.Id, approvalProcess.Stage__c, data.decision, true);

                    if (hasComment) {
                        CsApprovalProcessEntryHelper.createCommentEntry(approvalProcess.Id, approvalProcess.Stage__c, data.comment, decisionEntry.Id, true);
                    }
                }
            }

            update application;
            update approvalProcess;

            return CsApprovalProcessStageExecutionResult.success();
        }

        public override CsApprovalProcessStageBaseData retrieveStageData(Approval_Process__c approvalProcess) {
            return super.initStepBaseData(canPerformAction(approvalProcess.Related_Record_Id__c));
        }

        private Boolean canPerformAction(Id relatedRecordId) {
            Career_Services_Application__c application = [SELECT Id, Status__c FROM Career_Services_Application__c WHERE Id = :relatedRecordId];

            List<String> validStatuses = new List<String>{
                Constants.CAREER_SERVICES_APPLICATION_STATUS_NEW_APPLICATION,
                Constants.CAREER_SERVICES_APPLICATION_STATUS_REVERIFICATION,
                Constants.CAREER_SERVICES_APPLICATION_STATUS_CS_REVERIFICATION
            };

            return validStatuses.contains(application.Status__c)
                && Utils.isPermissionSetAssigned(Constants.PERMISSION_SET_CAREER_SERVICES_EMPLOYEE_API_NAME, UserInfo.getUserId());
        }
    }

    public class SupervisorAcceptanceStageLogic extends CsApprovalProcessStageLogicImplementor {
        public override CsApprovalProcessStageExecutionResult execute(Approval_Process__c approvalProcess, String jsonData) {
            StageExecutionData data = (StageExecutionData) JSON.deserializeStrict(jsonData, StageExecutionData.class);
            Career_Services_Application__c application = [SELECT Status__c FROM Career_Services_Application__c WHERE Id = :approvalProcess.Related_Record_Id__c];
            DecisionValue decision = DecisionValue.valueOf(data.decision);
            Boolean hasComment = data.comment != null && data.comment.length() > 0;

            switch on decision {
                when Approve {
                    application.Status__c = Constants.CAREER_SERVICES_APPLICATION_STATUS_AGREEMENT_CREATION;

                    Approval_Process_Entry__c decisionEntry = CsApprovalProcessEntryHelper.createDecisionEntry(approvalProcess.Id, approvalProcess.Stage__c, data.decision, true);

                    if (hasComment) {
                        CsApprovalProcessEntryHelper.createCommentEntry(approvalProcess.Id, approvalProcess.Stage__c, data.comment, decisionEntry.Id, true);
                    }

                    approvalProcess.Status__c = Constants.CAREER_SERVICES_APPROVAL_PROCESS_STATUS_FINISHED;
                }
                when Reject {
                    application.Status__c = Constants.CAREER_SERVICES_APPLICATION_STATUS_SUPERVISOR_REJECTION;
                    application.Internal_Supervisor_Rejection_Reason__c = data.comment;
                    
                    Approval_Process_Entry__c decisionEntry = CsApprovalProcessEntryHelper.createDecisionEntry(approvalProcess.Id, approvalProcess.Stage__c, data.decision, true);
                    CsApprovalProcessEntryHelper.createCommentEntry(approvalProcess.Id, approvalProcess.Stage__c, data.comment, decisionEntry.Id, true);

                    approvalProcess.Status__c = Constants.CAREER_SERVICES_APPROVAL_PROCESS_STATUS_FINISHED;
                }
                when CsReverification {
                    application.Status__c = Constants.CAREER_SERVICES_APPLICATION_STATUS_CS_REVERIFICATION;
                    Approval_Process_Entry__c decisionEntry = CsApprovalProcessEntryHelper.createDecisionEntry(approvalProcess.Id, approvalProcess.Stage__c, data.decision, true);
                    if (hasComment) {
                        CsApprovalProcessEntryHelper.createCommentEntry(approvalProcess.Id, approvalProcess.Stage__c, data.comment, decisionEntry.Id, true);
                    }

                    approvalProcess.Stage__c = Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_CAREER_SERVICES_ACCEPTANCE;
                }
            }

            update approvalProcess;
            update application;

            return CsApprovalProcessStageExecutionResult.success();
        }

        public override CsApprovalProcessStageBaseData retrieveStageData(Approval_Process__c approvalProcess) {
            Set<Id> supervisorUserIds = new Set<Id>();

            for (Internship_Supervisor__c supervisor : [SELECT User__c FROM Internship_Supervisor__c]) {
                supervisorUserIds.add(supervisor.User__c);
            }

            Boolean canPerformAction = canPerformAction(approvalProcess.Related_Record_Id__c);
            Boolean isAllowedToSendReminder = Utils.isPermissionSetAssigned(Constants.PERMISSION_SET_CAREER_SERVICES_EMPLOYEE_API_NAME, UserInfo.getUserId()) && !supervisorUserIds.contains(UserInfo.getUserId());
            CsApprovalProcessStageBaseData data = super.initStepBaseData(canPerformAction);

            if (!isAllowedToSendReminder) {
                return data;
            }

            Boolean canSendReminder = true;
            List<Approval_Process_Entry__c> lastReminderEntries = [
                SELECT CreatedDate
                FROM Approval_Process_Entry__c
                WHERE Approval_Process__c = :approvalProcess.Id
                    AND RecordType.DeveloperName = :Constants.CAREER_SERVICES_APPROVAL_PROCESS_ENTRY_REMINDER_RECORD_TYPE
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];

            JSONGenerator jsonData = JSON.createGenerator(false);
            jsonData.writeStartObject();
            jsonData.writeBooleanField('isAllowedToSendReminder', isAllowedToSendReminder);

            if (!lastReminderEntries.isEmpty()) {
                jsonData.writeDateField('lastReminderDate', lastReminderEntries[0].CreatedDate.date());
                canSendReminder = lastReminderEntries[0].CreatedDate.date().daysBetween(Date.today()) >= 3;
            }
            jsonData.writeBooleanField('canSendReminder', canSendReminder);
            jsonData.writeEndObject();

            data.jsonData = jsonData.getAsString();

            return data;
        }

        private Boolean canPerformAction(Id relatedRecordId) {
            Career_Services_Application__c application = [SELECT Internal_Supervisor__r.User__c, Status__c FROM Career_Services_Application__c WHERE Id = :relatedRecordId];

            return application.Status__c == Constants.CAREER_SERVICES_APPLICATION_STATUS_SENT_FOR_SUPERVISOR_ACCEPTANCE
                   && UserInfo.getUserId() == application.Internal_Supervisor__r.User__c;
        }
    }
}
