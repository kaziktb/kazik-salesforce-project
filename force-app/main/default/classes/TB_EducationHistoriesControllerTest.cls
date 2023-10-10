@IsTest
public with sharing class TB_EducationHistoriesControllerTest {

    private static final Integer packetSize = 500;

    @TestSetup
    static void testSetup() {
        TB_StaticTest.setDoNotRunTriggers();
        Individual individual = new Individual(LastName = 'EducationHistories');
        insert individual;
        Contact contact = TB_TestDataFactory.createContact(false);
        contact.RecordTypeId = TB_SObjectUtils.getRecordTypeIdByDevName('Contact', 'TB_Applicant');
        contact.TB_Is_Candidate__c = true;
        insert contact;
        contact.IndividualId = individual.Id;
        update contact;
        Contact student = TB_TestDataFactory.createContact(false);
        student.RecordTypeId = TB_SObjectUtils.getRecordTypeIdByDevName('Contact', 'TB_Student');
        insert student;
        student.IndividualId = individual.Id;
        update student;
        TB_TestDataFactory.createApplicationWithNestedLookup(true, contact.Id);
        hed__Program_Enrollment__c programEnrollment =  new hed__Program_Enrollment__c(
            hed__Contact__c = student.Id,
            hed__Account__c = student.AccountId
        );
        insert programEnrollment;
    }

    static void prepareCache() {
        TB_EducationHistoriesController.getApplications(
            'Name',
            '',
            '',
            true,
            '',
            packetSize,
            ''
        );
        TB_EducationHistoriesController.getContacts(
            'Name',
            'TB_Is_Candidate__c = TRUE',
            1,
            packetSize,
            ''
        );
        TB_EducationHistoriesController.getStudents(
            1,
            packetSize,
            ''
        );
        TB_EducationHistoriesController.getEnrollments(
            'Name',
            '',
            1,
            packetSize,
            ''
        );
    }

    @IsTest
    static void getApplicationsPositive() {
        Test.startTest();
        TB_EducationHistoriesController.getApplications(
            'Name',
            '',
            '',
            true,
            '',
            packetSize,
            ''
        );
        Test.stopTest();

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void getContactsPositive() {
        TB_EducationHistoriesController.getApplications(
            'Name',
            '',
            '',
            true,
            '',
            packetSize,
            ''
        );
        Test.startTest();
        TB_EducationHistoriesController.getContacts(
            'Name',
            'TB_Is_Candidate__c = TRUE',
            1,
            packetSize,
            ''
        );
        Test.stopTest();

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void getStudentsPositive() {
        TB_EducationHistoriesController.getApplications(
            'Name',
            '',
            '',
            true,
            '',
            packetSize,
            ''
        );
        TB_EducationHistoriesController.getContacts(
            'Name',
            'TB_Is_Candidate__c = TRUE',
            1,
            packetSize,
            ''
        );
        Test.startTest();
        TB_EducationHistoriesController.getStudents(
            1,
            packetSize,
            ''
        );
        Test.stopTest();

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void getEnrollmentsPositive() {
        TB_EducationHistoriesController.getApplications(
            'Name',
            '',
            '',
            true,
            '',
            packetSize,
            ''
        );
        TB_EducationHistoriesController.getContacts(
            'Name',
            'TB_Is_Candidate__c = TRUE',
            1,
            packetSize,
            ''
        );
        TB_EducationHistoriesController.getStudents(
            1,
            packetSize,
            ''
        );
        Test.startTest();
        TB_EducationHistoriesController.getEnrollments(
            'Name',
            '',
            1,
            packetSize,
            ''
        );
        Test.stopTest();

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void getRefreshDatePositive() {
        prepareCache();
        Test.startTest();
        TB_EducationHistoriesController.getRefreshDate('');
        Test.stopTest();

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void retrieveRelatedDataPositive() {
        prepareCache();
        Test.startTest();
        List<TB_EducationHistoriesController.EducationHistoryWrapper> result = TB_EducationHistoriesController.retrieveRelatedData(
            'Name',
            'Name',
            'Name',
            1,
            1,
            1,
            1,
            100,
            1,
            'Contact_Id',
            'asc',
            '',
            '',
            ''
        );
        Test.stopTest();

        System.assertEquals(1,result.size());
        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void getUserLanguagePositive() {
        Test.startTest();
        String result = TB_EducationHistoriesController.getUserLanguage();
        Test.stopTest();

        System.assertNotEquals(null,result);
        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void retrieveColumnDataPositive() {
        Test.startTest();
        String resultJSON = TB_EducationHistoriesController.retrieveColumnData(
            true, false,
            'Name',
            'Name',
            'Name'
        );
        Test.stopTest();

        List<TB_EducationHistoriesController.ResponseWrapper> result =
            (List<TB_EducationHistoriesController.ResponseWrapper>) JSON.deserialize(
                resultJSON, List<TB_EducationHistoriesController.ResponseWrapper>.class);

        System.assertEquals(4,result.size());
    }

}