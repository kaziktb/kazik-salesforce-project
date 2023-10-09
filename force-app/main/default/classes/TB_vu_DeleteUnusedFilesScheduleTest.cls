@isTest
private class TB_vu_DeleteUnusedFilesScheduleTest {
    private static final String CRON_EXP = '0 0 0 11 11 ? 2030';

    @isTest
    private static void shouldScheduleApexClass() 
    {
        Test.startTest();
        String jobId = System.schedule(
            'TB_vu_DeleteUnusedFilesScheduleTest',
            CRON_EXP, 
            new TB_vu_DeleteUnusedFilesSchedule()
        );
        Test.stopTest();

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        Assert.areEqual(CRON_EXP, ct.CronExpression);
        Assert.areEqual(0, ct.TimesTriggered);
        Assert.areEqual('2030-11-11 00:00:00', String.valueOf(ct.NextFireTime));
    }
    
}