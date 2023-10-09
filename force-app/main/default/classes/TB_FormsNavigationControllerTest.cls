/**
 * Created by Aneta on 19/08/2021.
 */

@IsTest
private class TB_FormsNavigationControllerTest {

    public static List<String> stageTypes = new List<String>{
        TB_Constants.EEPS_TYPE_ACADEMIC_ACTIVITY_REPORT,
        TB_Constants.EEPS_TYPE_EVALUATION_OF_ACADEMIC_ACTIVITY,
        TB_Constants.EEPS_TYPE_APPROVAL_OR_MODIFICATION,
        TB_Constants.EEPS_TYPE_FINAL_ASSESSMENT,
        TB_Constants.EEPS_TYPE_OBJECTION_FROM_ASSESSMENT,
        TB_Constants.EEPS_TYPE_SUPERVISOR_DECISION,
        TB_Constants.EEPS_TYPE_RECTOR_DECISION
    };

    static List<TB_Employee_Evaluation_Stage__c> actualStages;

    @TestSetup
    static void testSetup() {

        Contact contact = TB_TestDataFactory.prepareContact(false);
        contact.TB_User__c = UserInfo.getUserId();
        insert contact;
        TB_Employee_Evaluation__c evaluation = TB_TestDataFactory.prepareEmployeeEvaluation(contact.Id,'Didactic');
        insert evaluation;

        List<TB_Employee_Evaluation_Process_Stage__c> processStages = new List<TB_Employee_Evaluation_Process_Stage__c>();
        List<TB_Employee_Evaluation_Stage__c> evaluationStages = new List<TB_Employee_Evaluation_Stage__c>();

        for(String singleType : stageTypes) {
            TB_Employee_Evaluation_Process_Stage__c processStage = TB_TestDataFactory.prepareEmployeeEvaluationProcessStage(singleType);
            processStages.add(processStage);
        }
        insert processStages;

        Integer order = 1;
        for(String singleType : stageTypes) {
            Id processStageId = processStages.get(order-1).Id;
            TB_Employee_Evaluation_Stage__c stage = TB_TestDataFactory.prepareEmployeeEvaluationStage(processStageId,evaluation.Id,'New',singleType, null);
            stage.TB_Evaluation_Stage_Order__c = Decimal.valueOf(order);
            evaluationStages.add(stage);
            order++;
        }
        insert evaluationStages;
    }

    @IsTest
    static void getStagesForCompleted() {

        TB_Employee_Evaluation_Stage__c currentStage = [
            SELECT Id
            FROM TB_Employee_Evaluation_Stage__c
            LIMIT 1
        ];

        TB_Employee_Evaluation_Stage__c finalStage = [
            SELECT Id
            FROM TB_Employee_Evaluation_Stage__c
            WHERE TB_Employee_Stage_Type__c = 'Final Assessment'
        ];
        finalStage.TB_Evaluation_Stage_Status__c = 'Completed';
        update  finalStage;

        Test.startTest();
        actualStages = TB_FormsNavigationController.getStagesForNavigation(currentStage.Id);
        Test.stopTest();

        System.assertEquals(1,actualStages.size());
    }

    @IsTest
    static void getStagesForRector() {

        String currentStageId = prepareEvaluationStage('TB_Rector__c','Rector Decision');

        Test.startTest();
        actualStages = TB_FormsNavigationController.getStagesForNavigation(currentStageId);
        Test.stopTest();

        System.assertEquals(6,actualStages.size());
    }

    @IsTest
    static void getStagesForSupervisor() {

        String currentStageId = prepareEvaluationStage('TB_Supervisor__c','Approval or Modification');

        Test.startTest();
        actualStages = TB_FormsNavigationController.getStagesForNavigation(currentStageId);
        Test.stopTest();

        System.assertEquals(4,actualStages.size());
    }

    @IsTest
    static void getStagesForEvaluator() {

        String currentStageId = prepareEvaluationStage('TB_Evaluator__c','Academic Activity Report');
        TB_Employee_Evaluation_Stage__c currentStage = [
            SELECT TB_Employee_Evaluation__r.TB_Employee_Evaluation__r.Id
            FROM TB_Employee_Evaluation_Stage__c
            WHERE Id =: currentStageId
        ];


        TB_Employee_Evaluation__c evaluation = [
            SELECT Id, TB_Employee_Evaluation__c
            FROM TB_Employee_Evaluation__c
            LIMIT 1
        ];

        Contact contact = [SELECT Id FROM Contact WHERE TB_User__c =: UserInfo.getUserId()];
        TB_Employee_Evaluation__c connectedEvaluation = TB_TestDataFactory.prepareEmployeeEvaluation(contact.Id,'Didactic');
        insert connectedEvaluation;

        evaluation.TB_Employee_Evaluation__c = connectedEvaluation.Id;
        upsert evaluation;

        currentStage.TB_Employee_Evaluation__c = evaluation.Id;
        upsert currentStage;

        Test.startTest();
        actualStages = TB_FormsNavigationController.getStagesForNavigation(currentStageId);
        Test.stopTest();

        System.assertEquals(1,actualStages.size());
    }

    @IsTest
    static void getNavigationUrl() {
        Test.startTest();
        TB_FormsNavigationController.getNavigationUrl();
        Test.stopTest();
    }
    
    @IsTest
    static void getUrlForActivityStage() {

        String currentStageId = prepareEvaluationStage('TB_Evaluator__c','Academic Activity Report');

        Test.startTest();
        TB_FormsNavigationController.getUrlForActivityStage(currentStageId);
        Test.stopTest();
    }

    private static String prepareEvaluationStage(string contactRole, string stageType) {
        Contact contact = [
            SELECT Id
            FROM Contact
        ];

        TB_Employee_Evaluation_Stage__c currentStage = [
            SELECT Id
            FROM TB_Employee_Evaluation_Stage__c
            WHERE TB_Employee_Stage_Type__c =: stageType
        ];
        currentStage.put(contactRole,contact.Id);
        currentStage.TB_Evaluator__c = contact.Id;
        update currentStage;

        return currentStage.Id;
    }


}