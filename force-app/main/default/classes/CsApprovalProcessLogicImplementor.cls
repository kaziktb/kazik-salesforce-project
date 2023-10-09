public abstract class CsApprovalProcessLogicImplementor {
    @TestVisible
    private final Map<String, String> STAGE_NAME_2_STAGE_IMPLEMENTOR_CLASS_NAME = new Map<String, String>();

    protected void registerStage(String stageName, String stageLogicImplementorClassName) {
        STAGE_NAME_2_STAGE_IMPLEMENTOR_CLASS_NAME.put(stageName, stageLogicImplementorClassName);
    }

    public virtual CsApprovalProcessStageExecutionResult executeCurrentStage(Id approvalProcessId, String jsonData) {
        Approval_Process__c approvalProcess = fetchAndValidateApprovalProcessOrThrow(approvalProcessId);

        try {
            CsApprovalProcessStageLogicImplementor stepLogicImplementor = getStageLogicImplementor(approvalProcess.Stage__c);

            return stepLogicImplementor.execute(approvalProcess, jsonData);
        } catch (CustomException ex) {
            ex.saveLog();
            return CsApprovalProcessStageExecutionResult.failure(ex);
        }
    }

    public virtual CsApprovalProcessStageBaseData fetchCurrentStageData(Id approvalProcessId) {
        Approval_Process__c approvalProcess = fetchAndValidateApprovalProcessOrThrow(approvalProcessId);

        CsApprovalProcessStageLogicImplementor stepLogicImplementor = getStageLogicImplementor(approvalProcess.Stage__c);

        return stepLogicImplementor.retrieveStageData(approvalProcess);
    }

    private Approval_Process__c fetchAndValidateApprovalProcessOrThrow(Id approvalProcessId) {
        Approval_Process__c[] approvalProcesses = [SELECT Status__c, Stage__c, Related_Record_Id__c FROM Approval_Process__c WHERE Id = :approvalProcessId];

        if (approvalProcesses.isEmpty()) {
            throw new CustomException.ApprovalProcessNotExistsException().saveLog();
        }

        Approval_Process__c approvalProcess = approvalProcesses[0];

        if (approvalProcess.Status__c != Constants.CAREER_SERVICES_APPROVAL_PROCESS_STATUS_ACTIVE) {
            throw new CustomException.ApprovalProcessNoLongerActiveException().saveLog();
        }

        if (!STAGE_NAME_2_STAGE_IMPLEMENTOR_CLASS_NAME.containsKey(approvalProcess.Stage__c)) {
            throw new CustomException.ApprovalProcessStageLogicNotFoundException().saveLog();
        }

        return approvalProcess;
    }

    private CsApprovalProcessStageLogicImplementor getStageLogicImplementor(String stageName) {
        String implementorClassName = STAGE_NAME_2_STAGE_IMPLEMENTOR_CLASS_NAME.get(stageName);

        return  (CsApprovalProcessStageLogicImplementor) Type.forName(implementorClassName).newInstance();

    }
}