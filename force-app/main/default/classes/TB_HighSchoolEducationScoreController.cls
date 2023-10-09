/**
 * Created by Aneta on 28/10/2021.
 */

public with sharing class TB_HighSchoolEducationScoreController {

    public static final String KREM_INTEGRATION_DISABLED = 'KREM_INTEGRATION_DISABLED';
    public static final String KReM_STATUS_NOT_INITIATED = 'Not_initiated';
    public static final String KReM_STATUS_PENDING = 'Pending';
    public static final String KReM_STATUS_RECEIVED= 'Received';
    public static final String KReM_STATUS_RECEIVED_NO_RESULT = 'Received_no_result';
    public static final String KReM_STATUS_FAILED = 'Failed';

    @AuraEnabled
    public static String createSubjectMetricsForApplication(String hsExamMetric) {
        try {
            TB_Experience_History__c examMetric = (TB_Experience_History__c) JSON.deserialize(hsExamMetric, TB_Experience_History__c.class);
            TB_Experience_History__c singleMetric = new TB_Experience_History__c(
                TB_HS_Exam_Metric__c = examMetric.Id
            );
            HSExamScoreMetricWrapper singleWrapper = new HSExamScoreMetricWrapper(singleMetric, examMetric);
            return JSON.serialize(singleWrapper);
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return 'FAILED';
        }
    }

    @AuraEnabled
    public static String deleteSubjectMetric(String subjectMetricId) {
        try {
           TB_Experience_History__c experienceHistory = new TB_Experience_History__c(
               Id = subjectMetricId
           );
           delete experienceHistory;
            return 'SUCCESS_DELETE_SUBJECT_METRIC';
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return 'FAILED_DELETE_SUBJECT_METRIC';
        }
    }

    @AuraEnabled
    public static String saveSubjectMetricsForApplication(String wrappers) {
        List<HSExamScoreMetricWrapper> examMetrics
            = (List<HSExamScoreMetricWrapper>) JSON.deserialize(wrappers, List<HSExamScoreMetricWrapper>.class);

        List<TB_Experience_History__c> metricsToUpdate = new List<TB_Experience_History__c>();
        List<TB_Experience_History__c> metricsToCreate = new List<TB_Experience_History__c>();

        for(HSExamScoreMetricWrapper singleMetric : examMetrics) {
            String metricId = singleMetric.subject.Id;
            if(metricId.contains('FAKE_ID')) {
                singleMetric.subject.Id = null;
                singleMetric.subject.RecordTypeId = TB_re_Constants.TB_EDUCATION_EXP_HS_EXAM_SUBJECT_METRIC_RT_ID;
                metricsToCreate.add(singleMetric.subject);
            }else {
                singleMetric.subject.TB_KReM_Status__c = '';
                metricsToUpdate.add(singleMetric.subject);
            }
        }
        try{
            update metricsToUpdate;
            insert metricsToCreate;
            return 'SUCCESS';
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return 'FAILED' + e.getMessage();
        }
    }

    @AuraEnabled
    public static String getSubjectMetricsForApplication(String applicationId) {
        List<TB_Experience_History__c> experienceHistoryMetrics = getSubjectMetrics(applicationId);
        Integer order = 1;
        List<HSExamScoreMetricWrapper> wrappers = new List<HSExamScoreMetricWrapper>();
        for (TB_Experience_History__c singleMetric : experienceHistoryMetrics) {
            HSExamScoreMetricWrapper singleWrapper = new HSExamScoreMetricWrapper(singleMetric, order++);
            wrappers.add(singleWrapper);
        }
        return JSON.serialize(wrappers);
    }

    private static List<TB_Experience_History__c> getSubjectMetrics(String applicationId) {
        return [
                SELECT Id, TB_Application__c, TB_HS_Exam_Subject__c, TB_HS_Basic_Result__c, TB_HS_Extended_Result__c,
                        TB_HS_Bilingual_Result__c,
                        TB_HS_Exam_Metric__r.TB_HS_Exam_Type__r.TB_HS_Exam_Type__c,
                        TB_HS_Exam_Metric__r.TB_HS_Exam_Type__r.TB_HS_Exam_Sub_Type__c,
                        TB_HS_Exam_Metric__r.TB_HS_Exam_Type__r.TB_Basic_Level_Exam__c,
                        TB_HS_Exam_Metric__r.TB_HS_Exam_Type__r.TB_Extended_Level_Exam__c,
                        TB_HS_Exam_Metric__r.TB_HS_Exam_Type__r.TB_Bilingual_Level_Exam__c,
                        TB_HS_Exam_Metric__r.TB_HS_Exam_Type__r.TB_Number_of_Maturity_Subjects__c,
                        TB_HS_Exam_Metric__r.TB_HS_Exam_Country__c,
                        TB_HS_Exam_Metric__r.TB_HS_Exam_Sub_Type__r.TB_HS_Exam_Sub_Type__c,
                        TB_HS_Exam_Subject__r.TB_KReM_Subject_Code__c
                FROM TB_Experience_History__c
                WHERE TB_Application__c = :applicationId
                AND RecordTypeId =: TB_re_Constants.TB_EDUCATION_EXP_HS_EXAM_SUBJECT_METRIC_RT_ID
                ORDER BY CreatedDate
        ];
    }

    @AuraEnabled
    public static String getExamMetricForApplication(String applicationId) {
        if(enableKReMIntegration()) {
            return TB_HighSchoolEducationController.getHSExamMetric(applicationId);
        }
        return KREM_INTEGRATION_DISABLED;
    }

    private static Boolean enableKReMIntegration() {
        return KReM_Settings__c.getInstance().get('TB_Enable_Integration__c') != null
                && Boolean.valueOf(KReM_Settings__c.getInstance()?.get('TB_Enable_Integration__c'));
    }
    private static void saveKReMResponse(TB_KReMSIOIntegrator.Response response, String examMetricId, String applicationId, String applicantId) {
        Map<Integer,String> resultCodeToDetail = TB_KReMSIOIntegrator.getResultCodes();
        String responseStatus;
        String responseDescription;
        if(response.errorCode == 0) {
            String createResult = createSubjectMetricsForKReMResult(examMetricId, applicationId, applicantId, response.studentResult);
            responseStatus = createResult == 'SUCCESS' ? KReM_STATUS_RECEIVED : KReM_STATUS_FAILED;
            responseDescription = createResult == 'SUCCESS'
                    ? JSON.serialize(response.studentResult) : (resultCodeToDetail.containsKey(response.errorCode)
                            ?  resultCodeToDetail.get(response.errorCode): JSON.serialize(response.errorCode));
        }else {
            responseStatus = getResponseStatusFromErrorCode(response.errorCode, resultCodeToDetail.keySet());
            responseDescription = resultCodeToDetail.containsKey(response.errorCode)
                    ?  resultCodeToDetail.get(response.errorCode): JSON.serialize(response.errorCode);
        }
        updateHsExamMetric(examMetricId, responseStatus, responseDescription);
    }
    private static String getResponseStatusFromErrorCode(Integer errorCode, Set<Integer> resultCodes) {
        if(errorCode == 0) {
            return KReM_STATUS_RECEIVED;
        }else if(resultCodes.contains(errorCode)) {
            return KReM_STATUS_RECEIVED_NO_RESULT;
        }else {
            return KReM_STATUS_FAILED;
        }
    }
    private static String createSubjectMetricsForKReMResult(String examMetricId, String applicationId, String applicantId, TB_KReMSIOIntegrator.StudentResult studentResult) {
        try {
            String codesNotFound = '';
            Map<String,TB_Admissions_Dictionary__c> subjectsByCode = getSubjectsMapByCode();
            List<TB_Experience_History__c> existSubjectMetrics = getSubjectMetrics(applicationId);
            Map<String, TB_Experience_History__c> newMetricsToUpsertBySubjectId = new Map<String, TB_Experience_History__c>();
            for(TB_KReMSIOIntegrator.Result singleResult : studentResult.results) {
                TB_Admissions_Dictionary__c currentSubject = subjectsByCode.get(singleResult.code.trim().substring(0,4));
                if(currentSubject != null) {
                    TB_Experience_History__c singleExperience;
                    if(newMetricsToUpsertBySubjectId.containsKey(currentSubject.Id)) {
                        singleExperience = newMetricsToUpsertBySubjectId.get(currentSubject.Id);
                    }else {
                        singleExperience = new TB_Experience_History__c(
                                RecordTypeId = TB_re_Constants.TB_EDUCATION_EXP_HS_EXAM_SUBJECT_METRIC_RT_ID,
                                TB_Application__c = applicationId,
                                TB_Applicant__c = applicantId,
                                TB_HS_Exam_Metric__c = examMetricId,
                                TB_HS_Exam_Subject__c = currentSubject.Id,
                                TB_KReM_Status__c = KReM_STATUS_RECEIVED
                        );
                    }
                    newMetricsToUpsertBySubjectId.put(currentSubject.Id, getExperienceWithScore(singleExperience, singleResult));
                }else {
                    codesNotFound += ' ' + singleResult.code;
                }
            }
            delete existSubjectMetrics;
            insert newMetricsToUpsertBySubjectId.values();

            if(codesNotFound != '') {
                insert TB_LogUtils.registerLog(
                        'Subject not found: ' + codesNotFound,
                        TB_HighSchoolEducationScoreController.class
                );
            }
            return 'SUCCESS';
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return 'FAILED' + e.getMessage();
        }
    }


    private static TB_Experience_History__c getExperienceWithScore(TB_Experience_History__c scoreExperience, TB_KReMSIOIntegrator.Result  result) {
        switch on result.code.substring(5,6) {
            when 'R' {
                scoreExperience.TB_HS_Extended_Result__c = getHigherResult(scoreExperience.TB_HS_Extended_Result__c, result.points);
            }
            when 'P' {
                scoreExperience.TB_HS_Basic_Result__c = getHigherResult(scoreExperience.TB_HS_Basic_Result__c, result.points);
            }
            when 'D' {
                scoreExperience.TB_HS_Bilingual_Result__c = getHigherResult(scoreExperience.TB_HS_Bilingual_Result__c, result.points);
            }
        }
        return scoreExperience;
    }

    public static String getHigherResult(String currentResult, Integer newResult) {
        try {
            return Integer.valueOf(currentResult) < newResult ? String.valueOf(newResult) : currentResult;
        }catch (Exception e) {
            return String.valueOf(newResult);
        }
    }

    @AuraEnabled
    public static Map<String, TB_Admissions_Dictionary__c> getSubjectsMapByCode() {
        Map<String, TB_Admissions_Dictionary__c> subjectsByCode = new Map<String, TB_Admissions_Dictionary__c>();
        for(TB_Admissions_Dictionary__c singleSubject : [
                SELECT TB_Display_Name_PL__c, TB_KReM_Subject_Code__c
                FROM TB_Admissions_Dictionary__c
                WHERE RecordTypeId = :TB_re_Constants.ADMISSIONS_DICTIONARY_RT_HS_EXAM_SUBJECT
                AND TB_Available_For_HS_Exams__c INCLUDES (:TB_re_Constants.TB_APP_EXAM_TYPE_POLISH_SINCE_2005)
                AND TB_KReM_Subject_Code__c != NULL
        ]) {
            for(String singleCode : String.valueOf(singleSubject.TB_KReM_Subject_Code__c).split(';')) {
                if(singleCode.trim().length() > 0) {
                    subjectsByCode.put(singleCode, singleSubject);
                }
            }
        }
        return subjectsByCode;
    }

    @AuraEnabled
    public static String invokeIntegrationMethod(String pesel, String examMetricId, String applicationId, String applicantId) {
        try {
            String responses = TB_KReMSIOIntegrator.getRetrievedResults(new List<String>{ pesel }, false);
            if(responses.startsWith(TB_re_Constants.ERROR_OCCURRED)) {
                updateHsExamMetric(examMetricId, KReM_STATUS_FAILED, responses);
            }else {
                TB_KReMSIOIntegrator.Body body = (TB_KReMSIOIntegrator.Body) JSON.deserialize(responses, TB_KReMSIOIntegrator.Body.class);
                if(body.responseCode == 0) {
                    saveKReMResponse(body.responses[0], examMetricId, applicationId, applicantId);
                    return JSON.serialize(body);
                }else {
                    updateHsExamMetric(examMetricId, KReM_STATUS_FAILED, body.responseCodeDetail);
                }
            }
            return null;
        }catch (Exception e) {
            updateHsExamMetric(examMetricId, KReM_STATUS_FAILED, e.getMessage());
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    @AuraEnabled
    public static Boolean updateHsExamMetric(String examMetricId, String kremStatus, String kremDescription) {
        try {
            TB_Experience_History__c updatedExamMetric = new TB_Experience_History__c(
                    Id = examMetricId,
                    TB_KReM_Status__c = kremStatus
            );
            if (kremDescription != null) {
                updatedExamMetric.TB_KReM_Status_Description__c = kremDescription;
            }
            update updatedExamMetric;
            return true;
        }catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return false;
        }
    }

    public class HSExamResultWrapper {
        @AuraEnabled public List<HSExamResultWrapper> subjects {get;set;}
        @AuraEnabled public TB_Experience_History__c metric  {get;set;}
    }

    public class HSExamScoreMetricWrapper {
        @AuraEnabled public TB_Experience_History__c subject {get;set;}
        @AuraEnabled public String subjectLabel {get;set;}
        @AuraEnabled public TB_Experience_History__c hsExamMetric {get;set;}
        @AuraEnabled public Integer order {get;set;}
        @AuraEnabled public Boolean isDropdownOpenFlag {get;set;}
        @AuraEnabled public String inputType {get;set;}
        @AuraEnabled public Boolean isAdditionalMetric {get;set;}

        public HSExamScoreMetricWrapper(TB_Experience_History__c subject, Integer order) {
            this.subject = subject;
            this.hsExamMetric = subject.TB_HS_Exam_Metric__r;
            this.order = order;
            this.isDropdownOpenFlag = false;
            this.inputType = 'number';
            this.isAdditionalMetric = (this.order <= this.hsExamMetric.TB_HS_Exam_Type__r.TB_Number_of_Maturity_Subjects__c) ? false : true;
        }

        public HSExamScoreMetricWrapper(TB_Experience_History__c subject, TB_Experience_History__c hsExamMetric) {
            this.subject = subject;
            this.hsExamMetric = hsExamMetric;
            this.isDropdownOpenFlag = false;
            this.inputType = 'number';
            this.isAdditionalMetric = false;
        }
    }

    @AuraEnabled
    public static String getAdmissionsDictionaryWrapperForHSExamScore(String hsExamType, String hsExamSubType, String country) {
        List<TB_JSON_Wrapper__c> wrappers = [
            SELECT Id, TB_Wrapper_Value__c, TB_Object_API_Name__c, TB_Record_Type_Dev_Name__c
            FROM TB_JSON_Wrapper__c
            WHERE TB_Object_API_Name__c = 'TB_Admissions_Dictionary__c'
            ORDER BY TB_Order__c
        ];

        List<TB_Admissions_Dictionary__c> highSchoolExamSubjects = new List<TB_Admissions_Dictionary__c>();
        List<TB_Admissions_Dictionary__c> highSchoolExamScores = new List<TB_Admissions_Dictionary__c>();

        TB_Admissions_Dictionary__c singleDictionary = new TB_Admissions_Dictionary__c();
        for(TB_JSON_Wrapper__c singleWrapper : wrappers) {
            singleDictionary = (TB_Admissions_Dictionary__c) JSON.deserialize(singleWrapper.TB_Wrapper_Value__c, TB_Admissions_Dictionary__c.class);
            if(singleDictionary.TB_Active__c == true) {
                if (singleWrapper.TB_Record_Type_Dev_Name__c == 'TB_High_School_Exam_Subject') {
                    if (singleDictionary.TB_Available_For_HS_Exams__c.contains(hsExamType)) {
                        highSchoolExamSubjects.add(singleDictionary);
                    }
                } else if(singleWrapper.TB_Record_Type_Dev_Name__c == 'TB_High_School_Exam_Score') {
                    singleDictionary = (TB_Admissions_Dictionary__c) JSON.deserialize(singleWrapper.TB_Wrapper_Value__c, TB_Admissions_Dictionary__c.class);
                    if(singleDictionary.TB_HS_Exam_Type__c == hsExamType && (singleDictionary.TB_Country__c == null || singleDictionary.TB_Country__c == country)) {
                        if(hsExamSubType != null) {
                            if(singleDictionary.TB_HS_Exam_Sub_Type__c == hsExamSubType) {
                                highSchoolExamScores.add(singleDictionary);
                            }
                        }else {
                            highSchoolExamScores.add(singleDictionary);
                        }

                    }
                }
            }
        }
        AdmissionsDictionaryWrapper dictionaryWrapper = new AdmissionsDictionaryWrapper(highSchoolExamSubjects, highSchoolExamScores);
        return JSON.serialize(dictionaryWrapper);
    }

    public class AdmissionsDictionaryWrapper {
        List<TB_Admissions_Dictionary__c> hsExamSubjects {get;set;}
        List<ScoresRangeWrapper> hsExamScores {get;set;}

        public AdmissionsDictionaryWrapper(List<TB_Admissions_Dictionary__c> examSubjects, List<TB_Admissions_Dictionary__c> examScoresRange) {
            this.hsExamSubjects = examSubjects;
            this.hsExamScores = prepareScoresRangeWrapper(examScoresRange);
        }
    }

    public class ScoresRangeWrapper {
        String nameOfLevel {get;set;}
        String typeOfValues {get;set;}
        Decimal maxLength {get;set;}
        Decimal maxValue {get;set;}
        Decimal minValue {get;set;}
        String rangeStep {get;set;}
        String pattern {get;set;}
        List<String> valuesRangeText {get;set;}
        String valuesRangeMisMatchMessage {get;set;}
        List<Decimal> valuesRangeDecimal {get;set;}
        Boolean definedScoresRangeMetric {get;set;}

        public ScoresRangeWrapper(String typeOfValues, String rangeStep, String nameOfLevel) {
            this.valuesRangeText = new List<String>();
            this.valuesRangeDecimal = new List<Decimal>();
            this.nameOfLevel = nameOfLevel;
            this.typeOfValues = typeOfValues;
            this.rangeStep = rangeStep;
            this.maxLength = 0;
            this.minValue = 1000000;
            this.maxValue = -1000000;
            this.valuesRangeMisMatchMessage = '';
            this.definedScoresRangeMetric = true;
        }
    }

   private static List<ScoresRangeWrapper> prepareScoresRangeWrapper(List<TB_Admissions_Dictionary__c> examScoresRange) {
       List<ScoresRangeWrapper> allRangeWrappers = new List<ScoresRangeWrapper>();
       Map<String,ScoresRangeWrapper> rangesMap = new  Map<String,ScoresRangeWrapper>();
       List<String> checkboxRangeApiNames = new List<String>{'TB_Basic_Level_Exam__c','TB_Extended_Level_Exam__c','TB_Bilingual_Level_Exam__c'};

       if(examScoresRange.size() > 0) {
           String rangeOfValues;
           switch on examScoresRange[0].TB_Score_Format__c {
               when 'Text' {
                   rangeOfValues = '';
               }
               when 'Number_Integer' {
                   rangeOfValues = '1';
               }
               when 'Number_Decimal' {
                   rangeOfValues = '0.01';
               }
               when else {
                   rangeOfValues = '0.01';
               }
           }

           String typeOfValues = (examScoresRange[0].TB_Score_Format__c == 'Text') ? 'text' : 'number';
           for(String singleApiName : checkboxRangeApiNames) {
               ScoresRangeWrapper singleWrapper = new ScoresRangeWrapper(typeOfValues, rangeOfValues, singleApiName);
               rangesMap.put(singleApiName,singleWrapper);
           }

           for(TB_Admissions_Dictionary__c singleScore : examScoresRange) {
               if(typeOfValues == 'text') {
                   for(String singleApiName : checkboxRangeApiNames) {
                       if(singleScore.get(singleApiName) == true) {
                           rangesMap.get(singleApiName).valuesRangeText.add(singleScore.TB_Score_Range_Text__c);
                           rangesMap.get(singleApiName).valuesRangeMisMatchMessage += singleScore.TB_Score_Range_Text__c + ', ';
                           rangesMap.get(singleApiName).maxLength 
                               = rangesMap.get(singleApiName).maxLength < singleScore.TB_Score_Range_Text__c.length() 
                               ? singleScore.TB_Score_Range_Text__c.length() : rangesMap.get(singleApiName).maxLength;
                       }
                   }
               }else {
                   for(String singleApiName : checkboxRangeApiNames) {
                       if(singleScore.get(singleApiName) == true) {
                           rangesMap.get(singleApiName).minValue
                               = (rangesMap.get(singleApiName).minValue > singleScore.TB_Score_Range_From__c)
                               ? singleScore.TB_Score_Range_From__c : rangesMap.get(singleApiName).minValue;

                           rangesMap.get(singleApiName).maxValue
                               = (rangesMap.get(singleApiName).maxValue < singleScore.TB_Score_Range_To__c)
                               ? singleScore.TB_Score_Range_To__c : rangesMap.get(singleApiName).maxValue;
                       }
                   }
               }
           }

           for(ScoresRangeWrapper singleRange : rangesMap.values()) {
                if(typeOfValues == 'text') {
                    String message = singleRange.valuesRangeMisMatchMessage;
                    if(message.length() > 2) {
                        singleRange.valuesRangeMisMatchMessage = message.substring(0, message.length() - 2);
                    }
                }else {
                    String pattern = '([0-9]*[.,]?[0-9]+)';
                    singleRange.pattern = pattern;
                    singleRange.maxLength = 10;
                }
               allRangeWrappers.add(singleRange);
           }
           return allRangeWrappers;
       }else {

           for(String singleApiName : checkboxRangeApiNames) {
               ScoresRangeWrapper singleWrapper = new ScoresRangeWrapper('text', '', singleApiName);
               rangesMap.put(singleApiName,singleWrapper);
           }

           for(ScoresRangeWrapper singleRange : rangesMap.values()) {
               singleRange.maxLength = 50;
               singleRange.definedScoresRangeMetric = false;
               allRangeWrappers.add(singleRange);
           }
           return allRangeWrappers;
       }
   }
}