@IsTest
public class DT_TaskTriggerHandlerTest {
    @TestSetup
    private static void dataInit () {
        User adminUser = DT_DataFactory.createAdminUser();
            System.runAs( adminUser ) {
                DT_DataFactory.createStudentUser();
             }
    }

    @IsTest
    private static void deleteTaskAsStudent () {
        User studentUser = DT_TestClassUtils.getUserByEmail( DT_DataFactory.USER_STUDENT_EMAIL );
        Task t = DT_DataFactory.createTasks(
                1, true, new Task(
                Priority = 'Normal',
                Subject = 'Task to delete',
                OwnerId = studentUser.Id
                )
        ).get(0);

        Test.startTest();
            System.runAs(studentUser) {
                try {
                    delete t;
                } catch (Exception e) {
                    System.assertEquals(e.getMessage().contains(System.Label.DT_No_Permission_To_Delete), true);
             }
            }
        Test.stopTest();
    }
}