/**
 * Created by kamilkwaczynski on 17/08/2022.
 */
@IsTest
public with sharing class TB_pdo_PdfGeneratorControllerTest {
  private static final String ARTISTIC_ACHIEVEMENT_FILE_TEMPLATE_CATEGORY = 'Affiliate_Statement_Template_Artistic';
  private static final String SCIENCE_ACHIEVEMENT_FILE_TEMPLATE_CATEGORY = 'Affiliate_Statement_Template_Science';
  private static final String AFFILIATE_STATEMENT_TEMPLATE_PARTICIPANT = 'Affiliate_Statement_Template_Participant';
  @TestSetup
  static void prepareData() {
    TB_SWPS_Document_Template_Account_Ids__c accTemplate = new TB_SWPS_Document_Template_Account_Ids__c();
    accTemplate.TB_PDO_Account__c = 'Test';
    insert accTemplate;
    String templateId = [
      SELECT TB_PDO_Account__c
      FROM TB_SWPS_Document_Template_Account_Ids__c
    ]
    .TB_PDO_Account__c;
    Account acc = new Account();
    acc.DT_VDO_ID__c = templateId;
    acc.Name = 'Testowy acc';
    insert acc;

    ContentVersion cv = TB_TestDataFactory.createContentVersion(
      true,
      'TestowyTytul',
      '/test.pdf',
      'test file artistic'
    );
    cv.TB_Category__c = SCIENCE_ACHIEVEMENT_FILE_TEMPLATE_CATEGORY;
    update cv;

    TB_TestDataFactory.createContentDocumentLink(
      true,
      [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id]
      .ContentDocumentId,
      acc.Id
    );
  }
  @IsTest
  static void generatePdfMethodTest() {
    List<ContentVersion> lstBeforeUpdate = [SELECT Id FROM ContentVersion];
    Contact con = new Contact();
    con.LastName = 'TestTestowy';
    insert con;
    TB_PDO__c pdoTest = new TB_PDO__c();
    pdoTest.TB_Type__c = 'ReviewArticle';
    pdoTest.TB_Author__c = con.Id;
    pdoTest.TB_Title_Original__c = 'SuperTestowyTytul';
    insert pdoTest;

    TB_Affiliate_Statement__c affiliateStatementTest = new TB_Affiliate_Statement__c();
    affiliateStatementTest.TB_PBN_Affiliation__c = 'psychologia';
    affiliateStatementTest.TB_PDO__c = pdoTest.Id;
    affiliateStatementTest.TB_Contact__c = con.Id;
    affiliateStatementTest.TB_Status__c = 'New';
    insert affiliateStatementTest;

    Test.startTest();
    affiliateStatementTest.TB_Status__c = 'To_Signature';
    update affiliateStatementTest;

    Test.stopTest();
    List<ContentVersion> lstAfterUpdate = [
      SELECT Id
      FROM ContentVersion
      WHERE TB_Category__c = :AFFILIATE_STATEMENT_TEMPLATE_PARTICIPANT
    ];

    System.assertEquals(
      1,
      lstAfterUpdate.size(),
      'List after update should be 1'
    );
  }
}