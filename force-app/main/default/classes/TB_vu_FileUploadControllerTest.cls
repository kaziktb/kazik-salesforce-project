@isTest
private with sharing class TB_vu_FileUploadControllerTest {
    @TestSetup
    static void testSetup(){
        List<Account> accs = TB_TestDataFactory.createAccounts(1, TB_Constants.STUDENTS_ORGANIZATION_REC_TYPE_ID, true);

        ContentVersion content = TB_TestDataFactory.createContentVersion(
            false,
            'test content', 
            '/testPath', 
            'testVersion');
        
        content.TB_Category__c = TB_vu_FileUploadController.CONTENT_VERSION_SOR_CATEGORY;
        insert content;

        ContentDocumentLink contentDocumentLink = TB_TestDataFactory.createContentDocumentLink(
            true, 
            [SELECT ContentDocumentId FROM contentversion WHERE Id =: content.Id].ContentDocumentId, 
            accs[0].Id);
    }

    @isTest
    static void shouldReturnIdWithoutPassedContentVersionId(){
        Id recordId = [SELECT Id FROM Account WHERE TB_Email__c LIKE 'TBemail@email%'].Id;
        String result;
        
        Test.startTest();
        result = TB_vu_FileUploadController.uploadChunkedFile(recordId, 'test file name', 'test file content', '');
        Test.stopTest();


        System.assert(result.length() > 0, 'Returned string cannot be blank');
    }

    @isTest
    static void shouldReturnIdWithPassedContentVersionId(){
        Id recordId = [SELECT Id FROM Account WHERE TB_Email__c LIKE 'TBemail@email%'].Id;
        Id contentVersionId = [SELECT Id FROM ContentVersion WHERE Title LIKE 'test content'].Id;
        String result;
        
        Test.startTest();
        result = TB_vu_FileUploadController.uploadChunkedFile(recordId, 'test file name', 'test file content', contentVersionId);
        Test.stopTest();

        System.assert(result.length() > 0, 'Returned string cannot be blank');
    }

    @isTest
    static void shouldReturnRegulations(){
        Id recordId = [SELECT Id FROM Account WHERE TB_Email__c LIKE 'TBemail@email%'].Id;
        String result;
        
        Test.startTest();
        result = TB_vu_FileUploadController.getRegulationsFileByAccountId(recordId);
        Test.stopTest();

        System.assert(result.length() > 0, 'Returned string cannot be blank');
    }

    @isTest
    static void shouldDeleteFile(){
        Id recordId = [SELECT Id FROM Account WHERE TB_Email__c LIKE 'TBemail@email%'].Id;

        Test.startTest();
        TB_vu_FileUploadController.deleteFile(recordId);
        Test.stopTest();

        System.assert([SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId].size() == 0, 'Query should not return any record');
    }
}