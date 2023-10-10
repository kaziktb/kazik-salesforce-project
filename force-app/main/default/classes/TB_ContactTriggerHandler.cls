public with sharing class TB_ContactTriggerHandler extends TB_TriggerHandler {

    public override void afterUpdate() {
        TB_GenericFieldHistoryTracking.setFieldHistoryTracking(Trigger.newMap,Trigger.oldMap);
    }

    public override void beforeInsert() {
        TB_ContactActionsRestrictions.checkRestrictions(Trigger.new);
    }

    public override void beforeUpdate() {
        TB_ContactActionsRestrictions.checkRestrictions((Map<Id, Contact>) Trigger.newMap,
            (Map<Id, Contact>) Trigger.oldMap);
    }

}