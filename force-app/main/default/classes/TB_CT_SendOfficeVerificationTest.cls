@IsTest
private class TB_CT_SendOfficeVerificationTest {
    private static final String PARAM_TEST_FIRST_NAME = 'TestF';
    private static final String PARAM_TEST_LAST_NAME = 'TestL';
    private static final String PARAM_TEST_EMAIL = 'test@test.test';

    @TestSetup
    private static void setupMethod() {
        System.runAs(TB_DataFactory.createUser(TB_Constants.PROFILE_NAME_ADMINISTRATOR, TB_Constants.ROLE_DEV_NAME_ADMIN, false)) {
            TB_CT_TestDataFactory.insertCTUrls();
            TB_CT_TestDataFactory.insertCTEmail();
            Id adminUserId = UserInfo.getUserId();

            Contact primaryResponsible = new Contact(
                    LastName = 'primary',
                    Email = 'primary-responsible@test.test',
                    TB_Customer_Id__c = '09283412',
                    TB_User__c = adminUserId
            );
            Contact responsibleCoordinator = new Contact(
                    LastName = 'coordinator',
                    Email = 'responsible-coordinator@test.test',
                    TB_Customer_Id__c = '09438510',
                    TB_User__c = adminUserId
            );
            insert new List<Contact>{primaryResponsible, responsibleCoordinator};
            TB_StaticTest.setDoNotRunTriggers();
            insert new TB_App_Tracking__c(
                    TB_First_Name__c = PARAM_TEST_FIRST_NAME,
                    TB_Last_Name__c = PARAM_TEST_LAST_NAME,
                    TB_Email__c = PARAM_TEST_EMAIL
            );
        }
    }

    @IsTest
    private static void sendEmailToOfficeTest() {
        TB_App_Tracking__c app = [SELECT TB_Applicant__c, TB_Email__c FROM TB_App_Tracking__c][0];
        TB_CT_SendOfficeVerification.AppTrackingWrapper wrapper = new TB_CT_SendOfficeVerification.AppTrackingWrapper();
        TB_Community_main_url__mdt communityLink = TB_Community_main_url__mdt.getInstance(TB_CT_CreateContactPreviewURL.COMMUNITY_URL_SETTING);
        String contactPreviewURL = communityLink.Community_URL__c + '?id=' + app.TB_Applicant__c + '&mode=preview';
        wrapper.appTrackingId = app.Id;
        wrapper.toAddress = app.TB_Email__c;
        wrapper.contactPreviewURL = contactPreviewURL;

        Test.startTest();
        TB_CT_SendOfficeVerification.sendEmailToOffice(new List<TB_CT_SendOfficeVerification.AppTrackingWrapper>{wrapper});
        Test.stopTest();

        System.assertEquals(1, Limits.getEmailInvocations(), 'Emails should be sent');
    }
}