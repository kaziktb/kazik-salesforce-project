/**
 * @description       : 
 * @author            : aleksandra.gonta-kacperska@devoteam.com
 * @group             : 
 * @last modified on  : 12-03-2021
 * @last modified by  : aleksandra.gonta-kacperska@devoteam.com
**/
@IsTest
public class DT_CTTagsCtrlTest {
    private static final String USER_EMAIL = 'test123@cttag.test';
    private static final String TAG_NAME_JAVA = 'Java';
    private static final String TAG_NAME_DOCKER = 'Docker';
    private static final String TAG_NAME_RESISTANT_FOR_STRESS = 'Resistant For Stress';
    private static final String TAG_NAME_SELF_MOTIVATED = 'Self Motivated';
    private static final String JOB_OFFER_TITLE = 'Junior Java Developer';
    private static final String INTERNSHIP_COMPANY = 'Devoteam';
    private static final String GUEST_LANGUAGE = 'pl';


    @TestSetup
    public static void dataInit() {
        User adminUser = DT_DataFactory.createAdminUser();

        System.runAs(adminUser) {
            Account account = DT_DataFactory.createAccounts(
                1, true, new Account(
                    Name = 'Student Administrative Account',
                    RecordTypeId = DT_Utils.getRecTypeIdByDevName (
                        DT_Utils.ACCOUNT_ADMINISTRATIVE_RECORD_TYPE_NAME, 'Account'
                    ),
                    DT_Account_Type__c = DT_Utils.ACCOUNT_TYPE_ADMINISTRATIVE
                )
            ).get(0);

            Contact contact = DT_DataFactory.createContacts(
                1, true, new Contact(
                    AccountId = account.Id,
                    Email = USER_EMAIL
                )
            ).get(0);

            User user = DT_DataFactory.createUsers(
                1, true, new User(
                    Email = USER_EMAIL,
                    ProfileId = DT_Utils.getProfileIdByName('SWPS Student'),
                    ContactId = contact.Id
                )
            ).get(0);

            DT_Job_Offers__c jobOffer = DT_DataFactory.createJobOffers(
                1, true, new DT_Job_Offers__c(
                    DT_Job_Title__c = JOB_OFFER_TITLE
                )
            ).get(0);

            DT_Internship__c internship = DT_DataFactory.createInternships(
                1, true, new DT_Internship__c(
                    DT_Full_Name_Of_The_Organization__c = INTERNSHIP_COMPANY
                )
            ).get(0);

            DT_Tag__c tag = DT_DataFactory.createTags(
                1, true, new DT_Tag__c(
                    Name = TAG_NAME_JAVA,
                    DT_Category__c = DT_Utils.TAG_CATEGORY_PROFESSIONAL
                )
            ).get(0);
            DT_DataFactory.createContactTags(
                1, true, new DT_Contact_Tag__c(
                    DT_Contact__c = contact.Id,
                    DT_Tag__c = tag.Id,
                    DT_isProposed__c = true
                )
            );
            DT_DataFactory.createJobOfferTags(
                1, true, new DT_Job_Offer_Tags__c(
                    DT_Job_Offers__c = jobOffer.Id,
                    DT_Tag__c = tag.Id
                )
            );
            DT_DataFactory.createInternshipTags(
                    1, true, new DT_Internship_Tag__c(
                            DT_Internship__c = internship.Id,
                            DT_Tag__c = tag.Id
                    )
            );

            List<DT_Tag__c> newTags = new List<DT_Tag__c>();

            newTags.add(
                DT_DataFactory.createTags(
                    1, false, new DT_Tag__c (
                        Name = TAG_NAME_DOCKER,
                        DT_Category__c = DT_Utils.TAG_CATEGORY_PROFESSIONAL
                    )
                ).get(0)
            );

            newTags.add(
                DT_DataFactory.createTags(
                    1, false, new DT_Tag__c (
                        Name = TAG_NAME_RESISTANT_FOR_STRESS,
                        DT_Category__c = DT_Utils.TAG_CATEGORY_PERSONAL,
                        DT_Type__c = DT_Utils.TAG_TYPE_COMPETENCES
                    )
                ).get(0)
            );

            newTags.add(
                DT_DataFactory.createTags(
                    1, false, new DT_Tag__c (
                        Name = TAG_NAME_SELF_MOTIVATED,
                        DT_Category__c = DT_Utils.TAG_CATEGORY_PERSONAL,
                        DT_Type__c = DT_Utils.TAG_TYPE_COMPETENCES
                    )
                ).get(0)
            );
            insert newTags;
        }
    }

    @IsTest
    public static void getRecordTagsTest() {
        Map<Id, SObject> id2sobject;
        User studentUser = DT_TestClassUtils.getUserByEmail(USER_EMAIL);
        DT_Job_Offers__c jobOffer = DT_TestClassUtils.getJobOfferByTitle(JOB_OFFER_TITLE);
        DT_Internship__c internship = DT_TestClassUtils.getInternshipByCompany(INTERNSHIP_COMPANY);

        Test.startTest();
            /** SObject type Contact */
            id2sobject = DT_CTTagsCtrl.getRecordTags(DT_Utils.SOBJ_CONTACT, studentUser.ContactId, true);
            System.assertEquals(false, id2sobject.isEmpty());
            System.assertEquals(1, id2sobject.size());

            System.runAs(studentUser){
                /**  SObject type User */
                id2sobject = DT_CTTagsCtrl.getRecordTags(DT_Utils.SOBJ_USER, studentUser.Id, true);
                System.assertEquals(false, id2sobject.isEmpty());
                System.assertEquals(1, id2sobject.size());
            }

            /** SObject type Job Offer */
            id2sobject = DT_CTTagsCtrl.getRecordTags(DT_Utils.SOBJ_JOB_OFFER, jobOffer.Id, false);
            System.assertEquals(false, id2sobject.isEmpty());
            System.assertEquals(1, id2sobject.size());

            /** SObject type Internship */
            id2sobject = DT_CTTagsCtrl.getRecordTags(DT_Utils.SOBJ_INTERNSHIP, internship.Id, false);
            System.assertEquals(false, id2sobject.isEmpty());
            System.assertEquals(1, id2sobject.size());
        Test.stopTest();

    }

    @IsTest
    public static void handleTagItemAddToContactTest() {
        /** fetch data */
        DT_Tag__c newTag = DT_TestClassUtils.getTagByName(TAG_NAME_DOCKER);
        Contact student = DT_TestClassUtils.getContactByEmail(USER_EMAIL);
        System.assertEquals(1, student.Contact_Tags__r.size());

        Test.startTest();
            /** Contact */
            DT_CTTagsCtrl.save(DT_Utils.SOBJ_CONTACT, student.Id, new List<String>(), new List<String>{newTag.Id}, false);
        Test.stopTest();

        student = DT_TestClassUtils.getContactByEmail(USER_EMAIL);
        System.assertEquals(2, student.Contact_Tags__r.size());
    }

    @IsTest
    public static void handleTagItemAddToUserTest() {
        /** fetch data */
        DT_Tag__c newTag = DT_TestClassUtils.getTagByName(TAG_NAME_DOCKER);
        User user = DT_TestClassUtils.getUserByEmail(USER_EMAIL);
        Contact student = DT_TestClassUtils.getContactByEmail(USER_EMAIL);
        System.assertEquals(1, student.Contact_Tags__r.size());

        Test.startTest();
        /** User */
        System.runAs(user){
            DT_CTTagsCtrl.save(
                DT_Utils.SOBJ_USER, user.Id, new List<String>(), new List<String>{newTag.Id}, false
            );
        }
        Test.stopTest();
        student = DT_TestClassUtils.getContactByEmail(USER_EMAIL);
        System.assertEquals(2, student.Contact_Tags__r.size());
    }


    @IsTest
    public static void handleTagItemAddToJobOfferTest() {
        /** fetch data */
        DT_Tag__c newTag = DT_TestClassUtils.getTagByName(TAG_NAME_DOCKER);
        DT_Job_Offers__c jobOffer = DT_TestClassUtils.getJobOfferByTitle(JOB_OFFER_TITLE);
        System.assertEquals(1, jobOffer.Job_Offer_Tags__r.size());

        Test.startTest();
        /** Job Offer */
            DT_CTTagsCtrl.save(
                DT_Utils.SOBJ_JOB_OFFER, jobOffer.Id, new List<String>(), new List<String>{newTag.Id}, false
            );
        Test.stopTest();

        jobOffer = DT_TestClassUtils.getJobOfferByTitle(JOB_OFFER_TITLE);

        System.assertEquals(2, jobOffer.Job_Offer_Tags__r.size());
    }
    @IsTest
    public static void handleTagItemAddToInternshipTest() {
        /** fetch data */
        DT_Tag__c newTag = DT_TestClassUtils.getTagByName(TAG_NAME_DOCKER);
        DT_Internship__c internship = DT_TestClassUtils.getInternshipByCompany(INTERNSHIP_COMPANY);
        System.assertEquals(1, internship.Internship_Tags__r.size());

        Test.startTest();

        /** Internship */
            DT_CTTagsCtrl.save(
                DT_Utils.SOBJ_INTERNSHIP, internship.Id, new List<String>(), new List<String>{newTag.Id}, false
            );
        Test.stopTest();

        internship = DT_TestClassUtils.getInternshipByCompany(INTERNSHIP_COMPANY);
        System.assertEquals(2, internship.Internship_Tags__r.size());
    }

    @IsTest
    public static void handleTagItemRemoveFromContactTest() {
        /** fetch data */
        Contact student = DT_TestClassUtils.getContactByEmail(USER_EMAIL);
        DT_Contact_Tag__c existingContactTag = student.Contact_Tags__r.get(0);
        System.assertEquals(1, student.Contact_Tags__r.size());

        Test.startTest();
        /** Contact */
        DT_CTTagsCtrl.save(DT_Utils.SOBJ_CONTACT, student.Id, new List<String>{existingContactTag.Id}, new List<String>{}, false);
        Test.stopTest();

        student = DT_TestClassUtils.getContactByEmail(USER_EMAIL);
        System.assertEquals(0, student.Contact_Tags__r.size());
    }

    @IsTest
    public static void handleTagItemRemoveFromUserTest() {
        /** fetch data */
        User user = DT_TestClassUtils.getUserByEmail(USER_EMAIL);
        Contact student = DT_TestClassUtils.getContactByEmail(USER_EMAIL);
        DT_Contact_Tag__c existingContactTag = student.Contact_Tags__r.get(0);
        System.assertEquals(1, student.Contact_Tags__r.size());

        Test.startTest();
        /** User */
        System.runAs(user){
            DT_CTTagsCtrl.save(
                DT_Utils.SOBJ_USER, user.Id, new List<String>{existingContactTag.Id}, new List<String>{}, false
            );
        }
        Test.stopTest();
        student = DT_TestClassUtils.getContactByEmail(USER_EMAIL);
        System.assertEquals(0, student.Contact_Tags__r.size());
    }


    @IsTest
    public static void handleTagItemRemoveFromJobOfferTest() {
        /** fetch data */
        DT_Job_Offers__c jobOffer = DT_TestClassUtils.getJobOfferByTitle(JOB_OFFER_TITLE);
        DT_Job_Offer_Tags__c existingJobOfferTag  = jobOffer.Job_Offer_Tags__r.get(0);
        System.assertEquals(1, jobOffer.Job_Offer_Tags__r.size());

        Test.startTest();
        /** Job Offer */
        DT_CTTagsCtrl.save(
            DT_Utils.SOBJ_JOB_OFFER, jobOffer.Id, new List<String>{existingJobOfferTag.Id}, new List<String>{}, false
        );
        Test.stopTest();

        jobOffer = DT_TestClassUtils.getJobOfferByTitle(JOB_OFFER_TITLE);

        System.assertEquals(0, jobOffer.Job_Offer_Tags__r.size());
    }
    @IsTest
    public static void handleTagItemRemoveFromInternshipTest() {
        /** fetch data */
        DT_Internship__c internship = DT_TestClassUtils.getInternshipByCompany(INTERNSHIP_COMPANY);
        DT_Internship_Tag__c existingInternshipTag  = internship.Internship_Tags__r.get(0);
        System.assertEquals(1, internship.Internship_Tags__r.size());

        Test.startTest();
        /** Internship */
        DT_CTTagsCtrl.save(
                DT_Utils.SOBJ_INTERNSHIP, internship.Id, new List<String>{existingInternshipTag.Id}, new List<String>{}, false
        );
        Test.stopTest();

        internship = DT_TestClassUtils.getInternshipByCompany(INTERNSHIP_COMPANY);
        System.assertEquals(0, internship.Internship_Tags__r.size());
    }

    @IsTest
    public static void searchTagsTest(){
        /** fetch data */
        DT_Tag__c tag1 = DT_TestClassUtils.getTagByName(TAG_NAME_SELF_MOTIVATED);
        DT_Tag__c tag2 = DT_TestClassUtils.getTagByName(TAG_NAME_RESISTANT_FOR_STRESS);
        List<DT_Tag__c> foundTags;

        Test.startTest();
            /** Full code covered scenario */
            foundTags = DT_CTTagsCtrl.searchTags(
                DT_Utils.TAG_CATEGORY_PERSONAL, DT_Utils.TAG_TYPE_COMPETENCES, TAG_NAME_RESISTANT_FOR_STRESS, new List<String>{tag1.Id}, GUEST_LANGUAGE
            );
        Test.stopTest();
        System.assertEquals(1, foundTags.size());
        System.assertEquals(tag2.Name, foundTags.get(0).Name);
    }
}