@isTest
private class TB_kb_ArticleControllerTest {
    private static final String TEST_EXPRESSION = TB_kb_Constants.TEST_EXPRESSION;
    private static final String INVALID_EXPRESSION = TB_kb_Constants.INVALID_EXPRESSION;

    @TestSetup
    static void makeData(){
        TB_Knowledge_Category__c kc = TB_TestDataFactory.createKnowledgeCategories(1, TEST_EXPRESSION, TB_kb_Constants.ADMISSIONS_KNOWLEDGE_CATEGORY_BUSINESS_OWNER, true)[0];
        Knowledge__kav kav = TB_TestDataFactory.createKnowledgeKavs(1, TEST_EXPRESSION, false)[0];
        kav.TB_Knowledge_Category__c = kc.Id;
        insert kav;        
        ContentVersion cv = TB_TestDataFactory.createContentVersion(true, TEST_EXPRESSION, TEST_EXPRESSION, TEST_EXPRESSION+'.pdf');
    }

    @isTest
    static void shouldGetArticleData() {
        Id knowledgeArticleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Title =: TEST_EXPRESSION LIMIT 1].KnowledgeArticleId;
        User userWithEnLocaleKey = TB_TestDataFactory.prepareUser();
        KbManagement.PublishingService.publishArticle(knowledgeArticleId, true);
        TB_kb_ArticleController.ArticleWrapper result;

        Test.startTest();
        System.runAs(userWithEnLocaleKey) {
            result = TB_kb_ArticleController.getArticleData(knowledgeArticleId);
        }
        Test.stopTest();
    
        Assert.isTrue(result.id != null);
        Assert.isTrue(result.title == TEST_EXPRESSION);
        Assert.isTrue(result.contentVersions == null);
    }

    @isTest
    static void shouldGetArticleDataWithFiles() {
        Knowledge__kav kav = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Title =: TEST_EXPRESSION LIMIT 1];
        ContentVersion cvWithContentDocumentd = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title =: TEST_EXPRESSION LIMIT 1];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cvWithContentDocumentd.ContentDocumentId;
        cdl.LinkedEntityId = kav.Id;
        insert cdl;
        KbManagement.PublishingService.publishArticle(kav.KnowledgeArticleId, true);
        User userWithEnLocaleKey = TB_TestDataFactory.prepareUser();
        TB_kb_ArticleController.ArticleWrapper result;

        Test.startTest();
        System.runAs(userWithEnLocaleKey) {
            result = TB_kb_ArticleController.getArticleData(kav.KnowledgeArticleId);
        }
        Test.stopTest();
    
        Assert.isTrue(result.id != null);
        Assert.isTrue(result.title == TEST_EXPRESSION);
        Assert.isTrue(result.contentVersions.size() == 1);
    }

    @IsTest
    static void throwAnError_whenInvalidIdIsPassed() {
        TB_kb_ArticleController.ArticleWrapper result;
        Boolean errorOccurred;

        Test.startTest();
        try {
            result = TB_kb_ArticleController.getArticleData(INVALID_EXPRESSION);
        } catch (Exception e) {
            errorOccurred = true;
        }
        Test.stopTest();

        Assert.isTrue(errorOccurred);
    }
}