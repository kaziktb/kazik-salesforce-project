@isTest
private class TB_kb_NoSearchResultFoundTriggerHandTest {
    private static final String TEST_EXPRESSION = TB_kb_Constants.TEST_EXPRESSION;

    @isTest
    private static void shouldInsertNewSearchResultRecord() {
        Test.startTest();
        EventBus.publish(
            new TB_KB_No_Search_Result_Found__e(
                TB_KB_Searched_Phrase__c = TEST_EXPRESSION
            )
        );
        Test.stopTest();
    
        Assert.isTrue([SELECT Id FROM TB_KB_Search_Result__c WHERE TB_Search_Phrase__c =: TEST_EXPRESSION AND TB_Counter__c = 1].size() == 1);
    }

    @isTest
    private static void shouldUpdateExistingSearchResultRecord() {
        insert new TB_KB_Search_Result__c(
            TB_Search_Phrase__c = TEST_EXPRESSION
        );
        
        Test.startTest();
        EventBus.publish(
            new TB_KB_No_Search_Result_Found__e(
                TB_KB_Searched_Phrase__c = TEST_EXPRESSION
            )
        );
        Test.stopTest();
    
        Assert.isTrue([SELECT Id FROM TB_KB_Search_Result__c WHERE TB_Search_Phrase__c =: TEST_EXPRESSION AND TB_Counter__c = 2].size() == 1);
    }
}