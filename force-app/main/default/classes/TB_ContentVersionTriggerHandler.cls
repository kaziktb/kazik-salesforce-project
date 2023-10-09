public inherited sharing class TB_ContentVersionTriggerHandler extends TB_TriggerHandler {
    private List<ContentVersion> newList = (List<ContentVersion>) Trigger.new;
    private Map<Id, ContentVersion> newMap = (Map<Id, ContentVersion>) Trigger.newMap;

    public override void afterInsert() {
        if(!newList[0].TB_Is_From_ZIP_Generator__c){
            addApplicationDocumentLink();
        } else {
            prepareZipWithDeliveredDocuments();
        }
    }

    public void prepareZipWithDeliveredDocuments() {
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
                    AND TB_Application__c = :newList[0].TB_Application_Id__c
                    AND TB_Document_Type__c = :TB_Constants.TB_APP_DOCUMENT_TYPE_SCAN
                    AND TB_Document_Category__c != :TB_Constants.TB_APP_DOCUMENT_TYPE_PHOTO
                    AND TB_Status__c = :TB_Constants.TB_APP_DOCUMENT_STATUS_VERIFIED
                ])
            {
                applicationDocumentCategoriesById.put(applicationDocument.Id, applicationDocument.TB_Document_Category__c);
            }

            if(applicationDocumentCategoriesById.size() > 0){
                ID previousLinkedEntity = null;
                ID previousVersionId = null;
                for(ContentDocumentLink documentLink : [SELECT ContentDocument.LatestPublishedVersionId, ContentDocument.ContentModifiedDate, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :applicationDocumentCategoriesById.keySet() ORDER BY LinkedEntityId, ContentDocument.ContentModifiedDate DESC]){
                    if(documentLink.LinkedEntityId != previousLinkedEntity || previousLinkedEntity == null){
                        contentVersionsToUpdateIdWithLinkedEntity.put(documentLink.ContentDocument.LatestPublishedVersionId, documentLink.LinkedEntityId);
                    }
                    previousLinkedEntity = documentLink.LinkedEntityId;
                    previousVersionId = documentLink.ContentDocument.LatestPublishedVersionId;
                }
    
                String documentsNameNormalized = TB_StringUtils.stripPolishAccents(newList[0].Title);
    
                for(ContentVersion contentVersionToReturn :[SELECT VersionData, FileExtension FROM ContentVersion WHERE ID IN :contentVersionsToUpdateIdWithLinkedEntity.keySet()]){
                    String fileExtention = contentVersionToReturn.FileExtension;
                    String documentName = String.valueOf(numberOfDocument) + TB_Constants.TB_SEPARATOR_UNDERSCORE + documentsNameNormalized + TB_Constants.TB_SEPARATOR_UNDERSCORE + TB_StringUtils.stripPolishAccents(applicationDocumentCategoriesById.get(contentVersionsToUpdateIdWithLinkedEntity.get(contentVersionToReturn.ID)));

                    if(fileExtention != null){
                        documentName += (TB_Constants.TB_SEPARATOR_FULL_STOP + fileExtention);
                    }

                    documentsZip.addFile(documentName, contentVersionToReturn.VersionData, null);
                    numberOfDocument++;
                }
            }

            ContentVersion contentVersionToZip = [SELECT Title, PathOnClient, TB_Application_Id__c FROM ContentVersion WHERE PathOnClient = :newList[0].PathOnClient LIMIT 1];

            if(numberOfDocument != 1){
                contentVersionToZip.TB_Job_Id__c = System.enqueueJob(new TB_GetDeliveredDocumentsZipArchive(contentVersionToZip, documentsZip));
                update contentVersionToZip;
            } else {
                contentVersionToZip.TB_Application_Id__c = null;
                update contentVersionToZip;
            }
        } catch(Exception e){
            insert TB_LogUtils.registerLog(e);
        }
    }

    public override void afterUpdate() {
        if(!newList[0].TB_Is_From_ZIP_Generator__c){
            addApplicationDocumentLink();
        }
        new TB_CT_FileSharingManager(Trigger.new).updateCDLsVisibility();
    }

    private void addApplicationDocumentLink() {
        Map<String, String> appDocumentIdToContentVersionId = TB_SObjectUtils.createFieldToFieldStringMap(newList, ContentVersion.TB_Application_Document__c, ContentVersion.Id);
        appDocumentIdToContentVersionId.remove(null);
        List<TB_Application_Document__c> applicationDocumentsToUpdate = new List<TB_Application_Document__c>();
        List<ContentDocumentLink> contentDocumentLinksToCreate = new List<ContentDocumentLink>();
        for (Id appDocumentId : appDocumentIdToContentVersionId.keySet()) {
            ContentVersion contentVersion = newMap.get(appDocumentIdToContentVersionId.get(appDocumentId));
            //changes
            applicationDocumentsToUpdate.add(new TB_Application_Document__c(
                    Id = appDocumentId,
                    TB_Content_Version_Id__c = appDocumentIdToContentVersionId.get(appDocumentId),
                    TB_Content_Document_Id__c = contentVersion.ContentDocumentId,
                    TB_Status__c = 'To_Verify',
                    TB_Document_File_Date_Time__c = System.today()
            ));

            contentDocumentLinksToCreate.add(new ContentDocumentLink(
                    ContentDocumentId = contentVersion.ContentDocumentId,
                    LinkedEntityId = appDocumentId,
                    ShareType = 'I',
                    Visibility = 'AllUsers'
            ));
        }

        if (Trigger.isInsert) {
            insert contentDocumentLinksToCreate;
        }
        update applicationDocumentsToUpdate;
    }
}