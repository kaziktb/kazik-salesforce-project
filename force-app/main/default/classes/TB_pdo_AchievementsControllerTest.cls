/**
 * Created by kamilkwaczynski on 31/08/2022.
 */
@IsTest
public with sharing class TB_pdo_AchievementsControllerTest {
  private static final String POLICY_DOCUMENT_CATEGORY = 'Open_Access_Policy_Document_EN';
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
      'Test class policy file'
    );
    cv.TB_Category__c = POLICY_DOCUMENT_CATEGORY;
    update cv;

    TB_TestDataFactory.createContentDocumentLink(
      true,
      [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id]
      .ContentDocumentId,
      acc.Id
    );

    User user = TB_TestDataFactory.prepareUser();
    insert user;

    Contact con = new Contact();
    con.TB_User__c = user.Id;
    con.FirstName = 'TestCon';
    con.LastName = 'TestConLast';
    insert con;
    ////
    List<TB_PDO__c> pdos = new List<TB_PDO__c>();
    for (Integer i = 0; i < 5; i++) {
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

    TB_PDO__c pdoWithVorCorrection = new TB_PDO__c();
    pdoWithVorCorrection.TB_VoR_Correction_Source__c = pdos[0].Id;
    pdoWithVorCorrection.TB_VoR_Correction__c = true;

    insert pdoWithVorCorrection;

    TB_PDO_URLs__c urls = new TB_PDO_URLs__c();
    urls.TB_DSpace_Redirect_New_Article__c = 'test1';
    urls.TB_DSpace_Redirect_New_Artistic__c = 'test2';
    urls.TB_DSpace_Redirect_New_Science_Data__c = 'test5';
    urls.TB_DSpace_Redirect_New_Book__c = 'Test3';
    insert urls;

    TB_PDO_Participant__c participant = new TB_PDO_Participant__c();
    participant.TB_PDO__c = pdos[0].Id;
    participant.TB_Contact_Role__c = 'Co_Author';
    participant.TB_Bonus_Application_Share__c = 20;
    participant.TB_Contact__c = con.Id;
    insert participant;
  }

  @IsTest
  static void getMyAchievementFilterNotAllTest() {
    User usr = [SELECT Id FROM User WHERE Email = 'puser000@amamama.com'];
    Integer limitSize = 10;
    Integer offset = 0;
    String filterValue = 'Draft';

    List<TB_pdo_AchievementsController.AchievementWrapper> result = new List<TB_pdo_AchievementsController.AchievementWrapper>();

    List<TB_PDO__c> pdosExpected = [
      SELECT Id
      FROM TB_PDO__c
      WHERE
        TB_DSpace_Status__c = 'Draft'
        AND TB_x_Show_VoR_Source_on_Portal__c = TRUE
    ];

    Test.startTest();
    System.runAs(usr) {
      result = TB_pdo_AchievementsController.getMyAchievment(
        limitSize,
        offset,
        filterValue
      );
    }
    Test.stopTest();
    System.assertEquals(
      pdosExpected.size(),
      result.size(),
      'Should return the same size of pdos'
    );
  }

  @IsTest
  static void getMyAchievementWithFilterValueAllTest() {
    User usr = [SELECT Id FROM User WHERE Email = 'puser000@amamama.com'];
    Integer limitSize = 10;
    Integer offset = 0;
    String filterValue = 'All';

    List<TB_pdo_AchievementsController.AchievementWrapper> result = new List<TB_pdo_AchievementsController.AchievementWrapper>();

    List<TB_PDO__c> pdosExpected = [
      SELECT Id, TB_Active__c
      FROM TB_PDO__c
      WHERE TB_x_Show_VoR_Source_on_Portal__c = TRUE
    ];

    Test.startTest();
    System.runAs(usr) {
      result = TB_pdo_AchievementsController.getMyAchievment(
        limitSize,
        offset,
        filterValue
      );
    }
    Test.stopTest();
    System.assertEquals(
      pdosExpected.size(),
      result.size(),
      'Should return the same size of pdos'
    );
  }

  @IsTest
  static void getStatusesTest() {
    Schema.DescribeFieldResult field = TB_PDO__c.TB_DSpace_Status__c.getDescribe();

    List<TB_pdo_AchievementsController.StatusesWrapper> actualResult = new List<TB_pdo_AchievementsController.StatusesWrapper>();

    Test.startTest();
    actualResult = TB_pdo_AchievementsController.getMyUniqueStatus();
    Test.stopTest();

    System.assertEquals(
      field.getPicklistValues().size(),
      actualResult.size(),
      'Size should return 7'
    );
  }

  @IsTest
  static void getDSpaceUrlsTest() {
    TB_PDO_URLs__c expectedResult = [
      SELECT
        TB_DSpace_Redirect_New_Article__c,
        TB_DSpace_Redirect_New_Artistic__c,
        TB_DSpace_Redirect_New_Science_Data__c,
        TB_DSpace_Redirect_New_Book__c
      FROM TB_PDO_URLs__c
      LIMIT 1
    ];
    Test.startTest();
    String result = TB_pdo_AchievementsController.getDSpaceUrls();
    Test.stopTest();

    System.assertEquals(
      JSON.serialize(expectedResult, false),
      result,
      'Should return urls'
    );
  }

  @IsTest
  static void getAllAchievementDetailsTest() {
    User usr = [SELECT Id FROM User WHERE Email = 'puser000@amamama.com'];
    TB_pdo_AchievementsController.DataWrapper dwresult;
    TB_PDO__c pdo = [
      SELECT Id, Name
      FROM TB_PDO__c
      WHERE TB_Type__c = 'ReviewArticle'
      LIMIT 1
    ];
    Test.startTest();
    System.runAs(usr) {
      dwresult = TB_pdo_AchievementsController.getAchievementDetails(pdo.Id);
    }

    Test.stopTest();

    System.assertEquals(pdo.Name, dwresult.pdo.Name);
  }

  @IsTest
  static void getAllPDORecordTypesFromListSizeControllerTest() {
    Integer expectedRecordTypeSize = 5;
    Test.startTest();
    List<TB_pdo_AchievementsController.StatusesWrapper> listResult = TB_pdo_AchievementsController.getPDORecordTypes();
    Test.stopTest();

    System.assertEquals(expectedRecordTypeSize, listResult.size());
  }

  @IsTest
  static void getPicklistStatusesSizeFromPdoObject() {
    Integer expectedStatusesSize = 7;
    Test.startTest();
    List<TB_pdo_AchievementsController.StatusesWrapper> listResult = TB_pdo_AchievementsController.getObjectPicklistStatuses(
      'TB_PDO__c',
      'TB_PDO_Status__c'
    );
    Test.stopTest();
    System.assertEquals(expectedStatusesSize, listResult.size());
  }

  @IsTest
  static void getVorCorrectionWhereCorrectionSourceHavePdoId() {
    TB_PDO__c pdoIdWithVorCorrection = [
      SELECT Id, TB_VoR_Correction_Source__c
      FROM TB_PDO__c
      WHERE TB_VoR_Correction_Source__c != NULL
      LIMIT 1
    ];
    Test.startTest();
    List<TB_PDO__c> result = TB_pdo_AchievementsController.getVorCorrection(
      pdoIdWithVorCorrection.TB_VoR_Correction_Source__c
    );
    Test.stopTest();
    System.assertEquals(result[0].Id, pdoIdWithVorCorrection.Id);
  }

  @IsTest
  static void getParticipantsWhereHasPdo() {
    Integer expectedListSize = 1;
    Id pdoAssignedToParticipant = [
      SELECT TB_PDO__c
      FROM TB_PDO_Participant__c
      WHERE TB_PDO__c != NULL
      LIMIT 1
    ]
    .TB_PDO__c;
    Test.startTest();
    String result = TB_pdo_AchievementsController.getParticipants(
      pdoAssignedToParticipant
    );
    Test.stopTest();
    List<TB_PDO_Participant__c> deserializedResult = (List<TB_PDO_Participant__c>) JSON.deserialize(
      result,
      List<TB_PDO_Participant__c>.class
    );
    System.assertEquals(expectedListSize, deserializedResult.size());
  }

  @IsTest
  static void getPolicyFileContentHtmlFromPdf() {
    User usr = [
      SELECT Id
      FROM User
      WHERE Email = 'puser000@amamama.com'
      LIMIT 1
    ];
    String expectedString = 'Test class policy file';
    String result;
    Test.startTest();
    System.runAs(usr) {
      result = TB_pdo_AchievementsController.getPolicyFileContent();
    }
    Test.stopTest();
    System.assertEquals(expectedString, result);
  }
}