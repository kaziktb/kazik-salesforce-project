/**
 * Created by kacperjachowicz on 18/08/2021.
 */
@IsTest
public with sharing class TB_EmployeeEvaluationTriggerHelperTest {

    @TestSetup
    static void createTestData(){
        Contact contact = TB_TestDataFactory.prepareContact(true);
        Contact contact2 = TB_TestDataFactory.prepareContact(false);
        contact2.FirstName = 'UpdatedName';
        insert contact2;

        TB_TestDataFactory.prepareContactAttribute(contact.Id, true);

        TB_Employee_Evaluation__c employeeEvaluation = TB_TestDataFactory.prepareEmployeeEvaluation(
            contact.Id,
            TB_Constants.EE_PROCESS_TYPE_DIDACTIC
        );
        insert employeeEvaluation;

        TB_Employee_Evaluation_Process_Stage__c employeeEvaluationProcessStage = TB_TestDataFactory.prepareEmployeeEvaluationProcessStage(TB_Constants.EEPS_TYPE_ACADEMIC_ACTIVITY_REPORT);
        insert employeeEvaluationProcessStage;

        TB_Employee_Evaluation_Stage__c employeeEvaluationStage = TB_TestDataFactory.prepareEmployeeEvaluationStage(
            employeeEvaluationProcessStage.Id,
            employeeEvaluation.Id
        );

        insert employeeEvaluationStage;
        TB_Data_Collection__c dataCollection = TB_TestDataFactory.prepareDataCollection(employeeEvaluationStage.Id,'Contact','FirstName', 'Contact','FirstName');
        dataCollection.TB_Source_Object_Id__c = contact.Id;
        dataCollection.TB_Employee_Evaluation__c = employeeEvaluation.Id;
        insert dataCollection;
    }

    @IsTest
    static void updateEvaluatedRelationshipsTest(){
        TB_Employee_Evaluation__c employeeEvaluation = [SELECT Id,TB_Evaluated__c FROM TB_Employee_Evaluation__c];
        Contact contact = [SELECT Id,FirstName FROM Contact WHERE FirstName != 'UpdatedName'];
        Contact contact2 = [SELECT Id,FirstName FROM Contact WHERE FirstName = 'UpdatedName'];
        TB_Data_Collection__c dataCollection = [SELECT Id,TB_Value_Text__c,TB_Source_Object_Id__c FROM TB_Data_Collection__c];

        System.assert(employeeEvaluation.TB_Evaluated__c == contact.Id);
        System.assert(dataCollection.TB_Value_Text__c == null);
        System.assert(dataCollection.TB_Source_Object_Id__c == contact.Id);

        Test.startTest();
        employeeEvaluation.TB_Evaluated__c = contact2.Id;
        update employeeEvaluation;
        Test.stopTest();

//        TB_Data_Collection__c dataCollectionAfterUpdate = [SELECT Id,TB_Source_Object_Id__c,TB_Value_Text__c FROM TB_Data_Collection__c];
//        System.assert(dataCollectionAfterUpdate.TB_Source_Object_Id__c == contact2.Id);
//        System.assert(dataCollectionAfterUpdate.TB_Value_Text__c == contact2.FirstName);
    }

    @IsTest
    static void updateSupervisorRelationshipsTest(){
        TB_Employee_Evaluation__c employeeEvaluation = [SELECT Id,TB_Evaluated__c,TB_Supervisor__c FROM TB_Employee_Evaluation__c];
        Contact contact = [SELECT Id,FirstName FROM Contact WHERE FirstName != 'UpdatedName'];
        Contact contact2 = [SELECT Id,FirstName FROM Contact WHERE FirstName = 'UpdatedName'];
        TB_Data_Collection__c dataCollection = [SELECT Id,TB_Value_Text__c,TB_Source_Object_Id__c FROM TB_Data_Collection__c];

        System.assert(employeeEvaluation.TB_Supervisor__c == null);
        System.assert(dataCollection.TB_Value_Text__c == null);
        System.assert(dataCollection.TB_Source_Object_Id__c == contact.Id);

        Test.startTest();
        employeeEvaluation.TB_Supervisor__c = contact2.Id;
        update employeeEvaluation;
        Test.stopTest();

//        TB_Data_Collection__c dataCollectionAfterUpdate = [SELECT Id,TB_Source_Object_Id__c,TB_Value_Text__c FROM TB_Data_Collection__c];
//        System.assert(dataCollectionAfterUpdate.TB_Source_Object_Id__c == contact2.Id);
//        System.assert(dataCollectionAfterUpdate.TB_Value_Text__c == contact2.FirstName);
    }
}