public with sharing class TB_pdo_PdoTriggerHandler extends TB_TriggerHandler {
  public override void afterUpdate() {
    TB_GenericFieldHistoryTracking.setFieldHistoryTracking(
      Trigger.newMap,
      Trigger.oldMap
    );
  }
}