/**
 * Created by jowitakozlak on 16/07/2021.
 */

@IsTest
public with sharing class TB_CreateEmployeeEvaluationsTest {

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
        Contact didactic = new Contact(
            LastName = 'Kot',
            TB_Included_In_Evaluations__c = true,
            TB_Employee_Group__c = 'Didactic',
            TB_Dean__c = rector.Id,
            TB_Employee_Number__c = '00002'
        );
        insert didactic;
        Contact scientist = new Contact(
            LastName = 'Nowak',
            TB_Included_In_Evaluations__c = true,
            TB_Employee_Group__c = 'Scientist',
            TB_Institute_Director_1__c = rector.Id,
            TB_Scientific_Discipline_1__c = 'Not applicable',
            TB_Scientific_Discipline_1_X__c = '75%',
            TB_Institute_Director_2__c = rector.Id,
            TB_Scientific_Discipline_2__c = 'Not applicable',
            TB_Scientific_Discipline_2_X__c = '25%',
            TB_Employee_Number__c = '00003'
        );
        insert scientist;
        Contact scientistAndDidactic = new Contact(
            LastName = 'Adamowicz',
            TB_Included_In_Evaluations__c = true,
            TB_Employee_Group__c = 'Scientist and Didactic',
            TB_Dean__c = rector.Id,
            TB_Institute_Director_1__c = rector.Id,
            TB_Scientific_Discipline_1__c = 'Not applicable',
            TB_Scientific_Discipline_1_X__c = '100%',
            TB_Employee_Number__c = '00004'
        );
        insert scientistAndDidactic;
    }

    @IsTest
    static void createEEPositive() {
        TB_Employee_Evaluation_Process__c employeeEvaluationProcess = [
            SELECT Id
            FROM TB_Employee_Evaluation_Process__c
            WHERE Name = 'Ewaluacja'
            LIMIT 1
        ];

        Test.startTest();
        TB_CreateEmployeeEvaluations.createEmployeeEvaluations(new List<Id>{employeeEvaluationProcess.Id});
        Test.stopTest();

        List<TB_Employee_Evaluation__c> employeeEvaluations = [
            SELECT Id, TB_Process_Type__c, TB_Evaluated__r.LastName
            FROM TB_Employee_Evaluation__c
            WHERE TB_Employee_Evaluation_Process__c =: employeeEvaluationProcess.Id
            AND TB_Employee_Evaluation__c = NULL
        ];

        System.assertEquals(3,employeeEvaluations.size());
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

        List<Contact> contacts = [
            SELECT Id, TB_Included_In_Evaluations__c
            FROM Contact
            WHERE TB_Included_In_Evaluations__c =: true
        ];

        for (Contact contact : contacts) {
            contact.TB_Included_In_Evaluations__c = false;
        }

        update contacts;

        Test.startTest();
        TB_CreateEmployeeEvaluations.createEmployeeEvaluations(new List<Id>{employeeEvaluationProcess.Id});
        Test.stopTest();

        List<TB_Employee_Evaluation__c> employeeEvaluations = [
            SELECT Id, TB_Process_Type__c, TB_Evaluated__r.LastName
            FROM TB_Employee_Evaluation__c
            WHERE TB_Employee_Evaluation_Process__c =: employeeEvaluationProcess.Id
        ];

        System.assertEquals(0,employeeEvaluations.size());
    }

}