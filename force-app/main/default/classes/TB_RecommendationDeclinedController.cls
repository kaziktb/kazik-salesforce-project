public class TB_RecommendationDeclinedController {

    @AuraEnabled
    public static hed__Application__c getApplicationData(String applicationId) {
        hed__Application__c application = [SELECT Id, hed__Application_Status__c, TB_Interest_Examination_Confirmed__c FROM hed__Application__c WHERE Id = :applicationId];

        return application;
    }

    @AuraEnabled
    public static List<TB_Related_Offered_Product__c> getRelatedProducts(String applicationId) {
        hed__Application__c application = [SELECT Id, TB_Applicant_Citizenship__c, TB_Applying_To_Offered_Product__c FROM hed__Application__c WHERE Id = :applicationId];
        List<TB_Related_Offered_Product__c> relatedProducts = new List<TB_Related_Offered_Product__c>();

        List<TB_JSON_Wrapper__c> wrappers = [
            SELECT Id, TB_Wrapper_Value__c, TB_Object_API_Name__c
            FROM TB_JSON_Wrapper__c
            WHERE TB_Object_API_Name__c = 'TB_Related_Offered_Product__c'
            ORDER BY TB_Order__c
        ];

        if(application.TB_Applicant_Citizenship__c == 'Poland' || application.TB_Applicant_Citizenship__c == 'PL'){
            for(TB_JSON_Wrapper__c singleWrapper : wrappers) {
                TB_Related_Offered_Product__c relatedProduct = (TB_Related_Offered_Product__c) JSON.deserialize(singleWrapper.TB_Wrapper_Value__c, TB_Related_Offered_Product__c.class);
                if(relatedProduct.TB_Active__c == true && relatedProduct.TB_Parent_Product__c == application.TB_Applying_To_Offered_Product__c && RelatedProduct.TB_Relation_Type__c == 'Recommendation_Declined' 
                && (RelatedProduct.TB_Citizenship_Dependency__c == 'Everyone' || RelatedProduct.TB_Citizenship_Dependency__c == 'Polish_Citizens')) {
                    relatedProducts.add(relatedProduct);
                }
            }
        }
        else if((application.TB_Applicant_Citizenship__c != 'Poland' || application.TB_Applicant_Citizenship__c != 'PL') && application.TB_Applicant_Citizenship__c != null){
            for(TB_JSON_Wrapper__c singleWrapper : wrappers) {
                TB_Related_Offered_Product__c relatedProduct = (TB_Related_Offered_Product__c) JSON.deserialize(singleWrapper.TB_Wrapper_Value__c, TB_Related_Offered_Product__c.class);
                if(relatedProduct.TB_Active__c == true && relatedProduct.TB_Parent_Product__c == application.TB_Applying_To_Offered_Product__c && RelatedProduct.TB_Relation_Type__c == 'Recommendation_Declined' 
                && (RelatedProduct.TB_Citizenship_Dependency__c == 'Everyone' || RelatedProduct.TB_Citizenship_Dependency__c == 'Non_Polish_Citizens')) {
                    relatedProducts.add(relatedProduct);
                }
            }
        }
        else{
            for(TB_JSON_Wrapper__c singleWrapper : wrappers) {
                TB_Related_Offered_Product__c relatedProduct = (TB_Related_Offered_Product__c) JSON.deserialize(singleWrapper.TB_Wrapper_Value__c, TB_Related_Offered_Product__c.class);
                if(relatedProduct.TB_Active__c == true && relatedProduct.TB_Parent_Product__c == application.TB_Applying_To_Offered_Product__c && RelatedProduct.TB_Relation_Type__c == 'Recommendation_Declined' 
                && RelatedProduct.TB_Citizenship_Dependency__c == 'Everyone') {
                    relatedProducts.add(relatedProduct);
                }
            }
        }
        return relatedProducts;
    }

    @AuraEnabled
    public static String setApplication(String currentApplicationId, String productId) {
        hed__Application__c currentApplication = [SELECT Id, hed__Applicant__c, hed__Application_Status__c FROM hed__Application__c WHERE Id = :currentApplicationId];

        currentApplication.hed__Application_Status__c = 'Cancelled';
        update currentApplication;

        hed__Application__c newApplication = new hed__Application__c();
        newApplication.hed__Applicant__c = currentApplication.hed__Applicant__c;
        newApplication.TB_Applying_To_Offered_Product__c = productId;
        insert newApplication;

        return newApplication.Id;
    }
}