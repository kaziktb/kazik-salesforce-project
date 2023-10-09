/**
 * Created by Aneta on 27/01/2022.
 */
public with sharing class TB_ApplicationDocumentTriggerHandler extends TB_TriggerHandler {

    public override void beforeUpdate() {
        updateApplicationDocumentStatus(
            (Map<Id,TB_Application_Document__c>)Trigger.newMap,
            (Map<Id,TB_Application_Document__c>)Trigger.oldMap);
    }

    private void updateApplicationDocumentStatus(Map<Id, TB_Application_Document__c> newMap, Map<Id, TB_Application_Document__c> oldMap) {
        for(TB_Application_Document__c singleDocument : newMap.values()) {
            if(singleDocument.TB_Document_Category__c == TB_Constants.TB_APP_DOCUMENT_CATEGORY_STUDY_AGREEMENT_ELECTRONIC
                && singleDocument.TB_Status__c == TB_Constants.TB_APP_DOCUMENT_STATUS_TO_VERIFY
                && singleDocument.TB_Status__c != oldMap.get(singleDocument.Id).TB_Status__c
                && singleDocument.TB_Document_Type__c == TB_Constants.TB_APP_DOCUMENT_TYPE_ELECTRONIC
            ) {
                singleDocument.TB_Status__c = TB_Constants.TB_APP_DOCUMENT_STATUS_CONCLUDED;
            }
        }
    }
}