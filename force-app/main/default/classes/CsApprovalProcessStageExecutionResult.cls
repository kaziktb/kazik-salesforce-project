public virtual class CsApprovalProcessStageExecutionResult {
    public static CsApprovalProcessStageExecutionResult success() {
        CsApprovalProcessStageExecutionResult result = new CsApprovalProcessStageExecutionResult();
        result.isSuccess = true;
        return result;
    }

    public static CsApprovalProcessStageExecutionResult failure() {
        return new CsApprovalProcessStageExecutionResult();
    }

    public static CsApprovalProcessStageExecutionResult failure(CustomException ex) {
        CsApprovalProcessStageExecutionResult result = new CsApprovalProcessStageExecutionResult();
        result.errors.add(ex);
        return new CsApprovalProcessStageExecutionResult();
    }

    public static CsApprovalProcessStageExecutionResult failure(List<CustomException> exceptions) {
        CsApprovalProcessStageExecutionResult result = new CsApprovalProcessStageExecutionResult();
        result.errors.addAll(exceptions);
        return new CsApprovalProcessStageExecutionResult();
    }

    public Boolean isSuccess = false;
    public List<CustomException> errors = new List<CustomException>();
}