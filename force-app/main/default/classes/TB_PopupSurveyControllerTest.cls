/**
 * Created by jowitakozlak on 03/03/2022.
 */

@IsTest
public with sharing class TB_PopupSurveyControllerTest {

    @TestSetup
    static void testSetup() {
        hed__Application__c application = TB_TestDataFactory.createApplicationWithRelatedObjectsAndNestedLookup(false);
        Contact applicant = new Contact(
            LastName = 'Test'
        );
        insert applicant;
        application.hed__Applicant__c = applicant.Id;
        insert application;
        TB_Admissions_Survey__c survey = new TB_Admissions_Survey__c(
            RecordTypeId = Schema.SObjectType.TB_Admissions_Survey__c.getRecordTypeInfosByDeveloperName().get('TB_Survey').getRecordTypeId(),
            TB_Active__c = true,
            Name = 'Test'
        );
        insert survey;
        TB_Admissions_Survey__c question = new TB_Admissions_Survey__c(
            RecordTypeId = Schema.SObjectType.TB_Admissions_Survey__c.getRecordTypeInfosByDeveloperName().get('TB_Question').getRecordTypeId(),
            TB_Active__c = true,
            Name = 'Test',
            TB_Survey__c = survey.Id,
            TB_Question_Type__c = 'Single_Choice'
        );
        insert question;
        TB_Admissions_Survey__c questionValue = new TB_Admissions_Survey__c(
            RecordTypeId = Schema.SObjectType.TB_Admissions_Survey__c.getRecordTypeInfosByDeveloperName().get('TB_Question_Value').getRecordTypeId(),
            TB_Active__c = true,
            Name = 'Test',
            TB_Question__c = question.Id
        );
        insert questionValue;
        TB_Admissions_Logic__c surveyLogic = TB_DataFactory.createAdmissionsLogic(false);
        surveyLogic.RecordTypeId = Schema.SObjectType.TB_Admissions_Logic__c.getRecordTypeInfosByDeveloperName().get('TB_Survey_Logic').getRecordTypeId();
        surveyLogic.TB_Active__c = true;
        surveyLogic.TB_Admissions_Process__c = application.TB_Admissions_Process__c;
        surveyLogic.TB_Admissions_Survey__c = survey.Id;
        surveyLogic.TB_Display_Logic__c = 'Application.hed__Application_Status__c=\'Verification\'';
        insert surveyLogic;
    }

    //TODO- rework on preprod
    // @IsTest
    // static void getSurveyLogics() {
    //     hed__Application__c app = [SELECT Id, TB_Admissions_Process_Id__c FROM hed__Application__c LIMIT 1];
    //     app = TB_AdmissionsFormsController.getApplication(app.Id);

    //     Test.startTest();
    //     String resultJSON = TB_PopupSurveyController.getSurveyLogics(app, 'EN');
    //     Test.stopTest();

    //     List<TB_PopupSurveyController.SurveyLogicsWrapper> result = (List<TB_PopupSurveyController.SurveyLogicsWrapper>) JSON.deserialize(resultJSON, List<TB_PopupSurveyController.SurveyLogicsWrapper>.class);
    //     System.assertEquals(1,result.size());
    // }

    @IsTest
    static void updateApplication() {
        hed__Application__c app = [SELECT Id, TB_Survey_Answer__c FROM hed__Application__c LIMIT 1];
        TB_Admissions_Survey__c questionValue = [SELECT Id FROM TB_Admissions_Survey__c LIMIT 1];

        Test.startTest();
        TB_PopupSurveyController.updateApplication(app.Id, questionValue.Id);
        Test.stopTest();

        hed__Application__c appAfterUpdate = [SELECT Id, TB_Survey_Answer__c FROM hed__Application__c LIMIT 1];
        System.assertEquals(questionValue.Id,appAfterUpdate.TB_Survey_Answer__c);
        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

}