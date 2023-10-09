public without sharing class TB_IC_FetchRelatedServices {
    
    @AuraEnabled(cacheable=true)
    public static List<Product2> getServices(Id contractId) {
        Map<Id, List<Product2>> relatedServicesMap = new Map<Id, List<Product2>>();
        
        for (DT_Contract_Product__c relatedService : [SELECT DT_Product_Name__c FROM DT_Contract_Product__c WHERE DT_Contract__c = :contractId]) {
            if (relatedService.DT_Product_Name__c != null) {
                List<Product2> relatedServicesList = [SELECT Name, DT_Product_Name_EN__c, toLabel(Family) Family, DT_Product_Family_PL__c 
                                                      FROM Product2 
                                                      WHERE Id = :relatedService.DT_Product_Name__c];
                
                    relatedServicesMap.put(relatedService.Id, relatedServicesList);
                
            }
        }
    
        List<Product2> relatedServicesList = new List<Product2>();
        for (List<Product2> services : relatedServicesMap.values()) {
            relatedServicesList.addAll(services);
        }
        return relatedServicesList;
    }
}