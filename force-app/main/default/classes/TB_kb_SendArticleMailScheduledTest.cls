@IsTest
public with sharing class TB_kb_SendArticleMailScheduledTest {
    private static final String ARTICLE_TITLE = 'Test Article';
    private static final Integer ARTICLE_COUNT = 3;
    private static final Id CONTACT_EMPLOYEE_RECORD_TYPE_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('TB_Employee').getRecordTypeId();
    private static final String CRON_EXP = '0 02 15 05 APR ? 2045';

    @TestSetup
    static void makeData(){
        User u = DT_DataFactory.createAdminUser();
        u.UserPermissionsKnowledgeUser = true;
        u.LanguageLocaleKey = 'en_US';
        update u;
        System.runAs(u){
            TB_StaticTest.setDoNotRunTriggers();

            insert new Contact(LastName = 'Admin Contact', 
                               TB_User__c = u.Id, 
                               recordTypeId = CONTACT_EMPLOYEE_RECORD_TYPE_ID,
                               hed__WorkEmail__c = 'test@swps.edu.pl');
            TB_Knowledge_Article_Inactivity_Days__c inactivityDays = new TB_Knowledge_Article_Inactivity_Days__c(TB_KB_Days_Of_Inactivity__c  = 180);   
            insert inactivityDays;
            
            List<Knowledge__kav> kbArticles = new List<Knowledge__kav>();
            for(Integer i = 0; i < ARTICLE_COUNT; i++) {
                kbArticles.add(new Knowledge__kav(
                        TB_Last_Activity_Date__c = System.Today().addDays(-180),
                        Title = ARTICLE_TITLE + ' ' + i,
                        urlName = 'Test-' + String.valueOf(Crypto.getRandomLong()) + '-' + String.valueOf(i),
                        OwnerId = u.Id
                    ));
    
                }
            
            insert kbArticles;
        }
    }


    @IsTest
    private static void testSchedulable() {
    Knowledge__kav recordDraft = [SELECT Id, 
                                        KnowledgeArticleId 
                                        FROM Knowledge__kav 
                                        WHERE Title =: ARTICLE_TITLE + ' 1' 
                                        AND PublishStatus = 'Draft' 
                                        LIMIT 1];
      KbManagement.PublishingService.publishArticle(recordDraft.KnowledgeArticleId, true);
      Test.startTest();
      String jobId  = System.schedule('Email_Send_Scheduled', CRON_EXP, new TB_kb_SendArticleMailScheduled());
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
      Test.stopTest();
      Assert.areEqual(CRON_EXP,  ct.CronExpression);
      Assert.areEqual(0, ct.TimesTriggered);
      Assert.areEqual('2045-04-05 15:02:00', String.valueOf(ct.NextFireTime));
    }
}