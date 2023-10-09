/**
 * @File Name          : DT_JobOfferUtilsTest.cls
 * @Description        : 
 * @Author             : aleksandra.gonta-kacperska@devoteam.com
 * @Group              : 
 * @Last Modified By   : aleksandra.gonta-kacperska@devoteam.com
 * @Last Modified On   : 06-15-2021
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    2/28/2020   Andrzej Cieślak (andrzej.cieslak@avalonsolutions.com)     Initial Version
**/
@isTest
private with sharing class DT_JobOfferUtilsTest {
    @TestSetup
    public static void dataInit() {
        User adminUser = DT_DataFactory.createAdminUser();
        System.runAs(adminUser) {
            DT_DataFactory.createStudentUser();
        }
    }

    @isTest
    static void testViewAndClickCounter() {
        User studentUser = DT_TestClassUtils.getUserByEmail(DT_DataFactory.USER_STUDENT_EMAIL);

        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Organization').getRecordTypeId();
        Account acc = new Account(Name = 'Test Account', RecordTypeId = recordTypeId);
        insert acc;

        DT_Job_Offers__c jobOffer = DT_DataFactory.createJobOffers(
            1, true, new DT_Job_Offers__c(
                DT_Company_Name__c = acc.Id,
                DT_Polish_Required_Picklist__c = 'Yes',
                DT_Views__c = null
            )
        ).get(0);

        jobOffer = [SELECT DT_Views__c, DT_Clicks__c FROM DT_Job_Offers__c WHERE Id = :jobOffer.Id LIMIT 1];
        System.assertEquals(0, jobOffer.DT_Clicks__c, 'A new job offer should have 0 clicks');


        Test.startTest();
        System.runAs(studentUser) {
            DT_JobOfferUtils.addViews(jobOffer.Id);
            DT_JobOfferUtils.addViews(jobOffer.Id);
            DT_JobOfferUtils.addViews(jobOffer.Id);
            DT_JobOfferUtils.addClicks(jobOffer.Id);
            DT_JobOfferUtils.addClicks(jobOffer.Id);
        }
        Test.stopTest();

        jobOffer = [SELECT DT_Views__c, DT_Clicks__c FROM DT_Job_Offers__c WHERE Id = :jobOffer.Id LIMIT 1];
        System.assertEquals(3, jobOffer.DT_Views__c, 'A new job offer should have 2 views');
        System.assertEquals(2, jobOffer.DT_Clicks__c, 'A new job offer should have 1 clicks');
    }
    
}