@isTest
public without sharing class TB_AdmissionsSurveyControllerTest {
  @TestSetup
  public static void dataFactory() {
    Contact tempContact = new Contact();
    tempContact.LastName = 'TestContact';
    insert tempContact;
    String applicantId = tempContact.id;

    TB_Offered_Product__c offeredProduct = new TB_Offered_Product__c();
    offeredProduct.Name = 'TestProduct';
    insert offeredProduct;

    hed__Application__c application = new hed__Application__c();
    application.hed__Applicant__c = applicantId;
    application.TB_Applying_To_Offered_Product__c = offeredProduct.id;
    insert application;

    TB_Admissions_Survey__c testAdmissionsSurvey = new TB_Admissions_Survey__c();
    testAdmissionsSurvey.Name = 'TestSurvey';

    insert testAdmissionsSurvey;

    TB_Admissions_Process__c testAdmissionsProcess = new TB_Admissions_Process__c();
    testAdmissionsProcess.Name = 'TestProcess';
    testAdmissionsProcess.TB_Admissions_Survey__c = testAdmissionsSurvey.Id;

    insert testAdmissionsProcess;

    TB_Admissions_Survey__c testQuestion = new TB_Admissions_Survey__c();
    testQuestion.Name = 'TestQuestion';
    testQuestion.TB_Survey__c = testAdmissionsSurvey.Id;
    testQuestion.TB_Active__c = true;
    testQuestion.RecordTypeId = Schema.SObjectType.TB_Admissions_Survey__c.getRecordTypeInfosByName()
      .get(TB_Constants.TB_ADMISSIONS_SURVEY_QUESTION)
      .getRecordTypeId();

    insert testQuestion;

    TB_Admissions_Survey__c testQuestionValue = new TB_Admissions_Survey__c();
    testQuestionValue.Name = 'TestQuestionValue';
    testQuestionValue.TB_Question__c = testQuestion.Id;
    testQuestionValue.TB_Active__c = true;
    testQuestionValue.RecordTypeId = Schema.SObjectType.TB_Admissions_Survey__c.getRecordTypeInfosByName()
      .get(TB_Constants.TB_ADMISSIONS_SURVEY_QUESTION_VALUE)
      .getRecordTypeId();

    insert testQuestionValue;

    TB_Admissions_Survey_Answer__c testAnswer = new TB_Admissions_Survey_Answer__c();
    testAnswer.Name = 'TestAnswer';
    testAnswer.TB_Survey__c = testAdmissionsSurvey.Id;
    testAnswer.TB_Question__c = testQuestion.Id;
    testAnswer.TB_Application__c = application.Id;

    insert testAnswer;
  }

  @isTest
  public static void getSurveyDetailsTest() {
    test.startTest();
    TB_Admissions_Survey__c admissionsSurvey = TB_AdmissionsSurveyController.getSurveyDetails(
      [SELECT Id FROM TB_Admissions_Process__c]
      .Id
    );
    test.stopTest();
    System.assertNotEquals(null, admissionsSurvey.Id);
  }

  @isTest
  public static void getQuestionsTest() {
    test.startTest();
    String SurveyId = [
      SELECT Id
      FROM TB_Admissions_Survey__c
      WHERE Name = 'TestSurvey'
    ]
    .Id;
    List<TB_Admissions_Survey__c> questionList = TB_AdmissionsSurveyController.getQuestions(
      SurveyId
    );
    test.stopTest();
    System.assertEquals(1, questionList.size());
  }

  @isTest
  public static void getQuestionValues() {
    test.startTest();
    List<String> questionIds = new List<String>();
    questionIds.add(
      [SELECT Id FROM TB_Admissions_Survey__c WHERE Name = 'TestQuestion']
      .Id
    );
    List<TB_Admissions_Survey__c> questionValuesList = TB_AdmissionsSurveyController.getQuestionValues(
      questionIds
    );
    test.stopTest();
    System.assertEquals(1, questionValuesList.size());
  }

  @isTest
  public static void addAnswersTest() {
    test.startTest();
    String surveyId = [
      SELECT Id
      FROM TB_Admissions_Survey__c
      WHERE Name = 'TestSurvey'
    ]
    .Id;
    String applicationId = [SELECT Id FROM hed__Application__c].Id;
    List<String> encodedAnswers = new List<String>();
    TB_Admissions_Survey_Answer__c answer = new TB_Admissions_Survey_Answer__c();
    answer.Name = 'TestAnswer';
    answer.TB_Survey__c = surveyId;
    answer.TB_Application__c = applicationId;
    answer.TB_Question__c = [
      SELECT Id
      FROM TB_Admissions_Survey__c
      WHERE Name = 'TestQuestion'
    ]
    .Id;
    encodedAnswers.add(JSON.serialize(answer));
    TB_AdmissionsSurveyController.addAnswers(
      encodedAnswers,
      surveyId,
      applicationId
    );
    test.stopTest();
    List<TB_Admissions_Survey_Answer__c> answerList = [
      SELECT Id
      FROM TB_Admissions_Survey_Answer__c
    ];
    System.assertEquals(1, answerList.size());
  }

  @isTest
  public static void getPreviousAnswersTest() {
    test.startTest();
    String surveyId = [
      SELECT Id
      FROM TB_Admissions_Survey__c
      WHERE Name = 'TestSurvey'
    ]
    .Id;
    String applicationId = [SELECT Id FROM hed__Application__c].Id;
    List<TB_Admissions_Survey_Answer__c> previousAnswerList = TB_AdmissionsSurveyController.getPreviousAnswers(
      surveyId,
      applicationId
    );
    test.stopTest();
    System.assertEquals(1, previousAnswerList.size());
  }
}