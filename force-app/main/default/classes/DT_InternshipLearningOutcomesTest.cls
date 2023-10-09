@IsTest
public with sharing class DT_InternshipLearningOutcomesTest {
    private static final String QUESTION_PL = 'Question PL';
    private static final String DESCRIPTION_PL = 'Description PL';
    private static final String QUESTION_EN = 'Question EN';
    private static final String DESCRIPTION_EN = 'Description EN';

    @TestSetup
    private static void prepareData() {
        List<DT_Internship_Requirement__c> requirements = DT_DataFactory.createInternshipRequirements(1, true);

        List<DT_Internship_Settlement__c> settlements = DT_DataFactory.createIndividualInternshipSettlementsForRequirement(1, requirements[0].Id, true);
        DT_DataFactory.createInternshipLearningOutcomes(2, true, settlements[0]);
    }

    @IsTest
    private static void fetchAllLearningOutcomesPolish() {
        DT_Internship_Settlement__c settlement = [SELECT Id FROM DT_Internship_Settlement__c LIMIT 1];

        String language = DT_Utils.EXPERIENCE_CLOUD_LANGUAGE_POLISH;

        List<DT_Internship_Learning_Outcomes__c> learningOutcomes = [
            SELECT Id
            FROM DT_Internship_Learning_Outcomes__c
            WHERE DT_Internship_Report__c = :settlement.Id
        ];

        for (DT_Internship_Learning_Outcomes__c learningOutcome : learningOutcomes) {
            learningOutcome.DT_Question_PL__c = QUESTION_PL;
            learningOutcome.DT_Learning_Outcome_Descripton_PL__c = DESCRIPTION_PL;
            learningOutcome.DT_Question_EN__c = QUESTION_EN;
            learningOutcome.DT_Learning_Outcome_Descripton_EN__c = DESCRIPTION_EN;
        }

        update learningOutcomes;

        Test.startTest();

        List<DT_InternshipLearningOutcomesController.LearningOutcomeWrapper> learningOutcomeWrappers = DT_InternshipLearningOutcomesController.fetchAllLearningOutcomes(settlement.Id, language);

        Test.stopTest();

        System.assertEquals(2, learningOutcomeWrappers.size());
        System.assertEquals(QUESTION_PL, learningOutcomeWrappers[0].question);
        System.assertEquals(DESCRIPTION_PL, learningOutcomeWrappers[0].description);
    }

    @IsTest
    private static void fetchAllLearningOutcomesEnglish() {
        DT_Internship_Settlement__c settlement = [SELECT Id FROM DT_Internship_Settlement__c LIMIT 1];

        String language = DT_Utils.EXPERIENCE_CLOUD_LANGUAGE_ENGLISH;

        List<DT_Internship_Learning_Outcomes__c> learningOutcomes = [
            SELECT Id
            FROM DT_Internship_Learning_Outcomes__c
            WHERE DT_Internship_Report__c = :settlement.Id
        ];

        for (DT_Internship_Learning_Outcomes__c learningOutcome : learningOutcomes) {
            learningOutcome.DT_Question_PL__c = QUESTION_PL;
            learningOutcome.DT_Learning_Outcome_Descripton_PL__c = DESCRIPTION_PL;
            learningOutcome.DT_Question_EN__c = QUESTION_EN;
            learningOutcome.DT_Learning_Outcome_Descripton_EN__c = DESCRIPTION_EN;
        }

        update learningOutcomes;

        Test.startTest();

        List<DT_InternshipLearningOutcomesController.LearningOutcomeWrapper> learningOutcomeWrappers = DT_InternshipLearningOutcomesController.fetchAllLearningOutcomes(settlement.Id, language);

        Test.stopTest();

        System.assertEquals(2, learningOutcomeWrappers.size());
        System.assertEquals(QUESTION_EN, learningOutcomeWrappers[0].question);
        System.assertEquals(DESCRIPTION_EN, learningOutcomeWrappers[0].description);
    }
}