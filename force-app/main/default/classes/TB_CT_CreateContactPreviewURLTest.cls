@IsTest
private class TB_CT_CreateContactPreviewURLTest {
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
                    TB_User__c = adminUserId,
                    hed__AlternateEmail__c = 'primary-responsible@test.test'
            );
            Contact responsibleCoordinator = new Contact(
                    LastName = 'coordinator',
                    Email = 'responsible-coordinator@test.test',
                    TB_Customer_Id__c = '09438510',
                    TB_User__c = adminUserId,
                    hed__AlternateEmail__c = 'primary-responsible@test.test'
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
    private static void createContactPreviewUrlTest() {
        TB_App_Tracking__c app = [
                SELECT TB_Applicant__c
                FROM TB_App_Tracking__c
        ][0];
        TB_Community_main_url__mdt communityLink = TB_Community_main_url__mdt.getInstance(TB_CT_CreateContactPreviewURL.COMMUNITY_URL_SETTING);
        String expectedURL = communityLink.Community_URL__c + '?contact-id=' + app.TB_Applicant__c + '&mode=preview';

        Test.startTest();
        List<TB_CT_CreateContactPreviewURL.LinkWrapper> wrappers =
                TB_CT_CreateContactPreviewURL.createContactPreviewUrl(new List<Id>{app.TB_Applicant__c});
        Test.stopTest();

        System.assertEquals(expectedURL, wrappers[0].contactPreviewURL);
    }

    @IsTest
    private static void createContactPreviewUrlNegativeTest() {

        Test.startTest();
        TB_CT_CreateContactPreviewURL.createContactPreviewUrl(null);
        Test.stopTest();

        Assert.areNotEqual(0, [SELECT Id FROM TB_Log__c].size());
    }
}