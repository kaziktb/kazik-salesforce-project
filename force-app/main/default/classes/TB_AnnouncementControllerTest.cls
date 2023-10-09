@IsTest
public with sharing class TB_AnnouncementControllerTest {

    @TestSetup
    static void testSetup() {
        hed__Application__c application = TB_TestDataFactory.createApplicationWithRelatedObjectsAndNestedLookup(false);
        Contact applicant = new Contact(
            LastName = 'Test'
        );
        insert applicant;
        application.hed__Applicant__c = applicant.Id;
        insert application;
        TB_Admissions_Content__c content = new TB_Admissions_Content__c(
            TB_Active__c = true,
            TB_Content_Type__c = 'Message',
            TB_Content_PL__c = 'Test',
            TB_Content_EN__c = 'Test'
        );
        insert content;
        TB_Admissions_Logic__c messageLogic = TB_DataFactory.createAdmissionsLogic(false);
        messageLogic.RecordTypeId = Schema.SObjectType.TB_Admissions_Logic__c
            .getRecordTypeInfosByDeveloperName().get(TB_re_Constants.ADMISSIONS_LOGIC_MESSAGE_LOGIC_RT).getRecordTypeId();
        messageLogic.TB_Active__c = true;
        messageLogic.TB_Admissions_Process__c = application.TB_Admissions_Process__c;
        messageLogic.TB_Admissions_Content__c = content.Id;
        messageLogic.TB_Display_Logic__c = 'Application.hed__Application_Status__c=\'Verification\'';
        insert messageLogic;
    }

    @IsTest
    static void getMessageLogics() {
        hed__Application__c app = [ SELECT Id, TB_Admissions_Process_Id__c FROM hed__Application__c LIMIT 1 ];
        app = TB_AdmissionsFormsController.getApplication(app.Id);

        Test.startTest();
        String resultJSON = TB_AnnouncementController.getMessageLogics(app, 'EN');
        Test.stopTest();

        List<TB_AnnouncementController.MessageLogicsWrapper> result = (List<TB_AnnouncementController.MessageLogicsWrapper>) JSON.deserialize(resultJSON, List<TB_AnnouncementController.MessageLogicsWrapper>.class);
        System.assertEquals(1, result.size());
    }

}