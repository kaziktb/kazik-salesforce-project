@isTest
private class TB_PdfControllerLwcTest {
    @TestSetup
    static void testSetup(){
        prepareData();
    }

    @isTest
    private static void testGeneratePdfDocumentsForGivenTemplateNegative(){
        ID testApplicationId = [SELECT ID FROM hed__Application__c LIMIT 1].ID;
        ID testDocumentTemplateId = [SELECT TB_Output_Format__c FROM TB_Document_Template__c LIMIT 1].ID;
        Database.delete(testDocumentTemplateId);

        Test.startTest();
        String testResult = TB_PdfControllerLwc.generatePdfDocumentsForGivenTemplate(testDocumentTemplateId, testApplicationId);
        Test.stopTest();

        System.assertEquals('There is problem with Document Template, you should check it.', testResult, 'test should have error message');
    }

    @isTest
    private static void testGeneratePdfDocumentsForGivenTemplatePositive(){
        ID testApplicationId = [SELECT ID FROM hed__Application__c LIMIT 1].ID;
        Contact testApplicant = [SELECT TB_Communication_Language__c FROM Contact LIMIT 1];
        List<TB_Document_Template__c> testDocumentTemplates = [SELECT ID FROM TB_Document_Template__c];
        List<String> testResults = new List<String>();

        Test.startTest();
        testResults.add(TB_PdfControllerLwc.generatePdfDocumentsForGivenTemplate(testDocumentTemplates[0].ID, testApplicationId));
        testResults.add(TB_PdfControllerLwc.generatePdfDocumentsForGivenTemplate(testDocumentTemplates[1].ID, testApplicationId));
        testApplicant.TB_Communication_Language__c = 'Polish';
        Database.update(testApplicant);
        testResults.add(TB_PdfControllerLwc.generatePdfDocumentsForGivenTemplate(testDocumentTemplates[0].ID, testApplicationId));
        testResults.add(TB_PdfControllerLwc.generatePdfDocumentsForGivenTemplate(testDocumentTemplates[1].ID, testApplicationId));
        Test.stopTest();

        System.assertEquals(4, testResults.size(), 'there shuld be 4 test results');
        for(String testResult : testResults){
            System.assert(testResult.startsWith('068'), 'Result should be Content Version ID');
        }        
    }

    @isTest
    private static void testCreatePdfFile(){
        TB_Application_Document__c testContentVersion = [SELECT ID FROM TB_Application_Document__c LIMIT 1];
        String testResult = '';
        Test.startTest();
        testResult = TB_PdfControllerLwc.createPdfFile(String.valueOf(testContentVersion.Id));
        Test.stopTest();

        TB_Application_Document__c updatedDoc = [SELECT TB_Download_URL__c FROM TB_Application_Document__c WHERE Id = :testContentVersion.Id];
        System.assertNotEquals(null, updatedDoc.TB_Download_URL__c);
        System.assertEquals(updatedDoc.TB_Download_URL__c, testResult, 'Download URL expected');
    }

    private static void prepareData(){
        hed__Application__c application = TB_TestDataFactory.createApplicationWithRelatedObjects(true);

        TB_Document_Template__c testDocumentTemplate = new TB_Document_Template__c();
        Database.insert(testDocumentTemplate);

        TB_Document_Template__c testDocumentTemplate2 = new TB_Document_Template__c(TB_Output_Format__c = 'PDF');
        Database.insert(testDocumentTemplate2);
        
        ContentVersion testVersion = new ContentVersion(VersionData = Blob.valueof('test ${Application.Name} ${Application.Name} ${Applicant.LastName} test'), Title = 'test', PathOnClient = 'test.html');
        Database.insert(testVersion);

        ContentVersion testContentVersionWithContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion LIMIT 1];

        TB_Application_Document__c testApplicationDocument = new TB_Application_Document__c(
            TB_Application__c = application.Id,
            TB_Document_Template__c = testDocumentTemplate.Id,
            TB_Document_Type__c = 'Dynamic_Template',
            TB_Document_Name_EN__c = 'Doc'
        );
        Database.insert(testApplicationDocument);

        ContentDocumentLink testLink = new ContentDocumentLink(LinkedEntityId = testDocumentTemplate.Id, ContentDocumentId = testContentVersionWithContentDocumentId.ContentDocumentId);
        Database.insert(testLink);

        ContentVersion testVersion2 = new ContentVersion(VersionData = Blob.valueof('test ${Application.Name} ${Application.Name} ${Applicant.LastName} test'), Title = 'test2', PathOnClient = 'test.html');
        Database.insert(testVersion2);

        ContentVersion testContentVersionWithContentDocumentId2 = [SELECT ContentDocumentId FROM ContentVersion LIMIT 1];

        TB_Application_Document__c testApplicationDocument2 = new TB_Application_Document__c(
            TB_Application__c = application.Id,
            TB_Document_Template__c = testDocumentTemplate2.Id,
            TB_Document_Type__c = 'Dynamic_Template',
            TB_Document_Name_EN__c = 'Doc'
        );
        Database.insert(testApplicationDocument2);

        ContentDocumentLink testLink2 = new ContentDocumentLink(LinkedEntityId = testDocumentTemplate2.Id, ContentDocumentId = testContentVersionWithContentDocumentId2.ContentDocumentId);
        Database.insert(testLink2);
    }
}