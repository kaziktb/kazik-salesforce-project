public with sharing class TB_vu_NotificationsController {

    public class CaseWrapper {
        @AuraEnabled public Id caseId;
        @AuraEnabled public String contactName;
        @AuraEnabled public String subject;
        @AuraEnabled public String type;
        @AuraEnabled public String subtype;
        @AuraEnabled public String programEnrollment;
        @AuraEnabled public Datetime createdDate;
        @AuraEnabled public String createdByName;
        @AuraEnabled public Datetime lastActivityDate;
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String status;
        @AuraEnabled public String description;
        @AuraEnabled public String descriptionPlain;
        @AuraEnabled public Boolean showDownloadButton;
        @AuraEnabled public List<ContentVersion> contentVersions;
        @AuraEnabled public String downloadFileHref;
    }

    @AuraEnabled
    public static List<CaseWrapper> fetchCaseWrappers(Id contactId) {
        List<Case> cases = fetchCases(contactId);
        return prepareCaseWrappers(cases);
    }

    private static List<CaseWrapper> prepareCaseWrappers(List<Case> cases) {
        List<Id> caseIds = new List<Id>();
        for (Case c : cases) {
            caseIds.add(c.Id);
        }
        List<CaseWrapper> resultWrappers = new List<CaseWrapper>();
        if (caseIds.size() > 0) {
            Map<Id, List<ContentVersion>> caseIdsToContentVersion = getIdToContentVersions(caseIds);
            Map<Id, String> downloadFileHrefs = getDownloadFileHrefs(caseIds);
            for (Case c : cases) {
                CaseWrapper wrapper = new CaseWrapper();
                wrapper.caseId = c.Id;
                wrapper.contactName = c.Contact.TB_x_Contact_Name__c;
                wrapper.subject = c.Subject;
                wrapper.type = c.TB_Category__c;
                wrapper.subtype = c.TB_Subcategory__c;
                wrapper.programEnrollment = UserInfo.getLanguage() == TB_vu_Constants.LANGUAGE_POLISH ? c.TB_Program_Enrollment__r.TB_Study_Name_With_Attributes_PL__c : c.TB_Program_Enrollment__r.TB_Study_Name_With_Attributes_EN__c;
                wrapper.createdDate = c.CreatedDate;
                wrapper.lastActivityDate = c.TB_Last_Activity_Date__c == null ? c.CreatedDate : c.TB_Last_Activity_Date__c;
                wrapper.caseNumber = c.CaseNumber;
                wrapper.createdByName = c.CreatedBy.Contact.TB_x_Contact_Name__c;
                wrapper.status = c.TB_Status_For_Student__c;
                wrapper.description = c.TB_Description_Rich_Text__c;
                wrapper.descriptionPlain = c.Description;
                wrapper.showDownloadButton = c.TB_Available_To_Download__c;
                wrapper.contentVersions = caseIdsToContentVersion.get(c.Id);
                wrapper.downloadFileHref = c.TB_Available_To_Download__c ? downloadFileHrefs.get(c.Id) : null;
                resultWrappers.add(wrapper);
            }
        }
        return resultWrappers;
    }

    @AuraEnabled
    public static List<Case> fetchCases(Id contactId) {
        try {
            return [
                SELECT Id, CaseNumber, Contact.TB_x_Contact_Name__c, Subject, toLabel(TB_Category__c), toLabel(TB_Subcategory__c), TB_Program_Enrollment__r.TB_Study_Name_With_Attributes_PL__c,
                    TB_Program_Enrollment__r.TB_Study_Name_With_Attributes_EN__c, toLabel(TB_Status_For_Student__c), CreatedDate, CreatedBy.Contact.TB_x_Contact_Name__c,
                    CreatedById, Description, TB_Description_Rich_Text__c, ClosedDate, IsClosed, TB_Last_Activity_Date__c, TB_Available_To_Download__c
                FROM Case
                WHERE ContactId =: contactId AND RecordType.DeveloperName =: TB_vu_Constants.NOTIFICATION_CASE_RECORD_TYPE_DEVELOPER_NAME
                ORDER BY TB_Last_Activity_Date__c DESC
            ];
        } catch (Exception e) {
            throw new AuraHandledException(
                TB_vu_Utils.registerLog(e.getMessage(),TB_vu_NotificationsController.class.getName(),e.getStackTraceString(), contactId)
            );
        }
    }

    private static Map<Id, List<ContentVersion>> getIdToContentVersions(List<Id> ids) {
        Map<Id, List<ContentVersion>> idToContentVersions = new Map<Id, List<ContentVersion>>();
        List<ContentDocumentLink> contentDocumentLinks = getContentLinks(ids);

        Set<Id> allVersionIds = new Set<Id>();

        for (ContentDocumentLink link : contentDocumentLinks) {
            allVersionIds.add(link.ContentDocument.LatestPublishedVersionId);

        }
        Map<Id, ContentVersion> allContentIdToVersions = new Map<Id, ContentVersion>([
            SELECT FileExtension, ContentSize, Title, TB_Case_Comment__c
            FROM ContentVersion
            WHERE Id IN :allVersionIds AND TB_Category__c =: TB_vu_Constants.CASE_ATTACHMENT_CONTENT_VERSION_CATEGORY
        ]);

        for (ContentDocumentLink link : contentDocumentLinks) {
            Id versionId = link.ContentDocument.LatestPublishedVersionId;
            if (idToContentVersions.get(link.LinkedEntityId) == null) {
                idToContentVersions.put(link.LinkedEntityId, new List<ContentVersion>{
                    allContentIdToVersions.get(versionId)
                });
            } else {
                idToContentVersions.get(link.LinkedEntityId).add(allContentIdToVersions.get(versionId));
            }
        }
        return idToContentVersions;
    }

    private static List<ContentDocumentLink> getContentLinks(List<Id> linkedEntityIds) {
        List<ContentDocumentLink> contentLinks = [
            SELECT ContentDocumentId, LinkedEntityId, ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :linkedEntityIds
            ORDER BY SystemModstamp DESC
            LIMIT 1000
        ];
        return contentLinks;
    }

    private static Map<Id,String> getDownloadFileHrefs(List<String> caseIds) {
        try {
            Map<Id, String> toReturn = new Map<Id,String>();
            for(ContentDocumentLink cdl :[
                SELECT
                    LinkedEntityId,
                    ContentDocument.LatestPublishedVersion.contentDocumentId
                FROM ContentDocumentLink
                WHERE
                    LinkedEntityId IN :caseIds AND 
                    ContentDocument.LatestPublishedVersion.TB_Category__c = :TB_vu_Constants.STUDENT_NOTIFICATION_CONTENT_VERSION_CATEGORY
                ORDER BY ContentDocument.LatestPublishedVersion.LastModifiedDate DESC
                
            ]){
                toReturn.put(cdl.LinkedEntityId, TB_Constants.DOWNLOAD_FILE_HREF + cdl.ContentDocument.LatestPublishedVersion.ContentDocumentId);
            }

            return toReturn;
        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_NotificationsController.class.getName(),e.getStackTraceString(),''));
        }
    }
}