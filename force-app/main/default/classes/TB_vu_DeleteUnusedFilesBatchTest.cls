@isTest
private class TB_vu_DeleteUnusedFilesBatchTest {
    private static final String TITLE_FILE = 'asd.pdf';
    
    @TestSetup
    private static void testSetup(){
        User user = TB_TestDataFactory.createUser('SWPS Employee Platform User', true);
        System.runAs(user){
            List<ContentVersion> cvToInsert = new List<ContentVersion>();
            List<ContentDocumentLink> cdlToInsert = new List<ContentDocumentLink>();
        
            for(Integer i=0; i<20; i++){
                cvToInsert.add(TB_TestDataFactory.createContentVersion(false, TITLE_FILE + i, TITLE_FILE + i, EncodingUtil.base64Encode(Blob.toPdf('a'))));
            }
            insert cvToInsert;
        }
    }

    @isTest
    private static void shouldDelete20ContentDocuments() {
        User user = [SELECT Id FROM User WHERE Username LIKE 'puser000%' LIMIT 1];
        List<Id> cdIds = new List<Id>();
        for (ContentDocumentLink cdl : [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: user.Id]){
            cdIds.add(cdl.ContentDocumentId);
        }
        List<ContentDocument> cd = [SELECT Id FROM ContentDocument WHERE Id IN: cdIds];

        Test.startTest();
            Database.executeBatch(new TB_vu_DeleteUnusedFilesBatch());
        Test.stopTest();

        Assert.isTrue([SELECT Id FROM ContentDocument WHERE Id IN: cdIds].size() == 0);
    }
}