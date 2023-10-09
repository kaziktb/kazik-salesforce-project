@isTest
public with sharing class TB_KnowledgeTriggerHandlerTest {
    private static final String ARTICLE_TITLE = 'Test Article';
    private static final Datetime POSITIVE_TEST_DATETIME = Datetime.newInstanceGmt(2022, 02, 02, 12, 0, 0);
    private static final String CUSTOM_LASTNAME = 'Custom Admin';

    @TestSetup
    static void makeData(){
        User u = DT_DataFactory.createAdminUser();
        u.UserPermissionsKnowledgeUser = true;
        u.LastName = CUSTOM_LASTNAME;
        update u;
        System.runAs(u) {
            insert new Knowledge__kav(
                        Title = ARTICLE_TITLE,
                        urlName = 'Test-' + String.valueOf(Crypto.getRandomLong()) + '-1',
                        OwnerId = u.Id
                    );
                }
    }

    @IsTest
    static void fillLastActivityDateInsertTest() {
        User admin = [SELECT Id FROM User WHERE LastName =:CUSTOM_LASTNAME];
        Test.startTest();
        System.runAs(admin) {
            insert new Knowledge__kav(
            Title = ARTICLE_TITLE,
            urlName = 'Test-' + String.valueOf(Crypto.getRandomLong()) + '-1',
            OwnerId = admin.Id
            );
        }
        Test.stopTest();
        Knowledge__kav kav = [SELECT Id, TB_Last_Activity_Date__c FROM Knowledge__kav WHERE Title =: ARTICLE_TITLE LIMIT 1];
        Assert.areNotEqual(null, kav.TB_Last_Activity_Date__c);
        Assert.areEqual(POSITIVE_TEST_DATETIME, kav.TB_Last_Activity_Date__c);
    }

    @IsTest
    static void fillLastActivityDateUpdateTest() {
        User admin = [SELECT Id FROM User WHERE LastName =:CUSTOM_LASTNAME];
        Knowledge__kav kav;
        Test.startTest();
        System.runAs(admin) {
            kav = [SELECT Id, Title, TB_Last_Activity_Date__c FROM Knowledge__kav WHERE Title =: ARTICLE_TITLE];
            kav.Title = 'Updated Title';
            update kav;
        }
        Test.stopTest();
        Assert.isTrue([SELECT Title FROM Knowledge__kav WHERE OwnerId =: admin.Id].Title == 'Updated Title');
        Assert.areEqual(POSITIVE_TEST_DATETIME, kav.TB_Last_Activity_Date__c);
    }
}