public with sharing class TB_CT_LastActivityManager {
    private static final Datetime TEST_DATETIME = Datetime.newInstance(2022, 02, 02, 12, 0, 0);
    private static final Datetime DATETIME_NOW = Test.isRunningTest() ? TEST_DATETIME : Datetime.now();

public Datetime getCurrentDateTimePoland() {
        Datetime now = DATETIME_NOW;
        Integer offset = TimeZone.getTimeZone(TB_Constants.TIMEZONE_POLAND).getOffset(now);
        Datetime currentDateTimePoland = now.addSeconds(offset / 1000);
        return Test.isRunningTest() ? TEST_DATETIME :currentDateTimePoland;
    }
}