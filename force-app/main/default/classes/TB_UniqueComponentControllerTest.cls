/**
 * Created by jowitakozlak on 07/12/2021.
 */

@IsTest
public with sharing class TB_UniqueComponentControllerTest {

    @TestSetup
    static void testSetup() {
        hed__Application__c application = TB_DataFactory.createApplicationWithRelatedObjects(false);
        Contact applicant = new Contact(LastName = 'Test');
        insert applicant;
        application.hed__Applicant__c = applicant.Id;
        insert application;
        TB_Admissions_Dictionary__c dictionary = TB_TestDataFactory.createAdmissionDictionary(false);
        dictionary.RecordTypeId = Schema.SObjectType.TB_Admissions_Dictionary__c.getRecordTypeInfosByDeveloperName().get('TB_Country_State').getRecordTypeId();
        insert dictionary;
    }

    @IsTest
    static void getContactForAddressComponentPositive() {

        hed__Application__c application = [
            SELECT Id
            FROM hed__Application__c
            WHERE hed__Applicant__r.LastName = 'Test'
        ];

        System.assertNotEquals(null, TB_UniqueComponentController.getContactForAddressComponent(application.Id));
        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void updateContactPositive() { 

        Contact applicant = [
            SELECT Id
            FROM Contact
            WHERE LastName = 'Test'
        ];

        System.assertEquals('', TB_UniqueComponentController.updateContact(JSON.serialize(applicant)));
        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void getApplicationForTuitionComponentPositive() {

        hed__Application__c application = [
            SELECT Id, TB_Applying_To_Offered_Product__r.TB_Tuition_Fee_PLN_1_Instalment__c,
                TB_Applying_To_Offered_Product__r.TB_Tuition_Fee_PLN_2_Instalment__c,
                TB_Applying_To_Offered_Product__r.TB_Tuition_Fee_PLN_10_Instalment__c
            FROM hed__Application__c
            WHERE hed__Applicant__r.LastName = 'Test'
        ];
        application.TB_Applying_To_Offered_Product__r.TB_Tuition_Fee_PLN_1_Instalment__c = 100;
        application.TB_Applying_To_Offered_Product__r.TB_Tuition_Fee_PLN_2_Instalment__c = 50;
        application.TB_Applying_To_Offered_Product__r.TB_Tuition_Fee_PLN_10_Instalment__c = 10;
        update application.TB_Applying_To_Offered_Product__r;

        System.assertNotEquals(null, TB_UniqueComponentController.getApplicationForTuitionComponent(application.Id));
        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void updateApplicationPositive() {

        hed__Application__c application = [
            SELECT Id
            FROM hed__Application__c
            WHERE hed__Applicant__r.LastName = 'Test'
        ];

        System.assertEquals('', TB_UniqueComponentController.updateApplication(JSON.serialize(application)));
        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void getStatesPositive() {

        System.assertNotEquals(null, TB_UniqueComponentController.getStates());
        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }
}