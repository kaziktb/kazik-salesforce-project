@IsTest
private class TB_vu_CertificatePreviewControllerTest
{
    private static final String USER_LAST_NAME = 'CaseTest';
    private static final String UNIVERSITY_MAIL = 'test.tester@st.swps.edu.pl';
    
    private static final String ACCOUNT_NAME = 'Test SWPS Account';
    private static final String ACCOUNT_VDO_ID = '93';
    private static final String TEMPLATE_TITLE = 'Test_Cert';
    private static final String TEMPLATE_HTML_EXTENSION = '.html';
    private static final String TEMPLATE_CONTENT = 'Test template';
    private static final String TEMPLATE_TB_CATEGORY = 'PDF_Template';
    
    private static final String ADDITIONAL_COMMENT = 'Test Additional Comment';
    
    @TestSetup
    static void setup()
    {
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
    
        Case testCertificate = new Case(
                RecordTypeId = TB_vu_CasesController.getRecordTypeId('TB_Student_Certificate_HE'),
                Origin = 'Virtual_University',
                ContactId = contact.Id,
                TB_Category__c = 'Study_Certificate',
                TB_Program_Enrollment__c = pe.Id,
                TB_Creation_Method__c = 'Request_For_Certificate',
                TB_Document_Template_Name__c = TEMPLATE_TITLE,
                TB_Document_Additional_Comment__c = ADDITIONAL_COMMENT
        );
        insert testCertificate;
    }
    
    @IsTest
    static void getCertInfoTest()
    {
        Case testCertificate = [SELECT Id FROM Case];
        
        Test.startTest();
        TB_vu_CertificatePreviewController.CertInfo info = TB_vu_CertificatePreviewController.getCertInfo(testCertificate.Id, '');
        Test.stopTest();
        
        System.assert(info.recordIds.contains(testCertificate.Id));
        ContentVersion cv = [SELECT Id FROM ContentVersion WHERE Title = :TEMPLATE_TITLE];
        System.assert(info.recordIds.contains(cv.Id));
        Map<String,String> deserializedReplacements = (Map<String,String>)JSON.deserialize(info.replacementsJSON,Map<String,String>.class);
        System.assert(deserializedReplacements.containsKey('CreationDate'));
        System.assert(deserializedReplacements.containsKey('AdditionalComment'));
        System.assertEquals(ADDITIONAL_COMMENT,deserializedReplacements.get('AdditionalComment'));
        System.assert(deserializedReplacements.containsKey('Signer'));
        System.assertEquals('.............................',deserializedReplacements.get('Signer'));
    }
    
    @IsTest
    static void savePDFTest()
    {
        Case testCertificate = [SELECT Id FROM Case];
        
        Test.startTest();
        TB_vu_CertificatePreviewController.savePDF(testCertificate.Id, '');
        Test.stopTest();
    
        ContentDocumentLink link = [SELECT Id, ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink WHERE LinkedEntityId = :testCertificate.Id];
        ContentVersion version = [SELECT Id, TB_Category__c FROM ContentVersion WHERE Id = :link.ContentDocument.LatestPublishedVersionId];
        System.assertEquals('Student_Certificate',version.TB_Category__c);
    }
}