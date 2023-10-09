/**
 * @description       : 
 * @author            : aleksandra.gonta-kacperska@devoteam.com
 * @group             : 
 * @last modified on  : 12-09-2021
 * @last modified by  : aleksandra.gonta-kacperska@devoteam.com
**/
@IsTest
public with sharing class DT_DataFactoryTest {

    @IsTest
    public static void createAccountsTest(){
        Account acc = DT_DataFactory.createAccounts(
            1,true, null
        ).get(0);
        DT_DataFactory.createAccounts(1,false, acc);

        List<Account> accounts = [SELECT Id FROM Account];
        System.assertEquals(false, accounts.isEmpty());
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void createContactsTest(){
        Contact contact = DT_DataFactory.createContacts(
            1,true, null
        ).get(0);
        DT_DataFactory.createContacts(1,false, contact);

        List<Contact> contacts = [SELECT Id FROM Contact];
        System.assertEquals(false, contacts.isEmpty());
        System.assertEquals(1, contacts.size());
    }

    @IsTest
    public static void createUsersTest(){
        User user = DT_DataFactory.createUsers(
            1,true, null
        ).get(0);
        DT_DataFactory.createUsers(1,false, user);

        List<User> users = [SELECT Id FROM User LIMIT 1];
        System.assertEquals(false, users.isEmpty());
    }

    @IsTest
    public static void createJobOffersTest(){
        DT_Job_Offers__c jobOffer = DT_DataFactory.createJobOffers(
            1,true, null
        ).get(0);
        DT_DataFactory.createJobOffers(1,false, jobOffer);

        List<DT_Job_Offers__c> jobOffers = [SELECT Id FROM DT_Job_Offers__c];
        System.assertEquals(false, jobOffers.isEmpty());
        System.assertEquals(1, jobOffers.size());
    }

    @IsTest
    public static void createInternshipsTest(){
        DT_Internship__c  internship = DT_DataFactory.createInternships(
            1, true, null
        ).get(0);
        DT_DataFactory.createInternships(1,false, internship);

        List<DT_Internship__c > internships = [SELECT Id FROM DT_Internship__c ];
        System.assertEquals(false, internships.isEmpty());
        System.assertEquals(1, internships.size());
    }

    @IsTest
    public static void createJobOfferApplicationsTest(){
        DT_Job_Offer_Application__c jobOfferApplication = DT_DataFactory.createJobOfferApplications(
            1,true, null
        ).get(0);
        DT_DataFactory.createJobOfferApplications(1,false, jobOfferApplication);

        List<DT_Job_Offer_Application__c> jobOfferApplications = [SELECT Id FROM DT_Job_Offer_Application__c];
        System.assertEquals(false, jobOfferApplications.isEmpty());
        System.assertEquals(1, jobOfferApplications.size());
    }

    @IsTest
    public static void createTagsTest(){
        DT_Tag__c tag = DT_DataFactory.createTags(
            1,true, null
        ).get(0);
        DT_DataFactory.createTags(1,false, tag);

        List<DT_Tag__c> tags = [SELECT Id FROM DT_Tag__c];
        System.assertEquals(false, tags.isEmpty());
        System.assertEquals(1, tags.size());
    }

    @IsTest
    public static void createContactTagsTest(){
        DT_Contact_Tag__c contactTag = DT_DataFactory.createContactTags(
            1,true, null
        ).get(0);
        DT_DataFactory.createContactTags(1,false, contactTag);

        List<DT_Contact_Tag__c> contactTags = [SELECT Id FROM DT_Contact_Tag__c];
        System.assertEquals(false, contactTags.isEmpty());
        System.assertEquals(1, contactTags.size());
    }

    @IsTest
    public static void createInternshipTagsTest(){
        DT_Internship_Tag__c internshipTag = DT_DataFactory.createInternshipTags(
                1,true, new DT_Internship_Tag__c ()
        ).get(0);
        DT_DataFactory.createInternshipTags(1,false, internshipTag);

        List<DT_Internship_Tag__c> internshipTags = [SELECT Id FROM DT_Internship_Tag__c];
        System.assertEquals(false, internshipTags.isEmpty());
        System.assertEquals(1, internshipTags.size());
    }

    @IsTest
    public static void createJobOfferTagsTest(){
        DT_Job_Offer_Tags__c jobOfferTag = DT_DataFactory.createJobOfferTags(
            1,true, null
        ).get(0);
        DT_DataFactory.createJobOfferTags(1,false, jobOfferTag);

        List<DT_Job_Offer_Tags__c> jobOfferTags = [SELECT Id FROM DT_Job_Offer_Tags__c];
        System.assertEquals(false, jobOfferTags.isEmpty());
        System.assertEquals(1, jobOfferTags.size());
    }

    public static void createKnowledgeArticles() {
        Knowledge__kav article = DT_DataFactory.createKnowledgeArticles(
            1, true, null
        ).get(0);
        DT_DataFactory.createKnowledgeArticles(1, false, article);

        List<Knowledge__kav> articles = [SELECT Id FROM Knowledge__kav];
        System.assertEquals(false, articles.isEmpty());
        System.assertEquals(1, articles.size());
    }

    @IsTest
    public static void createCasesTest(){
        Case c = DT_DataFactory.createCases(
            1, true, null
        ).get(0);
        DT_DataFactory.createCases(1,false, c);

        List<Case> cases = [SELECT Id FROM Case];
        System.assertEquals(false, cases.isEmpty());
        System.assertEquals(1, cases.size());
    }
    @IsTest
    public static void createTasksTest(){
        Task task = DT_DataFactory.createTasks(
                1,true, new Task()
        ).get(0);
        DT_DataFactory.createTasks(1,false, task);

        List<Task> tasks = [SELECT Id FROM Task];
        System.assertEquals(false, tasks.isEmpty());
        System.assertEquals(1,tasks.size());
    }

    @IsTest
    public static void createContentVersionsTest(){
        ContentVersion contentVersion = DT_DataFactory.createContentVersions(
                1,true, new ContentVersion()
        ).get(0);
        DT_DataFactory.createContentVersions(1,false, contentVersion);

        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion];
        System.assertEquals(false, contentVersions.isEmpty());
        System.assertEquals(1,contentVersions.size());
    }

    @IsTest
    public static void createProgramPlansTest() {
        hed__Program_Plan__c programPlan = DT_DataFactory.createProgramPlans(
            1, true, null
        ).get(0);
        DT_DataFactory.createProgramPlans(1, false, programPlan);

        List<hed__Program_Plan__c> programPlans = [SELECT Id FROM hed__Program_Plan__c];
        System.assertEquals(false, programPlans.isEmpty());
        System.assertEquals(1, programPlans.size());
    }

    @IsTest
    public static void createProgramEnrollmentsTest() {
        hed__Program_Enrollment__c programEnrollment = DT_DataFactory.createProgramEnrollments(
            1, true, null
        ).get(0);
        DT_DataFactory.createProgramEnrollments(1, false, programEnrollment);

        List<hed__Program_Enrollment__c> programEnrollments = [SELECT Id FROM hed__Program_Enrollment__c];
        System.assertEquals(false, programEnrollments.isEmpty());
        System.assertEquals(1, programEnrollments.size());
    }
}