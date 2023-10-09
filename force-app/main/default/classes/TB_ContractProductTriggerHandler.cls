public with sharing class TB_ContractProductTriggerHandler extends TB_TriggerHandler {
    public override void afterInsert() {
        TB_GenericJsonWrapperGenerator.upsertJsonWrappers(Trigger.new);
    }

    public override void afterUpdate() {
        TB_GenericJsonWrapperGenerator.upsertJsonWrappers(Trigger.new);
    }

    public override void beforeDelete() {
        TB_GenericJsonWrapperGenerator.deleteRelatedJsonWrappers(Trigger.oldMap);
    }
}