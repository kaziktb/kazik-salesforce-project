@IsTest
public class TB_AdmissionsProcessTriggerHelperTest {
    @TestSetup
    static void testSetup(){
        hed__Application__c application = TB_TestDataFactory.createApplicationWithRelatedObjects(true);
        application.hed__Application_Status__c = 'Initially_Selected';

        TB_Admissions_Logic__c admissionsLogic = TB_DataFactory.createAdmissionsLogic(false);
        admissionsLogic.RecordTypeId = Schema.SObjectType.TB_Admissions_Logic__c.getRecordTypeInfosByDeveloperName().get('TB_Redirect_Logic').getRecordTypeId();
        insert admissionsLogic;
    }

    @IsTest
    static void testFillJsonFields(){
        TB_Admissions_Process__c admissionProcess = [SELECT TB_Display_Logic_JSON__c, TB_Edit_Logic_JSON__c FROM TB_Admissions_Process__c LIMIT 1];

        Test.startTest();
        admissionProcess.TB_Display_Logic__c = 'Application.hed__Application_Status__c != \'Initially_Selected\'';
        admissionProcess.TB_Edit_Logic__c = 'Application.hed__Application_Status__c != BLANK AND Application.hed__Application_Status__c = \'Data_Completion\' AND (Application.TB_PD_Status__c != \'To_Verify\' AND Application.TB_PD_Status__c != \'Awaiting_Candidate\')';
        Database.update(admissionProcess);
        Test.stopTest();

        TB_Admissions_Process__c admissionProcessAfterUpdate = [SELECT TB_Display_Logic_JSON__c, TB_Edit_Logic_JSON__c FROM TB_Admissions_Process__c LIMIT 1];

        System.assertEquals('{"singleLogicWrappers":[{"value":"\'Initially_Selected\'","order":1,"operator":"!=","fieldName":"hed__Application__c.hed__Application_Status__c"}],"order":"1"}', admissionProcessAfterUpdate.TB_Display_Logic_JSON__c);
        System.assertEquals('{"singleLogicWrappers":[{"value":"\'\'","order":1,"operator":"!=","fieldName":"hed__Application__c.hed__Application_Status__c"},{"value":"\'Data_Completion\'","order":2,"operator":"=","fieldName":"hed__Application__c.hed__Application_Status__c"},{"value":"\'To_Verify\'","order":3,"operator":"!=","fieldName":"hed__Application__c.TB_PD_Status__c"},{"value":"\'Awaiting_Candidate\'","order":4,"operator":"!=","fieldName":"hed__Application__c.TB_PD_Status__c"}],"order":"1 AND 2 AND ( 3 AND 4 ) "}', admissionProcessAfterUpdate.TB_Edit_Logic_JSON__c);
    }

    @IsTest
    static void testFillJsonFieldsForRedirectLogic(){
        TB_Admissions_Logic__c admissionsLogic = [SELECT TB_Redirect_Logic_JSON__c FROM TB_Admissions_Logic__c LIMIT 1];

        Test.startTest();
        admissionsLogic.TB_Redirect_Logic__c = 'Application.hed__Application_Status__c != \'Initially_Selected\'';
        Database.update(admissionsLogic);
        Test.stopTest();

        TB_Admissions_Logic__c admissionLogicAfterUpdate = [SELECT TB_Redirect_Logic_JSON__c FROM TB_Admissions_Logic__c LIMIT 1];

        System.assertEquals('{"singleLogicWrappers":[{"value":"\'Initially_Selected\'","order":1,"operator":"!=","fieldName":"hed__Application__c.hed__Application_Status__c"}],"order":"1"}', admissionLogicAfterUpdate.TB_Redirect_Logic_JSON__c);
    }

    @IsTest
    static void testRemoveAdmissionProcess(){
        hed__Application__c application = [SELECT TB_Admissions_Process__c FROM hed__Application__c LIMIT 1];
        TB_Admissions_Process__c admissionProcess = [SELECT Id FROM TB_Admissions_Process__c LIMIT 1];

        Test.startTest();
        Database.delete(application);
        Database.delete(admissionProcess);
        Test.stopTest();

        System.assert([SELECT Id FROM hed__Application__c LIMIT 1].isEmpty());
        System.assert([SELECT Id FROM TB_Admissions_Process__c LIMIT 1].isEmpty());
    }
}