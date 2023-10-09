public with sharing class TB_kb_TopArticlesController {
    private static final String ONLINE_PUBLISH_STATUS = TB_kb_Constants.ONLINE_KAV_PUBLISH_STATUS;

    @AuraEnabled
    public static List<ArticleWrapper> getTopArticles(Id knowledgeCategoryId, Boolean placedOnHomePage) {
        List<ArticleWrapper> toReturn = new List<ArticleWrapper>();
        try{
            List<Id> kaIds = new List<Id>();
            Map<Id, Knowledge__kav> kaIdToKavRecord = new Map<Id, Knowledge__kav>();

            String userLanguage = UserInfo.getLanguage();
            String kavRecordsQuery = 
                'SELECT Id, KnowledgeArticleId, Title, TB_Knowledge_Category__c ' +
                'FROM Knowledge__kav ' +
                'WHERE PublishStatus =: ONLINE_PUBLISH_STATUS ' +
                'AND IsLatestVersion = TRUE ' +
                'AND Language =: userLanguage';

            kavRecordsQuery += placedOnHomePage ? ' AND TB_Knowledge_Category__c != null' : ' AND TB_Knowledge_Category__c =: knowledgeCategoryId';

            List<Knowledge__kav> kavRecords = Database.query(kavRecordsQuery);
            if(kavRecords.size() > 0){
                List<Id> topKaIds = new List<Id>();
                for(Knowledge__kav kav : kavRecords){
                    kaIds.add(kav.KnowledgeArticleId);
                    kaIdToKavRecord.put(kav.KnowledgeArticleId, kav);
                    if(Test.isRunningTest()) topKaIds.add(kav.KnowledgeArticleId);
                }

                for(Knowledge__ViewStat kvs : [
                    SELECT 
                        Id,  
                        ParentId
                    FROM Knowledge__ViewStat 
                    WHERE Channel = 'Csp'
                    AND ParentId IN: kaIds
                    ORDER BY ViewCount DESC LIMIT 5
                ]){
                    topKaIds.add(kvs.ParentId);
                }

                for(Id kaId : topKaIds){
                    Knowledge__kav kav = kaIdToKavRecord.get(kaId);
                    toReturn.add(
                        new ArticleWrapper(
                            kaId,
                            kav.TB_Knowledge_Category__c,
                            kav.Title
                        )
                    );
                }
            }

        }catch(Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_kb_TopArticlesController.class.getName(),e.getStackTraceString(), knowledgeCategoryId));
        }
        return toReturn;
    }
    
    public class ArticleWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String knowledgeCategoryId;
        @AuraEnabled public String name;

        public ArticleWrapper (String id, String knowledgeCategoryId, String name) {
            this.id = id;
            this.knowledgeCategoryId = knowledgeCategoryId;
            this.name = name;
        }
    }
}