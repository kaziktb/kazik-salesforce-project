public without sharing class TB_PDFViewerController {

    @AuraEnabled(Cacheable = true)
    public static Map<Id,ViewerWrapper> getRelatedFilesByRecordId(String recordId) {
        Map<Id,String> titles = new Map<Id,String>();
        Map<Id,Id> contactToLink = new Map<Id,Id>();
        Set<Id> applicationDocumentIds = new Set<Id>();
        for (TB_Application_Document__c docs : [
            SELECT Id,TB_Document_Name__c
            FROM TB_Application_Document__c
            WHERE TB_Application__c = :recordId
            AND TB_Document_Type__c = :TB_re_Constants.TB_APP_DOCUMENT_TYPE_SCAN
        ]) {
            applicationDocumentIds.add(docs.Id);
            titles.put(docs.Id, docs.TB_Document_Name__c);
        }
        List<ContentDocumentLink> files = [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :applicationDocumentIds
        ];
        List<Id> fileIDs = new List<Id>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
            contactToLink.put(docLink.ContentDocumentId, docLink.LinkedEntityId);
        }
        List<ContentVersion> docs = [
            SELECT ContentDocumentId, FileExtension, Title
            FROM ContentVersion
            WHERE ContentDocumentId IN : fileIDs
        ];
        Map<Id,ViewerWrapper> contentDocumentIdToWrapper = new Map<Id,ViewerWrapper>();
        for (ContentVersion docLink : docs) {
            ViewerWrapper viewerWrapper = new ViewerWrapper(
                docLink.FileExtension == 'pdf',
                titles.get(contactToLink.get(docLink.ContentDocumentId)),
                '/sfc/servlet.shepherd/version/download/' + docLink.Id
            );
            contentDocumentIdToWrapper.put(docLink.ContentDocumentId, viewerWrapper);
        }
        return contentDocumentIdToWrapper;
    }

    public class ViewerWrapper {
        @AuraEnabled public Boolean isPdf;
        @AuraEnabled public String title;
        @AuraEnabled public String image;

        public ViewerWrapper(Boolean isPdf, String title, String image) {
            this.isPdf = isPdf;
            this.title = title;
            this.image = image;
        }
    }

}