/**
 * Created by Aneta on 18/02/2022.
 */

public with sharing class TB_PDMultiDocumentController {

    @AuraEnabled
    public static String getPDApplicationDocuments(String applicationId) {
        List<String> documentCategories = TB_Constants.TB_PD_DOCUMENT_CATEGORIES;

        try {
            String documentsQuery = prepareApplicationDocumentsQuery();
            documentsQuery += 'WHERE TB_Application__c =: applicationId ' +
                ' AND TB_Experience__c = null ' +
                ' AND TB_Active__c = true ' +
                ' AND TB_Document_Type__c = \'' + TB_Constants.TB_APP_DOCUMENT_TYPE_SCAN + '\'' +
                ' AND TB_Document_Category__c IN: documentCategories' +
                ' ORDER BY CreatedDate';

            List<TB_Application_Document__c> applicationDocuments = Database.query(documentsQuery);
            return JSON.serialize(TB_FileUtils.createFileWrapperForDocuments(applicationDocuments));
        }catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return 'EXCEPTION';
        }
    }
    
    @AuraEnabled
    public static String getNewPDApplicationDocument(String applicationDocumentId) {
        String documentQuery = prepareApplicationDocumentsQuery();
        documentQuery += 'WHERE Id =: applicationDocumentId LIMIT 1';
        try {
            TB_Application_Document__c applicationDocument = Database.query(documentQuery);
            return JSON.serialize(TB_FileUtils.createFileWrapperForDocument(applicationDocument));
        }catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    private static String prepareApplicationDocumentsQuery() {
        return 'SELECT Id, TB_Document_Name_PL__c, TB_Document_Name_EN__c, ' +
            'TB_Document_Category__c, toLabel(TB_Document_Category__c) TB_Document_Category_Label, ' +
            'TB_Status__c, toLabel(TB_Status__c) TB_Status_Label,TB_Comment__c, ' +
            'TB_Download_URL__c, TB_Document_Description_EN__c, TB_Document_Description_PL__c ' +
            'FROM TB_Application_Document__c ';
    }

    @AuraEnabled
    public static String deleteApplicationDocument(String appDocumentId) {

        if(appDocumentId == null) {
            return 'EMPTY_APP_DOCUMENT_ID';
        }
        try {
            List<ContentDocumentLink> documentLinks = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :appDocumentId];
            Set<Id> contentDocumentIds = new Set<Id>();
            for (ContentDocumentLink singleLink : documentLinks) {
                contentDocumentIds.add(singleLink.ContentDocumentId);
            }
            delete [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentIds];
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return 'DELETE_CONTENT_DOCUMENTS_EXCEPTION';
        }

        try {
            delete [SELECT Id FROM TB_Application_Document__c WHERE Id =: appDocumentId];
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return 'DELETE_APPLICATION_DOCUMENT_EXCEPTION';
        }

        return 'SUCCESS';
    }

    @AuraEnabled
    public static String getDocumentsCategory() {
        List<String> values = TB_StringUtils.getPicklistValuesOrLabelsSortedByLabel('TB_Application_Document__c','TB_Document_Category__c','values');
        List<String> labels = TB_StringUtils.getPicklistValuesOrLabelsSortedByLabel('TB_Application_Document__c','TB_Document_Category__c','labels');

        Map<String,String> picklistByApiName = new Map<String,String>();

        for(Integer i = 0; i < values.size(); i ++) {
            if(TB_Constants.TB_PD_DOCUMENT_CATEGORIES.contains(values[i])) {
                picklistByApiName.put(values[i], labels[i]);
            }
        }
        return JSON.serialize(picklistByApiName);
    }

    @AuraEnabled
    public static String createNewApplicationDocumentSlot(String applicationId, String applicantId, String documentCategory, String documentDescription, String stepId, String stageId) {
        try {
            TB_Application_Document__c applicationDocument = new TB_Application_Document__c(
                TB_Application__c = applicationId,
                TB_Status__c = TB_Constants.TB_APP_DOCUMENT_STATUS_EMPTY,
                TB_Order__c = 1000,
                TB_Contact__c = applicantId,
                TB_Document_Category__c = documentCategory,
                TB_Document_Type__c = TB_Constants.TB_APP_DOCUMENT_TYPE_SCAN,
                TB_Output_Format__c = TB_Constants.TB_APP_DOCUMENT_OUTPUT_FORMAT_ORIGINAL,
                TB_Document_Description_EN__c = documentDescription,
                TB_Document_Description_PL__c = documentDescription,
                TB_Step_Id__c = stepId,
                TB_Stage_Id__c = stageId
            );
            insert applicationDocument;

            return JSON.serialize((TB_Application_Document__c) [
                SELECT Id, TB_Document_File_Name__c
                FROM TB_Application_Document__c
                WHERE Id =: applicationDocument.Id
                LIMIT 1
            ]);
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }
}