public without sharing class TB_OpportunityLineItemHandler {

    private static Final String TB_SAME_FAMILY_ERROR_INFO = System.Label.Tb_OppoLineItem_Same_Family_Error_Info;
    private static Final String TB_SAME_ORDER_ERROR_INFO = System.Label.Tb_OppoLineItem_Same_Order_Error_Info;

   public static void checkSameFamilyAndRedundantProduct(List<OpportunityLineItem> newLineItems){
     Set<Id> oppo_parentsId = new Set<Id>(); 
     Set<Id> prod_parentsId = new Set<Id>(); 
        for(OpportunityLineItem item : newLineItems){
            oppo_parentsId.add(item.OpportunityId);
            prod_parentsId.add(item.Product2Id);
        }
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('DT_Partnerships').getRecordTypeId();
          
        Map<Id,Opportunity> oppo_parents = new Map<Id,Opportunity>(
            [SELECT Id,DT_Main_Product_Family__c FROM Opportunity WHERE Id IN:oppo_parentsId AND RecordTypeId =:recordTypeId ]);

        Map<Id,Product2> prod_parents = new Map<Id,Product2>(
                [SELECT Id,Family FROM Product2 WHERE Id IN:prod_parentsId]);

            for(OpportunityLineItem item : newLineItems){
                if(oppo_parents.containsKey(item.OpportunityId)){
                    if(oppo_parents.get(item.OpportunityId).DT_Main_Product_Family__c != prod_parents.get(item.Product2Id).Family )
                    {
                        item.addError(TB_SAME_FAMILY_ERROR_INFO);
                    }
                }
            }  
        checkRedundantProduct(newLineItems,oppo_parents);
   }

   private static void checkRedundantProduct(List<OpportunityLineItem> newLineItems,Map<Id,Opportunity> oppo_parents){
    Set<Id> parentsId = new Set<Id>(); 
        for(OpportunityLineItem item : newLineItems){
            parentsId.add(item.OpportunityId);
        }
    List<OpportunityLineItem> otherLineItems = 
        [SELECT ID,Product2Id,OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN:parentsId];
        
        for(OpportunityLineItem item : newLineItems){
            if(oppo_parents.containsKey(item.OpportunityId)){
                for(OpportunityLineItem otherItem :otherLineItems){
                    if(item.OpportunityId == otherItem.OpportunityId 
                    && item.Product2Id == otherItem.Product2Id){
                            item.addError(TB_SAME_ORDER_ERROR_INFO);
                    }
                }
            }
        }
    }
}