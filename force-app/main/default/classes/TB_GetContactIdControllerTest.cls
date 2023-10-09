@isTest
private without sharing class TB_GetContactIdControllerTest {
    @testSetup static void testSetup(){
        TB_DataFactory.createUser('Standard User', true);
    }
    @isTest static void returnContactIdTest(){
        User user = [SELECT Id From User WHERE Email = 'puser000@amamama.com' AND LastName = 'last'];
		Contact con = new Contact(LastName = 'test', TB_User__c = user.Id);
        insert con;
        String result;
        
        Test.startTest();
        result = TB_GetContactIdController.returnContactId(user.Id);
        
        Test.stopTest();
        
        System.assertEquals(con.Id, result);
    }
    @isTest static void returnContactIdException(){
        String result;
       	Test.startTest();
        result = TB_GetContactIdController.returnContactId('something');
        Test.stopTest();
        System.assertEquals(result, null);
    }
}