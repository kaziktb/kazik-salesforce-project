/**
 * Created by Aneta on 21/10/2021.
 */

public with sharing class TB_HighSchoolEducationController {

    public static String hsExamSubjectRecordTypeId = Schema.SObjectType.TB_Experience_History__c
        .getRecordTypeInfosByDeveloperName().get('TB_HS_Exam_Subjects').getRecordTypeId();

    @AuraEnabled
    public static String getAdmissionsDictionaryWrapperForHSExam() {
        List<TB_JSON_Wrapper__c> wrappers = [
            SELECT Id, TB_Wrapper_Value__c, TB_Object_API_Name__c, TB_Record_Type_Dev_Name__c
            FROM TB_JSON_Wrapper__c
            WHERE TB_Object_API_Name__c = 'TB_Admissions_Dictionary__c'
            ORDER BY TB_Order__c
        ];

        List<TB_Admissions_Dictionary__c> highSchoolExamTypes = new List<TB_Admissions_Dictionary__c>();
        List<TB_Admissions_Dictionary__c> regionalExaminationBoard = new List<TB_Admissions_Dictionary__c>();
        List<TB_Admissions_Dictionary__c> highSchoolExamSubTypes = new List<TB_Admissions_Dictionary__c>();
        PicklistWrapper countryOptions = getPicklistByApiName('TB_Experience_History__c','TB_HS_Exam_Country__c');

        TB_Admissions_Dictionary__c singleDictionary = new TB_Admissions_Dictionary__c();
        for(TB_JSON_Wrapper__c singleWrapper : wrappers) {
            if(singleWrapper.TB_Record_Type_Dev_Name__c == 'TB_High_School_Exam_Type'){
               singleDictionary = (TB_Admissions_Dictionary__c) JSON.deserialize(singleWrapper.TB_Wrapper_Value__c, TB_Admissions_Dictionary__c.class);
                if(singleDictionary.TB_Active__c == true) {
                    highSchoolExamTypes.add(singleDictionary);
                }
            }else if(singleWrapper.TB_Record_Type_Dev_Name__c == 'TB_Local_Educational_Committee'){
                singleDictionary = (TB_Admissions_Dictionary__c) JSON.deserialize(singleWrapper.TB_Wrapper_Value__c, TB_Admissions_Dictionary__c.class);
                if(singleDictionary.TB_Active__c == true) {
                    regionalExaminationBoard.add(singleDictionary);
                }
            }else if(singleWrapper.TB_Record_Type_Dev_Name__c == 'TB_High_School_Exam_Sub_Type'){
                singleDictionary = (TB_Admissions_Dictionary__c) JSON.deserialize(singleWrapper.TB_Wrapper_Value__c, TB_Admissions_Dictionary__c.class);
                if(singleDictionary.TB_Active__c == true) {
                    highSchoolExamSubTypes.add(singleDictionary);
                }
            }
        }

        AdmissionsDictionaryWrapper dictionaryWrapper
            = new AdmissionsDictionaryWrapper(highSchoolExamTypes,regionalExaminationBoard,highSchoolExamSubTypes, countryOptions);

        return JSON.serialize(dictionaryWrapper);
    }


    public class AdmissionsDictionaryWrapper {
        List<TB_Admissions_Dictionary__c> examTypes {get;set;}
        List<TB_Admissions_Dictionary__c> examinationBoard {get;set;}
        Map<String,Set<TB_Admissions_Dictionary__c>> highSchoolExamSubTypes {get;set;}
        PicklistWrapper countryOptions {get;set;}

        public AdmissionsDictionaryWrapper
        (
            List<TB_Admissions_Dictionary__c> examTypes, List<TB_Admissions_Dictionary__c> examinationBoard,
            List<TB_Admissions_Dictionary__c> highSchoolExamSubTypes, PicklistWrapper countryOptions
        ) {
            this.examTypes = examTypes;
            this.examinationBoard = examinationBoard;
            this.highSchoolExamSubTypes = prepareCountryExamSubTypesMap(highSchoolExamSubTypes);
            this.countryOptions = countryOptions;
        }
    }

    private static Map<String,Set<TB_Admissions_Dictionary__c>> prepareCountryExamSubTypesMap(List<TB_Admissions_Dictionary__c> highSchoolExamSubTypes) {
        Map<String,Set<TB_Admissions_Dictionary__c>> subTypesForCountries = new Map<String,Set<TB_Admissions_Dictionary__c>>();

        for(TB_Admissions_Dictionary__c singleSubType : highSchoolExamSubTypes) {
            List<String> countries = singleSubType.TB_Country__c.split(';');
            for(String singleCountry : countries) {
                Set<TB_Admissions_Dictionary__c> admissions;
                if(subTypesForCountries.containsKey(singleCountry)) {
                    admissions = subTypesForCountries.get(singleCountry);
                }else {
                    admissions = new Set<TB_Admissions_Dictionary__c>();
                }
                admissions.add(singleSubType);
                subTypesForCountries.put(singleCountry, admissions);
            }
        }
        return subTypesForCountries;
    }

    private static PicklistWrapper getPicklistByApiName(String objectApiName, String fieldApiName) {
        List<String> labels = TB_StringUtils.getPicklistValuesOrLabelsSortedByLabel(objectApiName, fieldApiName, 'labels');
        List<String> values = TB_StringUtils.getPicklistValuesOrLabelsSortedByLabel(objectApiName, fieldApiName, 'values');
        List<List<String>> valuesAndLabelsPrioritized = TB_StringUtils.getPolandOnTop(new List<List<String>>{values,labels});
        PicklistWrapper picklistWrapper = new PicklistWrapper(valuesAndLabelsPrioritized);
        return picklistWrapper;
    }

    public class PicklistWrapper {
        @AuraEnabled public List<String> choicesValues { get; set; }
        @AuraEnabled public List<String> choicesLabels { get; set; }

        public PicklistWrapper(List<List<String>> valuesAndLabelsPrioritized) {

            this.choicesValues = valuesAndLabelsPrioritized[0];
            this.choicesLabels = valuesAndLabelsPrioritized[1];
        }
    }

    @AuraEnabled
    public static String getHSExamMetric(String applicationId) {
        List<TB_Experience_History__c> hsExamMetrics = [
            SELECT Id, TB_HS_Exam_Type__c, TB_HS_Exam_Country__c, TB_HS_Exam_Sub_Type__c,
                TB_Educational_Institution_Country__c, TB_Educational_Institution_City__c,
                TB_Educational_Institution__c, TB_Document_Number__c, TB_Document_Issue_City__c,
                TB_Issue_Date__c, TB_Regional_Examination_Board__c, TB_HS_Exam_GPA__c, TB_Application__r.TB_No_HS_Exam__c,
                TB_KReM_Status__c, TB_KReM_Integration__c, TB_Applicant__r.DT_PESEL__c, TB_Applicant__c,
                TB_HS_Exam_Type__r.TB_HS_Exam_Type__c
            FROM TB_Experience_History__c
            WHERE TB_Application__c = :applicationId AND RecordType.DeveloperName = 'TB_HS_Exam_Metric'
        ];

        switch on hsExamMetrics.size() {
            when 0 {
                return null;
            }
            when 1 {
                return JSON.serialize(hsExamMetrics[0]);
            }
            when else {
                insert TB_LogUtils.errorRequest('Duplicates hsExamMetrics');
                return JSON.serialize(hsExamMetrics[0]);
            }
        }
    }

    @AuraEnabled
    public static String getApplicationDocuments(String examMetricId) {
        List<String> examMetrics = new List<String>{examMetricId};
        List<TB_Application_Document__c> documents = TB_FileUtils.getApplicationDocuments(examMetrics, 'TB_Experience__c').get(examMetricId);
        return JSON.serialize(TB_FileUtils.createFileWrapperForDocuments(documents));
    }

    @AuraEnabled
    public static String updateApplicationDocuments(Boolean createFiles, Boolean deleteFiles, String hsExamMetric, String applicationId, Boolean isForeign) {

        TB_Experience_History__c experienceHistory = new TB_Experience_History__c();
        experienceHistory = (TB_Experience_History__c) JSON.deserialize(hsExamMetric, TB_Experience_History__c.class);

        Map<String,List<String>> diplomaCategory = new Map<String,List<String>>();

        List<TB_Application_Document__c> activeDocuments = [
            SELECT Id
            FROM TB_Application_Document__c
            WHERE TB_Application__c = :applicationId
            AND TB_Experience__c = :experienceHistory.Id
            ORDER BY LastModifiedDate ASC
        ];

        if(deleteFiles) {
            try {
                delete activeDocuments;
            }catch(Exception e) {
                insert TB_LogUtils.registerLog(e);
            }
        }

        if(createFiles) {
            diplomaCategory = createApplicationDocumentSlots(experienceHistory, isForeign);
            return JSON.serialize(diplomaCategory);
        }else {
            return 'SUCCESS';
        }
    }

    @AuraEnabled
    public static String createHSExamMetric(String examMetric, Boolean noHSExam, Boolean isForeign) {
        TB_Experience_History__c experienceHistory = new TB_Experience_History__c();
        experienceHistory = (TB_Experience_History__c) JSON.deserialize(examMetric, TB_Experience_History__c.class);
        try {
            String hsExamMetric = Schema.SObjectType.TB_Experience_History__c
                .getRecordTypeInfosByDeveloperName().get('TB_HS_Exam_Metric').getRecordTypeId();
            experienceHistory.RecordTypeId = hsExamMetric;
            insert experienceHistory;

            hed__Application__c application = new hed__Application__c();
            application.Id = experienceHistory.TB_Application__c;
            application.TB_No_HS_Exam__c = noHSExam;
            update application;

            if(!noHSExam) {
                Map<String,List<String>> documents = createApplicationDocumentSlots(experienceHistory, isForeign);
                if(documents == null) {
                    return 'CREATE_FAILED.CANNOT_CREATE_DOCUMENTS';
                }else {
                    ExperienceWrapper wrapper = new ExperienceWrapper(experienceHistory, documents);
                    return JSON.serialize(wrapper);
                }
            }else {
                ExperienceWrapper wrapper = new ExperienceWrapper(experienceHistory, null);
                return JSON.serialize(wrapper);
            }

        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            String firstExceptionType = e.getMessage().substringAfter(':');
            firstExceptionType = firstExceptionType.split(',')[0];
            return 'CREATE_FAILED.'+ firstExceptionType;
        }
    }

    public class ExperienceWrapper {
        @AuraEnabled public TB_Experience_History__c examMetric { get; set; }
        @AuraEnabled public Map<String,List<String>> documentsByCategory { get; set; }

        public ExperienceWrapper(TB_Experience_History__c examMetric, Map<String,List<String>> documents) {
            this.examMetric = examMetric;
            this.documentsByCategory = documents;
        }
    }

    private static Map<String,List<String>> createApplicationDocumentSlots(TB_Experience_History__c experience, Boolean isForeign) {
        List<String> diplomaCategory = new List<String>{'High_School_Diploma','High_School_Diploma_Translation','High_School_Transcript','High_School_Transcript_Translation'};
        try {
            List<TB_Application_Document__c> documents = new List<TB_Application_Document__c>();
            if (isForeign) {
                for (String singleCategory : diplomaCategory) {
                    documents.add(prepareApplicationDocumentSlot(experience, singleCategory));
                }
            } else {
                documents.add(prepareApplicationDocumentSlot(experience, diplomaCategory[0]));
            }
            insert documents;

            Set<Id> documentIds = new Set<Id>();
            for(TB_Application_Document__c singleDocument : documents) {
                documentIds.add(singleDocument.Id);
            }

            Map<String,List<String>> documentsCategory = new Map<String,List<String>>();
            for(TB_Application_Document__c singleDocument : [
                SELECT TB_Document_Category__c, TB_Document_File_Name__c
                FROM TB_Application_Document__c
                WHERE Id IN: documentIds
                ])
            {
                documentsCategory.put(singleDocument.TB_Document_Category__c, new List<String>{singleDocument.Id, singleDocument.TB_Document_File_Name__c});
            }
            return documentsCategory;
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    private static TB_Application_Document__c prepareApplicationDocumentSlot(
        TB_Experience_History__c experience, String documentCategory
    ) {
        TB_Application_Document__c applicationDocument = new TB_Application_Document__c(
            TB_Application__c = experience.TB_Application__c,
            TB_Status__c = 'Empty',
            TB_Experience__c = experience.Id,
            TB_Order__c = 1000,
            TB_Contact__c = experience.TB_Applicant__c,
            TB_Document_Category__c = documentCategory,
            TB_Document_Type__c = 'Scan',
            TB_Output_Format__c = 'Original'
        );
        return applicationDocument;
    }

    @AuraEnabled
    public static Map<String,List<String>> prepareHSExamFieldsMap() {
        Map<String,List<String>> fieldsForExamTypes = new Map<String,List<String>>();
        List<String> mustHaveFields = new List<String>{'TB_HS_Exam_Type__c','TB_Educational_Institution_City__c','TB_Educational_Institution__c'};
        List<String> polandExamFields = new List<String>{'TB_Document_Number__c','TB_Document_Issue_City__c','TB_Issue_Date__c'};
        List<String> foreignExamAdditionFields = new List<String>{'TB_HS_Exam_Country__c','TB_HS_Exam_GPA__c'};

        fieldsForExamTypes.put('noDiploma',mustHaveFields);

        List<String> hsExamTypes = new List<String>
        {
            'New_Polish_HS_Exam_Since_2005','Old_Polish_HS_Exam_1991_2004','Old_Polish_HS_Exam_Before_1991',
            'Foreign_HS_Exam', 'International_Baccalaureate_HS_Exam', 'European_Baccalaureate_HS_Exam'
        };

        for(String singleType : hsExamTypes) {
            List<String> finallyFields = new List<String>();
            finallyFields.addAll(mustHaveFields);
            finallyFields.addAll(polandExamFields);

            switch on singleType {
                when 'New_Polish_HS_Exam_Since_2005' {
                    finallyFields.add('TB_Regional_Examination_Board__c');
                }
                when 'International_Baccalaureate_HS_Exam','European_Baccalaureate_HS_Exam'{
                    finallyFields.add('TB_Educational_Institution_Country__c');
                }
                when 'Foreign_HS_Exam' {
                    finallyFields.add('TB_Educational_Institution_Country__c');
                    finallyFields.addAll(foreignExamAdditionFields);
                }
            }
            fieldsForExamTypes.put(singleType,finallyFields);
        }
        return fieldsForExamTypes;
    }

    @AuraEnabled
    public static String updateHSExamMetric(String examMetric, String apiNamesToDeleteValues, Boolean noDiploma, String applicationId) {

        if(applicationId != null){
            try{
                hed__Application__c application = new hed__Application__c(
                   Id = applicationId,
                   TB_No_HS_Exam__c = noDiploma
                );
                update application;
            }catch(Exception e){
                insert TB_LogUtils.registerLog(e);
                return 'APPLICATION_UPDATE_FAILED';
            }
        }

        TB_Experience_History__c experienceHistory = (TB_Experience_History__c) JSON.deserialize(examMetric, TB_Experience_History__c.class);
        List<String> apiNames = apiNamesToDeleteValues.split(';');
        for(String singleApiName : apiNames) {
            experienceHistory.put(singleApiName,null);
        }

        try {
            update experienceHistory;
            return JSON.serialize(experienceHistory);
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            String firstExceptionType = e.getMessage().substringAfter(':');
            firstExceptionType = firstExceptionType.split(',')[0];
            return 'UPDATE_FAILED.' + firstExceptionType;
        }
    }

    @AuraEnabled
    public static String handleExamScoreMetrics(
        String examType, String applicationId, String applicantId,
        String examMetricId, Boolean deleteMetrics, Boolean createMetrics
    ) {
        String result;
        if(deleteMetrics) {
            result = deleteExamScoreMetrics(applicationId,examMetricId);
            if(result == 'FAILED_DELETE_SCORE_METRICS') {
                return 'FAILED_DELETE_SCORE_METRICS';
            }else {
                TB_HighSchoolEducationScoreController.updateHsExamMetric(examMetricId, null, null);
                deleteStepHistoryByStepType(applicationId, TB_Constants.TB_ADMISSIONS_STEP_TYPE_HS_EXAM_SCORE);
            }
        }

        if(createMetrics) {
            result = createExamScoreMetrics(examType, applicationId, applicantId, examMetricId);
            return result;
        }
        return 'NO_UPDATE';
    }

    private static String createExamScoreMetrics(String examType, String applicationId, String applicantId, String examMetricId) {
        TB_Admissions_Dictionary__c examTypeRecord
            = (TB_Admissions_Dictionary__c) JSON.deserialize(examType, TB_Admissions_Dictionary__c.class);

        List<TB_Experience_History__c> experienceHistories = new List<TB_Experience_History__c>();
        Decimal numberOfSlots = examTypeRecord.TB_Number_of_Maturity_Subjects__c;
        if(numberOfSlots > 0 && numberOfSlots != null && numberOfSlots < 100){
            for(Integer i = 0; i < numberOfSlots; i++) {
                TB_Experience_History__c singleExperience = new TB_Experience_History__c
                (
                    TB_Application__c = applicationId,
                    TB_Applicant__c = applicantId,
                    TB_HS_Exam_Metric__c = examMetricId,
                    RecordTypeId = hsExamSubjectRecordTypeId
                );
                experienceHistories.add(singleExperience);
            }

            try {
                insert experienceHistories;
                return 'SUCCESS';
            }catch(Exception e) {
                insert TB_LogUtils.registerLog(e);
                return 'FAILED';
            }
        }
        return 'empty';
    }

    private static String deleteExamScoreMetrics(String applicationId, String examMetricId) {

        List<TB_Experience_History__c> scoreMetrics = [
            SELECT Id
            FROM TB_Experience_History__c
            WHERE TB_Application__c = :applicationId AND TB_HS_Exam_Metric__c = :examMetricId
            AND RecordTypeId = :hsExamSubjectRecordTypeId AND TB_Active__c = TRUE
        ];

        try {
            delete scoreMetrics;
            return 'SUCCESS_DELETE_METRICS';
        }catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return 'FAILED_DELETE_SCORE_METRICS';
        }
    }

    private static void deleteStepHistoryByStepType(String applicationId, String stepType) {
        List<TB_Application_Step_History__c> stepHistories = [
            SELECT Id, TB_Admissions_Step_Type__c
            FROM TB_Application_Step_History__c
            WHERE TB_Application__c = :applicationId AND TB_Admissions_Step_Type__c = :stepType
        ];
        try {
            if(stepHistories.size() > 0) {
                delete stepHistories;
            }
        }catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
        }
    }

}