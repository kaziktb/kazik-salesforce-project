public with sharing class TB_DocumentsDataController {

    @AuraEnabled
    public static String getDocumentsToDownload(Id applicationId, String stepJson) {
        String documentCategoriesBeforeSplit = TB_Constants.PARAM_EMPTY_STRING;
        String documentTypesBeforeSplit = TB_Constants.PARAM_EMPTY_STRING;
        
        try {
            TB_Admissions_Process__c admissionsStep = (TB_Admissions_Process__c) JSON.deserialize(stepJson, TB_Admissions_Process__c.class);
            if (admissionsStep.TB_Step_Type__c == TB_Constants.STEP_TYPE_DOCUMENT_COLLECTION
                && admissionsStep.TB_Document_Categories__c != null
                && admissionsStep.TB_Document_Types__c != null
                ) {
                documentCategoriesBeforeSplit += admissionsStep.TB_Document_Categories__c;
                documentTypesBeforeSplit += admissionsStep.TB_Document_Types__c;
            }

            Set<String> documentCategories = new Set<String>(documentCategoriesBeforeSplit.split(';'));
            Set<String> documentTypes = new Set<String>(documentTypesBeforeSplit.split(';'));
            return JSON.serialize(getApplicationDocumentsWrappers(applicationId, documentCategories, documentTypes));
        } catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    private static List<TB_FileUtils.FileWrapper> getApplicationDocumentsWrappers(String applicationId, Set<String> documentCategories, Set<String> documentTypes) {
        List<TB_Application_Document__c> applicationDocumentsToReturn = [
            SELECT TB_Comment__c, TB_Download_URL__c, TB_Content_Document_Id__c, TB_Document_Category__c,
                TB_Document_Description_PL__c, TB_Document_Description_EN__c, TB_Document_Name_PL__c,
                TB_Document_Name_EN__c, TB_Document_Required__c, TB_Document_Type__c, TB_Status__c,
                toLabel(TB_Document_Category__c) TB_Document_Category_Label, TB_Experience__c,
                toLabel(TB_Status__c) TB_Status_Label, TB_Document_File_Name__c
            FROM TB_Application_Document__c
            WHERE IsDeleted = FALSE
            AND TB_Active__c = TRUE
            AND TB_Internal__c = FALSE
            AND TB_Anonymisation_Status__c != :TB_Constants.TB_APP_DOCUMENT_ANONYMISATION_STATUS_ANONYMIZED
            AND TB_Experience__c = NULL
            AND TB_Application__c = :applicationId
            AND TB_Document_Category__c IN :documentCategories
            AND TB_Document_Type__c IN :documentTypes
            ORDER BY Name ASC NULLS FIRST
        ];
        return TB_FileUtils.createFileWrapperForDocuments(applicationDocumentsToReturn);
    }

    @AuraEnabled
    public static List<TB_Document_Template_Bundle_Item__c> getDocumentTemplateBundleItems(){
        try{
            ID documentTemplatesBundleId = [SELECT ID FROM TB_Document_Templates_Bundle__c WHERE TB_On_Demand_Documents__c = true AND TB_Product_Group__c = :TB_Constants.TB_ADMISSIONS_CONTENT_PRODUCT_GROUP_HIGHER_EDUCATION AND TB_Active__c = true AND IsDeleted = false LIMIT 1].ID;
            return [SELECT TB_Document_Template__c, TB_Document_Template_Name__c FROM TB_Document_Template_Bundle_Item__c WHERE TB_Document_Templates_Bundle__c = :documentTemplatesBundleId AND TB_Document_Template_Type__c = :TB_Constants.TB_APP_DOCUMENT_TYPE_DYNAMIC_TEMPLATE ORDER BY TB_Document_Template_Name__c LIMIT 50000];
        } catch(Exception e){
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    @AuraEnabled
    public static String getDeliveredDocuments(Id applicationId) {
        Map<ID, ID> contentVersionsToUpdateIdWithLinkedEntity = new Map<ID, ID>();
        Map<Id, String> applicationDocumentCategoriesById = new  Map<Id, String>();
        Integer numberOfDocument = 1;
        String zipToDownloadId = null;
        Zippex documentsZip = new Zippex();

        try {
            for(TB_Application_Document__c applicationDocument : [
                SELECT TB_Document_Category__c
                FROM TB_Application_Document__c
                WHERE IsDeleted = FALSE
                    AND TB_Active__c = TRUE
                    AND TB_Anonymisation_Status__c != :TB_Constants.TB_APP_DOCUMENT_ANONYMISATION_STATUS_ANONYMIZED
                    AND TB_Application__c = :applicationId
                    AND TB_Document_Type__c = :TB_Constants.TB_APP_DOCUMENT_TYPE_SCAN
                    AND TB_Document_Category__c != :TB_Constants.TB_APP_DOCUMENT_TYPE_PHOTO
                    AND TB_Status__c = :TB_Constants.TB_APP_DOCUMENT_STATUS_VERIFIED
                ])
            {
                applicationDocumentCategoriesById.put(applicationDocument.Id, applicationDocument.TB_Document_Category__c);
            }

            ID previousLinkedEntity = null;
            ID previousVersionId = null;
            for(ContentDocumentLink documentLink : [SELECT ContentDocument.LatestPublishedVersionId, ContentDocument.ContentModifiedDate, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :applicationDocumentCategoriesById.keySet() ORDER BY LinkedEntityId, ContentDocument.ContentModifiedDate DESC]){
                if(documentLink.LinkedEntityId != previousLinkedEntity || previousLinkedEntity == null){
                    contentVersionsToUpdateIdWithLinkedEntity.put(documentLink.ContentDocument.LatestPublishedVersionId, documentLink.LinkedEntityId);
                }

                previousLinkedEntity = documentLink.LinkedEntityId;
                previousVersionId = documentLink.ContentDocument.LatestPublishedVersionId;
            }

            hed__Application__c application = [SELECT Name, hed__Applicant__r.FirstName, hed__Applicant__r.LastName FROM hed__Application__c WHERE Id = :applicationId];
            String documentsName = String.valueOf(application.Name + '_' + application.hed__Applicant__r.FirstName + '_' + application.hed__Applicant__r.LastName);
            String documentsNameNormalized = TB_StringUtils.stripPolishAccents(documentsName);

            for(ContentVersion contentVersionToReturn :[SELECT VersionData, FileExtension FROM ContentVersion WHERE ID IN :contentVersionsToUpdateIdWithLinkedEntity.keySet()]){
                String fileExtention = contentVersionToReturn.FileExtension;
                String documentName = String.valueOf(numberOfDocument) + '_' + documentsNameNormalized + '_' + TB_StringUtils.stripPolishAccents(applicationDocumentCategoriesById.get(contentVersionsToUpdateIdWithLinkedEntity.get(contentVersionToReturn.ID)));

                if(fileExtention != null){
                    documentName += ('.' + fileExtention);
                }
                
                documentsZip.addFile(documentName, contentVersionToReturn.VersionData, null);
                numberOfDocument++;
            }

            if(numberOfDocument != 1){
                ContentVersion zipFileContentVersion = new ContentVersion(
                    Title = documentsName,
                    VersionData = documentsZip.getZipArchive(),
                    PathOnClient = documentsName + '.zip'
                );
    
                insert zipFileContentVersion;
                zipToDownloadId = zipFileContentVersion.id;
            } else {
                zipToDownloadId = null;
            }
        } catch(Exception e){
            insert TB_LogUtils.registerLog(e);
        }
        return zipToDownloadId;
    }

    @AuraEnabled
    public static String getApplicationDocumentType(Id documentId) {
        try {
            return [SELECT TB_Document_Type__c FROM TB_Application_Document__c WHERE ID = :documentId LIMIT 1].TB_Document_Type__c;
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    @AuraEnabled
    public static String getNonGeneratedDocument(Id recordId){
        ContentVersion contVerFile = new ContentVersion();
        TB_Application_Document__c applicationDocument = new TB_Application_Document__c();

        try {
            applicationDocument = [
                SELECT TB_Application__c, TB_Document_Template__c,
                    TB_Application__r.hed__Applicant__r.TB_Communication_Language__c,
                    TB_Application__r.TB_Communication_Language__c,
                    TB_Document_Name_EN__c, TB_Document_Name_PL__c, TB_Document_Category__c,
                    TB_Document_File_Name__c
                FROM TB_Application_Document__c
                WHERE ID = :recordId
                LIMIT 1
            ];

            if(applicationDocument.TB_Document_Template__c != null) {
                ID documentTemplateId = applicationDocument.TB_Document_Template__c;

                ContentDocumentLink link = [
                    SELECT ContentDocumentId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId = :documentTemplateId
                    ORDER BY ContentDocument.CreatedDate DESC
                    LIMIT 1
                ];

                ContentVersion contVerFileBefore = [
                    SELECT VersionData
                    FROM ContentVersion
                    WHERE ContentDocumentId = :link.ContentDocumentId
                    AND IsLatest = TRUE
                    LIMIT 1
                ];
                contVerFile.VersionData = contVerFileBefore.VersionData;
                contVerFile.Title = applicationDocument.TB_Document_File_Name__c;
                contVerFile.PathOnClient = applicationDocument.TB_Document_File_Name__c + '.pdf';
                contVerFile.TB_Application_Document__c = recordId;

                Database.insert(contVerFile);
                return contVerFile.Id;

            }else {
                List<ContentDocumentLink> links = [
                    SELECT Id, ContentDocumentId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId = :recordId
                    ORDER BY ContentDocument.CreatedDate DESC
                ];

                Set<Id> ids = new Set<Id>();
                for(ContentDocumentLink singleLink : links) {
                    ids.add(singleLink.ContentDocumentId);
                }

                ContentVersion contentVersion = [
                    SELECT Id, TB_Application_Document__c
                    FROM ContentVersion
                    WHERE ContentDocumentId IN: ids
                    AND TB_Application_Document__c =: recordId
                    AND IsLatest = TRUE
                    ORDER BY LastModifiedDate DESC
                    LIMIT 1
                ];
                return  contentVersion.Id;
            }

        } catch (Exception e){
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    @AuraEnabled
    public static Id getApplicantPhoto(Id applicationId){
        try {
            return [
                SELECT TB_Content_Version_Id__c
                FROM TB_Application_Document__c
                WHERE TB_Document_Category__c = : TB_Constants.TB_APP_DOCUMENT_TYPE_PHOTO
                AND TB_Application__c = :applicationId
                AND TB_Status__c != :TB_Constants.TB_APP_DOCUMENT_STATUS_EMPTY
                LIMIT 1
            ].TB_Content_Version_Id__c;
        } catch(Exception e){
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    @AuraEnabled
    public static Id getNewestApplicantPhoto(Id contactId){
        List<Id> applicationIds = new List<Id>();
        List<Id> applicationDocumentPhotosIds = new List<Id>();
        
        try {
            for (hed__Application__c app : [
                SELECT ID
                FROM hed__Application__c
                WHERE hed__Applicant__c = :contactId
                LIMIT 50000
            ])
            {
                applicationIds.add(app.Id);
            }

            for(TB_Application_Document__c appDocument : [SELECT ID FROM TB_Application_Document__c WHERE TB_Document_Category__c = :TB_Constants.TB_APP_DOCUMENT_TYPE_PHOTO
                AND TB_Application__c IN :applicationIds AND TB_Status__c != :TB_Constants.TB_APP_DOCUMENT_STATUS_EMPTY])
            {
                applicationDocumentPhotosIds.add(appDocument.Id);
            }

            ContentDocumentLink photoLink = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId in :applicationDocumentPhotosIds
                ORDER BY ContentDocument.LastModifiedDate DESC
                LIMIT 1
            ];

            ContentVersion photoVersion = [
                SELECT ID
                FROM ContentVersion
                WHERE ContentDocumentId = :photoLink.ContentDocumentId
                AND IsLatest = true
                LIMIT 1
            ];

            return photoVersion.Id;
        } catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }
}