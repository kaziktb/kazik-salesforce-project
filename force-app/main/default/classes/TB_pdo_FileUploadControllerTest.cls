@IsTest
private class TB_pdo_FileUploadControllerTest {
  private static final String CONTENT_VERSION_ASF_CATEGORY = 'Affiliate_Statement_File';

  @TestSetup
  static void testSetup() {
    TB_PDO__c pdo = new TB_PDO__c();
    pdo.TB_Type__c = 'ReviewArticle';
    pdo.TB_DSpace_Reference_Id__c = 'test';
    insert pdo;

    Contact con = new Contact();
    con.LastName = 'Testowy';
    insert con;

    TB_Affiliate_Statement__c affiliateStatement = new TB_Affiliate_Statement__c();
    affiliateStatement.TB_PDO__c = pdo.Id;
    affiliateStatement.TB_Contact__c = con.Id;
    insert affiliateStatement;

    Account acc = new Account();
    acc.Name = 'Testowy acc';
    acc.TB_Email__c = 'TBemail@email.pl';
    insert acc;

    Account acc2 = new Account();
    acc2.Name = 'Testowy acc';
    acc2.TB_Email__c = 'er@email.pl';
    insert acc2;

    ContentVersion content = TB_TestDataFactory.createContentVersion(
      false,
      'test content',
      '/testPath',
      'testVersion'
    );

    content.TB_Category__c = CONTENT_VERSION_ASF_CATEGORY;
    insert content;

    ContentDocumentLink contentDocumentLink = TB_TestDataFactory.createContentDocumentLink(
      true,
      [SELECT ContentDocumentId FROM contentversion WHERE Id = :content.Id]
      .ContentDocumentId,
      acc.Id
    );
  }

  @isTest
  static void shouldReturnIdWithoutPassedContentVersionId() {
    Id recordId = [SELECT Id FROM TB_Affiliate_Statement__c LIMIT 1].Id;
    String result;

    Test.startTest();
    result = TB_pdo_FileUploadController.uploadChunkedFile(
      recordId,
      'test file name',
      'test file content',
      ''
    );
    Test.stopTest();

    System.assert(result.length() > 0, 'Returned string cannot be blank');
  }
  @isTest
  static void shouldReturnErrorWhenThereIsNotAffiliateStatementAsRecordId() {
    Id recordId = [
      SELECT Id
      FROM Account
      WHERE TB_Email__c LIKE 'TBemail@email%'
    ]
    .Id;
    Boolean hasError = false;
    Test.startTest();
    try {
      TB_pdo_FileUploadController.uploadChunkedFile(
        recordId,
        'test file name',
        'test file content',
        ''
      );
    } catch (Exception e) {
      hasError = true;
    }
    Test.stopTest();
    System.assertEquals(true, hasError);
  }

  @isTest
  static void shouldReturnIdWithPassedContentVersionId() {
    Id recordId = [
      SELECT Id
      FROM Account
      WHERE TB_Email__c LIKE 'TBemail@email%'
    ]
    .Id;
    Id contentVersionId = [
      SELECT Id
      FROM ContentVersion
      WHERE Title LIKE 'test content'
    ]
    .Id;
    String result;

    Test.startTest();
    result = TB_pdo_FileUploadController.uploadChunkedFile(
      recordId,
      'test file name',
      'test file content',
      contentVersionId
    );
    Test.stopTest();

    System.assert(result.length() > 0, 'Returned string cannot be blank');
  }

  @isTest
  static void shouldReturnRegulations() {
    Id recordId = [
      SELECT Id
      FROM Account
      WHERE TB_Email__c LIKE 'TBemail@email%'
    ]
    .Id;
    String result;

    Test.startTest();
    result = TB_pdo_FileUploadController.getRegulationsFileByAccountId(
      recordId
    );
    Test.stopTest();

    System.assert(result.length() > 0, 'Returned string cannot be blank');
  }

  @isTest
  static void shouldDeleteFile() {
    Id recordId = [
      SELECT Id
      FROM Account
      WHERE TB_Email__c LIKE 'TBemail@email%'
    ]
    .Id;

    Test.startTest();
    TB_pdo_FileUploadController.deleteFile(recordId);
    Test.stopTest();

    System.assert(
      [
        SELECT ContentDocumentId
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :recordId
      ]
      .size() == 0,
      'Query should not return any record'
    );
  }
  @isTest
  static void shouldReturnErrorAfterTryDeleteFile() {
    Id recordId = [SELECT Id FROM Account WHERE TB_Email__c LIKE 'er@email.pl']
    .Id;

    Boolean hasError = false;
    Test.startTest();
    try {
      TB_pdo_FileUploadController.deleteFile(recordId);
    } catch (Exception e) {
      hasError = true;
    }

    Test.stopTest();
    System.assertEquals(true, hasError);
  }
}