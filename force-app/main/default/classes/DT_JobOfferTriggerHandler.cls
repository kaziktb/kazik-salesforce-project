public with sharing class DT_JobOfferTriggerHandler extends DT_TriggerHandler {
    private DT_JobOfferTriggerHandler() {}

    public static DT_JobOfferTriggerHandler instance {
        get {
            if (instance == null) {
                instance = new DT_JobOfferTriggerHandler();
            }
            return instance;
        }
        private set;
    }

    public override void afterUpdate() {
        DT_JobOfferTriggerHelper.sendSummaryEmailAfterJobPlacementAcceptance(Trigger.new, (Map<Id, DT_Job_Offers__c>) Trigger.oldMap);
    }
}