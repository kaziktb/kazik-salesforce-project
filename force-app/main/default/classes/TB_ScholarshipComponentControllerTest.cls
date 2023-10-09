/**
 * Created by annaseveryna on 23/11/2021.
 */
@IsTest
public with sharing class TB_ScholarshipComponentControllerTest {

    @TestSetup
    static void setupMethod() {
        Contact contact = new Contact(
                LastName = 'Kowalski',
                hed__Citizenship__c = 'Angola'
        );
        insert contact;

        Id campusRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('University_Department').getRecordTypeId();
        Account campus = new Account(Name = 'Test Campus', RecordTypeId = campusRecordTypeId);
        insert campus;

        Id facultyRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Academic_Program').getRecordTypeId();
        Account faculty = new Account(Name = 'Test Faculty', RecordTypeId = facultyRecordTypeId);
        insert faculty;

        TB_Offered_Product__c studies = new TB_Offered_Product__c(
                Name = 'Test Studies',
                TB_Campus__c = campus.Id,
                TB_Faculty__c = faculty.Id,
                TB_Mode_of_Study__c = 'Full_Time',
                TB_Level_of_Study__c = 'Bachelor'
        );
        insert studies;

        hed__Application__c application = new hed__Application__c(
                TB_Applying_To_Offered_Product__c = studies.Id,
                TB_Applicant_Citizenship__c = 'Angola',
                TB_HS_Exam_Date__c = Date.newInstance(2020, 07, 20),
                TB_HS_Exam_Score_Top_3__c = 220,
                TB_HS_Exam_Type__c = 'New_Polish_HS_Exam_Since_2005',
                TB_Active__c = true,
                hed__Applicant__c = contact.Id
        );
        insert application;

        Id scholarshipRecordTypeId = SObjectType.TB_Admissions_Dictionary__c.getRecordTypeInfosByDeveloperName().get('TB_Scholarship').getRecordTypeId();
        TB_Admissions_Dictionary__c scholarship = new TB_Admissions_Dictionary__c(
                TB_Valid_From__c = Date.newInstance(2020, 01, 01),
                TB_Valid_To__c = Date.newInstance(2022, 01, 01),
                TB_High_School_Exams__c = 'New_Polish_HS_Exam_Since_2005',
                TB_Mode_of_Study__c = 'Full_Time',
                TB_Citizenships__c = 'Non_Polish_Citizens',
                TB_Level_of_Study__c = 'Bachelor',
                TB_HS_Exam_Date_From__c = Date.newInstance(2015, 01, 01),
                TB_HS_Exam_Min_Points__c = 200,
                TB_Active__c = true,
                TB_Request__c = true,
                TB_Contest_Entry__c = true,
                RecordTypeId = scholarshipRecordTypeId
        );
        insert scholarship;

        Id scholarshipAssignmentId = SObjectType.TB_Admissions_Dictionary__c.getRecordTypeInfosByDeveloperName().get('TB_Scholarship_Assignment').getRecordTypeId();
        TB_Admissions_Dictionary__c assignment = new TB_Admissions_Dictionary__c(
                Name = 'Test Scholarship Assignment',
                TB_Campus__c = campus.Id,
                TB_Faculty__c = faculty.Id,
                TB_Offered_Product__c = studies.Id,
                RecordTypeId = scholarshipAssignmentId,
                TB_Scholarship__c = scholarship.Id
        );
        insert assignment;

        TB_Application_Document__c requestDocument = new TB_Application_Document__c(
                TB_Application__c = application.Id,
                TB_Active__c = true,
                TB_Contact__c = application.hed__Applicant__c,
                TB_Document_Type__c = 'Scan',
                TB_Citizenship_Dependency__c = 'Everyone',
                TB_Order__c = 1000,
                TB_Output_Format__c = 'Original',
                TB_Document_Category__c = 'Application_Request',
                TB_Document_Name_EN__c = 'Scholarship Application Request'
        );
        insert requestDocument;

        TB_Application_Document__c contestEntryDocument = new TB_Application_Document__c(
                TB_Application__c = application.Id,
                TB_Active__c = true,
                TB_Contact__c = application.hed__Applicant__c,
                TB_Document_Type__c = 'Scan',
                TB_Citizenship_Dependency__c = 'Everyone',
                TB_Order__c = 1000,
                TB_Output_Format__c = 'Original',
                TB_Document_Category__c = 'Contest_Entry',
                TB_Document_Name_EN__c = 'Scholarship Application Contest Entry'
        );
        insert contestEntryDocument;
    }

    @IsTest
    public static void matchScholarshipPositive() {
        hed__Application__c application = [SELECT Id, TB_Applicant_Citizenship__c, TB_HS_Exam_Date__c FROM hed__Application__c];

        Test.startTest();
        List<TB_Admissions_Dictionary__c> scholarships = TB_ScholarshipComponentController.matchScholarships(application.Id);
        Test.stopTest();

        System.assertEquals(1, scholarships.size());
    }

    @IsTest
    public static void matchScholarshipWithWrongDate() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c];
        TB_JSON_Wrapper__c scholarshipJSON = [SELECT TB_Wrapper_Value__c FROM TB_JSON_Wrapper__c WHERE TB_Record_Type_Dev_Name__c = 'TB_Scholarship'];
        TB_Admissions_Dictionary__c scholarship = (TB_Admissions_Dictionary__c)JSON.deserialize(scholarshipJSON.TB_Wrapper_Value__c, TB_Admissions_Dictionary__c.class);
        scholarship.TB_Valid_From__c = Date.newInstance(2020, 01, 01);
        scholarship.TB_Valid_To__c = Date.newInstance(2020, 02, 01);
        update scholarship;

        Test.startTest();
        List<TB_Admissions_Dictionary__c> scholarships = TB_ScholarshipComponentController.matchScholarships(application.Id);
        Test.stopTest();

        System.assertEquals(0, scholarships.size());
    }

    @IsTest
    public static void matchScholarshipWithWrongCampus() {
        hed__Application__c application = [SELECT TB_Applying_To_Offered_Product__c FROM hed__Application__c];
        Id campusRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('University_Department').getRecordTypeId();
        Account campus = new Account (Name = 'Another Campus', RecordTypeId = campusRecordTypeId);
        insert campus;
        application.TB_Campus__c = campus.Id;
        update application;

        Test.startTest();
        List<TB_Admissions_Dictionary__c> scholarships = TB_ScholarshipComponentController.matchScholarships(application.Id);
        Test.stopTest();

        System.assertEquals(0, scholarships.size());
    }

    @IsTest
    public static void matchScholarshipWithWrongFaculty() {
        hed__Application__c application = [SELECT TB_Applying_To_Offered_Product__c FROM hed__Application__c];
        Id facultyRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Academic_Program').getRecordTypeId();
        Account faculty = new Account(Name = 'Test Faculty', RecordTypeId = facultyRecordTypeId);
        insert faculty;
        application.TB_Faculty__c = faculty.Id;
        update application;

        Test.startTest();
        List<TB_Admissions_Dictionary__c> scholarships = TB_ScholarshipComponentController.matchScholarships(application.Id);
        Test.stopTest();

        System.assertEquals(0, scholarships.size());
    }

    @IsTest
    public static void matchScholarshipWithWrongStudies() {
        hed__Application__c application = [SELECT TB_Applying_To_Offered_Product__c FROM hed__Application__c];
        TB_Offered_Product__c newStudies = new TB_Offered_Product__c(Name = 'Another Studies');
        insert newStudies;
        application.TB_Applying_To_Offered_Product__c = newStudies.Id;
        update application;

        Test.startTest();
        List<TB_Admissions_Dictionary__c> scholarships = TB_ScholarshipComponentController.matchScholarships(application.Id);
        Test.stopTest();

        System.assertEquals(0, scholarships.size());
    }

    @IsTest
    public static void matchScholarshipWithWrongModeOfStudy() {
        hed__Application__c application = [SELECT TB_Applying_To_Offered_Product__c FROM hed__Application__c];
        application.TB_Mode_of_Study__c = 'Part_Time';
        update application;

        Test.startTest();
        List<TB_Admissions_Dictionary__c> scholarships = TB_ScholarshipComponentController.matchScholarships(application.Id);
        Test.stopTest();

        System.assertEquals(0, scholarships.size());
    }

    @IsTest
    public static void matchScholarshipWithWrongCitizenship() {
        hed__Application__c application = [SELECT TB_Applying_To_Offered_Product__c, hed__Applicant__c FROM hed__Application__c];
        Contact applicant = new Contact(Id = application.hed__Applicant__c, hed__Citizenship__c = 'Poland');
        update applicant;
        application.TB_Applicant_Citizenship__c = 'Poland';
        update application;

        Test.startTest();
        List<TB_Admissions_Dictionary__c> scholarships = TB_ScholarshipComponentController.matchScholarships(application.Id);
        Test.stopTest();

        System.assertEquals(0, scholarships.size());
    }

    @IsTest
    public static void matchScholarshipWithWrongLevelOfStudy() {
        hed__Application__c application = [SELECT TB_Applying_To_Offered_Product__c FROM hed__Application__c];
        application.TB_Level_of_Study__c = 'Master';
        update application;

        Test.startTest();
        List<TB_Admissions_Dictionary__c> scholarships = TB_ScholarshipComponentController.matchScholarships(application.Id);
        Test.stopTest();

        System.assertEquals(0, scholarships.size());
    }

    @IsTest
    public static void matchScholarshipWithWrongHSExamDate() {
        hed__Application__c application = [SELECT TB_Applying_To_Offered_Product__c FROM hed__Application__c];
        application.TB_HS_Exam_Date__c = Date.newInstance(2014, 02, 01);
        update application;

        Test.startTest();
        List<TB_Admissions_Dictionary__c> scholarships = TB_ScholarshipComponentController.matchScholarships(application.Id);
        Test.stopTest();

        System.assertEquals(0, scholarships.size());
    }

    @IsTest
    public static void matchScholarshipWithWrongHSExamPoints() {
        hed__Application__c application = [SELECT TB_Applying_To_Offered_Product__c FROM hed__Application__c];
        application.TB_HS_Exam_Score_Top_3__c = 190;
        update application;

        Test.startTest();
        List<TB_Admissions_Dictionary__c> scholarships = TB_ScholarshipComponentController.matchScholarships(application.Id);
        Test.stopTest();

        System.assertEquals(0, scholarships.size());
    }

    @IsTest
    public static void matchScholarshipWithWrongHSExamType() {
        hed__Application__c application = [SELECT TB_Applying_To_Offered_Product__c FROM hed__Application__c];
        application.TB_HS_Exam_Type__c = 'Foreign_HS_Exam';
        update application;

        Test.startTest();
        List<TB_Admissions_Dictionary__c> scholarships = TB_ScholarshipComponentController.matchScholarships(application.Id);
        Test.stopTest();

        System.assertEquals(0, scholarships.size());
    }

    @IsTest
    public static void loadSelectedPreviouslyScholarshipTest() {
        hed__Application__c application = [SELECT TB_Applying_To_Offered_Product__c, TB_Scholarship__c FROM hed__Application__c];
        TB_JSON_Wrapper__c scholarshipJSON = [SELECT TB_Wrapper_Value__c FROM TB_JSON_Wrapper__c WHERE TB_Record_Type_Dev_Name__c = 'TB_Scholarship'];
        TB_Admissions_Dictionary__c scholarship = (TB_Admissions_Dictionary__c)JSON.deserialize(scholarshipJSON.TB_Wrapper_Value__c, TB_Admissions_Dictionary__c.class);
        application.TB_Scholarship__c = scholarship.Id;
        update application;

        Test.startTest();
        TB_Admissions_Dictionary__c returnedScholarship = TB_ScholarshipComponentController.loadSelectedPreviouslyScholarship(application.Id);
        Test.stopTest();

        System.assertEquals(scholarship.Id, returnedScholarship.Id);
    }

    @IsTest
    public static void updateSelectedScholarshipTestPositive() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c];
        TB_JSON_Wrapper__c scholarshipJSON = [SELECT TB_Wrapper_Value__c FROM TB_JSON_Wrapper__c WHERE TB_Record_Type_Dev_Name__c = 'TB_Scholarship'];
        TB_Admissions_Dictionary__c scholarship = (TB_Admissions_Dictionary__c)JSON.deserialize(scholarshipJSON.TB_Wrapper_Value__c, TB_Admissions_Dictionary__c.class);
        String taxOfficeName = 'Tax Office Name Test';
        String taxOfficeAddress = 'Tax Office Name Address';

        Test.startTest();
        TB_ScholarshipComponentController.updateSelectedScholarship(scholarship.Id, application.Id, taxOfficeName, taxOfficeAddress);
        Test.stopTest();

        hed__Application__c updatedApplication = [
                SELECT TB_Applying_To_Offered_Product__c, TB_Scholarship__c,
                        TB_Scholarship_Status__c, TB_Tax_Office_Name__c, TB_Tax_Office_Address__c
                FROM hed__Application__c];
        System.assertEquals(scholarship.Id, updatedApplication.TB_Scholarship__c);
        System.assertEquals('Requested', updatedApplication.TB_Scholarship_Status__c);
        System.assertEquals('Tax Office Name Test', updatedApplication.TB_Tax_Office_Name__c);
        System.assertEquals('Tax Office Name Address', updatedApplication.TB_Tax_Office_Address__c);
    }

    @IsTest
    public static void createApplicationDocumentsForUploadTest() {
        hed__Application__c application = [SELECT TB_Applying_To_Offered_Product__c, TB_Scholarship__c, TB_Scholarship_Status__c FROM hed__Application__c];
        TB_JSON_Wrapper__c scholarshipJSON = [SELECT TB_Wrapper_Value__c FROM TB_JSON_Wrapper__c WHERE TB_Record_Type_Dev_Name__c = 'TB_Scholarship'];
        TB_Admissions_Dictionary__c scholarship = (TB_Admissions_Dictionary__c)JSON.deserialize(scholarshipJSON.TB_Wrapper_Value__c, TB_Admissions_Dictionary__c.class);

        Test.startTest();
        List<TB_Application_Document__c> createdDocuments = TB_ScholarshipComponentController.createApplicationDocumentsForUpload(application.Id, scholarship.Id);
        Test.stopTest();

        List<TB_Application_Document__c> insertedDocuments = [SELECT Id FROM TB_Application_Document__c WHERE TB_Application__c = :application.Id];
        System.assertEquals(2, createdDocuments.size());
        System.assertEquals(4, insertedDocuments.size());
    }

    @IsTest
    public static void scholarshipApplicationDocumentsTest() {
        hed__Application__c application = [SELECT hed__Applicant__c FROM hed__Application__c];

        Test.startTest();
        List<TB_Application_Document__c> returnedDocuments = TB_ScholarshipComponentController.scholarshipApplicationDocuments(application.Id);
        Test.stopTest();

        System.assertEquals(2, returnedDocuments.size());
    }

    @IsTest
    public static void loadSelectedPreviouslyScholarshipTestNull() {
        hed__Application__c application = [SELECT TB_Applying_To_Offered_Product__c, TB_Scholarship__c FROM hed__Application__c];

        Test.startTest();
        TB_Admissions_Dictionary__c returnedScholarship = TB_ScholarshipComponentController.loadSelectedPreviouslyScholarship(application.Id);
        Test.stopTest();

        System.assertEquals(null, returnedScholarship);
    }

    @IsTest
    public static void updateSelectedScholarshipTestNegative() {
        Boolean isException = false;

        Test.startTest();
        try {
            TB_ScholarshipComponentController.updateSelectedScholarship(null, null, null, null);
        } catch(Exception e) {
            isException = true;
        }
        Test.stopTest();

        System.assertEquals(true, isException);
    }
}