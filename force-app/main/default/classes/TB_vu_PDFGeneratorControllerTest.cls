@IsTest
private class TB_vu_PDFGeneratorControllerTest
{
    private static final String TEST_HTML = '<html xmlns:v="urn:schemas-microsoft-com:vml"\n' +
            'xmlns:o="urn:schemas-microsoft-com:office:office"\n' +
            'xmlns:w="urn:schemas-microsoft-com:office:word"\n' +
            'xmlns:m="http://schemas.microsoft.com/office/2004/12/omml"\n' +
            'xmlns="http://www.w3.org/TR/REC-html40">\n' +
            '\n' +
            '<head>\n' +
            '<meta http-equiv=Content-Type content="text/html; charset=utf-8">\n' +
            '<meta name=ProgId content=Word.Document>\n' +
            '<meta name=Generator content="Microsoft Word 15">\n' +
            '<meta name=Originator content="Microsoft Word 15">\n' +
            '</head>\n' +
            '\n' +
            '<body lang=PL style=\'tab-interval:35.4pt\'>\n' +
            '\n' +
            '<div class=WordSection1>\n' +
            '\n' +
            '<table class=MsoTable15Plain5 border=0 cellspacing=0 cellpadding=0\n' +
            ' style=\'border-collapse:collapse;mso-yfti-tbllook:1536;mso-padding-alt:0cm 5.4pt 0cm 5.4pt\'>\n' +
            ' <tr style=\'mso-yfti-irow:0;mso-yfti-firstrow:yes\'>\n' +
            '  <td width=151 valign=top style=\'width:113.15pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p class=MsoNormal>${Resource.swps_logo height="100%" width="100%"}</p>\n' +
            '  </td>\n' +
            '  <td width=170 valign=top style=\'width:127.6pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p class=MsoNormal><o:p>&nbsp;</o:p></p>\n' +
            '  </td>\n' +
            '  <td width=283 valign=top style=\'width:212.05pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p class=MsoNormal>Numer Systemowy podania: ${<span class=SpellE>Case.CaseNumber</span>}</p>\n' +
            '  </td>\n' +
            '</tr>\n' +
            ' <tr style=\'mso-yfti-irow:0;mso-yfti-firstrow:yes\'>\n' +
            '  <td width=151 valign=top style=\'width:113.15pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p class=MsoNormal>${Case.Contact.Account.Name}</p>\n' +
            '  </td>\n' +
            '  <td width=170 valign=top style=\'width:127.6pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p class=MsoNormal><o:p>${Case.Contact.Birthdate}</o:p></p>\n' +
            '  </td>\n' +
            '  <td width=283 valign=top style=\'width:212.05pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p class=MsoNormal>${<span class=SpellE>Case.Contact.DT_Hourly_Rate_Consultant__c</span>}</p>\n' +
            '  </td>\n' +
            '</tr>\n' +
            ' <tr style=\'mso-yfti-irow:0;mso-yfti-firstrow:yes\'>\n' +
            '  <td width=151 valign=top style=\'width:113.15pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p class=MsoNormal>${Case.Contact.Account.Name}</p>\n' +
            '  </td>\n' +
            '  <td width=170 valign=top style=\'width:127.6pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p class=MsoNormal><o:p>${CustomMergeField}</o:p></p>\n' +
            '  </td>\n' +
            '  <td width=283 valign=top style=\'width:212.05pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p class=MsoNormal>${<span class=SpellE>Case.Contact.DT_Contact_Type__c</span>}</p>\n' +
            '  </td>\n' +
            '</tr>\n' +
            '</tr>\n' +
            ' <tr style=\'mso-yfti-irow:0;mso-yfti-firstrow:yes\'>\n' +
            '  <td>\n' +
            '  <p class=MsoNormal>${<span class=SpellE>Case.CaseComments:comment(IsPublished = TRUE)</span></p>\n' +
            '  <p class=MsoNormal>$comment.CommentBody</p>\n' +
            '  <p class=MsoNormal>$comment.IsPublished</p>\n' +
            '  <p class=MsoNormal>:}</p>\n' +
            '  </td>\n' +
            '</tr>\n' +
            '</table>\n' +
            '</div>\n' +
            '</body>\n' +
            '</html>';
    
    private static final String CLEAN_BODY = '<div>\n' +
            '\n' +
            '<table border=0 cellspacing=0 cellpadding=0\n' +
            ' style=\'border-collapse:collapse;mso-yfti-tbllook:1536;mso-padding-alt:0cm 5.4pt 0cm 5.4pt\'>\n' +
            ' <tr style=\'mso-yfti-irow:0;mso-yfti-firstrow:yes\'>\n' +
            '  <td width=151 valign=top style=\'width:113.15pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p>${Resource.swps_logo height="100%" width="100%"}</p>\n' +
            '  </td>\n' +
            '  <td width=170 valign=top style=\'width:127.6pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p><p>&nbsp;</p></p>\n' +
            '  </td>\n' +
            '  <td width=283 valign=top style=\'width:212.05pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p>Numer Systemowy podania: ${Case.CaseNumber}</p>\n' +
            '  </td>\n' +
            '</tr>\n' +
            ' <tr style=\'mso-yfti-irow:0;mso-yfti-firstrow:yes\'>\n' +
            '  <td width=151 valign=top style=\'width:113.15pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p>${Case.Contact.Account.Name}</p>\n' +
            '  </td>\n' +
            '  <td width=170 valign=top style=\'width:127.6pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p><p>${Case.Contact.Birthdate}</p></p>\n' +
            '  </td>\n' +
            '  <td width=283 valign=top style=\'width:212.05pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p>${Case.Contact.DT_Hourly_Rate_Consultant__c}</p>\n' +
            '  </td>\n' +
            '</tr>\n' +
            ' <tr style=\'mso-yfti-irow:0;mso-yfti-firstrow:yes\'>\n' +
            '  <td width=151 valign=top style=\'width:113.15pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p>${Case.Contact.Account.Name}</p>\n' +
            '  </td>\n' +
            '  <td width=170 valign=top style=\'width:127.6pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p><p>${CustomMergeField}</p></p>\n' +
            '  </td>\n' +
            '  <td width=283 valign=top style=\'width:212.05pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p>${Case.Contact.DT_Contact_Type__c}</p>\n' +
            '  </td>\n' +
            '</tr>\n' +
            '</tr>\n' +
            ' <tr style=\'mso-yfti-irow:0;mso-yfti-firstrow:yes\'>\n' +
            '  <td>\n' +
            '  <p>${Case.CaseComments:comment(IsPublished = TRUE)</p>\n' +
            '  <p>$comment.CommentBody</p>\n' +
            '  <p>$comment.IsPublished</p>\n' +
            '  <p>:}</p>\n' +
            '  </td>\n' +
            '</tr>\n' +
            '</table>\n' +
            '</div>';
    
    private static final String RESULT_HTML = '<div>\n' +
            '\n' +
            '<table border=0 cellspacing=0 cellpadding=0\n' +
            ' style=\'border-collapse:collapse;mso-yfti-tbllook:1536;mso-padding-alt:0cm 5.4pt 0cm 5.4pt\'>\n' +
            ' <tr style=\'mso-yfti-irow:0;mso-yfti-firstrow:yes\'>\n' +
            '  <td width=151 valign=top style=\'width:113.15pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p><img src="/resource/swps_logo" height="100%" width="100%"/></p>\n' +
            '  </td>\n' +
            '  <td width=170 valign=top style=\'width:127.6pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p><p>&nbsp;</p></p>\n' +
            '  </td>\n' +
            '  <td width=283 valign=top style=\'width:212.05pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p>Numer Systemowy podania: ${Case.CaseNumber}</p>\n' +
            '  </td>\n' +
            '</tr>\n' +
            ' <tr style=\'mso-yfti-irow:0;mso-yfti-firstrow:yes\'>\n' +
            '  <td width=151 valign=top style=\'width:113.15pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p>Test Account</p>\n' +
            '  </td>\n' +
            '  <td width=170 valign=top style=\'width:127.6pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p><p>21.02.1997</p></p>\n' +
            '  </td>\n' +
            '  <td width=283 valign=top style=\'width:212.05pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p>3,14</p>\n' +
            '  </td>\n' +
            '</tr>\n' +
            ' <tr style=\'mso-yfti-irow:0;mso-yfti-firstrow:yes\'>\n' +
            '  <td width=151 valign=top style=\'width:113.15pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p>Test Account</p>\n' +
            '  </td>\n' +
            '  <td width=170 valign=top style=\'width:127.6pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p><p>Custom Merge Field Value</p></p>\n' +
            '  </td>\n' +
            '  <td width=283 valign=top style=\'width:212.05pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p>Student</p>\n' +
            '  </td>\n' +
            '</tr>\n' +
            '</tr>\n' +
            ' <tr style=\'mso-yfti-irow:0;mso-yfti-firstrow:yes\'>\n' +
            '  <td>\n' +
            '  <p></p>\n' +
            '  <p>Test 1</p>\n' +
            '  <p>Yes</p>\n' +
            '  <p></p>\n' +
            '  <p>Test 2</p>\n' +
            '  <p>Yes</p>\n' +
            '  <p></p>\n' +
            '  </td>\n' +
            '</tr>\n' +
            '</table>\n' +
            '</div>';
    
    private static final String RESULT_HTML_NO_CHILDREN = '<div>\n' +
            '\n' +
            '<table border=0 cellspacing=0 cellpadding=0\n' +
            ' style=\'border-collapse:collapse;mso-yfti-tbllook:1536;mso-padding-alt:0cm 5.4pt 0cm 5.4pt\'>\n' +
            ' <tr style=\'mso-yfti-irow:0;mso-yfti-firstrow:yes\'>\n' +
            '  <td width=151 valign=top style=\'width:113.15pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p><img src="/resource/swps_logo" height="100%" width="100%"/></p>\n' +
            '  </td>\n' +
            '  <td width=170 valign=top style=\'width:127.6pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p><p>&nbsp;</p></p>\n' +
            '  </td>\n' +
            '  <td width=283 valign=top style=\'width:212.05pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p>Numer Systemowy podania: ${<span>Case.CaseNumber</span>}</p>\n' +
            '  </td>\n' +
            '</tr>\n' +
            ' <tr style=\'mso-yfti-irow:0;mso-yfti-firstrow:yes\'>\n' +
            '  <td width=151 valign=top style=\'width:113.15pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p>Test Account</p>\n' +
            '  </td>\n' +
            '  <td width=170 valign=top style=\'width:127.6pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p><p>'+Date.newInstance(1997,2,21).format()+'</p></p>\n' +
            '  </td>\n' +
            '  <td width=283 valign=top style=\'width:212.05pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p>3,14</p>\n' +
            '  </td>\n' +
            '</tr>\n' +
            ' <tr style=\'mso-yfti-irow:0;mso-yfti-firstrow:yes\'>\n' +
            '  <td width=151 valign=top style=\'width:113.15pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p>Test Account</p>\n' +
            '  </td>\n' +
            '  <td width=170 valign=top style=\'width:127.6pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p><p>Custom Merge Field Value</p></p>\n' +
            '  </td>\n' +
            '  <td width=283 valign=top style=\'width:212.05pt;padding:0cm 5.4pt 0cm 5.4pt\'>\n' +
            '  <p>Student</p>\n' +
            '  </td>\n' +
            '</tr>\n' +
            '</tr>\n' +
            ' <tr style=\'mso-yfti-irow:0;mso-yfti-firstrow:yes\'>\n' +
            '  <td>\n' +
            '  <p></p>\n' +
            '  </td>\n' +
            '</tr>\n' +
            '</table>\n' +
            '</div>';
    private static final String ACCOUNT_NAME = 'Test SWPS Account';
    private static final String ACCOUNT_VDO_ID = '93';
    private static final String TEMPLATE_TITLE = 'Application_Template_';
    private static final String TEMPLATE_TITLE_PL_SUFFIX = 'PL';
    private static final String TEMPLATE_TITLE_EN_SUFFIX = 'EN';
    private static final String TEMPLATE_HTML_EXTENSION = '.html';
    private static final String TEMPLATE_CONTENT = 'Test template';
    private static final String TEMPLATE_TB_CATEGORY = 'PDF_Template';
    private static final String TEMPLATE_NAME_PARAM = '%Application_Template%';
    
    @TestSetup
    static void setup()
    {
        ContentVersion template = new ContentVersion(
                Title = 'Test Template',
                PathOnClient = 'testTemplate',
                VersionData = Blob.valueOf(TEST_HTML)
        );
        insert template;
        Account account = new Account(Name='Test Account');
        insert account;
        Contact contact = new Contact(
                LastName = 'Kowalski',
                Birthdate = Date.newInstance(1997,2,21),
                DT_Hourly_Rate_Consultant__c = 3.14,
                DT_Contact_Type__c = 'Student',
                AccountId = account.Id);
        insert contact;
        Case testCase = new Case(
                Subject = 'Test',
                Status = 'New',
                ContactId = contact.Id
        );
        insert testCase;
    }
    
    @IsTest
    static void testGetCleanHtmlBody()
    {
        String cleanHtml = TB_vu_PDFGeneratorController.getCleanHtmlBody(TEST_HTML);
        System.assertEquals(CLEAN_BODY,cleanHtml);
    }
    
    @IsTest
    static void testController()
    {
        Case testCase = [SELECT Id, CaseNumber FROM Case LIMIT 1];
        List<CaseComment> comments = new List<CaseComment>();
        comments.add(new CaseComment(ParentId=testCase.Id,CommentBody='Test 1',IsPublished=true));
        comments.add(new CaseComment(ParentId=testCase.Id,CommentBody='Test 2',IsPublished=true));
        comments.add(new CaseComment(ParentId=testCase.Id,CommentBody='Test 3'));
        insert comments;
    
        ContentVersion template = [SELECT Id FROM ContentVersion WHERE Title = 'Test Template'];
        
        PageReference pdfGeneratorPage = Page.TB_vu_PDFGenerator;
        Test.setCurrentPage(pdfGeneratorPage);
        ApexPages.currentPage().getParameters().put('recordIds',template.Id + ',' + testCase.Id);
        ApexPages.currentPage().getParameters().put('replacements','{"CustomMergeField":"Custom Merge Field Value"}');
        
        TB_vu_PDFGeneratorController controller = new TB_vu_PDFGeneratorController();
        System.assertEquals(RESULT_HTML.replace('${Case.CaseNumber}',testCase.CaseNumber),controller.htmlValue);
    }
    
    @IsTest
    static void testControllerNoChildren()
    {
        Case testCase = [SELECT Id, CaseNumber FROM Case LIMIT 1];
    
        ContentVersion template = [SELECT Id FROM ContentVersion WHERE Title = 'Test Template'];
        
        PageReference pdfGeneratorPage = Page.TB_vu_PDFGenerator;
        Test.setCurrentPage(pdfGeneratorPage);
        ApexPages.currentPage().getParameters().put('recordIds',template.Id + ',' + testCase.Id);
        ApexPages.currentPage().getParameters().put('replacements','{"CustomMergeField":"Custom Merge Field Value"}');
    
        Case dbCase = [SELECT CaseNumber FROM Case WHERE Id = :testCase.Id];
        TB_vu_PDFGeneratorController controller = new TB_vu_PDFGeneratorController();
        System.assertEquals(RESULT_HTML_NO_CHILDREN.replace('${<span>Case.CaseNumber</span>}',dbCase.CaseNumber),controller.htmlValue);
    }
    
    @IsTest
    static void testControllerNoTemplate()
    {
        Case testCase = [SELECT Id, CaseNumber FROM Case LIMIT 1];
    
        ContentVersion template = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'Test Template'];
    
        PageReference pdfGeneratorPage = Page.TB_vu_PDFGenerator;
        Test.setCurrentPage(pdfGeneratorPage);
        ApexPages.currentPage().getParameters().put('recordIds',template.Id + ',' + testCase.Id);
    
        String templateId = template.Id;
        Database.delete(template.ContentDocumentId);
        TB_vu_PDFGeneratorController controller = new TB_vu_PDFGeneratorController();
        System.assertEquals('<p>Template not found! Couldn\'t find a template with this ID: '+templateId+'</p>',controller.htmlValue);
    }
    
    @IsTest
    static void testControllerNoTemplateID()
    {
        Case testCase = [SELECT Id, CaseNumber FROM Case LIMIT 1];
        
        PageReference pdfGeneratorPage = Page.TB_vu_PDFGenerator;
        Test.setCurrentPage(pdfGeneratorPage);
        ApexPages.currentPage().getParameters().put('recordIds',testCase.Id);
        
        TB_vu_PDFGeneratorController controller = new TB_vu_PDFGeneratorController();
        System.assertEquals('<p>Template not found! The template ID was not provided</p>',controller.htmlValue);
    }
    
    @IsTest
    static void testQueueable()
    {
        Case testCase = [SELECT Id, CaseNumber FROM Case LIMIT 1];
        ContentVersion template = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'Test Template'];
        
        TB_vu_PDFGeneratorController.PDFQueueableParams params = new TB_vu_PDFGeneratorController.PDFQueueableParams();
        params.templateId = template.Id;
        params.networkId = [SELECT Id FROM Network WHERE Name = 'Virtual University'].Id;
        params.objects = new List<TB_vu_PDFGeneratorController.PDFObjectWrapper>();
        TB_vu_PDFGeneratorController.PDFObjectWrapper wrapper = new TB_vu_PDFGeneratorController.PDFObjectWrapper();
        wrapper.recordId = testCase.Id;
        wrapper.linkToIds.add(testCase.Id);
        wrapper.isUpdate = true;
        wrapper.category = TB_vu_ApplicationPreviewController.APPLICATION_PDF_CATEGORY;
        wrapper.fileName = 'testname';
        params.objects.add(wrapper);
        
        Test.startTest();
        System.enqueueJob(new TB_vu_PDFGeneratorController.PDFQueueable(params));
        Test.stopTest();
        
        ContentVersion version = [SELECT Id, ContentDocumentId, Title, PathOnClient FROM ContentVersion WHERE TB_Category__c = :TB_vu_ApplicationPreviewController.APPLICATION_PDF_CATEGORY];
        System.assertEquals('testname',version.Title);
        System.assertEquals('testname.pdf',version.PathOnClient);
        List<ContentDocumentLink> links = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId = :version.ContentDocumentId];
        System.assertEquals(2,links.size());
        Boolean foundLink = false;
        for(ContentDocumentLink link : links)
        {
            if(link.LinkedEntityId == testCase.Id)
            {
                foundLink = true;
            }
        }
        System.assert(foundLink);
    }
    
    @IsTest
    static void testGetTemplateDocumentId()
    {
        Account testAccount = new Account(Name=ACCOUNT_NAME,DT_VDO_ID__c = ACCOUNT_VDO_ID);
        insert testAccount;
        TB_SWPS_Document_Template_Account_Ids__c customSetting = new TB_SWPS_Document_Template_Account_Ids__c(TB_SS_Account__c=ACCOUNT_VDO_ID);
        insert customSetting;
        ContentVersion templateVersionPL = new ContentVersion(Title = TEMPLATE_TITLE+TEMPLATE_TITLE_PL_SUFFIX, PathOnClient = TEMPLATE_TITLE+TEMPLATE_TITLE_PL_SUFFIX+TEMPLATE_HTML_EXTENSION, VersionData=Blob.valueOf(TEMPLATE_CONTENT), TB_Category__c=TEMPLATE_TB_CATEGORY);
        ContentVersion templateVersionEN = new ContentVersion(Title = TEMPLATE_TITLE+TEMPLATE_TITLE_EN_SUFFIX, PathOnClient = TEMPLATE_TITLE+TEMPLATE_TITLE_EN_SUFFIX+TEMPLATE_HTML_EXTENSION, VersionData=Blob.valueOf(TEMPLATE_CONTENT), TB_Category__c=TEMPLATE_TB_CATEGORY);
        insert new List<ContentVersion>{templateVersionPL,templateVersionEN};
        Map<Id,ContentVersion> cvs = new Map<Id,ContentVersion>([SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :templateVersionPL.Id OR Id = :templateVersionEN.Id]);
        ContentDocumentLink templateLinkPL = new ContentDocumentLink(LinkedEntityId = testAccount.Id, ContentDocumentId = cvs.get(templateVersionPL.Id).ContentDocumentId);
        ContentDocumentLink templateLinkEN = new ContentDocumentLink(LinkedEntityId = testAccount.Id, ContentDocumentId = cvs.get(templateVersionEN.Id).ContentDocumentId);
        insert new List<ContentDocumentLink>{templateLinkPL,templateLinkEN};
        
        Test.startTest();
        Id plTemplateId;
        Id enTemplateId;
        TB_vu_LanguageSelectorController.changeLang('pl');
        plTemplateId = TB_vu_PDFGeneratorController.getTemplateDocumentId(TEMPLATE_NAME_PARAM);
        TB_vu_LanguageSelectorController.changeLang('en_US');
        enTemplateId = TB_vu_PDFGeneratorController.getTemplateDocumentId(TEMPLATE_NAME_PARAM);
        Test.stopTest();
        
        System.assertEquals(templateVersionPL.Id,plTemplateId);
        System.assertEquals(templateVersionEN.Id,enTemplateId);
    }
    
    @IsTest
    static void testGetTemplateDocumentIdNoMatchingTemplate()
    {
        Account testAccount = new Account(Name=ACCOUNT_NAME,DT_VDO_ID__c = ACCOUNT_VDO_ID);
        insert testAccount;
        TB_SWPS_Document_Template_Account_Ids__c customSetting = new TB_SWPS_Document_Template_Account_Ids__c(TB_SS_Account__c=ACCOUNT_VDO_ID);
        insert customSetting;
        ContentVersion templateVersionPL = new ContentVersion(Title = TEMPLATE_TITLE+TEMPLATE_TITLE_PL_SUFFIX, PathOnClient = TEMPLATE_TITLE+TEMPLATE_TITLE_PL_SUFFIX+TEMPLATE_HTML_EXTENSION, VersionData=Blob.valueOf(TEMPLATE_CONTENT), TB_Category__c=TEMPLATE_TB_CATEGORY);
        ContentVersion templateVersionPL2 = new ContentVersion(Title = TEMPLATE_TITLE+TEMPLATE_TITLE_PL_SUFFIX, PathOnClient = TEMPLATE_TITLE+TEMPLATE_TITLE_PL_SUFFIX+TEMPLATE_HTML_EXTENSION, VersionData=Blob.valueOf(TEMPLATE_CONTENT), TB_Category__c=TEMPLATE_TB_CATEGORY);
        insert new List<ContentVersion>{templateVersionPL,templateVersionPL2};
        Map<Id,ContentVersion> cvs = new Map<Id,ContentVersion>([SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :templateVersionPL.Id OR Id = :templateVersionPL2.Id]);
        ContentDocumentLink templateLinkPL = new ContentDocumentLink(LinkedEntityId = testAccount.Id, ContentDocumentId = cvs.get(templateVersionPL.Id).ContentDocumentId);
        ContentDocumentLink templateLinkPL2 = new ContentDocumentLink(LinkedEntityId = testAccount.Id, ContentDocumentId = cvs.get(templateVersionPL2.Id).ContentDocumentId);
        insert new List<ContentDocumentLink>{templateLinkPL,templateLinkPL2};
        
        Test.startTest();
        Id templateId;
        TB_vu_LanguageSelectorController.changeLang('en_US');
        templateId = TB_vu_PDFGeneratorController.getTemplateDocumentId(TEMPLATE_NAME_PARAM);
        Test.stopTest();
        
        System.assertEquals(null,templateId);
    }
    
    @IsTest
    static void testGetTemplateDocumentIdSingleTemplate()
    {
        Account testAccount = new Account(Name=ACCOUNT_NAME,DT_VDO_ID__c = ACCOUNT_VDO_ID);
        insert testAccount;
        TB_SWPS_Document_Template_Account_Ids__c customSetting = new TB_SWPS_Document_Template_Account_Ids__c(TB_SS_Account__c=ACCOUNT_VDO_ID);
        insert customSetting;
        ContentVersion templateVersion = new ContentVersion(Title = 'Application_Template', PathOnClient = 'Application_Template.html', VersionData=Blob.valueOf(TEMPLATE_CONTENT), TB_Category__c=TEMPLATE_TB_CATEGORY);
        insert templateVersion;
        Map<Id,ContentVersion> cvs = new Map<Id,ContentVersion>([SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :templateVersion.Id]);
        ContentDocumentLink templateLink = new ContentDocumentLink(LinkedEntityId = testAccount.Id, ContentDocumentId = cvs.get(templateVersion.Id).ContentDocumentId);
        insert templateLink;
        
        Test.startTest();
        Id templateId;
        templateId = TB_vu_PDFGeneratorController.getTemplateDocumentId(TEMPLATE_NAME_PARAM);
        Test.stopTest();
        
        System.assertEquals(templateVersion.Id,templateId);
    }
    
    @IsTest
    static void testGetTemplateDocumentIdNoTemplate()
    {
        Account testAccount = new Account(Name=ACCOUNT_NAME,DT_VDO_ID__c = ACCOUNT_VDO_ID);
        insert testAccount;
        TB_SWPS_Document_Template_Account_Ids__c customSetting = new TB_SWPS_Document_Template_Account_Ids__c(TB_SS_Account__c=ACCOUNT_VDO_ID);
        insert customSetting;
        
        Test.startTest();
        Id templateId;
        templateId = TB_vu_PDFGeneratorController.getTemplateDocumentId(TEMPLATE_NAME_PARAM);
        Test.stopTest();
        
        System.assertEquals(null,templateId);
    }
    
    @IsTest
    static void testGetTemplateDocumentIdNoAccount()
    {
        TB_SWPS_Document_Template_Account_Ids__c customSetting = new TB_SWPS_Document_Template_Account_Ids__c(TB_SS_Account__c=ACCOUNT_VDO_ID);
        insert customSetting;
        
        Test.startTest();
        Id templateId;
        templateId = TB_vu_PDFGeneratorController.getTemplateDocumentId(TEMPLATE_NAME_PARAM);
        Test.stopTest();
        
        System.assertEquals(null,templateId);
    }
    
    @IsTest
    static void testGetTemplateDocumentIdNothing()
    {
        Test.startTest();
        Id templateId;
        templateId = TB_vu_PDFGeneratorController.getTemplateDocumentId(TEMPLATE_NAME_PARAM);
        Test.stopTest();
        
        System.assertEquals(null,templateId);
    }
    
    @IsTest
    static void testSyncGeneration()
    {
        Case testCase = [SELECT Id, CaseNumber FROM Case LIMIT 1];
        ContentVersion template = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'Test Template'];
        
        TB_vu_PDFGeneratorController.PDFQueueableParams params = new TB_vu_PDFGeneratorController.PDFQueueableParams();
        params.templateId = template.Id;
        params.networkId = [SELECT Id FROM Network WHERE Name = 'Virtual University'].Id;
        params.objects = new List<TB_vu_PDFGeneratorController.PDFObjectWrapper>();
        TB_vu_PDFGeneratorController.PDFObjectWrapper wrapper = new TB_vu_PDFGeneratorController.PDFObjectWrapper();
        wrapper.recordId = testCase.Id;
        wrapper.linkToIds.add(testCase.Id);
        wrapper.isUpdate = true;
        wrapper.category = TB_vu_ApplicationPreviewController.APPLICATION_PDF_CATEGORY;
        wrapper.fileName = 'testname';
        params.objects.add(wrapper);
        
        Test.startTest();
        Id cvId = new TB_vu_PDFGeneratorController.PDFQueueable(params).executeSync();
        Test.stopTest();
        
        ContentVersion version = [SELECT Id, ContentDocumentId, Title, PathOnClient FROM ContentVersion WHERE Id = :cvId];
        System.assertEquals('testname',version.Title);
        System.assertEquals('testname.pdf',version.PathOnClient);
        List<ContentDocumentLink> links = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId = :version.ContentDocumentId];
        System.assertEquals(2,links.size());
        Boolean foundLink = false;
        for(ContentDocumentLink link : links)
        {
            if(link.LinkedEntityId == testCase.Id)
            {
                foundLink = true;
            }
        }
        System.assert(foundLink);
    }
}