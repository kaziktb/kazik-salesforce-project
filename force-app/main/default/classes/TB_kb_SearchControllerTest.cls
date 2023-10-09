@isTest
private class TB_kb_SearchControllerTest {
    private static final String TEST_EXPRESSION = TB_kb_Constants.TEST_EXPRESSION;
    private static final String INVALID_EXPRESSION = TB_kb_Constants.INVALID_EXPRESSION;
    private static final String WRONG_TITLE = 'WRONG_TITLE';

    @testSetup
    static void testSetup() {
        TB_Knowledge_Category__c kc = TB_TestDataFactory.createKnowledgeCategories(1, TEST_EXPRESSION, TB_kb_Constants.ADMISSIONS_KNOWLEDGE_CATEGORY_BUSINESS_OWNER, true)[0];
        Knowledge__kav kav = TB_TestDataFactory.createKnowledgeKavs(1, TEST_EXPRESSION, false)[0];
        kav.TB_Knowledge_Category__c = kc.Id;
        insert kav;  
        Id knowledgeArticleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Title =: TEST_EXPRESSION LIMIT 1].KnowledgeArticleId;
        KbManagement.PublishingService.publishArticle(knowledgeArticleId, true);
    
        TB_KB_Search_Component_Parameters__c customSetting = new TB_KB_Search_Component_Parameters__c();
        customSetting.TB_Is_Toggle_Visible__c = true;
        customSetting.TB_Minimum_Number_Of_Characters__c = 5;
        customSetting.TB_Should_Search_In_Content_By_Default__c = true;
        insert customSetting;
    }

    @isTest
    private static void shouldFindArticleByTitle() {
        List<TB_kb_SearchController.SearchResultWrapper> results = new List<TB_kb_SearchController.SearchResultWrapper>();
        User userEN = TB_TestDataFactory.prepareUser();

        Test.startTest();
        System.runAs(userEN) {
            results = TB_kb_SearchController.getSearchResults(TEST_EXPRESSION, false);
        }
        Test.stopTest();
        
        Assert.isTrue(results.size() > 0);
        Assert.isTrue(results[0].title == TEST_EXPRESSION);
    }

    @isTest
    private static void shouldNotFindArticleAndInsertSearchResultRecord() {
        List<TB_kb_SearchController.SearchResultWrapper> results = new List<TB_kb_SearchController.SearchResultWrapper>();
        User userEN = TB_TestDataFactory.prepareUser();

        Test.startTest();
        System.runAs(userEN) {
            results = TB_kb_SearchController.getSearchResults(WRONG_TITLE, false);
        }
        Test.stopTest();
        
        Assert.isTrue(results.size() == 0);
        Assert.isTrue([SELECT Id FROM TB_KB_Search_Result__c WHERE TB_Search_Phrase__c =: WRONG_TITLE].size() > 0);
    }

    @isTest
    private static void shouldFindArticleByContent() {
        List<TB_kb_SearchController.SearchResultWrapper> results = new List<TB_kb_SearchController.SearchResultWrapper>();
        User userEN = TB_TestDataFactory.prepareUser();
        Id kavId = [SELECT Id FROM Knowledge__kav WHERE Title =: TEST_EXPRESSION LIMIT 1].Id;
        
        Test.setFixedSearchResults(new List<Id>{kavId});
        Test.startTest();
        System.runAs(userEN) {
            results = TB_kb_SearchController.getSearchResults('Moim zdaniem to nie ma tak, że dobrze', true);
        }
        Test.stopTest();
    
        Assert.isTrue(results.size() > 0);
        Assert.isTrue(results[0].title == TEST_EXPRESSION);
    }

    @isTest
    private static void shouldReturnSearchComponentParametersCustomSetting() {
        TB_KB_Search_Component_Parameters__c result;
        
        Test.startTest();
        result = TB_kb_SearchController.getSearchComponentParameters();
        Test.stopTest();
    
        Assert.isTrue(result != null);
        Assert.isTrue(result.TB_Is_Toggle_Visible__c);
        Assert.isTrue(result.TB_Should_Search_In_Content_By_Default__c);
        Assert.isTrue(result.TB_Minimum_Number_Of_Characters__c == 5);
    }
}