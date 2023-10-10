/**
 * Created by arturlydkowski on 05/07/2021.
 */

public with sharing class TB_DataCollectionTriggerHandler extends TB_TriggerHandler  {
    public override void beforeInsert() {
        TB_DataCollectionTriggerHelper.fetchSourceAndTargetFields(Trigger.new);
    }

    public override void afterInsert() {
        TB_DataCollectionTriggerHelper.updateJsonField(Trigger.new);
    }

    public override void afterUpdate() {
        TB_DataCollectionTriggerHelper.updateJsonField(Trigger.new);
        if (firstRun) {
            TB_DataCollectionTriggerHelper.setTargetValues(Trigger.new, (Map<Id,TB_Data_Collection__c>) Trigger.oldMap);
        }
    }
}