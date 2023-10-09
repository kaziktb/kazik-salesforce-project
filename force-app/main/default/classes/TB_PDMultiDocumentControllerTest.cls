/**
 * Created by Aneta on 22/02/2022.
 */

@IsTest
private class TB_PDMultiDocumentControllerTest {
    @TestSetup
    static void testSetup() {
        TB_Offered_Product__c product = TB_TestDataFactory.createOfferedProduct(false);
        insert product;

        Contact contact = new Contact(
            LastName = 'Kowalski'
        );
        insert contact;

        hed__Application__c application = TB_TestDataFactory.createApplication(null, product.Id,false);
        application.hed__Applicant__c = contact.Id;
        application.TB_Product_Group__c = 'Higher_Education';
        insert application;

        TB_Application_Document__c document = TB_TestDataFactory.createApplicationDocument(false, application.Id, TB_Constants.TB_APP_DOCUMENT_TYPE_SCAN);
        document.TB_Document_Category__c = TB_Constants.TB_PD_DOCUMENT_CATEGORIES[0];
        insert document;
    }

    @IsTest
    static void testGetPDApplicationDocumentsPositive() {
        String applicationId = [SELECT Id, hed__Applicant__c FROM hed__Application__c LIMIT 1].Id;
        Test.startTest();
        String result  = TB_PDMultiDocumentController.getPDApplicationDocuments(applicationId);
        List<TB_FileUtils.FileWrapper> wrappers = (List<TB_FileUtils.FileWrapper>)
            JSON.deserialize(result, List<TB_FileUtils.FileWrapper>.class);
        Test.stopTest();

        System.assertEquals(1, wrappers.size());
        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());

    }

    @IsTest
    static void testGetNewPDApplicationDocument() {
        String documentId = [SELECT Id FROM TB_Application_Document__c LIMIT 1].Id;
        Test.startTest();
        String result = TB_PDMultiDocumentController.getNewPDApplicationDocument(documentId);
        Test.stopTest();

        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
        System.assertEquals(true, result != null);
    }

    @IsTest
    static void testDeleteApplicationDocument() {
        String documentId = [SELECT Id FROM TB_Application_Document__c LIMIT 1].Id;
        Test.startTest();
        String result = TB_PDMultiDocumentController.deleteApplicationDocument(documentId);
        Test.stopTest();

        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
        System.assertEquals(0, [SELECT Id FROM TB_Application_Document__c].size());
        System.assertEquals('SUCCESS', result);
    }

    @IsTest
    static void testDeleteApplicationDocumentEmpty() {
        Test.startTest();
        String result = TB_PDMultiDocumentController.deleteApplicationDocument(null);
        Test.stopTest();

        System.assertEquals('EMPTY_APP_DOCUMENT_ID', result);
        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void testCreateNewApplicationDocumentSlotNegative() {

        Test.startTest();
        TB_PDMultiDocumentController.createNewApplicationDocumentSlot(null, null, null, null, null, null);
        Test.stopTest();

        System.assertEquals(1, [SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void testCreateNewApplicationDocumentSlotPositive() {

        hed__Application__c application = [SELECT Id, hed__Applicant__c FROM hed__Application__c LIMIT 1];
        Test.startTest();
        TB_PDMultiDocumentController.createNewApplicationDocumentSlot(application.Id, application.hed__Applicant__c, TB_Constants.TB_PD_DOCUMENT_CATEGORIES[0], 'Test', null, null);
        Test.stopTest();

        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void testGetDocumentsCategory() {
        Test.startTest();
        TB_PDMultiDocumentController.getDocumentsCategory();
        Test.stopTest();
    }

}