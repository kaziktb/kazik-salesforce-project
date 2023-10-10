/**
 * Created by jowitakozlak on 22/11/2021.
 */

public with sharing class TB_AdmissionsProcessTriggerHandler extends TB_TriggerHandler {
    public override void beforeInsert() {
        TB_AdmissionsProcessTriggerHelper.handleLogicFieldCorrectness(Trigger.new, (Map<Id, TB_Admissions_Process__c>) Trigger.oldMap);
        TB_AdmissionsProcessTriggerHelper.fillJSONFields(Trigger.new);
        TB_AdmissionsProcessTriggerHelper.handleJsonFieldCorrectness(Trigger.new, (Map<Id, TB_Admissions_Process__c>) Trigger.oldMap);
    }

    public override void beforeUpdate() {
        TB_AdmissionsProcessTriggerHelper.handleLogicFieldCorrectness(Trigger.new, (Map<Id, TB_Admissions_Process__c>) Trigger.oldMap);
        TB_AdmissionsProcessTriggerHelper.fillJSONFields(Trigger.new);
        TB_AdmissionsProcessTriggerHelper.handleJsonFieldCorrectness(Trigger.new, (Map<Id, TB_Admissions_Process__c>) Trigger.oldMap);
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