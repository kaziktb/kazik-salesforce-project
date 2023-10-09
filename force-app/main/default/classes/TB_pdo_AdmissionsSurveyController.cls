public without sharing class TB_pdo_AdmissionsSurveyController {
    @AuraEnabled
    public static SurveyWrapper getSurveyWrapper(String recordId){

        TB_PDO_Popularisation__c popularisation = getPDOTypeFromPopularisation(recordId);
        if(popularisation.TB_PDO__r.RecordType.DeveloperName == 'TB_Book'){
            popularisation.TB_PDO__r.RecordType.DeveloperName = 'TB_Article';
        }
        TB_Admissions_Survey__c survey = getSurveyDetails(popularisation.TB_PDO__r.RecordType.DeveloperName);
        List<TB_Admissions_Survey__c> questions = getQuestions(survey.Id);
        List<String> questionIds = new List<String>();
        for (TB_Admissions_Survey__c question : questions) {
            questionIds.add(question.Id);
        }
        List<TB_Admissions_Survey__c> questionsValues = getQuestionValues(questionIds);
        SurveyWrapper surveyWrapper = new SurveyWrapper();
        surveyWrapper.surveyInfo = survey;
        surveyWrapper.questions = questions;
        surveyWrapper.questionValues = questionsValues;

        return surveyWrapper;
    }
    @AuraEnabled
    public static TB_Admissions_Survey__c getSurveyDetails(
            String surveyAchievementType
    ) {
        TB_Admissions_Survey__c surveyDetails = [
                SELECT
                        TB_Display_Name_PL__c,
                        TB_Info_PL__c,
                        TB_Display_Name_EN__c,
                        TB_Info_EN__c
                FROM TB_Admissions_Survey__c
                WHERE TB_Achievement_Type__c = :surveyAchievementType
                AND TB_Active__c = true ORDER BY CreatedDate DESC LIMIT 1
        ];

        return surveyDetails;
    }

    @AuraEnabled
    public static List<TB_Admissions_Survey__c> getQuestions(String surveyId) {
        String recordTypeId = Schema.SObjectType.TB_Admissions_Survey__c.getRecordTypeInfosByDeveloperName()
                .get(TB_Constants.TB_ADMISSIONS_SURVEY_QUESTION_DEVELOPER_NAME)
                .getRecordTypeId();

        List<TB_Admissions_Survey__c> questions = [
                SELECT
                        Name,
                        TB_Display_Name_PL__c,
                        TB_Display_Name_EN__c,
                        TB_Info_PL__c,
                        TB_Info_EN__c,
                        TB_Visibility_Requirement__c,
                        TB_Question_Type__c,
                        TB_Required__c,
                        TB_Undeniable__c
                FROM TB_Admissions_Survey__c
                WHERE
                        TB_Active__c = TRUE
                        AND RecordTypeId = :recordTypeId
                        AND TB_Survey__c = :surveyId
                ORDER BY TB_Order__c
        ];

        return questions;
    }

    @AuraEnabled
    public static Id getSuveyIdByAchievementType(String achievementType) {
        return [
                SELECT Id
                FROM TB_Admissions_Survey__c
                WHERE TB_Achievement_Type__c = :achievementType
        ]
                .Id;
    }

    @AuraEnabled
    public static List<TB_Admissions_Survey__c> getQuestionValues(
            List<String> questionIds
    ) {
        String recordTypeId = Schema.SObjectType.TB_Admissions_Survey__c.getRecordTypeInfosByDeveloperName()
                .get(TB_Constants.TB_ADMISSIONS_SURVEY_QUESTION_VALUE_DEVELOPER_NAME)
                .getRecordTypeId();

        List<TB_Admissions_Survey__c> questionValues = [
                SELECT
                        TB_Display_Name_PL__c,
                        TB_Display_Name_EN__c,
                        TB_Question__c,
                        TB_Info_PL__c,
                        TB_Info_EN__c
                FROM TB_Admissions_Survey__c
                WHERE
                        TB_Active__c = TRUE
                        AND RecordTypeId = :recordTypeId
                        AND TB_Question__c IN :questionIds
                ORDER BY TB_Order__c
        ];
        return questionValues;
    }

    @AuraEnabled
    public static void addAnswersForPopularisation(String serializedAnswers){
        List<TB_Admissions_Survey_Answer__c> answers = (List<TB_Admissions_Survey_Answer__c>) JSON.deserialize(serializedAnswers, List<TB_Admissions_Survey_Answer__c>.class);

        if(answers.size() > 0){
            insert answers;
        }

        updatePopularisation(answers[0].TB_PDO_Popularisation__c);
    }

    public static void updatePopularisation(String popularisationId){
        TB_PDO_Popularisation__c popularisation = new TB_PDO_Popularisation__c();
        popularisation.Id = popularisationId;
        popularisation.TB_Stage__c = 'Survey_Answers_Received';
        update popularisation;
    }


    @AuraEnabled
    public static List<TB_Admissions_Survey_Answer__c> getPreviousAnswers(
            String surveyId,
            String popularisation
    ) {
        List<TB_Admissions_Survey_Answer__c> previousAnswers = [
                SELECT
                        TB_Question__c,
                        TB_Answer_Content__c,
                        TB_Answer_Selection__c,
                        TB_PDO_Popularisation__c
                FROM TB_Admissions_Survey_Answer__c
                WHERE TB_Survey__c = :surveyId AND TB_PDO_Popularisation__c = :popularisation
        ];

        return previousAnswers;
    }

    private static TB_PDO_Popularisation__c getPDOTypeFromPopularisation(String popularisationId){
        TB_PDO_Popularisation__c popularisation = [
                SELECT
                        Id,
                        TB_PDO__r.RecordType.DeveloperName,
                        TB_PDO__r.TB_Depositor__c,
                        TB_PDO_Survey_URL__c
                FROM TB_PDO_Popularisation__c
                WHERE Id = :popularisationId
                LIMIT 1
        ];

        return popularisation;
    }

    public class SurveyWrapper{
        @AuraEnabled
        public TB_Admissions_Survey__c surveyInfo;
        @AuraEnabled
        public List<TB_Admissions_Survey__c> questions;
        @AuraEnabled
        public List<TB_Admissions_Survey__c> questionValues;
    }
}