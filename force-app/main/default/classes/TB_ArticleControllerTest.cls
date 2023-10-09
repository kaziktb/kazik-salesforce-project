@IsTest
private class TB_ArticleControllerTest {

    @TestSetup
    static void testSetup() {
        Contact conTestTrue = TB_TestDataFactory.createContact(false);
        Contact conTestFalse = TB_TestDataFactory.createContact(false);
        conTestTrue.TB_Test__c = true;
        insert new List<Contact>{
                conTestTrue, conTestFalse
        };
        TB_Admissions_Content__c articleWithoutCategory = TB_TestDataFactory.createAdmissionsContent(false, 'Tests1', TB_Constants.TB_ADMISSIONS_CONTENT_CONTENT_TYPE_ARTICLE, null);
        TB_Admissions_Content__c articleWithCategory = TB_TestDataFactory.createAdmissionsContent(false, 'Test2', TB_Constants.TB_ADMISSIONS_CONTENT_CONTENT_TYPE_ARTICLE, null);
        articleWithCategory.TB_Product_Group__c = TB_Constants.TB_ADMISSIONS_CONTENT_PRODUCT_GROUP_HIGHER_EDUCATION;
        TB_Admissions_Content__c nonArticle = TB_TestDataFactory.createAdmissionsContent(false, 'Test3', TB_Constants.TB_ADMISSIONS_CONTENT_CONTENT_TYPE_EXCEPTION, null);
        insert new List<TB_Admissions_Content__c>{
                articleWithCategory, articleWithoutCategory, nonArticle
        };
        TB_Offered_Product__c offeredProduct = TB_TestDataFactory.createOfferedProduct(false);
        offeredProduct.TB_Product_Group__c = TB_Constants.TB_ADMISSIONS_CONTENT_PRODUCT_GROUP_HIGHER_EDUCATION;
        offeredProduct.TB_Level_of_Study__c = 'Bachelor';
        insert offeredProduct;
        TB_TestDataFactory.createAdmissionProcess(true);
    }

    @IsTest
    static void shouldReturnTwoArticleWrapper_whenContactIsTest() {
        //given
        Integer expectedResult = [SELECT ID FROM TB_Admissions_Content__c WHERE TB_Content_Type__c = :TB_Constants.TB_ADMISSIONS_CONTENT_CONTENT_TYPE_ARTICLE].size();
        Id offeredProductId = [SELECT ID From TB_Offered_Product__c].Id;
        Id admissionsProcessId = [SELECT ID From TB_Admissions_Process__c].Id;
        Contact contactIsTest = [SELECT ID, TB_Test__c From Contact WHERE TB_Test__c = TRUE];
        hed__Application__c application = TB_TestDataFactory.createApplication(admissionsProcessId, offeredProductId, false);
        application.TB_Product_Group__c = TB_Constants.TB_ADMISSIONS_CONTENT_PRODUCT_GROUP_HIGHER_EDUCATION;
        application.hed__Applicant__c = contactIsTest.Id;
        insert application;

        //when
        Test.startTest();
        List<TB_ArticleController.ArticleWrapper> articleWrapper = TB_ArticleController.getArticles(TB_Constants.LANGUAGE_PL, contactIsTest.Id, contactIsTest.TB_Test__c);
        Test.stopTest();

        //then
        System.assertEquals(expectedResult, articleWrapper.size(), 'should return 2 Articles');
    }

    @IsTest
    static void shouldReturnNull_whenContactAndLanguageIsNull() {
        //given
        Id offeredProductId = [SELECT ID From TB_Offered_Product__c].Id;
        Id admissionsProcessId = [SELECT ID From TB_Admissions_Process__c].Id;
        Contact contactIsTest = [SELECT ID, TB_Test__c From Contact WHERE TB_Test__c = TRUE];
        hed__Application__c application = TB_TestDataFactory.createApplication(admissionsProcessId, offeredProductId, false);
        application.TB_Product_Group__c = TB_Constants.TB_ADMISSIONS_CONTENT_PRODUCT_GROUP_HIGHER_EDUCATION;
        application.hed__Applicant__c = contactIsTest.Id;
        insert application;

        //when
        Test.startTest();
        List<TB_ArticleController.ArticleWrapper> articleWrapper = new List<TB_ArticleController.ArticleWrapper>();
        try {
            articleWrapper = TB_ArticleController.getArticles(null, contactIsTest.Id, contactIsTest.TB_Test__c);
        } catch (Exception e) {
        }
        Test.stopTest();

        //then
        System.assert(articleWrapper == null, 'Return value from getArticles should be null');
    }

    @IsTest
    static void shouldReturnOneArticleWithoutCategory_whenContactIsNotTest() {
        //given
        Integer expectedResult = [SELECT ID FROM TB_Admissions_Content__c WHERE TB_Product_Group__c = NULL AND TB_Content_Type__c = :TB_Constants.TB_ADMISSIONS_CONTENT_CONTENT_TYPE_ARTICLE].size();
        TB_Offered_Product__c offeredProduct = [SELECT ID From TB_Offered_Product__c];
        offeredProduct.TB_Level_of_Study__c = null;
        offeredProduct.TB_Product_Group__c = TB_Constants.TB_ADMISSIONS_CONTENT_PRODUCT_GROUP_OTHER;
        update offeredProduct;
        Id admissionsProcessId = [SELECT ID From TB_Admissions_Process__c].Id;
        Contact contactIsTest = [SELECT ID, TB_Test__c From Contact WHERE TB_Test__c = FALSE];
        hed__Application__c application = TB_TestDataFactory.createApplication(admissionsProcessId, offeredProduct.Id, false);
        application.TB_Product_Group__c = TB_Constants.TB_ADMISSIONS_CONTENT_PRODUCT_GROUP_HIGHER_EDUCATION;
        application.hed__Applicant__c = contactIsTest.Id;
        insert application;

        //when
        Test.startTest();
        List<TB_ArticleController.ArticleWrapper> articleWrapper = TB_ArticleController.getArticles(TB_Constants.LANGUAGE_PL, contactIsTest.Id, contactIsTest.TB_Test__c);
        Test.stopTest();

        //then
        System.assertEquals(expectedResult, articleWrapper.size(), ' should return only articles without category');
    }

    @IsTest
    static void fetchArticlesPositive() {
        //given
        TB_Admissions_Content__c article = TB_TestDataFactory.createAdmissionsContent(false, 'Tests4', TB_Constants.TB_ADMISSIONS_CONTENT_CONTENT_TYPE_ARTICLE, null);
        article.TB_Active__c = true;
        article.TB_Title_EN__c = 'Test title';
        article.TB_Lead_EN__c = 'Test lead';
        article.TB_Content_EN__c = 'Test content';
        insert article;

        //when
        Test.startTest();
        String articleWrapperValue = TB_ArticleController.fetchArticle(article.Id);
        Test.stopTest();

        //then
        TB_Admissions_Content__c returnedArticle = (TB_Admissions_Content__c) JSON.deserialize(articleWrapperValue, TB_Admissions_Content__c.class);
        System.assertEquals(returnedArticle.TB_Title_EN__c, article.TB_Title_EN__c);
        System.assertEquals(returnedArticle.TB_Lead_EN__c, article.TB_Lead_EN__c);
        System.assertEquals(returnedArticle.TB_Content_EN__c, article.TB_Content_EN__c);
    }

    @IsTest
    static void fetchArticlesNullArgumentNegative() {
        //given
        String articleWrapperValue;

        //when
        Test.startTest();
        try {
            articleWrapperValue = TB_ArticleController.fetchArticle(null);
        } catch (Exception e) {
        }
        Test.stopTest();

        //then
        System.assertEquals(null, articleWrapperValue);
    }

    @IsTest
    static void fetchArticlesNotArticleNegative() {
        //given
        TB_Admissions_Content__c notArticleContent = TB_TestDataFactory.createAdmissionsContent(false, 'Tests5', TB_Constants.TB_ADMISSIONS_CONTENT_CONTENT_TYPE_EXCEPTION, null);
        insert notArticleContent;

        //when
        Test.startTest();
        String articleWrapperValue = TB_ArticleController.fetchArticle(notArticleContent.Id);
        Test.stopTest();

        //then
        System.assertEquals(null, articleWrapperValue);
    }
}