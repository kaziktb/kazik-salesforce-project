@IsTest
private class TB_ContentVersionTriggerHandlerTest {
    static final String DOCUMENT_CATEGORY = 'Main_Picture';
    static final String DOCUMENT_SHARE_TYPE = 'V';
    static final String DOCUMENT_VISIBILITY = 'AllUsers';
    static final String TEST_EXPRESSION = 'Test';
    static final String CASE_ATTACHMENT_CONTENT_VERSION_CATEGORY = 'Case_Attachment';

    @IsTest
    private static void testApplicationDocumentLink() {
        TB_Offered_Product__c offeredProduct = TB_TestDataFactory.createOfferedProduct(true);
        Contact contact = new Contact(
                LastName = 'Kowalski'
        );
        insert contact;

        hed__Application__c application = TB_TestDataFactory.createApplication(null, offeredProduct.Id, false);
        application.hed__Applicant__c = contact.Id;
        insert application;

        List<TB_Application_Document__c> applicationDocuments = new List<TB_Application_Document__c>{
                TB_TestDataFactory.createApplicationDocument(false, application.Id, 'Scan'),
                TB_TestDataFactory.createApplicationDocument(false, application.Id, 'Scan')
        };
        insert applicationDocuments;

        List<ContentVersion> contentVersions = new List<ContentVersion>();
        for (Integer i = 0; i < 3; i++) {
            contentVersions.add(TB_TestDataFactory.createContentVersion(false, 'asd.pdf', 'asd.pdf', EncodingUtil.base64Encode(Blob.toPdf('a'))));
        }
        contentVersions[0].TB_Application_Document__c = applicationDocuments[0].Id;
        contentVersions[1].TB_Application_Document__c = applicationDocuments[1].Id;

        Test.startTest();
        insert contentVersions;
        Test.stopTest();

        List<TB_Application_Document__c> updatedAppDocuments = [SELECT (SELECT Id FROM ContentDocumentLinks) FROM TB_Application_Document__c WHERE TB_Content_Version_Id__c != NULL];
        System.assertEquals(applicationDocuments.size(), updatedAppDocuments.size());
        for (TB_Application_Document__c updatedAppDocument: updatedAppDocuments) {
            System.assertEquals(1, updatedAppDocument.ContentDocumentLinks.size());
        }
    }

    @IsTest
    private static void testThesameAvatar() {
        Contact contact = new Contact(
                LastName = 'Kowalski'
        );
        insert contact;

        ContentVersion contentToInsert = TB_TestDataFactory.createContentVersion(false, 'asd.pdf', 'asd.pdf', EncodingUtil.base64Encode(Blob.toPdf('a')));
        contentToInsert.TB_Category__c = DOCUMENT_CATEGORY;
        insert contentToInsert;
        contentToInsert = [
            SELECT id, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :contentToInsert.Id
        ];
        ContentDocumentLink cl = new ContentDocumentLink();
        cl.ContentDocumentId = contentToInsert.ContentDocumentId;
        cl.LinkedEntityId = contact.Id;
        cl.ShareType = DOCUMENT_SHARE_TYPE;
        cl.Visibility = DOCUMENT_VISIBILITY;
        insert cl;

        Boolean testfailed = false;
        Test.startTest();
            try{
                ContentVersion contentToInsert1 = TB_TestDataFactory.createContentVersion(false, 'asd.pdf', 'asd.pdf', EncodingUtil.base64Encode(Blob.toPdf('a')));
                contentToInsert1.TB_Category__c = DOCUMENT_CATEGORY;
                insert contentToInsert;
                contentToInsert = [
                    SELECT id, ContentDocumentId
                    FROM ContentVersion
                    WHERE Id = :contentToInsert1.Id
                ];
                ContentDocumentLink cl1 = new ContentDocumentLink();
                cl1.ContentDocumentId = contentToInsert.ContentDocumentId;
                cl1.LinkedEntityId = contact.Id;
                cl1.ShareType = DOCUMENT_SHARE_TYPE;
                cl1.Visibility = DOCUMENT_VISIBILITY;
                insert cl;
            }catch(Exception ex){
                testfailed = true;
            }
        Test.stopTest();
            System.assert(testfailed, 'Trigger Should throw Exception');

    }

    @IsTest
    private static void shouldChangeContentVersionTitleWhenContentDocumentLinkIsInserted(){
        Contact contact = TB_TestDataFactory.createContact(true);
        Case operationCase = TB_TestDataFactory.createCases(1, TEST_EXPRESSION, contact.Id, true)[0];
        TB_Operation__c operation = TB_TestDataFactory.createOperation(contact.Id, operationCase.Id, TEST_EXPRESSION, true);
        ContentVersion contentToInsert = TB_TestDataFactory.createContentVersion(false, 'file.pdf', 'file.pdf', EncodingUtil.base64Encode(Blob.toPdf('a')));
        insert contentToInsert;

        Test.startTest();
            contentToInsert = [
                SELECT ContentDocumentId
                FROM ContentVersion
                WHERE Id = :contentToInsert.Id
            ];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = contentToInsert.ContentDocumentId;
            cdl.LinkedEntityId = operation.Id;
            cdl.ShareType = DOCUMENT_SHARE_TYPE;
            cdl.Visibility = DOCUMENT_VISIBILITY;
            insert cdl;
        Test.stopTest();
        
        Assert.isTrue([SELECT Id FROM ContentVersion WHERE Title LIKE '%file.pdf - testContact testContact' AND TB_Category__c =: CASE_ATTACHMENT_CONTENT_VERSION_CATEGORY].size() == 1);
    }
}