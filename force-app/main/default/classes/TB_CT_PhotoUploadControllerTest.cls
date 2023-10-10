@isTest
private class TB_CT_PhotoUploadControllerTest {

    private static final String EMAIL_TEST = 'test@test.com';
    private static final String SEX = 'Female';
    private static final String TITLE_GRANDE = 'mgr. inz';
    private static final String TEST_ACC = 'Test Acc';
    private static final String TEST_ACC_NUMBER = 'ABC341242134OP';
    private static final String TEST_CONTACT = 'testContact';
    private static final String TEST_PHONE = '521345098';
    private static final String TEST_STRING_BASE64 = 'base64Data';
    private static final String TEST_STRING_BASE64_CONV = 'base64DatQ==';
    private static final String TEST_PL = 'PL';
    private static final String TEST_EN = 'EN';
    private static final String TEST_DOWOD = 'POLSKI_DOWOD_OSOBISTY';
    private static final String TEST_DOWOD_NUM = 'AX91233FRE';
    private static final String POLAND = 'PL';
    private static final String ENGLISH = 'English';
    
   @TestSetup
   static void makeData(){
      TB_Admissions_Content__c content = new TB_Admissions_Content__c(
            TB_Active__c = true,
            TB_Content_Type__c = 'Message',
            TB_Content_PL__c = 'Brak rekordów',
            TB_Content_EN__c = 'Lack of records',
            TB_Record_Code__c = 'List has no rows for assignment to SObject'
        );
        insert content;
   }

    @IsTest
    public static void saveTheChunkFileTest(){
        Contact cont = new Contact(
            LastName = TEST_CONTACT,
            FirstName = TEST_CONTACT, 
            Email = EMAIL_TEST,
            Birthdate = Date.today() - 365*19,
            hed__Gender__c = SEX,
            hed__AlternateEmail__c = EMAIL_TEST,
            TB_Title_Grade__c = TITLE_GRANDE,
            Phone = TEST_PHONE,
            DT_Document_Issuing_Country__c = TEST_PL,
            DT_Document_Type__c = TEST_DOWOD,
            DT_Document_Series_and_Number__c = TEST_DOWOD_NUM,
            TB_Citizenship__c = POLAND);
        insert cont; 
        Id fileId;
        Test.startTest();
        fileId = TB_CT_PhotoUploadController.saveTheChunkFile(cont.Id, 'fileName', TEST_STRING_BASE64, null);
        Test.stopTest();
        ContentVersion versionData = [
                SELECT Id, VersionData, ContentDocumentId
                FROM ContentVersion
                WHERE Id = :fileId
        ];
        String existingBody = EncodingUtil.base64Encode(versionData.VersionData);
        System.assertEquals(TEST_STRING_BASE64_CONV, existingBody, 'Both values should be appended');
    }

    @IsTest
    public static void saveTheChunkFileTestErrorCheck(){
        Id fileId;
        Test.startTest();
        Boolean checkError = false;
        try {
            fileId = TB_CT_PhotoUploadController.saveTheChunkFile(null, null, TEST_STRING_BASE64, null);
        } catch (Exception ex ) {
            checkError = true;
        }
        Test.stopTest();
        System.assert(checkError, 'Error should occur');
    }


    @IsTest
    public static void clearCurrentFileTestErrorCheck(){
        Id fileId;
        Test.startTest();
        Boolean checkError = false;
        try {
            TB_CT_PhotoUploadController.clearCurrentFile(null);
        } catch (Exception ex ) {
            checkError = true;
        }
        Test.stopTest();
        System.assert(checkError, 'Error should occur');
    }
    @isTest
    public static void clearCurrentFileTest(){
        Contact cont = new Contact(
            LastName = TEST_CONTACT,
            FirstName = TEST_CONTACT, 
            Email = EMAIL_TEST,
            Birthdate = Date.today() - 365*19,
            hed__Gender__c = SEX,
            hed__AlternateEmail__c = EMAIL_TEST,
            TB_Title_Grade__c = TITLE_GRANDE,
            Phone = TEST_PHONE,
            DT_Document_Issuing_Country__c = TEST_PL,
            DT_Document_Type__c = TEST_DOWOD,
            DT_Document_Series_and_Number__c = TEST_DOWOD_NUM,
            TB_Citizenship__c = POLAND);
        insert cont; 

        Id fileId = TB_CT_PhotoUploadController.saveTheChunkFile(cont.Id, 'fileName', TEST_STRING_BASE64, null);
        Test.startTest();
        TB_CT_PhotoUploadController.clearCurrentFile(cont.Id);
        Test.stopTest();
        List<ContentVersion> versionsData = [
                SELECT Id, VersionData, ContentDocumentId
                FROM ContentVersion
                WHERE Id = :fileId
        ];
        System.assert(versionsData.isEmpty(), 'Files should be deleted');
    }

    @isTest
    public static void downloadFileTest(){
        Contact cont = new Contact(
            LastName = TEST_CONTACT,
            FirstName = TEST_CONTACT, 
            Email = EMAIL_TEST,
            Birthdate = Date.today() - 365*19,
            hed__Gender__c = SEX,
            hed__AlternateEmail__c = EMAIL_TEST,
            TB_Title_Grade__c = TITLE_GRANDE,
            Phone = TEST_PHONE,
            DT_Document_Issuing_Country__c = TEST_PL,
            DT_Document_Type__c = TEST_DOWOD,
            DT_Document_Series_and_Number__c = TEST_DOWOD_NUM,
            TB_Citizenship__c = POLAND);
        insert cont;  
        Id fileId = TB_CT_PhotoUploadController.saveTheChunkFile(cont.Id, 'fileName', TEST_STRING_BASE64, null);
        String outputTest;
        Test.startTest();
        outputTest = TB_CT_PhotoUploadController.downloadFile(cont.Id);
        Test.stopTest();
        System.assert(outputTest != null, 'Encoded Data should be returned');
    }
}
