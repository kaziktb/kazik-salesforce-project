@IsTest
private class TB_pdo_AdmissionsSurveyControllerTest {
    @TestSetup
    static void testSetup(){
        TB_PDO_Automation_Disable__c setting = new TB_PDO_Automation_Disable__c(
                TB_Disable__c = true
        );
        insert setting;

        Id rtId = Schema.SObjectType.TB_PDO__c.getRecordTypeInfosByDeveloperName().get('TB_Book').getRecordTypeId();
        TB_PDO__c pdo = new TB_PDO__c(RecordTypeId = rtId);
        insert pdo;

        TB_PDO_Popularisation__c popularisation = new TB_PDO_Popularisation__c();
        popularisation.Name = 'Test Popularisation';
        popularisation.TB_PDO__c = pdo.Id;

        insert popularisation;


        TB_Admissions_Survey__c survey = new TB_Admissions_Survey__c();
        survey.Name = 'Test Survey';
        survey.TB_Achievement_Type__c = 'TB_Article';
        survey.RecordTypeId = Schema.SObjectType.TB_Admissions_Survey__c.getRecordTypeInfosByDeveloperName().get('TB_Survey').getRecordTypeId();
        survey.TB_Active__c = true;
        insert survey;

        TB_Admissions_Survey__c question1 = new TB_Admissions_Survey__c();
        question1.Name = 'Question 1';
        question1.RecordTypeId = Schema.SObjectType.TB_Admissions_Survey__c.getRecordTypeInfosByDeveloperName().get('TB_Question').getRecordTypeId();
        question1.TB_Survey__c = survey.Id;
        question1.TB_Active__c = true;
        insert question1;

        TB_Admissions_Survey__c question2 = new TB_Admissions_Survey__c();
        question2.Name = 'Question 2';
        question2.RecordTypeId = Schema.SObjectType.TB_Admissions_Survey__c.getRecordTypeInfosByDeveloperName().get('TB_Question').getRecordTypeId();
        question2.TB_Survey__c = survey.Id;
        question2.TB_Active__c = true;
        insert question2;
        System.debug('KAKWA: pop: ' + popularisation);

        TB_Admissions_Survey__c questionVal1 = new TB_Admissions_Survey__c();
        questionVal1.RecordTypeId = Schema.SObjectType.TB_Admissions_Survey__c.getRecordTypeInfosByDeveloperName().get('TB_Question_Value').getRecordTypeId();
        questionVal1.Name = 'Question Val1';
        questionVal1.TB_Active__c = true;
        questionVal1.TB_Question__c = question1.Id;
        insert questionVal1;

        TB_Admissions_Survey__c questionVal2 = new TB_Admissions_Survey__c();
        questionVal2.RecordTypeId = Schema.SObjectType.TB_Admissions_Survey__c.getRecordTypeInfosByDeveloperName().get('TB_Question_Value').getRecordTypeId();
        questionVal2.Name = 'Question Val2';
        questionVal2.TB_Active__c = true;
        questionVal2.TB_Question__c = question2.Id;
        insert questionVal2;

        List<TB_Admissions_Survey_Answer__c> previousAnswers = new List<TB_Admissions_Survey_Answer__c>();
        for(Integer i = 0; i<4; i++){
            previousAnswers.add(new TB_Admissions_Survey_Answer__c(
                    Name='prevAns'+i,
                    TB_PDO_Popularisation__c = popularisation.Id,
                    TB_Answer_Content__c = 'prevAns'+i,
                    TB_Survey__c=survey.Id));
        }
        insert previousAnswers;
    }
    @isTest
    static void testGetSurveyWrapper() {
        TB_PDO_Popularisation__c popularisation = [SELECT Id FROM TB_PDO_Popularisation__c LIMIT 1];
        TB_Admissions_Survey__c survey = [SELECT Id FROM TB_Admissions_Survey__c WHERE TB_Achievement_Type__c = 'TB_Article'];

        Test.startTest();
        TB_pdo_AdmissionsSurveyController.SurveyWrapper wrapper = TB_pdo_AdmissionsSurveyController.getSurveyWrapper(popularisation.Id);
        Test.stopTest();

        System.assertEquals(survey.Id, wrapper.surveyInfo.Id);
        System.assertEquals(2, wrapper.questions.size());
    }
    @IsTest
    static void testAddAnswersForPopularisation(){
        List<TB_Admissions_Survey_Answer__c> answersBeforeInsert = [SELECT Id FROM TB_Admissions_Survey_Answer__c WHERE Name LIKE '%Test ans%'];
        TB_PDO_Popularisation__c popularisation = [SELECT Id FROM TB_PDO_Popularisation__c LIMIT 1];

        List<TB_Admissions_Survey_Answer__c> answers = new List<TB_Admissions_Survey_Answer__c>();
        for(Integer i = 0; i<2; i++){
            answers.add(new TB_Admissions_Survey_Answer__c(
                    Name='Test ans'+i,
                    TB_PDO_Popularisation__c = popularisation.Id,
                    TB_Answer_Content__c = 'Ans Content'+i));
        }

        Test.startTest();
        TB_pdo_AdmissionsSurveyController.addAnswersForPopularisation(JSON.serialize(answers));
        Test.stopTest();

        List<TB_Admissions_Survey_Answer__c> answersAfterInsert = [SELECT Id, Name FROM TB_Admissions_Survey_Answer__c WHERE Name LIKE '%Test ans%'];

        System.assertEquals(0, answersBeforeInsert.size());
        System.assertEquals(2, answersAfterInsert.size());
        System.assertEquals('Test ans0', answersAfterInsert[0].Name);
    }

    @IsTest
    static void testGetPreviousAnswersMethod(){
        TB_PDO_Popularisation__c popularisation = [SELECT Id FROM TB_PDO_Popularisation__c LIMIT 1];
        TB_Admissions_Survey__c survey = [SELECT Id FROM TB_Admissions_Survey__c LIMIT 1];

        Test.startTest();
        List<TB_Admissions_Survey_Answer__c> previousAnswersResult = TB_pdo_AdmissionsSurveyController.getPreviousAnswers(survey.Id, popularisation.Id);
        Test.stopTest();

        System.assertEquals(4, previousAnswersResult.size());
    }
}