public with sharing class CsInstitutionalApplicationApprovalLogic extends CsApprovalProcessLogicImplementor {
    public enum DecisionValue {
        Approve,
        Reject
    }

    public CsInstitutionalApplicationApprovalLogic() {
        super.registerStage(Constants.CAREER_SERVICES_APPROVAL_PROCESS_STAGE_CAREER_SERVICES_ACCEPTANCE, CareerServicesAcceptanceStageLogic.class.getName());
    }

    public class StageExecutionData {
        public String decision;
        public String comment;
    }

    public class CareerServicesAcceptanceStageLogic extends CsApprovalProcessStageLogicImplementor {
        public override CsApprovalProcessStageExecutionResult execute(Approval_Process__c approvalProcess, String jsonData) {
            StageExecutionData data = (StageExecutionData) JSON.deserializeStrict(jsonData, StageExecutionData.class);
            Career_Services_Application__c application = [SELECT Id, Status__c FROM Career_Services_Application__c WHERE Id = :approvalProcess.Related_Record_Id__c];
            DecisionValue decision = DecisionValue.valueOf(data.decision);
            Boolean hasComment = data.comment != null && data.comment.length() > 0;

            switch on decision {
                when Approve {
                    application.Status__c = Constants.CAREER_SERVICES_APPLICATION_STATUS_APPLICATION_SENT_TO_EMPLOYER;

                    CsApprovalProcessEntryHelper.createDecisionEntry(approvalProcess.Id, approvalProcess.Stage__c, data.decision, true);

                    approvalProcess.Status__c = Constants.CAREER_SERVICES_APPROVAL_PROCESS_STATUS_FINISHED;
                }

                when Reject {
                    application.Status__c = Constants.CAREER_SERVICES_APPLICATION_STATUS_CS_REJECTION;
                    application.Career_Services_Rejection_Reason__c = data.comment;

                    Approval_Process_Entry__c decisionEntry = CsApprovalProcessEntryHelper.createDecisionEntry(approvalProcess.Id, approvalProcess.Stage__c, data.decision, true);

                    if (hasComment) {
                        CsApprovalProcessEntryHelper.createCommentEntry(approvalProcess.Id, approvalProcess.Stage__c, data.comment, decisionEntry.Id, true);
                    }

                    approvalProcess.Status__c = Constants.CAREER_SERVICES_APPROVAL_PROCESS_STATUS_FINISHED;

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
                Constants.CAREER_SERVICES_APPLICATION_STATUS_NEW_APPLICATION
            };

            return Utils.isPermissionSetAssigned(Constants.PERMISSION_SET_CAREER_SERVICES_EMPLOYEE_API_NAME, UserInfo.getUserId())
                && validStatuses.contains(application.Status__c);
        }
    }
}