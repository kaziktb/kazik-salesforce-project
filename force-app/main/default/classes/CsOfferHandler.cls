public with sharing class CsOfferHandler extends TriggerHandler {
    private CsOfferHandler() {}

    public static CsOfferHandler instance {
        get {
            if (instance == null) {
                instance = new CsOfferHandler();
            }
            return instance;
        }
        private set;
    }

    public override void afterInsert() {
        CsOfferHelper.adjustPolishLanguageTag(null, Trigger.new);
    }

    public override void afterUpdate() {
        CsOfferHelper.adjustPolishLanguageTag((Map<Id, Career_Services_Offer__c>) Trigger.oldMap, Trigger.new);
    }
}