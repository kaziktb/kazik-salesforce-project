@IsTest
private class TB_MoodleGetResultSchedulerTest {

    @IsTest
    static void shouldScheduleTwoJobs(){
        //given
        List<String> jobsList = new List<String>();

        //when
        Test.startTest();
        TB_MoodleGetResultScheduler m = new TB_MoodleGetResultScheduler();
        String sch1 = '0 00 * ? * *';
        String sch2 = '0 30 * ? * *';
        String jobID00 = System.schedule('Moodle TEST 00', sch1, m);
        String jobID30 = System.schedule('Moodle TEST 30', sch2, m);
        jobsList.add(jobID00);
        jobsList.add(jobID30);
        Test.stopTest();

        //then
       System.assert([SELECT Id From CronTrigger WHERE Id IN: jobsList].size() == 2, 'Should insert 2 scheduled jobs');
    }

}