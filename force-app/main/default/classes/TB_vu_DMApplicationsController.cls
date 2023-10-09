public with sharing class TB_vu_DMApplicationsController
{
    private static final String POLISH_LANGUAGE_CODE = 'pl';
    private static final String SWPS_STUDENT_PROFILE = 'SWPS Student';
    
    public class CommentWrapper
    {
        @AuraEnabled public TB_Operation__c comment;
        @AuraEnabled public Boolean isStudent;
        @AuraEnabled public Boolean isDecision;
        @AuraEnabled public String createdByName;
        @AuraEnabled public List<ContentVersion> commentContentVersions;

        public CommentWrapper(TB_Operation__c comment, Boolean isStudent, Boolean isDecision, String createdByName, List<ContentVersion> commentContentVersions)
        {
            this.comment = comment;
            this.isStudent = isStudent;
            this.isDecision = isDecision;
            this.createdByName = createdByName;
            this.commentContentVersions = commentContentVersions;
        }
    }
    
    public class CaseWrapper
    {
        @AuraEnabled public Id caseId;
        @AuraEnabled public List<CommentWrapper> caseComments;
        @AuraEnabled public String subject;
        @AuraEnabled public String contactName;
        @AuraEnabled public String albumNumber;
        @AuraEnabled public String category;
        @AuraEnabled public String subCategory;
        @AuraEnabled public String studyName;
        @AuraEnabled public Datetime createdDate;
        @AuraEnabled public Datetime lastActivityDate;
        @AuraEnabled public String createdDateFormatted;
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String parentCaseNumber;
        @AuraEnabled public String status;
        @AuraEnabled public String description;
        @AuraEnabled public String descriptionPlain;
        @AuraEnabled public Boolean isAwaitingCSS;
        @AuraEnabled public Boolean isDecision;
        @AuraEnabled public Boolean decisionUnavailable;
    }
    
    @AuraEnabled
    public static List<CaseWrapper> fetchCaseWrappers(Id contactId)
    {
        List<TB_Operation__c> decisionRequests = getDecisionRequests(contactId);
        return prepareCaseWrappers(decisionRequests);
    }
    
    private static List<CaseWrapper> prepareCaseWrappers(List<TB_Operation__c> decisionRequests)
    {
        List<Id> caseIds = new List<Id>();
        for(TB_Operation__c dR : decisionRequests)
        {
            caseIds.add(dR.TB_Case__c);
        }
        List<CaseWrapper> resultWrappers = new List<CaseWrapper>();
        if(!caseIds.isEmpty())
        {
            Map<Id,TB_Operation__c> caseIdsToInitialRecords = new Map<Id,TB_Operation__c>();

            for(TB_Operation__c iR :[
                SELECT 
                    Id, TB_Case__c, TB_Parent_Case_Number__c, CreatedDate, TB_Author__c, TB_Description_Rich_Text__c, TB_Initial__c,
                    TB_Decision__c, TB_Is_Decision__c, TB_Type__c, TB_Decision_Maker_Name__c, CreatedById,
                    TB_Case_Subject__c, TB_Contact_Name__c, toLabel(TB_Case_Category__c),
                    toLabel(TB_Case_Subcategory__c), TB_Case_Study_Name_With_Attributes_EN__c, TB_Case_Study_Name_With_Attributes_PL__c,
                    TB_Album_Number__c, TB_Case_Created_Date__c, TB_Case_Number__c, TB_Case_Status__c, TB_Case__r.TB_Last_Activity_Date__c,
                    TB_Description__c, TB_Awaiting_CSS__c
                FROM TB_Operation__c
                WHERE TB_Case__c IN: caseIds
                AND TB_Initial__c = true
            ]){
                caseIdsToInitialRecords.put(iR.TB_Case__c, iR);
            }

            for (TB_Operation__c dR : decisionRequests){
                CaseWrapper wrapper = new CaseWrapper();
                TB_Operation__c caseDataSource = caseIdsToInitialRecords.get(dR.TB_Case__c) == null ? dR : caseIdsToInitialRecords.get(dR.TB_Case__c);

                wrapper.caseId = caseDataSource.TB_Case__c;
                wrapper.subject = String.isNotBlank(caseDataSource.TB_Case_Subcategory__c) ?  caseDataSource.TB_Case_Category__c + ' - ' + caseDataSource.TB_Case_Subcategory__c : caseDataSource.TB_Case_Category__c;
                wrapper.contactName = caseDataSource.TB_Contact_Name__c;
                wrapper.albumNumber = caseDataSource.TB_Album_Number__c;
                wrapper.category = caseDataSource.TB_Case_Category__c;
                wrapper.subCategory = caseDataSource.TB_Case_Subcategory__c;
                wrapper.studyName = UserInfo.getLanguage() == POLISH_LANGUAGE_CODE ? caseDataSource.TB_Case_Study_Name_With_Attributes_PL__c : caseDataSource.TB_Case_Study_Name_With_Attributes_EN__c;
                wrapper.createdDate = caseDataSource.CreatedDate;
                wrapper.createdDateFormatted = formatDate(wrapper.createdDate);
                wrapper.lastActivityDate = caseDataSource.TB_Case__r.TB_Last_Activity_Date__c == null ? caseDataSource.CreatedDate : caseDataSource.TB_Case__r.TB_Last_Activity_Date__c;
                wrapper.caseNumber = caseDataSource.TB_Case_Number__c;
                wrapper.parentCaseNumber = caseDataSource.TB_Parent_Case_Number__c;
                wrapper.status = caseDataSource.TB_Case_Status__c;
                wrapper.description = caseDataSource.TB_Description_Rich_Text__c;
                wrapper.descriptionPlain = caseDataSource.TB_Description__c;
                wrapper.isAwaitingCSS = caseDataSource.TB_Awaiting_CSS__c;
                wrapper.isDecision = dR.TB_Is_Decision__c;
                wrapper.decisionUnavailable = caseDataSource.TB_Awaiting_CSS__c && caseDataSource.TB_Initial__c;
                resultWrappers.add(wrapper);
            }
        }
        return resultWrappers;
    }

    private static String formatDate(DateTime d) {
        String month = d.month() < 10 ? '0' + String.valueOf(d.month()) : String.valueOf(d.month());
        return d.day() + '.' + month + '.' + d.year();
    }

    @AuraEnabled
    public static List<CommentWrapper> fetchCaseComments(Id caseId)
    {
        try{
            List<CommentWrapper> caseCommentsToCaseId = new List<CommentWrapper>();
            List<TB_Operation__c> allCaseComments = getAllOperations(caseId);
            List<Id> commentIds = new List<Id>();
            for(TB_Operation__c op : allCaseComments)
            {
                commentIds.add(op.Id);
            }
        
            List<Id> userIds = getCommentUserIds(allCaseComments);
            Map<Id, Boolean> userIdToIsStudent = new WithoutSharing().userIdToIsStudent(userIds);
            Map<Id, String> userIdToName = new WithoutSharing().userIdToName(userIds);
            
            Map<Id, List<ContentVersion>> commentIdToContentVersions = getContentVersionsByParentIds(commentIds);
            for (TB_Operation__c comment : allCaseComments)
            {
                caseCommentsToCaseId.add(new CommentWrapper(
                        comment,
                        userIdToIsStudent.get(comment.CreatedById),
                        comment.TB_Is_Decision__c && comment.TB_Type__c == 'Decision',
                        userIdToName.get(comment.CreatedById),
                        commentIdToContentVersions.get(comment.Id)
                ));
            }
            return caseCommentsToCaseId;
        }
        catch(Exception e)
        {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_DMApplicationsController.class.getName(),e.getStackTraceString(), caseId));
        }

    }
    
    private static List<TB_Operation__c> getDecisionRequests(Id contactId)
    {
        return
        [
                SELECT Id, TB_Case__c, TB_Parent_Case_Number__c, CreatedDate, TB_Author__c, TB_Description_Rich_Text__c, TB_Initial__c,
                        TB_Decision__c, TB_Is_Decision__c, TB_Type__c, TB_Decision_Maker_Name__c, CreatedById,
                        TB_Case_Subject__c, TB_Contact_Name__c, toLabel(TB_Case_Category__c),
                        toLabel(TB_Case_Subcategory__c), TB_Case_Study_Name_With_Attributes_EN__c, TB_Case_Study_Name_With_Attributes_PL__c,
                        TB_Album_Number__c, TB_Case_Created_Date__c, TB_Case_Number__c, TB_Case_Status__c, TB_Case__r.TB_Last_Activity_Date__c,
                        TB_Description__c, TB_Awaiting_CSS__c
                FROM TB_Operation__c
                WHERE TB_Case__c != NULL
                AND RecordType.DeveloperName = 'TB_Decision'
                AND TB_Type__c = 'Request_For_A_Decision'
                AND TB_Decision_Maker__c = :contactId
        ];
    }
    
    private static List<TB_Operation__c> getAllOperations(Id caseId)
    {
        return
        [
                SELECT Id, TB_Case__c, TB_Parent_Case_Number__c, CreatedDate, TB_Author__c, TB_Description_Rich_Text__c, TB_Initial__c,
                        TB_Decision__c, TB_Is_Decision__c, TB_Type__c, TB_Decision_Maker_Name__c, CreatedById,
                        TB_Case_Subject__c, TB_Contact_Name__c, toLabel(TB_Case_Category__c),
                        toLabel(TB_Case_Subcategory__c), TB_Case_Study_Name_With_Attributes_EN__c, TB_Case_Study_Name_With_Attributes_PL__c,
                        TB_Album_Number__c, TB_Case_Created_Date__c, TB_Case_Number__c, TB_Case_Status__c,
                        TB_Description__c, TB_Awaiting_CSS__c
                FROM TB_Operation__c
                WHERE TB_Case__c =: caseId
        ];
        
    }
    
    private static Map<Id, List<ContentVersion>> getContentVersionsByParentIds(List<Id> recordIds)
    {
        Map<Id, List<ContentVersion>> idToContentVersions = new Map<Id, List<ContentVersion>>();
        List<ContentDocumentLink> contentDocumentLinks = getContentLinks(recordIds);
        
        Set<Id> allVersionIds = new Set<Id>();
        for (ContentDocumentLink link : contentDocumentLinks)
        {
            allVersionIds.add(link.ContentDocument.LatestPublishedVersionId);
        }
        
        Map<Id, ContentVersion> allContentIdToVersions = new Map<Id, ContentVersion>([
                SELECT FileExtension, ContentSize, Title
                FROM ContentVersion
                WHERE Id IN :allVersionIds
                AND TB_Category__c != 'Student_Application'
                AND TB_Category__c != 'Student_Application_Decision'
        ]);
        
        for (ContentDocumentLink link : contentDocumentLinks)
        {
            Id versionId = link.ContentDocument.LatestPublishedVersionId;
            if (idToContentVersions.get(link.LinkedEntityId) == null)
            {
                idToContentVersions.put(link.LinkedEntityId, new List<ContentVersion>{allContentIdToVersions.get(versionId)});
            }
            else
            {
                idToContentVersions.get(link.LinkedEntityId).add(allContentIdToVersions.get(versionId));
            }
        }
        return idToContentVersions;
    }
    
    private static List<ContentDocumentLink> getContentLinks(List<Id> linkedEntityIds)
    {
        List<ContentDocumentLink> contentLinks = [
                SELECT ContentDocumentId, LinkedEntityId, ContentDocument.LatestPublishedVersionId
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN :linkedEntityIds
                ORDER BY SystemModstamp DESC
                LIMIT 1000
        ];
        return contentLinks;
    }
    
    private static List<Id> getCommentUserIds(List<TB_Operation__c> comments) {
        List<Id> userIds = new List<Id>();
        for (TB_Operation__c comment : comments) {
            userIds.add(comment.CreatedById);
        }
        return userIds;
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