/**
 * Created by jowitakozlak on 08/12/2021.
 */

@IsTest
private class TB_AdmissionsFormsControllerTest {
    static final String APP_LAST_NAME = 'Test';

    @TestSetup
    static void testSetup() {
        hed__Application__c application = TB_TestDataFactory.createApplicationWithRelatedObjectsAndNestedLookup(false);
        Contact applicant = new Contact(
            LastName = APP_LAST_NAME
        );
        insert applicant;
        application.hed__Applicant__c = applicant.Id;
        insert application;
        
        TB_Admissions_Logic__c admissionsLogic = TB_DataFactory.createAdmissionsLogic(false);
        admissionsLogic.TB_Admissions_Process__c = application.TB_Admissions_Process__c;
        admissionsLogic.RecordTypeId = Schema.SObjectType.TB_Admissions_Logic__c.getRecordTypeInfosByDeveloperName().get('TB_Redirect_Logic').getRecordTypeId();
        admissionsLogic.TB_Redirect_Logic__c = 'Application.hed__Application_Status__c != \'Initially_Selected\'';
        admissionsLogic.TB_Active__c = true;
        insert admissionsLogic;

        TB_Admissions_Process__c admissionsStage = new TB_Admissions_Process__c(
            RecordTypeId = TB_SObjectUtils.getRecordTypeIdByDevName('TB_Admissions_Process__c', 'TB_Admissions_Stage'),
            Name = 'TestStage',
            TB_Display_Name_PL__c = 'Test',
            TB_Display_Name_EN__c = 'Test',
            TB_Active__c = true,
            TB_Admissions_Process__c = application.TB_Admissions_Process__c
        );
        insert admissionsStage;
        TB_Admissions_Process__c secondAdmissionsStage = new TB_Admissions_Process__c(
            RecordTypeId = TB_SObjectUtils.getRecordTypeIdByDevName('TB_Admissions_Process__c', 'TB_Admissions_Stage'),
            Name = 'TestStage2',
            TB_Display_Name_PL__c = 'Test2',
            TB_Display_Name_EN__c = 'Test2',
            TB_Active__c = true,
            TB_Admissions_Process__c = application.TB_Admissions_Process__c
        );
        insert secondAdmissionsStage;
        TB_Admissions_Process__c admissionsStep = new TB_Admissions_Process__c(
            RecordTypeId = TB_SObjectUtils.getRecordTypeIdByDevName('TB_Admissions_Process__c', 'TB_Admissions_Step'),
            Name = 'TestStep',
            TB_Display_Name_PL__c = 'Test',
            TB_Display_Name_EN__c = 'Test',
            TB_Active__c = true,
            TB_Admissions_Stage__c = admissionsStage.Id
        );
        insert admissionsStep;
        TB_Admissions_Process__c secondAdmissionsStep = new TB_Admissions_Process__c(
            RecordTypeId = TB_SObjectUtils.getRecordTypeIdByDevName('TB_Admissions_Process__c', 'TB_Admissions_Step'),
            Name = 'TestStep2',
            TB_Display_Name_PL__c = 'Test2',
            TB_Display_Name_EN__c = 'Test2',
            TB_Active__c = true,
            TB_Admissions_Stage__c = admissionsStage.Id
        );
        insert secondAdmissionsStep;
        TB_Admissions_Process__c thirdAdmissionsStep = new TB_Admissions_Process__c(
            RecordTypeId = TB_SObjectUtils.getRecordTypeIdByDevName('TB_Admissions_Process__c', 'TB_Admissions_Step'),
            Name = 'TestStep3',
            TB_Display_Name_PL__c = 'Test3',
            TB_Display_Name_EN__c = 'Test3',
            TB_Active__c = true,
            TB_Admissions_Stage__c = secondAdmissionsStage.Id
        );
        insert thirdAdmissionsStep;

        String recordTypeId = TB_SObjectUtils.getRecordTypeIdByDevName('TB_Application_Step_History__c','TB_Step_Status_History');
        TB_Application_Step_History__c stepHistory = new TB_Application_Step_History__c(
            TB_Admissions_Stage__c = admissionsStage.Id,
            TB_Admissions_Step__c = admissionsStep.Id,
            TB_Application__c = application.Id,
            TB_Status__c = 'To_Correct',
            TB_Comments__c = 'Popraw',
            RecordTypeId = recordTypeId
        );
        insert stepHistory;
        TB_Application_Step_History__c secondStepHistory = new TB_Application_Step_History__c(
            TB_Admissions_Stage__c = admissionsStage.Id,
            TB_Admissions_Step__c = secondAdmissionsStep.Id,
            TB_Application__c = application.Id,
            TB_Status__c = 'To_Verify',
            TB_Comments__c = 'Popraw',
            RecordTypeId = recordTypeId
        );
        insert secondStepHistory;

        insert new TB_Marketing_Cloud_API__c(
                SetupOwnerId = UserInfo.getOrganizationId(),
                TB_Auth_End_Point__c = 'https://test.com',
                TB_POST_End_Point__c = 'https://test.com',
                TB_Client_Id__c = '123',
                TB_Secret__c = '123',
                TB_Grant_Type__c = 'token'
        );
    }

    @IsTest
    static void getApplicationPositive() {

        hed__Application__c application = [
            SELECT Id
            FROM hed__Application__c
            WHERE hed__Applicant__r.LastName = :APP_LAST_NAME
        ];

        System.assertNotEquals(null, TB_AdmissionsFormsController.getApplication(application.Id));
        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void disableAdmissionsLogicNegative() {
        System.assertEquals(false,TB_AdmissionsFormsController.disableAdmissionsLogic());
    }

    @IsTest
    static void getRedirectLogicsPositive() {
        hed__Application__c application = [
            SELECT Id, TB_Admissions_Process_Id__c, TB_Admissions_Process__c, TB_Applying_To_Offered_Product__c, TB_Applying_To_Offered_Product__r.TB_Admissions_Process__c
            FROM hed__Application__c
            WHERE hed__Applicant__r.LastName = :APP_LAST_NAME
        ];
        application = TB_AdmissionsFormsController.getApplication(application.Id);

        System.assertNotEquals(null, TB_AdmissionsFormsController.getRedirectLogics(application));
        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void getAdmissionsStagesPositive() {

        hed__Application__c application = [
            SELECT Id, TB_Admissions_Process_Id__c, TB_Admissions_Process__c, TB_Applying_To_Offered_Product__c, TB_Applying_To_Offered_Product__r.TB_Admissions_Process__c
            FROM hed__Application__c
            WHERE hed__Applicant__r.LastName = :APP_LAST_NAME
        ];
        application = TB_AdmissionsFormsController.getApplication(application.Id);

        System.assertNotEquals(null, TB_AdmissionsFormsController.getAdmissionsStages(application));
        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void createStepHistoryPositiveInsert() {

        hed__Application__c application = [
            SELECT Id
            FROM hed__Application__c
            WHERE hed__Applicant__r.LastName = :APP_LAST_NAME
        ];
        TB_Admissions_Process__c stage = [
            SELECT Id
            FROM TB_Admissions_Process__c
            WHERE Name = 'TestStage2'
        ];
        TB_Admissions_Process__c step = [
            SELECT Id
            FROM TB_Admissions_Process__c
            WHERE Name = 'TestStep3'
        ];

        Test.startTest();
        TB_AdmissionsFormsController.createStepHistory(application.Id,stage.Id,step.Id,'Test','To_Verify','browserInfo');
        Test.stopTest();

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void createStepHistoryPositiveUpdate() {

        hed__Application__c application = [
            SELECT Id
            FROM hed__Application__c
            WHERE hed__Applicant__r.LastName = :APP_LAST_NAME
        ];
        TB_Admissions_Process__c stage = [
            SELECT Id
            FROM TB_Admissions_Process__c
            WHERE Name = 'TestStage'
        ];
        TB_Admissions_Process__c step = [
            SELECT Id
            FROM TB_Admissions_Process__c
            WHERE Name = 'TestStep'
        ];

        Test.startTest();
        TB_AdmissionsFormsController.createStepHistory(application.Id,stage.Id,step.Id,'Test','To_Verify','browserInfo');
        Test.stopTest();

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void blockFormAbsolutelyPositive() {

        hed__Application__c application = [
            SELECT Id, hed__Application_Status__c
            FROM hed__Application__c
            WHERE hed__Applicant__r.LastName = :APP_LAST_NAME
        ];
        application.hed__Application_Status__c = 'Cancelled';

        System.assertEquals(true, TB_AdmissionsFormsController.blockFormAbsolutely(application));
        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void blockFormAbsolutelyNegative() {

        hed__Application__c application = [
            SELECT Id, hed__Application_Status__c
            FROM hed__Application__c
            WHERE hed__Applicant__r.LastName = :APP_LAST_NAME
        ];
        application.hed__Application_Status__c = 'Data_Completion';

        System.assertEquals(false, TB_AdmissionsFormsController.blockFormAbsolutely(application));
        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void registerLastActionsOnApplicationUpdatePositive() {
        Test.setMock(HttpCalloutMock.class, new TB_MCClientQueueableBatchMock());
        hed__Application__c application = [
            SELECT Id, hed__Application_Status__c
            FROM hed__Application__c
            WHERE hed__Applicant__r.LastName = :APP_LAST_NAME
        ];
        application.hed__Applicant__c = [SELECT Id, ContactId, Contact.TB_Test__c FROM User WHERE Id = :UserInfo.getUserId()].contactId;
        TB_Admissions_Process__c step = [
            SELECT Id
            FROM TB_Admissions_Process__c
            WHERE Name = 'TestStep'
        ];

        System.assertEquals('200', TB_AdmissionsFormsController.registerLastActionsOnApplication(application,'update','Application.hed__Application_Status__c = \'Data_Completion\'',step.Id));
        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void registerLastActionsOnApplicationUpdateNegative() {
        hed__Application__c application = [
            SELECT Id, hed__Application_Status__c
            FROM hed__Application__c
            WHERE hed__Applicant__r.LastName = :APP_LAST_NAME
        ];
        TB_Admissions_Process__c step = [
            SELECT Id
            FROM TB_Admissions_Process__c
            WHERE Name = 'TestStep'
        ];

        System.assertEquals('500', TB_AdmissionsFormsController.registerLastActionsOnApplication(application,'update','Application.hed__Application_Status__c = \'Data_Completion\'',step.Id));
    }

    @IsTest
    static void registerLastActionsOnApplicationVisitPositive() {
        hed__Application__c application = [
            SELECT Id, hed__Application_Status__c
            FROM hed__Application__c
            WHERE hed__Applicant__r.LastName = :APP_LAST_NAME
        ];
        application.hed__Applicant__c = [SELECT Id, ContactId, Contact.TB_Test__c FROM User WHERE Id = :UserInfo.getUserId()].contactId;

        System.assertEquals('200', TB_AdmissionsFormsController.registerLastActionsOnApplication(application,'visit','',''));
        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void clearCommentPositive() {

        hed__Application__c application = [
            SELECT Id, hed__Application_Status__c
            FROM hed__Application__c
            WHERE hed__Applicant__r.LastName = :APP_LAST_NAME
        ];

        System.assertEquals('200', TB_AdmissionsFormsController.clearComment(application));
        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void shouldPassValidation_whenReqAndAppIsPLAndPointsConPassed() {

        //given
        TB_Offered_Product__c offeredProduct = TB_DataFactory.createOfferedProduct(true);
        TB_TestDataFactory.createQualificationRequirement(offeredProduct.Id, TB_SObjectUtils.getRecordTypeIdByDevName(TB_Qualification_Requirement__c.getSObjectType().getDescribe().name, TB_Constants.TB_QUA_REQ_MIN_REC_TYPE_NAME), TB_Constants.TB_QUA_REQ_EXAM_TYPE_POLISH_SINCE_2005, TB_Constants.TB_QUA_REQ_CITIZENSHIP_DEPENDENCY_POL, 30);
        hed__Application__c application = [
                SELECT
                        Id,
                        TB_No_HS_Exam__c,
                        TB_PD_Opt_In__c
                FROM hed__Application__c
                WHERE hed__Applicant__r.LastName = :APP_LAST_NAME
        ];
        application.TB_Applicant_Citizenship__c = TB_Constants.TB_APP_APPLICANT_CITIZENSHIP_POLAND;
        application.TB_HS_Exam_Score_Top_2__c = 50;
        application.TB_HS_Exam_Type__c = TB_Constants.TB_APP_EXAM_TYPE_POLISH_SINCE_2005;
        application.TB_Applying_To_Offered_Product__c = offeredProduct.Id;
        update application;

        //when
        Test.startTest();
        Boolean passed = TB_AdmissionsFormsController.validateExamResult(application);
        Test.stopTest();

        //then
        System.assertEquals(true, passed);
    }

    @IsTest
    static void shouldNotPassValidation_whenReqAndAppIsSpainAndPointsConNotPassed() {

        //given
        TB_Offered_Product__c offeredProduct = TB_DataFactory.createOfferedProduct(true);
        TB_TestDataFactory.createQualificationRequirement(offeredProduct.Id, TB_SObjectUtils.getRecordTypeIdByDevName(TB_Qualification_Requirement__c.getSObjectType().getDescribe().name, TB_Constants.TB_QUA_REQ_MIN_REC_TYPE_NAME), TB_Constants.TB_QUA_REQ_EXAM_TYPE_POLISH_SINCE_2005, TB_Constants.TB_QUA_REQ_CITIZENSHIP_DEPENDENCY_NON_POL, 80);
        hed__Application__c application = [
                SELECT
                        Id,
                        TB_No_HS_Exam__c,
                        TB_PD_Opt_In__c
                FROM hed__Application__c
                WHERE hed__Applicant__r.LastName = :APP_LAST_NAME
        ];
        application.TB_Applicant_Citizenship__c = 'Spain';
        application.TB_HS_Exam_Score_Top_2__c = 50;
        application.TB_HS_Exam_Type__c = TB_Constants.TB_APP_EXAM_TYPE_POLISH_SINCE_2005;
        application.TB_Applying_To_Offered_Product__c = offeredProduct.Id;
        update application;

        //when
        Test.startTest();
        Boolean passed = TB_AdmissionsFormsController.validateExamResult(application);
        Test.stopTest();

        //then
        System.assertEquals(false, passed);
    }

    @IsTest
    static void shouldPassValidation_whenReqWithOutExamTypeAndCitizenshipDep() {

        //given
        TB_Offered_Product__c offeredProduct = TB_DataFactory.createOfferedProduct(true);
        TB_TestDataFactory.createQualificationRequirement(offeredProduct.Id, TB_SObjectUtils.getRecordTypeIdByDevName(TB_Qualification_Requirement__c.getSObjectType().getDescribe().name, TB_Constants.TB_QUA_REQ_MIN_REC_TYPE_NAME), null, null, 80);
        hed__Application__c application = [
                SELECT
                        Id,
                        TB_No_HS_Exam__c,
                        TB_PD_Opt_In__c
                FROM hed__Application__c
                WHERE hed__Applicant__r.LastName = :APP_LAST_NAME
        ];
        application.TB_Applicant_Citizenship__c = 'Spain';
        application.TB_HS_Exam_Score_Top_2__c = 50;
        application.TB_HS_Exam_Type__c = TB_Constants.TB_APP_EXAM_TYPE_POLISH_SINCE_2005;
        application.TB_Applying_To_Offered_Product__c = offeredProduct.Id;
        update application;

        //when
        Test.startTest();
        Boolean passed = TB_AdmissionsFormsController.validateExamResult(application);
        Test.stopTest();

        //then
        System.assertEquals(false, passed);
    }

    @IsTest
    static void shouldPassValidation_whenReqAndAppNotMatchCitizenship() {

        //given
        TB_Offered_Product__c offeredProduct = TB_DataFactory.createOfferedProduct(true);
        TB_TestDataFactory.createQualificationRequirement(offeredProduct.Id, TB_SObjectUtils.getRecordTypeIdByDevName(TB_Qualification_Requirement__c.getSObjectType().getDescribe().name, TB_Constants.TB_QUA_REQ_MIN_REC_TYPE_NAME), TB_Constants.TB_APP_EXAM_TYPE_POLISH_SINCE_2005, TB_Constants.TB_QUA_REQ_CITIZENSHIP_DEPENDENCY_NON_POL, 80);
        hed__Application__c application = [
                SELECT
                        Id,
                        TB_No_HS_Exam__c,
                        TB_PD_Opt_In__c
                FROM hed__Application__c
                WHERE hed__Applicant__r.LastName = :APP_LAST_NAME
        ];
        application.TB_Applicant_Citizenship__c = TB_Constants.TB_APP_APPLICANT_CITIZENSHIP_POLAND;
        application.TB_HS_Exam_Score_Top_2__c = 60;
        application.TB_HS_Exam_Type__c = TB_Constants.TB_APP_EXAM_TYPE_POLISH_SINCE_2005;
        application.TB_Applying_To_Offered_Product__c = offeredProduct.Id;
        update application;

        //when
        Test.startTest();
        Boolean passed = TB_AdmissionsFormsController.validateExamResult(application);
        Test.stopTest();

        //then
        System.assertEquals(true, passed);
    }
}