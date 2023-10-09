/**
 * Created by kacperjachowicz on 16/08/2021.
 */

public with sharing class TB_EmployeeEvaluationTriggerHandler extends TB_TriggerHandler{
    public override void afterUpdate () {
            TB_EmployeeEvaluationTriggerHelper.updateRelationships(Trigger.newMap,Trigger.oldMap);
            TB_GenericDataCollectionUpdate.updateDataCollections(Trigger.newMap);
    }
}