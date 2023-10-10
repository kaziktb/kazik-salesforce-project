/**
 * Created by Aneta on 15/07/2021.
 */

public with sharing class TB_FilesListViewController {
    @AuraEnabled
    public static List<ContentVersionWrapper> getFilesForRecordId(String recordId) {
        List<ContentVersionWrapper> result=null;
        List<TB_Employee_Evaluation_Stage_Document__c> employeeEvaluationStageDocuments;

        String recordType =  Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        String query =  'SELECT Id ';
        query+= 'FROM TB_Employee_Evaluation_Stage_Document__c ';
        query+= 'WHERE ' + recordType +'=: recordId';

        try {
            employeeEvaluationStageDocuments = Database.query(query);
            if(!employeeEvaluationStageDocuments.isEmpty()) {
                result = getFiles(employeeEvaluationStageDocuments);
            }
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
        }

        return result;
    }

    private static List<ContentVersionWrapper> getFiles(List<TB_Employee_Evaluation_Stage_Document__c> employeeEvaluationStageDocuments) {
        try {
            Set<Id> stageDocumentIds = new Set<Id>();
            for (TB_Employee_Evaluation_Stage_Document__c stageDocument : employeeEvaluationStageDocuments) {
                stageDocumentIds.add(stageDocument.Id);
            }
            Set<Id> contentDocumentIds = new Set<Id>();
            for (ContentDocumentLink contentDocumentLink : [
                SELECT Id, ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN :stageDocumentIds
            ]) {
                contentDocumentIds.add(contentDocumentLink.ContentDocumentId);
            }

            List<ContentVersion> contentVersions = [
                SELECT Title, ContentDocumentId, ContentDocument.CreatedBy.Name,
                    ContentDocument.ContentSize, ContentDocument.FileType, ContentDocument.LatestPublishedVersionId
                FROM ContentVersion
                WHERE ContentDocumentId IN :contentDocumentIds
            ];

            List<ContentDistribution> contentDistribution = [
                SELECT Id,ContentVersionId, ContentDownloadUrl
                FROM ContentDistribution
                WHERE ContentVersionId IN :contentVersions
            ];

            Map<Id,ContentDistribution> contentsForVersionId = new Map<Id,ContentDistribution>();
            for(ContentDistribution singleDistribution : contentDistribution) {
                contentsForVersionId.put(singleDistribution.ContentVersionId,singleDistribution);
            }

            List<ContentDistribution> contentDistributionsToInsert = new List<ContentDistribution>();
            for(ContentVersion singleContent : contentVersions) {
                if(!contentsForVersionId.containsKey(singleContent.Id)){
                    ContentDistribution singleDistribution = prepareContentDistributions(singleContent);
                    contentDistributionsToInsert.add(singleDistribution);
                }
            }

            try {
                insert contentDistributionsToInsert;
            }catch(Exception e) {
                insert TB_LogUtils.registerLog(e);
            }

            List<ContentDistribution> receivedDistributions = [
                SELECT Id,ContentVersionId, ContentDownloadUrl, DistributionPublicUrl
                FROM ContentDistribution
                WHERE ContentVersionId IN :contentVersions
            ];

            List<ContentVersionWrapper> contentVersionWrappers = new List<ContentVersionWrapper>();

            for(ContentDistribution singleDistribution : receivedDistributions) {
                for(ContentVersion singleVersion : contentVersions) {
                    if(singleDistribution.ContentVersionId == singleVersion.Id) {
                        ContentVersionWrapper wrapper = new ContentVersionWrapper(singleVersion, singleDistribution);
                        contentVersionWrappers.add(wrapper);
                    }
                }
            }
            return contentVersionWrappers;

        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }


    private static ContentDistribution prepareContentDistributions(ContentVersion contentVersion){
        ContentDistribution contentDistribution = new ContentDistribution();
        contentDistribution.Name = contentVersion.Id;
        contentDistribution.ContentVersionId = contentVersion.Id;
        contentDistribution.PreferencesAllowViewInBrowser = true;
        contentDistribution.PreferencesLinkLatestVersion = true;
        contentDistribution.PreferencesNotifyOnVisit = false;
        contentDistribution.PreferencesPasswordRequired = false;
        contentDistribution.PreferencesAllowOriginalDownload = true;
        return contentDistribution;
    }

    @AuraEnabled
    public static Boolean deleteFile(String contentDocumentId) {

        Database.DeleteResult deleteResult;

        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        Set<Id> stageIds = new Set<Id>();
        try {
            contentDocumentLinks = [
                SELECT Id, LinkedEntityId
                FROM ContentDocumentLink
                WHERE ContentDocumentId = :contentDocumentId
            ];

            for(ContentDocumentLink singleDocumentLink : contentDocumentLinks) {
                String objectType =  Id.valueOf(singleDocumentLink.LinkedEntityId).getSObjectType().getDescribe().getName();
                if(objectType == 'TB_Employee_Evaluation_Stage_Document__c'){
                    stageIds.add(singleDocumentLink.LinkedEntityId);
                }
            }
            deleteResult = Database.delete(contentDocumentId);
        }catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return false;
        }

        List<ContentDocumentLink> contentDocumentLinkedEntities = [
            SELECT Id, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :stageIds
        ];

        for(Id singleStageId : stageIds) {
            List<ContentDocumentLink> stageWithLinks = new List<ContentDocumentLink>();
            for(ContentDocumentLink singleDocumentLink : contentDocumentLinkedEntities) {
                if(singleDocumentLink.LinkedEntityId == singleStageId) {
                    stageWithLinks.add(singleDocumentLink);
                }
            }
            if(stageWithLinks.size()<1) {
                try {
                    deleteResult = Database.delete(singleStageId);
                } catch (Exception e) {
                    insert TB_LogUtils.registerLog(e);
                }
            }
        }
        return deleteResult.isSuccess();
    }

    @AuraEnabled(cacheable=true)
    public static String getLoginURL() {
        String baseURL = System.Url.getSalesforceBaseUrl().toExternalForm();
        User userRecord = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        if (userRecord.ContactId != null) {
            baseUrl = getExperienceURL();
        }
        return baseUrl;
    }

    public static String getExperienceURL() {
        String baseUrl = '';
        baseUrl += Network.getLoginUrl(Network.getNetworkId());
        baseUrl =  baseUrl.replace('/s/login', '');
        baseUrl =  baseUrl.replace('/s/Login', '');
        baseUrl =  baseUrl.replace('/login', '');
        baseUrl =  baseUrl.replace('/Login', '');
        return baseUrl;
    }

    public class ContentVersionWrapper {
        @AuraEnabled public ContentVersion cntVersion {get;set;}
        @AuraEnabled public ContentDistribution cntDistribution {get;set;}

        public ContentVersionWrapper(ContentVersion contentVersion, ContentDistribution contentDistribution) {
            this.cntVersion = contentVersion;
            this.cntDistribution = contentDistribution;
        }
    }
}