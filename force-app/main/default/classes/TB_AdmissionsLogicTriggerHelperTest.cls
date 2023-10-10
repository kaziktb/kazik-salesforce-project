/**
 * Created by jowitakozlak on 22/02/2022.
 */

@IsTest
public without sharing class TB_AdmissionsLogicTriggerHelperTest {

    @TestSetup
    static void testSetup(){
        TB_Admissions_Logic__c redirectLogic = TB_DataFactory.createAdmissionsLogic(false);
        redirectLogic.TB_Description__c = 'redirect';
        redirectLogic.RecordTypeId = Schema.SObjectType.TB_Admissions_Logic__c.getRecordTypeInfosByDeveloperName().get('TB_Redirect_Logic').getRecordTypeId();
        insert redirectLogic;
        TB_Admissions_Logic__c messageLogic = TB_DataFactory.createAdmissionsLogic(false);
        messageLogic.TB_Description__c = 'message';
        messageLogic.RecordTypeId = Schema.SObjectType.TB_Admissions_Logic__c.getRecordTypeInfosByDeveloperName().get('TB_Message_Logic').getRecordTypeId();
        insert messageLogic;
    }

    @IsTest
    static void testFillJsonFieldsForRedirectLogic(){
        TB_Admissions_Logic__c admissionsLogic = [
            SELECT TB_Redirect_Logic_JSON__c
            FROM TB_Admissions_Logic__c
            WHERE TB_Description__c = 'redirect'
            LIMIT 1
        ];

        Test.startTest();
        admissionsLogic.TB_Redirect_Logic__c = 'Application.hed__Application_Status__c = \'Initially_Selected\'';
        Database.update(admissionsLogic);
        Test.stopTest();

        TB_Admissions_Logic__c admissionLogicAfterUpdate = [
            SELECT TB_Redirect_Logic_JSON__c
            FROM TB_Admissions_Logic__c
            WHERE TB_Description__c = 'redirect'
            LIMIT 1
        ];

        System.assertEquals('{"singleLogicWrappers":[{"value":"\'Initially_Selected\'","order":1,"operator":"=","fieldName":"hed__Application__c.hed__Application_Status__c"}],"order":"1"}', admissionLogicAfterUpdate.TB_Redirect_Logic_JSON__c);
    }

    @IsTest
    static void testFillJsonFieldsForMessageLogic(){
        TB_Admissions_Logic__c admissionsLogic = [
            SELECT TB_Display_Logic_JSON__c
            FROM TB_Admissions_Logic__c
            WHERE TB_Description__c = 'message'
            LIMIT 1
        ];

        Test.startTest();
        admissionsLogic.TB_Display_Logic__c = 'Application.hed__Application_Status__c != \'Initially_Selected\'';
        Database.update(admissionsLogic);
        Test.stopTest();

        TB_Admissions_Logic__c admissionLogicAfterUpdate = [
            SELECT TB_Display_Logic_JSON__c
            FROM TB_Admissions_Logic__c
            WHERE TB_Description__c = 'message'
            LIMIT 1
        ];

        System.assertEquals('{"singleLogicWrappers":[{"value":"\'Initially_Selected\'","order":1,"operator":"!=","fieldName":"hed__Application__c.hed__Application_Status__c"}],"order":"1"}', admissionLogicAfterUpdate.TB_Display_Logic_JSON__c);
    }

}