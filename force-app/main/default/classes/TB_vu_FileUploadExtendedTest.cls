@IsTest
private class TB_vu_FileUploadExtendedTest {
    private static final String USER_LAST_NAME = 'CaseTest';
    private static final String CASE_SUBJECT_CONTRACT = 'Contract';
    private static final String TEST_FILE_CONTENT = 'dGVzdA==';
    private static final String TEST_FILE_NAME = 'Test_Name';
    private static final String EXPRESSION_TEST = 'Test';

    @TestSetup
    static void setupMethod() {
        User user = TB_TestDataFactory.createUser(TB_TestDataFactory.SYSTEM_ADMINISTRATOR, false);
        user.Email = 'user@usertest.com';
        insert user;

        Contact contact = new Contact(LastName = USER_LAST_NAME, TB_User__c = user.Id);
        insert contact;
        
        insert new Case(ContactId = contact.Id, Subject = CASE_SUBJECT_CONTRACT);
    }

    @isTest
    static void throwAnError_whenInvalidIdIsPassedToGetFileWrappers(){
        List<TB_vu_FileUploadExtended.FileWrapper> result = new List<TB_vu_FileUploadExtended.FileWrapper>();
        Boolean isException;

        Test.startTest();
        try {
            result = TB_vu_FileUploadExtended.getFileWrappers(new List<Id>{'INVALID_ID'}); 
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        Assert.isTrue(isException);
    }

    @isTest
    static void shouldReturnFileWrapper(){
        ContentVersion version = TB_TestDataFactory.createContentVersion(true, CASE_SUBJECT_CONTRACT, CASE_SUBJECT_CONTRACT, TEST_FILE_CONTENT);
        List<TB_vu_FileUploadExtended.FileWrapper> result = new List<TB_vu_FileUploadExtended.FileWrapper>();

        Test.startTest();
        result = TB_vu_FileUploadExtended.getFileWrappers(new List<Id>{version.Id}); 
        Test.stopTest();

        Assert.areEqual(result.size(), 1);
        Assert.areEqual(result[0].Title, CASE_SUBJECT_CONTRACT);
    }

    @IsTest
    static void shouldUpdateContentVersionOnCase() {
        Case c = [SELECT Id FROM Case];
        User user = [SELECT Id, Name FROM User WHERE Email LIKE 'user@usertest.com' LIMIT 1];
        ContentVersion version = TB_TestDataFactory.createContentVersion(false, EXPRESSION_TEST, EXPRESSION_TEST, EXPRESSION_TEST);
        insert version;
        System.runAs(user) {
            Test.startTest();
            TB_vu_FileUploadExtended.updateContentVersions(
                new List<Id>{version.Id},
                new List<Id>{c.Id});
            Test.stopTest();
        }


        ContentVersion newVersion = [SELECT TB_Category__c, ContentDocumentId FROM ContentVersion];
        List<ContentDocumentLink> links = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :c.Id];

        System.assertEquals(newVersion.ContentDocumentId, links[0].ContentDocumentId);
        System.assertEquals(c.Id, links[0].LinkedEntityId);
    }

    @IsTest
    static void throwAnError_whenInvalidParametersPassedToUpdateContentVersions() {
        Boolean isException = false;
        ContentVersion version = TB_TestDataFactory.createContentVersion(false, EXPRESSION_TEST, EXPRESSION_TEST, EXPRESSION_TEST);
        insert version;
        User user = [SELECT Id, Name FROM User WHERE Email LIKE 'user@usertest.com' LIMIT 1];
        System.runAs(user) {
            Test.startTest();
            try {
                TB_vu_FileUploadExtended.updateContentVersions(
                    new List<Id>{version.Id}, 
                    new List<Id>{'INVALID'});
            } catch (Exception e) {
                isException = true;
            }
            Test.stopTest();
        }

        System.assert(isException);
    }

    @IsTest
    static void shouldDeleteContentDocuments() {
        ContentVersion version = TB_TestDataFactory.createContentVersion(false, EXPRESSION_TEST, EXPRESSION_TEST, EXPRESSION_TEST);
        insert version;

        Test.startTest();
        TB_vu_FileUploadExtended.deleteContentDocuments(new List<Id> {version.Id});
        Test.stopTest();

        System.assertEquals(0, [SELECT Id FROM ContentDocument].size());
    }
}