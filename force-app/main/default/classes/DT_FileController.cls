public without sharing class DT_FileController {

    @AuraEnabled
    public static String getRelatedFilesToRecord(Id recordId) {
        List<ContentDocumentLink> cdl = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :recordId
        ];

        List <Id> cdlIds = new List <Id> ();
        for (ContentDocumentLink nextCDL : cdl) {
            cdlIds.add(nextCDL.ContentDocumentId);
        }

        List<ContentVersion> cv = [
                SELECT Id, Title, FileType, FileExtension, ContentDocumentId
                FROM ContentVersion
                WHERE ContentDocumentId IN: cdlIds
        ];

        return JSON.serialize(cv);
    }
}