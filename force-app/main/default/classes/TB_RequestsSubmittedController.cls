/**
 * Created by annaseveryna on 06/12/2021.
 */
public with sharing class TB_RequestsSubmittedController {
    private static final String APPLICATION_REQUEST_RECORD_TYPE = 'TB_Application_Request_Case';

    @AuraEnabled
    public static List<Case> loadSubmittedRequests(Id contactId) {
        if (contactId != null) {
            List<Case> requests = [
                    SELECT TB_Application__r.Name, TB_Application__r.TB_Product_Name__c, Subject, Status, CreatedDate, Description, TB_Document__c, TB_Document__r.TB_Download_URL__c, TB_Document__r.Name, TB_Application__r.TB_Applying_To_Offered_Product__r.Name
                    FROM Case
                    WHERE RecordType.DeveloperName = :APPLICATION_REQUEST_RECORD_TYPE AND TB_Application__r.hed__Applicant__c = :contactId
                    ORDER BY CreatedDate DESC
            ];
            return requests;
        } else {
            throw new AuraHandledException('Parameters cannot be null');
        }
    }

    public class CaseCommentWrapper {
        @AuraEnabled public CaseComment comment;
        @AuraEnabled public Boolean isOutboundComment;
        public CaseCommentWrapper(CaseComment comment, Boolean isOutboundComment) {
            this.comment = comment;
            this.isOutboundComment = isOutboundComment;
        }
    }

    @AuraEnabled
    public static List<CaseCommentWrapper> getCaseComments(Id requestId) {
        if (requestId != null) {
            List<CaseComment> caseComments = [
                    SELECT CommentBody, ParentId, CreatedDate, CreatedById
                    FROM CaseComment
                    WHERE ParentId = :requestId
                    ORDER BY CreatedDate DESC
            ];
            Set<Id> userIds = new Set<Id>();
            for (CaseComment comment : caseComments) {
                userIds.add(comment.CreatedById);
            }
            Map<Id, Boolean> userIdToIsOutboundUser = TB_RequestSubmittedControllerSharingSkip.userIdToIsOutboundUser(userIds);
            List<CaseCommentWrapper> caseCommentWrappers = new List<CaseCommentWrapper>();
            for (CaseComment comment : caseComments) {
                caseCommentWrappers.add(new CaseCommentWrapper(comment, userIdToIsOutboundUser.get(comment.CreatedById)));
            }
            return caseCommentWrappers;
        } else {
            throw new AuraHandledException('Parameters cannot be null');
        }
    }

    @AuraEnabled
    public static void insertComment(Id requestCaseId, String comment) {
        if (comment != null || !String.isBlank(comment)) {
            CaseComment caseComment = new CaseComment(
                    CommentBody = comment,
                    ParentId = requestCaseId,
                    IsPublished = true
            );
            insert caseComment;
        } else {
            throw new AuraHandledException('Comment content cannot be empty');
        }
    }
}