@isTest
private with sharing class TB_ExperienceHistoryControllerTest {
    @TestSetup
    static void setup(){
        hed__Application__c testApplication = TB_TestDataFactory.createApplicationWithRelatedObjects(true);
        TB_Experience_History__c testExperienceHistory = TB_TestDataFactory.createExperienceHistoryWithRecordType(TB_Constants.TB_PD_DIFFERENCES_EXP_RT_ID, testApplication.ID, true, 'Test Experience History 1');
    }

    @isTest
    static void testGetExperienceHistoriesPositive(){
        ID testApplicationId = [SELECT ID FROM hed__Application__c LIMIT 1].ID;

        Test.startTest();
        List<TB_Experience_History__c> testResult = TB_ExperienceHistoryController.getExperienceHistories(testApplicationId);
        Test.stopTest();

        System.assert(testResult.size() == 1, 'test result list should have one record');
    }

    @isTest
    static void testGetExperienceHistoriesNegative(){
        ID testApplicationId = [SELECT ID FROM hed__Application__c LIMIT 1].ID;
        Database.delete(testApplicationId);

        Test.startTest();
        List<TB_Experience_History__c> testResult = TB_ExperienceHistoryController.getExperienceHistories(testApplicationId);
        Test.stopTest();

        System.assert(testResult.size() == 0, 'test result list should have zero record');
    }
}