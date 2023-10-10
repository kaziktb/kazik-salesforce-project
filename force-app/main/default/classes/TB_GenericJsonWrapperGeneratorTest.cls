@IsTest
private with sharing class TB_GenericJsonWrapperGeneratorTest {
  @TestSetup
  private static void testSetup() {
    TB_TestDataFactory.createAdmissionProcess(true);
  }

  @IsTest
  private static void testInsertJsonWrapper() {
    Test.startTest();
    TB_Offered_Product__c offeredProduct = TB_TestDataFactory.createOfferedProduct(
      true
    );
    Test.stopTest();
    List<TB_JSON_Wrapper__c> jsonWrappers = [
      SELECT Id, TB_Wrapper_Value__c
      FROM TB_JSON_Wrapper__c
      WHERE TB_Object_Id__c = :offeredProduct.Id
    ];
    System.assertEquals(1, jsonWrappers.size());
    System.assert(
      jsonWrappers[0].TB_Wrapper_Value__c.contains(offeredProduct.Id)
    );
  }

  @IsTest
  private static void testUpdateJsonWrapper() {
    TB_Offered_Product__c offeredProduct = TB_TestDataFactory.createOfferedProduct(
      true
    );
    List<TB_JSON_Wrapper__c> oldJsonWrappers = [
      SELECT Id, TB_Wrapper_Value__c
      FROM TB_JSON_Wrapper__c
      WHERE TB_Object_Id__c = :offeredProduct.Id
    ];
    System.assertEquals(1, oldJsonWrappers.size());

    Test.startTest();
    offeredProduct.TB_Description_PL__c = 'test';
    update offeredProduct;
    Test.stopTest();

    List<TB_JSON_Wrapper__c> newJsonWrappers = [
      SELECT Id, TB_Wrapper_Value__c
      FROM TB_JSON_Wrapper__c
      WHERE TB_Object_Id__c = :offeredProduct.Id
    ];
    System.assertEquals(1, newJsonWrappers.size());
    System.assertEquals(oldJsonWrappers[0].Id, newJsonWrappers[0].Id);

    TB_Offered_Product__c offeredProductFromJson = (TB_Offered_Product__c) JSON.deserialize(
      newJsonWrappers[0].TB_Wrapper_Value__c,
      TB_Offered_Product__c.class
    );
    System.assertEquals('test', offeredProductFromJson.TB_Description_PL__c);
  }

  @IsTest
  private static void testInsertJsonWrapperWithParent() {
    TB_Admissions_Process__c admissionsStep = TB_TestDataFactory.createAdmissionStep(
      true,
      null
    );
    TB_Admissions_Content__c admissionsContent = TB_TestDataFactory.createAdmissionsContent(
      true
    );

    TB_JSON_Wrapper__c stepJsonWrapper = [
      SELECT Id
      FROM TB_JSON_Wrapper__c
      WHERE TB_Object_Id__c = :admissionsStep.Id
    ];

    Test.startTest();
    TB_Admissions_Step_Dynamic_Content__c admissionsStepDynamicContent = TB_TestDataFactory.createAdmissionsStepDynamicContent(
      false,
      admissionsStep.Id,
      admissionsContent.Id
    );
    insert admissionsStepDynamicContent;
    Test.stopTest();

    TB_JSON_Wrapper__c dynamicContentJsonWrapper = [
      SELECT Id, TB_Parent_JSON_Wrapper__c
      FROM TB_JSON_Wrapper__c
      WHERE TB_Object_Id__c = :admissionsStepDynamicContent.Id
    ];
    System.assertEquals(
      stepJsonWrapper.Id,
      dynamicContentJsonWrapper.TB_Parent_JSON_Wrapper__c
    );
  }

  @IsTest
  private static void testInsertJsonWrapperWithParentWithRecordType() {
    TB_Admissions_Process__c admissionsProcess = [
      SELECT Id
      FROM TB_Admissions_Process__c
    ];
    TB_JSON_Wrapper__c processJsonWrapper = [
      SELECT Id
      FROM TB_JSON_Wrapper__c
      WHERE TB_Object_Id__c = :admissionsProcess.Id
    ];

    Test.startTest();
    TB_Admissions_Process__c admissionsStage = TB_TestDataFactory.createAdmissionStage(
      false,
      admissionsProcess.Id
    );
    insert admissionsStage;
    Test.stopTest();

    TB_JSON_Wrapper__c stageJsonWrapper = [
      SELECT Id, TB_Parent_JSON_Wrapper__c
      FROM TB_JSON_Wrapper__c
      WHERE TB_Object_Id__c = :admissionsStage.Id
    ];
    System.assertEquals(
      processJsonWrapper.Id,
      stageJsonWrapper.TB_Parent_JSON_Wrapper__c
    );
  }

  @IsTest
  private static void testUpdateJsonWrapperReparenting() {
    TB_Admissions_Process__c admissionsProcess1 = [
      SELECT Id
      FROM TB_Admissions_Process__c
    ];
    TB_JSON_Wrapper__c process1JsonWrapper = [
      SELECT Id
      FROM TB_JSON_Wrapper__c
      WHERE TB_Object_Id__c = :admissionsProcess1.Id
    ];

    TB_Admissions_Process__c admissionsStage = TB_TestDataFactory.createAdmissionStage(
      true,
      admissionsProcess1.Id
    );
    TB_JSON_Wrapper__c stageJsonWrapperBefore = [
      SELECT Id, TB_Parent_JSON_Wrapper__c
      FROM TB_JSON_Wrapper__c
      WHERE TB_Object_Id__c = :admissionsStage.Id
    ];
    System.assertEquals(
      process1JsonWrapper.Id,
      stageJsonWrapperBefore.TB_Parent_JSON_Wrapper__c
    );

    Test.startTest();
    TB_Admissions_Process__c admissionsProcess2 = TB_TestDataFactory.createAdmissionProcess(
      false
    );
    insert admissionsProcess2;

    admissionsStage.TB_Admissions_Process__c = admissionsProcess2.Id;
    update admissionsStage;
    Test.stopTest();

    TB_JSON_Wrapper__c stageJsonWrapperAfter = [
      SELECT Id, TB_Parent_JSON_Wrapper__c
      FROM TB_JSON_Wrapper__c
      WHERE TB_Object_Id__c = :admissionsStage.Id
    ];
    System.assertEquals(stageJsonWrapperBefore.Id, stageJsonWrapperAfter.Id);

    TB_JSON_Wrapper__c process2JsonWrapper = [
      SELECT Id
      FROM TB_JSON_Wrapper__c
      WHERE TB_Object_Id__c = :admissionsProcess2.Id
    ];
    System.assertEquals(
      process2JsonWrapper.Id,
      stageJsonWrapperAfter.TB_Parent_JSON_Wrapper__c
    );
  }

  @IsTest
  private static void testDeleteJsonWrapper() {
    TB_Admissions_Process__c admissionsProcess = [
      SELECT Id
      FROM TB_Admissions_Process__c
    ];
    List<TB_JSON_Wrapper__c> jsonWrappersBefore = [
      SELECT Id, TB_Wrapper_Value__c
      FROM TB_JSON_Wrapper__c
      WHERE TB_Object_Id__c = :admissionsProcess.Id
    ];
    System.assertEquals(1, jsonWrappersBefore.size());

    Test.startTest();
    delete admissionsProcess;
    Test.stopTest();
    List<TB_JSON_Wrapper__c> jsonWrappersAfter = [
      SELECT Id, TB_Wrapper_Value__c
      FROM TB_JSON_Wrapper__c
      WHERE TB_Object_Id__c = :admissionsProcess.Id
    ];
    System.assert(jsonWrappersAfter.isEmpty());
  }

  @IsTest
  private static void coverSimilarScenariosForOtherObjects() {
    TB_Admissions_Process__c admissionsStep = TB_TestDataFactory.createAdmissionStep(
      true,
      null
    );

    Test.startTest();
    TB_Admissions_Dictionary__c admissionsDictionary = TB_TestDataFactory.createAdmissionDictionary(
      true
    );
    TB_Admissions_Content__c admissionsContent = TB_TestDataFactory.createAdmissionsContent(
      true
    );
    TB_Admissions_Data_Definition__c admissionsDataDefinition = TB_TestDataFactory.createAdmissionsDataDefinition(
      true
    );
    TB_Admissions_Logic__c admissionsLogic = TB_TestDataFactory.createAdmissionsLogic(
      true
    );
    TB_Admissions_Step_Data__c admissionsStepData = TB_TestDataFactory.createAdmissionsStepData(
      true,
      admissionsStep.Id,
      admissionsDataDefinition.Id
    );
    TB_Admissions_Step_Dynamic_Content__c admissionsStepDynamicContent = TB_TestDataFactory.createAdmissionsStepDynamicContent(
      true,
      admissionsStep.Id,
      admissionsContent.Id
    );
    TB_Admissions_Survey__c admissionsSurvey = TB_TestDataFactory.createAdmissionsSurvey(
      true
    );
    TB_Admissions_Survey_Answer__c admissionsSurveyAnswer = TB_TestDataFactory.createAdmissionsSurveyAnswer(
      true
    );
    TB_Portal__c portal = TB_TestDataFactory.createPortal(
        true
    );
    List<Account> accounts = TB_TestDataFactory.createAccounts(1, TB_Constants.STUDENTS_ORGANIZATION_REC_TYPE_ID, true);
    Contract contract = TB_TestDataFactory.createContract(
        true,
        accounts[0].Id
    );
    DT_Contract_Product__c contractProduct = TB_TestDataFactory.createContractProduct(
        true,
        contract.Id
    );
    TB_Offered_Product__c offeredProduct = TB_TestDataFactory.createOfferedProduct(
      true
    );
    TB_Qualification_Requirement__c qualificationRequirement = TB_TestDataFactory.createQualificationRequirement(
      true
    );
    TB_Related_Offered_Product__c relatedOfferedProduct = TB_TestDataFactory.createRelatedOfferedProduct(
      true
    );

    List<SObject> sObjects = new List<SObject>{
      admissionsStepData,
      admissionsStepDynamicContent,
      admissionsDictionary,
      admissionsContent,
      admissionsDataDefinition,
      admissionsLogic,
      admissionsSurvey,
      admissionsSurveyAnswer,
      offeredProduct,
      qualificationRequirement
    };

    List<SObject> additionalSObjects = new List<SObject>{
      relatedOfferedProduct,
      portal,
      contractProduct,
      contract
    };

    update sObjects;
    update additionalSObjects;
    delete sObjects;
    delete additionalSObjects;
    Test.stopTest();
  }
}