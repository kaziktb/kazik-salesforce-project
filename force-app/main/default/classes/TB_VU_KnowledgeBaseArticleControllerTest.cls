@IsTest
public with sharing class TB_VU_KnowledgeBaseArticleControllerTest {
    private static final String ARTICLE_TITLE = 'Test Article';
    private static final Integer ARTICLE_COUNT = 3;
    private static final String CUSTOM_LASTNAME = 'Custom Admin';

    @TestSetup
    static void makeData(){
        User u = DT_DataFactory.createAdminUser();
        u.UserPermissionsKnowledgeUser = true;
        u.LastName = CUSTOM_LASTNAME;
        u.LanguageLocaleKey = 'en_US';
        update u;
        System.runAs(u) {
            TB_Knowledge_Article_Inactivity_Days__c inactivityDays = new TB_Knowledge_Article_Inactivity_Days__c(TB_KB_Days_Of_Inactivity__c  = 0);   
            insert inactivityDays;

            List<Knowledge__kav> kbArticles = new List<Knowledge__kav>();
            for(Integer i = 0; i < ARTICLE_COUNT; i++) {
                kbArticles.add(new Knowledge__kav(
                        Title = ARTICLE_TITLE + ' ' + i,
                        urlName = 'Test-' + String.valueOf(Crypto.getRandomLong()) + '-' + String.valueOf(i),
                        OwnerId = u.Id
                    ));

                }
            insert kbArticles;

            TB_StaticTest.setDoNotRunTriggers();
            insert new Contact(TB_User__c = u.Id, LastName = CUSTOM_LASTNAME);
            TB_StaticTest.unsetDoNotRunTriggers();
        }
    }

    @IsTest
    static void getOwnerLanguageTest() {
        User u = [SELECT Id FROM User WHERE LastName =: CUSTOM_LASTNAME LIMIT 1];
        String language;

        TB_VU_KnowledgeBaseArticleController controller = new TB_VU_KnowledgeBaseArticleController();
        controller.ownerId = u.Id;
        Test.startTest();
        System.runAs(u) {
            language = controller.getOwnerLanguage();
            system.debug(language);
        }
        Test.stopTest();

        Assert.isFalse(language == null);
        Assert.isTrue(language == 'en_US');
    }

    @IsTest
    static void getRelatedArticlesTest() {
        User u = [SELECT Id FROM User WHERE LastName =: CUSTOM_LASTNAME LIMIT 1];
        TB_StaticTest.setDoNotRunTriggers();
        System.runAs(u) {
            insert new Knowledge__kav(
                    Title = 'Testing',
                    urlName = 'Test-' + String.valueOf(Crypto.getRandomLong()) + '-xxxx',
                    OwnerId = u.Id,
                    TB_Last_Activity_Date__c = System.Today().addDays(-180)
                );
        }

        KbManagement.PublishingService.publishArticle([SELECT KnowledgeArticleId 
                                                       FROM Knowledge__kav 
                                                       WHERE Title = 'Testing' LIMIT 1]
                                                       .KnowledgeArticleId, true);


        TB_VU_KnowledgeBaseArticleController controller = new TB_VU_KnowledgeBaseArticleController();
        controller.ownerId = u.Id;

        Test.startTest();
        List<Knowledge__kav> relatedArticles = controller.getRelatedArticles();

        Test.stopTest();

        System.assertEquals(1, relatedArticles.size(), 'Number of related articles should match');
    }

    @IsTest
    static void handleSetArticleUpToDateTest() {
        Knowledge__kav recordDraft = [SELECT Id, 
                                                KnowledgeArticleId 
                                                FROM Knowledge__kav 
                                                WHERE Title =: ARTICLE_TITLE + ' 1' 
                                                AND PublishStatus = 'Draft' 
                                                LIMIT 1];
        KbManagement.PublishingService.publishArticle(recordDraft.KnowledgeArticleId, true);

        Knowledge__kav recordPublished = [SELECT PublishStatus FROM Knowledge__kav WHERE Id =: recordDraft.Id];
        User u = [SELECT Id FROM User WHERE LastName =: CUSTOM_LASTNAME LIMIT 1];

        Test.startTest();
        System.runAs(u) {
        TB_VU_KnowledgeBaseArticleController.handleSetArticleUpToDate(recordPublished.Id);
        }
        Test.stopTest();
        
        Knowledge__kav recordAfterUpdate = [SELECT Id FROM Knowledge__kav WHERE Title =: ARTICLE_TITLE + ' 1' LIMIT 1];

        Assert.isTrue(recordPublished.PublishStatus == 'Online');
        Assert.areNotEqual(recordPublished.Id, recordAfterUpdate.Id, 'New Version should be created with new Id');
    }
}