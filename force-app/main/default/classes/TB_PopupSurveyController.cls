/**
 * Created by jowitakozlak on 01/03/2022.
 */

public with sharing class TB_PopupSurveyController {

    @AuraEnabled
    public static String getSurveyLogics(hed__Application__c application, String language) {
        try {
            Set<TB_Admissions_Logic__c> admissionsLogics = new Set<TB_Admissions_Logic__c>();
            Set<Id> admissionsSurveysIds = new Set<Id>();
            List<TB_JSON_Wrapper__c> logicJsonWrappers = [
                SELECT Id, TB_Wrapper_Value__c
                FROM TB_JSON_Wrapper__c
                WHERE TB_Parent_JSON_Wrapper__r.TB_Object_Id__c = :application.TB_Admissions_Process_Id__c
                AND TB_Record_Type_Dev_Name__c = 'TB_Survey_Logic'
                ORDER BY TB_Order__c
            ];

            for (TB_JSON_Wrapper__c logicJsonWrapper : logicJsonWrappers) {
                TB_Admissions_Logic__c admissionsLogic = (TB_Admissions_Logic__c) JSON.deserialize(
                    logicJsonWrapper.TB_Wrapper_Value__c, TB_Admissions_Logic__c.class
                );
                if (admissionsLogic.TB_Active__c == true) {
                    admissionsLogics.add(admissionsLogic);
                    admissionsSurveysIds.add(admissionsLogic.TB_Admissions_Survey__c);
                }
            }

            Set<TB_Admissions_Survey__c> admissionsSurveys = new Set<TB_Admissions_Survey__c>();
            List<TB_JSON_Wrapper__c> surveyJsonWrappers = [
                SELECT Id, TB_Wrapper_Value__c
                FROM TB_JSON_Wrapper__c
                WHERE TB_Object_Id__c IN :admissionsSurveysIds
                ORDER BY TB_Order__c
            ];

            for (TB_JSON_Wrapper__c surveyJsonWrapper : surveyJsonWrappers) {
                TB_Admissions_Survey__c admissionsSurvey = (TB_Admissions_Survey__c) JSON.deserialize(
                    surveyJsonWrapper.TB_Wrapper_Value__c, TB_Admissions_Survey__c.class
                );
                if (admissionsSurvey.TB_Active__c == true) {
                    admissionsSurveys.add(admissionsSurvey);
                }
            }

            List<SurveyLogicsWrapper> logicWrappers = new List<SurveyLogicsWrapper>();

            logicWrappers = getQuestions(
                admissionsSurveysIds,
                logicWrappers, admissionsLogics, admissionsSurveys, language
            );

            return JSON.serialize(logicWrappers);
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    public static List<SurveyLogicsWrapper> getQuestions (
        Set<Id> admissionsSurveysIds, List<SurveyLogicsWrapper> logicWrappers,
        Set<TB_Admissions_Logic__c> admissionsLogics, Set<TB_Admissions_Survey__c> admissionsSurveys,
        String language
    ) {
        Set<TB_Admissions_Survey__c> questions = new Set<TB_Admissions_Survey__c>();
        Set<Id> questionsIds = new Set<Id>();
        Map<Id,List<TB_Admissions_Survey__c>> surveyIdToQuestions = new Map<Id,List<TB_Admissions_Survey__c>>();
        List<TB_JSON_Wrapper__c> questionJsonWrappers = [
            SELECT Id, TB_Wrapper_Value__c
            FROM TB_JSON_Wrapper__c
            WHERE TB_Parent_JSON_Wrapper__r.TB_Object_Id__c IN :admissionsSurveysIds
            AND TB_Record_Type_Dev_Name__c = 'TB_Question'
            ORDER BY TB_Order__c
        ];

        for (TB_JSON_Wrapper__c questionJsonWrapper : questionJsonWrappers) {
            TB_Admissions_Survey__c question = (TB_Admissions_Survey__c) JSON.deserialize(
                questionJsonWrapper.TB_Wrapper_Value__c, TB_Admissions_Survey__c.class
            );
            if (question.TB_Active__c == true && question.TB_Question_Type__c == 'Single_Choice') {
                questions.add(question);
                questionsIds.add(question.Id);
            }
        }

        for (TB_Admissions_Survey__c survey : admissionsSurveys) {
            for (TB_Admissions_Survey__c question : questions) {
                if (survey.Id == question.TB_Survey__c) {
                    List<TB_Admissions_Survey__c> questionsInSurvey = new List<TB_Admissions_Survey__c>();
                    if (surveyIdToQuestions.get(survey.Id) != null) {
                        questionsInSurvey = surveyIdToQuestions.get(survey.Id);
                    }
                    questionsInSurvey.add(question);
                    surveyIdToQuestions.put(survey.Id, questionsInSurvey);
                }
            }
        }

        logicWrappers = getQuestionValues(
            questionsIds, questions, surveyIdToQuestions,
            logicWrappers, admissionsLogics, admissionsSurveys, language
        );

        return logicWrappers;
    }

    public static List<SurveyLogicsWrapper> getQuestionValues (
        Set<Id> questionsIds, Set<TB_Admissions_Survey__c> questions,
        Map<Id,List<TB_Admissions_Survey__c>> surveyIdToQuestions, List<SurveyLogicsWrapper> logicWrappers,
        Set<TB_Admissions_Logic__c> admissionsLogics, Set<TB_Admissions_Survey__c> admissionsSurveys,
        String language
    ) {
        if (!questionsIds.isEmpty()) {
            Map<Id,List<TB_Admissions_Survey__c>> questionIdToQuestionValues = new Map<Id,List<TB_Admissions_Survey__c>>();
            Set<TB_Admissions_Survey__c> questionValues = new Set<TB_Admissions_Survey__c>();
            List<TB_JSON_Wrapper__c> questionValueJsonWrappers = [
                SELECT Id, TB_Wrapper_Value__c
                FROM TB_JSON_Wrapper__c
                WHERE TB_Parent_JSON_Wrapper__r.TB_Object_Id__c IN :questionsIds
                AND TB_Record_Type_Dev_Name__c = 'TB_Question_Value'
                ORDER BY TB_Order__c
            ];

            for (TB_JSON_Wrapper__c questionValueJsonWrapper : questionValueJsonWrappers) {
                TB_Admissions_Survey__c questionValue = (TB_Admissions_Survey__c) JSON.deserialize(
                    questionValueJsonWrapper.TB_Wrapper_Value__c, TB_Admissions_Survey__c.class
                );
                if (questionValue.TB_Active__c == true) {
                    questionValues.add(questionValue);
                }
            }

            for (TB_Admissions_Survey__c question : questions) {
                for (TB_Admissions_Survey__c questionValue : questionValues) {
                    if (question.Id == questionValue.TB_Question__c) {
                        List<TB_Admissions_Survey__c> questionValuesInQuestion = new List<TB_Admissions_Survey__c>();
                        if (questionIdToQuestionValues.get(question.Id) != null) {
                            questionValuesInQuestion = questionIdToQuestionValues.get(question.Id);
                        }
                        questionValuesInQuestion.add(questionValue);
                        questionIdToQuestionValues.put(question.Id, questionValuesInQuestion);

                    }
                }
            }

            logicWrappers = prepareSurveyLogicsWrappers(
                questionIdToQuestionValues,
                logicWrappers, admissionsLogics, admissionsSurveys, surveyIdToQuestions, language
            );
        }

        return logicWrappers;
    }

    public static List<SurveyLogicsWrapper> prepareSurveyLogicsWrappers (
        Map<Id,List<TB_Admissions_Survey__c>> questionIdToQuestionValues, List<SurveyLogicsWrapper> logicWrappers,
        Set<TB_Admissions_Logic__c> admissionsLogics, Set<TB_Admissions_Survey__c> admissionsSurveys,
        Map<Id,List<TB_Admissions_Survey__c>> surveyIdToQuestions, String language
    ) {
        for (TB_Admissions_Logic__c logic : admissionsLogics) {
            for (TB_Admissions_Survey__c survey : admissionsSurveys) {
                if (logic.TB_Admissions_Survey__c == survey.Id && logic.TB_Admissions_Survey__c != null) {
                    SurveyLogicsWrapper singleWrapper = new SurveyLogicsWrapper(logic);
                    singleWrapper.surveyName = String.valueOf(survey.get('TB_Display_Name_' + language + '__c'));
                    singleWrapper.surveyInfo = String.valueOf(survey.get('TB_Info_' + language + '__c'));

                    TB_Admissions_Survey__c question = surveyIdToQuestions.get(survey.Id)[0];
                    singleWrapper.questionName = String.valueOf(question.get('TB_Display_Name_' + language + '__c'));
                    singleWrapper.questionInfo = String.valueOf(question.get('TB_Info_' + language + '__c'));

                    List<TB_Admissions_Survey__c> questionValuesFromQuestion = questionIdToQuestionValues.get(question.Id);
                    List<String> questionValuesNames = new List<String>();
                    List<String> questionValuesIds = new List<String>();
                    for (TB_Admissions_Survey__c questionValue : questionValuesFromQuestion) {
                        questionValuesNames.add(String.valueOf(questionValue.get('TB_Display_Name_' + language + '__c')));
                        questionValuesIds.add(questionValue.Id);
                    }
                    singleWrapper.questionValueNames = questionValuesNames;
                    singleWrapper.questionValueIds = questionValuesIds;

                    if (!singleWrapper.questionValueNames.isEmpty()) {
                        logicWrappers.add(singleWrapper);
                    }
                }
            }
        }

        return logicWrappers;
    }

    @AuraEnabled
    public static String updateApplication(String applicationId, String questionValueId) {
        try {
            hed__Application__c application = [
                SELECT Id
                FROM hed__Application__c
                WHERE Id = :applicationId
            ];
            application.TB_Survey_Answer__c = questionValueId;
            update application;
            return 'success';
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    public class SurveyLogicsWrapper {
        @AuraEnabled public TB_Admissions_Logic__c al { get; set; }
        @AuraEnabled public String surveyName { get; set; }
        @AuraEnabled public String surveyInfo { get; set; }
        @AuraEnabled public String questionName { get; set; }
        @AuraEnabled public String questionInfo { get; set; }
        @AuraEnabled public List<String> questionValueNames { get; set; }
        @AuraEnabled public List<String> questionValueIds { get; set; }

        public SurveyLogicsWrapper(TB_Admissions_Logic__c al) {
            this.al = al;
        }
    }

}