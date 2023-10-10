@isTest
private class TB_SuggestedArticleGroupTriggerHandlTest {
    private static final String TEST_EXPRESSION = 'Test';

    @testSetup
    private static void testSetup() {
        TB_Knowledge_Category__c kc = new TB_Knowledge_Category__c(
            Name = TEST_EXPRESSION,
            TB_Category_Api_Name__c = TEST_EXPRESSION,
            TB_Category_Name_PL__c = TEST_EXPRESSION + 'PL',
            TB_Category_Name_EN__c = TEST_EXPRESSION + 'EN',
            TB_Business_Owner__c = 'Admissions'
        );
        insert kc;
    }

    @IsTest
    static void shouldInsertJSONWrapper() {
        TB_Knowledge_Category__c kc = [SELECT Id FROM TB_Knowledge_Category__c WHERE Name =: TEST_EXPRESSION LIMIT 1];
        TB_Suggested_Article_Group__c sag = new TB_Suggested_Article_Group__c(
            TB_Owner_Name__c = TEST_EXPRESSION,
            TB_Knowledge_Category__c = kc.Id
        );

        Test.startTest();
        insert sag;
        Test.stopTest();

        Assert.isTrue([SELECT Id FROM TB_JSON_Wrapper__c WHERE TB_Object_Id__c =: sag.Id].size() == 1);
    }

    @IsTest
    static void shouldUpdateJSONWrapper() {
        TB_Knowledge_Category__c kc = [SELECT Id FROM TB_Knowledge_Category__c WHERE Name =: TEST_EXPRESSION LIMIT 1];
        TB_Suggested_Article_Group__c sag = new TB_Suggested_Article_Group__c(
            TB_Owner_Name__c = TEST_EXPRESSION,
            TB_Knowledge_Category__c = kc.Id
        );
        insert sag;

        Test.startTest();
        sag.TB_Owner_Name__c = TEST_EXPRESSION + '123';
        update sag;
        Test.stopTest();

        Assert.isTrue([SELECT TB_Wrapper_Value__c FROM TB_JSON_Wrapper__c WHERE TB_Object_Id__c =: sag.Id].TB_Wrapper_Value__c.contains(TEST_EXPRESSION + '123'));
    }

    @IsTest
    static void shouldDeleteJSONWrapper() {
        TB_Knowledge_Category__c kc = [SELECT Id FROM TB_Knowledge_Category__c WHERE Name =: TEST_EXPRESSION LIMIT 1];
        TB_Suggested_Article_Group__c sag = new TB_Suggested_Article_Group__c(
            TB_Owner_Name__c = TEST_EXPRESSION,
            TB_Knowledge_Category__c = kc.Id
        );
        insert sag;

        Test.startTest();
        delete [SELECT Id FROM TB_Suggested_Article_Group__c WHERE Id =: sag.Id];
        Test.stopTest();

        Assert.isTrue([SELECT Id FROM TB_JSON_Wrapper__c WHERE TB_Object_Id__c =: sag.Id].size() == 0);
        Assert.isTrue([SELECT Id FROM TB_Suggested_Article_Group__c WHERE Id =: sag.Id].size() == 0);
    }
}