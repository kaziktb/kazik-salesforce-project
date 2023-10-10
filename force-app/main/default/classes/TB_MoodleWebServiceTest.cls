@IsTest
private class TB_MoodleWebServiceTest {
    @TestSetup
    static void testSetup(){
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
        insert appQua;
        application.TB_Qualification__c = appQua.Id;
        update application;
        Test.stopTest();
    }

    @IsTest
    static void shouldCreateMoodleUser_WhenAppAndQualiExist() {
        //given
        TB_Application_Qualification__c appQua = [
                SELECT
                        Id,
                        TB_Application__r.Name,
                        TB_Application__r.hed__Applicant__r.FirstName,
                        TB_Application__r.hed__Applicant__r.LastName,
                        TB_Application__r.hed__Applicant__r.Email
                FROM TB_Application_Qualification__c
        ];
        TB_MoodleWebService.WrapperClass wrapper = new TB_MoodleWebService.WrapperClass();
        wrapper.methodToken = TB_MoodleConstants.FUNC_CREATE_USER;
        wrapper.appQualId = appQua.Id;
        wrapper.applicationName = appQua.TB_Application__r.Name;
        wrapper.firstname = appQua.TB_Application__r.hed__Applicant__r.FirstName;
        wrapper.lastname = appQua.TB_Application__r.hed__Applicant__r.LastName;
        wrapper.email = appQua.TB_Application__r.hed__Applicant__r.Email;

        //when
        Test.startTest();
        TB_MoodleWebService.rightMoodleMethod(wrapper, null);
        Test.stopTest();

        //then
        TB_Application_Qualification__c resultAppQuali = [SELECT ID, TB_Moodle_Username__c, TB_Moodle_Id__c From TB_Application_Qualification__c];
        System.assert(TB_MoodleMock.CREATE_USER_RESPONSE.contains(resultAppQuali.TB_Moodle_Username__c), 'Wrong MoodleUsername');
        System.assert(TB_MoodleMock.CREATE_USER_RESPONSE.contains(resultAppQuali.TB_Moodle_Id__c), 'Wrong moodle Id');
    }
}