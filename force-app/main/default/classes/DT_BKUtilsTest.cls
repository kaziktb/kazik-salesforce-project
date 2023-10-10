/**
* @File Name          : DT_BKUtilsTest.cls
* @Description        :
* @Author             : aleksandra.gonta-kacperska@devoteam.com
* @Group              :
* @Last Modified By   : aleksandra.gonta-kacperska@devoteam.com
* @Last Modified On   : 01-28-2022
* @Modification Log   :
* Ver       Date            Author                 Modification
* 1.0    2/18/2020   slawek.wojcik@avalonsolutions.com     Initial Version
**/
@isTest
public with sharing class DT_BKUtilsTest {
    @TestSetup
    public static void dataInit() {
        User adminUser = DT_DataFactory.createAdminUser();
        System.runAs(adminUser) {
            DT_DataFactory.createStudentUser();
        }
    }

    @isTest
    public static void testGetJobOffers() {
        DT_Job_Offers__c jobOffer  = DT_DataFactory.createJobOffers(
            1,true, new DT_Job_Offers__c(
                DT_Valid_Until__c = Date.today() + 30,
                DT_Polish_Required_Picklist__c = 'YES',
                DT_Job_Title__c = 'Developer',
                RecordTypeId = DT_Utils.getRecTypeIdByDevName(DT_Utils.JOB_OFFER_RECORD_TYPE_DEVELOPER_NAME_JOB_OFFER, DT_Utils.SOBJ_JOB_OFFER)
            )
        ).get(0);

        Test.startTest();
            jobOffer.DT_Status__c = DT_Utils.JOB_OFFER_STATUS_PUBLISHED;
            update jobOffer;

        Test.stopTest();

        List<DT_Job_Offers__c> result = DT_BKUtils.getAllJobOffers();
        System.assertEquals(1, result.size(), 'Job offer should be returned');
    }

    @isTest
    public static void testGetInternships() {
        DT_Internship__c internship  = DT_DataFactory.createInternships(
            1,true, new DT_Internship__c(
                DT_Internship_Period_From__c = Date.today() + 30,
                DT_Polish_Required__c = 'YES',
                DT_Name_Of_Position__c = 'Developer'
            )
        ).get(0);

        Test.startTest();
            internship.DT_Status_Of_The_Offer__c = DT_Utils.INTERNSHIP_STATUS_PUBLISHED;
            update internship;

        Test.stopTest();

        List<DT_Internship__c> result = DT_BKUtils.getAllInternships();
        System.assertEquals(1, result.size(), 'Internship should be returned');
    }
    @isTest
    public static void testGetInternshipApplications() {
        List<DT_Internship_Application__c> result;
        User studentUser = DT_TestClassUtils.getUserByEmail(DT_DataFactory.USER_STUDENT_EMAIL);

        DT_Internship_Application__c internshipApp  =  new DT_Internship_Application__c(
            DT_Status__c = 'Draft',
            DT_Provider_Institution__c = 'Devoteam',
            DT_Student__c = studentUser.ContactId
        );

        Test.startTest();
            System.runAs(studentUser){
                insert internshipApp;
                result = DT_BKUtils.getAllInternshipApplications();
            }
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Internship application should be returned');
    }

    @isTest
    public static void testTags() {
        DT_Tag__c tag = DT_DataFactory.createTags(
            1, true, new DT_Tag__c()
        ).get(0);

        User studentUser = DT_TestClassUtils.getUserByEmail(DT_DataFactory.USER_STUDENT_EMAIL);
        System.debug(studentUser);

        DT_DataFactory.createContactTags(
            1, true, new DT_Contact_Tag__c (
                DT_Tag__c = tag.Id,
                DT_Contact__c = studentUser.ContactId
            )
        ).get(0);

        Test.startTest();
        System.runAs(studentUser) {
            List <DT_Contact_Tag__c> currentUserTags = DT_BKUtils.getCurrentUserTags();
            System.assertEquals(1, currentUserTags.size(), 'User Tag should be returned');
        }
        Test.stopTest();

        DT_Job_Offers__c jobOffer = DT_DataFactory.createJobOffers(
            1, true, new DT_Job_Offers__c(
                DT_Valid_Until__c = Date.today() + 30,
                DT_Polish_Required_Picklist__c = 'YES',
                DT_Job_Title__c = 'Developer'
            )
        ).get(0);

        DT_DataFactory.createJobOfferTags(
            1, true, new DT_Job_Offer_Tags__c(
                DT_Tag__c = tag.Id,
                DT_Job_Offers__c = jobOffer.Id
            )
        ).get(0);

        List <DT_Job_Offer_Tags__c> jobOfferTags = DT_BKUtils.getJobTags();
        System.assertEquals(1, jobOfferTags.size(), 'Job offer tag should be returned');
    }
}