@IsTest
private class TB_MoodleExamControllerTest {

    @TestSetup
    static void testSetup() {
        Test.startTest();
        TB_TestDataFactory.createMoodleCustomSetting('test.pl', 'test', 'test', 'test.pl', '5');
        Contact contact = TB_TestDataFactory.createContact(false);
        contact.Email = TB_MoodleMock.TB_MOODLE_EMAIL;
        insert contact;
        Id offeredProductId = TB_TestDataFactory.createOfferedProduct(true).Id;
        Id admissionsProcessId = TB_TestDataFactory.createAdmissionProcess(true).Id;
        hed__Application__c application = TB_TestDataFactory.createApplication(admissionsProcessId, offeredProductId, false);
        application.TB_Product_Group__c = TB_Constants.TB_ADMISSIONS_CONTENT_PRODUCT_GROUP_HIGHER_EDUCATION;
        application.hed__Applicant__c = contact.Id;
        insert application;
        TB_Application_Qualification__c appQua = TB_TestDataFactory.createApplicationQualification(false, application.Id);
        appQua.TB_Moodle_Exam_ID__c = TB_MoodleMock.URL_COURSE;
        appQua.TB_Application__c = application.Id;
        insert appQua;
        application.TB_Qualification__c = appQua.Id;
        update application;
        Test.stopTest();
    }

    @IsTest
    static void shouldReturnAppQualRec_whenAppAndQualiExist() {
        //given
        Id applicationId = [SELECT Id From hed__Application__c]?.Id;

        //when
        Test.startTest();
        TB_Application_Qualification__c result = TB_MoodleExamController.getQualiObject(applicationId);
        Test.stopTest();

        //then
        System.assertEquals(TB_MoodleMock.URL_COURSE, result.TB_Moodle_Exam_ID__c, ' Incorrect url field on Application qualification');
    }

    @IsTest
    static void shouldReturnAuraHandledEx_whenAppAndQualiExist() {
        //given
        Id applicationId;
        Boolean threwError = false;
        //when
        Test.startTest();
        try {
            TB_MoodleExamController.getQualiObject(applicationId);
        } catch (Exception e) {
            if (e instanceof AuraHandledException) {
                threwError = true;
            }
        }
        Test.stopTest();

        //then
        System.assert(threwError, ' Aura Exception should threw');
    }

    @IsTest
    static void shouldReturnLoginLink_whenAppAndQualiExist() {
        //given
        Test.setMock(HttpCalloutMock.class, new TB_MoodleMock(TB_MoodleConstants.API_FUNCTION_LOG_USER));
        TB_Application_Qualification__c appQua = [
                SELECT
                        Id,
                        TB_Moodle_Id__c,
                        TB_Moodle_Exam_ID__c,
                        TB_Moodle_Username__c,
                        TB_Moodle_Exam_Started__c,
                        TB_Qualification_Available_To__c,
                        TB_Application__r.hed__Applicant__r.Email
                FROM TB_Application_Qualification__c
        ];
        appQua.TB_Moodle_Username__c = 'testadadsad';
        update appQua;
        //when
        Test.startTest();
        String result = TB_MoodleExamController.getOneClickLink(appQua.Id);
        Test.stopTest();

        //then
        System.assert(result.contains(TB_MoodleMock.ONE_CLICK_KEY_AUT), ' Incorrect url field on Application qualification');
    }

    @IsTest
    static void shouldReturnError_whenAppAndQualiExist() {
        //given
        Boolean threwError = false;
        Test.setMock(HttpCalloutMock.class, new TB_MoodleMock(TB_MoodleConstants.API_FUNCTION_LOGIN));
        TB_Application_Qualification__c appQua = [
                SELECT
                        Id,
                        TB_Moodle_Id__c,
                        TB_Moodle_Exam_ID__c,
                        TB_Moodle_Username__c,
                        TB_Moodle_Exam_Started__c,
                        TB_Qualification_Available_To__c,
                        TB_Application__r.hed__Applicant__r.Email
                FROM TB_Application_Qualification__c
        ];
        //when
        Test.startTest();
        try {
            TB_MoodleExamController.getOneClickLink(appQua.Id);
        } catch (Exception e) {
            if (e instanceof AuraHandledException) {
                threwError = true;
            }
        }
        Test.stopTest();

        //then
        System.assert(threwError, ' Aura Exception should threw');
    }

    @IsTest
    static void shouldReturnErrorFromMethod_whenAppAndQualiExist() {
        //given
        Boolean threwError = false;
        Test.setMock(HttpCalloutMock.class, new TB_MoodleMock(TB_MoodleConstants.API_FUNCTION_LOGIN));
        //when
        Test.startTest();
        try {
            TB_MoodleExamController.getOneClickLink(null);
        } catch (Exception e) {
            if (e instanceof AuraHandledException) {
                threwError = true;
            }
        }
        Test.stopTest();

        //then
        System.assert(threwError, ' Aura Exception should threw');
    }

    @IsTest
    static void shouldReturnExamResult_whenAppAndQualiExist() {
        //given
        Test.setMock(HttpCalloutMock.class, new TB_MoodleMock(TB_MoodleConstants.FUNC_COURSE_RESULT));
        TB_Application_Qualification__c appQua = [
                SELECT
                        Id,
                        TB_Moodle_Id__c,
                        TB_Moodle_Exam_ID__c,
                        TB_Moodle_Username__c,
                        TB_Moodle_Exam_Started__c,
                        TB_Qualification_Available_To__c,
                        TB_Application__r.hed__Applicant__r.Email
                FROM TB_Application_Qualification__c
        ];
        appQua.TB_Moodle_Id__c = TB_MoodleMock.TB_MOODLE_USER_ID;
        update appQua;
        //when
        Test.startTest();
        TB_Application_Qualification__c result = (TB_Application_Qualification__c)TB_MoodleExamController.checkExamResult(appQua.Id,  appQua.TB_Moodle_Id__c, appQua.TB_Moodle_Exam_ID__c);
        Test.stopTest();

        //then
        System.assertEquals(TB_MoodleMock.TB_MOODLE_RESULT_POINTS, result.TB_Moodle_Test_Result_Points__c);
        System.assertEquals(TB_MoodleMock.TB_MOODLE_RESULT_PERC, result.TB_Moodle_Test_Result_Percent__c);
    }

    @IsTest
    static void shouldReturnAuraError_whenAppAndQualiExist() {
        //given
        Boolean threwError = false;
        Test.setMock(HttpCalloutMock.class, new TB_MoodleMock(TB_MoodleConstants.FUNC_COURSE_RESULT));

        //when
        Test.startTest();
        try{
            TB_MoodleExamController.checkExamResult(null, null, null);
        }catch (Exception e) {
            if (e instanceof AuraHandledException) {
                threwError = true;
            }
        }
        Test.stopTest();

        //then
        System.assert(threwError, ' Aura Exception should threw');
    }

    @IsTest
    static void shouldReturnAuraError_whenResetButtonIsWithoutId() {
        //given
        Boolean threwError = false;
        //when
        Test.startTest();
        try{
            TB_MoodleExamController.resetExam(null);
        }catch (Exception e) {
            if (e instanceof AuraHandledException) {
                threwError = true;
            }
        }
        Test.stopTest();

        //then
        System.assert(threwError, ' Aura Exception should threw');
    }

    @IsTest
    static void shouldResetExam_whenAppAndQualiExist() {
        //given
        String points = '4.53';
        TB_Application_Qualification__c appQua = [
                SELECT
                        Id
                FROM TB_Application_Qualification__c
        ];
        appQua.TB_Moodle_Test_Result_Points__c = points;
        appQua.TB_Moodle_Id__c = '9999';
        update appQua;
        appQua = [
                SELECT
                        Id,
                        TB_Moodle_Test_Result_Points__c
                FROM TB_Application_Qualification__c
        ];
        System.assertEquals(points, appQua.TB_Moodle_Test_Result_Points__c);
        //when
        Test.startTest();
        TB_MoodleExamController.resetExam(appQua.Id);
        Test.stopTest();

        //then
        appQua = [
                SELECT
                        Id,
                        TB_Moodle_Test_Result_Points__c
                FROM TB_Application_Qualification__c
        ];
        System.assert(appQua.TB_Moodle_Test_Result_Points__c == null, 'Field result point should be empty');
    }

    @IsTest
    static void shouldReturnQuali_whenIsLinked(){
        //given
        TB_Application_Qualification__c applicationQualification = [SELECT ID FROM TB_Application_Qualification__c];
        hed__Application__c application = [SELECT ID FROM hed__Application__c];
        applicationQualification.TB_Qualification_Type__c = TB_Constants.TB_APPLICATION_QUALIFICATION_TYPE_LANGUAGE_TEST;
        update applicationQualification;

        //when
        Test.startTest();
        Object result = TB_MoodleExamController.getQualiObjectToLang(application.Id);
        Test.stopTest();

        //then
        System.assert(result instanceof  TB_Application_Qualification__c, 'Should return Application Qualification record');
    }

    @IsTest
    static void shouldReturnError_whenQualiIsNotTestType(){
        //given
        Boolean throwAuraExc =false;
        TB_Application_Qualification__c applicationQualification = [SELECT ID FROM TB_Application_Qualification__c];
        hed__Application__c application = [SELECT ID FROM hed__Application__c];
        update applicationQualification;

        //when
        Test.startTest();
        try{
            TB_MoodleExamController.getQualiObjectToLang(application.Id);
        }catch (Exception e) {
            if (e instanceof  AuraHandledException) {
                throwAuraExc = true;
            }
        }
        Test.stopTest();

        //then
        System.assert(throwAuraExc, ' Aura Exception should threw');
    }
}