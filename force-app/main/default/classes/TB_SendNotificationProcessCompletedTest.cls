/**
 * Created by Aneta on 20/08/2021.
 */

@IsTest
private class TB_SendNotificationProcessCompletedTest {
    @TestSetup
    static void testSetup() {

        Contact rector = TB_TestDataFactory.prepareContact(false);
        insert rector;

        Contact administrator = TB_TestDataFactory.prepareContact(false);
        insert administrator;

        TB_Employee_Evaluation_Process__c process = new TB_Employee_Evaluation_Process__c(
            Name = 'Test',
            TB_Rector__c = rector.Id,
            TB_Administrator__c = administrator.Id
        );
        insert process;

    }

    @IsTest
    static void sendNotificationToProcessAdministrator() {

        String processId = [
            SELECT Id
            FROM TB_Employee_Evaluation_Process__c
            LIMIT 1
        ].Id;
        Test.startTest();
        TB_SendNotificationProcessCompleted.SendNotificationToProcessAdministrator(processId,true);
        Test.stopTest();
    }
}