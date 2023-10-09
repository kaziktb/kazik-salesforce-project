public with sharing class CsOfferContractDeactivationScheduler implements Schedulable {
    public static final String EVERY_DAY_CRON = '0 0 0 ? * * *';
    public static final String JOB_NAME = 'Career Services Offer Contracts Deactivation/Activation Job';
    public void execute(SchedulableContext context) {
        Database.executeBatch(new CsOfferContractDeactivationBatch());
    }

    public void scheduleEveryday(String jobName) {
        cronScheduling(EVERY_DAY_CRON, jobName);
    }

    public void cronScheduling(String cronExpression, String jobName) {
        if (!AutomationBypass__c.getInstance().Bypass_Automations__c) {
           throw new CustomException.MissingBypassException('Cannot schedule this batch while ' + AutomationBypass__c.Bypass_Automations__c.getDescribe().name + ' is not set to true').saveLog();
        }

        System.schedule(jobName, cronExpression, this);
    }
}