/**
 * Created by Aneta on 08/12/2021.
 */

@IsTest
private class TB_FileUtilsTest {

    public static String higherEducationRecordTypeId = Schema.SObjectType.TB_Experience_History__c.getRecordTypeInfosByDeveloperName().get('TB_Higher_Education').getRecordTypeId();

    @TestSetup
    static void testSetup() {

        TB_Admissions_Campaign__c campaign = new TB_Admissions_Campaign__c(
            TB_Active__c = true,
            TB_Status__c = 'Launched'
        );
        insert campaign;

        String processRecordType = Schema.SObjectType.TB_Admissions_Process__c.getRecordTypeInfosByDeveloperName().get('TB_Admissions_Process').getRecordTypeId();
        TB_Admissions_Process__c process = new TB_Admissions_Process__c(
            RecordTypeId = processRecordType,
            Name = 'Process'
        );
        insert process;

        TB_Offered_Product__c product = TB_TestDataFactory.createOfferedProduct(false);
        product.Name = 'Wrapper_Product';
        product.TB_Product_Group__c = 'Higher_Education';
        product.TB_Status__c = 'Launched';
        product.TB_Active__c = true;
        product.TB_Admissions_Campaign__c = campaign.Id;
        product.TB_Product_Start_Date__c = System.now();
        product.TB_Product_End_Date__c = System.now().addDays(10);
        product.TB_Test__c = true;
        product.TB_Admissions_Process__c = process.Id;
        insert product;


        Contact contact = new Contact(
            FirstName = 'Jan',
            LastName = 'Kowalski',
            Email = 'test@test.test'
        );
        insert contact;

        hed__Application__c application = new hed__Application__c();
        application.TB_Applying_To_Offered_Product__c = product.Id;
        application.hed__Applicant__c = contact.Id;
        application.TB_Test__c = false;
        insert application;

        TB_Experience_History__c experienceHistory = new TB_Experience_History__c(
            TB_Application__c = application.Id,
            TB_Applicant__c = contact.Id,
            RecordTypeId = higherEducationRecordTypeId,
            TB_Not_Diploma__c = false,
            TB_Educational_Institution_Country__c = 'PL',
            TB_Active__c = true
        );
        insert experienceHistory;

        TB_Application_Document__c applicationDocument = new TB_Application_Document__c(
            TB_Experience__c = experienceHistory.Id,
            TB_Active__c = true,
            TB_Application__c = application.Id,
            TB_Document_Type__c = 'Scan',
            TB_Status__c = 'Rejected',
            TB_Comment__c = 'Test Comment'
        );
        insert applicationDocument;

        TB_Application_Document__c applicationDocumentEmpty = new TB_Application_Document__c(
            TB_Experience__c = experienceHistory.Id,
            TB_Active__c = true,
            TB_Application__c = application.Id,
            TB_Document_Type__c = 'Scan',
            TB_Status__c = 'Empty'
        );
        insert applicationDocumentEmpty;

        TB_Application_Document__c applicationDocumentToVerify = new TB_Application_Document__c(
            TB_Experience__c = experienceHistory.Id,
            TB_Active__c = true,
            TB_Application__c = application.Id,
            TB_Document_Type__c = 'Scan',
            TB_Status__c = 'To_Verify',
            TB_Comment__c = 'Test Comment'
        );
        insert applicationDocumentToVerify;

        TB_Application_Document__c applicationDocumentVerified = new TB_Application_Document__c(
            TB_Experience__c = experienceHistory.Id,
            TB_Active__c = true,
            TB_Application__c = application.Id,
            TB_Document_Type__c = 'Scan',
            TB_Status__c = 'Verified'
        );
        insert applicationDocumentVerified;

        TB_Application_Document__c applicationDocumentToCorrect = new TB_Application_Document__c(
            TB_Experience__c = experienceHistory.Id,
            TB_Active__c = true,
            TB_Application__c = application.Id,
            TB_Document_Type__c = 'Scan',
            TB_Status__c = 'To_Correct',
            TB_Comment__c = 'Test Comment'
        );
        insert applicationDocumentToCorrect;

    }

    @IsTest
    private static void getApplicationDocuments() {
        TB_Experience_History__c experience = [SELECT Id FROM TB_Experience_History__c LIMIT 1];
        List<Id> experienceIds = new List<Id>();
        experienceIds.add(experience.Id);

        Test.startTest();
        TB_FileUtils.getApplicationDocuments(experienceIds,'TB_Experience__c');
        Test.stopTest();
    }

    @IsTest
    private static void createFileWrapperForDocuments() {
        List<TB_Application_Document__c> applicationDocuments = [SELECT Id, TB_Active__c, TB_Status__c, TB_Comment__c FROM TB_Application_Document__c];
        Test.startTest();
        TB_FileUtils.createFileWrapperForDocuments(applicationDocuments);
        Test.stopTest();
    }

    @IsTest
    private static void createFileWrapperForDocumentSingle() {
        TB_Application_Document__c applicationDocument = [SELECT Id, TB_Active__c, TB_Status__c, TB_Comment__c FROM TB_Application_Document__c LIMIT 1];
        Test.startTest();
        TB_FileUtils.createFileWrapperForDocument(applicationDocument);
        Test.stopTest();
    }

    @IsTest
    private static void getNewUploadedFileWrapper() {
        TB_Application_Document__c applicationDocument = [SELECT Id, TB_Active__c, TB_Status__c, TB_Comment__c FROM TB_Application_Document__c LIMIT 1];
        Test.startTest();
        TB_FileUtils.getNewUploadedFileWrapper(applicationDocument.Id);
        Test.stopTest();
    }

    @IsTest
    private static void deleteApplicationDocument() {
        TB_Application_Document__c applicationDocument = [SELECT Id, TB_Active__c, TB_Status__c, TB_Comment__c FROM TB_Application_Document__c LIMIT 1];
        Test.startTest();
        TB_FileUtils.deleteApplicationDocument(applicationDocument.Id);
        Test.stopTest();
    }

    @IsTest
    private static void prepareApplicationDocumentSlot() {
        TB_Experience_History__c experienceHistory = [SELECT Id, TB_Applicant__c, TB_Application__c FROM TB_Experience_History__c LIMIT 1];
        Test.startTest();
        TB_FileUtils.prepareApplicationDocumentSlot(experienceHistory, 'Language_Certificate', null, null);
        Test.stopTest();
    }
}