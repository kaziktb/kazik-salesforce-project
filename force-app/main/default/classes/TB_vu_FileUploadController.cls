/**
 * Created by kamilkwaczynski on 21/09/2022.
 */

public with sharing class TB_vu_FileUploadController {
    public static final String CONTENT_VERSION_SOR_CATEGORY = 'Students_Organisation_Regulations';
    public static final String CONTENT_DOCUMENT_LINK_SHARE_TYPE_V = 'V';
    public static final String CONTENT_DOCUMENT_LINK_VISIBILITY_ALL_USERS = 'AllUsers';
    @AuraEnabled
    public static String uploadChunkedFile(Id recordId, String fileName, String fileContent, String contentVersionId) {
        try {
            Id contentVersionIdToReturn;
            fileContent = EncodingUtil.urlDecode(fileContent, 'UTF-8');
            if (String.isBlank(contentVersionId)) {
                ContentVersion cv = new ContentVersion();
                cv.Title = fileName;
                cv.VersionData = EncodingUtil.base64Decode(fileContent);
                cv.PathOnClient = '/' + fileName;
                cv.IsMajorVersion = false;
                cv.TB_Category__c = CONTENT_VERSION_SOR_CATEGORY;
                insert cv;

                Id contentDocId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id]
                .ContentDocumentId;
                ContentDocumentLink cdl = new ContentDocumentLink();

                cdl.ContentDocumentId = contentDocId;
                cdl.LinkedEntityId = recordId;
                cdl.ShareType = CONTENT_DOCUMENT_LINK_SHARE_TYPE_V;
                cdl.Visibility = CONTENT_DOCUMENT_LINK_VISIBILITY_ALL_USERS;
                insert cdl;
                contentVersionIdToReturn = cv.Id;
            } else {
                ContentVersion cv = [
                    SELECT Id, VersionData, ContentDocumentId
                    FROM ContentVersion
                    WHERE Id = :contentVersionId
                ];
                String existingFileContent = EncodingUtil.base64Encode(cv.VersionData);
                cv.VersionData = EncodingUtil.base64Decode(existingFileContent + fileContent);
                contentVersionIdToReturn = contentVersionId;
                update cv;
            }
            return contentVersionIdToReturn;
        } catch (Exception e) {
            throw new AuraHandledException(
                TB_vu_Utils.registerLog(
                    e.getMessage(),
                    TB_vu_FileUploadController.class.getName(),
                    e.getStackTraceString(),
                    ''
                )
            );
        }
    }
    @AuraEnabled
    public static void deleteFile(Id recordId) {
        try {
            delete [
                SELECT Id
                FROM ContentDocument
                WHERE
                    Id = :[SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId]
                    .ContentDocumentId
            ];
        } catch (Exception e) {
            throw new AuraHandledException(
                TB_vu_Utils.registerLog(
                    e.getMessage(),
                    TB_vu_FileUploadController.class.getName(),
                    e.getStackTraceString(),
                    ''
                )
            );
        }
    }
    @AuraEnabled
    public static String getRegulationsFileByAccountId(Id recordId) {
        try {
            List<ContentDocumentLink> cdl = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :recordId
                LIMIT 1
            ];
            if (cdl.size() == 0) {
                return '';
            }
            ContentVersion cv = [
                SELECT ContentDocumentId, FileExtension, Title
                FROM ContentVersion
                WHERE ContentDocumentId = :cdl[0].ContentDocumentId
            ];
            Map<Id, String> mapIdTitle = new Map<Id, String>{ cv.ContentDocumentId => cv.Title };
            return JSON.serialize(mapIdTitle);
        } catch (Exception e) {
            throw new AuraHandledException(
                TB_vu_Utils.registerLog(
                    e.getMessage(),
                    TB_vu_FileUploadController.class.getName(),
                    e.getStackTraceString(),
                    ''
                )
            );
        }
    }
}