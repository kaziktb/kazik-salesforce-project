/**
 * @File Name          : AS_JobOfferUtils.cls
 * @Description        : 
 * @Author             : Andrzej Cieślak (andrzej.cieslak@avalonsolutions.com)
 * @Group              : 
 * @Last Modified By   : aleksandra.gonta-kacperska@devoteam.com
 * @Last Modified On   : 05-17-2021
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    2/28/2020   Andrzej Cieślak (andrzej.cieslak@avalonsolutions.com)     Initial Version
**/
public without sharing class DT_JobOfferUtils {
    @AuraEnabled
    public static Boolean addViews(String jobOfferId) {
        return increaseCounter('DT_Views__c', jobOfferId);
    }

    @AuraEnabled
    public static Boolean addClicks(String jobOfferId) {
        return increaseCounter('DT_Clicks__c', jobOfferId);
    }

    private static Boolean increaseCounter(String field, String jobOfferId) {
        DT_Job_Offers__c jobOffer = Database.query('SELECT ' + field + ' FROM DT_Job_Offers__c WHERE Id =: jobOfferId LIMIT 1');
        Decimal counter = (Decimal) jobOffer.get(field);
        if (counter == null) {
            counter = 0.0;
        }

        jobOffer.put(field, (counter + 1));
        Database.SaveResult result = Database.update(jobOffer);
        if (result.isSuccess()) {
            return true;
        }

        return false;
    }

    @AuraEnabled
    public static DT_Job_Offers__c fetchJobOfferDetails(Id jobOfferId) {
        return [
            SELECT Id, RecordType.DeveloperName
            FROM DT_Job_Offers__c
            WHERE Id =: jobOfferId
        ];
    }

}