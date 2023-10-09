@IsTest
public with sharing class TB_pdo_AffiliateStatementControllerTest {
  @TestSetup
  static void prepareData() {
    User user = TB_TestDataFactory.prepareUser();
    insert user;

    Contact con = new Contact();
    con.TB_User__c = user.Id;
    con.FirstName = 'TestCon';
    con.LastName = 'TestConLast';
    insert con;
    //////
    List<TB_PDO__c> pdos = new List<TB_PDO__c>();
    for (Integer i = 0; i < 2; i++) {
      TB_PDO__c pdo = new TB_PDO__c();
      pdo.TB_Type__c = 'ReviewArticle';
      pdo.TB_Depositor__c = con.Id;
      pdo.CreatedById = user.Id;
      pdo.TB_PDO_Status__c = 'Corrected';
      pdo.TB_Title_Original__c = 'TestowyTitle';
      pdo.TB_DSpace_Status__c = 'Draft';
      pdos.add(pdo);
    }
    insert pdos;

    TB_Affiliate_Statement__c affiliate = new TB_Affiliate_Statement__c();
    affiliate.TB_PDO__c = pdos[0].Id;
    affiliate.TB_Contact__c = con.Id;
    affiliate.TB_Status__c = 'New';
    affiliate.TB_PBN_Affiliation__c = 'językoznawstwo';
    insert affiliate;

    TB_PDO_Participant__c participant = new TB_PDO_Participant__c();
    participant.TB_PDO__c = pdos[0].Id;
    participant.TB_Contact__c = con.Id;
    participant.TB_Bonus_Application_Share__c = 20;
    participant.TB_Affiliate_Statement__c = affiliate.Id;
    insert participant;

    ContentVersion cv = TB_TestDataFactory.createContentVersion(
      true,
      'TestowyTytul',
      '/test.pdf',
      'test file artistic'
    );
    cv.TB_Category__c = 'Affiliate_Statement_Template_Participant';
    update cv;

    TB_TestDataFactory.createContentDocumentLink(
      true,
      [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id]
      .ContentDocumentId,
      affiliate.Id
    );
  }

  @isTest
  static void shouldReturnAllHavingAffiliatesWithLimit10() {
    Integer limitSize = 10;
    Integer offset = 0;
    String filter = 'All';
    User usr = [
      SELECT Id
      FROM User
      WHERE Email = 'puser000@amamama.com'
      LIMIT 1
    ];
    List<TB_Affiliate_Statement__c> result = new List<TB_Affiliate_Statement__c>();
    List<TB_Affiliate_Statement__c> expectedAffiliatesSize = [
      SELECT Id
      FROM TB_Affiliate_Statement__c
      WHERE TB_PDO__c != NULL
      ORDER BY CreatedDate DESC
      LIMIT :limitSize
      OFFSET :offset
    ];
    Test.startTest();
    System.runAs(usr) {
      result = TB_pdo_AffiliateStatementController.getAffiliates(
        limitSize,
        offset,
        filter
      );
    }

    Test.stopTest();
    System.assertEquals(expectedAffiliatesSize.size(), result.size());
  }

  @IsTest
  static void getAffiliateStatementTest() {
    User usr = [SELECT Id FROM User WHERE Email = 'puser000@amamama.com'];
    TB_PDO__c pdoId = [
      SELECT Id
      FROM TB_PDO__c
      WHERE TB_PDO_Status__c = 'Corrected'
      LIMIT 1
    ];
    TB_Affiliate_Statement__c expectedAffiliate = [
      SELECT Id, TB_Status__c, TB_PBN_Affiliation__c, TB_DAN_Comment__c
      FROM TB_Affiliate_Statement__c
      LIMIT 1
    ];
    String result;
    System.runAs(usr) {
      Test.startTest();
      result = TB_pdo_AffiliateStatementController.getAffiliation(pdoId.Id);
      Test.stopTest();
    }

    TB_Affiliate_Statement__c resDeserialized = (TB_Affiliate_Statement__c)JSON.deserialize(result, TB_Affiliate_Statement__c.class);

    System.assertEquals(
      expectedAffiliate.Id,
      resDeserialized.Id
    );
  }
  @IsTest
  static void updateAffiliateStatementStatusTest() {
    TB_Affiliate_Statement__c affiliateStatement = [
      SELECT Id
      FROM TB_Affiliate_Statement__c
      LIMIT 1
    ];

    String statusNew = 'New';
    String newDiscipline = 'psychologia';

    Test.startTest();
    TB_pdo_AffiliateStatementController.updateAffiliateStatementStatus(
      affiliateStatement.Id,
            newDiscipline
    );
    Test.stopTest();
    TB_Affiliate_Statement__c affiliateStatementAfterUpdate = [
      SELECT Id, TB_Status__c
      FROM TB_Affiliate_Statement__c
      LIMIT 1
    ];
    System.assertEquals(statusNew, affiliateStatementAfterUpdate.TB_Status__c);
  }
  @IsTest
  static void getAllNecessaryDetailsDataTest() {
    TB_Affiliate_Statement__c affiliate = [
      SELECT Id
      FROM TB_Affiliate_Statement__c
      LIMIT 1
    ];

    Test.startTest();
    String result = TB_pdo_AffiliateStatementController.getAffiliationDetails(
      affiliate.Id
    );
    TB_Affiliate_Statement__c deserialized = (TB_Affiliate_Statement__c) JSON.deserialize(
      result,
      TB_Affiliate_Statement__c.class
    );
    Test.stopTest();
    System.assertEquals(affiliate.Id, deserialized.Id);
  }
  @IsTest
  static void getAffiliationStatementFileTest() {
    TB_Affiliate_Statement__c affiliate = [
      SELECT Id
      FROM TB_Affiliate_Statement__c
      LIMIT 1
    ];
    ContentDocumentLink fileLink = [
      SELECT ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :affiliate.Id
    ];
    ContentVersion doc = [
      SELECT ContentDocumentId, Title
      FROM ContentVersion
      WHERE ContentDocumentId = :fileLink.ContentDocumentId
    ];

    Map<Id, String> expectedMapIdTitle = new Map<Id, String>();
    expectedMapIdTitle.put(doc.ContentDocumentId, doc.Title);

    Test.startTest();
    String result = TB_pdo_AffiliateStatementController.getAffiliationStatementFile(
      affiliate.Id
    );
    Test.stopTest();

    System.assertEquals(JSON.serialize(expectedMapIdTitle), result);
  }
}