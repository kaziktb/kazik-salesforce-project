/**
 * Created by Adam Czeczuk on 27/07/2022.
 */
@IsTest
public with sharing class TB_MCCommerceOrderQueueableBatchTest {

    @TestSetup
    static void testSetup() {

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        User u = new User(
                Username = 'test@swps.edu.pl.test',
                LastName = 'Testowy',
                Email = 'test@swps.edu.pl.test',
                Alias = 'test',
                ProfileId = p.Id,
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert u;

        Contact ct = new Contact(
                LastName = 'Testowy',
                TB_User__c = u.Id,
                Email = 'test@swps.edu.pl.test');
        insert ct;

        TB_Commerce_Order__c commerceOrder = new TB_Commerce_Order__c(
                TB_Status__c = 'New',
                TB_Customer__c = ct.id);
        insert commerceOrder;

        insert new TB_Marketing_Cloud_API__c(
                SetupOwnerId = UserInfo.getOrganizationId(),
                TB_Auth_End_Point__c = 'https://test.com',
                TB_POST_End_Point__c = 'https://test.com',
                TB_Client_Id__c = '123',
                TB_Secret__c = '123',
                TB_Grant_Type__c = 'token'
        ); 
    }

    @IsTest
    static void ClientCommerceTest() {
        Test.setMock(HttpCalloutMock.class, new TB_MCClientQueueableBatchMock());
        Id orderId = [SELECT Id FROM TB_Commerce_Order__c LIMIT 1].Id;

        TB_MCClient.WrapperClass wc = new TB_MCClient.WrapperClass();
        wc.recordId = orderId;
        wc.eventKey = 'Test';
        wc.journey = 'Test';
        List<TB_MCClient.WrapperClass> wcList = new List<TB_MCClient.WrapperClass>();
        wcList.add(wc);

        Test.startTest();
        TB_MCCommerceOrderQueueableBatch batch = new TB_MCCommerceOrderQueueableBatch(wcList);
        Database.executeBatch(batch);
        Test.stopTest();
    }

    @IsTest
    static void ClientMCTest() {
        Test.setMock(HttpCalloutMock.class, new TB_MCClientQueueableBatchMock());
        Id orderId = [SELECT Id FROM TB_Commerce_Order__c LIMIT 1].Id;

        TB_MCClient.WrapperClass wc = new TB_MCClient.WrapperClass();
        wc.recordId = orderId;
        wc.eventKey = 'Test';
        wc.journey = 'Test';
        List<TB_MCClient.WrapperClass> wcList = new List<TB_MCClient.WrapperClass>();
        wcList.add(wc);

        Test.startTest();
        TB_MCCommerceOrderQueueableBatch batch = new TB_MCCommerceOrderQueueableBatch(wcList);
        Database.executeBatch(batch);
        Test.stopTest();
    }
}