@IsTest
private class TB_CT_SendDataForRegistrationTest {

    private static final String PARAM_TEST_FIRST_NAME = 'TestF';
    private static final String PARAM_TEST_LAST_NAME = 'TestL';
    private static final String PARAM_TEST_EMAIL = 'test@test.test';
    private static final String PARAM_TEST_CITIZENSHIP = 'AD';
    private static final String WORK_DEPARTMENT_EMAIL = 'work.dept@test.test';

    @TestSetup
    private static void setupMethod() {
        System.runAs(TB_DataFactory.createUser(TB_Constants.PROFILE_NAME_ADMINISTRATOR, TB_Constants.ROLE_DEV_NAME_ADMIN, false)) {
                TB_CT_TestDataFactory.insertCTEmail();
                TB_CT_TestDataFactory.insertCTUrls();
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

            Id recordTypeId = Schema.SObjectType.Account.recordTypeInfosByDeveloperName.get(TB_Constants.TB_CT_RECORD_TYPE_UNI_DEPARTMENTS).getRecordTypeId();
            Account department = new Account(
                    Name = 'Test',
                    TB_Email__c = WORK_DEPARTMENT_EMAIL,
                    RecordTypeId = recordTypeId
            );
            insert department;

            TB_App_Tracking__c app = new TB_App_Tracking__c(
                    TB_First_Name__c = PARAM_TEST_FIRST_NAME,
                    TB_Last_Name__c = PARAM_TEST_LAST_NAME,
                    TB_Email__c = PARAM_TEST_EMAIL,
                    TB_Process_Status__c = 'New',
                    TB_Dean_s_Office_Responsible__c = primaryResponsible.Id,
                    TB_Responsible_Coordinator__c = responsibleCoordinator.Id,
                    TB_Uni_Work_Department__c = department.Id
            );
            insert app;

            Contact contact = [
                    SELECT Id
                    FROM Contact
                    WHERE LastName = :PARAM_TEST_LAST_NAME
            ];
            contact.TB_Citizenship__c = PARAM_TEST_CITIZENSHIP;
            update contact;
        }
    }

    @IsTest
    private static void sendRegisterEmailNotificationPositiveTest() {
        TB_App_Tracking__c app = [
                SELECT TB_Email__c
                FROM TB_App_Tracking__c
        ][0];
        TB_CT_SendDataForRegistrationController.AppTrackingWrapperClass wrapper = new TB_CT_SendDataForRegistrationController.AppTrackingWrapperClass();
        wrapper.appTrackingId = app.Id;

        List<TB_CT_SendDataForRegistrationController.AppTrackingWrapperClass> wrappers = new List<TB_CT_SendDataForRegistrationController.AppTrackingWrapperClass>();
        wrappers.add(wrapper);

        Test.startTest();
        TB_CT_SendDataForRegistrationController.sendRegisterEmailNotification(wrappers);
        Test.stopTest();

        System.assertEquals(1, Limits.getEmailInvocations(), 'Emails should be sent');
    }

    @IsTest
    private static void sendRegisterEmailNotificationNegativeTest() {
        Test.startTest();
        TB_CT_SendDataForRegistrationController.sendRegisterEmailNotification(null);
        Test.stopTest();

        Assert.areNotEqual([SELECT Id FROM TB_Log__c].size(), 0);
    }
}