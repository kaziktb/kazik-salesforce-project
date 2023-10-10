/**
* @description       : 
* @author            : aleksandra.gonta-kacperska@devoteam.com
* @group             : 
* @last modified on  : 11-13-2020
* @last modified by  : aleksandra.gonta-kacperska@devoteam.com
* Modifications Log 
* Ver   Date         Author                                    Modification
* 1.0   11-13-2020   aleksandra.gonta-kacperska@devoteam.com   Initial Version
**/

@isTest
public with sharing class DT_JobOfferApplicationControllerTest {
    public static final String TEST_USER_FIRST_NAME = 'xyzFirst';
    public static final String TEST_USER_LAST_NAME = 'XyZLast';
    public static final String TEST_USER_EMAIL = 'xyzmail@mail.com';

    public static final String TEST_JOB_OFFER_NAME = 'testJob';

    @testSetup static void dataInit() {
        DT_DataFactory.createContacts(
            1, true, new Contact(
                FirstName = TEST_USER_FIRST_NAME,
                LastName = TEST_USER_LAST_NAME,
                Email = TEST_USER_EMAIL,
                RecordTypeId = DT_Utils.getRecTypeIdByDevName(
                    DT_Utils.CONTACT_STUDENT_RECORD_TYPE_DEV_NAME, Contact.getSObjectType().getDescribe().getName()
                )
            )
        );

        DT_DataFactory.createJobOffers(
            1, true, new DT_Job_Offers__c(
                DT_Job_Title__c = TEST_JOB_OFFER_NAME
            )
        );
    }

    @isTest static void testJobOfferApplicationCreation() {

        DT_Job_Offers__c testJob = [SELECT Id FROM DT_Job_Offers__c WHERE DT_Job_Title__c = :TEST_JOB_OFFER_NAME];
        Contact testContact = [SELECT Id FROM Contact WHERE Email = :TEST_USER_EMAIL];

        DT_Job_Offer_Application__c application = new DT_Job_Offer_Application__c();
        application.DT_Job_Offer__c = testJob.Id;
        application.DT_Contact__c = testContact.Id;

        DT_JobOfferApplicationController.createApplication (application);
        DT_Job_Offer_Application__c testApplication = [
            SELECT Id
            FROM DT_Job_Offer_Application__c
            WHERE DT_Job_Offer__c = :testJob.Id
            AND DT_Contact__c = :testContact.Id
            LIMIT 1
        ];
        System.assertEquals(testApplication.Id, application.Id);
    }
}