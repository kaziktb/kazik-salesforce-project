
public with sharing class TB_CT_FileUpload {
    public static final String CONTENT_DOCUMENT_LINK_SHARE_TYPE_V = 'V';
    public static final String CONTENT_DOCUMENT_LINK_VISIBILITY_ALL_USERS = 'AllUsers';

    @AuraEnabled
    public static String uploadChunkedFile(String recordId, String fileName, String fileContent, String contentVersionId, String category) {
        try {
            fileContent = EncodingUtil.urlDecode(fileContent, 'UTF-8');
            if (String.isBlank(contentVersionId)) {
                ContentVersion contentVersion = getContentVersion(fileName, fileContent, category);
                insert contentVersion;
                if (String.isNotBlank(recordId)) {
                    handleContentDocumentLinks(contentVersion.Id, recordId);
                }
                return contentVersion.Id;
            } else {
                ContentVersion contentVersion = [
                        SELECT Id, VersionData, ContentDocumentId
                        FROM ContentVersion
                        WHERE Id = :contentVersionId
                ];
                String existingFileContent = EncodingUtil.base64Encode(contentVersion.VersionData);
                contentVersion.VersionData = EncodingUtil.base64Decode(existingFileContent + fileContent);
                update contentVersion;
                return contentVersion.Id;
            }
        } catch (Exception ex) {
            throw new AuraHandledException(TB_LogUtils.prepareAuraLog(ex.getMessage(), TB_CT_FileUpload.class.getName(), ex.getStackTraceString(), ''));
        }
    }

    private static ContentVersion getContentVersion(String fileName, String fileContent, String category) {
        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.VersionData = EncodingUtil.base64Decode(fileContent);
        cv.PathOnClient = '/' + fileName;
        cv.IsMajorVersion = false;
        if (String.isNotBlank(category)) {
            cv.TB_Category__c = category;
        }
        return cv;
    }

    private static void handleContentDocumentLinks(Id contentVersionId, Id linkedEntityId) {
        Id contentDocId = [
                SELECT Id, ContentDocumentId
                FROM ContentVersion
                WHERE Id = :contentVersionId
        ].ContentDocumentId;
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = contentDocId;
        contentDocumentLink.LinkedEntityId = linkedEntityId;
        contentDocumentLink.ShareType = CONTENT_DOCUMENT_LINK_SHARE_TYPE_V;
        contentDocumentLink.Visibility = CONTENT_DOCUMENT_LINK_VISIBILITY_ALL_USERS;
        insert contentDocumentLink;
    }
}