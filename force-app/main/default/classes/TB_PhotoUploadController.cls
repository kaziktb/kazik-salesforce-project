public with sharing class TB_PhotoUploadController {
    static final String STEP_TYPE = 'Photo';
    static final String DOCUMENT_CATEGORY = 'Photo';
    static final String DOCUMENT_NAME = 'Zdjęcie do legitymacji';
    static final String DOCUMENT_TITLE = 'IdPhotoComponent';
    static final String DOCUMENT_EMPTY_STATUS = 'Empty';
    static final String DOCUMENT_TO_VERIFY_STATUS = 'To_Verify';
    static final String DOCUMENT_ENCODING = 'UTF-8';
    static final String DOCUMENT_EXTENSION = '.png';
    static final String DOCUMENT_SHARE_TYPE = 'V';
    static final String DOCUMENT_VISIBILITY = 'AllUsers';

    @AuraEnabled
    public static void removeStepHistory(Id parentId) {
        try {
            TB_Application_Step_History__c photoStepHistory = [
                SELECT ID
                FROM TB_Application_Step_History__c
                WHERE TB_Application__c = :parentId
                AND TB_Admissions_Step_Type__c = :STEP_TYPE
            ];

            delete photoStepHistory;
        } catch (Exception e) {
            TB_LogUtils.registerLogFuture(
                e.getMessage(),
                TB_PhotoUploadController.class.getName()
            );
        }
    }

    @AuraEnabled
    public static void clearCurrentFile(Id parentId) {
        TB_Application_Document__c applicationDocument = [
            SELECT Id, TB_Status__c
            FROM TB_Application_Document__c
            WHERE
                TB_Application__c = :parentId
                AND TB_Document_Category__c = :DOCUMENT_CATEGORY
                AND TB_Document_Name__c = :DOCUMENT_NAME
            LIMIT 1
        ];

        List<Id> contentDocumentIds = new List<Id>();

        for (ContentDocumentLink singleDocumentLink : [
            SELECT Id, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :parentId
        ]) {
            contentDocumentIds.add(singleDocumentLink.ContentDocumentId);
        }

        List<ContentDocument> contentDocument = [
            SELECT Id, Title
            FROM ContentDocument
            WHERE Id IN :contentDocumentIds AND Title = :DOCUMENT_TITLE
        ];

        List<Database.DeleteResult> photoDeleteResult = Database.delete(
            contentDocument,
            true
        );

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

        applicationDocument.TB_Status__c = DOCUMENT_EMPTY_STATUS;
        applicationDocument.TB_Comment__c = '';

        Database.SaveResult photoUpdateResult = Database.update(
            applicationDocument,
            true
        );

        if (!photoUpdateResult.isSuccess()) {
            TB_LogUtils.registerLogFuture(
                photoUpdateResult.errors.get(0).message,
                TB_PhotoUploadController.class.getName()
            );
        }
    }

    @AuraEnabled
    public static Id saveTheChunkFile(
        Id parentId,
        String fileName,
        String base64Data,
        String fileId
    ) {
        base64Data = EncodingUtil.urlDecode(base64Data, DOCUMENT_ENCODING);
        if (String.isBlank(fileId)) {
            fileId = saveFiles(parentId, fileName, base64Data, parentId);
        } else {
            appendToFile(fileId, base64Data);
        }

        return Id.valueOf(fileId);
    }

    private static Id saveFiles(
        Id recordId,
        String fileName,
        String base64Data,
        String parentId
    ) {
        TB_Application_Document__c applicationDocument = [
            SELECT Id, TB_Status__c
            FROM TB_Application_Document__c
            WHERE
                TB_Application__c = :parentId
                AND TB_Document_Category__c = :DOCUMENT_CATEGORY
                AND TB_Document_Name__c = :DOCUMENT_NAME
            LIMIT 1
        ];

        ContentVersion contentToInsert = new ContentVersion();
        contentToInsert.Title = DOCUMENT_TITLE;
        contentToInsert.VersionData = EncodingUtil.base64Decode(base64Data);
        contentToInsert.PathOnClient = '/' + fileName + DOCUMENT_EXTENSION;
        contentToInsert.IsMajorVersion = false;
        contentToInsert.TB_Application_Document__c = applicationDocument.id;
        Database.SaveResult insertResult = Database.insert(contentToInsert, true);

        if (!insertResult.isSuccess()) {
            TB_LogUtils.registerLogFuture(
                insertResult.errors.get(0).message,
                TB_PhotoUploadController.class.getName()
            );
        }

        applicationDocument.TB_Status__c = DOCUMENT_TO_VERIFY_STATUS;

        Database.SaveResult updateResult = Database.update(
            applicationDocument,
            true
        );

        if (!updateResult.isSuccess()) {
            TB_LogUtils.registerLogFuture(
                updateResult.errors.get(0).message,
                TB_PhotoUploadController.class.getName()
            );
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

        if (!insertResult.isSuccess()) {
            TB_LogUtils.registerLogFuture(
                insertResult.errors.get(0).message,
                TB_PhotoUploadController.class.getName()
            );
        }

        return contentToInsert.id;
    }

    @AuraEnabled
    public static void appendToFile(Id contentDocumentId, String base64Data) {
        ContentVersion versionData = [
            SELECT Id, VersionData, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :contentDocumentId
        ];

        String existingBody = EncodingUtil.base64Encode(versionData.VersionData);
        versionData.VersionData = EncodingUtil.base64Decode(
            existingBody + base64Data
        );

        Database.SaveResult updateResult = Database.update(
            versionData,
            true
        );

        if (!updateResult.isSuccess()) {
            TB_LogUtils.registerLogFuture(
                updateResult.errors.get(0).message,
                TB_PhotoUploadController.class.getName()
            );
        }
    }

    @AuraEnabled
    public static String downloadFile(Id parentId) {
        String returnData = null;

        List<Id> contentDocumentIds = new List<Id>();

        for (ContentDocumentLink singleDocumentLink : [
            SELECT Id, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :parentId
        ]) {
            contentDocumentIds.add(singleDocumentLink.ContentDocumentId);
        }

        if (!contentDocumentIds.isEmpty()) {
            ContentVersion document = [
                SELECT Id, VersionData
                FROM ContentVersion
                WHERE
                    ContentDocumentId IN :contentDocumentIds
                    AND Title = :DOCUMENT_TITLE
            ];
            returnData = EncodingUtil.base64Encode(document.VersionData);
        }
        return returnData;
    }

    @AuraEnabled
    public static TB_Application_Document__c getPhotoStatus(String parentId) {
        return (TB_Application_Document__c) [
            SELECT Id, TB_Status__c, TB_Comment__c
            FROM TB_Application_Document__c
            WHERE
                TB_Application__c = :parentId
                AND TB_Document_Category__c = :DOCUMENT_CATEGORY
                AND TB_Document_Name__c = :DOCUMENT_NAME
            LIMIT 1
        ];
    }
}