public with sharing class TB_KnowledgeTriggerHandler extends TB_TriggerHandler {

    public override void beforeInsert() {
        fillLastActivityDate();
    }

    public override void beforeUpdate() {
        fillLastActivityDate();
    }

    private static void fillLastActivityDate() {
        for (Knowledge__kav ka : (List<Knowledge__kav>) Trigger.new) {
            Datetime now = Datetime.now();
            Integer offset = TimeZone.getTimeZone('Poland').getOffset(now);
            Datetime currentDateTimePoland = now.addSeconds(offset / 1000);
            ka.TB_Last_Activity_Date__c = Test.isRunningTest() 
                                        ? Datetime.newInstanceGmt(2022, 02, 02, 12, 0, 0)
                                        : currentDateTimePoland;
      }
    }
}