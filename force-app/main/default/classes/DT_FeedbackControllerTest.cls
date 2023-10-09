/**
 * @description       : 
 * @author            : aleksandra.gonta-kacperska@devoteam.com
 * @group             : 
 * @last modified on  : 07-30-2021
 * @last modified by  : aleksandra.gonta-kacperska@devoteam.com
**/
@isTest
public with sharing class DT_FeedbackControllerTest {

    @isTest static void testFeedbackCreation() {
        DT_Article_Feedback__c feedback = new DT_Article_Feedback__c();
        feedback.DT_Like__c = true;

        DT_FeedbackController.createFeedback(feedback);

        DT_Article_Feedback__c testFeedback = [
                SELECT Id
                FROM DT_Article_Feedback__c
                WHERE DT_Like__c = true
        ];
        System.assertEquals(feedback.Id, testFeedback.Id);
    }
}