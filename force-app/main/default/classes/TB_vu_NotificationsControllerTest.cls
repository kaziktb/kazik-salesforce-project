@IsTest
private class TB_vu_NotificationsControllerTest {
    private static final String ADMIN_ROLE = 'Admin';
    private static final String NOTIFICATION_CATEGORY = 'Notification';

    @TestSetup
    static void setupMethod() {
        System.runAs(TB_DataFactory.createUser(TB_vu_Constants.ADMIN_PROFILE_NAME, ADMIN_ROLE, false)) {
            Contact contact = new Contact(LastName = TB_vu_Constants.TEST_EXPRESSION);
            insert contact;
            Case c = new Case(ContactId = contact.Id);
            c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(TB_vu_Constants.NOTIFICATION_CASE_RECORD_TYPE_DEVELOPER_NAME).getRecordTypeId();
            c.Origin = TB_vu_Constants.CSS_OFFICE_CASE_ORIGIN;
            c.TB_Category__c = NOTIFICATION_CATEGORY;
            insert c;
            ContentVersion version = TB_TestDataFactory.createContentVersion(
                false, 
                TB_vu_Constants.TEST_EXPRESSION, 
                TB_vu_Constants.TEST_EXPRESSION + '.pdf', 
                TB_vu_Constants.TEST_EXPRESSION);
            version.TB_Category__c = TB_vu_Constants.STUDENT_NOTIFICATION_CONTENT_VERSION_CATEGORY;
            insert version;
            ContentDocumentLink contentDocumentLink = TB_TestDataFactory.createContentDocumentLink(
                true,
                [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :version.Id].ContentDocumentId,
                c.Id
            );
            
            User u = TB_DataFactory.createUser(TB_vu_Constants.SWPS_STUDENT_PROFILE_Name, false);
            u.FirstName = TB_vu_Constants.TEST_EXPRESSION;
            u.LastName = TB_vu_Constants.TEST_EXPRESSION;
            u.ContactId = contact.Id;
            insert u;
            contact.TB_User__c = u.Id;
            update contact;
            hed__Program_Enrollment__c peToInsert = new hed__Program_Enrollment__c(
                hed__Contact__c = contact.Id
            );
            insert peToInsert;
        }
    }

    @IsTest
    static void shouldReturnCaseConnectedToContact() {
        Contact contact = [SELECT Id FROM Contact WHERE LastName =: TB_vu_Constants.TEST_EXPRESSION LIMIT 1];

        Test.startTest();
        List<Case> cases = TB_vu_NotificationsController.fetchCases(contact.Id);
        Test.stopTest();

        Assert.isTrue(cases.size() == 1);
        Assert.isTrue(cases[0].TB_Category__c == NOTIFICATION_CATEGORY);
    }

    @IsTest
    static void throwAnError_whenInvalidContactIdIsPassedToFetchCases() {
        Boolean isException = false;

        Test.startTest();
        try {
            TB_vu_NotificationsController.fetchCases(TB_vu_Constants.INVALID_EXPRESSION);
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        Assert.isTrue(isException);
    }

    @IsTest
    static void shouldReturnCaseWrappers() {
        Contact contact = [SELECT Id FROM Contact WHERE LastName =: TB_vu_Constants.TEST_EXPRESSION LIMIT 1];

        Test.startTest();
            List<TB_vu_NotificationsController.CaseWrapper> cases = TB_vu_NotificationsController.fetchCaseWrappers(contact.Id);
        Test.stopTest();

        Assert.isTrue(cases.size() == 1);
        Assert.isTrue(cases[0].type == NOTIFICATION_CATEGORY);
    }

}