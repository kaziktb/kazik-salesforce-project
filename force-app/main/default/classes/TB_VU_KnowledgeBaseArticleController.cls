public with sharing class TB_VU_KnowledgeBaseArticleController {
    public Id ownerId {get;set;}
    public static final String STATUS_PUBLISHED = 'Online';
    public static final String STATUS_DRAFT = 'Draft';

    public String getOwnerLanguage() {
        try {
        return [SELECT TB_User__c, 
                       TB_User__r.LanguageLocaleKey 
                       FROM Contact 
                       WHERE TB_User__c = :ownerId 
                       LIMIT 1]
                       .TB_User__r.LanguageLocaleKey;
        }catch(System.QueryException e) {
            TB_vu_Utils.registerLog(e.getMessage(),
            TB_VU_KnowledgeBaseArticleController.class.getName(), 
            e.getStackTraceString(),
            ''); 
            return 'pl';       
        }
    }

    public List<Knowledge__kav> getRelatedArticles() {
        TB_Knowledge_Article_Inactivity_Days__c inactiveDaysCS = TB_Knowledge_Article_Inactivity_Days__c.getInstance();
        Integer daysOfInactivity = Integer.valueOf(inactiveDaysCS.TB_KB_Days_Of_Inactivity__c);

        return  [SELECT Title, 
                             TB_Knowledge_Category__r.TB_Category_Name_PL__c,
                             TB_Knowledge_Category__r.TB_Category_Name_EN__c,
                             TB_Last_Activity_Date__c,
                             TB_Days_Of_Inactivity__c,
                             UrlName
                             FROM Knowledge__kav 
                             WHERE OwnerId = :ownerId
                             AND PublishStatus =: STATUS_PUBLISHED
                             AND TB_Days_Of_Inactivity__c >=: daysOfInactivity];
    }

    @AuraEnabled
    public static Id handleSetArticleUpToDate(Id recordId) {
        try {
            Knowledge__kav record = [SELECT Id, 
                                            ArticleNumber,
                                            UrlName, 
                                            KnowledgeArticleId, 
                                            Title,
                                            OwnerId, 
                                            PublishStatus
                                            FROM Knowledge__kav 
                                            WHERE PublishStatus =: STATUS_PUBLISHED
                                            AND Id =: recordId
                                            LIMIT 1];
        String newDraftID =  KbManagement.PublishingService.editOnlineArticle(record.KnowledgeArticleId, false);
        Knowledge__kav articleToRePublish = [SELECT Id,
                                                        KnowledgeArticleId, 
                                                        Title, 
                                                        PublishStatus FROM Knowledge__kav 
                                                        WHERE PublishStatus =: STATUS_DRAFT 
                                                        AND ID =: newDraftID];
        KbManagement.PublishingService.publishArticle(articleToRePublish.KnowledgeArticleId, false);
        Knowledge__kav articleAfterRePublish = [SELECT Id 
                                                       FROM Knowledge__kav 
                                                       WHERE UrlName =: record.UrlName
                                                       AND Title =: record.Title
                                                       AND OwnerId =: record.OwnerId
                                                       AND PublishStatus=: STATUS_PUBLISHED ];

            return articleAfterRePublish.Id;
        } catch(System.QueryException e) {
            throw new AuraHandledException(TB_LogUtils.prepareAuraLog(e.getMessage(), TB_VU_KnowledgeBaseArticleController.class.getName(),e.getStackTraceString(), String.valueOf(recordId)));
        }
    }
}