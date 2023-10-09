/**
 * Created by Aneta on 15/07/2021.
 */
@IsTest
public with sharing class TB_FilesListViewControllerTest {

    @TestSetup
    static void testSetup() {

        TB_Employee_Evaluation_Process_Stage__c eeProcessStage = TB_TestDataFactory.prepareEmployeeEvaluationProcessStage(
            TB_Constants.EEPS_TYPE_ACADEMIC_ACTIVITY_REPORT
        );
        insert eeProcessStage;

        Contact evalauted = TB_TestDataFactory.prepareContact(false);
        insert evalauted;

        TB_Employee_Evaluation__c eEvaluation = TB_TestDataFactory.prepareEmployeeEvaluation(evalauted.Id, TB_Constants.EE_PROCESS_TYPE_DIDACTIC);
        insert  eEvaluation;

        TB_Employee_Evaluation_Stage__c eEvaluationStage = TB_TestDataFactory.prepareEmployeeEvaluationStage(
            eeProcessStage.Id, eEvaluation.Id
        );
        insert eEvaluationStage;

        TB_Data_Collection__c dataCollection = TB_TestDataFactory.prepareDataCollection(eEvaluationStage.Id);
        insert dataCollection;

        TB_Employee_Evaluation_Stage_Document__c stageDocument  = TB_TestDataFactory.prepareEmployeeEvaluationStageDocument(
            dataCollection.Id, eEvaluationStage.Id
        );
        insert stageDocument;


        ContentVersion contentVersion = new ContentVersion (
            PathOnClient = 'Title',
            Title = 'Title',
            VersionData = Blob.valueOf('Test'),
            ContentLocation = 's'
        );
        insert contentVersion;

        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :contentVersion.Id];

        ContentDocumentLink contentDocumentLink = new ContentDocumentLink (
            ContentDocumentId = testContent.ContentDocumentId,
            LinkedEntityId = stageDocument.Id,
            ShareType = 'V'
        );
        insert contentDocumentLink;
        //TODO: dodać wersję z plikami (ContentLink)
    }



    @IsTest
    static void getFilesForDataCollection() {

        String dataCollectionId = [
                SELECT Id
                FROM TB_Data_Collection__c
                LIMIT 1
        ].Id;

        Test.startTest();
        TB_FilesListViewController.getFilesForRecordId(dataCollectionId);
        Test.stopTest();
    }

    @IsTest
    static void getFilesForInvalidRecordId() {

        Contact c = [
            SELECT Id
            FROM Contact
            LIMIT 1
        ];
        Test.startTest();
        TB_FilesListViewController.getFilesForRecordId(c.Id);
        Test.stopTest();
    }

    @IsTest
    static void getFilesForEvaluationStage() {

        String employeeEvaluationStageId = [
                SELECT Id
                FROM TB_Employee_Evaluation_Stage__c
                LIMIT 1
        ].Id;

        Test.startTest();
        TB_FilesListViewController.getFilesForRecordId(employeeEvaluationStageId);
        Test.stopTest();
    }

    @IsTest
    static void deleteFileNegative() {
        Test.startTest();
        TB_FilesListViewController.deleteFile(null);
        Test.stopTest();
        System.assertEquals(1,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void deleteFilePositive() {
        ContentDocument contentDocument = [
            SELECT Id
            FROM ContentDocument
            LIMIT 1
        ];
        Test.startTest();
        TB_FilesListViewController.deleteFile(contentDocument.Id);
        Test.stopTest();
    }

    @IsTest
    static void getLoginURL() {
        Test.startTest();
        TB_FilesListViewController.getLoginURL();
        Test.stopTest();
    }
    
    @IsTest
    static void getExperienceUrl() {
        Test.startTest();
        TB_FilesListViewController.getExperienceUrl();
        Test.stopTest();
    }
}