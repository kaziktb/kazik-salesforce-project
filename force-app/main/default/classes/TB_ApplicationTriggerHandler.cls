/**
 * Created by kacperjachowicz on 25/08/2021.
 */

public with sharing class TB_ApplicationTriggerHandler extends TB_TriggerHandler {
    public override void afterUpdate() {
        TB_GenericFieldHistoryTracking.setFieldHistoryTracking(Trigger.newMap,Trigger.oldMap);
    }
}