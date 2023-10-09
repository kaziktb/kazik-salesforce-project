/**
 * Created by kamilkwaczynski on 17/08/2022.
 */
@isTest
public with sharing class TB_pdo_PdfGeneratorTest {
  public static final String TEST_HTML =
    '<html xmlns:v="urn:schemas-microsoft-com:vml"\n' +
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

  public static final String CLEAN_BODY =
    '<div>\n' +
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
    '  <p>Numer Systemowy podania: ${<span>Case.CaseNumber</span>}</p>\n' +
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
    '  <p>${<span>Case.Contact.DT_Hourly_Rate_Consultant__c</span>}</p>\n' +
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
    '  <p>${<span>Case.Contact.DT_Contact_Type__c</span>}</p>\n' +
    '  </td>\n' +
    '</tr>\n' +
    '</tr>\n' +
    ' <tr style=\'mso-yfti-irow:0;mso-yfti-firstrow:yes\'>\n' +
    '  <td>\n' +
    '  <p>${<span>Case.CaseComments:comment(IsPublished = TRUE)</span></p>\n' +
    '  <p>$comment.CommentBody</p>\n' +
    '  <p>$comment.IsPublished</p>\n' +
    '  <p>:}</p>\n' +
    '  </td>\n' +
    '</tr>\n' +
    '</table>\n' +
    '</div>';

  public static final String RESULT_HTML =
    '<div>\n' +
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
    '  <p><span></span></p>\n' +
    '  <p>Test 1</p>\n' +
    '  <p>Yes</p>\n' +
    '  <p><span></span></p>\n' +
    '  <p>Test 2</p>\n' +
    '  <p>Yes</p>\n' +
    '  <p></p>\n' +
    '  </td>\n' +
    '</tr>\n' +
    '</table>\n' +
    '</div>';

  public static final String RESULT_HTML_NO_CHILDREN =
    '<div>\n' +
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
    '  </td>\n' +
    '</tr>\n' +
    '</table>\n' +
    '</div>';

  @IsTest
  static void testGetCleanHtmlBody() {
    String cleanHtml = TB_pdo_PdfGenerator.getCleanHtmlBody(TEST_HTML);
    System.assertEquals(CLEAN_BODY, cleanHtml);
  }

  @IsTest
  static void testController() {
    ContentVersion template = new ContentVersion(
      Title = 'Test Template',
      PathOnClient = 'testTemplate',
      VersionData = Blob.valueOf(TEST_HTML)
    );
    insert template;
    Account account = new Account(Name = 'Test Account');
    insert account;
    Contact contact = new Contact(
      LastName = 'Kowalski',
      Birthdate = Date.newInstance(1997, 2, 21),
      DT_Hourly_Rate_Consultant__c = 3.14,
      DT_Contact_Type__c = 'Student',
      AccountId = account.Id
    );
    insert contact;
    Case testCase = new Case(
      Subject = 'Test',
      Status = 'New',
      ContactId = contact.Id
    );
    insert testCase;
    List<CaseComment> comments = new List<CaseComment>();
    comments.add(
      new CaseComment(
        ParentId = testCase.Id,
        CommentBody = 'Test 1',
        IsPublished = true
      )
    );
    comments.add(
      new CaseComment(
        ParentId = testCase.Id,
        CommentBody = 'Test 2',
        IsPublished = true
      )
    );
    comments.add(
      new CaseComment(ParentId = testCase.Id, CommentBody = 'Test 3')
    );
    insert comments;

    PageReference pdfGeneratorPage = Page.TB_pdo_PdfGenerator;
    Test.setCurrentPage(pdfGeneratorPage);
    ApexPages.currentPage()
      .getParameters()
      .put('recordIds', template.Id + ',' + testCase.Id);
    ApexPages.currentPage()
      .getParameters()
      .put('replacements', '{"CustomMergeField":"Custom Merge Field Value"}');

    Case dbCase = [SELECT CaseNumber FROM Case WHERE Id = :testCase.Id];
    TB_pdo_PdfGenerator controller = new TB_pdo_PdfGenerator();
    System.assertEquals(
      RESULT_HTML.replace('${<span>Case.CaseNumber</span>}', dbCase.CaseNumber),
      controller.htmlValue
    );
  }

  @IsTest
  static void testControllerNoChildren() {
    ContentVersion template = new ContentVersion(
      Title = 'Test Template',
      PathOnClient = 'testTemplate',
      VersionData = Blob.valueOf(TEST_HTML)
    );
    insert template;
    Account account = new Account(Name = 'Test Account');
    insert account;
    Contact contact = new Contact(
      LastName = 'Kowalski',
      Birthdate = Date.newInstance(1997, 2, 21),
      DT_Hourly_Rate_Consultant__c = 3.14,
      DT_Contact_Type__c = 'Student',
      AccountId = account.Id
    );
    insert contact;
    Case testCase = new Case(
      Subject = 'Test',
      Status = 'New',
      ContactId = contact.Id
    );
    insert testCase;

    PageReference pdfGeneratorPage = Page.TB_pdo_PdfGenerator;
    Test.setCurrentPage(pdfGeneratorPage);
    ApexPages.currentPage()
      .getParameters()
      .put('recordIds', template.Id + ',' + testCase.Id);
    ApexPages.currentPage()
      .getParameters()
      .put('replacements', '{"CustomMergeField":"Custom Merge Field Value"}');

    Case dbCase = [SELECT CaseNumber FROM Case WHERE Id = :testCase.Id];
    TB_pdo_PdfGenerator controller = new TB_pdo_PdfGenerator();
    System.assertEquals(
      RESULT_HTML_NO_CHILDREN.replace(
        '${<span>Case.CaseNumber</span>}',
        dbCase.CaseNumber
      ),
      controller.htmlValue
    );
  }

  @IsTest
  static void testControllerNoTemplate() {
    Contact contact = new Contact(LastName = 'Kowalski');
    insert contact;
    Case testCase = new Case(
      Subject = 'Test',
      Status = 'New',
      ContactId = contact.Id
    );
    insert testCase;

    PageReference pdfGeneratorPage = Page.TB_pdo_PdfGenerator;
    Test.setCurrentPage(pdfGeneratorPage);
    ApexPages.currentPage()
      .getParameters()
      .put('recordIds', '0681l000002AO5dAAG,' + testCase.Id);

    TB_pdo_PdfGenerator controller = new TB_pdo_PdfGenerator();
    System.assertEquals(
      '<p>Template not found! Couldn\'t find a template with this ID: 0681l000002AO5dAAG</p>',
      controller.htmlValue
    );
  }

  @IsTest
  static void testControllerNoTemplateID() {
    Contact contact = new Contact(LastName = 'Kowalski');
    insert contact;
    Case testCase = new Case(
      Subject = 'Test',
      Status = 'New',
      ContactId = contact.Id
    );
    insert testCase;

    PageReference pdfGeneratorPage = Page.TB_pdo_PdfGenerator;
    Test.setCurrentPage(pdfGeneratorPage);
    ApexPages.currentPage().getParameters().put('recordIds', testCase.Id);

    TB_pdo_PdfGenerator controller = new TB_pdo_PdfGenerator();
    System.assertEquals(
      '<p>Template not found! The template ID was not provided</p>',
      controller.htmlValue
    );
  }
}