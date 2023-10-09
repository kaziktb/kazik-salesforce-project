@isTest
private without sharing class TB_RatingTriggerHandlerTest {
    @testSetup static void testSetup(){
        Contact contact = TB_TestDataFactory.createContact(true);
        TB_Offered_Product__c offeredProduct = TB_TestDataFactory.createOfferedProduct(true);
        TB_Rating__c rating = TB_TestDataFactory.createRating(true, contact.Id, offeredProduct.Id);

    }
    
    @isTest static void testAfterInsert(){
        Contact contact = [SELECT Id from Contact LIMIT 1];
        TB_Offered_Product__c  offeredProduct = [SELECT Id from TB_Offered_Product__c LIMIT 1];
        Test.startTest();
        TB_Rating__c rating = TB_TestDataFactory.createRating(true, contact.Id, offeredProduct.Id);
        Test.stopTest();
        
        List<TB_JSON_Wrapper__c> jsonWrappers = [
            SELECT Id, TB_Wrapper_Value__c
            FROM TB_JSON_Wrapper__c
            WHERE TB_Object_Id__c = :rating.Id
        ];
        System.assertEquals(1, jsonWrappers.size());
        System.assert(
            jsonWrappers[0].TB_Wrapper_Value__c.contains(rating.Id)
        );
        
    }
    
     
    @isTest static void testAfterUpdate(){
        Contact contact = [SELECT Id from Contact LIMIT 1];
        TB_Offered_Product__c  offeredProduct = [SELECT Id from TB_Offered_Product__c LIMIT 1];
        TB_Rating__c rating = [SELECT Id From TB_Rating__C LIMIT 1];
        List<TB_JSON_Wrapper__c> oldJsonWrappers = [
            SELECT Id, TB_Wrapper_Value__c
            FROM TB_JSON_Wrapper__c
            WHERE TB_Object_Id__c = :rating.Id
        ];
        System.assertEquals(1, oldJsonWrappers.size());
        
        Test.startTest();
        rating.TB_Active__c = false;
        update rating;
        Test.stopTest();
        
        List<TB_JSON_Wrapper__c> newJsonWrappers = [
            SELECT Id, TB_Wrapper_Value__c
            FROM TB_JSON_Wrapper__c
            WHERE TB_Object_Id__c = :rating.Id
        ];
        System.assertEquals(1, newJsonWrappers.size());
        System.assertEquals(oldJsonWrappers[0].Id, newJsonWrappers[0].Id);
        
        TB_Rating__c ratingFromJson = (TB_Rating__c)JSON.deserialize(
            newJsonWrappers[0].TB_Wrapper_Value__c,
            TB_Rating__c.class
        );
        System.assertEquals(false, ratingFromJson.TB_Active__c);
    }
    
    @isTest
    private static void testBeforeDelete(){
        TB_Rating__c rating = [
            SELECT Id
            FROM TB_Rating__c
            LIMIT 1
        ];
        List<TB_JSON_Wrapper__c> jsonWrappersBefore = [
            SELECT Id, TB_Wrapper_Value__c
            FROM TB_JSON_Wrapper__c
            WHERE TB_Object_Id__c = :rating.Id
        ];
        System.assertEquals(1, jsonWrappersBefore.size());
        
        Test.startTest();
        delete rating;
        Test.stopTest();
        List<TB_JSON_Wrapper__c> jsonWrappersAfter = [
            SELECT Id, TB_Wrapper_Value__c
            FROM TB_JSON_Wrapper__c
            WHERE TB_Object_Id__c = :rating.Id
        ];
        System.assert(jsonWrappersAfter.isEmpty());
    }
    
    
    
}