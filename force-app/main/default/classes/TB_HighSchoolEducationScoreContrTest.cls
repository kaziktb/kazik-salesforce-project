/**
 * Created by Aneta on 07/12/2021.
 */


@IsTest
private class TB_HighSchoolEducationScoreContrTest {

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

        String subjectScoreRecordTypeId = Schema.SObjectType.TB_Admissions_Dictionary__c.getRecordTypeInfosByDeveloperName().get('TB_High_School_Exam_Sub_Type').getRecordTypeId();
        TB_Admissions_Dictionary__c admissionsScoreDictionary = new TB_Admissions_Dictionary__c(
            Name = 'Subject_Score',
            TB_HS_Exam_Type__c = 'Foreign_HS_Exam',
            TB_HS_Exam_Sub_Type__c = 'USA_GED',
            RecordTypeId = subjectScoreRecordTypeId,
            TB_Country__c = 'PL;US'
        );
        insert admissionsScoreDictionary;

        TB_Experience_History__c examMetric = new TB_Experience_History__c(
            RecordTypeId = TB_re_Constants.TB_EDUCATION_EXP_HS_EXAM_METRIC_RT_ID,
            TB_Educational_Institution_City__c = 'Metric'
        );
        insert examMetric;

        String subjectMetricRecordTypeId = Schema.SObjectType.TB_Experience_History__c.getRecordTypeInfosByDeveloperName().get('TB_HS_Exam_Subjects').getRecordTypeId();
        TB_Experience_History__c subjectMetric = new TB_Experience_History__c(
            RecordTypeId = subjectMetricRecordTypeId,
            TB_Educational_Institution_City__c = 'Warsaw',
            TB_HS_Exam_Metric__c = examMetric.Id,
            TB_Application__c = application.Id
        );
        insert subjectMetric;

        String examScoreSubjectDictionary = Schema.SObjectType.TB_Admissions_Dictionary__c.getRecordTypeInfosByDeveloperName().get('TB_High_School_Exam_Subject').getRecordTypeId();
        TB_Admissions_Dictionary__c subjectDictionary = new TB_Admissions_Dictionary__c(
            Name = 'Subject Dictionary',
            RecordTypeId = examScoreSubjectDictionary,
            TB_Available_For_HS_Exams__c = 'Foreign_HS_Exam',
            TB_Active__c = true
        );
        insert subjectDictionary;

        String examScoreRange = Schema.SObjectType.TB_Admissions_Dictionary__c.getRecordTypeInfosByDeveloperName().get('TB_High_School_Exam_Score').getRecordTypeId();
        TB_Admissions_Dictionary__c scoreRangeDecimal = new TB_Admissions_Dictionary__c(
            Name = 'Score Range',
            RecordTypeId = examScoreRange,
            TB_HS_Exam_Type__c = 'Foreign_HS_Exam',
            TB_Score_Range_From__c = 2,
            TB_Score_Range_To__c = 3,
            TB_Score_Format__c = 'Number_Decimal',
            TB_HS_Exam_Sub_Type__c = 'USA_GED',
            TB_Active__c = true,
            TB_Basic_Level_Exam__c = true
        );
        insert scoreRangeDecimal;
        TB_Admissions_Dictionary__c scoreRange = new TB_Admissions_Dictionary__c(
            Name = 'Score Range',
            RecordTypeId = examScoreRange,
            TB_HS_Exam_Type__c = TB_re_Constants.TB_APP_EXAM_TYPE_POLISH_SINCE_2005,
            TB_HS_Exam_Sub_Type__c = 'USA_GED',
            TB_Score_Range_Text__c = 'A+++',
            TB_Score_Format__c = 'Text',
            TB_Active__c = true,
            TB_Extended_Level_Exam__c = true
        );
        insert scoreRange;
    }

    @IsTest
    static void getExamMetricForApplication() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        Test.startTest();
        String result = TB_HighSchoolEducationScoreController.getExamMetricForApplication(application.Id);
        Test.stopTest();
        System.assertEquals(result, TB_HighSchoolEducationScoreController.KREM_INTEGRATION_DISABLED);
    }

    @IsTest
    static void getExamMetricForApplicationWithCustomSettings() {
        KReM_Settings__c instance = new KReM_Settings__c(TB_Enable_Integration__c = true);
        insert instance;
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        Test.startTest();
        String result = TB_HighSchoolEducationScoreController.getExamMetricForApplication(application.Id);
        Test.stopTest();
        System.assertEquals(result, null);
    }

    @IsTest
    static void getSubjectMetricsForApplication() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        Test.startTest();
        TB_HighSchoolEducationScoreController.getSubjectMetricsForApplication(application.Id);
        Test.stopTest();
    }

    @IsTest
    static void createSubjectMetricsForApplicationPositive() {
        TB_Experience_History__c examMetric = new TB_Experience_History__c(
            RecordTypeId = TB_re_Constants.TB_EDUCATION_EXP_HS_EXAM_METRIC_RT_ID
        );
        Test.startTest();
        TB_HighSchoolEducationScoreController.createSubjectMetricsForApplication(JSON.serialize(examMetric));
        Test.stopTest();
    }

    @IsTest
    static void createSubjectMetricsForApplicationNegative() {
        Test.startTest();
        TB_HighSchoolEducationScoreController.createSubjectMetricsForApplication(JSON.serialize('test'));
        Test.stopTest();
    }

    @IsTest
    static void getAdmissionsDictionaryWrapper() {
        Test.startTest();
        TB_HighSchoolEducationScoreController.getAdmissionsDictionaryWrapperForHSExamScore(TB_re_Constants.TB_APP_EXAM_TYPE_POLISH_SINCE_2005,'USA_GED','US');
        Test.stopTest();
    }

    @IsTest
    static void getAdmissionsDictionaryWrapperTextRange() {
        Test.startTest();
        TB_HighSchoolEducationScoreController.getAdmissionsDictionaryWrapperForHSExamScore('Foreign_HS_Exam','USA_GED','US');
        Test.stopTest();
    }

    @IsTest
    static void getAdmissionsDictionaryWrapperWithoutRange() {
        Test.startTest();
        TB_HighSchoolEducationScoreController.getAdmissionsDictionaryWrapperForHSExamScore('Old_Polish_HS_Exam_1991_2004','USA_GED','US');
        Test.stopTest();
    }

    @IsTest
    static void saveSubjectMetricsForApplication() {
        String examScoreRange = Schema.SObjectType.TB_Admissions_Dictionary__c.getRecordTypeInfosByDeveloperName().get('TB_High_School_Exam_Score').getRecordTypeId();
        TB_Admissions_Dictionary__c scoreRangeDecimal = new TB_Admissions_Dictionary__c(
            Name = 'Score Range',
            RecordTypeId = examScoreRange,
            TB_HS_Exam_Type__c = 'Foreign_HS_Exam',
            TB_Score_Range_From__c = 2,
            TB_Score_Range_To__c = 3,
            TB_Score_Format__c = 'Number_Decimal',
            TB_Active__c = true
        );
        insert scoreRangeDecimal;

        List<TB_HighSchoolEducationScoreController.HSExamScoreMetricWrapper> wrappers = new List<TB_HighSchoolEducationScoreController.HSExamScoreMetricWrapper>();
        TB_Experience_History__c examSubject = [SELECT Id, TB_HS_Exam_Metric__c FROM TB_Experience_History__c WHERE TB_Educational_Institution_City__c = 'Warsaw' LIMIT 1];
        TB_Experience_History__c examMetric = [SELECT Id FROM TB_Experience_History__c WHERE Id =: examSubject.TB_HS_Exam_Metric__c LIMIT 1];
        TB_HighSchoolEducationScoreController.HSExamScoreMetricWrapper wrapper = new TB_HighSchoolEducationScoreController.HSExamScoreMetricWrapper(examSubject, examMetric);
        wrappers.add(wrapper);

        Test.startTest();
        TB_HighSchoolEducationScoreController.saveSubjectMetricsForApplication(JSON.serialize(wrappers));
        Test.stopTest();
    }

    @IsTest
    static void saveSubjectMetricsForApplicationTextRange() {
        String examScoreRange = Schema.SObjectType.TB_Admissions_Dictionary__c.getRecordTypeInfosByDeveloperName().get('TB_High_School_Exam_Score').getRecordTypeId();
        TB_Admissions_Dictionary__c scoreRange = new TB_Admissions_Dictionary__c(
            Name = 'Score Range',
            RecordTypeId = examScoreRange,
            TB_HS_Exam_Type__c = TB_re_Constants.TB_APP_EXAM_TYPE_POLISH_SINCE_2005,
            TB_Score_Range_Text__c = 'A+',
            TB_Score_Format__c = 'Text',
            TB_Active__c = true,
            TB_Bilingual_Level_Exam__c = true,
            TB_Extended_Level_Exam__c = true,
            TB_Basic_Level_Exam__c = true
        );
        insert scoreRange;

        List<TB_HighSchoolEducationScoreController.HSExamScoreMetricWrapper> wrappers = new List<TB_HighSchoolEducationScoreController.HSExamScoreMetricWrapper>();
        TB_Experience_History__c examSubject = [SELECT Id, TB_HS_Exam_Metric__c FROM TB_Experience_History__c WHERE TB_Educational_Institution_City__c = 'Warsaw' LIMIT 1];
        TB_Experience_History__c examMetric = [SELECT Id FROM TB_Experience_History__c WHERE Id =: examSubject.TB_HS_Exam_Metric__c LIMIT 1];
        TB_HighSchoolEducationScoreController.HSExamScoreMetricWrapper wrapper = new TB_HighSchoolEducationScoreController.HSExamScoreMetricWrapper(examSubject, examMetric);
        wrappers.add(wrapper);

        Test.startTest();
        TB_HighSchoolEducationScoreController.saveSubjectMetricsForApplication(JSON.serialize(wrappers));
        Test.stopTest();
    }

    @IsTest
    static void deleteSubjectMetricPositive() {
        TB_Experience_History__c subjectMetric = [SELECT Id FROM  TB_Experience_History__c WHERE TB_Educational_Institution_City__c = 'Warsaw' LIMIT 1];
        Test.startTest();
        TB_HighSchoolEducationScoreController.deleteSubjectMetric(subjectMetric.Id);
        Test.stopTest();
    }

    @IsTest
    static void deleteSubjectMetricNegative() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        TB_HighSchoolEducationScoreController.deleteSubjectMetric(contact.Id);
        Test.stopTest();
    }

    @IsTest
    static void invokeIntegrationMethodNegative() {
        Test.setMock(HttpCalloutMock.class, new TB_KReMSIOIntegratorMock('error'));
        Test.startTest();
        TB_HighSchoolEducationScoreController.invokeIntegrationMethod(null, null, null, null);
        Test.stopTest();
        System.assertEquals(2, [SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void invokeIntegrationMethodSubjectsNotFound() {
        Test.setMock(HttpCalloutMock.class, new TB_KReMSIOIntegratorMock('resultsPositive'));
        Test.startTest();
        TB_HighSchoolEducationScoreController.invokeIntegrationMethod(null, null, null, null);
        Test.stopTest();

        System.assertEquals(2, [SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void invokeIntegrationMethodPositive() {
        TB_re_TestDataFactory.createHSExamSubjectsDictionaryWithCode(true, new Map<String, String> {
                'matematyka' => 'MA_p;',
                'język polski' => 'PO_p;',
                'język angielski' => 'JA_p;',
                'informatyka' => 'IN_p;'
        });
        TB_Experience_History__c examMetric = [SELECT Id, TB_Applicant__c, TB_Application__c FROM TB_Experience_History__c WHERE RecordTypeId =: TB_re_Constants.TB_EDUCATION_EXP_HS_EXAM_METRIC_RT_ID LIMIT 1];
        hed__Application__c application = [SELECT Id, hed__Applicant__c FROM hed__Application__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new TB_KReMSIOIntegratorMock('resultsPositive'));
        Test.startTest();
        String result = TB_HighSchoolEducationScoreController.invokeIntegrationMethod('66666666666', examMetric.Id, application.Id, application.hed__Applicant__c);
        Test.stopTest();

        System.assertEquals(true, result != null);
        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
        System.assertEquals(5, [SELECT Id FROM TB_Experience_History__c].size());
    }

}