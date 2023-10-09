@IsTest
private class TB_GetDeliveredDocumentsZipArchiveTest {
    @testSetup
    static void setup() {
        ContentVersion testContentVersion = TB_TestDataFactory.createContentVersion(false, TB_Constants.TB_TEST_LABEL, TB_Constants.TB_TEST_LABEL + TB_Constants.TB_PARAM_ZIP_EXTENSION, TB_Constants.TB_TEST_LABEL);
        testContentVersion.IsMajorVersion = false;
        testContentVersion.TB_Imported__c = false;
        insert testContentVersion;
    }

    @IsTest
    private static void testQueueablePositive() {
        Zippex dataToQueueable = new Zippex();
        dataToQueueable.addFile(TB_Constants.TB_TEST_LABEL, Blob.valueof(TB_Constants.TB_TEST_LABEL), null);
        ContentVersion testQueueableContentVersion = [SELECT TB_Imported__c, VersionData FROM ContentVersion WHERE Title = :TB_Constants.TB_TEST_LABEL LIMIT 1];

        Test.startTest();
        System.enqueueJob(new TB_GetDeliveredDocumentsZipArchive(testQueueableContentVersion, dataToQueueable));
        Test.stopTest();

        System.assertEquals(true, [SELECT TB_Imported__c FROM ContentVersion WHERE Title = :TB_Constants.TB_TEST_LABEL LIMIT 1].TB_Imported__c, 'TB_Imported__c should be upadated to true by queueable Apex');
    }

    @IsTest
    private static void testQueueableNegative() {
        Test.startTest();
        System.enqueueJob(new TB_GetDeliveredDocumentsZipArchive(null, null));
        Test.stopTest();

        System.assertEquals(1, [SELECT ID FROM TB_Log__c].size(), 'Exceptions should be handled by the method');
    }
}