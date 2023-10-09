/**
 * Created by Adam Czeczuk on 14/10/2021.
 * Edited by Dawid Machon on 01/03/2023
 */
@IsTest
public with sharing class TB_MCAdmissions_v2_QueueableBatchTest {

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

        TB_Offered_Product__c study = new TB_Offered_Product__c(
                Name = 'Psychologia');
        insert study;

        Contact candidate = new Contact(
                LastName = 'Kandydat',
                Email = 'kandydat@email.test');
        insert candidate;

        TB_Offered_Product__c offeredProduct = [
                SELECT Id
                FROM TB_Offered_Product__c
                LIMIT 1
        ];

        hed__Application__c candApplication = new hed__Application__c(
                TB_Applying_To_Offered_Product__c = offeredProduct.Id,
                hed__Applicant__c = candidate.Id
        );
        insert candApplication;


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
    static void ClientAdmissionsTest() {
        Test.setMock(HttpCalloutMock.class, new TB_MCClientQueueableBatchMock());
        Id appId = [SELECT Id FROM hed__Application__c LIMIT 1].Id;

        TB_MCClient_v2.WrapperClass wc = new TB_MCClient_v2.WrapperClass();
        wc.recordId = appId;
        wc.eventKey = 'Test';
        wc.journey = 'Test';
        List<TB_MCClient_v2.WrapperClass> wcList = new List<TB_MCClient_v2.WrapperClass>();
        wcList.add(wc);

        Test.startTest();
        TB_MCAdmissions_v2_QueueableBatch batch = new TB_MCAdmissions_v2_QueueableBatch(wcList);
        Database.executeBatch(batch);
        Test.stopTest();
    }

    @IsTest
    static void ClientMCTest() {
        Test.setMock(HttpCalloutMock.class, new TB_MCClientQueueableBatchMock());
        Id appId = [SELECT Id FROM hed__Application__c LIMIT 1].Id;

        TB_MCClient_v2.WrapperClass wc = new TB_MCClient_v2.WrapperClass();
        wc.recordId = appId;
        wc.eventKey = 'Test';
        wc.journey = 'Test';
        List<TB_MCClient_v2.WrapperClass> wcList = new List<TB_MCClient_v2.WrapperClass>();
        wcList.add(wc);

        Test.startTest();
        TB_MCAdmissions_v2_QueueableBatch batch = new TB_MCAdmissions_v2_QueueableBatch(wcList);
        Database.executeBatch(batch);
        Test.stopTest();
    }
}