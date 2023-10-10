@IsTest
private class TB_SuggestedArticleGroupElementTrigHTest {
    private static final String TEST_EXPRESSION = 'Test';

    @TestSetup
    static void testSetup(){
        TB_Knowledge_Category__c kc = new TB_Knowledge_Category__c(
            Name = TEST_EXPRESSION,
            TB_Category_Api_Name__c = TEST_EXPRESSION,
            TB_Category_Name_PL__c = TEST_EXPRESSION + 'PL',
            TB_Category_Name_EN__c = TEST_EXPRESSION + 'EN',
            TB_Business_Owner__c = 'Admissions'
        );
        insert kc;

        TB_Suggested_Article_Group__c sag = new TB_Suggested_Article_Group__c(
            TB_Owner_Name__c = TEST_EXPRESSION,
            TB_Knowledge_Category__c = kc.Id
        );
        insert sag;

        Knowledge__kav kav = new Knowledge__kav(
            Title = TEST_EXPRESSION,
            UrlName = TEST_EXPRESSION + 'url'
        );
        insert kav;
    }

    @IsTest
    static void shouldFillUpArticleParentIdFieldOnInsert() {
        Knowledge__kav kav = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Title =: TEST_EXPRESSION LIMIT 1];
        TB_Suggested_Article_Group__c sag = [SELECT Id FROM TB_Suggested_Article_Group__c WHERE TB_Owner_Name__c =: TEST_EXPRESSION LIMIT 1];
        TB_Suggested_Article_Group_Element__c sage = new TB_Suggested_Article_Group_Element__c(
            TB_Suggested_Article_Group__c = sag.Id,
            TB_Article__c = kav.Id,
            TB_Order__c = 0
        );

        Test.startTest();
        insert sage;
        Test.stopTest();

        Assert.isTrue([SELECT Id FROM TB_Suggested_Article_Group_Element__c WHERE TB_Article_Parent_Id__c =: kav.KnowledgeArticleId].size() == 1);
    }


    @IsTest
    static void shouldFillUpArticleParentIdFieldOnUpdate() {
        Knowledge__kav kav = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Title =: TEST_EXPRESSION LIMIT 1];
        TB_Suggested_Article_Group__c sag = [SELECT Id FROM TB_Suggested_Article_Group__c WHERE TB_Owner_Name__c =: TEST_EXPRESSION LIMIT 1];
        TB_Suggested_Article_Group_Element__c sage = new TB_Suggested_Article_Group_Element__c(
            TB_Suggested_Article_Group__c = sag.Id,
            TB_Article__c = kav.Id,
            TB_Order__c = 0
        );
        insert sage;
        Knowledge__kav newKav = new Knowledge__kav(
            Title = TEST_EXPRESSION + 'V2',
            UrlName = TEST_EXPRESSION + 'v2' + 'url'
        );
        insert newKav;

        Test.startTest();
        sage.TB_Article__c = newKav.Id;
        update sage;
        Test.stopTest();

        Id newKavArticleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id =: newKav.Id LIMIT 1].KnowledgeArticleId;
        Assert.isTrue([SELECT Id FROM TB_Suggested_Article_Group_Element__c WHERE TB_Article_Parent_Id__c =: newKavArticleId].size() == 1);
    }

    @IsTest
    static void shouldDeleteJSONWrapperRelatedToRecord() {
        Knowledge__kav kav = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Title =: TEST_EXPRESSION LIMIT 1];
        TB_Suggested_Article_Group__c sag = [SELECT Id FROM TB_Suggested_Article_Group__c WHERE TB_Owner_Name__c =: TEST_EXPRESSION LIMIT 1];
        TB_Suggested_Article_Group_Element__c sage = new TB_Suggested_Article_Group_Element__c(
            TB_Suggested_Article_Group__c = sag.Id,
            TB_Article__c = kav.Id,
            TB_Order__c = 0
        );
        insert sage;
        
        Test.startTest();
        delete [SELECT Id FROM TB_Suggested_Article_Group_Element__c WHERE Id =: sage.Id];
        Test.stopTest();

        Assert.isTrue([SELECT Id FROM TB_JSON_Wrapper__c WHERE TB_Object_Id__c =: sage.Id].size() == 0);
        Assert.isTrue([SELECT Id FROM TB_Suggested_Article_Group_Element__c WHERE Id =: sage.Id].size() == 0);
    }

    @IsTest
    static void shouldInsertJSONWrapper() {
        Knowledge__kav kav = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Title =: TEST_EXPRESSION LIMIT 1];
        TB_Suggested_Article_Group__c sag = [SELECT Id FROM TB_Suggested_Article_Group__c WHERE TB_Owner_Name__c =: TEST_EXPRESSION LIMIT 1];
        TB_Suggested_Article_Group_Element__c sage = new TB_Suggested_Article_Group_Element__c(
            TB_Suggested_Article_Group__c = sag.Id,
            TB_Article__c = kav.Id,
            TB_Order__c = 0
        );

        Test.startTest();
        insert sage;
        Test.stopTest();

        Assert.isTrue([SELECT Id FROM TB_JSON_Wrapper__c WHERE TB_Object_Id__c =: sage.Id].size() == 1);
    }
}