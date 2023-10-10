public with sharing class TB_CT_PhotoUploadController {
    static final String DOCUMENT_CATEGORY = 'Main_Picture';
    static final String DOCUMENT_NAME = 'Zdjęcie dydaktyka';
    static final String DOCUMENT_TITLE = 'IdPhotoComponent';
    static final String DOCUMENT_EMPTY_STATUS = 'Empty';
    static final String DOCUMENT_ENCODING = 'UTF-8';
    static final String DOCUMENT_EXTENSION = '.png';
    static final String DOCUMENT_SHARE_TYPE = 'V';
    static final String DOCUMENT_VISIBILITY = 'AllUsers';


    private static Set<Id> getContentDocumentIds(Id parentId){
        Set<Id> contentDocumentIds = new Set<Id>();

        for (ContentDocumentLink singleDocumentLink : [
                SELECT Id, ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :parentId
        ]) {
            contentDocumentIds.add(singleDocumentLink.ContentDocumentId);
        }
        return contentDocumentIds;
    }

    @AuraEnabled
    public static void clearCurrentFile(Id parentId) {

        Set<Id> contentDocumentIds = getContentDocumentIds(parentId);

        List<ContentDocument> contentDocuments = [
                SELECT Id, Title
                FROM ContentDocument
                WHERE Id IN :contentDocumentIds AND Title = :DOCUMENT_TITLE
        ];

        List<Database.DeleteResult> photoDeleteResult = Database.delete(
                contentDocuments,
                true
        );
        registerDeleteErrors(photoDeleteResult);
    }

    private static void registerDeleteErrors(List<Database.DeleteResult> photoDeleteResult){
        List<String> deleteLogs = new List<String>();
        for (Database.DeleteResult singleDeleteResult : photoDeleteResult) {
            if (!singleDeleteResult.isSuccess()) {
                deleteLogs.add(singleDeleteResult.errors.get(0).message);
            }
        }
        insert TB_LogUtils.registerLogs(
                deleteLogs,
                TB_PhotoUploadController.class.getName()
        );
    }

    @AuraEnabled
    public static Id saveTheChunkFile(
            Id parentId,
            String fileName,
            String base64Data,
            String fileId
    ) {
        try {
            base64Data = EncodingUtil.urlDecode(base64Data, DOCUMENT_ENCODING);
            fileId = saveFiles(parentId, fileName, base64Data, parentId);
            return Id.valueOf(fileId);
        } catch (Exception ex) {
            System.debug(ex.getStackTraceString() + ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
    }

    private static Id saveFiles(
            Id recordId,
            String fileName,
            String base64Data,
            String parentId
    ) {
        ContentVersion contentToInsert = new ContentVersion();
        contentToInsert.Title = DOCUMENT_TITLE;
        contentToInsert.VersionData = EncodingUtil.base64Decode(base64Data);
        contentToInsert.PathOnClient = TB_Constants.TB_SEPARATOR_SLASH + fileName + DOCUMENT_EXTENSION;
        contentToInsert.IsMajorVersion = false;
        contentToInsert.TB_Category__c = DOCUMENT_CATEGORY;
        contentToInsert.TB_Is_Main_Avatar__c = true;
        Database.SaveResult insertResult = Database.insert(contentToInsert, true);
        if(!registerInsertErrors(insertResult)){
            throw new TB_CT_PhotoUploadControllerException();
        }

        contentToInsert = [
                SELECT id, ContentDocumentId
                FROM ContentVersion
                WHERE Id = :contentToInsert.Id
        ];
        ContentDocumentLink cl = new ContentDocumentLink();
        cl.ContentDocumentId = contentToInsert.ContentDocumentId;
        cl.LinkedEntityId = recordId;
        cl.ShareType = DOCUMENT_SHARE_TYPE;
        cl.Visibility = DOCUMENT_VISIBILITY;
        insertResult = Database.insert(cl, true);
        if(!registerInsertErrors(insertResult)){
            throw new TB_CT_PhotoUploadControllerException();
        }
        return contentToInsert.id;
    }
    
    private static Boolean registerInsertErrors(Database.SaveResult insertResult){
        Boolean isSuccess = insertResult.isSuccess();
        if (!isSuccess) {
            TB_LogUtils.registerLogFuture(
                    insertResult.errors.get(0).message,
                    TB_PhotoUploadController.class.getName()
            );
        }
        return isSuccess;
    }

    @AuraEnabled
    public static String downloadFile(Id parentId) {
        String returnData;
        Set<Id> contentDocumentIds = getcontentDocumentIds(parentId);

        if (!contentDocumentIds.isEmpty()) {
            ContentVersion document = [
                    SELECT Id, VersionData
                    FROM ContentVersion
                    WHERE
                    ContentDocumentId IN :contentDocumentIds
                    AND Title = :DOCUMENT_TITLE  AND TB_Category__c = :DOCUMENT_CATEGORY AND TB_Is_Main_Avatar__c = true LIMIT 1
            ];
            returnData = EncodingUtil.base64Encode(document.VersionData);
        }
        return returnData;
    }

    public class TB_CT_PhotoUploadControllerException extends Exception {}
}
