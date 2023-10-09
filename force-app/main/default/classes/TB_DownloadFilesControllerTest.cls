@IsTest
private class TB_DownloadFilesControllerTest {
    final static String CONTACT_LAST_NAME = 'TB_DFCT_LAST_NAME_';
    final static String CON_DID_EMAIL = 'TB_FRCT_CON_DID_puser000@amamama.com';
    final static String CON_SCIE_EMAIL = 'TB_FRCT_CON_SCIE_puser000@amamama.com';
    final static String DATA_COLLECTION_TAG_FIRST_NAME = 'FirstName';
    final static String DATA_COLLECTION_TAG_LAST_NAME = 'FirstName';
    final static String EVALUATION_NAME = 'Ewaluacja';
    final static String OBJECT_EVALUATED = 'Evaluated';
    final static String STAGE_STATUS_NEW = 'New';
    final static String USER_EMAIL = 'TB_FRCT_puser000@amamama.com';

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
    static void shouldReturnOneCollection_whenAdminHas3EE() {
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
        evaluation.TB_Administrator__c = emailToContactID.get(USER_EMAIL.toLowerCase());
        evaluation.TB_Employee_Evaluation_Process__c = employeeEvaluationProcess.Id;
        evaluation.TB_Supervisor__c = emailToContactID.get(USER_EMAIL.toLowerCase());
        evaluation.TB_Evaluation_Stage_Type__c = TB_Constants.EE_EVALUATION_STAGE_TYPE_FINAL_ASSESSMENT;
        TB_Employee_Evaluation__c evaluation2
                = TB_TestDataFactory.prepareEmployeeEvaluation(emailToContactID.get(CON_SCIE_EMAIL.toLowerCase()), emailToContactID.get(CON_DID_EMAIL.toLowerCase()), TB_Constants.EE_PROCESS_TYPE_SCIENTIST);
        evaluation2.TB_Administrator__c = emailToContactID.get(USER_EMAIL.toLowerCase());
        evaluation2.TB_Employee_Evaluation_Process__c = employeeEvaluationProcess.Id;
        evaluation2.TB_Supervisor__c = emailToContactID.get(USER_EMAIL.toLowerCase());
        evaluation2.TB_Evaluation_Stage_Type__c = TB_Constants.EE_EVALUATION_STAGE_TYPE_SUPERVISOR_DECISION;
        TB_Employee_Evaluation__c evaluation3
                = TB_TestDataFactory.prepareEmployeeEvaluation(emailToContactID.get(CON_SCIE_EMAIL.toLowerCase()), emailToContactID.get(CON_DID_EMAIL.toLowerCase()), TB_Constants.EE_PROCESS_TYPE_SCIENTIST);
        evaluation3.TB_Administrator__c = emailToContactID.get(USER_EMAIL.toLowerCase());
        evaluation3.TB_Employee_Evaluation_Process__c = employeeEvaluationProcess.Id;
        evaluation3.TB_Supervisor__c = emailToContactID.get(USER_EMAIL.toLowerCase());
        evaluation3.TB_Evaluation_Stage_Type__c = TB_Constants.EE_EVALUATION_STAGE_TYPE_SUPERVISOR_DECISION;
        insert new List<TB_Employee_Evaluation__c>{
                evaluation, evaluation2
        };
        evaluation3.TB_Employee_Evaluation__c = evaluation.Id;
        insert evaluation3;

        //when
        List<TB_DownloadFilesController.EvaluationWrapper> result = new List<TB_DownloadFilesController.EvaluationWrapper>();
        System.runAs(user) {
            result = TB_DownloadFilesController.chainEERecords();
        }
        System.assertEquals(3, result.size(), 'Should return size of return value');
    }

    @IsTest
    static void shouldReturnContentDocumentId_whenAdminHasDataCollections() {
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
        evaluation.TB_Administrator__c = emailToContactID.get(USER_EMAIL.toLowerCase());
        evaluation.TB_Employee_Evaluation_Process__c = employeeEvaluationProcess.Id;
        evaluation.TB_Supervisor__c = emailToContactID.get(USER_EMAIL.toLowerCase());
        evaluation.TB_Evaluation_Stage_Type__c = TB_Constants.EE_EVALUATION_STAGE_TYPE_FINAL_ASSESSMENT;
        TB_Employee_Evaluation__c evaluation2
                = TB_TestDataFactory.prepareEmployeeEvaluation(emailToContactID.get(CON_SCIE_EMAIL.toLowerCase()), emailToContactID.get(CON_DID_EMAIL.toLowerCase()), TB_Constants.EE_PROCESS_TYPE_SCIENTIST);
        evaluation2.TB_Administrator__c = emailToContactID.get(USER_EMAIL.toLowerCase());
        evaluation2.TB_Employee_Evaluation_Process__c = employeeEvaluationProcess.Id;
        evaluation2.TB_Supervisor__c = emailToContactID.get(USER_EMAIL.toLowerCase());
        evaluation2.TB_Evaluation_Stage_Type__c = TB_Constants.EE_EVALUATION_STAGE_TYPE_SUPERVISOR_DECISION;

        TB_Employee_Evaluation__c evaluation3
                = TB_TestDataFactory.prepareEmployeeEvaluation(emailToContactID.get(CON_SCIE_EMAIL.toLowerCase()), emailToContactID.get(CON_DID_EMAIL.toLowerCase()), TB_Constants.EE_PROCESS_TYPE_SCIENTIST);
        evaluation3.TB_Administrator__c = emailToContactID.get(USER_EMAIL.toLowerCase());
        evaluation3.TB_Employee_Evaluation_Process__c = employeeEvaluationProcess.Id;
        evaluation3.TB_Supervisor__c = emailToContactID.get(USER_EMAIL.toLowerCase());
        evaluation3.TB_Evaluation_Stage_Type__c = TB_Constants.EE_EVALUATION_STAGE_TYPE_SUPERVISOR_DECISION;
        insert new List<TB_Employee_Evaluation__c>{
                evaluation, evaluation2
        };
        evaluation3.TB_Employee_Evaluation__c = evaluation.Id;
        insert evaluation3;
        TB_Employee_Evaluation_Process_Stage__c processStage = TB_TestDataFactory.prepareEmployeeEvaluationProcessStage(TB_Constants.EEPS_TYPE_ACADEMIC_ACTIVITY_REPORT);
        insert processStage;
        TB_Employee_Evaluation_Stage__c employeeEvaluationStageScientist = TB_TestDataFactory.prepareEmployeeEvaluationStage
                (
                        processStage.Id, evaluation.Id, STAGE_STATUS_NEW,
                        TB_Constants.EEPS_TYPE_ACADEMIC_ACTIVITY_REPORT, Date.today().addDays(10)
                );
        TB_Employee_Evaluation_Stage__c employeeEvaluationStage2 = TB_TestDataFactory.prepareEmployeeEvaluationStage
                (
                        processStage.Id, evaluation.Id, STAGE_STATUS_NEW,
                        TB_Constants.EEPS_TYPE_EVALUATION_OF_ACADEMIC_ACTIVITY, Date.today().addDays(10)
                );
        insert new List<TB_Employee_Evaluation_Stage__c>{
                employeeEvaluationStageScientist, employeeEvaluationStage2
        };
        TB_Data_Collection__c data1 = TB_TestDataFactory.prepareDataCollection(employeeEvaluationStageScientist.Id, OBJECT_EVALUATED, DATA_COLLECTION_TAG_FIRST_NAME);
        TB_Data_Collection__c data2 = TB_TestDataFactory.prepareDataCollection(employeeEvaluationStageScientist.Id, OBJECT_EVALUATED, DATA_COLLECTION_TAG_LAST_NAME);
        TB_Data_Collection__c data3 = TB_TestDataFactory.prepareDataCollection(employeeEvaluationStage2.Id, OBJECT_EVALUATED, DATA_COLLECTION_TAG_LAST_NAME);
        data1.TB_Employee_Evaluation__c = evaluation.Id;
        data2.TB_Employee_Evaluation__c = evaluation.Id;
        data3.TB_Employee_Evaluation__c = evaluation.Id;
        insert new List<TB_Data_Collection__c>{
                data1, data2, data3
        };
        data2.TB_Value_Text__c = null;
        update data2;
        //when
        String resultValue;
        Id expectedResultValue;
        System.runAs(user) {
            resultValue = TB_DownloadFilesController.prepareZip(TB_Constants.LANGUAGE_PL, evaluation.Id);

            //then
            expectedResultValue = [
                    SELECT Id, Title, ContentDocumentId
                    FROM ContentVersion
                    LIMIT 1
            ]?.ContentDocumentId;
        }
        System.assertEquals(expectedResultValue, resultValue, 'Should return correct ContentDocumentId');
    }

    /*
    @IsTest
    static void shouldOccurredException_whenContactIsNotExistsInPrepareZip() {
        //given
        Boolean exceptionOccurred = false;
        User testUser = TB_TestDataFactory.prepareUser();
        insert testUser;

        //when
        System.runAs(testUser) {
            try {
                TB_DownloadFilesController.prepareZip(null, null);
            } catch (Exception e) {
                exceptionOccurred = true;
            }
        }

        //then
        System.assert(exceptionOccurred, 'Should occurred error');
    }

    @IsTest
    static void shouldOccurredException_whenContactIsNotExistsInChainEERecord() {
        //given
        Boolean exceptionOccurred = false;
        User testUser = TB_TestDataFactory.prepareUser();
        insert testUser;
        //when
        System.runAs(testUser) {
            try {
                TB_DownloadFilesController.chainEERecords();
            } catch (Exception e) {
                exceptionOccurred = true;
            }
        }

        //then
        System.assert(exceptionOccurred, 'Should occurred Error');
    }
    
     */
}