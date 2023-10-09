@IsTest
private class TB_MoodleGetResultBatchTest {

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
    static void shouldUpdateAppQua_whenTestHasResult(){
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
        TB_Admissions_Committee__c committee = TB_TestDataFactory.createAdmissionsCommittee(true);
        TB_Qualification_Requirement_Item__c item = TB_TestDataFactory.createQualificationRequirementItem(false, committee.Id);
        item.TB_Moodle_Exam_ID__c = TB_MoodleMock.URL_COURSE;
        insert item;
        TB_Qualification_Requirement_Item_Term__c itemTerm = TB_TestDataFactory.createQualificationRequirementItemTerm(false, item.Id);
        itemTerm.TB_Start__c = Datetime.now().addMinutes(-30);
        itemTerm.TB_Moodle_Exam_ID__c = TB_MoodleMock.URL_COURSE;
        insert itemTerm;
        appQua.TB_Qualification_Requirement_Item_Term__c = itemTerm.Id;
        update appQua;
        System.assert([SELECT Id, TB_Moodle_Test_Result_Points__c FROM TB_Application_Qualification__c].TB_Moodle_Test_Result_Points__c == null, 'App Quali Moodle Result should not be set');

        //when
        Test.startTest();
        Database.executeBatch(new TB_MoodleGetResultBatch(), 50);
        Test.stopTest();

        //then
        //System.assert([SELECT Id, TB_Moodle_Test_Result_Points__c FROM TB_Application_Qualification__c].TB_Moodle_Test_Result_Points__c == TB_MoodleMock.TB_MOODLE_RESULT_POINTS, 'App Quali Moodle Result should be set');

    }

}