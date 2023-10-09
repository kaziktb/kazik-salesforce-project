public without sharing class MySwpsFileInputController {
    @AuraEnabled
    public static void fileHandler(FileWrapper fileWrapper, Id relatedRecordId) {
        ContentVersion contentVersion = createContentVersion(fileWrapper.base64, fileWrapper.fileName);

        createContentDocumentLink(
            contentVersion.Id,
            relatedRecordId,
            Constants.CONTENT_DOCUMENT_LINK_SHARE_TYPE_VIEWER_API_NAME,
            Constants.CONTENT_DOCUMENT_LINK_VISIBILITY_ALL_USERS_API_NAME
        );
    }

    private static ContentVersion createContentVersion(String base64, String fileName) {
        ContentVersion contentVersion = new ContentVersion(
            PathOnClient = fileName,
            Title = fileName,
            VersionData = EncodingUtil.base64Decode(base64)
        );

        if (Test.isRunningTest()) {
            Network mySwpsNetwork = [SELECT Id FROM Network WHERE Name = :Constants.NETWORK_NAME_MYSWPS];
            contentVersion.NetworkId = mySwpsNetwork.Id;
        }

        insert contentVersion;
        return contentVersion;
    }

    private static ContentDocumentLink createContentDocumentLink(Id contentVersionId, Id relatedRecordId, String shareType, String visibility) {
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();

        ContentVersion contentVersion = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id = :contentVersionId
        ];

        contentDocumentLink.ContentDocumentId = contentVersion.ContentDocumentId;
        contentDocumentLink.LinkedEntityId = relatedRecordId;
        contentDocumentLink.ShareType = shareType;
        contentDocumentLink.Visibility = visibility;

        insert contentDocumentLink;
        return contentDocumentLink;
    }

    public class FileWrapper {
        @AuraEnabled
        public String base64 {get; set;}
        @AuraEnabled
        public String fileName {get; set;}
    }
}