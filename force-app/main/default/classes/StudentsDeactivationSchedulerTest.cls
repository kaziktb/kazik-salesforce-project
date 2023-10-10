@IsTest
private class StudentsDeactivationSchedulerTest {
    private static final String JOB_NAME = 'Test Students Deactivation Job';
    @IsTest
    static void everyNightSchedulingTest() {
        StudentsDeactivationScheduler scheduler = new StudentsDeactivationScheduler();

        Test.startTest();
        scheduler.scheduleEveryday(JOB_NAME);
        Test.stopTest();

        CronJobDetail jobDetail = [SELECT Id FROM CronJobDetail WHERE Name = :JOB_NAME];
        List<CronTrigger> cronTriggers = [SELECT Id FROM CronTrigger WHERE CronJobDetailId = :jobDetail.Id];

        Assert.isFalse(cronTriggers.isEmpty());
    }
}