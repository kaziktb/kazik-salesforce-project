@IsTest
public class CsOfferContractDeactivationSchedulerTest {

    private static final String PROCESS_AUTOMATION_TEST_USER_USERNAME = 'pautom@email.com.test';
    private static final String JOB_NAME_TEST = 'Career Services Offer Contracts Deactivation/Activation Job Test';

    @TestSetup
    static void setup() {
        User processAutomationUser = UserTestDataFactory.createProcessAutomationUser(true, PROCESS_AUTOMATION_TEST_USER_USERNAME);

        System.runAs(processAutomationUser) {
            AutomationBypassTestDataFactory.createAutomationBypassConfigForUser(true, processAutomationUser.Id);
        }
    }
    @IsTest
    static void everyNightScheduling() {
        User processAutomationUser = [SELECT Id FROM User WHERE Username = :PROCESS_AUTOMATION_TEST_USER_USERNAME];

        CsOfferContractDeactivationScheduler scheduler = new CsOfferContractDeactivationScheduler();

        System.runAs(processAutomationUser) {
            Test.startTest();
            scheduler.scheduleEveryday(JOB_NAME_TEST);
            Test.stopTest();
        }

        CronJobDetail jobDetail = [SELECT Id FROM CronJobDetail WHERE Name = :JOB_NAME_TEST];
        List<CronTrigger> cronTriggers = [SELECT Id FROM CronTrigger WHERE CronJobDetailId = :jobDetail.Id];

        Assert.isFalse(cronTriggers.isEmpty());
    }

    @IsTest
    static void schedulingWithoutBypassThrowsError() {
        CsOfferContractDeactivationScheduler scheduler = new CsOfferContractDeactivationScheduler();

        try {
            Test.startTest();
            scheduler.scheduleEveryday(JOB_NAME_TEST);
            Test.stopTest();
        } catch (CustomException.MissingBypassException e) {

        }

        Logger__c log =
        [
            SELECT
                Id,
                Apex_Method_Name__c,
                Apex_Class_Name__c,
                Exception_Type__c,
                Exception_Message__c,
                Stack_Trace__c
            FROM Logger__c
            WHERE Apex_Class_Name__c = :CsOfferContractDeactivationScheduler.class.getName()
            LIMIT 1
        ];

        Assert.isNotNull(log);
        Assert.isNotNull(log.Exception_Message__c);
        Assert.isNotNull(log.Stack_Trace__c);
        Assert.areEqual('CsOfferContractDeactivationScheduler', log.Apex_Class_Name__c);
        Assert.areEqual('cronScheduling', log.Apex_Method_Name__c);
        Assert.areEqual(CustomException.MissingBypassException.class.getName(), log.Exception_Type__c);
    }
}