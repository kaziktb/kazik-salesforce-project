/**
 * Created by jowitakozlak on 30/07/2021.
 */


@IsTest
public with sharing class TB_SendAcademicActivityReportNotifTest {

    @TestSetup
    static void testSetup() {

        Contact administrator = new Contact(
            LastName = 'Kowal',
            TB_Included_In_Evaluations__c = false,
            hed__WorkEmail__c = 'test@test.com'
        );
        insert administrator;
        Contact didactic = new Contact(
            LastName = 'Kot',
            TB_Included_In_Evaluations__c = true,
            TB_Employee_Group__c = 'Didactic',
            TB_Dean__c = administrator.Id,
            hed__WorkEmail__c = 'test@test.com',
            TB_Employee_Number__c = '00001'
        );
        insert didactic;
        TB_Employee_Evaluation_Process_Stage__c employeeEvaluationProcessStage = new TB_Employee_Evaluation_Process_Stage__c(
            Name='Test',
            TB_Process_Stage_Type__c = 'Academic Activity Report'
        );
        insert employeeEvaluationProcessStage;
        TB_Employee_Evaluation_Stage__c employeeEvaluationStage = new TB_Employee_Evaluation_Stage__c(
            Name='Test',
            TB_First_Reminder_Date__c = System.today(),
            TB_First_Reminder_Recipient__c = 'Evaluated',
            TB_Second_Reminder_Date__c = System.today(),
            TB_Second_Reminder_Recipient__c = 'Process Administrator',
            TB_Employee_Stage_Type__c = 'Academic Activity Report',
            TB_Evaluation_Stage_Status__c = 'New',
            TB_Evaluated__c = didactic.Id,
            TB_Administrator__c = administrator.Id,
            TB_Employee_Evaluation_Process_Stage__c = employeeEvaluationProcessStage.Id
        );
        insert employeeEvaluationStage;
    }

    @IsTest
    static void sendFirstSecondReminderPositive() {

        Test.startTest();
        TB_SendAcademicActivityReportNotif.sendAcademicActivityReportFirstSecondReminder();
        Test.stopTest();

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void sendFirstSecondReminderEmpty() {

        TB_Employee_Evaluation_Stage__c stage = [
            SELECT Id, TB_First_Reminder_Date__c, TB_Second_Reminder_Date__c
            FROM TB_Employee_Evaluation_Stage__c
            WHERE Name =: 'Test'
            LIMIT 1
        ];
        stage.TB_First_Reminder_Date__c = System.today().addDays(1) ;
        stage.TB_Second_Reminder_Date__c = System.today().addDays(1);
        update stage;

        Test.startTest();
        TB_SendAcademicActivityReportNotif.sendAcademicActivityReportFirstSecondReminder();
        Test.stopTest();

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }
}