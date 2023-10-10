public with sharing class TB_kb_CategoryController {

    public class ArticleWrapper{
        @AuraEnabled public Id id;
        @AuraEnabled public Id knowledgeCategoryId;
        @AuraEnabled public String title;

        public ArticleWrapper(Knowledge__kav article) {
            this.id = article.KnowledgeArticleId;
            this.knowledgeCategoryId = article.TB_Knowledge_Category__c;
            this.title = article.Title;
        }
    }

    @AuraEnabled
    public static List<ArticleWrapper> getArticles(Id knowledgeCategoryId) {
        TB_Knowledge_Category__c category;
        try {
            category = [
                    SELECT TB_Category_API_Name__c, TB_Parent_Category__r.TB_Category_API_Name__c, TB_Parent_Category__r.TB_Parent_Category__r.TB_Category_API_Name__c
                    FROM TB_Knowledge_Category__c
                    WHERE Id = :knowledgeCategoryId
            ];
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
        String knowledgeCatGroup;
        if(category.TB_Parent_Category__r == null) {
            throw new AuraHandledException('No parent category');
        }
        if(category.TB_Parent_Category__r.TB_Parent_Category__r != null) {
            knowledgeCatGroup = category.TB_Parent_Category__r.TB_Parent_Category__r.TB_Category_API_Name__c;
        } else {
            knowledgeCatGroup = category.TB_Parent_Category__r.TB_Category_API_Name__c;
        }

        String userLanguage = UserInfo.getLanguage();

        List<Knowledge__kav> articlesList = Database.query
                (
                        'SELECT Id, KnowledgeArticleId, TB_Knowledge_Category__c, Title ' +
                        'FROM Knowledge__kav ' +
                        'WHERE PublishStatus = \''+TB_kb_Constants.ONLINE_KAV_PUBLISH_STATUS+'\' ' +
                        'AND IsLatestVersion = TRUE ' +
                        'AND Language =: userLanguage ' +
                        'WITH DATA CATEGORY ' + knowledgeCatGroup + ' ' +
                        'BELOW ' + category.TB_Category_API_Name__c
                );

        List<ArticleWrapper> articlesToWrap = new List<ArticleWrapper>();
        for (Knowledge__kav article : articlesList) {
            articlesToWrap.add(new ArticleWrapper(article));
        }
        return articlesToWrap;
    }
}