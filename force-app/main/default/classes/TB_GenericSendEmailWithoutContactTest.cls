@IsTest
private class TB_GenericSendEmailWithoutContactTest {

    private static final String PARAM_TEST_FIRST_NAME = 'TestF';
    private static final String PARAM_TEST_LAST_NAME = 'TestL';
    private static final String PARAM_TEST_EMAIL = 'test@test.test';
    private static final String TEMPLATE_DEVNAME = 'TB_Registration_Notification_PL';
    private static final String PARAM_TEST_CITIZENSHIP = 'AD';
    private static final String PARAM_TEST_PHONE = '111111111';
    private static final String WORK_DEPARTMENT_EMAIL = 'work.dept@test.test';
    private static final String ALTERNATE_VAL = 'Alternate';

    @TestSetup
    private static void setupMethod() {
        System.runAs(TB_DataFactory.createUser(TB_Constants.PROFILE_NAME_ADMINISTRATOR, TB_Constants.ROLE_DEV_NAME_ADMIN, false)) {
            TB_CT_TestDataFactory.insertCTEmail();
            TB_CT_TestDataFactory.insertCTUrls();
            Id adminUserId = UserInfo.getUserId();
            Contact primaryResponsible = new Contact(
                    LastName = 'primary',
                    Email=PARAM_TEST_EMAIL,
                    hed__AlternateEmail__c = PARAM_TEST_EMAIL,
                    hed__Preferred_Email__c = ALTERNATE_VAL,
                    hed__WorkEmail__c = 'primary-responsible@test.test',
                    TB_Customer_Id__c = '09283412',
                    TB_User__c = adminUserId
            );
            Contact responsibleCoordinator = new Contact(
                    LastName = 'coordinator',
                    Email = 'responsible-coordinator@test.test',
                    hed__AlternateEmail__c = PARAM_TEST_EMAIL,
                    hed__Preferred_Email__c = ALTERNATE_VAL,
                    hed__WorkEmail__c = 'responsibleCoordinator@test.test',
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
            contact.hed__WorkPhone__c = PARAM_TEST_PHONE;
            update contact;


        }
    }

    @IsTest
    private static void sendEmailPositiveTest() {
        TB_App_Tracking__c app = [
                SELECT TB_Email__c
                FROM TB_App_Tracking__c
        ][0];
        EmailTemplate template = [
                SELECT Id, HtmlValue, Body, Subject
                FROM EmailTemplate
                WHERE DeveloperName = :TEMPLATE_DEVNAME
        ][0];
        TB_GenericSendEmailWithoutContact.WrapperClass wrapper = new TB_GenericSendEmailWithoutContact.WrapperClass();
        wrapper.whatId = app.Id;
        wrapper.toAddress = app.TB_Email__c;
        wrapper.htmlBody = template.HtmlValue;
        wrapper.plainTextBody = template.Body;
        wrapper.subject = template.Subject;
        wrapper.sendFromEmail = 'test@test.com';
        List<TB_GenericSendEmailWithoutContact.WrapperClass> wrappers = new List<TB_GenericSendEmailWithoutContact.WrapperClass>();
        wrappers.add(wrapper);

        Test.startTest();
        TB_GenericSendEmailWithoutContact.sendEmail(wrappers);
        Test.stopTest();

        System.assertEquals(1, Limits.getEmailInvocations(), 'Emails should be sent');
    }

    @IsTest
    private static void sendEmailWithTargetIdInvocableTest() {
        Contact contact = [
                SELECT hed__WorkEmail__c
                FROM Contact
        ][0];
        EmailTemplate template = [
                SELECT Id, HtmlValue, Body, Subject
                FROM EmailTemplate
                WHERE DeveloperName = :TEMPLATE_DEVNAME
        ][0];
        TB_GenericSendEmailWithoutContact.WrapperClass wrapper = new TB_GenericSendEmailWithoutContact.WrapperClass();
        wrapper.targetObjectId = contact.Id;
        wrapper.toAddress = contact.hed__WorkEmail__c;
        wrapper.htmlBody = template.HtmlValue;
        wrapper.plainTextBody = template.Body;
        wrapper.subject = template.Subject;
        wrapper.sendFromEmail = 'test@test.com';
        List<TB_GenericSendEmailWithoutContact.WrapperClass> wrappers = new List<TB_GenericSendEmailWithoutContact.WrapperClass>();
        wrappers.add(wrapper);

        Test.startTest();
        TB_GenericSendEmailWithoutContact.sendEmailInvocable(wrappers);
        Test.stopTest();

        System.assertEquals(1, Limits.getEmailInvocations(), 'Emails should be sent');
    }

    @IsTest
    private static void sendEmailNegativeTest() {

        Test.startTest();
        TB_GenericSendEmailWithoutContact.sendEmail(null);
        Test.stopTest();

        Assert.areNotEqual(0, [SELECT Id FROM TB_Log__c].size());
    }
}