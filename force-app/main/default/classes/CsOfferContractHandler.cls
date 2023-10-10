public with sharing class CsOfferContractHandler extends TriggerHandler {

    private CsOfferContractHandler() {}

    public static CsOfferContractHandler instance {
        get {
            if (instance == null) {
                instance = new CsOfferContractHandler();
            }
            return instance;
        }
        private set;
    }

    public override void beforeUpdate() {
        CsOfferContractHelper.validatePublishedContractDuplication((Map<Id, Career_Services_Offer_Contract__c>) Trigger.oldMap, Trigger.new);
    }

    public override void beforeInsert() {
        CsOfferContractHelper.validatePublishedContractDuplication(null, Trigger.new);
    }
}