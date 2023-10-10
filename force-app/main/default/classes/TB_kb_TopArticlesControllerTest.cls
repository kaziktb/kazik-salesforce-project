@isTest
private class TB_kb_TopArticlesControllerTest {
    private static final String TEST_EXPRESSION = 'Test';

    @TestSetup
    static void makeData(){
        List<TB_Knowledge_Category__c> kcToInsert = new List<TB_Knowledge_Category__c>();
        for(Integer i=0; i<2; i++){
            kcToInsert.add(
                new TB_Knowledge_Category__c(
                    Name = TEST_EXPRESSION + i,
                    TB_Category_Api_Name__c = TEST_EXPRESSION + i,
                    TB_Category_Name_PL__c = TEST_EXPRESSION + 'PL',
                    TB_Category_Name_EN__c = TEST_EXPRESSION + 'EN',
                    TB_Business_Owner__c = 'Admissions'
                )
            );
        }
        insert kcToInsert;

        List<Knowledge__kav> kavToInsert = new List<Knowledge__kav>();
        for(Integer i=0; i<2; i++){
            kavToInsert.add(
                new Knowledge__kav(
                    Title = TEST_EXPRESSION + i,
                    UrlName = TEST_EXPRESSION + i + 'url',
                    TB_Knowledge_Category__c = kcToInsert[i].Id,
                    Language = 'en_US'
                )
            );
        }
        insert kavToInsert;
        
        List<Id> kaIds = new List<Id>();
        for(Knowledge__kav kav : [
            SELECT 
                Id,
                KnowledgeArticleId
            FROM Knowledge__kav
            WHERE Title LIKE: TEST_EXPRESSION + '%'
            LIMIT 2
        ]){
            kaIds.add(kav.KnowledgeArticleId);
            KbManagement.PublishingService.publishArticle(kav.KnowledgeArticleId, true);
        }
    }

    @isTest
    static void shouldReturnTopArticlesOnHomePage() {
        List<TB_kb_TopArticlesController.ArticleWrapper> result;
        
        Test.startTest();
        result = TB_kb_TopArticlesController.getTopArticles(null, true);
        Test.stopTest();
        
        Assert.isTrue(result.size() == 2);   
    }

    @isTest
    static void throwAnError_whenComponentIsNotPlacedOnHomePageAndKnowledgeCategoryIdIsInvalid() {
        Boolean errorOccurred = false;
        List<TB_kb_TopArticlesController.ArticleWrapper> result;

        Test.startTest();
        try {
            TB_kb_TopArticlesController.getTopArticles('INVALID', false);
        } catch (Exception e) {
            errorOccurred = true;
        }
        Test.stopTest();

        Assert.isTrue(errorOccurred);
    }
}