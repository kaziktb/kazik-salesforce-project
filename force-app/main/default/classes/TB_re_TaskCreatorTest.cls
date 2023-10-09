@IsTest
public with sharing class TB_re_TaskCreatorTest {

    @TestSetup
    static void testSetup() {
        User user = TB_TestDataFactory.createUser(TB_Constants.PROFILE_NAME_ADMINISTRATOR, true);
        Contact contact = TB_TestDataFactory.createContact(false);
        contact.TB_User__c = user.Id;
        insert contact;
    }

    @IsTest
    static void createTasksPositive() {
        User user = [SELECT Id FROM User ORDER BY CreatedDate DESC LIMIT 1];
        Contact contact = [SELECT Id, AccountId FROM Contact ORDER BY CreatedDate DESC LIMIT 1];
        Task task = new Task(
            OwnerId = user.Id,
            Priority = 'Normal',
            Status = 'In_Progress',
            Subject = 'Draft',
            WhatId = contact.AccountId,
            WhoId = contact.Id
        );

        Test.startTest();
        TB_re_TaskCreator.createTasks(new List<List<Task>>{new List<Task>{task}});
        Test.stopTest();

        List<Task> tasks = [
            SELECT Id
            FROM Task
            WHERE OwnerId = :user.Id
            AND Priority = 'Normal'
            AND Status = 'In_Progress'
            AND Subject = 'Draft'
            AND WhatId = :contact.AccountId
            AND WhoId = :contact.Id
        ];
        System.assertEquals(1, tasks.size());
        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
    }

}