@IsTest
private class TB_DocumentVerificationControllerTest {
    private static final Integer NUMBER_OF_RECORDS = 10;
    private static final String CONTACT_LAST_NAME = 'Kowalski';
    private static final String CONTACT_CITIZENSHIP = 'Angola';
    private static final String STUDIES_NAME = 'Test Studies';
    private static final String LANGUAGE_OF_STUDY = 'English';
    private static final String TEST_TITLE = 'test';
    private static final String TEST_PATH = 'test.html';

    @TestSetup
    private static void setupMethod() {
        Contact contact = TB_TestDataFactory.createContact(false);
        contact.LastName = CONTACT_LAST_NAME;
        contact.hed__Citizenship__c = CONTACT_CITIZENSHIP;
        insert contact;

        TB_Offered_Product__c studies = new TB_Offered_Product__c(
                Name = STUDIES_NAME,
                TB_Language_of_Study__c = LANGUAGE_OF_STUDY
        );
        insert studies;

        hed__Application__c application = new hed__Application__c(
                TB_Applying_To_Offered_Product__c = studies.Id,
                TB_Active__c = true,
                hed__Applicant__c = contact.Id
        );
        insert application;

        List<TB_Application_Document__c> documents = new List<TB_Application_Document__c>();
        TB_TestDataFactory.createApplicationDocument(false, application.Id, TB_Constants.TB_APP_DOCUMENT_TYPE_SCAN);
        for (Integer i = 0; i < NUMBER_OF_RECORDS; i++) {
            TB_Application_Document__c document = TB_TestDataFactory.createApplicationDocument(false, application.Id, TB_Constants.TB_APP_DOCUMENT_TYPE_SCAN);
            document.TB_Status__c = TB_Constants.TB_APP_DOCUMENT_STATUS_TO_VERIFY;
            documents.add(document);
        }
        insert documents;

        List<ContentVersion> versions = new List<ContentVersion>();
        for (Integer i = 0; i < NUMBER_OF_RECORDS; i++) {
            ContentVersion version = TB_TestDataFactory.createContentVersion(false, TEST_TITLE, TEST_PATH, TEST_TITLE);
            version.TB_Application_Document__c = documents[i].Id;
            versions.add(version);
        }
        insert versions;

        Id recordTypeId = Schema.TB_Admissions_Dictionary__c.SObjectType.getDescribe().recordTypeInfosByDeveloperName.get(TB_Constants.ADMISSIONS_DICTIONARY_RT_COMMENT_DEVNAME).recordTypeId;
        List<TB_Admissions_Dictionary__c> comments = new List<TB_Admissions_Dictionary__c>();
        for (Integer i = 0; i < NUMBER_OF_RECORDS; i++) {
            comments.add(new TB_Admissions_Dictionary__c(
                    RecordTypeId = recordTypeId,
                    TB_Product_Group__c = TB_Constants.TB_ADMISSIONS_CONTENT_PRODUCT_GROUP_HIGHER_EDUCATION,
                    TB_Active__c = true));
        }
        insert comments;
    }

    @IsTest
    private static void fetchApplicationDocumentsTest() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];

        Test.startTest();
        TB_DocumentVerificationController.ApplicationDocumentWrapper documentWrapper = TB_DocumentVerificationController.fetchApplicationDocuments(application.Id);
        Test.stopTest();

        System.assertEquals(NUMBER_OF_RECORDS, documentWrapper.documentIdToApplicationDocument.keySet().size());
        for (TB_Application_Document__c document : documentWrapper.documentIdToApplicationDocument.values()) {
            System.assertEquals(TB_Constants.TB_APP_DOCUMENT_STATUS_TO_VERIFY, document.TB_Status__c);
        }
        System.assertEquals(NUMBER_OF_RECORDS, documentWrapper.idToFileExtension.values().size());
        System.assertEquals(NUMBER_OF_RECORDS, documentWrapper.idToContentVersion.values().size());
    }

    @IsTest
    private static void fetchDocumentCommentsTest() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        application.TB_Product_Group__c = TB_Constants.TB_ADMISSIONS_CONTENT_PRODUCT_GROUP_HIGHER_EDUCATION;
        update application;

        Test.startTest();
        Map<Id, TB_Admissions_Dictionary__c> idToComment = TB_DocumentVerificationController.fetchDocumentComments(application.Id);
        Test.stopTest();

        System.assertEquals(NUMBER_OF_RECORDS, idToComment.keySet().size());
    }

    @IsTest
    private static void updateDocumentStatusTest() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        List<TB_Application_Document__c> documents = [SELECT Id, TB_Status__c FROM TB_Application_Document__c WHERE TB_Application__c = :application.Id];
        List<Id> documentIds = new List<Id>();
        for (TB_Application_Document__c document : documents) {
            documentIds.add(document.Id);
        }
        Test.startTest();
        TB_DocumentVerificationController.updateDocumentStatus(documentIds, TB_Constants.TB_APP_DOCUMENT_STATUS_VERIFIED);
        Test.stopTest();

        List<TB_Application_Document__c> updatedDocuments = [SELECT Id, TB_Status__c FROM TB_Application_Document__c WHERE TB_Application__c = :application.Id];

        for (TB_Application_Document__c document : updatedDocuments) {
            System.assertEquals(TB_Constants.TB_APP_DOCUMENT_STATUS_VERIFIED, document.TB_Status__c);
        }
    }

    @IsTest
    private static void updateDocumentsTest() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        List<TB_Application_Document__c> documents = [SELECT Id, TB_Status__c FROM TB_Application_Document__c WHERE TB_Application__c = :application.Id];
        for (TB_Application_Document__c document : documents) {
            document.TB_Status__c = TB_Constants.TB_APP_DOCUMENT_STATUS_EMPTY;
        }

        Test.startTest();
        TB_DocumentVerificationController.updateDocuments(documents);
        Test.stopTest();

        List<TB_Application_Document__c> updatedDocuments = [SELECT Id, TB_Status__c FROM TB_Application_Document__c WHERE TB_Application__c = :application.Id];
        for (TB_Application_Document__c document : updatedDocuments) {
            System.assertEquals(document.TB_Status__c, TB_Constants.TB_APP_DOCUMENT_STATUS_EMPTY);
        }
    }
}