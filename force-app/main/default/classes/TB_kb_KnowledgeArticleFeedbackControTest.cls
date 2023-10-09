@isTest
private class TB_kb_KnowledgeArticleFeedbackControTest {
    private static final String TEST_EXPRESSION = TB_kb_Constants.TEST_EXPRESSION;
    private static final String INVALID_EXPRESSION = TB_kb_Constants.INVALID_EXPRESSION;
    private static final String NEGATIVE_FEEDBACK_REASON_VALUE = 'Other_Longer_Answer_Required';

    @TestSetup
    static void testSetup(){
        Knowledge__kav kav = TB_TestDataFactory.createKnowledgeKavs(1, TEST_EXPRESSION, true)[0];    
        Id knowledgeArticleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Title =: TEST_EXPRESSION LIMIT 1].KnowledgeArticleId;
        KbManagement.PublishingService.publishArticle(knowledgeArticleId, true);
    }

    @isTest
    static void shoudlSentPositiveFeedback() {
        String recordId = [SELECT Id FROM Knowledge__kav WHERE Title =: TEST_EXPRESSION].Id;
        
        Test.startTest();
        TB_kb_KnowledgeArticleFeedbackController.sendFeedback(recordId, true, '', '');
        Test.stopTest();
        
        TB_Knowledge_Article_Feedback__c feedback = [SELECT Id, TB_Knowledge_Article__c, TB_Helpful__c FROM TB_Knowledge_Article_Feedback__c WHERE TB_Knowledge_Article__c = :recordId LIMIT 1];
        
        Assert.areEqual(recordId, feedback.TB_Knowledge_Article__c);
        Assert.areEqual(true, feedback.TB_Helpful__c);
    }

    @isTest
    static void shoudlSentNegativeFeedback() {
        String recordId = [SELECT Id FROM Knowledge__kav WHERE Title =: TEST_EXPRESSION].Id;
        
        Test.startTest();
        TB_kb_KnowledgeArticleFeedbackController.sendFeedback(recordId, false, TEST_EXPRESSION, NEGATIVE_FEEDBACK_REASON_VALUE);
        Test.stopTest();
        
        TB_Knowledge_Article_Feedback__c feedback = [SELECT Id, TB_Knowledge_Article__c, TB_Helpful__c, TB_Description_Rich_Text__c, TB_Negative_Feedback_Reason__c FROM TB_Knowledge_Article_Feedback__c WHERE TB_Knowledge_Article__c = :recordId LIMIT 1];
        
        Assert.areEqual(recordId, feedback.TB_Knowledge_Article__c);
        Assert.areEqual(false, feedback.TB_Helpful__c);
        Assert.areEqual(TEST_EXPRESSION, feedback.TB_Description_Rich_Text__c);
        Assert.areEqual(NEGATIVE_FEEDBACK_REASON_VALUE, feedback.TB_Negative_Feedback_Reason__c);
    }

    @isTest
    static void throwAnErrorOn_PassingInvalidParametersToSendFeedback(){
        Boolean errorOccurred = false;

        Test.startTest();
        try {
            TB_kb_KnowledgeArticleFeedbackController.sendFeedback(INVALID_EXPRESSION, false, TEST_EXPRESSION, NEGATIVE_FEEDBACK_REASON_VALUE);
        } catch (Exception e) {
            errorOccurred = true;
        }
        Test.stopTest();

        Assert.areEqual(true, errorOccurred, 'Query should return exception');
    }
}