@IsTest
private class TB_CT_FileSharingManagerTest {
    private static final String CATEGORY_DIPLOMA = 'Diploma';
    private static final String CATEGORY_CV = 'CV';
    private static final String VISIBILITY_ALL_USERS = 'AllUsers';
    private static final String RECORD_TYPE_CONTRACT_TEACHERS = 'TB_Contract_Teachers';

    @TestSetup
    private static void setupMethod() {
        Contact contact = TB_TestDataFactory.createContact(true);

        Id recordTypeId = Schema.SObjectType.TB_Experience_History__c.getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_CONTRACT_TEACHERS).getRecordTypeId();
        TB_Experience_History__c history = new TB_Experience_History__c(
                RecordTypeId = recordTypeId,
                TB_Name__c = 'Test',
                TB_Active__c = true
        );
        insert history;

        List<ContentVersion> contentVersions = new List<ContentVersion>();
        for (Integer i = 0; i < 5; i++) {
            ContentVersion versionCV = TB_TestDataFactory.createContentVersion(false, 'Test', 'Test.jpg', 'Test');
            ContentVersion versionDiploma = TB_TestDataFactory.createContentVersion(false, 'Test', 'Test.jpg', 'Test');
            versionCV.TB_Category__c = CATEGORY_CV;
            versionDiploma.TB_Category__c = CATEGORY_DIPLOMA;
            contentVersions.addAll(new List<ContentVersion> {versionCV, versionDiploma});
        }
        insert contentVersions;

        List<ContentVersion> insertedContentVersions = [
                SELECT ContentDocumentId, TB_Category__c
                FROM ContentVersion
        ];

        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        for (ContentVersion version : insertedContentVersions) {
            if (version.TB_Category__c == CATEGORY_CV) {
                links.add(TB_TestDataFactory.createContentDocumentLink(false, version.ContentDocumentId, contact.Id));
            } else if (version.TB_Category__c == CATEGORY_DIPLOMA) {
                links.add(TB_TestDataFactory.createContentDocumentLink(false, version.ContentDocumentId, history.Id));
            }
        }
        insert links;
    }

    @IsTest
    private static void updateCDLsVisibilityContactPositiveTest() {
        List<ContentVersion> versions = [
                SELECT TB_Category__c, ContentDocumentId
                FROM ContentVersion
        ];

        Contact contact = [
                SELECT Id
                FROM Contact
        ];

        Test.startTest();
        new TB_CT_FileSharingManager(versions).updateCDLsVisibility();
        Test.stopTest();

        List<ContentDocumentLink> contentDocumentLinks = [
                SELECT Visibility
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :contact.Id
        ];

        for (ContentDocumentLink link : contentDocumentLinks) {
            System.assertEquals(VISIBILITY_ALL_USERS, link.Visibility);
        }
    }

    @IsTest
    private static void updateCDLsVisibilityExpHistoryPositiveTest() {
        List<ContentVersion> versions = [
                SELECT TB_Category__c, ContentDocumentId
                FROM ContentVersion
        ];

        TB_Experience_History__c history = [
                SELECT Id
                FROM TB_Experience_History__c
        ];

        Test.startTest();
        new TB_CT_FileSharingManager(versions).updateCDLsVisibility();
        Test.stopTest();

        List<ContentDocumentLink> contentDocumentLinks = [
                SELECT Visibility
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :history.Id
        ];

        for (ContentDocumentLink link : contentDocumentLinks) {
            System.assertEquals(VISIBILITY_ALL_USERS, link.Visibility);
        }
    }

    @IsTest
    private static void updateCDLsVisibilityExpHistoryNegativeTest() {

        ContentVersion version = TB_TestDataFactory.createContentVersion(false, 'Test', 'Test.jpg', 'Test');
        insert version;

        Test.startTest();
        List<ContentDocumentLink> result = new TB_CT_FileSharingManager(new List<ContentVersion>{version}).getFilteredContentDocumentLinks();
        Test.stopTest();

        System.assertEquals(0, result.size());
    }
}