public with sharing class TB_vu_ApplicationsController {
    private static final String POLISH_LANGUAGE_CODE = 'pl';
    private static final String STUDENT_AUTHOR = 'Student';
    private static final String APPLICATION_RECORD_TYPE = 'TB_Student_Application_HE';
    private static final String CONTENT_VERSION_CATEGORY = 'Student_Application_Decision';
    private static final String DECISION_TYPE = 'Decision';
    private static final String DECISION_MAKER_AUTHOR = 'Decision_Maker';

    public class CaseWrapper {
        @AuraEnabled public Id caseId;
        @AuraEnabled public String parentCaseNumber;
        @AuraEnabled public String subject;
        @AuraEnabled public String type;
        @AuraEnabled public String subtype;
        @AuraEnabled public String programEnrollment;
        @AuraEnabled public Datetime createdDate;
        @AuraEnabled public Datetime lastActivityDate;
        @AuraEnabled public String lastActivityDateFormatted;
        @AuraEnabled public String createdDateFormatted;
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String status;
        @AuraEnabled public String description;
        @AuraEnabled public String descriptionPlain;
        @AuraEnabled public String decisionFileHref;
        @AuraEnabled public Boolean createdByStudent;
        @AuraEnabled public Boolean showReplyButton;
        @AuraEnabled public Boolean showCancelButton;
        @AuraEnabled public Boolean showAppealButton;
        @AuraEnabled public Boolean showDownloadButton;
    }

    public class CommentWrapper {
        @AuraEnabled public TB_Operation__c comment;
        @AuraEnabled public Boolean isStudent;
        @AuraEnabled public Boolean isDecision;
        @AuraEnabled public String createdByName;
        @AuraEnabled public List<ContentVersion> commentContentVersions;

        public CommentWrapper(TB_Operation__c comment, Boolean isStudent, Boolean isDecision, String createdByName, List<ContentVersion> commentContentVersions) {
            this.comment = comment;
            this.isStudent = isStudent;
            this.isDecision = isDecision;
            this.createdByName = createdByName;
            this.commentContentVersions = commentContentVersions;
        }
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
            List<Id> userIds = getCaseUserIds(cases);
            Map<Id, Boolean> userIdToIsStudent = TB_vu_QuestionsControllerSharingSkip.userIdToIsStudent(userIds);
            Map<Id, String> decisionFileHrefs = getDecisionFileHrefs(caseIds);
            for (Case c : cases) {
                CaseWrapper wrapper = new CaseWrapper();
                wrapper.caseId = c.Id;
                wrapper.parentCaseNumber = c.Parent.CaseNumber;
                wrapper.subject = String.isNotBlank(c.TB_Subcategory__c) ?  c.TB_Category__c + ' - ' + c.TB_Subcategory__c : c.TB_Category__c;
                wrapper.type = c.TB_Category__c;
                wrapper.subtype = c.TB_Subcategory__c;
                wrapper.programEnrollment = UserInfo.getLanguage() == POLISH_LANGUAGE_CODE ? c.TB_Program_Enrollment__r.TB_Study_Name_With_Attributes_PL__c : c.TB_Program_Enrollment__r.TB_Study_Name_With_Attributes_EN__c;
                wrapper.createdDate = c.CreatedDate;
                wrapper.caseNumber = c.CaseNumber;
                wrapper.status = c.TB_Status_For_Student__c;
                wrapper.description = c.TB_Description_Rich_Text__c;
                wrapper.descriptionPlain = c.Description;
                wrapper.lastActivityDate = c.TB_Last_Activity_Date__c == null ? c.CreatedDate : c.TB_Last_Activity_Date__c;
                wrapper.lastActivityDateFormatted = formatDate(wrapper.lastActivityDate);
                wrapper.createdDateFormatted = formatDate(wrapper.createdDate);
                wrapper.createdByStudent = userIdToIsStudent.get(c.CreatedById);
                wrapper.showReplyButton = c.TB_Available_To_Reply__c;
                wrapper.showCancelButton = c.TB_Available_To_Cancel__c;
                wrapper.showAppealButton = c.TB_Available_To_Appeal__c;
                wrapper.showDownloadButton = c.TB_Available_To_Download__c;
                wrapper.decisionFileHref = c.TB_Available_To_Download__c ? decisionFileHrefs.get(c.Id) : null;
                resultWrappers.add(wrapper);
            }
        }
        return resultWrappers;
    }

    private static String formatDate(DateTime d) {
        String month = d.month() < 10 ? '0' + String.valueOf(d.month()) : String.valueOf(d.month());
        return d.day() + '.' + month + '.' + d.year();
    }

    private static Map<Id, List<ContentVersion>> getIdToContentVersions(List<Id> ids) {
        Map<Id, List<ContentVersion>> idToContentVersions = new Map<Id, List<ContentVersion>>();
        List<ContentDocumentLink> contentDocumentLinks = getContentLinks(ids);

        Set<Id> allVersionIds = new Set<Id>();

        for (ContentDocumentLink link : contentDocumentLinks) {
            allVersionIds.add(link.ContentDocument.LatestPublishedVersionId);

        }
        Map<Id, ContentVersion> allContentIdToVersions = new Map<Id, ContentVersion>([
            SELECT FileExtension, ContentSize, Title
            FROM ContentVersion
            WHERE Id IN :allVersionIds
            AND TB_Category__c != 'Student_Application'
            AND TB_Category__c != 'Student_Application_Decision'
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

    @AuraEnabled
    public static List<Case> fetchCases(Id contactId) {
        try {
            return [
                SELECT Id, Parent.CaseNumber, CaseNumber, Subject, toLabel(TB_Category__c), toLabel(TB_Subcategory__c), TB_Program_Enrollment__r.TB_Study_Name_With_Attributes_PL__c,
                    TB_Program_Enrollment__r.TB_Study_Name_With_Attributes_EN__c, TB_Status_For_Student__c, CreatedDate,
                    CreatedById, LastModifiedDate, Description, TB_Description_Rich_Text__c, TB_Last_Activity_Date__c, ClosedDate, IsClosed,
                    TB_Available_To_Reply__c, TB_Available_To_Cancel__c, TB_Available_To_Appeal__c, TB_Available_To_Download__c
                FROM Case
                WHERE ContactId =: contactId AND RecordType.DeveloperName =: APPLICATION_RECORD_TYPE
                ORDER BY TB_Last_Activity_Date__c DESC
            ];
        } catch (Exception e) {
            throw new AuraHandledException(
                TB_vu_Utils.registerLog(e.getMessage(),TB_vu_ApplicationsController.class.getName(),e.getStackTraceString(),'')
            );
        }
    }

    @AuraEnabled
    public static List<CommentWrapper> fetchCaseComments(Id caseId) {
        try {
            List<CommentWrapper> commentWrappers = new List<CommentWrapper>();
            List<TB_Operation__c> comments = [
                SELECT 
                    TB_Description_Rich_Text__c, 
                    CreatedById, 
                    CreatedDate, 
                    TB_Case__c,
                    TB_Is_Decision__c,
                    TB_Type__c,
                    TB_Author__c,
                    TB_Publish__c,
                    TB_Decision_Maker_Name__c
                FROM TB_Operation__c
                WHERE TB_Case__c = :caseId AND (TB_Author__c =: STUDENT_AUTHOR OR TB_Publish__c = TRUE)
                ORDER BY CreatedDate
            ];

            List<Id> caseCommentIds = new List<Id> ();
            for (TB_Operation__c comment : comments) {
                caseCommentIds.add(comment.Id);
            }

            Map<Id, List<ContentVersion>> commentIdToContentVersions = getIdToContentVersions(caseCommentIds);

            List<Id> userIds = getCommentUserIds(comments);
            Map<Id, Boolean> userIdToIsStudent = TB_vu_QuestionsControllerSharingSkip.userIdToIsStudent(userIds);
            Map<Id, String> userIdToName = TB_vu_QuestionsControllerSharingSkip.userIdToName(userIds);

            for (TB_Operation__c comment : comments) {
                commentWrappers.add(
                    new CommentWrapper(
                        comment,
                        userIdToIsStudent.get(comment.CreatedById),
                        comment.TB_Is_Decision__c && comment.TB_Type__c == DECISION_TYPE && comment.TB_Publish__c,
                        userIdToName.get(comment.CreatedById),
                        commentIdToContentVersions.get(comment.Id)
                    )
                );
            }
            return commentWrappers;
        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_ApplicationsController.class.getName(),e.getStackTraceString(),''));
        }
    }

    private static List<Id> getCommentUserIds(List<TB_Operation__c> comments) {
        List<Id> userIds = new List<Id>();
        for (TB_Operation__c comment : comments) {
            userIds.add(comment.CreatedById);
        }
        return userIds;
    }

    private static List<Id> getCaseUserIds(List<Case> cases) {
        List<Id> userIds = new List<Id>();
        for (Case c : cases) {
            userIds.add(c.CreatedById);
        }
        return userIds;
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


    private static Map<Id,String> getDecisionFileHrefs(List<String> caseIds) {
        try {
            Map<Id, String> toReturn = new Map<Id,String>();
            for(ContentDocumentLink cdl :[
                SELECT
                    LinkedEntityId,
                    ContentDocument.LatestPublishedVersion.ContentDocumentId
                FROM ContentDocumentLink
                WHERE
                    LinkedEntityId IN :caseIds AND
                    ContentDocument.LatestPublishedVersion.TB_Category__c = :CONTENT_VERSION_CATEGORY
                ORDER BY ContentDocument.LatestPublishedVersion.LastModifiedDate DESC
                
            ]){
                toReturn.put(cdl.LinkedEntityId, TB_Constants.DOWNLOAD_FILE_HREF + cdl.ContentDocument.LatestPublishedVersion.ContentDocumentId);
            }

            return toReturn;
        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_StudentOrganizationDetails.class.getName(),e.getStackTraceString(),''));
        }
    }
}