/**
 * Created by Adam Czeczuk on 14/10/2021.
 */
@IsTest
public with sharing class TB_MCMauticWebFormQueueableBatchTest {

    @TestSetup
    static void testSetup(){

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

        TB_Web_Form_Submission__c webForm = new TB_Web_Form_Submission__c(
                TB_Form_Name__c = 'Formularz');
        insert webForm;

        Contact lead = new Contact(
                LastName = 'Lead',
                Email = 'lead@niepodam.fake');
        insert lead;

        insert new TB_Marketing_Cloud_API__c(
            TB_Auth_End_Point__c = 'https://test.com',
            TB_POST_End_Point__c = 'https://test.com'
        );
    }

    @IsTest
    static void ClientWebFormTest() {
        Test.setMock(HttpCalloutMock.class, new TB_MCClientQueueableBatchMock());
        Id recId = [SELECT Id FROM TB_Web_Form_Submission__c LIMIT 1].Id;

        TB_MCClient.WrapperClass wc = new TB_MCClient.WrapperClass();
        wc.recordId = recId;
        wc.eventKey = 'Test';
        wc.journey = 'Test';
        List<TB_MCClient.WrapperClass> wcList = new List<TB_MCClient.WrapperClass>();
        wcList.add(wc);

        Test.startTest();
        TB_MCMauticWebFormQueueableBatch batch = new TB_MCMauticWebFormQueueableBatch(wcList);
        Database.executeBatch(batch);
        Test.stopTest();
    }

    @IsTest
    static void ClientMCTest() {
        Test.setMock(HttpCalloutMock.class, new TB_MCClientQueueableBatchMock());
        Id recId = [SELECT Id FROM TB_Web_Form_Submission__c LIMIT 1].Id;

        TB_MCClient.WrapperClass wc = new TB_MCClient.WrapperClass();
        wc.recordId = recId;
        wc.eventKey = 'Test';
        wc.journey = 'Test';
        List<TB_MCClient.WrapperClass> wcList = new List<TB_MCClient.WrapperClass>();
        wcList.add(wc);

        Test.startTest();
        TB_MCMauticWebFormQueueableBatch batch = new TB_MCMauticWebFormQueueableBatch(wcList);
        Database.executeBatch(batch);
        Test.stopTest();
    }
}