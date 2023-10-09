/**
 * Created by adriangawryszewski on 1/3/22.
 */
@isTest
public with sharing class TB_PDDifferencesControllerTest {

    @testSetup
    static void testSetup() {
        TB_Offered_Product__c product = TB_TestDataFactory.createOfferedProduct(false);
        insert product;

        Contact contact = new Contact(
                LastName = 'Kowalski'
        );
        insert contact;

        hed__Education_History__c educationHistory = new hed__Education_History__c(
                hed__Contact__c = contact.Id
        );
        insert educationHistory;

        hed__Application__c application = TB_TestDataFactory.createApplication(null, product.Id, false);
        application.hed__Applicant__c = contact.Id;
        application.TB_Product_Group__c = 'Higher_Education';
        insert application;

    }

    @IsTest
    static void testGetPDExperiences() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        List<TB_Experience_History__c> pdDifferences;
        insert TB_TestDataFactory.createExperienceHistoryWithRecordType(TB_Constants.TB_PD_DIFFERENCES_EXP_RT_ID, application.Id, false, 'Test PD Module');
        insert TB_TestDataFactory.createExperienceHistoryWithRecordType(TB_Constants.TB_EDUCATION_EXP_COURSE_AND_TRAIN_RT_ID, application.Id, false, 'Dome other exp');

        Test.startTest();
            pdDifferences = TB_PDDifferencesController.getProgramDifferencesExperiencesForApp(application.Id);
        Test.stopTest();

        System.assertEquals(1, pdDifferences.size());
    }

    @IsTest
    static void testGetProgramDifferencesDocumentSlot() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        TB_Application_Document__c appDoc, appDoc2;
        appDoc = TB_TestDataFactory.createApplicationDocument(false, application.Id, TB_Constants.TB_APP_DOCUMENT_TYPE_ELECTRONIC_TEMPLATE);
        appDoc.TB_Document_Category__c = TB_Constants.TB_APP_DOCUMENT_CAT_PD_DOCUMENT;
        insert appDoc;

        Test.startTest();
            appDoc2 = TB_PDDifferencesController.getProgramDifferencesDocumentSlot(application.Id);
        Test.stopTest();

        System.assertNotEquals(null, appDoc2);

    }

    @IsTest
    static void testUpsertProgramDifferencesExperiencesForApp() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        TB_Experience_History__c exp =  TB_TestDataFactory.createExperienceHistoryWithRecordType(TB_Constants.TB_PD_DIFFERENCES_EXP_RT_ID, application.Id, false, 'Test PD Module');
        insert exp;

        System.assertNotEquals(exp.TB_Score__c, 4);
        System.assertNotEquals(exp.TB_Hours__c, 4);
        System.assertNotEquals(exp.TB_Educational_Institution__c, 'test uni');

        List<TB_Experience_History__c> expsToUpdate = new List<TB_Experience_History__c>();

        Test.startTest();
            exp.TB_Score__c = 4;
            exp.TB_Hours__c = 4;
            exp.TB_Educational_Institution__c = 'test uni';
            expsToUpdate.add(exp);
            TB_PDDifferencesController.upsertProgramDifferencesExperiencesForApp(expsToUpdate);
        Test.stopTest();
        List<TB_Experience_History__c> updatedExps = [SELECT Id, TB_Score__c, TB_Hours__c, TB_Educational_Institution__c FROM TB_Experience_History__c];
        System.assertEquals(updatedExps[0].TB_Score__c, 4);
        System.assertEquals(updatedExps[0].TB_Hours__c, 4);
        System.assertEquals(updatedExps[0].TB_Educational_Institution__c, 'test uni');
        System.assertEquals(updatedExps[0].Id, exp.Id);

    }

    @IsTest
    static void testDeleteProgramDifferencesDocumentSlotDoc() {

        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        TB_Application_Document__c appDoc, appDoc2;
        appDoc = TB_TestDataFactory.createApplicationDocument(false, application.Id, TB_Constants.TB_APP_DOCUMENT_TYPE_ELECTRONIC_TEMPLATE);
        appDoc.TB_Document_Category__c = TB_Constants.TB_APP_DOCUMENT_CAT_PD_DOCUMENT;
        appDoc.TB_Status__c = 'To_Verify';
        insert appDoc;

        Test.startTest();
            TB_PDDifferencesController.deleteProgramDifferencesDocumentSlotDoc(appDoc.Id);
        Test.stopTest();
        appDoc2 = [SELECT Id, TB_Status__c FROM TB_Application_Document__c];
        System.assertNotEquals(appDoc.TB_Status__c, appDoc2.TB_Status__c); 
        System.assertEquals(appDoc2.TB_Status__c, TB_Constants.TB_APP_DOCUMENT_STATUS_EMPTY);

    }

    @IsTest
    static void testDeleteProgramDifferencesDocumentSlotDocNegative() {
        Test.startTest();
        TB_PDDifferencesController.deleteProgramDifferencesDocumentSlotDoc('incorrectId');
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM TB_Log__c]);

    }

    @IsTest
    static void testDeleteProgramDifferencesExperiencesForApp() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        insert TB_TestDataFactory.createExperienceHistoryWithRecordType(TB_Constants.TB_PD_DIFFERENCES_EXP_RT_ID, application.Id, false, 'Test PD Module');
        TB_Experience_History__c experienceHistory = [SELECT Id FROM TB_Experience_History__c LIMIT 1];
        Test.startTest();
        TB_PDDifferencesController.deleteProgramDifferencesExperiencesForApp(experienceHistory.Id);
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM TB_Experience_History__c].size());
    }


}