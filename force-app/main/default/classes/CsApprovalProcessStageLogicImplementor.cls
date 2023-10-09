public abstract class CsApprovalProcessStageLogicImplementor {
    public abstract CsApprovalProcessStageExecutionResult execute(Approval_Process__c approvalProcess, String jsonData);
    public abstract CsApprovalProcessStageBaseData retrieveStageData(Approval_Process__c approvalProcess);

    public CsApprovalProcessStageBaseData initStepBaseData(Boolean canPerformAction) {
        CsApprovalProcessStageBaseData stepBaseData = new CsApprovalProcessStageBaseData();
        stepBaseData.canPerformAction = canPerformAction;
        return stepBaseData;
    }
}