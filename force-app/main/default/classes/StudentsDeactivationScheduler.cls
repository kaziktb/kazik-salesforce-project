public with sharing class StudentsDeactivationScheduler implements Schedulable {
    public static final String EVERY_DAY_CRON = '0 0 2 ? * * *';
    public static final String JOB_NAME = 'Students Deactivation Job';

    public void execute(SchedulableContext sc) {
        StudentsDeactivationBatch batch = new StudentsDeactivationBatch();
        Database.executeBatch(batch);
    }

    public void scheduleEveryday(String jobName) {
        cronScheduling(EVERY_DAY_CRON, jobName);
    }

    public void cronScheduling(String cronExpression, String jobName) {
        System.schedule(jobName, cronExpression, this);
    }
}