/**
 * @description       : 
 * @author            : aleksandra.gonta-kacperska@devoteam.com
 * @group             : 
 * @last modified on  : 11-12-2020
 * @last modified by  : aleksandra.gonta-kacperska@devoteam.com
 * Modifications Log 
 * Ver   Date         Author                                    Modification
 * 1.0   11-12-2020   aleksandra.gonta-kacperska@devoteam.com   Initial Version
**/
public without sharing class DT_JobOfferApplicationController {
    @AuraEnabled
    public static Id createApplication(DT_Job_Offer_Application__c newRecord) {
        insert newRecord;
        return newRecord.Id;
    }

    @AuraEnabled
    public static List<DT_Job_Offer_Application__c> fetchExistingJobOfferApplications(Id jobOfferId, Id contactId) {
        return [
            SELECT Id
            FROM DT_Job_Offer_Application__c
            WHERE DT_Job_Offer__c = :jobOfferId
                AND DT_Contact__c = :contactId
        ];
    }
}