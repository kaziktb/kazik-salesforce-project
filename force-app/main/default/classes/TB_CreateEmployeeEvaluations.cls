/**
 * Created by jowitakozlak on 16/06/2021.
 */

public with sharing class TB_CreateEmployeeEvaluations {

    @InvocableMethod(label='createEmployeeEvaluations')
    public static void createEmployeeEvaluations (List<Id> processIds) {

        TB_Employee_Evaluation_Process__c employeeEvaluationProcess = [
            SELECT Id, TB_Process_Year__c, TB_For_Period__c, TB_Rector__c, TB_Administrator__c
            FROM TB_Employee_Evaluation_Process__c
            WHERE Id = :processIds[0]
        ];

        List<Contact> contacts = [
            SELECT Id, Name, TB_Included_In_Evaluations__c, TB_Employee_Group__c, TB_Dean__c,
                TB_Institute_Director_1__c, TB_Scientific_Discipline_1__c, TB_Scientific_Discipline_1_X__c,
                TB_Institute_Director_2__c
            FROM Contact
            WHERE TB_Included_In_Evaluations__c = TRUE
        ];

        List<TB_Employee_Evaluation__c> employeeEvaluations = new List<TB_Employee_Evaluation__c>();
        for (Contact contact : contacts) {
            TB_Employee_Evaluation__c employeeEvaluation
                = createEmployeeEvaluationBase(contact, employeeEvaluationProcess);
            //TODO Do rozważenia: czy nie połączyć metod do tworzenia employee evaluation, jakieś grupowanie?
            if (contact.TB_Employee_Group__c == 'Scientist') {
                employeeEvaluation.TB_Process_Type__c = 'Scientist';
                employeeEvaluation.TB_Evaluator__c = contact.TB_Institute_Director_1__c;
                employeeEvaluation.TB_Supervisor__c = contact.TB_Institute_Director_1__c;
                employeeEvaluation.TB_Scientific_Discipline__c = contact.TB_Scientific_Discipline_1__c;
                employeeEvaluation.TB_Scientific_Discipline_X__c = contact.TB_Scientific_Discipline_1_X__c;
                if (contact.TB_Institute_Director_2__c != null) {
                    employeeEvaluation.TB_Scientist_And_Scientist__c = true;
                }
            } else {
                employeeEvaluation.TB_Process_Type__c = 'Didactic';
                employeeEvaluation.TB_Evaluator__c = contact.TB_Dean__c;
                employeeEvaluation.TB_Supervisor__c = contact.TB_Dean__c;
                if (contact.TB_Employee_Group__c != 'Didactic') {
                    employeeEvaluation.TB_Scientist_And_Didactic__c = true;
                }
            }
            employeeEvaluations.add(employeeEvaluation);
        }

        try {
            Database.executeBatch (
                new TB_CreateEmployeeEvaluationsBatch(
                    employeeEvaluations, 'ConnectEmployeeEvaluations', processIds[0], true
                ),
                10
            );
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e, TB_CreateEmployeeEvaluations.class);
        }
    }

    private static TB_Employee_Evaluation__c createEmployeeEvaluationBase (
        Contact contact, TB_Employee_Evaluation_Process__c process
    ) {
        TB_Employee_Evaluation__c employeeEvaluation = new TB_Employee_Evaluation__c();
        employeeEvaluation.TB_Employee_Evaluation_Process__c = process.Id;
        employeeEvaluation.TB_Evaluated__c = contact.Id;
        employeeEvaluation.TB_Final_Mark_Status__c = 'Not Given';
        employeeEvaluation.TB_Process_Status__c = 'Configuration';
        employeeEvaluation.Name = contact.Name + ' ' + process.TB_Process_Year__c;
        employeeEvaluation.TB_For_Period__c = process.TB_For_Period__c;
        employeeEvaluation.TB_Rector__c = process.TB_Rector__c;
        employeeEvaluation.TB_Administrator__c = process.TB_Administrator__c;
        return employeeEvaluation;
    }
}