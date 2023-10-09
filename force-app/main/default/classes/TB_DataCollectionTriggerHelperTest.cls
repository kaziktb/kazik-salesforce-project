@IsTest
public with sharing class TB_DataCollectionTriggerHelperTest {
    @TestSetup
    private static void testSetup() {
        Contact evaluated = TB_TestDataFactory.prepareContact(false);
        insert evaluated;

        TB_Employee_Evaluation__c employeeEvaluation = TB_TestDataFactory.prepareEmployeeEvaluation(
            evaluated.Id,
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
    }

    @IsTest
    private static void updateJsonFieldOnCreatingDataCollection() {
        TB_Employee_Evaluation_Stage__c evaluationStageBefore = [SELECT Id, TB_Data_Collections_Json__c FROM TB_Employee_Evaluation_Stage__c LIMIT 1];

        Test.startTest();
        TB_Data_Collection__c dataCollection = TB_TestDataFactory.prepareDataCollection(evaluationStageBefore.Id);
        insert dataCollection;
        Test.stopTest();

        List<TB_JSON_Wrapper__c> jsonWrappers = [SELECT Id, TB_Wrapper_Value__c FROM TB_JSON_Wrapper__c WHERE TB_Object_Id__c = :evaluationStageBefore.Id];
        System.assertEquals(1, jsonWrappers.size());

        List<TB_Data_Collection__c> dataCollectionsFromJson = (List<TB_Data_Collection__c>)System.JSON.deserialize(jsonWrappers[0].TB_Wrapper_Value__c, List<TB_Data_Collection__c>.class);
        System.assertEquals(1, dataCollectionsFromJson.size());
        System.assertEquals(dataCollectionsFromJson[0].Id, dataCollection.Id);
    }

    @IsTest
    private static void updateJsonFieldOnUpdatingDataCollection() {
        TB_Employee_Evaluation_Stage__c evaluationStageBefore = [SELECT Id, TB_Data_Collections_Json__c FROM TB_Employee_Evaluation_Stage__c LIMIT 1];
        TB_Data_Collection__c dataCollection = TB_TestDataFactory.prepareDataCollection(evaluationStageBefore.Id);
        insert dataCollection;

        Test.startTest();
        dataCollection.TB_Value_Text__c = 'TEST';
        update dataCollection;
        Test.stopTest();

        List<TB_JSON_Wrapper__c> jsonWrappers = [SELECT Id, TB_Wrapper_Value__c FROM TB_JSON_Wrapper__c WHERE TB_Object_Id__c = :evaluationStageBefore.Id];
        System.assertEquals(1, jsonWrappers.size());

        List<TB_Data_Collection__c> dataCollectionsFromJson = (List<TB_Data_Collection__c>)System.JSON.deserialize(jsonWrappers[0].TB_Wrapper_Value__c, List<TB_Data_Collection__c>.class);
        System.assertEquals(1, dataCollectionsFromJson.size());
        System.assertEquals(dataCollection.Id, dataCollectionsFromJson[0].Id);
        System.assertEquals('TEST', dataCollectionsFromJson[0].TB_Value_Text__c);
    }

    @IsTest
    private static void updateJsonFieldOnAddingNewDataCollection() {
        TB_Employee_Evaluation_Stage__c evaluationStageBefore = [SELECT Id, TB_Data_Collections_Json__c FROM TB_Employee_Evaluation_Stage__c LIMIT 1];
        TB_Data_Collection__c dataCollection1 = TB_TestDataFactory.prepareDataCollection(evaluationStageBefore.Id);
        insert dataCollection1;

        Test.startTest();
        TB_Data_Collection__c dataCollection2 = TB_TestDataFactory.prepareDataCollection(evaluationStageBefore.Id);
        dataCollection2.TB_Name_PL__c = 'Pytanie 2';
        insert dataCollection2;
        Test.stopTest();

        List<TB_JSON_Wrapper__c> jsonWrappers = [SELECT Id, TB_Wrapper_Value__c FROM TB_JSON_Wrapper__c WHERE TB_Object_Id__c = :evaluationStageBefore.Id];
        System.assertEquals(1, jsonWrappers.size());
        System.assert(jsonWrappers[0].TB_Wrapper_Value__c.contains('Pytanie 2'));

        List<TB_Data_Collection__c> dataCollectionsFromJson = (List<TB_Data_Collection__c>)System.JSON.deserialize(jsonWrappers[0].TB_Wrapper_Value__c, List<TB_Data_Collection__c>.class);
        System.assertEquals(2, dataCollectionsFromJson.size());
    }

    @IsTest
    private static void fetchSourceValuesTest() {
        TB_Employee_Evaluation_Stage__c evaluationStage = [SELECT Id, TB_Data_Collections_Json__c, TB_Employee_Evaluation__r.TB_Evaluated__r.FirstName FROM TB_Employee_Evaluation_Stage__c LIMIT 1];

        Test.startTest();
        TB_Data_Collection__c dataCollection = TB_TestDataFactory.prepareDataCollection(evaluationStage.Id, 'Evaluated', 'FirstName');
        insert dataCollection;
        Test.stopTest();

        TB_Data_Collection__c dataCollectionAfter = [SELECT Id, TB_Value_Text__c FROM TB_Data_Collection__c];
        System.assertEquals(evaluationStage.TB_Employee_Evaluation__r.TB_Evaluated__r.FirstName, dataCollectionAfter.TB_Value_Text__c);
    }

    @IsTest
    private static void setTargetValues() {
        Contact evaluated = [SELECT Id FROM Contact LIMIT 1];
        TB_Employee_Evaluation_Stage__c evaluationStage = [SELECT Id, TB_Data_Collections_Json__c, TB_Employee_Evaluation__r.TB_Evaluated__r.FirstName FROM TB_Employee_Evaluation_Stage__c LIMIT 1];
        TB_Data_Collection__c dataCollection = TB_TestDataFactory.prepareDataCollection(evaluationStage.Id, 'Evaluated', 'FirstName', 'Evaluated', 'FirstName');
        dataCollection.TB_Target_Object_Id__c = evaluated.Id;
        dataCollection.TB_Data_Type__c = 'Text';
        dataCollection.TB_Value_Text__c = 'Jan';
        insert dataCollection;

        TB_Data_Collection__c dataCollectionNumber = TB_TestDataFactory.prepareDataCollection(evaluationStage.Id, 'Evaluated', 'TB_Included_In_Evaluations__c', 'Evaluated', 'TB_Included_In_Evaluations__c');
        dataCollectionNumber.TB_Target_Object_Id__c = evaluated.Id;
        dataCollectionNumber.TB_Data_Type__c = 'Checkbox';
        dataCollectionNumber.TB_Value_Text__c = null;
        insert dataCollectionNumber;

        List<TB_Data_Collection__c> dataCollections = [
            SELECT Id, TB_Target_Object_Id__c, TB_Target_Object_Field__c, TB_Value_Long_Text__c,
                TB_Value_Text__c, TB_Target_Object_Field_Type__c, TB_Data_Type__c, TB_Target_Object__c
            FROM TB_Data_Collection__c
        ];

        Test.startTest();
        TB_DataCollectionTriggerHelper.setTargetValues(dataCollections, new Map<Id, TB_Data_Collection__c>(dataCollections));
        Test.stopTest();
    }
}