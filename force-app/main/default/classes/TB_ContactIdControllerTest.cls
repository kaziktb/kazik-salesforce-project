@isTest
private with sharing class TB_ContactIdControllerTest {
    @testSetup static void testSetup(){
        TB_DataFactory.createUser('Standard User', true);
    }
    @isTest static void returnContactIdTest(){
        User user = [SELECT Id FROM User WHERE Email = 'puser000@amamama.com' AND LastName = 'last'];
		Contact con = new Contact(LastName = 'test', TB_User__c = user.Id);
        insert con;

        Contact result;
        
        Test.startTest();
        result = TB_ContactIdController.getContact(user.Id);
        Test.stopTest();
        
        System.assertEquals(con.Id, result.Id);
    }
    @isTest static void returnContactIdException(){
        Contact result;
        String message;

       	Test.startTest();
        try
        {
            result = TB_ContactIdController.getContact('something');
        }
        catch(Exception e)
        {
            message = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(null, result);
        System.assert(String.isNotBlank(message));
    }
}