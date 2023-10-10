public with sharing class ApprovalProcessTriggerHandler extends DT_TriggerHandler {
    private ApprovalProcessTriggerHandler() {
    }

    public static ApprovalProcessTriggerHandler instance {
        get {
            if (instance == null) {
                instance = new ApprovalProcessTriggerHandler();
            }
            return instance;
        }
        private set;
    }

    public override void beforeInsert() {
        ApprovalProcessTriggerHelper.checkActiveProcessDuplication(null, Trigger.new);
    }

    public override void beforeUpdate() {
        ApprovalProcessTriggerHelper.checkActiveProcessDuplication((Map<Id, Approval_Process__c>) Trigger.oldMap, Trigger.new);
    }
}