public with sharing class TB_DocumentVerificationController {

    @AuraEnabled (Cacheable = true)
    public static ApplicationDocumentWrapper fetchApplicationDocuments(Id applicationId) {
        ApplicationDocumentWrapper documentWrapper = new ApplicationDocumentWrapper();
        documentWrapper.documentIdToApplicationDocument = new Map<Id, TB_Application_Document__c>([
                SELECT TB_Status__c, TB_Sub_Status__c, TB_Comment__c, TB_Document_File_Date_Time__c,
                        TB_Content_Version_Id__c, TB_Content_Document_Id__c,
                        TB_Document_Type__c, TB_Download_URL__c, TB_Document_Name_PL__c, TB_Document_Name_EN__c,
                        TB_Document_Category__c, TB_Internal__c, TB_Document_Template_External_Id__c
                FROM TB_Application_Document__c
                WHERE TB_Application__c = :applicationId
        ]);
        Set<Id> contentVersionIds = new Set<Id>();
        for (TB_Application_Document__c document : documentWrapper.documentIdToApplicationDocument.values()) {
            contentVersionIds.add(document.TB_Content_Version_Id__c);
        }
        for (ContentVersion version : [
                SELECT TB_Application_Document__c, FileExtension
                FROM ContentVersion
                WHERE Id IN :contentVersionIds
        ]) {
            documentWrapper.idToFileExtension.put(version.TB_Application_Document__c, version.FileExtension);
            documentWrapper.idToContentVersion.put(version.TB_Application_Document__c, version.Id);
        }
        return documentWrapper;
    }

    @AuraEnabled (Cacheable = true)
    public static Map<Id, TB_Admissions_Dictionary__c> fetchDocumentComments(Id applicationId) {
        hed__Application__c application = [
                SELECT TB_Product_Group__c
                FROM hed__Application__c
                WHERE Id = :applicationId
        ];
        Map<Id, TB_Admissions_Dictionary__c> documentIdToComments = new Map<Id, TB_Admissions_Dictionary__c>();
        for (TB_JSON_Wrapper__c commentWrapper : [
                SELECT TB_Wrapper_Value__c
                FROM TB_JSON_Wrapper__c
                WHERE TB_Object_API_Name__c = :TB_Constants.TB_OBJECT_API_NAME_ADMISSIONS_DICTIONARY
                AND TB_Record_Type_Dev_Name__c = :TB_Constants.ADMISSIONS_DICTIONARY_RT_COMMENT_DEVNAME
        ]) {
            TB_Admissions_Dictionary__c comment = (TB_Admissions_Dictionary__c) JSON.deserialize(commentWrapper.TB_Wrapper_Value__c, TB_Admissions_Dictionary__c.class);
            if ((comment.TB_Active__c) && (application.TB_Product_Group__c == comment.TB_Product_Group__c)) {
                documentIdToComments.put(comment.Id, comment);
            }
        }
        return documentIdToComments;
    }

    @AuraEnabled
    public static void updateDocumentStatus(List<Id> documentIds, String status) {
        List<TB_Application_Document__c> documents = new List<TB_Application_Document__c>();
        for (Id id : documentIds) {
            documents.add(new TB_Application_Document__c(Id = id, TB_Status__c = status));
        }
        update documents;
    }

    @AuraEnabled
    public static void updateDocuments(List<TB_Application_Document__c> documents) {
        update documents;
    }

    public class ApplicationDocumentWrapper {
        @AuraEnabled public Map<Id, TB_Application_Document__c> documentIdToApplicationDocument;
        @AuraEnabled public Map<Id, String> idToFileExtension;
        @AuraEnabled public Map<Id, String> idToContentVersion;

        public ApplicationDocumentWrapper() {
            documentIdToApplicationDocument = new Map<Id, TB_Application_Document__c>();
            idToFileExtension = new Map<Id, String>();
            idToContentVersion = new Map<Id, String>();
        }
    }
}