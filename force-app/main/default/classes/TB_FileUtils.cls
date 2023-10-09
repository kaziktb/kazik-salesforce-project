/**
 * Created by Aneta on 22/11/2021.
 */

public with sharing class TB_FileUtils {

    public static Map<Id,List<TB_Application_Document__c>> getApplicationDocuments(List<Id> lookupIds, String lookupApiName) {

        Map<Id,List<TB_Application_Document__c>> applicationDocumentsMap = new Map<Id,List<TB_Application_Document__c>>();

        List<TB_Application_Document__c> applicationDocuments = [
            SELECT Id, TB_Document_Name_PL__c, TB_Document_Name_EN__c,
                TB_Document_Category__c, toLabel(TB_Document_Category__c) TB_Document_Category_Label,
                TB_Experience__c, TB_Status__c, toLabel(TB_Status__c) TB_Status_Label ,TB_Comment__c,
                TB_Download_URL__c, TB_Content_Document_Id__c, TB_Step_Id__c, TB_Stage_Id__c, TB_Document_File_Name__c
            FROM TB_Application_Document__c
            WHERE TB_Experience__c IN :lookupIds
            AND TB_Active__c = true
        ];

        //todo: if applicationDocuments >0
        for(TB_Application_Document__c singleDocument : applicationDocuments) {
            List<TB_Application_Document__c> singleDocumentsList
                = applicationDocumentsMap.get((String)singleDocument.get(lookupApiName));

            if(singleDocumentsList == null) {
                List<TB_Application_Document__c> newExperienceDocumentList = new List<TB_Application_Document__c>();
                newExperienceDocumentList.add(singleDocument);
                applicationDocumentsMap.put((String)singleDocument.get(lookupApiName),newExperienceDocumentList);
            }else {
                singleDocumentsList.add(singleDocument);
                applicationDocumentsMap.put((String)singleDocument.get(lookupApiName),singleDocumentsList);
            }
        }
        return applicationDocumentsMap;
    }

    public static List<FileWrapper> createFileWrapperForDocuments(List<TB_Application_Document__c> documents) {
        List<FileWrapper> fileWrappers = new List<FileWrapper>();
        if(documents != null) {
            for(TB_Application_Document__c singleDocument : documents) {
                FileWrapper singleFileWrapper = new FileWrapper(singleDocument);
                fileWrappers.add(singleFileWrapper);
            }
            return fileWrappers;
        }else {
            return null;
        }
    }

    public static FileWrapper createFileWrapperForDocument(TB_Application_Document__c document) {
        FileWrapper singleFileWrapper = new FileWrapper(document);
        return singleFileWrapper;
    }

    public class FileWrapper {
        @AuraEnabled public TB_Application_Document__c file {get;set;}
        @AuraEnabled public String statusBadgeClass {get;set;}
        @AuraEnabled public Boolean downloadFlag {get;set;}
        @AuraEnabled public Boolean deleteFlag {get;set;}
        @AuraEnabled public Boolean addFlag {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public Boolean required {get;set;}
        @AuraEnabled public Boolean isComments {get;set;}
        @AuraEnabled public Boolean isLabelCategory {get;set;}

        public FileWrapper(TB_Application_Document__c document) {
            this.file = document;
            this.isComments = !(String.isBlank(document.TB_Comment__c));
            this.isLabelCategory = false;
            switch on document.TB_Status__c {
                when 'Empty' {
                    this.statusBadgeClass = 'slds-badge';
                    this.downloadFlag = false;
                    this.deleteFlag = false;
                    this.addFlag = true;
                    this.isLabelCategory = true;
                }
                when 'To_Verify' {
                    this.statusBadgeClass = 'slds-badge slds-badge_inverse';
                    this.downloadFlag = true;
                    this.deleteFlag = true;
                    this.addFlag = false;
                }
                when 'Verified' {
                    this.statusBadgeClass = 'slds-badge slds-theme_success';
                    this.downloadFlag = true;
                    this.deleteFlag = false;
                    this.addFlag = false;
                }
                when 'To_Correct' {
                    this.statusBadgeClass = 'slds-badge slds-theme_warning';
                    this.downloadFlag = true;
                    this.deleteFlag = true;
                    this.addFlag = false;
                }
                when 'Rejected' {
                    this.statusBadgeClass = 'slds-badge slds-theme_error';
                    this.downloadFlag = true;
                    this.deleteFlag = true;
                    this.addFlag = false;
                }
                when else {
                    this.statusBadgeClass = 'slds-badge';
                }
            }
        }
    }

    @AuraEnabled
    public static String getNewUploadedFileWrapper(Id applicationDocumentId) {
        TB_Application_Document__c applicationDocument = [
            SELECT Id, TB_Document_Name_PL__c, TB_Document_Name_EN__c,
                TB_Document_Category__c, toLabel(TB_Document_Category__c) TB_Document_Category_Label,
                TB_Experience__c, TB_Status__c, toLabel(TB_Status__c) TB_Status_Label ,TB_Comment__c,
                TB_Download_URL__c, TB_Content_Document_Id__c, TB_Step_Id__c, TB_Stage_Id__c, TB_Document_Required__c,
                TB_Document_Description_PL__c, TB_Document_Description_EN__c, TB_Document_Type__c, TB_Document_File_Name__c
            FROM TB_Application_Document__c
            WHERE Id =: applicationDocumentId
        ];
        FileWrapper wrapper = createFileWrapperForDocument(applicationDocument);
        return JSON.serialize(wrapper);
    }

    @AuraEnabled
    public static String deleteApplicationDocument(String appDocumentId) {
        TB_Application_Document__c document = new TB_Application_Document__c();
        document.Id = appDocumentId;
        document.TB_Status__c = 'Empty';
        document.TB_Content_Document_Id__c = '';
        try {
            update document;
            return JSON.serialize(document);
        }catch(Exception e) {
            return 'DELETE_APPLICATION_DOCUMENT.EXCEPTION';
        }
    }

    public static TB_Application_Document__c prepareApplicationDocumentSlot
    (
        TB_Experience_History__c experience, String documentCategory, String stepId, String stageId
    ) {
        TB_Application_Document__c applicationDocument = new TB_Application_Document__c(
            TB_Application__c = experience.TB_Application__c,
            TB_Status__c = 'Empty',
            TB_Citizenship_Dependency__c = 'Everyone',
            TB_Order__c = 1000,
            TB_Document_Category__c = documentCategory,
            TB_Contact__c = experience.TB_Applicant__c,
            TB_Experience__c = experience.Id,
            TB_Document_Type__c = 'Scan',
            TB_Output_Format__c = 'Original'
        );

        if(stepId != null) {
            applicationDocument.TB_Step_Id__c = stepId;
        }

        if(stageId != null) {
            applicationDocument.TB_Stage_Id__c = stageId;
        }
        return applicationDocument;
    }

}