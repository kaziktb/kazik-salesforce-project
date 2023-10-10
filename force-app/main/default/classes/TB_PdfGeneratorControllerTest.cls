@isTest
private class TB_PdfGeneratorControllerTest {
    public static final String PARAM_DYNAMIC_TEMPLATE = 'Dynamic_Template';

    @TestSetup
    static void testSetup(){
        hed__Application__c application = TB_TestDataFactory.createApplicationWithRelatedObjects(true);

        TB_Document_Template__c testDocumentTemplate = TB_TestDataFactory.createDocumentTemplate(true);
        ID testDocumentTemplateId = testDocumentTemplate.Id;

        String versionData = 'test ${Application.Name} ${Application.Name} ${Applicant.LastName} test';
        TB_TestDataFactory.createContentVersion(true, 'test', 'test.html', versionData);

        ContentVersion testContentVersionWithContentDocument = [SELECT ContentDocumentId FROM ContentVersion LIMIT 1];

        TB_Application_Document__c testApplicationDocument = TB_TestDataFactory.createApplicationDocument(false, application.Id, PARAM_DYNAMIC_TEMPLATE);
        testApplicationDocument.TB_Document_Template__c = testDocumentTemplateId;
        Database.insert(testApplicationDocument);

        TB_TestDataFactory.createContentDocumentLink(true, testContentVersionWithContentDocument.ContentDocumentId, testDocumentTemplateId);
    }

    @isTest
    static void testGetHtmlValuePositive() {
        TB_PdfGeneratorController testController = new TB_PdfGeneratorController();
        TB_Application_Document__c testApplicationDocument = [SELECT ID, TB_Document_Template__c FROM TB_Application_Document__c LIMIT 1];
        hed__Application__c application = [SELECT Name, hed__Applicant__c FROM hed__Application__c LIMIT 1];
        Contact testContact = [SELECT LastName FROM Contact WHERE ID = :application.hed__Applicant__c LIMIT 1];
        ContentDocumentLink contentDocumentLink = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :testApplicationDocument.TB_Document_Template__c];

        Test.startTest();
        testController.currentRecordId = contentDocumentLink.ContentDocumentId;
        testController.applicationId = application.Id;
        String testResult = testController.getHtmlValue();
        Test.stopTest();

        System.assertEquals('test ' + application.Name + ' ' + application.Name + ' ' + testContact.LastName + ' test', testResult, 'results are not equal');
    }

    @isTest
    static void testGetHtmlValueException(){
        TB_PdfGeneratorController testController = new TB_PdfGeneratorController();
        TB_Application_Document__c testApplicationDocument = [SELECT TB_Document_Template__c FROM TB_Application_Document__c LIMIT 1];
        ID applicationId = [SELECT ID FROM hed__Application__c LIMIT 1].ID;
        ContentDocumentLink contentDocumentLink = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :testApplicationDocument.TB_Document_Template__c];


        testController.currentRecordId = contentDocumentLink.ContentDocumentId;
        testController.applicationId = applicationId;
        breakData(contentDocumentLink.ContentDocumentId);

        Test.startTest();
        System.debug(testController.getHtmlValue());
        Test.stopTest();
        List<TB_Log__c> testException = [SELECT ID FROM TB_Log__c LIMIT 100];

        System.assertEquals(1, testException.size(), 'Exceptions should be handled by the method');
    }

    private static void breakData(ID idToBreak){
        Database.delete(idToBreak);
    }
}