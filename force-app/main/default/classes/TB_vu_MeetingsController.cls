public with sharing class TB_vu_MeetingsController
{
    private static final String POLISH_LANGUAGE_CODE = 'pl';
    private static final String CONVERSATION_RECORD_TYPE = 'TB_Conversation';
    private static final String EXTERNAL_COMMENT_TYPE = 'External_Comment';
    private static final String STUDENT_AUTHOR = 'Student';
    private static final String SWPS_STUDENT_PROFILE = 'SWPS Student';
    private static final List<String> STATUSES = new List<String>{'New', 'In_Progress', 'Awaiting_Date_Confirmation', 'Awaiting_Student', 'Abandoned', 'Meeting_Booked', 'Rejected'};

    public class CommentWrapper {
        @AuraEnabled public TB_Operation__c comment;
        @AuraEnabled public Boolean isStudent;
        @AuraEnabled public String createdByName;
        @AuraEnabled public List<ContentVersion> commentContentVersions;

        public CommentWrapper(TB_Operation__c comment, Boolean isStudent, String createdByName, List<ContentVersion> commentContentVersions) {
            this.comment = comment;
            this.isStudent = isStudent;
            this.createdByName = createdByName;
            this.commentContentVersions = commentContentVersions;
        }
    }

    public class CaseWrapper {
        @AuraEnabled public Id caseId;
        @AuraEnabled public Id ownerId;
        @AuraEnabled public String subject;
        @AuraEnabled public String category;
        @AuraEnabled public String topic;
        @AuraEnabled public String programEnrollment;
        @AuraEnabled public Datetime createdDate;
        @AuraEnabled public Datetime lastActivityDate;
        @AuraEnabled public Datetime meetingDateTime;
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String status;
        @AuraEnabled public String priorStatus;
        @AuraEnabled public Boolean createdByStudent;
        @AuraEnabled public Boolean showReplyButton;
        @AuraEnabled public Boolean showCancelButton;
        @AuraEnabled public Boolean showBookButton;
        @AuraEnabled public String reservationId;
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
            Map<Id, Boolean> userIdToIsStudent = new WithoutSharing().userIdToIsStudent(userIds);

            for (Case c : cases) {
                CaseWrapper wrapper = new CaseWrapper();
                wrapper.caseId = c.Id;
                wrapper.ownerId = c.OwnerId;
                wrapper.category = c.TB_Category__c;
                wrapper.topic = UserInfo.getLanguage() == POLISH_LANGUAGE_CODE ? c.sfal__Topic__r.TB_Topic_PL__c : c.sfal__Topic__r.TB_Topic_EN__c;
                wrapper.subject = wrapper.topic;
                wrapper.programEnrollment = UserInfo.getLanguage() == POLISH_LANGUAGE_CODE ? c.TB_Program_Enrollment__r.TB_Study_Name_With_Attributes_PL__c : c.TB_Program_Enrollment__r.TB_Study_Name_With_Attributes_EN__c;
                wrapper.createdDate = c.CreatedDate;
                wrapper.meetingDateTime = c.TB_Meeting_DateTime__c;
                wrapper.caseNumber = c.CaseNumber;
                wrapper.status = c.TB_Status_For_Student__c;
                wrapper.priorStatus = c.TB_Prior_Status__c;
                wrapper.lastActivityDate = c.TB_Last_Activity_Date__c == null ? c.CreatedDate : c.TB_Last_Activity_Date__c;
                wrapper.createdByStudent = userIdToIsStudent.get(c.CreatedById);
                wrapper.showReplyButton = c.TB_Available_To_Reply__c;
                wrapper.showCancelButton = c.TB_Available_To_Cancel__c;
                wrapper.showBookButton = c.TB_Available_To_Book__c;
                wrapper.reservationId = c.TB_QMS_Reservation__c;
                resultWrappers.add(wrapper);
            }
        }
        return resultWrappers;
    }

    private static Map<Id, List<ContentVersion>> getIdToContentVersions(List<Id> ids) {
        Map<Id, List<ContentVersion>> idToContentVersions = new Map<Id, List<ContentVersion>>();
        List<ContentDocumentLink> contentDocumentLinks = getContentLinks(ids);
        if(contentDocumentLinks.isEmpty()) {
            return idToContentVersions;
        }
        Set<Id> allVersionIds = new Set<Id>();

        for (ContentDocumentLink link : contentDocumentLinks) {
            allVersionIds.add(link.ContentDocument.LatestPublishedVersionId);
        }

        Map<Id, ContentVersion> allContentIdToVersions = new Map<Id, ContentVersion>([
                SELECT FileExtension, ContentSize, Title
                FROM ContentVersion
                WHERE Id IN :allVersionIds
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
            return
            [
                    SELECT
                            Id, OwnerId, Parent.CaseNumber, CaseNumber, Subject, toLabel(TB_Category__c),
                            TB_Program_Enrollment__r.TB_Study_Name_With_Attributes_PL__c, sfal__Topic__r.TB_Topic_PL__c,
                            sfal__Topic__r.TB_Topic_EN__c, TB_Program_Enrollment__r.TB_Study_Name_With_Attributes_EN__c,
                            CreatedDate, IsClosed, TB_Available_To_Reply__c, TB_Status_For_Student__c,
                            TB_Available_To_Cancel__c, TB_Last_Activity_Date__c, CreatedById, TB_Available_To_Book__c,
                            TB_Meeting_DateTime__c, TB_QMS_Reservation__c, TB_Prior_Status__c
                    FROM Case
                    WHERE
                            ContactId = :contactId
                            AND RecordType.DeveloperName =: TB_vu_Constants.MEETING_CASE_RECORD_TYPE_DEVELOPER_NAME
                            AND TB_Status_For_Student__c IN :STATUSES
                            AND Case.Origin =: TB_vu_Constants.VIRTUAL_UNIVERSITY_CASE_ORIGIN
                    ORDER BY TB_Last_Activity_Date__c DESC
            ];
        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_MeetingsController.class.getName(),e.getStackTraceString(),contactId));
        }
    }

    @AuraEnabled
    public static List<CommentWrapper> fetchCaseComments(Id caseId) {
        try {
            List<CommentWrapper> commentWrappers = new List<CommentWrapper>();
            List<TB_Operation__c> comments = [
                    SELECT TB_Description_Rich_Text__c, CreatedById, CreatedDate, TB_Case__c
                    FROM TB_Operation__c
                    WHERE TB_Case__c = :caseId AND (TB_Author__c = 'Student' OR TB_Publish__c = TRUE) 
                    ORDER BY CreatedDate
            ];

            List<Id> caseCommentIds = new List<Id> ();
            for (TB_Operation__c comment : comments) {
                caseCommentIds.add(comment.Id);
            }

            Map<Id, List<ContentVersion>> commentIdToContentVersions = getIdToContentVersions(caseCommentIds);

            List<Id> userIds = getCommentUserIds(comments);
            Map<Id, Boolean> userIdToIsStudent = new WithoutSharing().userIdToIsStudent(userIds);
            Map<Id, String> userIdToName = new WithoutSharing().userIdToName(userIds);

            for (TB_Operation__c comment : comments) {
                commentWrappers.add(
                        new CommentWrapper(
                                comment,
                                userIdToIsStudent.get(comment.CreatedById),
                                userIdToName.get(comment.CreatedById),
                                commentIdToContentVersions.get(comment.Id)
                        )
                );
            }
            return commentWrappers;
        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_MeetingsController.class.getName(),e.getStackTraceString(),caseId));
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

    @AuraEnabled
    public static Id createCaseComment(Id caseId, Id contactId, String comment) {
        try {
            Id recordTypeId = Schema.SObjectType.TB_Operation__c.getRecordTypeInfosByDeveloperName().get(CONVERSATION_RECORD_TYPE).getRecordTypeId();

            TB_Operation__c newComment = new TB_Operation__c(
                    RecordTypeId = recordTypeId,
                    TB_Case__c = caseId,
                    TB_Contact__c = contactId,
                    TB_Description_Rich_Text__c = comment,
                    TB_Publish__c = true,
                    TB_Type__c = EXTERNAL_COMMENT_TYPE,
                    TB_Author__c = STUDENT_AUTHOR
            );
            insert newComment;
            return newComment.Id;
        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_MeetingsController.class.getName(),e.getStackTraceString(),caseId));
        }
    }

    private static List<ContentDocumentLink> getContentLinks(List<Id> linkedEntityIds) {
        List<ContentDocumentLink> contentLinks = new List<ContentDocumentLink>();
        if(!linkedEntityIds.isEmpty()) {
            contentLinks = [
                    SELECT ContentDocumentId, LinkedEntityId, ContentDocument.LatestPublishedVersionId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId IN :linkedEntityIds
                    ORDER BY SystemModstamp DESC
                    LIMIT 1000
            ];
        }
        return contentLinks;
    }

    @TestVisible
    private without sharing class WithoutSharing
    {
        @TestVisible
        Map<Id, Boolean> userIdToIsStudent(List<Id> userIds)
        {
            Profile studentProfile = [
                    SELECT Id
                    FROM Profile
                    WHERE Name = :SWPS_STUDENT_PROFILE
            ];
            Map<Id, Boolean> userIdToIsStudent = new Map<Id, Boolean>();
            for (User user : [
                    SELECT ProfileId
                    FROM User WHERE Id IN :userIds
            ])
            {
                Boolean isStudent = user.ProfileId == studentProfile.Id;
                userIdToIsStudent.put(user.Id, isStudent);
            }
            return userIdToIsStudent;
        }

        @TestVisible
        Map<Id, String> userIdToName(List<Id> userIds)
        {
            Map<Id, String> idToName = new Map<Id, String>();
            for (User u : [SELECT FirstName, LastName FROM User WHERE Id IN :userIds])
            {
                String name = u.FirstName + ' ' + u.LastName;
                idToName.put(u.Id, name);
            }
            return idToName;
        }
    }
}