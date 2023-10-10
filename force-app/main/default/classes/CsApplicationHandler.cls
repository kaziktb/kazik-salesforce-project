public with sharing class CsApplicationHandler extends TriggerHandler {

    private CsApplicationHandler() {}

    public static CsApplicationHandler instance {
        get {
            if (instance == null) {
                instance = new CsApplicationHandler();
            }
            return instance;
        }
        private set;
    }

    public override void afterInsert() {
        CsApplicationHelper.countApplications(null, Trigger.new);
    }

    public override void beforeUpdate() {
        CsApplicationHelper.blockIndividualApplicationsWithoutAgreement((Map<Id, Career_Services_Application__c>) Trigger.oldMap, Trigger.new);
    }

    public override void afterUpdate() {
        CsApplicationHelper.countApplications((Map<Id, Career_Services_Application__c>) Trigger.oldMap, Trigger.new);
    }

    public override void afterDelete() {
        CsApplicationHelper.countApplications(null, Trigger.old);
    }

}