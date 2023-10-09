public with sharing class TB_kb_KnowledgeArticleFeedbackController {

    @AuraEnabled
    public static void sendFeedback(String recordId, Boolean isHelpful, String description, String reason){
        try {
            insert new TB_Knowledge_Article_Feedback__c(
                TB_Knowledge_Article__c = recordId,
                TB_Helpful__c = isHelpful,
                TB_Description_Rich_Text__c = description,
                TB_Negative_Feedback_Reason__c = reason
            );
        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_kb_KnowledgeArticleFeedbackController.class.getName(),e.getStackTraceString(),recordId));
        }
    }
}