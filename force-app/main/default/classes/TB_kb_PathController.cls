public with sharing class TB_kb_PathController {
    private static final String POLISH_LANGUAGE_CODE = 'pl';

    @AuraEnabled
    public static CategoryWrapper getCategoriesForPath(Id recordId){
        CategoryWrapper toReturn = new CategoryWrapper();
        try {
            TB_Knowledge_Category__c subcategory = [
                SELECT
                    Id,
                    TB_Category_Name_PL__c,
                    TB_Category_Name_EN__c,
                    TB_Parent_Category__r.TB_Category_Name_PL__c,
                    TB_Parent_Category__r.TB_Category_Name_EN__c,
                    TB_Parent_Category__r.TB_Parent_Category__r.TB_Category_Name_PL__c,
                    TB_Parent_Category__r.TB_Parent_Category__r.TB_Category_Name_EN__c
                FROM TB_Knowledge_Category__c
                WHERE Id =: recordId 
                LIMIT 1
            ];
            toReturn.id = subcategory.Id;
            toReturn.label = UserInfo.getLanguage() == POLISH_LANGUAGE_CODE ? subcategory.TB_Category_Name_PL__c : subcategory.TB_Category_Name_EN__c;

            CategoryWrapper category = new CategoryWrapper();
            category.id = subcategory.TB_Parent_Category__c;
            category.label = UserInfo.getLanguage() == POLISH_LANGUAGE_CODE ? subcategory.TB_Parent_Category__r.TB_Category_Name_PL__c : subcategory.TB_Parent_Category__r.TB_Category_Name_EN__c;
            
            CategoryWrapper dataCategory = new CategoryWrapper();
            dataCategory.id = subcategory.TB_Parent_Category__r.TB_Parent_Category__c;
            dataCategory.label = UserInfo.getLanguage() == POLISH_LANGUAGE_CODE ? subcategory.TB_Parent_Category__r.TB_Parent_Category__r.TB_Category_Name_PL__c : subcategory.TB_Parent_Category__r.TB_Parent_Category__r.TB_Category_Name_EN__c;
            category.parentCategory = dataCategory;
            toReturn.parentCategory = category;
        } catch (Exception e) {
            throw new AuraHandledException(
                TB_vu_Utils.registerLog(e.getMessage(),TB_kb_PathController.class.getName(),e.getStackTraceString(),recordId)
            );
        }
        return toReturn;
    }

    public class CategoryWrapper{
        @AuraEnabled public Id id;
        @AuraEnabled public String label;
        @AuraEnabled public CategoryWrapper parentCategory;
    }
}