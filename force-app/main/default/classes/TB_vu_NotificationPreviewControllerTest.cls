@IsTest
private class TB_vu_NotificationPreviewControllerTest {
    private static final String USER_LAST_NAME = 'CaseTest';
    private static final String UNIVERSITY_MAIL = 'test.tester@st.swps.edu.pl';
    
    private static final String ACCOUNT_NAME = 'Test SWPS Account';
    private static final String ACCOUNT_VDO_ID = '93';
    private static final String TEMPLATE_TITLE = 'Test_Notification';
    private static final String TEMPLATE_HTML_EXTENSION = '.html';
    private static final String TEMPLATE_CONTENT = 'Test template';
    private static final String TEMPLATE_TB_CATEGORY = 'PDF_Template';
    
    @TestSetup
    static void testSetup(){
        Contact contact = new Contact(LastName = USER_LAST_NAME, hed__UniversityEmail__c = UNIVERSITY_MAIL);
        insert contact;

        Account testAccount = new Account(Name=ACCOUNT_NAME,DT_VDO_ID__c = ACCOUNT_VDO_ID);
        insert testAccount;

        hed__Program_Enrollment__c pe = new hed__Program_Enrollment__c(hed__Contact__c = contact.Id, hed__Account__c = testAccount.Id);
        insert pe;

        TB_SWPS_Document_Template_Account_Ids__c customSetting = new TB_SWPS_Document_Template_Account_Ids__c(TB_SS_Account__c=ACCOUNT_VDO_ID);
        insert customSetting;

        ContentVersion templateVersion = new ContentVersion(Title = TEMPLATE_TITLE, PathOnClient = TEMPLATE_TITLE+TEMPLATE_HTML_EXTENSION, VersionData=Blob.valueOf(TEMPLATE_CONTENT), TB_Category__c=TEMPLATE_TB_CATEGORY);
        insert templateVersion;

        ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :templateVersion.Id];

        ContentDocumentLink templateLink = new ContentDocumentLink(LinkedEntityId = testAccount.Id, ContentDocumentId = cv.ContentDocumentId);
        insert templateLink;

        Case testNotification = new Case(
            ContactId = contact.Id,
            RecordTypeId = TB_vu_CasesController.getRecordTypeId(TB_vu_Constants.NOTIFICATION_CASE_RECORD_TYPE_DEVELOPER_NAME),
            TB_Program_Enrollment__c = pe.Id,
            TB_Document_Template_Name__c = TEMPLATE_TITLE
        );
        insert testNotification;
    }

    @IsTest
    static void shouldSavePDF()
    {
        Case testNotification = [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest();
        TB_vu_NotificationPreviewController.generateNotificationPDF(new List<Id>{testNotification.Id});
        Test.stopTest();
    
        ContentDocumentLink link = [SELECT Id, ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink WHERE LinkedEntityId = :testNotification.Id];
        ContentVersion version = [SELECT Id, TB_Category__c FROM ContentVersion WHERE Id = :link.ContentDocument.LatestPublishedVersionId];
        Assert.areEqual(TB_vu_Constants.STUDENT_NOTIFICATION_CONTENT_VERSION_CATEGORY,version.TB_Category__c);
    }

    @isTest
    static void throwAnError_whenCaseHasDocumentTemplateName(){
        Case testNotification = [SELECT Id,TB_Document_Template_Name__c FROM Case LIMIT 1];
        testNotification.TB_Document_Template_Name__c = 'BAD_TEMPLATE.404';
        update testNotification;

        Boolean isException = false;

        Test.startTest();
        try {
            TB_vu_NotificationPreviewController.generateNotificationPDF(new List<Id>{testNotification.Id});
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        Assert.isTrue(isException);
    }
}