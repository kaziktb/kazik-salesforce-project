/**
 * @description       : 
 * @author            : aleksandra.gonta-kacperska@devoteam.com
 * @group             : 
 * @last modified on  : 01-19-2022
 * @last modified by  : aleksandra.gonta-kacperska@devoteam.com
 * Modifications Log 
 * Ver   Date         Author                                    Modification
 * 1.0   06-15-2021   aleksandra.gonta-kacperska@devoteam.com   Initial Version
**/
public with sharing class DT_DataFactory {

    /**
     * @Description Method which are implemented to create data base on template has the same arguments:
     * (Integer quantity, Boolean isInsert, SObject sObjectTemplate)
     * Number of records which will be created is described by @quantity argument.
     * Insertion of created records is controlled by @isInsert argument.
     * Set @isInsert to true, so the records will be automatically inserted and added to
     * static map @id2sObjectDataMap.
     * Use @sObjectTemplate argument to create records with predefined fields.
     * For example, to create Contact with with field Email set to 'test@test.com',
     * Set @sObjectTemplate argument to 'new Contact (Email = 'test@test.com').
     * Set @sObjectTemplate argument to 'null' if you won't use template,
     * and create new record with default test values
     */

    /** Account */
    public static final String ACCOUNT_ADMINISTRATIVE_TEST_NAME = 'Student Administrative Account';
    public static final String ACCOUNT_EDUCATIONAL_INSTITUTION_TEST_NAME = 'Test University';
    public static final String ACCOUNT_DEPARTMENT_TEST_NAME = 'Test Department';


    /** Address */
    public static final String ADDRESS_TEST_STREET = 'Test street 20';
    public static final String ADDRESS_TEST_CITY = 'Warsaw';
    public static final String ADDRESS_TEST_COUNTRY = 'Poland';
    public static final String ADDRESS_TEST_POSTAL_CODE = '00-001';

    /** Case */
    public static final String CASE_TEST_SUBJECT = 'Test Subject';
    public static final String CASE_TEST_DESCRIPTION = 'Test Description';

    /** Contact / User */
    public static final String PERSONAL_DATA_TEST_NAME = 'Name';
    public static final String PERSONAL_DATA_TEST_LAST_NAME = 'Test';
    public static final String PERSONAL_DATA_TEST_EMAIL = 'test@test.com.test';
    public static final String PERSONAL_DATA_TEST_ADMIN_EMAIL = 'test@test.admin123.com';
    public static final String PERSONAL_DATA_TEST_PHONE = '+46 123 456 789';
    public static final String USER_STUDENT_EMAIL = 'test123@teststudent.test';
    public static final String CONTACT_STUDENT_EMAIL = 'test123@teststudentcontact.test';
    public static final String INTERNSHIP_SUPERVISOR_NAME = 'Test Supervisor';

    /** Internship Settlement */
    public static final String INTERNSHIP_SETTLEMENT_TYPE_INDIVIDUAL = 'Individual_Internship';

    /** Job Offer */
    public static final String JOB_OFFER_CITY_TEST_NAME = 'Warsaw';

    public static final String USER_TEST_FIRST_NAME_ADMIN = 'Admin';

    /**@Description Main map which stores all created SObjects for future usages.*/
    public static Map<Id, SObject> id2sObjectDataMap;

    /**
     * @Description If you don't insert records straight away,
     * please note that you will have to call below method locally from your test class.
     */
    public static void createDataMapEntry(Id objId, SObject obj) {
        if (id2sObjectDataMap == null) {
            id2sObjectDataMap = new Map<Id, SObject>();
        }
        id2sObjectDataMap.put(objId, obj);
    }

    /**@Description Always use this method to retrieve id2sObjectDataMap entries.*/
    public static SObject getDataMapEntry(Id objId) {
        if (id2sObjectDataMap == null) {
            id2sObjectDataMap = new Map<Id, SObject>();
        }
        if (id2sObjectDataMap.containsKey(objId)) {
            return id2sObjectDataMap.get(objId);
        } else {
            Schema.SObjectType objType = objId.getSobjectType();
            SObject obj = objType.newSObject(objId);
            id2sObjectDataMap.put(objId, obj);
            return obj;
        }
    }

    public static List<Account> createAccounts(
        Integer quantity, Boolean isInsert, Account template
    ) {
        List<Account> accounts = new List<Account>();
        Account accountTemplate;
        for (Integer i = 0; i < quantity; i++) {
            accountTemplate =
                template != null ? template.clone(false, false, false, false) : new Account();

            accountTemplate.Name = accountTemplate.Name != null ?
                accountTemplate.Name : 'test' + Datetime.now().millisecond();
            accountTemplate.RecordTypeId = accountTemplate.RecordTypeId != null ?
                accountTemplate.RecordTypeId : DT_Utils.getRecTypeIdByDevName (
                    DT_Utils.ACCOUNT_EDUCATION_INSTITUTION_RECORD_TYPE_NAME, 'Account'
                );
            accountTemplate.DT_Account_Type__c = accountTemplate.DT_Account_Type__c != null ?
                accountTemplate.DT_Account_Type__c : DT_Utils.ACCOUNT_TYPE_EDUCATIONAL_INSTITUTION;
            accountTemplate.Industry = accountTemplate.Industry != null ?
                accountTemplate.Industry : 'Education';
            accountTemplate.BillingCity = accountTemplate.BillingCity != null ?
                accountTemplate.BillingCity : ADDRESS_TEST_CITY + Datetime.now().millisecond();
            accountTemplate.BillingStreet = accountTemplate.BillingStreet != null ?
                accountTemplate.BillingStreet : ADDRESS_TEST_STREET + Datetime.now().millisecond();
            accountTemplate.BillingPostalCode = accountTemplate.BillingPostalCode != null ?
                accountTemplate.BillingPostalCode : ADDRESS_TEST_POSTAL_CODE + Datetime.now().millisecond();
            accountTemplate.BillingCountry = accountTemplate.BillingCountry != null ?
                accountTemplate.BillingCountry : ADDRESS_TEST_COUNTRY;
            accountTemplate.ShippingCity = accountTemplate.ShippingCity != null ?
                accountTemplate.ShippingCity : accountTemplate.BillingCity;
            accountTemplate.ShippingStreet = accountTemplate.ShippingStreet != null ?
                accountTemplate.ShippingStreet : accountTemplate.BillingStreet;
            accountTemplate.ShippingPostalCode = accountTemplate.ShippingPostalCode != null ?
                accountTemplate.ShippingPostalCode : accountTemplate.BillingPostalCode;
            accountTemplate.ShippingCountry = accountTemplate.ShippingCountry != null ?
                accountTemplate.ShippingCountry : accountTemplate.BillingCountry;
            accounts.add(accountTemplate);
                accountTemplate.DT_Specialty_PL__c = accountTemplate.DT_Specialty_PL__c != null ?
            accountTemplate.DT_Specialty_PL__c: 'Polska Specjalnosc';
                accountTemplate.DT_Specialty_EN__c = accountTemplate.DT_Specialty_EN__c != null ?
            accountTemplate.DT_Specialty_PL__c: 'English Specialty';

        }

        if (isInsert) {
            System.debug('Accounts: ' + JSON.serialize(accounts));
            insert accounts;
            for (Account account : accounts) {
                createDataMapEntry(account.Id, account);
            }
        }
        return accounts;
    }

    public static List<Contact> createContacts(
        Integer quantity, Boolean isInsert, Contact template
    ) {
        Account account = (
            (template != null && template.AccountId != null) ?
                (Account) getDataMapEntry(template.AccountId) :
                createAccounts(1, true, null)[0]
        );
        List<Contact> contacts = new List<Contact>();
        Contact contactTemplate;
        for (Integer i = 0; i < quantity; i++) {
            contactTemplate = template != null ?
                template.clone(false, false, false, false) : new Contact();

            contactTemplate.AccountId = account.Id;
            List<String> salutations = new List<String>{
                'Mr.', 'Ms.', 'Dr.'
            };
            contactTemplate.Salutation = contactTemplate.Salutation != null ?
                contactTemplate.Salutation : salutations.get(Integer.valueOf(Math.random() * salutations.size()));
            contactTemplate.FirstName = contactTemplate.FirstName != null ?
                contactTemplate.FirstName : PERSONAL_DATA_TEST_NAME + String.valueOf(i);
            contactTemplate.LastName = contactTemplate.LastName != null ?
                contactTemplate.LastName : PERSONAL_DATA_TEST_LAST_NAME + String.valueOf(i);
            contactTemplate.MailingStreet = contactTemplate.MailingStreet != null ?
                contactTemplate.MailingStreet : ADDRESS_TEST_STREET;
            contactTemplate.MailingCity = contactTemplate.MailingCity != null ?
                contactTemplate.MailingCity : ADDRESS_TEST_CITY;
            contactTemplate.MailingPostalCode = contactTemplate.MailingPostalCode != null ?
                contactTemplate.MailingPostalCode : ADDRESS_TEST_POSTAL_CODE;
            contactTemplate.MailingCountry = contactTemplate.MailingCountry != null ?
                contactTemplate.MailingCountry : ADDRESS_TEST_COUNTRY;
            contactTemplate.Email = contactTemplate.Email != null ?
                contactTemplate.Email : PERSONAL_DATA_TEST_EMAIL + String.valueOf(i);
            contactTemplate.Phone = contactTemplate.Phone != null ?
                contactTemplate.Phone : PERSONAL_DATA_TEST_PHONE;
            contacts.add(contactTemplate);
        }

        if (isInsert) {
            System.debug('Contacts: ' + JSON.serialize(contacts));
            insert contacts;
            for (Contact contact : contacts) {
                createDataMapEntry(contact.Id, contact);
            }
        }
        return contacts;
    }

    public static List<Case> createCases(
        Integer quantity, Boolean isInsert, Case template
    ) {

        List<Case> cases = new List<Case>();
        Case caseTemplate;
        for (Integer i = 0; i < quantity; i++) {
            caseTemplate = template != null ?
                template.clone(false, false, false, false) : new Case();

            caseTemplate.ContactId = caseTemplate.ContactId != null ?
                caseTemplate.ContactId : createContacts(1, true, null).get(0).Id;
            caseTemplate.RecordTypeId = caseTemplate.RecordTypeId != null ?
                caseTemplate.RecordTypeId : DT_Utils.getRecTypeIdByDevName(DT_Utils.CASE_RECORD_TYPE_NAME_QUESTION, DT_Utils.SOBJ_CASE);
            caseTemplate.Type = caseTemplate.Type != null ?
                caseTemplate.Type : DT_Utils.CASE_TYPE_QUESTION;
            caseTemplate.hed__Category__c = caseTemplate.hed__Category__c != null ?
                caseTemplate.hed__Category__c : DT_Utils.CASE_CATEGORY_ENROLMENTS;
            caseTemplate.DT_Subcategory__c = caseTemplate.DT_Subcategory__c != null ?
                caseTemplate.DT_Subcategory__c : DT_Utils.CASE_SUBCATEGORY_ENROLLMENT_REGISTRATION;
            caseTemplate.Subject = caseTemplate.Subject != null ?
                caseTemplate.Subject : CASE_TEST_SUBJECT;
            caseTemplate.Description = caseTemplate.Description != null ?
                caseTemplate.Description : CASE_TEST_DESCRIPTION;
            caseTemplate.Origin = caseTemplate.Origin != null ?
                caseTemplate.Origin : DT_Utils.CASE_ORIGIN_WEB;
            cases.add(caseTemplate);
        }

        if (isInsert) {
            System.debug('Cases: ' + JSON.serialize(cases));
            insert cases;
            for (Case c : cases) {
                createDataMapEntry(c.Id, c);
            }
        }
        return cases;
    }

    private static Integer usersCreated;
    public static List<User> createUsers(
        Integer quantity, Boolean isInsert, User template
    ) {
        Id profileId = (
            (template != null && template.ProfileId != null) ?
                template.ProfileId : DT_Utils.getProfileIdByName('System Administrator')
        );
        List<User> users = new List<User>();
        User userTemplate;
        for (Integer i = 0; i < quantity; i++) {
            if (usersCreated == null) {
                usersCreated = 1;
            }
            userTemplate = template != null ?
                template.clone(false, false, false, false) : new User();
            userTemplate.LastName = userTemplate.LastName != null ?
                userTemplate.LastName : PERSONAL_DATA_TEST_LAST_NAME;
            userTemplate.Alias = userTemplate.Alias != null ?
                userTemplate.Alias : 'testuser';
            userTemplate.Email = userTemplate.Email != null ?
                userTemplate.Email : PERSONAL_DATA_TEST_EMAIL + String.valueOf(i) + DateTime.now().millisecond();
            userTemplate.EmailEncodingKey = userTemplate.EmailEncodingKey != null ?
                userTemplate.EmailEncodingKey : 'UTF-8';
            userTemplate.LanguageLocaleKey = userTemplate.LanguageLocaleKey != null ?
                userTemplate.LanguageLocaleKey : 'en_US';
            userTemplate.LocaleSidKey = userTemplate.LocaleSidKey != null ?
                userTemplate.LocaleSidKey : 'en_US';
            userTemplate.ProfileId = profileId;
            userTemplate.TimeZoneSidKey = userTemplate.TimeZoneSidKey != null ?
                userTemplate.TimeZoneSidKey : 'Europe/Berlin';
            userTemplate.Username = userTemplate.Username != null ?
                userTemplate.Username : 'testusername' + String.valueOf(i) + userTemplate.Email + String.valueOf(usersCreated++);

            users.add(userTemplate);
        }

        if (isInsert) {
            System.debug('Users: ' + JSON.serialize(users));
            insert users;
            for (User userObj : users) {
                createDataMapEntry(userObj.Id, userObj);
            }
        }

        return users;
    }

    public static List<DT_Internship_Application__c> createInstitutionalInternshipApplications(
            Id internshipOfferId, Id studentContactId, Id careerOfficeEmployeeId, Id supervisorId, Integer quantity, Boolean isInsert
    ) {
        Id institutionalAppRecordTypeId = DT_Utils.getRecTypeIdByDevName(
                DT_Utils.INTERNSHIP_APPLICATION_RECORD_TYPE_INSTITUTIONAL_NAME,
                Schema.DT_Internship_Application__c.getSObjectType().getDescribe().getName()
        );

        List<DT_Internship_Application__c> internshipApplications = new List<DT_Internship_Application__c>();

        for (Integer i = 0; i < quantity; i++) {
            DT_Internship_Application__c internshipApplication = new DT_Internship_Application__c(
                    DT_Career_Office_Employee__c = careerOfficeEmployeeId,
                    DT_Internship__c = internshipOfferId,
                    DT_Student__c = studentContactId,
                    RecordTypeId = institutionalAppRecordTypeId,
                    DT_University_Internship_Supervisor__c = supervisorId,
                    Agreement_Date__c = System.now().date()
            );

            internshipApplications.add(internshipApplication);
        }

        if (isInsert) {
            insert internshipApplications;
        }

        return internshipApplications;
    }

    public static List<DT_Internship_Application__c> createIndividualInternshipApplications(
        Id internshipOfferId, Id studentContactId, Id careerOfficeEmployeeId, Id supervisorId, Integer quantity, Boolean isInsert
    ) {
        Id individualInternshipRecordTypeId = DT_Utils.getRecTypeIdByDevName(
            DT_Utils.INTERNSHIP_APPLICATION_RECORD_TYPE_INDIVIDUAL_NAME,
            Schema.DT_Internship_Application__c.getSObjectType().getDescribe().getName()
        );

        List<DT_Internship_Application__c> internshipApplications = new List<DT_Internship_Application__c>();

        for (Integer i = 0; i < quantity; i++) {
            DT_Internship_Application__c internshipApplication = new DT_Internship_Application__c(
                DT_Career_Office_Employee__c = careerOfficeEmployeeId,
                DT_Internship__c = internshipOfferId,
                DT_Student__c = studentContactId,
                RecordTypeId = individualInternshipRecordTypeId,
                DT_University_Internship_Supervisor__c = supervisorId,
                Agreement_Date__c = System.now().date()
            );

            internshipApplications.add(internshipApplication);
        }

        if (isInsert) {
            insert internshipApplications;
        }

        return internshipApplications;
    }

    public static List<DT_Internship__c> createInternships(
        Integer quantity, Boolean isInsert, DT_Internship__c template
    ) {

        List<DT_Internship__c> internships = new List<DT_Internship__c>();

        DT_Internship__c internshipTemplate;
        for (Integer i = 0; i < quantity; i++) {
            internshipTemplate = template != null ?
                template.clone(false, false, false, false) : new DT_Internship__c();

            internshipTemplate.DT_Name_Of_Position__c = internshipTemplate.DT_Name_Of_Position__c != null ?
                internshipTemplate.DT_Name_Of_Position__c : 'Sample internship no' + String.valueOf(i);
            internshipTemplate.DT_Status_Of_The_Offer__c= internshipTemplate.DT_Status_Of_The_Offer__c != null ?
                internshipTemplate.DT_Status_Of_The_Offer__c : DT_Utils.INTERNSHIP_STATUS_NEW_OFFER;
            internshipTemplate.DT_Company_Name__c = internshipTemplate.DT_Company_Name__c != null ?
                internshipTemplate.DT_Company_Name__c : createAccounts(1, true, null)[0].Id;
            internshipTemplate.DT_Industry__c = internshipTemplate.DT_Industry__c  != null ?
                internshipTemplate.DT_Industry__c  : DT_Utils.INTERNSHIP_INDUSTRY_ARCHITECTURE ;
            internshipTemplate.DT_Description_Of_Completed_Tasks__c = internshipTemplate.DT_Description_Of_Completed_Tasks__c != null ?
                internshipTemplate.DT_Description_Of_Completed_Tasks__c : 'Sample task description';
            internshipTemplate.Agreement_Date__c = internshipTemplate.Agreement_Date__c != null ?
                internshipTemplate.Agreement_Date__c : System.now().date();
       
            internships.add(internshipTemplate);
        }

        if (isInsert) {
            System.debug('Internships: ' + JSON.serialize(internships));
            insert internships;
            for (DT_Internship__c internship : internships) {
                createDataMapEntry(internship.Id, internship);
            }
        }
        return internships;
    }

    public static List<DT_Internship_Learning_Outcomes__c> createInternshipLearningOutcomes(
        Integer quantity, Boolean isInsert, DT_Internship_Settlement__c internshipSettlement
    ) {
        List<DT_Internship_Learning_Outcomes__c> learningOutcomes = new List<DT_Internship_Learning_Outcomes__c>();

        for (Integer i = 0; i < quantity; i++) {
            DT_Internship_Learning_Outcomes__c learningOutcome = new DT_Internship_Learning_Outcomes__c(
                DT_Internship_Report__c = internshipSettlement.Id
            );

            learningOutcomes.add(learningOutcome);
        }

        if (isInsert) {
            insert learningOutcomes;
        }

        return learningOutcomes;
    }

    public static List<DT_Internship_Requirement__c> createInternshipRequirements(Integer quantity, Boolean isInsert) {
        List<DT_Internship_Requirement__c> internshipRequirements = new List<DT_Internship_Requirement__c>();

        for (Integer i = 0; i < quantity; i++) {
            DT_Internship_Requirement__c internshipRequirement = new DT_Internship_Requirement__c();
            internshipRequirements.add(internshipRequirement);
        }

        if (isInsert) {
            insert internshipRequirements;
        }

        return internshipRequirements;
    }

    public static List<DT_Internship_Settlement__c> createIndividualInternshipSettlementsForRequirement(Integer quantity, Id requirementId, Boolean isInsert) {
        List<DT_Internship_Settlement__c> internshipSettlements = new List<DT_Internship_Settlement__c>();

        for (Integer i = 0; i < quantity; i++) {
            DT_Internship_Settlement__c internshipSettlement = new DT_Internship_Settlement__c(
                    DT_Internship_Requirement__c = requirementId,
                    DT_Internship_Type__c = INTERNSHIP_SETTLEMENT_TYPE_INDIVIDUAL
            );
            internshipSettlements.add(internshipSettlement);
        }

        if (isInsert) {
            insert internshipSettlements;
        }
        
        return internshipSettlements;
    }

    public static List<DT_Internship_Supervisor__c> createInternshipSupervisors(
        Integer quantity, Boolean isInsert, DT_Internship_Supervisor__c template
    ) {
        Account account = (
            (template != null && template.DT_Specialty__c != null) ?
                (Account) getDataMapEntry(template.DT_Specialty__c) :
                createAccounts(1, true, new Account(
                    RecordTypeId = DT_Utils.getRecTypeIdByDevName (
                        DT_Utils.ACCOUNT_SPECIALTY_RECORD_TYPE_NAME, DT_Utils.SOBJ_ACCOUNT
                    ),
                    DT_Account_Type__c = DT_Utils.ACCOUNT_TYPE_SPECIALTY,
                    DT_Has_Active_Students__c = true
                )
                )[0]
        );

        User user = (
            (template != null && template.DT_User__c != null) ?
                (User) getDataMapEntry(template.DT_User__c) :
                createUsers(1, true, new User(
                    ProfileId = DT_Utils.getProfileIdByName(DT_Utils.SWPS_CAREER_OFFICE_PROFILE_NAME)
                ))[0]
        );

        List<DT_Internship_Supervisor__c> supervisors = new List<DT_Internship_Supervisor__c>();
        DT_Internship_Supervisor__c supervisorTemplate;
        for (Integer i = 0; i < quantity; i++) {
            supervisorTemplate = template != null ?
                template.clone(false, false, false, false) : new DT_Internship_Supervisor__c();

            supervisorTemplate.DT_Specialty__c = account.Id;
            supervisorTemplate.DT_User__c = user.Id;
            supervisorTemplate.Name = supervisorTemplate.Name != null ?
                supervisorTemplate.Name : INTERNSHIP_SUPERVISOR_NAME + String.valueOf(i) + DateTime.now().millisecond();
            supervisorTemplate.DT_Is_Active__c = supervisorTemplate.DT_Is_Active__c != null ?
                supervisorTemplate.DT_Is_Active__c : true;
            supervisorTemplate.DT_Type__c = supervisorTemplate.DT_Type__c != null ?
                supervisorTemplate.DT_Type__c : DT_Utils.INTERNSHIP_SUPERVISOR_TYPE_SUPERVISOR;

            supervisors.add(supervisorTemplate);
        }

        if (isInsert) {
            System.debug('Internship Supervisors: ' + JSON.serialize(supervisors));
            insert supervisors;
            for (DT_Internship_Supervisor__c supervisor : supervisors) {
                createDataMapEntry(supervisor.Id, supervisor);
            }
        }
        return supervisors;
    }

    public static List<DT_Job_Offers__c> createJobOffers(
        Integer quantity, Boolean isInsert, DT_Job_Offers__c template
    ) {

        List<DT_Job_Offers__c> jobOffers = new List<DT_Job_Offers__c>();

        DT_Job_Offers__c jobOfferTemplate;
        for (Integer i = 0; i < quantity; i++) {
            jobOfferTemplate = template != null ?
                template.clone(false, false, false, false) : new DT_Job_Offers__c();

            jobOfferTemplate.DT_Job_Title__c = jobOfferTemplate.DT_Job_Title__c != null ?
                jobOfferTemplate.DT_Job_Title__c : 'Sample Job no' + String.valueOf(i);
            jobOfferTemplate.DT_Status__c = jobOfferTemplate.DT_Status__c != null ?
                jobOfferTemplate.DT_Status__c : DT_Utils.JOB_OFFER_STATUS_NEW_OFFER;
            jobOfferTemplate.DT_Company_Name__c = jobOfferTemplate.DT_Company_Name__c != null ?
                jobOfferTemplate.DT_Company_Name__c : createAccounts(1, true, null)[0].Id;
            jobOfferTemplate.DT_Business_Category__c = jobOfferTemplate.DT_Business_Category__c != null ?
                jobOfferTemplate.DT_Business_Category__c : DT_Utils.JOB_OFFER_BUSINESS_CATEGORY_ADMINISTRATION;
            jobOfferTemplate.DT_Company_Description__c = jobOfferTemplate.DT_Company_Description__c != null ?
                jobOfferTemplate.DT_Company_Description__c : 'Sample company description';
            jobOfferTemplate.DT_Job_Description__c = jobOfferTemplate.DT_Job_Description__c != null ?
                jobOfferTemplate.DT_Job_Description__c : 'Sample Job Description';
            jobOfferTemplate.DT_We_Offer__c = jobOfferTemplate.DT_We_Offer__c != null ?
                jobOfferTemplate.DT_We_Offer__c : 'Sample offer profits';
            jobOfferTemplate.DT_Employment_Type__c = jobOfferTemplate.DT_Employment_Type__c != null ?
                jobOfferTemplate.DT_Employment_Type__c : DT_Utils.JOB_OFFER_EMPLOYMENT_TYPE_B2B;
            jobOfferTemplate.DT_Weekly_working_hours__c = jobOfferTemplate.DT_Weekly_working_hours__c != null ?
                jobOfferTemplate.DT_Weekly_working_hours__c : 40;
            jobOfferTemplate.DT_Salary__c = jobOfferTemplate.DT_Salary__c != null ?
                jobOfferTemplate.DT_Salary__c : 20;
            jobOfferTemplate.Salary__c = jobOfferTemplate.Salary__c != null ?
                jobOfferTemplate.Salary__c : '4001 - 5000 gross';
            jobOfferTemplate.DT_Requirements__c = jobOfferTemplate.DT_Requirements__c != null ?
                jobOfferTemplate.DT_Requirements__c : 'Sample requirements';
            jobOfferTemplate.DT_Required_Documents__c = jobOfferTemplate.DT_Required_Documents__c != null ?
                jobOfferTemplate.DT_Required_Documents__c : DT_Utils.JOB_OFFER_REQUIRED_DOCUMENTS_CV_PL;
            jobOfferTemplate.DT_Languages__c = jobOfferTemplate.DT_Languages__c != null ?
                jobOfferTemplate.DT_Languages__c : DT_Utils.JOB_OFFER_LANGUAGES_POLISH;
            jobOfferTemplate.DT_City__c = jobOfferTemplate.DT_City__c != null ?
                jobOfferTemplate.DT_City__c : JOB_OFFER_CITY_TEST_NAME;
            /** To clarify pick list values:
            jobOfferTemplate.DT_Job_Location__c = jobOfferTemplate.DT_Job_Location__c != null ?
                    jobOfferTemplate.DT_Job_Location__c : 'Warszawa';
            */

            jobOffers.add(jobOfferTemplate);
        }

        if (isInsert) {
            System.debug('Job offers: ' + JSON.serialize(jobOffers));
            insert jobOffers;
            for (DT_Job_Offers__c jobOffer : jobOffers) {
                createDataMapEntry(jobOffer.Id, jobOffer);
            }
        }
        return jobOffers;
    }

    public static List<DT_Job_Offer_Application__c> createJobOfferApplications(
        Integer quantity, Boolean isInsert, DT_Job_Offer_Application__c template
    ) {

        List<DT_Job_Offer_Application__c> jobOfferApplications = new List<DT_Job_Offer_Application__c>();

        DT_Job_Offers__c jobOffer = (
            (template != null && template.DT_Job_Offer__c != null) ?
                (DT_Job_Offers__c) getDataMapEntry(template.DT_Job_Offer__c) : createJobOffers(1, true, null)[0]
        );

        Contact contact = (
            (template != null && template.DT_Contact__c != null) ?
                (Contact) getDataMapEntry(template.DT_Contact__c) : createContacts(
                1, true, new Contact(
                    RecordTypeId = DT_Utils.getRecTypeIdByDevName(
                        DT_Utils.CONTACT_STUDENT_RECORD_TYPE_DEV_NAME, Contact.getSObjectType().getDescribe().getName()
                    )))[0]
        );

        DT_Job_Offer_Application__c jobOfferApplicationTemplate;
        for (Integer i = 0; i < quantity; i++) {
            jobOfferApplicationTemplate = template != null ?
                template.clone(false, false, false, false) : new DT_Job_Offer_Application__c();
            jobOfferApplicationTemplate.DT_Job_Offer__c = jobOfferApplicationTemplate.DT_Job_Offer__c != null ?
                jobOfferApplicationTemplate.DT_Job_Offer__c : jobOffer.Id;
            jobOfferApplicationTemplate.DT_Contact__c = jobOfferApplicationTemplate.DT_Contact__c != null ?
                jobOfferApplicationTemplate.DT_Contact__c : contact.Id;
            jobOfferApplications.add(jobOfferApplicationTemplate);
        }

        if (isInsert) {
            System.debug('Job offer applications: ' + JSON.serialize(jobOfferApplications));
            insert jobOfferApplications;
            for (DT_Job_Offer_Application__c jobOfferApplication : jobOfferApplications) {
                createDataMapEntry(jobOfferApplication.Id, jobOfferApplication);
            }
        }
        return jobOfferApplications;
    }

    public static List<DT_Tag__c> createTags(
        Integer quantity, Boolean isInsert, DT_Tag__c template
    ) {

        List<DT_Tag__c> tags = new List<DT_Tag__c>();

        DT_Tag__c tagTemplate;
        for (Integer i = 0; i < quantity; i++) {
            tagTemplate = template != null ?
                template.clone(false, false, false, false) : new DT_Tag__c();

            tagTemplate.DT_Category__c = tagTemplate.DT_Category__c != null ?
                tagTemplate.DT_Category__c : DT_Utils.TAG_CATEGORY_PERSONAL;
            tagTemplate.Name = tagTemplate.Name != null ?
                tagTemplate.Name : 'Sample Tag No' + String.valueOf(i);
            tagTemplate.DT_English_Name__c = tagTemplate.DT_English_Name__c != null ?
                tagTemplate.DT_English_Name__c : 'Eng Sample Tag No' + String.valueOf(i);
            tagTemplate.DT_Type__c = tagTemplate.DT_Type__c != null ?
                tagTemplate.DT_Type__c : DT_Utils.TAG_TYPE_COMPETENCES;

            tags.add(tagTemplate);
        }

        if (isInsert) {
            System.debug('Tags: ' + JSON.serialize(tags));
            insert tags;
            for (DT_Tag__c tag : tags) {
                createDataMapEntry(tag.Id, tag);
            }
        }
        return tags;
    }

    public static List<DT_Contact_Tag__c> createContactTags(
        Integer quantity, Boolean isInsert, DT_Contact_Tag__c template
    ) {

        List<DT_Contact_Tag__c> contactTags = new List<DT_Contact_Tag__c>();

        DT_Tag__c tag = (
            (template != null && template.DT_Tag__c != null) ?
                (DT_Tag__c) getDataMapEntry(template.DT_Tag__c) : createTags(1, true, null)[0]
        );

        Contact contact = (
            (template != null && template.DT_Contact__c != null) ?
                (Contact) getDataMapEntry(template.DT_Contact__c) : createContacts(1, true, null)[0]
        );

        DT_Contact_Tag__c contactTagTemplate;
        for (Integer i = 0; i < quantity; i++) {
            contactTagTemplate = template != null ?
                template.clone(false, false, false, false) : new DT_Contact_Tag__c();

            contactTagTemplate.DT_Contact__c = contactTagTemplate.DT_Contact__c != null ?
                contactTagTemplate.DT_Contact__c : contact.Id;
            contactTagTemplate.DT_Tag__c = contactTagTemplate.DT_Tag__c != null ?
                contactTagTemplate.DT_Tag__c : tag.Id;

            contactTags.add(contactTagTemplate);
        }

        if (isInsert) {
            System.debug('Contact tags: ' + JSON.serialize(contactTags));
            insert contactTags;
            for (DT_Contact_Tag__c contactTag : contactTags) {
                createDataMapEntry(contactTag.Id, contactTag);
            }
        }
        return contactTags;
    }

    public static List<DT_Job_Offer_Tags__c> createJobOfferTags(
        Integer quantity, Boolean isInsert, DT_Job_Offer_Tags__c template
    ) {

        List<DT_Job_Offer_Tags__c> jobOfferTagsTags = new List<DT_Job_Offer_Tags__c>();

        DT_Tag__c tag = (
            (template != null && template.DT_Tag__c != null) ?
                (DT_Tag__c) getDataMapEntry(template.DT_Tag__c) : createTags(1, true, null)[0]
        );

        DT_Job_Offers__c jobOffer = (
            (template != null && template.DT_Job_Offers__c != null) ?
                (DT_Job_Offers__c) getDataMapEntry(template.DT_Job_Offers__c) : createJobOffers(1, true, null)[0]
        );

        DT_Job_Offer_Tags__c jobOfferTagTemplate;
        for (Integer i = 0; i < quantity; i++) {
            jobOfferTagTemplate = template != null ?
                template.clone(false, false, false, false) : new DT_Job_Offer_Tags__c();

            jobOfferTagTemplate.DT_Job_Offers__c = jobOfferTagTemplate.DT_Job_Offers__c != null ?
                jobOfferTagTemplate.DT_Job_Offers__c : jobOffer.Id;
            jobOfferTagTemplate.DT_Tag__c = jobOfferTagTemplate.DT_Tag__c != null ?
                jobOfferTagTemplate.DT_Tag__c : tag.Id;

            jobOfferTagsTags.add(jobOfferTagTemplate);
        }

        if (isInsert) {
            System.debug('Job offer tags: ' + JSON.serialize(jobOfferTagsTags));
            insert jobOfferTagsTags;
            for (DT_Job_Offer_Tags__c jobOfferTag : jobOfferTagsTags) {
                createDataMapEntry(jobOfferTag.Id, jobOfferTag);
            }
        }
        return jobOfferTagsTags;
    }
    
    public static List<DT_Internship_Tag__c> createInternshipTags(
            Integer quantity, Boolean isInsert, DT_Internship_Tag__c template
    ) {

        List<DT_Internship_Tag__c> internshipTags = new List<DT_Internship_Tag__c>();

        DT_Tag__c tag = (
                (template != null && template.DT_Tag__c != null) ?
                        (DT_Tag__c) getDataMapEntry(template.DT_Tag__c) : createTags(1, true, null)[0]
        );

        DT_Internship__c internship = (
                (template != null && template.DT_Internship__c  != null) ?
                        (DT_Internship__c ) getDataMapEntry(template.DT_Internship__c ) : createInternships(1, true, null)[0]
        );

        DT_Internship_Tag__c internshipTagTemplate;
        for (Integer i = 0; i < quantity; i++) {
            internshipTagTemplate = template != null ?
                    template.clone(false, false, false, false) : new DT_Internship_Tag__c();

            internshipTagTemplate.DT_Internship__c  =   internshipTagTemplate.DT_Internship__c  != null ?
                    internshipTagTemplate.DT_Internship__c  : internship.Id;
            internshipTagTemplate.DT_Tag__c = internshipTagTemplate.DT_Tag__c != null ?
                    internshipTagTemplate.DT_Tag__c : tag.Id;

            internshipTags.add(internshipTagTemplate);
        }

        if (isInsert) {
            System.debug('Internships tags: ' + JSON.serialize(internshipTags));
            insert internshipTags;
            for (DT_Internship_Tag__c internshipTag : internshipTags) {
                createDataMapEntry(internshipTag.Id, internshipTag);
            }
        }
        return internshipTags;
    }

    public static List<Topic> createTopics(
        Integer quantity, Boolean isInsert, Topic template
    ) {
        List<Topic> topics = new List<Topic>();
        Topic topicTemplate;
        for (Integer i = 0; i < quantity; i++) {
            topicTemplate =
                template != null ? template.clone(false, false, false, false) : new Topic();

            topicTemplate.Name = topicTemplate.Name != null ?
                topicTemplate.Name : 'TestTopic' + Datetime.now().millisecond();
            topics.add(topicTemplate);
        }
        if (isInsert) {
            System.debug('Topics: ' + JSON.serialize(topics));
            insert topics;
            for (Topic topic : topics) {
                createDataMapEntry(topic.Id, topic);
            }
        }
        return topics;
    }
    public static List<Task> createTasks(
            Integer quantity, Boolean isInsert, Task template
    ) {
        List<Task> tasks = new List<Task>();
        Task taskTemplate;
        for (Integer i = 0; i < quantity; i++) {
            taskTemplate =
                    template != null ? template.clone(false, false, false, false) : new Task();

            taskTemplate.Subject = taskTemplate.Subject != null ?
                    taskTemplate.Subject : 'TestTask' + Datetime.now().millisecond();
            tasks.add(taskTemplate);
        }
        if (isInsert) {
            System.debug('Tasks: ' + JSON.serialize(tasks));
            insert tasks;
            for (Task task : tasks) {
                createDataMapEntry(task.Id, task);
            }
        }
        return tasks;
    }
    public static List<ContentVersion> createContentVersions(
            Integer quantity, Boolean isInsert, ContentVersion template
    ) {
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        ContentVersion contentVersionTemplate;
        for (Integer i = 0; i < quantity; i++) {
            contentVersionTemplate =
                    template != null ? template.clone(false, false, false, false) : new ContentVersion();

            contentVersionTemplate.Title = contentVersionTemplate.Title != null ?
                    contentVersionTemplate.Title : 'TestContentVersion' + Datetime.now().millisecond();
            contentVersionTemplate.PathOnClient = contentVersionTemplate.PathOnClient != null ?
                    contentVersionTemplate.PathOnClient : 'TestFile' + i;
            contentVersionTemplate.VersionData = contentVersionTemplate.VersionData != null ?
                    contentVersionTemplate.VersionData : Blob.valueOf('ContentVersion Body' + i);
            contentVersionTemplate.Origin = contentVersionTemplate.Origin != null ?
                    contentVersionTemplate.Origin : 'H';
            contentVersionTemplate.SharingPrivacy = contentVersionTemplate.SharingPrivacy != null ?
                    contentVersionTemplate.SharingPrivacy : 'N';
            contentVersions.add(contentVersionTemplate);
        }
        if (isInsert) {
            System.debug('Content Versions: ' + JSON.serialize(contentVersions));
            insert contentVersions;
            for (ContentVersion contentVersion : contentVersions) {
                createDataMapEntry(contentVersion.Id, contentVersion);
            }
        }
        return contentVersions;
    }

    public static List<Knowledge__kav> createKnowledgeArticles(
        Integer quantity, Boolean isInsert, Knowledge__kav template
    ) {
        List<Knowledge__kav> articles = new List<Knowledge__kav>();
        Knowledge__kav articleTemplate;
        for (Integer i = 0; i < quantity; i++) {
            articleTemplate =
                template != null ? template.clone(false, false, false, false) : new Knowledge__kav();

            articleTemplate.Title = articleTemplate.Title != null ?
                articleTemplate.Title : 'Test Title' + i;
            articleTemplate.DT_Content__c = articleTemplate.DT_Content__c != null ?
                articleTemplate.DT_Content__c : 'Test Content' + Datetime.now().millisecond();
            articleTemplate.UrlName = articleTemplate.UrlName != null ?
                articleTemplate.UrlName : 'test-title' + i;
            articleTemplate.DT_Knowledge_Campus__c = articleTemplate.DT_Knowledge_Campus__c != null ?
                articleTemplate.DT_Knowledge_Campus__c : DT_Utils.KNOWLEDGE_CAMPUS_VALUE_CSS_SWPS;
            articles.add(articleTemplate);
        }

        if (isInsert) {
            System.debug('Articles: ' + JSON.serialize(articles));
            insert articles;
            for (Knowledge__kav article : articles) {
                createDataMapEntry(article.Id, article);
            }
        }
        return articles;
    }

    public static List<hed__Program_Plan__c> createProgramPlans(
        Integer quantity, Boolean isInsert, hed__Program_Plan__c template
    ) {
        Account account = (
            (template != null && template.hed__Account__c != null) ?
                (Account) getDataMapEntry(template.hed__Account__c) :
                createTestAcademicProgram(true, null, null)
        );

        List<hed__Program_Plan__c> programPlans = new List<hed__Program_Plan__c>();
        hed__Program_Plan__c programPlanTemplate;
        for (Integer i = 0; i < quantity; i++) {
            programPlanTemplate =
                template != null ? template.clone(false, false, false, false) : new hed__Program_Plan__c();
            programPlanTemplate.Name = programPlanTemplate.Name != null ?
                programPlanTemplate.Name : 'Test-Program-Plan' + i + Datetime.now().millisecond();
            programPlanTemplate.hed__Account__c = programPlanTemplate.hed__Account__c != null ?
                programPlanTemplate.hed__Account__c : account.Id;
            programPlanTemplate.DT_Campus__c = programPlanTemplate.DT_Campus__c != null ?
                programPlanTemplate.DT_Campus__c : 'Katowice';
            programPlanTemplate.hed__Start_Date__c = programPlanTemplate.hed__Start_Date__c != null ?
                programPlanTemplate.hed__Start_Date__c : Date.today().addDays(-300);
            programPlanTemplate.hed__End_Date__c = programPlanTemplate.hed__End_Date__c != null ?
                programPlanTemplate.hed__End_Date__c : Date.today().addDays(65);
            programPlanTemplate.hed__Status__c = programPlanTemplate.hed__Status__c != null ?
                programPlanTemplate.hed__Status__c : 'Current';
            programPlanTemplate.DT_Mode_of_Studies__c = programPlanTemplate.DT_Mode_of_Studies__c != null ?
                programPlanTemplate.DT_Mode_of_Studies__c : DT_Utils.PROGRAM_PLAN_MODE_OF_STUDIES_FULL_TIME;
            programPlanTemplate.DT_Professional_Title__c = programPlanTemplate.DT_Professional_Title__c != null ?
                programPlanTemplate.DT_Professional_Title__c : DT_Utils.PROGRAM_PLAN_PROFESSIONAL_TITLE_BACHELOR_OF_SCIENCE;
            programPlanTemplate.DT_VDO_ID__c = programPlanTemplate.DT_VDO_ID__c != null ?
                programPlanTemplate.DT_VDO_ID__c : String.valueOf(100 + i) + Datetime.now().millisecond();
            programPlanTemplate.DT_Semesters_Number__c = programPlanTemplate.DT_Semesters_Number__c != null ?
                programPlanTemplate.DT_Semesters_Number__c : 6;
            programPlanTemplate.DT_Product_Code__c = programPlanTemplate.DT_Product_Code__c != null ?
                programPlanTemplate.DT_Product_Code__c : 'K-001-0-1-T-' + String.valueOf(i);
            programPlanTemplate.DT_Language_of_Instruction__c = programPlanTemplate.DT_Language_of_Instruction__c != null ?
                programPlanTemplate.DT_Language_of_Instruction__c : DT_Utils.PROGRAM_PLAN_LANGUAGE_OF_INSTRUCTION_PL;
            programPlanTemplate.DT_Fos_Instance_Name__c = programPlanTemplate.DT_Fos_Instance_Name__c != null ?
                programPlanTemplate.DT_Fos_Instance_Name__c : 'TEST' + String.valueOf(i) + Datetime.now().millisecond();

            programPlans.add(programPlanTemplate);
        }

        if (isInsert) {
            System.debug('Program Plans: ' + JSON.serialize(programPlans));
            insert programPlans;
            for (hed__Program_Plan__c programPlan : programPlans) {
                createDataMapEntry(programPlan.Id, programPlan);
            }
        }
        return programPlans;
    }

    public static List<hed__Program_Enrollment__c> createProgramEnrollments(
        Integer quantity, Boolean isInsert, hed__Program_Enrollment__c template
    ) {
        Account academicProgram;
        hed__Program_Plan__c programPlan;
        Contact contact = (
            (template != null && template.hed__Contact__c != null) ?
                (Contact) getDataMapEntry(template.hed__Contact__c) :
                createStudentContact(CONTACT_STUDENT_EMAIL)
        );

        if (template == null) {
            academicProgram = createTestAcademicProgram(true, null, null);
            programPlan = createProgramPlans(
                1, true, new hed__Program_Plan__c(
                    hed__Account__c = academicProgram.Id
                )
            ).get(0);
        }
        else if (template != null) {
            if (template.hed__Account__c != null) {
                academicProgram = (Account) getDataMapEntry(template.hed__Account__c);
            }

            if (programPlan == null) {
                if (template.hed__Program_Plan__c != null) {
                    programPlan = (hed__Program_Plan__c) getDataMapEntry(template.hed__Program_Plan__c);
                } else {
                    programPlan = createProgramPlans(
                        1, true, new hed__Program_Plan__c(
                            hed__Account__c = academicProgram.Id
                        )
                    ).get(0);
                }
            }

            if (academicProgram == null) {
                if (programPlan != null) {
                    academicProgram = (Account) getDataMapEntry(template.hed__Program_Plan__r.hed__Account__c);
                } else {
                    academicProgram = createTestAcademicProgram(true, null, null);
                }
            }
        }

        List<hed__Program_Enrollment__c> programEnrollments = new List<hed__Program_Enrollment__c>();
        hed__Program_Enrollment__c programEnrollment;
        for (Integer i = 0; i < quantity; i++) {
            programEnrollment =
                template != null ? template.clone(false, false, false, false) : new hed__Program_Enrollment__c();
            programEnrollment.hed__Account__c = programEnrollment.hed__Account__c != null ?
                programEnrollment.hed__Account__c : academicProgram.Id;
            programEnrollment.hed__Contact__c = programEnrollment.hed__Contact__c != null ?
                programEnrollment.hed__Contact__c : contact.Id;
            programEnrollment.hed__Program_Plan__c = programEnrollment.hed__Program_Plan__c != null ?
                programEnrollment.hed__Program_Plan__c : programPlan.Id;
            programEnrollment.DT_Campus__c = programEnrollment.DT_Campus__c != null ?
                programEnrollment.DT_Campus__c : 'Ka';
            programEnrollment.hed__Start_Date__c = programEnrollment.hed__Start_Date__c != null ?
                programEnrollment.hed__Start_Date__c : Date.today().addDays(-300);
            programEnrollment.hed__End_Date__c = programEnrollment.hed__End_Date__c != null ?
                programEnrollment.hed__End_Date__c : Date.today().addDays(65);
            programEnrollment.DT_Department__c = programEnrollment.DT_Department__c != null ?
                programEnrollment.DT_Department__c : '157';
            programEnrollment.DT_Level_Of_Studies__c = programEnrollment.DT_Level_Of_Studies__c != null ?
                programEnrollment.DT_Level_Of_Studies__c : DT_Utils.PROGRAM_PLAN_LEVEL_OF_STUDIES_BACHELOR;
            programEnrollment.DT_Mode_of_Studies__c = programEnrollment.DT_Mode_of_Studies__c != null ?
                programEnrollment.DT_Mode_of_Studies__c : DT_Utils.PROGRAM_PLAN_MODE_OF_STUDIES_FULL_TIME;
            programEnrollment.DT_VDO_ID__c = programEnrollment.DT_VDO_ID__c != null ?
                programEnrollment.DT_VDO_ID__c : String.valueOf(100 + i);
            programEnrollment.DT_Status_by_VDO__c = programEnrollment.DT_Status_by_VDO__c != null ?
                programEnrollment.DT_Status_by_VDO__c : DT_Utils.PROGRAM_ENROLMENT_STATUS_BY_VDO_ACTIVE;
            programEnrollment.DT_Language_of_Instruction__c = programEnrollment.DT_Language_of_Instruction__c != null ?
                programEnrollment.DT_Language_of_Instruction__c : DT_Utils.PROGRAM_PLAN_LANGUAGE_OF_INSTRUCTION_PL;
            programEnrollment.DT_Album_Number__c = programEnrollment.DT_Album_Number__c != null ?
                programEnrollment.DT_Album_Number__c : String.valueOf(10000 + i);
            programEnrollments.add(programEnrollment);
        }

        if (isInsert) {
            System.debug('Program Enrollments: ' + JSON.serialize(programEnrollments));
            insert programEnrollments;
            for (hed__Program_Enrollment__c program : programEnrollments) {
                createDataMapEntry(program.Id, program);
            }
        }
        return programEnrollments;
    }

    /** Dedicated methods */

    //Need to be invoked as administrator User to proper assign UserRole
    public static User createStudentUser() {
        return createStudentUser(USER_STUDENT_EMAIL, null);
    }

    public static Contact createStudentContact(String email) {
        Account account = DT_DataFactory.createAccounts(
            1, true, new Account(
                Name = ACCOUNT_ADMINISTRATIVE_TEST_NAME,
                RecordTypeId = DT_Utils.getRecTypeIdByDevName (
                    DT_Utils.ACCOUNT_ADMINISTRATIVE_RECORD_TYPE_NAME, DT_Utils.SOBJ_ACCOUNT
                ),
                DT_Account_Type__c = DT_Utils.ACCOUNT_TYPE_ADMINISTRATIVE
            )
        ).get(0);

        return DT_DataFactory.createContacts(
            1, true, new Contact(
                AccountId = account.Id,
                Email = email,
                RecordTypeId = DT_Utils.getRecTypeIdByDevName(
                    DT_Utils.CONTACT_STUDENT_RECORD_TYPE_DEV_NAME, Contact.getSObjectType().getDescribe().getName()
                ),
                DT_Is_Student__c = true
            )
        ).get(0);
    }

    public static User createStudentUser(String email, Contact contact) {
        if(contact == null){
           contact = createStudentContact(email);
        }

        User user = DT_DataFactory.createUsers(
            1, true, new User(
                Email = email,
                ProfileId = DT_Utils.getProfileIdByName(DT_Utils.SWPS_STUDENT_PROFILE_NAME),
                ContactId = contact.Id
            )
        ).get(0);
        return user;
    }

    public static User createApplicantUser(String email, Contact contact) {
        if(contact == null){
            contact = createStudentContact(email);
        }

        User user = DT_DataFactory.createUsers(
            1, true, new User(
                Email = email,
                ProfileId = DT_Utils.getProfileIdByName(DT_Utils.SWPS_ADMISSIONS_APPLICANT_PROFILE_NAME),
                ContactId = contact.Id
            )
        ).get(0);
        return user;
    }

    public static User createUserWithProfile(String email, String profileName) {

        User user = DT_DataFactory.createUsers(
            1, true, new User(
                Email = email,
                ProfileId = DT_Utils.getProfileIdByName(profileName)
            )
        ).get(0);
        return user;
    }

    public static User createAdminUser() {
        return DT_DataFactory.createUsers(
            1, true, new User(
                FirstName = USER_TEST_FIRST_NAME_ADMIN,
                Email = PERSONAL_DATA_TEST_ADMIN_EMAIL,
                UserRoleId = DT_Utils.getUserRoleIdByName(
                    DT_Utils.USER_ROLE_ADMIN
                )
            )
        ).get(0);
    }

    /** Create Educational Institution */
    public static Account createTestEducationInstitution(Boolean isInsert) {
        return DT_DataFactory.createAccounts(
            1, isInsert, new Account(
                Name = ACCOUNT_EDUCATIONAL_INSTITUTION_TEST_NAME,
                DT_Short_Name__c = 'TestUni',
                DT_VDO_ID__c = '97',
                RecordTypeId = DT_Utils.getRecTypeIdByDevName (
                    DT_Utils.ACCOUNT_EDUCATION_INSTITUTION_RECORD_TYPE_NAME, DT_Utils.SOBJ_ACCOUNT
                ),
                DT_Account_Type__c = DT_Utils.ACCOUNT_TYPE_EDUCATIONAL_INSTITUTION
            )
        ).get(0);
    }

    /** University Department - Campus */
    public static Account createTestCampus(Boolean isInsert, Id educationalInstitutionId) {
        if(educationalInstitutionId == null){
            educationalInstitutionId = createTestEducationInstitution(true).Id;
        }
        return DT_DataFactory.createAccounts(
            1, isInsert, new Account(
                Name = DT_Utils.ACCOUNT_CAMPUS_NAME_KATOWICE,
                DT_VDO_ID__c = 'Ka',
                ParentId = educationalInstitutionId,
                RecordTypeId = DT_Utils.getRecTypeIdByDevName (
                    DT_Utils.ACCOUNT_UNIVERSITY_DEPARTMENT_RECORD_TYPE_NAME, DT_Utils.SOBJ_ACCOUNT
                ),
                DT_Account_Type__c = DT_Utils.ACCOUNT_TYPE_CAMPUS
            )
        ).get(0);
    }

    /** University Department - Department */
    public static Account createTestDepartment(Boolean isInsert, Id campusId) {
        if(campusId == null){
            campusId = createTestCampus(true, null).Id;
        }
        return DT_DataFactory.createAccounts(
            1, isInsert, new Account(
                Name = ACCOUNT_DEPARTMENT_TEST_NAME,
                DT_Short_Name__c = 'KaTest',
                DT_English_Name__c = 'Faculty of TestCourse in Test Department',
                DT_VDO_ID__c = '234',
                ParentId = campusId,
                RecordTypeId = DT_Utils.getRecTypeIdByDevName (
                    DT_Utils.ACCOUNT_UNIVERSITY_DEPARTMENT_RECORD_TYPE_NAME, DT_Utils.SOBJ_ACCOUNT
                ),
                DT_Account_Type__c = DT_Utils.ACCOUNT_TYPE_DEPARTMENT
            )
        ).get(0);
    }

    /** Academic Program */
    public static Account createTestAcademicProgram(Boolean isInsert, Id departmentId, Account academicProgramTemplate) {
        Account academicProgram;
        if (departmentId == null) {
            departmentId = createTestDepartment(true, null).Id;
        }
        if (academicProgramTemplate != null) {
            academicProgram = DT_DataFactory.createAccounts(1, isInsert, academicProgramTemplate).get(0);
        } else {
            academicProgram = DT_DataFactory.createAccounts(
                1, isInsert, new Account(
                    Name = 'TestCourse, 1st, A, Ka',
                    DT_Profile__c = 'General academic',
                    DT_Level__c = DT_Utils.ACCOUNT_LEVEL_BACHELOR,
                    DT_Study_Field_EN__c = 'TestEn',
                    DT_Study_Field_PL__c = 'TestPL',
                    DT_Philological_Language_List__c = 'eng',
                    DT_VDO_ID__c = '2790',
                    DT_Polon_1_Code__c = '9000',
                    DT_Polon_2_Code__c = '2000',
                    DT_Creation_Date__c = Date.today().addDays(-300),
                    DT_Legal_Basis_Date__c = Date.today().addDays(-300),
                    DT_Fos_Status__c = 'Active',
                    ParentId = departmentId,
                    RecordTypeId = DT_Utils.getRecTypeIdByDevName (
                        DT_Utils.ACCOUNT_ACADEMIC_PROGRAM_RECORD_TYPE_NAME, DT_Utils.SOBJ_ACCOUNT
                    ),
                    DT_Account_Type__c = DT_Utils.ACCOUNT_TYPE_ACADEMIC_PROGRAM
                )
            ).get(0);
        }
        return academicProgram;
    }

    /** Specialty */
    public static Account createTestSpecialty(String name, Boolean isActive, Boolean isInsert) {
        return DT_DataFactory.createAccounts(
            1, isInsert, new Account(
                Name = name,
                DT_Specialty_PL__c = name + ' PL',
                DT_Specialty_EN__c = name + ' EN',
                DT_VDO_ID__c = '432',
                RecordTypeId = DT_Utils.getRecTypeIdByDevName (
                    DT_Utils.ACCOUNT_SPECIALTY_RECORD_TYPE_NAME, DT_Utils.SOBJ_ACCOUNT
                ),
                DT_Account_Type__c = DT_Utils.ACCOUNT_TYPE_SPECIALTY,
                DT_Has_Active_Students__c = isActive
            )
        ).get(0);
    }
}