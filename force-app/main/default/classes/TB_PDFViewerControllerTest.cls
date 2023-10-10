@isTest
private class TB_PDFViewerControllerTest {
    public static String higherEducationRecordTypeId = Schema.SObjectType.TB_Experience_History__c.getRecordTypeInfosByDeveloperName().get('TB_Higher_Education').getRecordTypeId();

    @TestSetup
    static void testSetup(){
        Contact contact = TB_TestDataFactory.createContact(true);
        hed__Application__c application = TB_TestDataFactory.createApplicationWithNestedLookup(
            true, contact.Id);
        TB_Application_Document__c applicationDocument = TB_TestDataFactory.createApplicationDocument(
            true, application.Id, 'Scan');

        TB_TestDataFactory.createContentVersion(
            true,
            'Title',
            'template.html',
            '${Application.Id}'
        );
        ContentDocument contentDocument = [SELECT Id FROM ContentDocument WHERE Id IN (SELECT ContentDocumentId FROM ContentVersion)];
        TB_TestDataFactory.createContentDocumentLink(true, contentDocument.Id, applicationDocument.Id);
    }

    @isTest
    private static void getRelatedFilesByRecordId(){
        Map<Id, TB_PDFViewerController.ViewerWrapper> values =
            TB_PDFViewerController.getRelatedFilesByRecordId([SELECT Id FROM hed__Application__c LIMIT 1 ].Id);

        System.assert(!values.isEmpty(),'Returned Map should not be empty');
    }
}