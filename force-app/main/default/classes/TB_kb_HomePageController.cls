public with sharing class TB_kb_HomePageController {
    private static final String POLISH_LANGUAGE_CODE = 'pl';

    public class DataCategoryWrapper{
        @AuraEnabled public Id id;
        @AuraEnabled public String label;
        @AuraEnabled public List<DataCategoryWrapper> relatedCategories;
        @AuraEnabled public Boolean expandedOnPage;

        public DataCategoryWrapper(Id id, String label, Boolean expandedOnPage) {
            this.id = id;
            this.label = label;
            this.expandedOnPage = expandedOnPage;
        }
    }
    
    @AuraEnabled
    public static List<DataCategoryWrapper> getDataCategories(Id recordId){
        try {
            List<DataCategoryWrapper> dataCategoriesToReturn = new List<DataCategoryWrapper>();
            List<Id> dataCategoryGroupIds = new List<Id>();
            Integer dataCategoriesCounter = 0;
            Map<Id, List<TB_Knowledge_Category__c>> parentIdToKnowledgeCategories = new Map<Id, List<TB_Knowledge_Category__c>>();
            for(TB_Knowledge_Category__c kc : [
                SELECT
                    Id,
                    TB_Parent_Category__c,
                    TB_Category_API_Name__c,
                    TB_Category_Name_PL__c,
                    TB_Category_Name_EN__c
                FROM TB_Knowledge_Category__c
                WHERE TB_Public__c = TRUE
            ]){
                if(parentIdToKnowledgeCategories.get(kc.TB_Parent_Category__c) == null)
                    parentIdToKnowledgeCategories.put(kc.TB_Parent_Category__c, new List<TB_Knowledge_Category__c>{kc});
                else 
                    parentIdToKnowledgeCategories.get(kc.TB_Parent_Category__c).add(kc);
                
            }

            if(parentIdToKnowledgeCategories.get(null) != null){
                for(TB_Knowledge_Category__c kc : parentIdToKnowledgeCategories.get(null)){
                    dataCategoriesToReturn.add(new DataCategoryWrapper(
                        kc.Id,
                        UserInfo.getLanguage() == POLISH_LANGUAGE_CODE ? kc.TB_Category_Name_PL__c : kc.TB_Category_Name_EN__c,
                        dataCategoriesCounter == 0 && String.isBlank(recordId)
                    ));
                    dataCategoriesCounter++;
                    dataCategoryGroupIds.add(kc.Id);
                }
    
                Map<Id, List<DataCategoryWrapper>> subcategoriesToParentIds = new Map<Id, List<DataCategoryWrapper>>();    
                for(Id parentId : parentIdToKnowledgeCategories.keySet()){
                    if(!dataCategoryGroupIds.contains(parentId)){
                        for(TB_Knowledge_Category__c kc : parentIdToKnowledgeCategories.get(parentId)){
                            DataCategoryWrapper subcategoryToAdd = new DataCategoryWrapper(
                                kc.Id,
                                UserInfo.getLanguage() == POLISH_LANGUAGE_CODE ? kc.TB_Category_Name_PL__c : kc.TB_Category_Name_EN__c,
                                false    
                            );
    
                            if(subcategoriesToParentIds.get(kc.TB_Parent_Category__c) == null)
                                subcategoriesToParentIds.put(kc.TB_Parent_Category__c, new List<DataCategoryWrapper>{subcategoryToAdd});
                            else
                                subcategoriesToParentIds.get(kc.TB_Parent_Category__c).add(subcategoryToAdd);
                            
                        }
                    }
                }
    
                String parentCategoryIdToExpand = '';
                Integer categoriesCounter = 0;
                Map<Id, List<DataCategoryWrapper>> categoriesToParentIds = new Map<Id, List<DataCategoryWrapper>>();
                for(Id parentId : parentIdToKnowledgeCategories.keySet()){
                    if(dataCategoryGroupIds.contains(parentId)){
                        for(TB_Knowledge_Category__c kc : parentIdToKnowledgeCategories.get(parentId)){
                            DataCategoryWrapper categoryToAdd = new DataCategoryWrapper(
                                kc.Id,
                                UserInfo.getLanguage() == POLISH_LANGUAGE_CODE ? kc.TB_Category_Name_PL__c : kc.TB_Category_Name_EN__c,
                                (String.isNotBlank(recordId) && kc.Id == recordId) || (categoriesCounter == 0 && String.isBlank(recordId))
                            );
                            categoriesCounter++;
                            categoryToAdd.relatedCategories = subcategoriesToParentIds.get(kc.id);
                            if(String.isNotBlank(recordId) && kc.Id == recordId) 
                                parentCategoryIdToExpand = kc.TB_Parent_Category__c;
                            if(categoriesToParentIds.get(kc.TB_Parent_Category__c) == null)
                                categoriesToParentIds.put(kc.TB_Parent_Category__c, new List<DataCategoryWrapper>{categoryToAdd});
                            
                            else
                                categoriesToParentIds.get(kc.TB_Parent_Category__c).add(categoryToAdd);
                        }
                    }
                }
    
                for(DataCategoryWrapper dc : dataCategoriesToReturn){
                    if((String.isNotBlank(recordId) && String.isBlank(parentCategoryIdToExpand) && dc.id == recordId) 
                    || (String.isNotBlank(parentCategoryIdToExpand) && dc.id == parentCategoryIdToExpand)) 
                        dc.expandedOnPage = true;
                    dc.relatedCategories = categoriesToParentIds.get(dc.id);
                }
            }

            return dataCategoriesToReturn;
        } catch (Exception e) {
            throw new AuraHandledException(
                TB_vu_Utils.registerLog(e.getMessage(),TB_kb_HomePageController.class.getName(),e.getStackTraceString(),recordId)
            );
        }
    }

}