public virtual class CsApprovalProcessStageBaseData {
    public CsApprovalProcessStageBaseData() {
    }

    @AuraEnabled
    public Boolean canPerformAction = false;
    @AuraEnabled
    public String jsonData;
}