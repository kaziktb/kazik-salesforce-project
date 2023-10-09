/**
 * Created by Aneta on 27/07/2021.
 */

@IsTest
private class TB_SendAcademicActivityReportEvrTest {
    @TestSetup
    static void testSetup() {

        Integer days = Integer.valueOf(TB_Days_For_Reminder__mdt.getInstance('TB_Report_Evaluator_Reminder').TB_How_Many_Days_Earlier__c);

        Contact evaluated = TB_TestDataFactory.prepareContact('Mr', 'test1@test.invalid',false);
        insert evaluated;
        Contact evaluator = TB_TestDataFactory.prepareContact('Miss', 'test2@test.invalid',false);
        insert evaluator;

        TB_Employee_Evaluation__c employeeEvaluationDidactic = TB_TestDataFactory.prepareEmployeeEvaluation(evaluated.Id, evaluator.Id,'Didactic');
        insert employeeEvaluationDidactic;
        TB_Employee_Evaluation__c employeeEvaluationScientist = TB_TestDataFactory.prepareEmployeeEvaluation(evaluated.Id, evaluator.Id,'Scientist');
        insert employeeEvaluationScientist;

        TB_Employee_Evaluation_Process_Stage__c processStage = TB_TestDataFactory.prepareEmployeeEvaluationProcessStage('Academic Activity Report');
        insert processStage;

        TB_Employee_Evaluation_Stage__c employeeEvaluationStageDidactic = TB_TestDataFactory.prepareEmployeeEvaluationStage
        (
            processStage.Id, employeeEvaluationDidactic.Id, 'New',
            'Academic Activity Report',Date.today().addDays(days)
        );
        insert employeeEvaluationStageDidactic;

        TB_Employee_Evaluation_Stage__c employeeEvaluationStageScientist = TB_TestDataFactory.prepareEmployeeEvaluationStage
        (
            processStage.Id, employeeEvaluationScientist.Id, 'New',
            'Academic Activity Report',Date.today().addDays(days)
        );
        insert employeeEvaluationStageScientist;
    }

    @IsTest
    static void sendAcademicActivityReportToEvaluator() {
        Test.startTest();
        TB_SendAcademicActivityReportEvaluator.sendAcademicActivityReportToEvaluator();
        Test.stopTest();
    }
}