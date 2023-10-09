/**
 * Created by jowitakozlak on 28/07/2021.
 */

@IsTest
public with sharing class TB_ConnectEmployeeEvaluationsTest {
    
    @TestSetup
    static void testSetup() {

        Contact rector = new Contact(
            LastName = 'Kowalski',
            TB_Included_In_Evaluations__c = false
        );
        insert rector;
        Contact administrator = new Contact(
            LastName = 'Kowal',
            TB_Included_In_Evaluations__c = false,
            hed__WorkEmail__c = 'test@gmail.com'
        );
        insert administrator;
        TB_Employee_Evaluation_Process__c employeeEvaluationProcess = new TB_Employee_Evaluation_Process__c(
            Name = 'Ewaluacja',
            TB_Process_Year__c = '2021',
            TB_Rector__c = rector.Id,
            TB_Administrator__c = administrator.Id
        );
        insert employeeEvaluationProcess;
        Contact scientistAndDidactic = new Contact(
            LastName = 'Adamowicz',
            TB_Included_In_Evaluations__c = true,
            TB_Employee_Group__c = 'Scientist and Didactic',
            TB_Dean__c = rector.Id,
            TB_Institute_Director_1__c = rector.Id,
            TB_Scientific_Discipline_1__c = 'Not applicable',
            TB_Scientific_Discipline_1_X__c = '100%',
            TB_Employee_Number__c = '00002'
        );
        insert scientistAndDidactic;

        TB_Employee_Evaluation__c evaluation
            = TB_TestDataFactory.prepareEmployeeEvaluation(scientistAndDidactic.Id,'Didactic');
        evaluation.TB_Scientist_And_Didactic__c = true;
        evaluation.TB_Employee_Evaluation_Process__c = employeeEvaluationProcess.Id;
        insert evaluation;
    }

    @IsTest
    static void connectEEPositive() {
        TB_Employee_Evaluation_Process__c employeeEvaluationProcess = [
            SELECT Id
            FROM TB_Employee_Evaluation_Process__c
            WHERE Name = 'Ewaluacja'
            LIMIT 1
        ];

        Test.startTest();
        TB_ConnectEmployeeEvaluations.connectEmployeeEvaluations(employeeEvaluationProcess.Id, true);
        Test.stopTest();

        List<TB_Employee_Evaluation__c> employeeEvaluations = [
            SELECT Id
            FROM TB_Employee_Evaluation__c
            WHERE TB_Employee_Evaluation_Process__c =: employeeEvaluationProcess.Id
            AND TB_Process_Type__c =: 'Scientist'
        ];

        System.assertEquals(1,employeeEvaluations.size());
        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void createEENegative() {
        TB_Employee_Evaluation_Process__c employeeEvaluationProcess = [
            SELECT Id
            FROM TB_Employee_Evaluation_Process__c
            WHERE Name = 'Ewaluacja'
            LIMIT 1
        ];

        List<TB_Employee_Evaluation__c> evaluations = [
            SELECT Id
            FROM TB_Employee_Evaluation__c
            WHERE TB_Employee_Evaluation_Process__c =: employeeEvaluationProcess.Id
        ];
        delete evaluations;

        Test.startTest();
        TB_ConnectEmployeeEvaluations.connectEmployeeEvaluations(employeeEvaluationProcess.Id,true);
        Test.stopTest();

        List<TB_Employee_Evaluation__c> employeeEvaluations = [
            SELECT Id
            FROM TB_Employee_Evaluation__c
            WHERE TB_Employee_Evaluation_Process__c =: employeeEvaluationProcess.Id
            AND TB_Process_Type__c =: 'Scientist'
        ];

        System.assertEquals(0,employeeEvaluations.size());
    }

}