public without sharing class TB_ArticleController {

    @AuraEnabled
    public static List<ArticleWrapper> getArticles(String language, String contactId, Boolean isTest) {
        List<ArticleWrapper> articleWrappers = new List<TB_ArticleController.ArticleWrapper>();
        Set<String> categoryProduct = new Set<String>{
                null
        };
        try {
            List<AggregateResult> applications = getApplicationsForUserContact(contactId, isTest);
            if (!applications.isEmpty()) {
                for (AggregateResult ar : applications) {
                    categoryProduct.add(String.valueOf(ar.get(hed__Application__c.TB_Product_Group__c.getDescribe().name)));
                }
            }
            articleWrappers = getArticlesWrapper(categoryProduct, language);
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            articleWrappers = null;
        }
        System.debug(articleWrappers);
        return articleWrappers;
    }

    @AuraEnabled
    public static String fetchArticle(Id articleId) {
        String articleWrapperValue = '';
        try {
            articleWrapperValue = [SELECT TB_Wrapper_Value__c FROM TB_JSON_Wrapper__c WHERE TB_Object_Id__c = :articleId].TB_Wrapper_Value__c;
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            articleWrapperValue = null;
        }
        return (isArticle(articleWrapperValue)) ? articleWrapperValue : null;
    }

    private static List<AggregateResult> getApplicationsForUserContact(String applicationContactId, Boolean isTest) {
        List<AggregateResult> applications = new List<AggregateResult>();
        if (applicationContactId != null) {
            String dynamicQuery = 'SELECT TB_Product_Group__c FROM hed__Application__c WHERE hed__Applicant__c = :applicationContactId';

            if (!isTest) {
                dynamicQuery += ' AND TB_Active__c = true AND TB_Archived__c = false AND TB_Anonymization_Status__c != \'Anonymized\' ';
            }
            dynamicQuery += ' Group by TB_Product_Group__c';
            applications = Database.query(dynamicQuery);
        }
        return applications;
    }

    private static List<ArticleWrapper> getArticlesWrapper(Set<String> productCategorySet, String language) {
        List<ArticleWrapper> articleWrappers = new List<TB_ArticleController.ArticleWrapper>();
        for (TB_JSON_Wrapper__c jsonWrapper : [SELECT TB_Wrapper_Value__c FROM TB_JSON_Wrapper__c WHERE TB_Object_API_Name__c = :TB_Admissions_Content__c.getSObjectType().getDescribe().name ORDER BY TB_Order__c DESC ]) {
            Map<String, Object> jsonFieldToValueMap = (Map<String, Object>) JSON.deserializeUntyped(jsonWrapper.TB_Wrapper_Value__c);
            if (Boolean.valueOf(jsonFieldToValueMap.get(TB_Admissions_Content__c.TB_Active__c.getDescribe().name)) &&
                    String.valueOf(jsonFieldToValueMap.get(TB_Admissions_Content__c.TB_Content_Type__c.getDescribe().name)) == TB_Constants.TB_ADMISSIONS_CONTENT_CONTENT_TYPE_ARTICLE &&
                    productCategorySet.contains(String.valueOf(jsonFieldToValueMap.get(TB_Admissions_Content__c.TB_Product_Group__c.getDescribe().name)))) {
                ArticleWrapper articleWrapper = new ArticleWrapper(jsonFieldToValueMap, language);
                articleWrappers.add(articleWrapper);
            }
        }
        return articleWrappers;
    }

    private static Boolean isArticle(String articleWrapperValue) {
        if (articleWrapperValue == null || String.isBlank(articleWrapperValue)) {
            return false;
        }
        TB_Admissions_Content__c admissionsContent = (TB_Admissions_Content__c) JSON.deserialize(articleWrapperValue, TB_Admissions_Content__c.class);
        return admissionsContent.TB_Content_Type__c == TB_Constants.TB_ADMISSIONS_CONTENT_CONTENT_TYPE_ARTICLE;
    }

    public class ArticleWrapper {
        @AuraEnabled public String Id;
        @AuraEnabled public String title;
        @AuraEnabled public String lead;
        @AuraEnabled public String content;
        @AuraEnabled public String url;

        public ArticleWrapper(Map<String, Object> jsonFieldToValueMap, String language) {
            this.Id = String.valueOf(jsonFieldToValueMap.get(TB_Constants.languageToFieldsMap.get(language).get(TB_Admissions_Content__c.Id.getDescribe().name)));
            this.title = String.valueOf(jsonFieldToValueMap.get(TB_Constants.languageToFieldsMap.get(language).get(TB_Constants.TB_ARTICLE_WRAPPER_TITLE_NAME)));
            this.lead = String.valueOf(jsonFieldToValueMap.get(TB_Constants.languageToFieldsMap.get(language).get(TB_Constants.TB_ARTICLE_WRAPPER_LEAD_NAME)));
            this.content = String.valueOf(jsonFieldToValueMap.get(TB_Constants.languageToFieldsMap.get(language).get(TB_Constants.TB_ARTICLE_WRAPPER_CONTENT_NAME)));
            this.url = String.valueOf(jsonFieldToValueMap.get(TB_Constants.languageToFieldsMap.get(language).get(TB_Constants.TB_ARTICLE_WRAPPER_URL_NAME)));
        }
    }
}