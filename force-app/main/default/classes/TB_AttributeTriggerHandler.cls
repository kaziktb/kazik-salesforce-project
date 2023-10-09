public with sharing class TB_AttributeTriggerHandler extends TB_TriggerHandler  {
    public override void afterUpdate () {
        if (firstRun) {
            TB_GenericDataCollectionUpdate.updateDataCollections(Trigger.newMap);
        }
    }
}