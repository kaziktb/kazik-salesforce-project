public with sharing class DT_InternshipLearningOutcomesController {
    private static final String LEARNING_OUTCOMES_QUERY_TEMPLATE = 'SELECT {0}, {1} ' 
        + 'FROM DT_Internship_Learning_Outcomes__c ' 
        + 'WHERE DT_Internship_Report__c = :recordId';
    private static final Map<String, String> FIELD_NAME_TO_API_NAME_PL = new Map<String, String> {
        'question' => 'DT_Question_PL__c',
        'description' => 'DT_Learning_Outcome_Descripton_PL__c'
    };
    private static final Map<String, String> FIELD_NAME_TO_API_NAME_EN = new Map<String, String> {
        'question' => 'DT_Question_EN__c',
        'description' => 'DT_Learning_Outcome_Descripton_EN__c'
    };

    @AuraEnabled(cacheable = true)
    public static List<LearningOutcomeWrapper> fetchAllLearningOutcomes(Id recordId, String language) {
        List<LearningOutcomeWrapper> learningOutcomeWrappers = new List<LearningOutcomeWrapper>();
        Map<String, String> fieldName2ApiName = new Map<String, String>();
        
        if (language == DT_Utils.EXPERIENCE_CLOUD_LANGUAGE_ENGLISH) {
            fieldName2ApiName = FIELD_NAME_TO_API_NAME_EN;
        } else if (language == DT_Utils.EXPERIENCE_CLOUD_LANGUAGE_POLISH) {
            fieldName2ApiName = FIELD_NAME_TO_API_NAME_PL;
        } else {
            return learningOutcomeWrappers;
        }

        String query = String.format(LEARNING_OUTCOMES_QUERY_TEMPLATE, fieldName2ApiName.values());

        for (DT_Internship_Learning_Outcomes__c learningOutcome : Database.query(query)) {
            LearningOutcomeWrapper learningOutcomeWrapper = new LearningOutcomeWrapper(
                learningOutcome.get(fieldName2ApiName.get('question')),
                learningOutcome.get(fieldName2ApiName.get('description'))
            );
            
            learningOutcomeWrappers.add(learningOutcomeWrapper);
        }

        return learningOutcomeWrappers;
    }

    public class LearningOutcomeWrapper {
        @AuraEnabled
        public String question = '';

        @AuraEnabled
        public String description = '';

        public LearningOutcomeWrapper(Object question, Object description) {
            this.question = (String) question;
            this.description = (String) description;
        }
    }
}