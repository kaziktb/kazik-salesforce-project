/**
 * Created by Aneta on 28/01/2022.
 */

@IsTest
private class TB_ApplicationDocumentTriggerHandlerTest {
    @TestSetup
    static void testSetup(){
        hed__Application__c application
            = TB_TestDataFactory.createApplicationWithRelatedObjects(false);
        insert application;
        TB_Application_Document__c applicationDocument
            = TB_TestDataFactory.createApplicationDocument(false, application.Id, TB_Constants.TB_APP_DOCUMENT_TYPE_ELECTRONIC);
        applicationDocument.TB_Status__c = 'Empty';
        applicationDocument.TB_Document_Category__c = TB_Constants.TB_APP_DOCUMENT_CATEGORY_STUDY_AGREEMENT_ELECTRONIC;
        insert applicationDocument;
    }

    @isTest
    static void updateApplicationDocumentStatus(){
        TB_Application_Document__c applicationDocument = [SELECT Id FROM TB_Application_Document__c LIMIT 1];
        Test.startTest();
        applicationDocument.TB_Status__c = 'To_Verify';
        Database.update(applicationDocument);
        Test.stopTest();

        System.assertEquals('Concluded', [SELECT TB_Status__c FROM TB_Application_Document__c LIMIT 1].TB_Status__c);
    }

}