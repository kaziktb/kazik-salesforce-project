public without sharing class TB_SpecializationChoice {
    @AuraEnabled
    public static hed__Application__c getApplicationData(String applicationId) {
        hed__Application__c application = new hed__Application__c();

        try {
            application = [
                SELECT
                    Id,
                    TB_PD_Specialisation__c,
                    TB_PD_Higher_Year__c,
                    TB_x_PD_Decision_Choice__c
                FROM hed__Application__c
                WHERE Id = :applicationId
            ];
        } catch (Exception e) {
            TB_LogUtils.registerLogFuture(e.getMessage(), TB_SpecializationChoice.class.getName());
        }

        return application;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> getConsentOptions() {
        Map<String, String> consentOptions = new Map<String, String>();

        try {
            Schema.DescribeFieldResult fieldResult = hed__Application__c.TB_x_PD_Decision_Choice__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal : ple) {
                consentOptions.put(pickListVal.getValue(), pickListVal.getLabel());
            }
        } catch (Exception e) {
            TB_LogUtils.registerLogFuture(e.getMessage(), TB_SpecializationChoice.class.getName());
        }
        return consentOptions;
    }

    @AuraEnabled
    public static List<TB_Related_Offered_Product__c> getRelatedProducts(String applicationId, String higherYear) {
        List<TB_Related_Offered_Product__c> relatedProducts = new List<TB_Related_Offered_Product__c>();

        try {
            hed__Application__c application = [
                SELECT Id, TB_Applicant_Citizenship__c, TB_Applying_To_Offered_Product__c
                FROM hed__Application__c
                WHERE Id = :applicationId
            ];

            List<TB_JSON_Wrapper__c> wrappers = [
                SELECT Id, TB_Wrapper_Value__c, TB_Object_API_Name__c
                FROM TB_JSON_Wrapper__c
                WHERE TB_Object_API_Name__c = 'TB_Related_Offered_Product__c'
                ORDER BY TB_Order__c
            ];

            if (application.TB_Applicant_Citizenship__c == 'Poland' || application.TB_Applicant_Citizenship__c == 'PL') {
                for (TB_JSON_Wrapper__c singleWrapper : wrappers) {
                    TB_Related_Offered_Product__c relatedProduct = (TB_Related_Offered_Product__c) JSON.deserialize(
                        singleWrapper.TB_Wrapper_Value__c,
                        TB_Related_Offered_Product__c.class
                    );
                    if (relatedProduct.TB_Active__c == true &&
                        relatedProduct.TB_Parent_Product__c == application.TB_Applying_To_Offered_Product__c &&
                        relatedProduct.TB_Relation_Type__c == TB_Constants.TB_SPECIALIZATION_CHOICE_RELATION_TYPE &&
                        relatedProduct.TB_Higher_Year__c == higherYear &&
                        (relatedProduct.TB_Citizenship_Dependency__c == TB_Constants.TB_CITIZENSHIP_DEPENDENCY_EVERYONE || relatedProduct.TB_Citizenship_Dependency__c == TB_Constants.TB_CITIZENSHIP_DEPENDENCY_POLISH_CITIZENS)) {
                        relatedProducts.add(relatedProduct);
                    }
                }
            } else if ((application.TB_Applicant_Citizenship__c != 'Poland' || application.TB_Applicant_Citizenship__c != 'PL') && application.TB_Applicant_Citizenship__c != null) {
                for (TB_JSON_Wrapper__c singleWrapper : wrappers) {
                    TB_Related_Offered_Product__c relatedProduct = (TB_Related_Offered_Product__c) JSON.deserialize(
                        singleWrapper.TB_Wrapper_Value__c,
                        TB_Related_Offered_Product__c.class
                    );
                    if (relatedProduct.TB_Active__c == true &&
                        relatedProduct.TB_Parent_Product__c == application.TB_Applying_To_Offered_Product__c &&
                        relatedProduct.TB_Relation_Type__c == TB_Constants.TB_SPECIALIZATION_CHOICE_RELATION_TYPE &&
                        relatedProduct.TB_Higher_Year__c == higherYear &&
                        (relatedProduct.TB_Citizenship_Dependency__c == TB_Constants.TB_CITIZENSHIP_DEPENDENCY_EVERYONE || relatedProduct.TB_Citizenship_Dependency__c == TB_Constants.TB_CITIZENSHIP_DEPENDENCY_NON_POLISH_CITIZENS)) {
                        relatedProducts.add(relatedProduct);
                    }
                }
            } else {
                for (TB_JSON_Wrapper__c singleWrapper : wrappers) {
                    TB_Related_Offered_Product__c relatedProduct = (TB_Related_Offered_Product__c) JSON.deserialize(
                        singleWrapper.TB_Wrapper_Value__c,
                        TB_Related_Offered_Product__c.class
                    );
                    if (
                        relatedProduct.TB_Active__c == true &&
                            relatedProduct.TB_Parent_Product__c == application.TB_Applying_To_Offered_Product__c &&
                            relatedProduct.TB_Relation_Type__c == TB_Constants.TB_SPECIALIZATION_CHOICE_RELATION_TYPE &&
                            relatedProduct.TB_Higher_Year__c == higherYear &&
                            relatedProduct.TB_Citizenship_Dependency__c == TB_Constants.TB_CITIZENSHIP_DEPENDENCY_EVERYONE
                    ) {
                        relatedProducts.add(relatedProduct);
                    }
                }
            }
        } catch (Exception e) {
            TB_LogUtils.registerLogFuture(e.getMessage(), TB_SpecializationChoice.class.getName());
        }

        return relatedProducts;
    }

    @AuraEnabled
    public static Boolean setSpecialization(String applicationId, String consent, String specialization) {
        Boolean isSuccess = false;

        try {
            hed__Application__c currentApplication = [
                SELECT Id
                FROM hed__Application__c
                WHERE Id = :applicationId
            ];
            currentApplication.TB_x_PD_Decision_Choice__c = consent;
            currentApplication.TB_PD_Specialisation__c = specialization;
            update currentApplication;
            isSuccess = true;
        } catch (Exception e) {
            TB_LogUtils.registerLogFuture(e.getMessage(), TB_SpecializationChoice.class.getName());
        }

        return isSuccess;
    }
}