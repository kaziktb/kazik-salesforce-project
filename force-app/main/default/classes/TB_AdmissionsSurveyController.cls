public without sharing class TB_AdmissionsSurveyController {
    @AuraEnabled
    public static TB_Admissions_Survey__c getSurveyDetails(String surveyProcessId) {
        String surveyId;

        for (TB_JSON_Wrapper__c singleWrapper : [
            SELECT Id, TB_Wrapper_Value__c, TB_Object_API_Name__c
            FROM TB_JSON_Wrapper__c
            WHERE
                TB_Object_API_Name__c = :TB_Admissions_Process__c.getSObjectType()
                    .getDescribe()
                    .getName()
            ORDER BY TB_Order__c
        ]) {
            TB_Admissions_Process__c admissionsProcess = (TB_Admissions_Process__c) JSON.deserialize(
                singleWrapper.TB_Wrapper_Value__c,
                TB_Admissions_Process__c.class
            );
            if (admissionsProcess.Id == surveyProcessId) {
                surveyId = admissionsProcess.TB_Admissions_Survey__c;
                break;
            }
        }

        TB_Admissions_Survey__c surveyDetails = [
            SELECT TB_Display_Name_PL__c, TB_Info_PL__c, TB_Display_Name_EN__c, TB_Info_EN__c
            FROM TB_Admissions_Survey__c WHERE id = :surveyId];

        return surveyDetails;
    }

    @AuraEnabled
    public static List<TB_Admissions_Survey__c> getQuestions(String surveyId) {
        String recordTypeId = Schema.SObjectType.TB_Admissions_Survey__c.getRecordTypeInfosByName()
            .get(TB_Constants.TB_ADMISSIONS_SURVEY_QUESTION)
            .getRecordTypeId();

        List<TB_Admissions_Survey__c> questions = [
            SELECT Name, TB_Display_Name_PL__c, TB_Display_Name_EN__c, TB_Info_PL__c, TB_Info_EN__c,
                TB_Visibility_Requirement__c, TB_Question_Type__c, TB_Required__c
            FROM TB_Admissions_Survey__c
            WHERE TB_Active__c = TRUE AND RecordTypeId = :recordTypeId AND TB_Survey__c = :surveyId
            ORDER BY TB_Order__c
        ];

        return questions;
    }

    @AuraEnabled
    public static List<TB_Admissions_Survey__c> getQuestionValues(List<String> questionIds) {
        String recordTypeId = Schema.SObjectType.TB_Admissions_Survey__c.getRecordTypeInfosByName()
            .get(TB_Constants.TB_ADMISSIONS_SURVEY_QUESTION_VALUE)
            .getRecordTypeId();

        List<TB_Admissions_Survey__c> questionValues = [
            SELECT TB_Display_Name_PL__c, TB_Display_Name_EN__c, TB_Question__c
            FROM TB_Admissions_Survey__c
            WHERE TB_Active__c = TRUE AND RecordTypeId = :recordTypeId AND TB_Question__c IN :questionIds
            ORDER BY TB_Order__c
        ];

        return questionValues;
    }

    @AuraEnabled
    public static void addAnswers(List<String> answers, String surveyId, String applicationId) {
        List<TB_Admissions_Survey_Answer__c> previousAnswers = [
            SELECT
                TB_Answer_Content__c,
                TB_Answer_Selection__c,
                TB_Application__c,
                TB_Chosen__c,
                TB_Question__c,
                TB_Survey__c
            FROM TB_Admissions_Survey_Answer__c
            WHERE TB_Survey__c = :surveyId AND TB_Application__c = :applicationId
        ];

        List<Database.DeleteResult> previousAnswersDeleteResult = Database.delete(
            previousAnswers,
            true
        );

        List<String> deleteLogs = new List<String>();

        for (
            Database.DeleteResult singleDeleteResult : previousAnswersDeleteResult
        ) {
            if (!singleDeleteResult.isSuccess()) {
                deleteLogs.add(singleDeleteResult.errors.get(0).message);
            }
        }

        insert TB_LogUtils.registerLogs(
            deleteLogs,
            TB_Admissions_Survey_Answer__c.getSObjectType().getDescribe().getName()
        );

        List<TB_Admissions_Survey_Answer__c> newAnswers = new List<TB_Admissions_Survey_Answer__c>();
        for (String answer : answers) {
            newAnswers.add(
                (TB_Admissions_Survey_Answer__c) json.deserialize(
                    answer,
                    TB_Admissions_Survey_Answer__c.class
                )
            );
        }

        List<Database.SaveResult> previousAnswersInsertResult = Database.insert(
            newAnswers,
            true
        );

        List<String> insertLogs = new List<String>();

        for (Database.SaveResult singleInsertResult : previousAnswersInsertResult) {
            if (!singleInsertResult.isSuccess()) {
                insertLogs.add(singleInsertResult.errors.get(0).message);
            }
        }

        insert TB_LogUtils.registerLogs(
            insertLogs,
            TB_Admissions_Survey_Answer__c.getSObjectType().getDescribe().getName()
        );
    }

    @AuraEnabled
    public static List<TB_Admissions_Survey_Answer__c> getPreviousAnswers(String surveyId, String applicationId) {
        List<TB_Admissions_Survey_Answer__c> previousAnswers = [
            SELECT TB_Question__c, TB_Answer_Content__c, TB_Answer_Selection__c, TB_Chosen__c, TB_Application__c
            FROM TB_Admissions_Survey_Answer__c
            WHERE TB_Survey__c = :surveyId AND TB_Application__c = :applicationId
        ];

        return previousAnswers;
    }
}