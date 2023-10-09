/**
 * Created by annaseveryna on 04/01/2022.
 */

public with sharing class TB_SocialMediaButtonsController {

    @AuraEnabled (Cacheable = true)
    public static List<TB_Admissions_Content__c> fetchSocialMediaPosts() {
        List<TB_JSON_Wrapper__c> jsonWrappers = [
                SELECT TB_Wrapper_Value__c
                FROM TB_JSON_Wrapper__c
                WHERE TB_Object_API_Name__c = 'TB_Admissions_Content__c'];
        List<TB_Admissions_Content__c> socialMediaPosts = new List<TB_Admissions_Content__c>();
        for (TB_JSON_Wrapper__c wrapper : jsonWrappers) {
            TB_Admissions_Content__c deserializeed = (TB_Admissions_Content__c)JSON.deserialize(wrapper.TB_Wrapper_Value__c, TB_Admissions_Content__c.class);
            if (deserializeed.TB_Content_Type__c == 'Social_Media'
                    && deserializeed.TB_Active__c == true
                    && deserializeed.TB_Product_Group__c == 'Higher_Education') {
                socialMediaPosts.add(deserializeed);
            }
        }
        return socialMediaPosts;
    }
}