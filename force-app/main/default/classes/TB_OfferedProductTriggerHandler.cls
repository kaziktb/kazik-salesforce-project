public with sharing class TB_OfferedProductTriggerHandler extends TB_TriggerHandler {

    public override void afterInsert() {
        TB_GenericJsonWrapperGenerator.upsertJsonWrappers(Trigger.new);
    }

    public override void afterUpdate() {
        TB_GenericFieldHistoryTracking.setFieldHistoryTracking(Trigger.newMap,Trigger.oldMap);
        TB_GenericJsonWrapperGenerator.upsertJsonWrappers(Trigger.new);
    }

    public override void beforeDelete() {
        TB_GenericJsonWrapperGenerator.deleteRelatedJsonWrappers(Trigger.oldMap);
    }
}