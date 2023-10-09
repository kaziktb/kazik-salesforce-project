
@IsTest
private class TB_CT_FileUploadTest {
    private static final String USER_LAST_NAME = 'CaseTest';
    private static final String CASE_SUBJECT_CONTRACT = 'Contract';
    private static final String TEST_FILE_CONTENT = 'dGVzdA==';
    private static final String TEST_FILE_NAME = 'Test_Name';

    @TestSetup
    private static void setupMethod() {
        Contact contact = new Contact(LastName = USER_LAST_NAME);
        insert contact;
        Case c = new Case(ContactId = contact.Id);
        c.Subject = CASE_SUBJECT_CONTRACT;
        insert c;
    }

    @IsTest
    private static void uploadChunkedFileTest() {
        Case c = [SELECT Id FROM Case];
        ContentVersion version = TB_TestDataFactory.createContentVersion(false, CASE_SUBJECT_CONTRACT, CASE_SUBJECT_CONTRACT, TEST_FILE_CONTENT);
        insert version;

        Test.startTest();
        Id result = TB_CT_FileUpload.uploadChunkedFile(c.Id, TEST_FILE_NAME, TEST_FILE_CONTENT, version.Id,
                TB_Constants.CONTENT_VERSION_CATEGORY_CASE_ATTACHMENT);
        Test.stopTest();

        System.assertEquals(version.Id, result);
    }

    @IsTest
    private static void uploadChunkedFileWithoutVersionTest() {
        Case c = [SELECT Id FROM Case];

        Test.startTest();
        TB_CT_FileUpload.uploadChunkedFile(c.Id, TEST_FILE_NAME, TEST_FILE_CONTENT, null,
                TB_Constants.CONTENT_VERSION_CATEGORY_CASE_ATTACHMENT);
        Test.stopTest();

        System.assertEquals(1, [SELECT Id FROM ContentVersion].size());
    }
}