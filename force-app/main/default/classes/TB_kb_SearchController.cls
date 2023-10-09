public with sharing class TB_kb_SearchController {
    private static final String ONLINE_STATUS = TB_kb_Constants.ONLINE_KAV_PUBLISH_STATUS;

    @AuraEnabled
    public static TB_KB_Search_Component_Parameters__c getSearchComponentParameters(){
        return TB_KB_Search_Component_Parameters__c.getOrgDefaults();
    }

    @AuraEnabled
    public static List<SearchResultWrapper> getSearchResults(String searchValue, Boolean searchInContent){
        List<SearchResultWrapper> toReturn = new List<SearchResultWrapper>();
        try {
            String userLanguage = UserInfo.getLanguage();
            if(searchInContent){
                String searchQuery = 
                    'FIND :searchValue RETURNING Knowledge__kav ( '+
                        'Title, TB_Knowledge_Category__c, KnowledgeArticleId ' +
                        'WHERE PublishStatus=: ONLINE_STATUS AND ' +
                        'isLatestVersion = TRUE AND ' +
                        'TB_Knowledge_Category__c != null AND ' +
                        'Language =: userLanguage' +
                    ' )';

                List<List<SObject>> soslResults = search.query(searchQuery);
                if(soslResults[0].size() > 0){
                    for(List<SObject> results : soslResults){
                        for(SObject element : results){
                            Knowledge__kav kav = (Knowledge__kav)element;
                            toReturn.add(
                                new SearchResultWrapper(
                                    kav.KnowledgeArticleId,
                                    kav.TB_Knowledge_Category__c,
                                    kav.Title
                                )
                            );
                        }
                    }
                }
            }
            else{
                for(Knowledge__kav kav : [
                    SELECT 
                        KnowledgeArticleId,
                        Title,
                        TB_Knowledge_Category__c
                    FROM Knowledge__kav 
                    WHERE Title LIKE: '%' + searchValue + '%'
                    AND IsLatestVersion = TRUE 
                    AND PublishStatus =: ONLINE_STATUS
                    AND Language =: userLanguage
                    AND TB_Knowledge_Category__c != null
                ]){
                    toReturn.add(
                        new SearchResultWrapper(
                            kav.KnowledgeArticleId,
                            kav.TB_Knowledge_Category__c,
                            kav.Title
                        )
                    );
                }
            }
            if(toReturn.size() == 0){
                handleNoSearchResultFound(searchValue);
            }
        } catch (Exception e) {
            throw new AuraHandledException(
                TB_vu_Utils.registerLog(e.getMessage(),TB_kb_SearchController.class.getName(),e.getStackTraceString(),UserInfo.getUserId())
            );
        }
        return toReturn;
    }

    private static void handleNoSearchResultFound(String searchValue){
        EventBus.publish(
            new TB_KB_No_Search_Result_Found__e(
                TB_KB_Searched_Phrase__c = searchValue
            )
        );
    }

    public class SearchResultWrapper{
        @AuraEnabled public Id id;
        @AuraEnabled public Id knowledgeCategoryId;
        @AuraEnabled public String title;

        public SearchResultWrapper(Id id, Id knowledgeCategoryId, String title){
            this.id = id;
            this.knowledgeCategoryId = knowledgeCategoryId;
            this.title = title;
        }
    }
}