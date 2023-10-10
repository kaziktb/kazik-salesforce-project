/**
 * @description       : 
 * @author            : aleksandra.gonta-kacperska@devoteam.com
 * @group             : 
 * @last modified on  : 05-31-2021
 * @last modified by  : aleksandra.gonta-kacperska@devoteam.com
 * Modifications Log 
 * Ver   Date         Author                                    Modification
 * 1.0   04-23-2021   aleksandra.gonta-kacperska@devoteam.com   Initial Version
**/
public with sharing class DT_FavoritesController {

    @AuraEnabled
    public static Boolean checkFavorite(Id jobOfferId, Id userId) {
        List <DT_Favorites__c> favoriteJobs = [
            SELECT Id
            FROM DT_Favorites__c
            WHERE DT_Job_Offer__c = :jobOfferId
                AND DT_User__c = : userId
        ];

        return !favoriteJobs.isEmpty();
    }

    @AuraEnabled
    public static void deleteFavorites(Id jobOfferId, Id userId) {

        DT_Favorites__c favoriteRecord = [
            SELECT Id
            FROM DT_Favorites__c
            WHERE DT_Job_Offer__c = :jobOfferId
                AND DT_User__c = : userId
            LIMIT 1
        ];

        delete favoriteRecord;
    }


    @AuraEnabled
    public static void createFavorite(Id jobOfferId, Id userId, Id contactId) {

        DT_Favorites__c favoriteJob = new DT_Favorites__c ();
        favoriteJob.DT_Job_Offer__c = jobOfferId;
        favoriteJob.DT_User__c = userId;
        favoriteJob.DT_Contact__c = contactId;

        insert favoriteJob;
    }

    @AuraEnabled
    public static List<DT_Favorites__c> getAllFavorites() {
        return [
            SELECT Id, DT_Job_Offer__c, DT_Job_Title__c, DT_Company_Name__c, DT_valid_until__c
            FROM DT_Favorites__c
            WHERE DT_User__c = :UserInfo.getUserId()
        ];
    }
}