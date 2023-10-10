/**
 * Created by Aneta on 19/01/2022.
 */

@IsTest
private class TB_AdmissionsStepHistoryControllerTest {
    @TestSetup
    public static void testSetup() {

        hed__Application__c application = TB_TestDataFactory.createApplicationWithRelatedObjects(false);
        insert application;

        TB_Admissions_Process__c admissionsStage = new TB_Admissions_Process__c(
            RecordTypeId = TB_SObjectUtils.getRecordTypeIdByDevName('TB_Admissions_Process__c', 'TB_Admissions_Stage'),
            Name = 'TestStage',
            TB_Display_Name_PL__c = 'Test',
            TB_Display_Name_EN__c = 'Test',
            TB_Active__c = true,
            TB_Admissions_Process__c = application.TB_Admissions_Process__c
        );
        insert admissionsStage;

        TB_Admissions_Process__c admissionsStep = new TB_Admissions_Process__c(
            RecordTypeId = TB_SObjectUtils.getRecordTypeIdByDevName('TB_Admissions_Process__c', 'TB_Admissions_Step'),
            Name = 'TestStep',
            TB_Display_Name_PL__c = 'Test',
            TB_Display_Name_EN__c = 'Test',
            TB_Active__c = true,
            TB_Admissions_Stage__c = admissionsStage.Id
        );
        insert admissionsStep;
    }

    @IsTest
    public static void insertHistory() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        TB_Admissions_Process__c admissionsStage = [SELECT Id FROM TB_Admissions_Process__c WHERE Name = 'TestStage' LIMIT 1];
        TB_Admissions_Process__c admissionsStep = [SELECT Id FROM TB_Admissions_Process__c WHERE Name = 'TestStep' LIMIT 1];

        String recordTypeId = TB_SObjectUtils.getRecordTypeIdByDevName('TB_Application_Step_History__c','TB_Step_Status_History');
        TB_Application_Step_History__c stepHistory = new TB_Application_Step_History__c(
            TB_Admissions_Stage__c = admissionsStage.Id,
            TB_Admissions_Step__c = admissionsStep.Id,
            TB_Application__c = application.Id,
            TB_Status__c = 'To_Correct',
            TB_Comments__c = 'Popraw',
            RecordTypeId = recordTypeId
        );

        Test.startTest();
        TB_AdmissionsStepHistoryController.insertHistory(stepHistory);
        Test.stopTest();

        System.assertEquals(1,[SELECT Id FROM TB_Application_Step_History__c].size());
    }
}