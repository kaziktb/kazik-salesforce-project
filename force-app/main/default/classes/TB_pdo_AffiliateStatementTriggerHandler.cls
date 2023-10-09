public with sharing class TB_pdo_AffiliateStatementTriggerHandler extends TB_TriggerHandler {
  public override void afterUpdate() {
    TB_GenericFieldHistoryTracking.setFieldHistoryTracking(
      Trigger.newMap,
      Trigger.oldMap
    );
  }
  public override void beforeUpdate() {
    TB_pdo_AffiliationStatementHelper.executeGeneratorPdf(
      Trigger.new,
      Trigger.old
    );
  }
}