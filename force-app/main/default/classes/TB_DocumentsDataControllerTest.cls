@IsTest
private class TB_DocumentsDataControllerTest {
    public static final String PARAM_DOCUMENT_COLLECTION = 'Document_Collection';
    public static final String PARAM_PHOTO = 'Photo';
    public static final String PARAM_DYNAMIC_TEMPLATE = 'Dynamic_Template';
    public static final String PARAM_STATIC_TEMPLATE = 'Static_Template';
    public static final String PARAM_SCAN = 'Scan';
    public static final String PARAM_EMPTY = 'Empty';
    public static final String PARAM_VERIFIED = 'Verified';
    public static final String PARAM_AWAITING = 'Awaiting';
    public static final String PARAM_LANGUAGE_CERTIFICATE = 'Language_Certificate';
    public static final String PARAM_STUDY_AGREEMENT_PAPER = 'Study_Agreement_Paper';
    public static final String PARAM_DIPLOMA = 'Diploma';
    public static final String PARAM_TEST = 'test';
    public static final String PARAM_PHOTO_TEST = 'photoTest';
    public static final String PARAM_TEST_DELIVERED = 'testDelivered';
    public static final String PARAM_TEST_COMMENT = 'testComment';

    @TestSetup
    static void testSetup(){
        hed__Application__c application = TB_TestDataFactory.createApplicationWithRelatedObjects(true);
        ID applicationId = application.Id;
        TB_Admissions_Process__c admissionsProcess = [SELECT ID FROM TB_Admissions_Process__c LIMIT 1];
        admissionsProcess.TB_Step_Type__c = PARAM_DOCUMENT_COLLECTION;
        admissionsProcess.TB_Document_Categories__c = PARAM_LANGUAGE_CERTIFICATE;
        admissionsProcess.TB_Document_Types__c = PARAM_DYNAMIC_TEMPLATE;
        Database.update(admissionsProcess);

        TB_Document_Template__c documentTemplate = TB_TestDataFactory.createDocumentTemplate(true, 'Dynamic_Template', 'test dynamic template');

        TB_Document_Templates_Bundle__c documentTemplatesBundle = TB_TestDataFactory.createDocumentTemplatesBundle(true, 'Test Document Templates Bundle', true, 'Higher_Education', true);
        TB_TestDataFactory.createDocumentTemplatesBundleItem(true, documentTemplate.ID, documentTemplatesBundle.ID);

        TB_TestDataFactory.createContentVersion(true, PARAM_TEST, PARAM_TEST, PARAM_TEST);
        ContentVersion testContentVersionWithContentDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE title = :PARAM_TEST LIMIT 1];

        TB_TestDataFactory.createContentDocumentLink(true, testContentVersionWithContentDocument.ContentDocumentId, documentTemplate.Id);
 
        TB_Application_Document__c applicationDocument = TB_TestDataFactory.createApplicationDocument(false, null, applicationId, PARAM_DYNAMIC_TEMPLATE, true, PARAM_LANGUAGE_CERTIFICATE, PARAM_VERIFIED);
        applicationDocument.TB_Document_Template__c = documentTemplate.Id;
        applicationDocument.TB_Comment__c = PARAM_TEST_COMMENT;
        applicationDocument.TB_Internal__c = False;
        applicationDocument.TB_Anonymisation_Status__c = PARAM_AWAITING;
        applicationDocument.TB_Experience__c = null;
        Database.insert(applicationDocument);

        TB_TestDataFactory.createContentVersion(true, PARAM_PHOTO_TEST, PARAM_PHOTO_TEST, PARAM_PHOTO_TEST);
        ContentVersion testPhotoContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE title = :PARAM_PHOTO_TEST LIMIT 1];

        TB_Application_Document__c photoApplicationDocument = TB_TestDataFactory.createApplicationDocument(true, PARAM_PHOTO_TEST, applicationId, PARAM_STATIC_TEMPLATE, true, PARAM_PHOTO, PARAM_EMPTY);
        
        TB_TestDataFactory.createContentDocumentLink(true, testPhotoContentVersion.ContentDocumentId, photoApplicationDocument.Id);

        TB_TestDataFactory.createContentVersion(true, PARAM_TEST_DELIVERED, PARAM_TEST_DELIVERED, PARAM_TEST_DELIVERED);
        TB_TestDataFactory.createContentVersion(true, PARAM_TEST_DELIVERED + '2', PARAM_TEST_DELIVERED + '2', PARAM_TEST_DELIVERED + '2');

        TB_Application_Document__c deliveredApplicationDocument = TB_TestDataFactory.createApplicationDocument(true, 'deliveredApplicationDocument', applicationId, PARAM_SCAN, true, PARAM_STUDY_AGREEMENT_PAPER, null);        

        ContentVersion testDeliveredContentVersionDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE title = :PARAM_TEST_DELIVERED LIMIT 1];
        TB_TestDataFactory.createContentDocumentLink(true, testDeliveredContentVersionDocument.ContentDocumentId, deliveredApplicationDocument.Id);

        ContentVersion testDeliveredContentVersionDocument2 = [SELECT ContentDocumentId FROM ContentVersion WHERE title = 'testDelivered2' LIMIT 1];
        TB_TestDataFactory.createContentDocumentLink(true, testDeliveredContentVersionDocument2.ContentDocumentId, deliveredApplicationDocument.Id);

        deliveredApplicationDocument.TB_Status__c = PARAM_VERIFIED;
        Database.update(deliveredApplicationDocument);


        TB_TestDataFactory.createContentVersion(true, PARAM_TEST_DELIVERED + '3', PARAM_TEST_DELIVERED + '3', PARAM_TEST_DELIVERED + '3');
        TB_TestDataFactory.createContentVersion(true, 'testDelivered4', 'testDelivered4', 'testDelivered4');

        TB_Application_Document__c deliveredApplicationDocument2 = TB_TestDataFactory.createApplicationDocument(true, 'deliveredApplicationDocument2', applicationId, PARAM_SCAN, true, PARAM_DIPLOMA, null);        

        ContentVersion testDeliveredContentVersionDocument3 = [SELECT ContentDocumentId FROM ContentVersion WHERE title = 'testDelivered3' LIMIT 1];
        TB_TestDataFactory.createContentDocumentLink(true, testDeliveredContentVersionDocument3.ContentDocumentId, deliveredApplicationDocument2.Id);

        ContentVersion testDeliveredContentVersionDocument4 = [SELECT ContentDocumentId FROM ContentVersion WHERE title = 'testDelivered4' LIMIT 1];
        TB_TestDataFactory.createContentDocumentLink(true, testDeliveredContentVersionDocument4.ContentDocumentId, deliveredApplicationDocument2.Id);

        deliveredApplicationDocument2.TB_Status__c = PARAM_VERIFIED;
        Database.update(deliveredApplicationDocument2);
    }

    @IsTest
    private static void testGetDocumentTemplatesPositive(){
        Test.startTest();
        List<TB_Document_Template_Bundle_Item__c> testResult = TB_DocumentsDataController.getDocumentTemplateBundleItems();
        Test.stopTest();

        System.assert(testResult != null, 'result should not be null');
        System.assert(testResult.size() == 1, 'result size should be 1');
        System.assertEquals('test dynamic template', testResult[0].TB_Document_Template_Name__c, 'name should be: test dynamic template');
    }

    @IsTest
    private static void testGetDocumentTemplatesNegative(){
        ID documentTemplatesBundleToRemoveId = [SELECT ID FROM TB_Document_Templates_Bundle__c WHERE TB_On_Demand_Documents__c = true AND TB_Product_Group__c = 'Higher_Education' AND TB_Active__c = true AND IsDeleted = false LIMIT 1].ID;
        List<TB_Document_Template_Bundle_Item__c> documentTemplatesBundleItemToRemove = [SELECT ID FROM TB_Document_Template_Bundle_Item__c WHERE TB_Document_Templates_Bundle__c = :documentTemplatesBundleToRemoveId];
        Database.delete(documentTemplatesBundleItemToRemove);
        Database.delete(documentTemplatesBundleToRemoveId);
        
        Test.startTest();
        List<TB_Document_Template_Bundle_Item__c> testResult = TB_DocumentsDataController.getDocumentTemplateBundleItems();
        Test.stopTest();

        System.assert(testResult == null, 'result should be null');
    }

    @IsTest
    private static void testGetDeliveredDocuments(){
        ID applicationId = [
            SELECT Id
            FROM hed__Application__c
            LIMIT 1
        ].Id;

        Test.startTest();
        String testResult = TB_DocumentsDataController.getDeliveredDocuments(applicationId);
        Test.stopTest();

        System.assert(testResult != null, 'result should not be null');
        System.assert(testResult != '', 'result should not be empty');
        System.assert(testResult.length() == 18, 'result should be ID');
    }

    @IsTest
    private static void testGetNewestApplicantPhoto(){
        ID applicantId = [
            SELECT Id
            FROM Contact
            LIMIT 1
        ].Id;


        Test.startTest();
        Id testResult = TB_DocumentsDataController.getNewestApplicantPhoto(applicantId);
        Test.stopTest();

        System.assert(testResult != null, 'result should be false');
    }

    @IsTest
    private static void testGetApplicantPhoto(){
        ID applicationId = [
            SELECT Id
            FROM hed__Application__c
            LIMIT 1
        ].Id;


        Test.startTest();
        Id testResult = TB_DocumentsDataController.getApplicantPhoto(applicationId);
        Test.stopTest();

        System.assert(testResult != null, 'result should be false');
    }

    @IsTest
    private static void testGetNonGeneratedDocumentPositive(){
        ID applicationDocumentId = [
            SELECT Id
            FROM TB_Application_Document__c
            WHERE TB_Document_Category__c = :PARAM_LANGUAGE_CERTIFICATE
            LIMIT 1
        ].Id;

        Test.startTest();
        String testResult = TB_DocumentsDataController.getNonGeneratedDocument(applicationDocumentId);
        Test.stopTest();

        System.assert(testResult.length() == 18, 'result is not ID');
    }

    @IsTest
    private static void testGetNonGeneratedDocumentNegative(){
        ID applicationDocumentId = [
            SELECT Id
            FROM TB_Application_Document__c
            WHERE TB_Document_Category__c = :PARAM_LANGUAGE_CERTIFICATE
            LIMIT 1
        ].Id;

        breakApplicationDocumentData(applicationDocumentId);

        Test.startTest();
        String testResult = TB_DocumentsDataController.getNonGeneratedDocument(applicationDocumentId);
        Test.stopTest();

        System.assert(testResult == null, 'exception was not thrown');
    }


    @IsTest
    private static void testGetDocumentsToDownloadPositive(){
        ID applicationId = [SELECT ID FROM hed__Application__c LIMIT 1].ID;
        TB_Admissions_Process__c step = [SELECT ID, TB_Step_Type__c, TB_Document_Categories__c, TB_Document_Types__c FROM TB_Admissions_Process__c LIMIT 1];

        Test.startTest();
        String testResult = TB_DocumentsDataController.getDocumentsToDownload(applicationId, JSON.serialize(step));
        Test.stopTest();

        List<TB_FileUtils.FileWrapper> customObject = (List<TB_FileUtils.FileWrapper>)JSON.deserialize(testResult, List<TB_FileUtils.FileWrapper>.class);
        System.assertEquals(1, customObject.size());
        System.assertEquals(PARAM_TEST_COMMENT, customObject[0].file.TB_Comment__c);
    }

    @IsTest
    private static void testGetDocumentsToDownloadNegative(){
        ID applicationId = [SELECT ID FROM hed__Application__c LIMIT 1].ID;
        ID stepId = [SELECT ID FROM TB_Admissions_Process__c LIMIT 1].ID;
        breakWrapperData(stepId);

        Test.startTest();
        String testResult = TB_DocumentsDataController.getDocumentsToDownload(applicationId, stepId);
        Test.stopTest();

        List<TB_Log__c> testException = [SELECT ID FROM TB_Log__c LIMIT 100];
        System.assertEquals(1, testException.size(), 'Exceptions should be handled by the method');
        System.assertEquals(testResult, null);
    }


    @IsTest
    private static void testGetApplicationDocumentTypePositive(){
        ID documentId = [SELECT ID FROM TB_Application_Document__c WHERE TB_Document_Category__c = :PARAM_LANGUAGE_CERTIFICATE LIMIT 1].ID;

        Test.startTest();
        String testResult = TB_DocumentsDataController.GetApplicationDocumentType(documentId);
        Test.stopTest();

        
        System.assertEquals(PARAM_DYNAMIC_TEMPLATE, testResult, 'result should be dynamic template');
    }

    private static void breakApplicationDocumentData(ID applicationDocumentId){
        TB_Application_Document__c applicationDocument = [
            SELECT Id
            FROM TB_Application_Document__c
            WHERE Id = :applicationDocumentId
            LIMIT 1
        ];

        Database.delete(applicationDocument);
    }

    private static void breakWrapperData(ID stepId){
        TB_JSON_Wrapper__c jsonWrapper = [SELECT TB_Wrapper_Value__c FROM TB_JSON_Wrapper__c WHERE TB_Object_Id__c = :stepId LIMIT 1];
        jsonWrapper.TB_Wrapper_Value__c = 'wrongValue';
        Database.update(jsonWrapper);
    }
}