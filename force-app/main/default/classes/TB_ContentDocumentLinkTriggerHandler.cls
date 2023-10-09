public with sharing class TB_ContentDocumentLinkTriggerHandler extends TB_TriggerHandler  {

    private static final String CASE_ATTACHMENT_CONTENT_VERSION_CATEGORY = 'Case_Attachment';

    public override void afterInsert() {
        setApplicationDocumentIdOnContentVersion();
        prepareTitleOnContentVersion();
    }

    private void setApplicationDocumentIdOnContentVersion() {
        List<ContentVersion> contentVersionsToUpdate = new List<ContentVersion>();
        for (ContentDocumentLink contentDocumentLink : (List<ContentDocumentLink>) Trigger.new) {
            String linkedObjectType = contentDocumentLink.LinkedEntityId.getSobjectType().getDescribe().getName();
            if (linkedObjectType == 'TB_Application_Document__c') {
                // Don't blame me. It's SF limiation...
                List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion WHERE ContentDocumentId = :contentDocumentLink.ContentDocumentId];
                for (ContentVersion version : contentVersions) {
                    version.TB_Application_Document__c = contentDocumentLink.LinkedEntityId;
                    contentVersionsToUpdate.add(version);
                }
            }
        }

        update contentVersionsToUpdate;
    }

    private void prepareTitleOnContentVersion(){
        List<ContentVersion> contentVersionsToUpdate = new List<ContentVersion>();
        List<Id> operationIds = new List<Id>();
        List<TB_Operation__c> operationsToUpdate = new List<TB_Operation__c>();
        Map<Id,Id> contentDocumentIdsAssignedToOperationIds = new Map<Id,Id>();
        Map<Id,TitleWrapper> operationIdsAssignedToTitle = new Map<Id,TitleWrapper>();

        for(ContentDocumentLink contentDocumentLink : (List<ContentDocumentLink>) Trigger.new){
            if (contentDocumentLink.LinkedEntityId.getSobjectType() == TB_Operation__c.SObjectType) {
                operationIds.add(contentDocumentLink.LinkedEntityId);
                contentDocumentIdsAssignedToOperationIds.put(contentDocumentLink.ContentDocumentId, contentDocumentLink.linkedEntityId);
            }
        }
        for (TB_Operation__c operation : [
            SELECT 
                Id, 
                TB_Contact__r.TB_x_Contact_Name__c, 
                TB_Initial__c,
                TB_Has_Attachment__c,
                Name 
            FROM TB_Operation__c 
            WHERE Id IN: operationIds]){
                TitleWrapper titleWrapperToAdd = new TitleWrapper(
                    '(' + operation.Name + ') ', 
                    operation.TB_Contact__r.TB_x_Contact_Name__c
                );
                operationIdsAssignedToTitle.put(operation.id,titleWrapperToAdd);
                operation.TB_Has_Attachment__c = true;
                operationsToUpdate.add(operation);
            }
        
        for (ContentVersion cv : [
            SELECT 
                Id, 
                Title, 
                ContentDocumentId,
                TB_Category__c
            FROM ContentVersion 
            WHERE ContentDocumentId IN: contentDocumentIdsAssignedToOperationIds.keySet() 
            AND TB_Category__c = null]){
                TitleWrapper titleData = operationIdsAssignedToTitle.get(contentDocumentIdsAssignedToOperationIds.get(cv.ContentDocumentId));
                cv.Title = titleData.operationNumber + cv.Title + ' - ' + titleData.contactName;
                cv.TB_Category__c = CASE_ATTACHMENT_CONTENT_VERSION_CATEGORY;
                contentVersionsToUpdate.add(cv);
        }

        update operationsToUpdate;
        update contentVersionsToUpdate;
    }

    public class TitleWrapper{
        String operationNumber;
        String contactName;
        
        public TitleWrapper(String operationNumber, String contactName){
            this.operationNumber = operationNumber;
            this.contactName = contactName;
        }
    }
}