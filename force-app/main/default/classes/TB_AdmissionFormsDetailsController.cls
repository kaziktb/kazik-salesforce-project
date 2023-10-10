/**
 * Created by Aneta on 21/09/2021.
 */

public with sharing class TB_AdmissionFormsDetailsController {
    
    @AuraEnabled
    public static ApplicationWrapper getApplicationWrappers(Id applicationId) {
        try {
            hed__Application__c application = [
                SELECT Name, TB_Applying_To_Offered_Product__c,
                    TB_Mode_of_Study__c, toLabel(TB_Mode_of_Study__c) TB_Mode_of_Study_Label,
                    TB_Level_of_Study__c, toLabel(TB_Level_of_Study__c) TB_Level_of_Study_Label,
                    TB_Applying_To_Offered_Product__r.TB_Course_PL__c,
                    TB_Applying_To_Offered_Product__r.TB_Course_EN__c
                FROM hed__Application__c
                WHERE Id = :applicationId
            ];
            ApplicationWrapper applicationWrapper = new ApplicationWrapper(application);
            return applicationWrapper;
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }
    
    public class ApplicationWrapper
    {
        @AuraEnabled public hed__Application__c app {get;set;}
        public ApplicationWrapper(hed__Application__c application) {
            this.app = application;
        }
    }
}