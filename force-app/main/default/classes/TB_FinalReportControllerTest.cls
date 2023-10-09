@IsTest
private class TB_FinalReportControllerTest {
    final static String USER_EMAIL = 'TB_FRCT_puser000@amamama.com';
    final static String CON_DID_EMAIL = 'TB_FRCT_CON_DID_puser000@amamama.com';
    final static String CON_SCIE_EMAIL = 'TB_FRCT_CON_SCIE_puser000@amamama.com';
    final static String EVALUATION_NAME = 'Ewaluacja';
    final static String CONTACT_LAST_NAME = 'TB_FRCT_LAST_NAME_';

    @TestSetup
    static void testSetup() {
        User testUser = TB_TestDataFactory.prepareUser();
        testUser.Email = USER_EMAIL;
        insert testUser;
        Contact testContact = TB_TestDataFactory.prepareContact(false);
        testContact.TB_User__c = testUser.Id;
        testContact.Email = USER_EMAIL;
        insert testContact;
        Contact rector = TB_TestDataFactory.prepareContact(true);
        TB_TestDataFactory.createEmployeeEvaluationProcess(EVALUATION_NAME, String.valueOf(Date.today().year()), rector.Id, testContact.Id);
        Contact scientistAndDidactic = TB_TestDataFactory.prepareContact(false);
        scientistAndDidactic.TB_Employee_Group__c = TB_Constants.EE_PROCESS_TYPE_DIDACTIC;
        scientistAndDidactic.Email = CON_DID_EMAIL;
        scientistAndDidactic.LastName = CONTACT_LAST_NAME + Integer.valueOf(Math.random() * 10000);
        scientistAndDidactic.TB_Dean__c = rector.Id;

        Contact scientist = TB_TestDataFactory.prepareContact(false);
        scientist.TB_Employee_Group__c = TB_Constants.EE_PROCESS_TYPE_DIDACTIC;
        scientist.Email = CON_SCIE_EMAIL;
        scientist.LastName = CONTACT_LAST_NAME + Integer.valueOf(Math.random() * 10000);
        scientist.TB_Dean__c = rector.Id;
        insert new List<Contact>{
                scientistAndDidactic, scientist
        };
    }

    @IsTest
    static void shouldReturn3Records_whenUserHas3EEAndOneIsChild() {
        //given
        Map<String, Id> emailToContactID = new Map<String, Id>();
        user user = [SELECT ID, Email, LanguageLocaleKey, Username, Name From User WHERE Email = :USER_EMAIL];
        for (Contact con : [
                SELECT Id, Email
                From Contact
                WHERE Email IN:new List<String>{
                        CON_SCIE_EMAIL, CON_DID_EMAIL
                } OR TB_User__c = :user.Id
        ]) {
            emailToContactID.put(con.Email, con.Id);
        }
        TB_Employee_Evaluation_Process__c employeeEvaluationProcess = [SELECT ID From TB_Employee_Evaluation_Process__c WHERE Name = :EVALUATION_NAME];
        TB_Employee_Evaluation__c evaluation
                = TB_TestDataFactory.prepareEmployeeEvaluation(emailToContactID.get(CON_DID_EMAIL.toLowerCase()), emailToContactID.get(USER_EMAIL.toLowerCase()), TB_Constants.EE_PROCESS_TYPE_DIDACTIC);
        evaluation.TB_Employee_Evaluation_Process__c = employeeEvaluationProcess.Id;
        evaluation.TB_Supervisor__c = emailToContactID.get(USER_EMAIL.toLowerCase());
        evaluation.TB_Evaluation_Stage_Type__c = TB_Constants.EE_EVALUATION_STAGE_TYPE_FINAL_ASSESSMENT;
        TB_Employee_Evaluation__c evaluation2
                = TB_TestDataFactory.prepareEmployeeEvaluation(emailToContactID.get(CON_SCIE_EMAIL.toLowerCase()), emailToContactID.get(CON_DID_EMAIL.toLowerCase()), TB_Constants.EE_PROCESS_TYPE_SCIENTIST);
        evaluation2.TB_Employee_Evaluation_Process__c = employeeEvaluationProcess.Id;
        evaluation2.TB_Supervisor__c = emailToContactID.get(USER_EMAIL.toLowerCase());
        evaluation2.TB_Evaluation_Stage_Type__c = TB_Constants.EE_EVALUATION_STAGE_TYPE_SUPERVISOR_DECISION;

        TB_Employee_Evaluation__c evaluation4
                = TB_TestDataFactory.prepareEmployeeEvaluation(emailToContactID.get(CON_SCIE_EMAIL.toLowerCase()), emailToContactID.get(CON_DID_EMAIL.toLowerCase()), TB_Constants.EE_PROCESS_TYPE_SCIENTIST);
        evaluation4.TB_Employee_Evaluation_Process__c = employeeEvaluationProcess.Id;
        evaluation4.TB_Supervisor__c = emailToContactID.get(USER_EMAIL.toLowerCase());
        evaluation4.TB_Evaluation_Stage_Type__c = TB_Constants.EE_EVALUATION_STAGE_TYPE_RECTOR_DECISION;
        evaluation4.TB_Rector_Decision_Mark__c = TB_Constants.EE_EVALUATION_DECISION_MARK_PASSED_WITH_DIS;

        TB_Employee_Evaluation__c evaluation3
                = TB_TestDataFactory.prepareEmployeeEvaluation(emailToContactID.get(CON_SCIE_EMAIL.toLowerCase()), emailToContactID.get(CON_DID_EMAIL.toLowerCase()), TB_Constants.EE_PROCESS_TYPE_SCIENTIST);
        evaluation3.TB_Employee_Evaluation_Process__c = employeeEvaluationProcess.Id;
        evaluation3.TB_Supervisor__c = emailToContactID.get(USER_EMAIL.toLowerCase());
        evaluation3.TB_Evaluation_Stage_Type__c = TB_Constants.EE_EVALUATION_STAGE_TYPE_RECTOR_DECISION;
        evaluation3.TB_Rector_Decision_Mark__c = TB_Constants.EE_EVALUATION_DECISION_MARK_PASSED_WITH_DIS;
        insert new List<TB_Employee_Evaluation__c>{
                evaluation, evaluation2, evaluation4
        };
        evaluation3.TB_Employee_Evaluation__c = evaluation.Id;
        insert evaluation3;

        //when
        TB_FinalReportController.DataWrapper result;
        System.runAs(user) {
            result = TB_FinalReportController.getEE(null);
        }

        //then
        System.assertEquals(3, result.finalReportWrappers.size(), 'Wrong number of return Employee Evaluation');
        System.assertEquals(user.Name, result.userName, 'Wrong return UserName');
        System.assertEquals(user.LanguageLocaleKey, result.userLanguage, 'Wrong return User Language');
    }

    @IsTest
    static void shouldInsertEER_whenDownloadFile() {
        //given
        user user = [SELECT ID, Email, LanguageLocaleKey, Username, Name From User WHERE Email = :USER_EMAIL];

        //when
        System.runAs(user) {
            TB_FinalReportController.insertEERRecord();
        }

        //then
        TB_Employee_Evaluation_Report__c eer = [SELECT TB_Supervisor__c From TB_Employee_Evaluation_Report__c];
        Contact contact = [SELECT ID From Contact WHERE TB_User__c = :user.Id];
        System.assert(contact.Id == eer.TB_Supervisor__c, 'Incorrect ContactId');
    }

    @IsTest
    static void shouldReturnError_whenDownloadFile() {
        //given
        Boolean exceptionOccurred = false;
        User testUser = TB_TestDataFactory.prepareUser();
        insert testUser;

        //when
        System.runAs(testUser) {
            try {
                TB_FinalReportController.insertEERRecord();
            } catch (Exception e) {
                exceptionOccurred = true;
            }
        }

        //then
        System.assert(exceptionOccurred, 'Should occurred error');
    }

    @IsTest
    static void shouldReturnError_whenReturnWrappers() {
        //given
        Boolean exceptionOccurred = false;
        User testUser = TB_TestDataFactory.prepareUser();
        insert testUser;

        //when
        System.runAs(testUser) {
            try {
                TB_FinalReportController.getEE(null);
            } catch (Exception e) {
                System.debug(e.getMessage());
                exceptionOccurred = true;
            }
        }

        //then
        System.assert(exceptionOccurred, 'Should occurred error');
    }

    @IsTest
    static void shouldReturnOption_whenOneRecordExist() {
        //given
        Map<String, Id> emailToContactID = new Map<String, Id>();
        user user = [SELECT ID, Email, LanguageLocaleKey, Username, Name From User WHERE Email = :USER_EMAIL];
        for (Contact con : [
                SELECT Id, Email
                From Contact
                WHERE Email IN:new List<String>{
                        CON_SCIE_EMAIL, CON_DID_EMAIL
                } OR TB_User__c = :user.Id
        ]) {
            emailToContactID.put(con.Email, con.Id);
        }
        TB_TestDataFactory.prepareEmployeeEvaluationProcess('NAME', String.valueOf(Date.today().year()), emailToContactID.get(USER_EMAIL.toLowerCase()), emailToContactID.get(USER_EMAIL.toLowerCase()));

        //when
        List<TB_FinalReportController.Option> optionList = TB_FinalReportController.getEEPOptions();

        //then
        System.assertEquals(1, optionList.size(), 'Wrong number of return option EEP');
    }
}