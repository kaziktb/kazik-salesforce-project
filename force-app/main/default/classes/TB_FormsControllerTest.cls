/**
 * Created by jowitakozlak on 13/08/2021.
 */

@IsTest
public with sharing class TB_FormsControllerTest {

    @TestSetup
    static void testSetup() {

        Contact evaluated = TB_TestDataFactory.prepareContact('Evaluated',false);
        evaluated.TB_Scientific_Discipline_1_X__c = '100%';
        insert evaluated;
        Contact contact = TB_TestDataFactory.prepareContact('Contact',true);

        TB_Employee_Evaluation_Process_Stage__c processStage
            = TB_TestDataFactory.prepareEmployeeEvaluationProcessStage('Evaluation of Academic Activity');
        insert processStage;

        TB_Employee_Evaluation__c evaluation
            = TB_TestDataFactory.prepareEmployeeEvaluation(evaluated.Id, 'Didactic');
        evaluation.TB_Evaluator__c = contact.Id;
        evaluation.TB_Supervisor__c = contact.Id;
        evaluation.TB_Rector__c = contact.Id;
        evaluation.TB_Administrator__c = contact.Id;
        insert evaluation;

        TB_Employee_Evaluation_Stage__c stage
            = TB_TestDataFactory.prepareEmployeeEvaluationStage(processStage.Id, evaluation.Id);
        stage.TB_Evaluation_Stage_Status__c = 'New';
        stage.Name = 'Testowy etap';
        stage.TB_Evaluated__c = evaluated.Id;
        stage.TB_Evaluator__c = contact.Id;
        stage.TB_Supervisor__c = contact.Id;
        stage.TB_Rector__c = contact.Id;
        stage.TB_Administrator__c = contact.Id;
        stage.TB_Employee_Stage_Type__c = 'Evaluation of Academic Activity';
        insert stage;

        TB_Data_Collection__c dataCollection
            = TB_TestDataFactory.prepareDataCollection(stage.Id);
        insert dataCollection;

        insert TB_TestDataFactory.prepareEmployeeEvaluationStageDocument(dataCollection.Id,stage.Id);

        TB_JSON_Wrapper__c jsonWrapper = new TB_JSON_Wrapper__c(
            TB_Order__c = 0,
            TB_Wrapper_Value__c
                = '[{"attributes":{"type":"TB_Data_Collection__c","url":"/services/data/v52.0/sobjects/TB_Data_Collection__c/a1j1x0000012CDfAAM"},' +
                '"TB_Purpose__c":"Header","TB_Web_Excluded__c":false,"TB_Name_EN__c":"<p><b>ASSESSMENT</b></p>","TB_Active__c":true,' +
                '"TB_Name_PL__c":"<p><b>OCENA</b></p>","TB_Employee_Evaluation__c":"a1a1x000002lKT8AAM","RecordTypeId":"0121x000002i6fVAAQ",' +
                '"TB_File__c":false,"Id":"a1j1x0000012CDfAAM","TB_Employee_Evaluation_Stage__c":"a1b1x000004R6TNAA0"},' +
                '{"attributes":{"type":"TB_Data_Collection__c","url":"/services/data/v52.0/sobjects/TB_Data_Collection__c/a1j1x0000012CDgAAM"},' +
                '"TB_Purpose__c":"Read Only","TB_Web_Excluded__c":false,"TB_Name_EN__c":"<p><b>Applies to: </b></p>","TB_Active__c":true,' +
                '"TB_Name_PL__c":"<p><b>Dotyczy: </b></p>","TB_Employee_Evaluation__c":"a1a1x000002lKT8AAM","RecordTypeId":"0121x000002i6fVAAQ",' +
                '"TB_File__c":false,"Id":"a1j1x0000012CDgAAM","TB_Employee_Evaluation_Stage__c":"a1b1x000004R6TNAA0"},' +
                '{"attributes":{"type":"TB_Data_Collection__c","url":"/services/data/v52.0/sobjects/TB_Data_Collection__c/a1j1x0000012CDoAAM"},' +
                '"TB_Picklist_Values_EN__c":"Scientist and Didactic;Scientist;Didactic","TB_Target_Object__c":"Evaluated","TB_Characters__c":255.0,' +
                '"TB_Employee_Evaluation__c":"a1a1x000002lKT8AAM","TB_Target_Object_Id__c":"0031x000019LyB0AAK",' +
                '"TB_Source_Object_Id__c":"0031x000019LyB0AAK","RecordTypeId":"0121x000002i6fVAAQ","TB_File__c":true,' +
                '"TB_Picklist_API_Names__c":"Scientist and Didactic;Scientist;Didactic","TB_Purpose__c":"Read Only","TB_Web_Excluded__c":true,' +
                '"TB_Name_EN__c":"Employment in the group","TB_Data_Type__c":"Picklist","TB_Active__c":true,"TB_Name_PL__c":"Zatrudnienie w grupie",' +
                '"TB_Value_Text__c":"Scientist","TB_Source_Object__c":"Evaluated","Id":"a1j1x0000012CDoAAM",' +
                '"TB_Employee_Evaluation_Stage__c":"a1b1x000004R6TNAA0","TB_Target_Object_Field__c":"TB_Employee_Group__c",' +
                '"TB_Picklist_Values_PL__c":"Badawczo-dydaktyczny;Badawczy;Dydaktyczny","TB_Source_Object_Field__c":"TB_Employee_Group__c"}]',
            TB_Object_Id__c = stage.Id
        );
        insert jsonWrapper;

    }

    @IsTest
    static void getDataCollectionsFromJSON() {

        TB_Employee_Evaluation_Stage__c stage = [
            SELECT Id
            FROM TB_Employee_Evaluation_Stage__c
            WHERE Name = 'Testowy etap'
        ];

        Test.startTest();
        TB_FormsController.getDataCollectionsFromJSON(stage.Id);
        Test.stopTest();

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void isObjection() {

        TB_Employee_Evaluation_Stage__c stage = [
            SELECT Id
            FROM TB_Employee_Evaluation_Stage__c
            WHERE Name = 'Testowy etap'
        ];

        Test.startTest();
        Boolean isObjection = TB_FormsController.isObjection(stage.Id);
        Test.stopTest();

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
        System.assertEquals(false,isObjection);
    }

    @IsTest
    static void evaluationReadyToSignByEvaluated() {

        TB_Employee_Evaluation_Stage__c stage = [
            SELECT Id, TB_Evaluator_Signature__c
            FROM TB_Employee_Evaluation_Stage__c
            WHERE Name = 'Testowy etap'
        ];
        stage.TB_Evaluator_Signature__c = true;
        update stage;

        Test.startTest();
        Boolean readyToSignByEvaluated = TB_FormsController.evaluationReadyToSignByEvaluated(stage.Id);
        Test.stopTest();

        System.assertEquals(false,readyToSignByEvaluated);
    }

    @IsTest
    static void validateUser() {

        TB_Employee_Evaluation_Stage__c stage = [
            SELECT Id
            FROM TB_Employee_Evaluation_Stage__c
            WHERE Name = 'Testowy etap'
        ];

        Test.startTest();
        TB_FormsController.validateUser(stage.Id);
        Test.stopTest();

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void signAndSend() {

        TB_Employee_Evaluation_Stage__c stage = [
            SELECT Id
            FROM TB_Employee_Evaluation_Stage__c
            WHERE Name = 'Testowy etap'
        ];

        Test.startTest();
        String signatureNotification = TB_FormsController.signAndSend(stage.Id);
        Test.stopTest();

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
        System.assert(!String.isBlank(signatureNotification));
    }

    @IsTest
    static void updateSignature() {

        TB_Employee_Evaluation_Stage__c stage = [
            SELECT Id
            FROM TB_Employee_Evaluation_Stage__c
            WHERE Name = 'Testowy etap'
        ];

        Test.startTest();
        TB_FormsController.updateSignature(stage.Id);
        Test.stopTest();

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void validateDataCollectionsWithFiles() {

        TB_Employee_Evaluation_Stage__c stage = [
            SELECT Id
            FROM TB_Employee_Evaluation_Stage__c
            WHERE Name = 'Testowy etap'
        ];
        List<TB_Data_Collection__c> dataCollection = [
            SELECT Id, TB_Employee_Evaluation_Stage__c
            FROM TB_Data_Collection__c
            WHERE TB_Employee_Evaluation_Stage__c = :stage.Id
        ];

        Test.startTest();
        TB_FormsController.validateDataCollectionsWithFiles(new List<Id>{dataCollection[0].Id});
        Test.stopTest();

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void updateDataCollectionsPositive() {

        TB_Employee_Evaluation_Stage__c stage = [
            SELECT Id
            FROM TB_Employee_Evaluation_Stage__c
            WHERE Name = 'Testowy etap'
        ];
        List<TB_Data_Collection__c> dataCollection = [
            SELECT Id, TB_Employee_Evaluation_Stage__c
            FROM TB_Data_Collection__c
            WHERE TB_Employee_Evaluation_Stage__c = :stage.Id
        ];

        Test.startTest();
        String errorMessage = TB_FormsController.updateDataCollections(JSON.serialize(dataCollection));
        Test.stopTest();

        System.assertEquals('',errorMessage);
    }
/*
    @IsTest
    static void updateDataCollectionsNegative() {

        TB_Employee_Evaluation_Stage__c stage = [
            SELECT Id
            FROM TB_Employee_Evaluation_Stage__c
            WHERE Name = 'Testowy etap'
        ];
        TB_Data_Collection__c primaryPercentage
            = TB_TestDataFactory.prepareDataCollection(
                stage.Id,
                'Evaluated',
                'TB_Scientific_Discipline_1_X__c',
                'Evaluated',
                'TB_Scientific_Discipline_1_X__c'
            );
        primaryPercentage.TB_Data_Type__c = 'Picklist';
        primaryPercentage.TB_Picklist_Values_PL__c = '100%';
        primaryPercentage.TB_Picklist_Values_EN__c = '100%';
        primaryPercentage.TB_Picklist_API_Names__c = '100%';
        insert primaryPercentage;
        TB_Data_Collection__c secondaryPercentage
            = TB_TestDataFactory.prepareDataCollection(
                stage.Id,
                'Evaluated',
                'TB_Scientific_Discipline_2_X__c',
                'Evaluated',
                'TB_Scientific_Discipline_2_X__c'
            );
        secondaryPercentage.TB_Data_Type__c = 'Picklist';
        secondaryPercentage.TB_Picklist_Values_PL__c = '100%';
        secondaryPercentage.TB_Picklist_Values_EN__c = '100%';
        secondaryPercentage.TB_Picklist_API_Names__c = '100%';
        insert secondaryPercentage;
        List<TB_Data_Collection__c> dataCollections = [
            SELECT Id, TB_Employee_Evaluation_Stage__c, TB_Value_Text__c
            FROM TB_Data_Collection__c
            WHERE TB_Employee_Evaluation_Stage__c = :stage.Id
        ];

        for (TB_Data_Collection__c dc :dataCollections) {
            if (dc.Id == secondaryPercentage.Id) {
                dc.TB_Value_Text__c = '100%';

            }
        }

        Test.startTest();
        String errorMessage = TB_FormsController.updateDataCollections(JSON.serialize(dataCollections));
        Test.stopTest();

        System.assert(String.isNotBlank(errorMessage));
    }
*/
    @IsTest
    static void changeStageStatusToInProgress() {

        TB_Employee_Evaluation_Stage__c stage = [
            SELECT Id
            FROM TB_Employee_Evaluation_Stage__c
            WHERE Name = 'Testowy etap'
        ];

        Test.startTest();
        TB_FormsController.changeStageStatusToInProgress(stage.Id);
        Test.stopTest();

        TB_Employee_Evaluation_Stage__c stageAfterUpdate = [
            SELECT Id, TB_Evaluation_Stage_Status__c
            FROM TB_Employee_Evaluation_Stage__c
            WHERE Name = 'Testowy etap'
        ];

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
        System.assertEquals('In Progress',stageAfterUpdate.TB_Evaluation_Stage_Status__c);
    }

    @IsTest
    static void finalMarkGiven() {

        TB_Employee_Evaluation_Stage__c stage = [
            SELECT Id, TB_Employee_Stage_Type__c
            FROM TB_Employee_Evaluation_Stage__c
            WHERE Name = 'Testowy etap'
        ];
        stage.TB_Employee_Stage_Type__c = 'Final Assessment';
        update stage;

        Test.startTest();
        Boolean finalMarkGiven = TB_FormsController.finalMarkGiven(stage.Id);
        Test.stopTest();

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
        System.assertEquals(false,finalMarkGiven);
    }

    @IsTest
    static void signAndSendWithEvaluator() {

        TB_Employee_Evaluation_Stage__c stage = [
            SELECT Id, TB_Employee_Stage_Type__c, TB_Evaluator__r.TB_User__c
            FROM TB_Employee_Evaluation_Stage__c
            WHERE Name = 'Testowy etap'
        ];
        stage.TB_Evaluator__r.TB_User__c = UserInfo.getUserId();
        update stage.TB_Evaluator__r;

        String signatureNotification;
        Test.startTest();
        signatureNotification = TB_FormsController.signAndSend(stage.Id);
        Test.stopTest();

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
        System.assert(!String.isBlank(signatureNotification));
    }

    @IsTest
    static void signAndSendWithEvaluated() {

        TB_Employee_Evaluation_Stage__c stage = [
            SELECT Id, TB_Employee_Stage_Type__c, TB_Evaluated__r.TB_User__c
            FROM TB_Employee_Evaluation_Stage__c
            WHERE Name = 'Testowy etap'
        ];
        stage.TB_Evaluated__r.TB_User__c = UserInfo.getUserId();
        update stage.TB_Evaluated__r;

        String signatureNotification;
        Test.startTest();
        signatureNotification = TB_FormsController.signAndSend(stage.Id);
        Test.stopTest();

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
        System.assert(!String.isBlank(signatureNotification));
    }

    @IsTest
    static void signAndSendWithRector() {

        TB_Employee_Evaluation_Stage__c stage = [
            SELECT Id, TB_Employee_Stage_Type__c, TB_Rector__r.TB_User__c
            FROM TB_Employee_Evaluation_Stage__c
            WHERE Name = 'Testowy etap'
        ];
        stage.TB_Rector__r.TB_User__c = UserInfo.getUserId();
        update stage.TB_Rector__r;

        String signatureNotification;
        Test.startTest();
        signatureNotification = TB_FormsController.signAndSend(stage.Id);
        Test.stopTest();

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
        System.assert(!String.isBlank(signatureNotification));
    }

    @IsTest
    static void signAndSendWithSupervisor() {

        TB_Employee_Evaluation_Stage__c stage = [
            SELECT Id, TB_Employee_Stage_Type__c, TB_Supervisor__c, TB_Supervisor_Signature__c
            FROM TB_Employee_Evaluation_Stage__c
            WHERE Name = 'Testowy etap'
        ];
        Contact contact = [
            SELECT Id, TB_User__c
            FROM Contact
            WHERE Id =: stage.TB_Supervisor__c
        ];

        stage.TB_Supervisor_Signature__c = true;
        update stage;
        contact.TB_User__c = UserInfo.getUserId();
        update contact;

        String signatureNotification;
        Test.startTest();
        signatureNotification = TB_FormsController.signAndSend(stage.Id);
        Test.stopTest();

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
        System.assert(!String.isBlank(signatureNotification));
    }

}