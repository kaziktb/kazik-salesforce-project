/**
 * Created by Aneta on 07/12/2021.
 */

@IsTest
private class TB_HighSchoolEducationControllerTest {
    
    @TestSetup
    static void testSetup() {

        TB_Offered_Product__c product = TB_TestDataFactory.createOfferedProduct(false);
        insert product;

        Contact contact = new Contact(
            LastName = 'Kowalski'
        );
        insert contact;

        hed__Application__c application = TB_TestDataFactory.createApplication(null,product.Id,false);
        application.hed__Applicant__c = contact.Id;
        application.TB_Product_Group__c = 'Higher_Education';
        insert application;

        String localEducationalComId = Schema.SObjectType.TB_Admissions_Dictionary__c.getRecordTypeInfosByDeveloperName().get('TB_Local_Educational_Committee').getRecordTypeId();
        TB_Admissions_Dictionary__c admissionsLocalEducation = new TB_Admissions_Dictionary__c(
            Name = 'Okręgowa komisja CKE Warszawa',
            RecordTypeId = localEducationalComId
        );
        insert admissionsLocalEducation;

        String examTypeId = Schema.SObjectType.TB_Admissions_Dictionary__c.getRecordTypeInfosByDeveloperName().get('TB_High_School_Exam_Type').getRecordTypeId();
        TB_Admissions_Dictionary__c admissionsExamType = new TB_Admissions_Dictionary__c(
            Name = 'Type',
            TB_Number_of_Maturity_Subjects__c = 3,
            RecordTypeId = examTypeId
        );
        insert admissionsExamType;

        String examSubTypeId = Schema.SObjectType.TB_Admissions_Dictionary__c.getRecordTypeInfosByDeveloperName().get('TB_High_School_Exam_Sub_Type').getRecordTypeId();
        TB_Admissions_Dictionary__c admissionsExamSubType = new TB_Admissions_Dictionary__c(
            Name = 'SubType',
            RecordTypeId = examSubTypeId,
            TB_Country__c = 'PL;US'
        );
        insert admissionsExamSubType;

        String examMetricRecordTypeId = Schema.SObjectType.TB_Experience_History__c.getRecordTypeInfosByDeveloperName().get('TB_HS_Exam_Metric').getRecordTypeId();
        TB_Experience_History__c examMetric = new TB_Experience_History__c(
            RecordTypeId = examMetricRecordTypeId
        );
        insert examMetric;
    }

    @IsTest
    static void getAdmissionsDictionaryWrapper() {
        Test.startTest();
        TB_HighSchoolEducationController.getAdmissionsDictionaryWrapperForHSExam();
        Test.stopTest();
    }

    @IsTest
    static void prepareHSExamFieldsMap() {
        Test.startTest();
        TB_HighSchoolEducationController.prepareHSExamFieldsMap();
        Test.stopTest();
    }

    @IsTest
    static void getHSExamMetric() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        Test.startTest();
        TB_HighSchoolEducationController.getHSExamMetric(application.Id);
        Test.stopTest();
    }

    @IsTest
    static void createHSExamMetricPositive() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        String examMetricRecordTypeId = Schema.SObjectType.TB_Experience_History__c.getRecordTypeInfosByDeveloperName().get('TB_HS_Exam_Metric').getRecordTypeId();
        TB_Experience_History__c examMetric = new TB_Experience_History__c(
            RecordTypeId = examMetricRecordTypeId,
            TB_Not_Diploma__c = false,
            TB_Application__c = application.Id
        );
        Test.startTest();
        TB_HighSchoolEducationController.createHSExamMetric(JSON.serialize(examMetric), false, false);
        Test.stopTest();
    }

    @IsTest
    static void createHSExamMetricNegative() {
        String examMetricRecordTypeId = Schema.SObjectType.TB_Experience_History__c.getRecordTypeInfosByDeveloperName().get('TB_HS_Exam_Metric').getRecordTypeId();
        TB_Experience_History__c examMetric = new TB_Experience_History__c(
            RecordTypeId = examMetricRecordTypeId,
            TB_Not_Diploma__c = false
        );
        Test.startTest();
        TB_HighSchoolEducationController.createHSExamMetric(JSON.serialize(examMetric), false, false);
        Test.stopTest();
    }

    @IsTest
    static void updateHSExamMetricPositive() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        TB_Experience_History__c examMetric = [SELECT Id FROM TB_Experience_History__c LIMIT 1];
        Test.startTest();
        TB_HighSchoolEducationController.updateHSExamMetric(JSON.serialize(examMetric), 'TB_Document_Issue_City__c;TB_Document_Number__c', false, application.Id);
        Test.stopTest();
    }

    @IsTest
    static void updateHSExamMetricNegative() {
        TB_Experience_History__c examMetric = [SELECT Id FROM TB_Experience_History__c LIMIT 1];
        Test.startTest();
        TB_HighSchoolEducationController.updateHSExamMetric(JSON.serialize(examMetric), 'TB_Document_Issue_City__c;TB_Document_Number__c', false, examMetric.Id);
        Test.stopTest();
    }

    @IsTest
    static void handleExamScoreMetrics() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        TB_Experience_History__c examMetric = [SELECT Id FROM TB_Experience_History__c LIMIT 1];
        TB_Admissions_Dictionary__c admissionsDictionary = [SELECT Id, TB_Number_of_Maturity_Subjects__c FROM TB_Admissions_Dictionary__c WHERE Name = 'Type' LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        TB_HighSchoolEducationController.handleExamScoreMetrics(JSON.serialize(admissionsDictionary), application.Id, contact.Id, examMetric.Id, true, true);
        Test.stopTest();
    }

    @IsTest
    static void getApplicationDocuments() {
        TB_Experience_History__c examMetric = [SELECT Id FROM TB_Experience_History__c LIMIT 1];
        Test.startTest();
        TB_HighSchoolEducationController.getApplicationDocuments(examMetric.Id);
        Test.stopTest();
    }

    @IsTest
    static void updateApplicationDocuments() {
        TB_Experience_History__c examMetric = [SELECT Id, TB_Application__c, TB_Applicant__c FROM TB_Experience_History__c LIMIT 1];
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        Test.startTest();
        TB_HighSchoolEducationController.updateApplicationDocuments(true, true, JSON.serialize(examMetric), application.Id , true);
        Test.stopTest();
    }
}