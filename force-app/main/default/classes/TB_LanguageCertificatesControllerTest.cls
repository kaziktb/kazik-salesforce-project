/**
 * Created by Aneta on 07/12/2021.
 */

@IsTest
private class TB_LanguageCertificatesControllerTest {
    @TestSetup
    static void testSetup() {
        TB_Offered_Product__c product = TB_TestDataFactory.createOfferedProduct(false);
        insert product;

        Contact contact = TB_TestDataFactory.createContact(false);
        insert contact;

        hed__Application__c application = TB_TestDataFactory.createApplication(null, product.Id,false);
        application.hed__Applicant__c = contact.Id;
        application.TB_Product_Group__c = TB_Constants.TB_ADMISSIONS_CONTENT_PRODUCT_GROUP_HIGHER_EDUCATION;
        insert application;

        String certificateRecordTypeId = Schema.SObjectType.TB_Experience_History__c.getRecordTypeInfosByDeveloperName().get('TB_Language_Certificate').getRecordTypeId();
        TB_Experience_History__c languageMetric = new TB_Experience_History__c(
            RecordTypeId = certificateRecordTypeId,
            TB_Active__c = true,
            TB_Applicant__c = contact.Id,
            TB_Application__c = application.Id
        );
        insert languageMetric;

        TB_Qualification_Requirement__c requirementPL
            = TB_TestDataFactory.createQualificationRequirementForLanguageCertificate('Polish_Citizens', product.Id, false);
        insert requirementPL;

        TB_Qualification_Requirement__c requirementNoPL
            = TB_TestDataFactory.createQualificationRequirementForLanguageCertificate('Non_Polish_Citizens', product.Id, false);
        insert requirementNoPL;

        TB_Qualification_Requirement__c requirementEV
            = TB_TestDataFactory.createQualificationRequirementForLanguageCertificate('Everyone', product.Id, false);
        insert requirementEV;

        String dictionaryLanguageCertificateId = Schema.SObjectType.TB_Admissions_Dictionary__c.getRecordTypeInfosByDeveloperName().get('TB_Language_Certificate').getRecordTypeId();
        TB_Admissions_Dictionary__c dictionary = new TB_Admissions_Dictionary__c(
            RecordTypeId = dictionaryLanguageCertificateId,
            TB_Language_of_Certificate__c = 'PL',
            TB_Active__c = true
        );
        insert dictionary;
    }

    @IsTest
    static void getAdmissionsDictionaryWrappers() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        Test.startTest();
        TB_LanguageCertificatesController.getAdmissionsDictionaryWrappers(application.Id);
        Test.stopTest();
    }

    @IsTest
    static void getLanguageCertificateMetrics() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        Test.startTest();
        TB_LanguageCertificatesController.getLanguageCertificateMetricsForApplication(application.Id);
        Test.stopTest();
    }

    @IsTest
    static void saveLanguageCertificateMetric() {
        Integer experienceHistorySize = [SELECT Id FROM  TB_Experience_History__c].size();
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        TB_Experience_History__c newCertificateMetric = new TB_Experience_History__c(
            TB_Application__c = application.Id,
            TB_Applicant__c = contact.Id
        );
        Test.startTest();
        TB_LanguageCertificatesController.saveLanguageCertificateMetric(JSON.serialize(newCertificateMetric),null , null);
        Test.stopTest();

        Integer sizeAfter = [SELECT Id FROM  TB_Experience_History__c].size();
        System.assertEquals(sizeAfter, experienceHistorySize + 1);
    }

    @IsTest
    static void saveLanguageCertificateMetricUpdate() {
        Integer experienceHistorySize = [SELECT Id FROM  TB_Experience_History__c].size();
        TB_Experience_History__c metric = [SELECT Id FROM TB_Experience_History__c LIMIT 1];
        Test.startTest();
        TB_LanguageCertificatesController.saveLanguageCertificateMetric(JSON.serialize(metric), null, null);
        Test.stopTest();

        Integer sizeAfter = [SELECT Id FROM  TB_Experience_History__c].size();
        System.assertEquals(sizeAfter, experienceHistorySize);
    }
    
    @IsTest
    static void saveLanguageCertificateMetricNegative() {
        TB_Experience_History__c newCertificateMetric = new TB_Experience_History__c();
        Test.startTest();
        String result = TB_LanguageCertificatesController.saveLanguageCertificateMetric(JSON.serialize(newCertificateMetric), null, null);
        Test.stopTest();
        System.assertEquals(result, 'FAILED');
    }

    @IsTest
    static void deleteLanguageCertificateMetricPositive() {
        Integer experienceHistorySize = [SELECT Id FROM  TB_Experience_History__c].size();
        TB_Experience_History__c experienceHistory = [SELECT Id FROM TB_Experience_History__c LIMIT 1];
        Test.startTest();
        TB_LanguageCertificatesController.deleteLanguageCertificateMetric(experienceHistory.Id);
        Test.stopTest();
        Integer sizeAfter = [SELECT Id FROM  TB_Experience_History__c].size();
        System.assertEquals(sizeAfter, experienceHistorySize - 1);
    }

    @IsTest
    static void deleteLanguageCertificateNegative() {
        Integer experienceHistorySize = [SELECT Id FROM  TB_Experience_History__c].size();
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        TB_LanguageCertificatesController.deleteLanguageCertificateMetric(contact.Id);
        Test.stopTest();

        Integer sizeAfter = [SELECT Id FROM  TB_Experience_History__c].size();
        System.assertEquals(sizeAfter, experienceHistorySize);
    }

    @IsTest
    static void getEmptyCertificateMetric() {
        Test.startTest();
        TB_LanguageCertificatesController.getEmptyCertificateMetric();
        Test.stopTest();
    }

    @IsTest
    static void updateApplicationPositive() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        Test.startTest();
        String result = TB_LanguageCertificatesController.updateApplication(application.Id, true);
        Test.stopTest();
        System.assertEquals('SUCCESS',result);
    }

    @IsTest
    static void updateApplicationNegative() {
        Test.startTest();
        String result = TB_LanguageCertificatesController.updateApplication('', true);
        Test.stopTest();
        System.assertEquals('FAILED',result);
        System.assertEquals([SELECT Id FROM TB_Log__c].size(),1);
    }
}