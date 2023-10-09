public with sharing class TB_vu_FileUploadExtended {
    private static final String CONTENT_DOCUMENT_LINK_SHARE_TYPE_V = 'V';
    private static final String CONTENT_DOCUMENT_LINK_VISIBILITY_ALL_USERS = 'AllUsers';

    @AuraEnabled
    public static List<FileWrapper> getFileWrappers(List<Id> contentVersionIds){
        try {
            List<FileWrapper> toReturn = new List<FileWrapper>();
            for(ContentVersion cv: [
                SELECT 
                    Id, 
                    Title, 
                    ContentSize, 
                    FileExtension 
                FROM ContentVersion
                WHERE Id IN: contentVersionIds]){
                    toReturn.add(new FileWrapper(
                        cv.Id,
                        cv.Title,
                        cv.ContentSize,
                        cv.FileExtension
                    ));
                }
                
            return toReturn;
        } catch (Exception e) {
            throw new AuraHandledException(TB_LogUtils.prepareAuraLog(e.getMessage(), TB_vu_FileUploadExtended.class.getName(),e.getStackTraceString(), String.valueOf(contentVersionIds)));
        }
    }

    @AuraEnabled
    public static void updateContentVersions(List<Id> contentVersionIds, List<Id> recordIds) {
        try {
            List<ContentVersion> contentVersions = [
                    SELECT
                        TB_Category__c,
                        Title,
                        ContentDocumentId
                    FROM ContentVersion
                    WHERE Id IN :contentVersionIds
            ];
            Map<Id, Id> contentVersionIdToContentDocumentId = new Map<Id, Id>();
            for (ContentVersion version : contentVersions) {
                for(Id recordId : recordIds){
                    contentVersionIdToContentDocumentId.put(version.Id, version.ContentDocumentId);
                }
            }
            update contentVersions;

            List<ContentDocumentLink> linksToInsert = getLinksToInsert(contentVersionIdToContentDocumentId, recordIds);
            new WithoutSharing().insertContentDocumentLinks(linksToInsert);
        } catch (Exception e) {
            throw new AuraHandledException(TB_LogUtils.prepareAuraLog(e.getMessage(), TB_vu_FileUploadExtended.class.getName(),e.getStackTraceString(), String.valueOf(recordIds)));
        }
    }

    @AuraEnabled
    public static void deleteContentDocuments(List<Id> contentVersionIds) {
        try {
            List<ContentVersion> contentVersions = [
                SELECT ContentDocumentId
                FROM ContentVersion
                WHERE Id IN :contentVersionIds
            ];
            Set<String> contentDocIds = TB_SObjectUtils.createIdFieldValueSet(contentVersions, ContentVersion.ContentDocumentId);

            List<Id> deletableRecordIds = new List<Id>();
            for (UserRecordAccess deletableRecord : [SELECT RecordId
                FROM UserRecordAccess
                WHERE UserId = :UserInfo.getUserId()
                AND HasDeleteAccess = TRUE
                AND RecordId IN :contentDocIds]) {
                deletableRecordIds.add(deletableRecord.Id);
            }
            List<ContentDocument> documents = [SELECT Id FROM ContentDocument WHERE Id IN :deletableRecordIds];
            delete documents;
        } catch (Exception e) {
            throw new AuraHandledException(TB_LogUtils.prepareAuraLog( e.getMessage(), TB_vu_FileUploadExtended.class.getName(), e.getStackTraceString(), TB_Constants.PARAM_EMPTY_STRING));
        }
    }

    private static List<ContentDocumentLink> getLinksToInsert(Map<Id, Id> contentVersionIdToContentDocumentId, List<Id> recordIds) {
        List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();
        for (Id contentVersionId : contentVersionIdToContentDocumentId.keySet()) {
            for(Id recordId : recordIds){
                linksToInsert.add(
                    new ContentDocumentLink(
                            LinkedEntityId = recordId,
                            ContentDocumentId = contentVersionIdToContentDocumentId.get(contentVersionId),
                            Visibility = CONTENT_DOCUMENT_LINK_VISIBILITY_ALL_USERS
                    )
                );
            }

        }
        return linksToInsert;
    }

    private without sharing class WithoutSharing
    {
        void insertContentDocumentLinks(List<ContentDocumentLink> contentDocumentLinks)
        {
            insert contentDocumentLinks;
        }
    }

    public class FileWrapper{
        @AuraEnabled
        public String Id { get; set; }
        @AuraEnabled
        public String Title { get; set; }
        @AuraEnabled
        public Integer ContentSize { get; set; }
        @AuraEnabled
        public String FileExtension { get; set; }

        public FileWrapper(String Id, String Title, Integer ContentSize, String FileExtension){
            this.Id = Id;
            this.Title = Title;
            this.ContentSize = ContentSize;
            this.FileExtension = FileExtension;
        }
    }
}