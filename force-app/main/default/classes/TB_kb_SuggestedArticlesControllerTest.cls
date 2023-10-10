@isTest
private class TB_kb_SuggestedArticlesControllerTest {
    private static final String TEST_EXPRESSION = TB_kb_Constants.TEST_EXPRESSION;
    private static final String INVALID_EXPRESSION = TB_kb_Constants.INVALID_EXPRESSION;
    private static final String CONTACT_LASTNAME = 'testContact';

    @TestSetup
    static void testSetup(){
        TB_Knowledge_Category__c kc = TB_TestDataFactory.createKnowledgeCategories(1,TEST_EXPRESSION, TB_kb_Constants.ADMISSIONS_KNOWLEDGE_CATEGORY_BUSINESS_OWNER, true)[0];

        TB_Suggested_Article_Group__c sagForCategory = TB_TestDataFactory.createSuggestedArticleGroups(1, TEST_EXPRESSION, kc.Id, TB_kb_Constants.ASSIGNED_TO_SUBCATEGORY_SUGGESTED_ARTICLE_GROUP_RT_DEVNAME, '', true)[0];

        List<TB_Suggested_Article_Group__c> sagsForContactGroups = TB_TestDataFactory.createSuggestedArticleGroups(2, TEST_EXPRESSION, null, TB_kb_Constants.ASSIGNED_TO_CONTACT_GROUP_SUGGESTED_ARTICLE_GROUP_RT_DEVNAME, TB_kb_Constants.HIGHER_EDUCATION_CONTACT_GROUP_SUGGESTED_ARTICLE_GROUP, true);

        Knowledge__kav kav = TB_TestDataFactory.createKnowledgeKavs(1,TEST_EXPRESSION, true)[0];

        Knowledge__kav kavToPublish = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Title =: TEST_EXPRESSION LIMIT 1];
        KbManagement.PublishingService.publishArticle(kavToPublish.KnowledgeArticleId, true);

        TB_Suggested_Article_Group_Element__c sageForCategory = new TB_Suggested_Article_Group_Element__c(
            TB_Suggested_Article_Group__c = sagForCategory.Id,
            TB_Article__c = kav.Id,
            TB_Order__c = 0
        );
        insert sageForCategory;

        List<TB_Suggested_Article_Group_Element__c> sagesForContactGroups = new List<TB_Suggested_Article_Group_Element__c>();
        for(TB_Suggested_Article_Group__c sag : sagsForContactGroups){
            sagesForContactGroups.add(
                new TB_Suggested_Article_Group_Element__c(
                    TB_Suggested_Article_Group__c = sag.Id,
                    TB_Article__c = kav.Id,
                    TB_Order__c = 0
                )
            );
        }
        insert sagesForContactGroups;
        
        Contact c = TB_TestDataFactory.createContact(true);
    }
    
    @isTest
    static void shouldGetSuggestedArticlesAssignedToSubcategory() {
        TB_Knowledge_Category__c kc = [SELECT Id FROM TB_Knowledge_Category__c WHERE TB_Category_API_Name__c LIKE: TEST_EXPRESSION + '%' LIMIT 1];
        List<TB_kb_SuggestedArticlesController.SuggestedArticleWrapper> result;
        User userWithEnglishLocaleKey = TB_TestDataFactory.prepareUser();
        insert userWithEnglishLocaleKey;

        System.runAs(userWithEnglishLocaleKey){
            Test.startTest();
            result = TB_kb_SuggestedArticlesController.getSuggestedArticlesBySubcategoryId(kc.Id);
            Test.stopTest();
        }

        Assert.isTrue(result.size() == 1);
        Assert.isTrue(result[0].id != null);
        Assert.isTrue(result[0].name == TEST_EXPRESSION);
    }

    @isTest
    static void throwAnError_whenInvalidIdIsPassedToGetSuggestedArticlesBySubcategoryId(){
        List<TB_kb_SuggestedArticlesController.SuggestedArticleWrapper> result;
        Boolean isException = false;

        Test.startTest();
        try {
            result = TB_kb_SuggestedArticlesController.getSuggestedArticlesBySubcategoryId(INVALID_EXPRESSION);
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        Assert.isTrue(isException);
    }

    @isTest
    static void shouldNotReturnAnySuggestedArticlesForContact() {
        Contact c = [SELECT Id FROM Contact WHERE LastName =: CONTACT_LASTNAME];
        List<TB_kb_SuggestedArticlesController.SuggestedArticleGroupWrapper> result;
        User userWithEnglishLocaleKey = TB_TestDataFactory.prepareUser();
        insert userWithEnglishLocaleKey;

        System.runAs(userWithEnglishLocaleKey){
            Test.startTest();
            result = TB_kb_SuggestedArticlesController.getSuggestedArticlesByContactGroups(c.Id);
            Test.stopTest();
        }

        Assert.isTrue(result.size() == 0);
    }

    @isTest
    static void shouldReturnSuggestedArticlesForContact() {
        Contact c = [SELECT Id, TB_Student_Counter_HE__c FROM Contact WHERE LastName =: CONTACT_LASTNAME];
        c.TB_Student_Counter_HE__c = 1;
        update c;
        List<TB_kb_SuggestedArticlesController.SuggestedArticleGroupWrapper> result;
        User userWithEnglishLocaleKey = TB_TestDataFactory.prepareUser();
        insert userWithEnglishLocaleKey;

        System.runAs(userWithEnglishLocaleKey){
            Test.startTest();
            result = TB_kb_SuggestedArticlesController.getSuggestedArticlesByContactGroups(c.Id);
            Test.stopTest();
        }

        Assert.isTrue(result.size() == 2);
    }

    @isTest
    static void throwAnError_whenInvalidIdIsPassedToGetSuggestedArticlesByContactGroups(){
        List<TB_kb_SuggestedArticlesController.SuggestedArticleGroupWrapper> result;
        Boolean isException = false;

        Test.startTest();
        try {
            result = TB_kb_SuggestedArticlesController.getSuggestedArticlesByContactGroups(INVALID_EXPRESSION);
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        Assert.isTrue(isException);
    }
}