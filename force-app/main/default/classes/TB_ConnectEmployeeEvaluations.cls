/**
 * Created by jowitakozlak on 17/06/2021.
 */

public with sharing class TB_ConnectEmployeeEvaluations {
    public static void connectEmployeeEvaluations (String processId, Boolean executeFlag) {

        List<TB_Employee_Evaluation__c> parentEmployeeEvaluations = [
            SELECT Id, Name, TB_Process_Type__c, TB_Employee_Evaluation_Process__c, TB_Evaluated__c,
                TB_Scientist_And_Didactic__c, TB_Final_Mark_Status__c, TB_Process_Status__c,
                TB_Evaluated__r.TB_Institute_Director_1__c, TB_Evaluated__r.TB_Scientific_Discipline_1__c,
                TB_Evaluated__r.TB_Scientific_Discipline_1_X__c, TB_Evaluated__r.TB_Institute_Director_2__c,
                TB_Employee_Evaluation_Process__r.TB_Administrator__c,
                TB_Employee_Evaluation_Process__r.TB_Rector__c, TB_For_Period__c
            FROM TB_Employee_Evaluation__c
            WHERE TB_Employee_Evaluation_Process__c = :processId
            AND TB_Process_Type__c = 'Didactic'
            AND TB_Scientist_And_Didactic__c = TRUE
        ];

        List<TB_Employee_Evaluation__c> childEmployeeEvaluations = new List<TB_Employee_Evaluation__c>();
        for (TB_Employee_Evaluation__c singleParentEmployeeEvaluation : parentEmployeeEvaluations) {
            childEmployeeEvaluations.add (
                new TB_Employee_Evaluation__c (
                    TB_Employee_Evaluation__c = singleParentEmployeeEvaluation.Id,
                    TB_Process_Type__c = 'Scientist',
                    TB_Employee_Evaluation_Process__c = processId,
                    TB_Evaluated__c = singleParentEmployeeEvaluation.TB_Evaluated__c,
                    TB_Evaluator__c = singleParentEmployeeEvaluation.TB_Evaluated__r.TB_Institute_Director_1__c,
                    TB_Supervisor__c = singleParentEmployeeEvaluation.TB_Evaluated__r.TB_Institute_Director_1__c,
                    TB_Final_Mark_Status__c = singleParentEmployeeEvaluation.TB_Final_Mark_Status__c,
                    TB_Process_Status__c = singleParentEmployeeEvaluation.TB_Process_Status__c,
                    Name = singleParentEmployeeEvaluation.Name,
                    TB_For_Period__c = singleParentEmployeeEvaluation.TB_For_Period__c,
                    TB_Rector__c = singleParentEmployeeEvaluation.TB_Employee_Evaluation_Process__r.TB_Rector__c,
                    TB_Administrator__c = singleParentEmployeeEvaluation.TB_Employee_Evaluation_Process__r.TB_Administrator__c,
                    TB_Scientific_Discipline__c =
                        singleParentEmployeeEvaluation.TB_Evaluated__r.TB_Scientific_Discipline_1__c,
                    TB_Scientific_Discipline_X__c =
                        singleParentEmployeeEvaluation.TB_Evaluated__r.TB_Scientific_Discipline_1_X__c,
                    TB_Scientist_And_Scientist__c = String.isNotBlank(
                        singleParentEmployeeEvaluation.TB_Evaluated__r.TB_Institute_Director_2__c
                    )
                )
            );
        }

        try {
            Database.executeBatch(
                new TB_CreateEmployeeEvaluationsBatch (
                    childEmployeeEvaluations, 'ConnectScientistEmployeeEvaluations', processId, executeFlag
                ),
                10
            );
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e, TB_CreateEmployeeEvaluations.class);
        }
    }

}