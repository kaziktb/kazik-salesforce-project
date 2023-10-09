public with sharing class TB_SuggestedArticleGroupElementTriggerHa extends TB_TriggerHandler {
    public override void afterInsert() {
        TB_GenericJsonWrapperGenerator.upsertJsonWrappers(Trigger.new);
    }

    public override void afterUpdate() {
        TB_GenericJsonWrapperGenerator.upsertJsonWrappers(Trigger.new);
    }

    public override void beforeDelete() {
        TB_GenericJsonWrapperGenerator.deleteRelatedJsonWrappers(Trigger.oldMap);
    }

    public override void beforeInsert() {
        fillUpArticleParentId();
    }

    public override void beforeUpdate() {
        fillUpArticleParentId();
    }

    private void fillUpArticleParentId(){
        List<Id> kavIds = new List<Id>();
        Map<Id, List<TB_Suggested_Article_Group_Element__c>> kavIdToSuggestedArticleGroupElement = new Map<Id, List<TB_Suggested_Article_Group_Element__c>>();

        for (TB_Suggested_Article_Group_Element__c singleElement : (List<TB_Suggested_Article_Group_Element__c>) Trigger.new) {
            kavIds.add(singleElement.TB_Article__c);
            if(kavIdToSuggestedArticleGroupElement.get(singleElement.TB_Article__c) == null){
                kavIdToSuggestedArticleGroupElement.put(
                    singleElement.TB_Article__c,
                    new List<TB_Suggested_Article_Group_Element__c>{singleElement}
                );
            }
            else {
                kavIdToSuggestedArticleGroupElement.get(singleElement.TB_Article__c).add(singleElement);
            }
        }

        List<TB_Suggested_Article_Group_Element__c> recordsToUpdate = new List<TB_Suggested_Article_Group_Element__c>();
        for(Knowledge__kav kav : [
            SELECT 
                Id, 
                KnowledgeArticleId 
            FROM Knowledge__kav 
            WHERE Id IN: kavIds
        ]){
            for(TB_Suggested_Article_Group_Element__c elementToUpdate : kavIdToSuggestedArticleGroupElement.get(kav.Id)){
                elementToUpdate.TB_Article_Parent_Id__c = kav.KnowledgeArticleId;
                recordsToUpdate.add(elementToUpdate);
            }
        }
    }
}
