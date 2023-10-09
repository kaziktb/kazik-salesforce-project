/**
 * @description       : 
 * @author            : aleksandra.gonta-kacperska@devoteam.com
 * @group             : 
 * @last modified on  : 05-24-2021
 * @last modified by  : aleksandra.gonta-kacperska@devoteam.com
 * Modifications Log 
 * Ver   Date         Author                                    Modification
 * 1.0   05-10-2021   aleksandra.gonta-kacperska@devoteam.com   Initial Version
**/
public without sharing class DT_FileUploadViewController {

    @AuraEnabled(cacheable=true)
    public static List<File> getRelatedFiles(String recordId){
        List<File> files = new List<File>();

        for (ContentDocument document : getDocumentsWithVersionsByRecordIds(recordId)) {
                File file = new File();
                file.Title = document.Title;
                file.Id = document.Id;
                file.CreatedDate = document.CreatedDate;
                file.Extension = document.FileType;
                file.ContentType = document.ContentVersions.get(0).DT_Content_Type_fileupload__c;
                files.add(file);
        }
        return files;
    }

    @AuraEnabled
    public static List<File> getRelatedFiles(String recordId, String contentType) {
        List<File> files = new List<File>();
        List<ContentDocument> documents = getDocumentsWithVersionsByRecordIds(recordId, contentType);

        for (ContentDocument document : documents) {
            if (document.ContentVersions != null && !document.ContentVersions.isEmpty()) {
                File file = new File();
                file.Title = document.Title;
                file.Id = document.Id;
                file.CreatedDate = document.CreatedDate;
                file.Extension = document.FileType;
                file.ContentType = document.ContentVersions.get(0).DT_Content_Type_fileupload__c;
                files.add(file);
            }
        }
        return files;
    }

    @AuraEnabled(cacheable=true)
    public static List<ContentDocument> getDocumentsWithVersionsByRecordIds(String recordId) {
        Set<Id> documentIds = getRelatedDocumentIdsByRecordId(recordId);

        return [
            SELECT Id, Title, CreatedDate, FileType, FileExtension, (
                SELECT Id, DT_Content_Type_fileupload__c, FileType, FileExtension
                FROM ContentVersions
                ORDER BY CreatedDate DESC
            )
            FROM ContentDocument
            WHERE Id IN:documentIds
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<ContentDocument> getDocumentsWithVersionsByRecordIds(String recordId, String contentType) {
        Set<Id> documentIds = getRelatedDocumentIdsByRecordId(recordId);

        return [
            SELECT Id, Title, CreatedDate, FileType, FileExtension, (
                SELECT Id, DT_Content_Type_fileupload__c, FileType, FileExtension
                FROM ContentVersions
                WHERE DT_Content_Type_fileupload__c = :contentType
                ORDER BY CreatedDate DESC
            )
            FROM ContentDocument
            WHERE Id IN:documentIds
        ];
    }

    public static Set<Id> getRelatedDocumentIdsByRecordId(String recordId) {
        Set<Id> documentIds = new Set<Id>();
        for (ContentDocumentLink conLink : [
            SELECT ContentDocument.Id, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
        ]) {
            documentIds.add(conLink.ContentDocument.Id);
        }
        return documentIds;
    }

    public class File {
        @AuraEnabled public String Title;
        @AuraEnabled public String Extension;
        @AuraEnabled public Id Id;
        @AuraEnabled public Datetime CreatedDate;
        @AuraEnabled public String ContentType;
    }

    @AuraEnabled
    public static void deleteFiles(String fileId) {

        List<ContentVersion> cvs = [SELECT ContentDocumentId FROM ContentVersion WHERE ContentDocumentId = :fileId LIMIT 1];

        if (cvs.isEmpty()) {
            throw new FileException('File not found');
        }

        try {
            ContentDocument cd = new ContentDocument(Id = cvs.get(0).ContentDocumentId);
            delete cd;
        } catch (Exception ex) {
            throw new FileException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static void handleCreateContentDocumentLinks(List<String> contentVersionIds, String targetRecordId) {
        handleCreateContentDocumentLinks(
            contentVersionIds, targetRecordId, DT_Utils.SHARE_TYPE_INFERRED_PERMISSION, DT_Utils.VISIBILITY_TYPE_ALL_USERS
        );
    }

    public static void handleCreateContentDocumentLinks(
        List<String> contentVersionIds, String targetRecordId, String shareType, String visibilityType
    ) {
        if (contentVersionIds != null && !contentVersionIds.isEmpty()) {
            Set<Id> documentIds = getDocumentIdsByContentVersionIds(contentVersionIds);
            List<ContentDocumentLink> links = DT_FileUploadViewController.createContentDocumentLinks(
                documentIds, targetRecordId, shareType, visibilityType
            );
            DT_FileUploadViewController.insertContentDocumentLinks(links);
        }
    }

    public static Set<Id> getDocumentIdsByContentVersionIds(List<String> contentVersionIds) {
        Set<Id> documentIds = new Set<Id>();
        for (ContentVersion contentVersion : [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id IN:contentVersionIds
        ]) {
            documentIds.add(contentVersion.ContentDocumentId);
        }
        return documentIds;
    }

    public static List<ContentDocumentLink> createContentDocumentLinks(
        Set<Id> documentIds, Id targetRecordId, String shareType, String visibility
    ) {
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        for (Id documentId : documentIds) {
            links.add(
                createContentDocumentLink(
                    documentId, targetRecordId, shareType, visibility
                )
            );
        }
        return links;
    }

    public static ContentDocumentLink createContentDocumentLink(
        Id documentId, Id targetRecordId, String shareType, String visibility
    ) {
        return new ContentDocumentLink(
            ContentDocumentId = documentId,
            LinkedEntityId = targetRecordId,
            ShareType = shareType,
            Visibility = visibility
        );
    }

    public static void insertContentDocumentLinks(List<ContentDocumentLink> links) {
        try {
            insert links;
        } catch (Exception e) {
            throw new FileException(
                'Content Document Link insert failed. \n' + e.getMessage() + '\n ' + e.getStackTraceString()
            );
        }
    }

    public class FileException extends Exception {}
}