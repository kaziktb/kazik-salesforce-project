public with sharing class TB_kb_ArticleController {
    @AuraEnabled
    public static ArticleWrapper getArticleData(Id knowledgeArticleId) {
        ArticleWrapper toReturn;
        try {
            Knowledge__kav kav = [
                SELECT
                    Id,
                    Title,
                    TB_Last_Activity_Date__c,
                    toLabel(TB_Knowledge_Category__r.TB_Business_Owner__c),
                    TB_Content__c
                FROM Knowledge__kav
                WHERE KnowledgeArticleId =: knowledgeArticleId
                AND PublishStatus =: TB_kb_Constants.ONLINE_KAV_PUBLISH_STATUS
                AND IsLatestVersion = TRUE
                AND Language = :UserInfo.getLanguage()
                LIMIT 1
                UPDATE VIEWSTAT
            ];

            if(kav != null){
                toReturn = new ArticleWrapper(
                    kav.Id,
                    kav.Title,
                    formatDate(kav.TB_Last_Activity_Date__c),
                    kav.TB_Knowledge_Category__r.TB_Business_Owner__c,
                    kav.TB_Content__c
                );

                List<Id> cdIds = new List<Id>();
                for(ContentDocumentLink cdl : [
                    SELECT ContentDocumentId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId =: kav.Id
                ]){
                    cdIds.add(cdl.ContentDocumentId);
                }

                if(cdIds.size() > 0){
                    toReturn.contentVersions = [
                        SELECT 
                            Id, 
                            Title, 
                            FileExtension, 
                            ContentSize 
                        FROM ContentVersion 
                        WHERE contentDocumentId IN: cdIds
                        AND isLatest = TRUE
                    ];
                }
            }
        }catch(Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_kb_ArticleController.class.getName(),e.getStackTraceString(), knowledgeArticleId));
        }
        return toReturn;
    }

    private static String formatDate(DateTime d) {
        String month = d.month() < 10 ? '0' + String.valueOf(d.month()) : String.valueOf(d.month());
        return d.day() + '.' + month + '.' + d.year();
    }

    public class ArticleWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String title;
        @AuraEnabled public String lastActivityDate;
        @AuraEnabled public String businessOwner;
        @AuraEnabled public String content;
        @AuraEnabled public List<ContentVersion> contentVersions;
        

        public ArticleWrapper (String id, String title, String lastActivityDate, String businessOwner, String content) {
            this.id = id;
            this.title = title;
            this.lastActivityDate = lastActivityDate;
            this.businessOwner = businessOwner;
            this.content = content;
        }
    }
}