public without sharing class TB_vu_CaseCommentsController {
    private static final String SWPS_STUDENT_PROFILE = 'SWPS Student';
    private static final String APPLICATION_RECORD_TYPE = 'TB_Student_Application_HE';

    public class CommentWrapper {
        @AuraEnabled public TB_Operation__c comment;
        @AuraEnabled public List<ContentVersion> contentVersions;
        @AuraEnabled public Boolean isStudent;
        @AuraEnabled public String createdByName;
        @AuraEnabled public Boolean isApplication;

        public CommentWrapper(TB_Operation__c comment, List<ContentVersion> contentVersions, Boolean isStudent, String createdByName, Boolean isApplication) {
            this.comment = comment;
            this.contentVersions = contentVersions;
            this.isStudent = isStudent;
            this.createdByName = createdByName;
            this.isApplication = isApplication;
        }
    }

    @AuraEnabled
    public static List<CommentWrapper> getCaseComments(Id caseId){
        try {
            List<CommentWrapper> commentWrappers = new List<CommentWrapper>();
            List<TB_Operation__c> comments = [
                SELECT
                    Id,
                    Name,
                    TB_Description_Rich_Text__c, 
                    TB_Contact_Name__c,
                    TB_Album_Number__c,
                    CreatedDate,
                    CreatedById, 
                    TB_Case__r.RecordType.DeveloperName,
                    TB_Is_Decision__c,
                    TB_Type__c,
                    toLabel(TB_Author__c),
                    toLabel(TB_Authorisation_Of__c),
                    RecordTypeId,
                    TB_Publish__c,
                    TB_Decision_Maker_Name__c
                FROM TB_Operation__c
                WHERE TB_Case__c = :caseId
                ORDER BY CreatedDate
            ];

            if(comments.size() > 0){
                List<Id> commentIds = new List<Id> ();
                for (TB_Operation__c comment : comments) {
                    commentIds.add(comment.Id);
                }
    
                List<Id> userIds = getCommentUserIds(comments);
                Map<Id, Boolean> userIdToIsStudent = new WithoutSharing().userIdToIsStudent(userIds);
                Map<Id, String> userIdToName = new WithoutSharing().userIdToName(userIds);
    
                Map<Id, List<ContentVersion>> commentIdToContentVersions = getIdToContentVersions(commentIds);
    
                for (TB_Operation__c comment : comments) {
                    commentWrappers.add(
                        new CommentWrapper(
                            comment,
                            commentIdToContentVersions.get(comment.Id) == null ? null : commentIdToContentVersions.get(comment.Id),
                            userIdToIsStudent.get(comment.CreatedById),
                            userIdToName.get(comment.CreatedById),
                            comment.TB_Case__r.RecordType.DeveloperName == APPLICATION_RECORD_TYPE
                        )
                    );
                }
            }

            return commentWrappers;

        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_CaseCommentsController.class.getName(),e.getStackTraceString(), caseId));
        }
    }

    private static List<Id> getCommentUserIds(List<TB_Operation__c> comments) {
        List<Id> userIds = new List<Id>();
        for (TB_Operation__c comment : comments) {
            userIds.add(comment.CreatedById);
        }
        return userIds;
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

    private without sharing class WithoutSharing
    {
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