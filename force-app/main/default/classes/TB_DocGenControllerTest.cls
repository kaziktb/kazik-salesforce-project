/**
 * Created by Aneta on 29/05/2023.
 */

@IsTest
private class TB_DocGenControllerTest {
    @TestSetup
    static void testSetup() {
        Contact contact = TB_TestDataFactory.createContact(true);
        hed__Application__c application = TB_TestDataFactory.createApplicationWithNestedLookup(true, contact.Id);
        TB_TestDataFactory.createApplicationDocument(true, application.Id, 'Scan');
    }

    @IsTest
    static void generateDocumentPositiveResponse() {
        Test.setMock(HttpCalloutMock.class, new TB_DocGenControllerMock(200, 'RESPONSE_MESSAGE'));
        Test.startTest();
        String result = TB_DocGenController.generateDocument(JSON.serialize(prepareDocumentWrapperMap()));
        Test.stopTest();
        TB_DocGenController.DocResponseWrapper parseResult = (TB_DocGenController.DocResponseWrapper) JSON.deserialize(result, TB_DocGenController.DocResponseWrapper.class);
        System.assertEquals(true, parseResult.isCorrect);
        System.assertEquals(true, parseResult.contentDocumentId != null);
        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void generateDocumentNegativeResponse() {
        Test.setMock(HttpCalloutMock.class, new TB_DocGenControllerMock(500, 'RESPONSE_MESSAGE'));

        Test.startTest();
        String result = TB_DocGenController.generateDocument(JSON.serialize(prepareDocumentWrapperMap()));
        Test.stopTest();
        TB_DocGenController.DocResponseWrapper parseResult = (TB_DocGenController.DocResponseWrapper) JSON.deserialize(result, TB_DocGenController.DocResponseWrapper.class);
        System.assertEquals(false, parseResult.isCorrect);
        System.assertEquals('RESPONSE_MESSAGE', parseResult.message);
        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void getDocumentTemplates() {
        Test.startTest();
        List<TB_Document_Template__c> documentTemplates = TB_DocGenController.getDocumentTemplates('Dynamic_Templates');
        Test.stopTest();
        System.assertEquals(documentTemplates.size(), 0);
        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void generateDocumentNegative() {
        Test.startTest();
        String result = TB_DocGenController.generateDocument(JSON.serialize(null));
        Test.stopTest();
        TB_DocGenController.DocResponseWrapper parseResult = (TB_DocGenController.DocResponseWrapper) JSON.deserialize(result, TB_DocGenController.DocResponseWrapper.class);
        System.assertEquals(false, parseResult.isCorrect);
        System.assertEquals(1, [SELECT Id FROM TB_Log__c].size());
    }

    private static Map<String, Object> prepareDocumentWrapperMap() {
        Id applicationDocumentId = [SELECT Id FROM TB_Application_Document__c LIMIT 1].Id;
        Id applicationId = [SELECT Id FROM hed__Application__c LIMIT 1].Id;
        return new Map<String, Object> {
            TB_DocGenController.JSON_GEN_DOC_REQ_APP_DOCUMENT_ID_PHRASE => applicationDocumentId,
            TB_DocGenController.JSON_GEN_DOC_REQ_RECORD_ID_PHRASE => applicationId,
            TB_DocGenController.JSON_GEN_DOC_REQ_TEMPLATE_URL_PHRASE => 'templateId',
            TB_DocGenController.JSON_GEN_DOC_REQ_DOCUMENT_NAME_PHRASE => 'DocumentName',
            TB_DocGenController.JSON_GEN_DOC_REQ_EXPORT_FORMAT_PHRASE => 'docx',
            TB_DocGenController.JSON_GEN_DOC_REQ_RELATED_SOBJECTS_PHRASE => new List<String>{'hed__Applicant__c'}
        };
    }

}