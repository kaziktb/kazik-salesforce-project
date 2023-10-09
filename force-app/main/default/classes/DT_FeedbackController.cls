/**
 * @description       : 
 * @author            : aleksandra.gonta-kacperska@devoteam.com
 * @group             : 
 * @last modified on  : 07-28-2021
 * @last modified by  : aleksandra.gonta-kacperska@devoteam.com
**/
public with sharing class DT_FeedbackController {
    @AuraEnabled
    public static DT_Article_Feedback__c createFeedback(DT_Article_Feedback__c newRecord) {
        insert newRecord;
        return null;
    }
}