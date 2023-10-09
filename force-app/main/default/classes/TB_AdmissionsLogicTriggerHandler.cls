public without sharing class TB_AdmissionsLogicTriggerHandler extends TB_TriggerHandler {
    public override void beforeInsert() {
        TB_AdmissionsLogicTriggerHelper.handleLogicFieldCorrectness(Trigger.new, (Map<Id, TB_Admissions_Logic__c>) Trigger.oldMap);
        TB_AdmissionsLogicTriggerHelper.fillJSONFields(Trigger.new);
        TB_AdmissionsLogicTriggerHelper.handleJsonFieldCorrectness(Trigger.new, (Map<Id, TB_Admissions_Logic__c>) Trigger.oldMap);
    }

    public override void beforeUpdate() {
        TB_AdmissionsLogicTriggerHelper.handleLogicFieldCorrectness(Trigger.new, (Map<Id, TB_Admissions_Logic__c>) Trigger.oldMap);
        TB_AdmissionsLogicTriggerHelper.fillJSONFields(Trigger.new);
        TB_AdmissionsLogicTriggerHelper.handleJsonFieldCorrectness(Trigger.new, (Map<Id, TB_Admissions_Logic__c>) Trigger.oldMap);
    }
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