@IsTest
private class TB_pdo_PopularisationControllerTest {
  @testSetup
  static void setupTestData() {
    TB_PDO_Automation_Disable__c setting = new TB_PDO_Automation_Disable__c(
      TB_Disable__c = true
    );
    insert setting;
  }
  @isTest
  private static void testGetPopularisationDetails() {
    TB_PDO__c pdo = new TB_PDO__c(
      TB_Repository_Link__c = 'https://test.com',
      TB_Title_Original__c = 'Test PDO'
    );

    insert pdo;
    TB_PDO_Popularisation__c popularisation = new TB_PDO_Popularisation__c(
      TB_PDO__c = pdo.Id,
      TB_Coordinator_Comment__c = 'Test Coordinator Comment',
      TB_Press_Centre_Marketing_Comment__c = 'Test Marketing Comment',
      TB_Send_to_Coordinator_Decision__c = 'Yes',
      TB_Status__c = 'New',
      TB_Stage__c = 'Submitted_for_Marketing_Decision'
    );
    insert popularisation;

    Test.startTest();
    TB_pdo_PopularisationController.PopularisationWrapper result = TB_pdo_PopularisationController.getPopularisationDetails(
      popularisation.Id
    );
    Test.stopTest();

    System.assertEquals(popularisation.Id, result.popularisation.Id);
    System.assertEquals(
      pdo.TB_Repository_Link__c,
      result.popularisation.TB_PDO__r.TB_Repository_Link__c
    );
    System.assertEquals(
      pdo.TB_Title_Original__c,
      result.popularisation.TB_PDO__r.TB_Title_Original__c
    );
    System.assertEquals(
      'Test Coordinator Comment',
      result.popularisation.TB_Coordinator_Comment__c
    );
    System.assertEquals(
      'Test Marketing Comment',
      result.popularisation.TB_Press_Centre_Marketing_Comment__c
    );
    System.assertEquals(
      'Yes',
      result.popularisation.TB_Send_to_Coordinator_Decision__c
    );
    System.assertEquals('New', result.popularisation.TB_Status__c);
    System.assertEquals(
      'Submitted_for_Marketing_Decision',
      result.popularisation.TB_Stage__c
    );
    System.assertEquals(2, result.statusesOfDecisions.size());
  }

  @isTest
  static void testUpdatePopularisationSendToCoordinatorDecision() {
    TB_PDO_Popularisation__c popularisation = new TB_PDO_Popularisation__c();
    popularisation.Name = 'Test Popularisation';
    popularisation.TB_Send_to_Coordinator_Decision__c = 'Yes';
    insert popularisation;

    String jsonData = JSON.serialize(popularisation);

    Test.startTest();
    TB_PDO_Popularisation__c updatedPopularisation = TB_pdo_PopularisationController.updatePopularisation(
      jsonData
    );
    Test.stopTest();

    System.assertEquals(
      'Yes',
      updatedPopularisation.TB_Send_to_Coordinator_Decision__c
    );
    System.assertEquals(
      UserInfo.getName(),
      updatedPopularisation.TB_Action_Contact_Coordinator_Decision__c
    );
    System.assertNotEquals(
      null,
      updatedPopularisation.TB_Action_Date_Time_Marketing_Decision__c
    );
  }

  @isTest
  static void testUpdatePopularisationCoordinatorDecision() {
    TB_PDO_Popularisation__c popularisation = new TB_PDO_Popularisation__c();
    popularisation.Name = 'Test Popularisation';
    popularisation.TB_Coordinator_Decision__c = 'Yes';
    insert popularisation;

    String jsonData = JSON.serialize(popularisation);

    Test.startTest();
    TB_PDO_Popularisation__c updatedPopularisation = TB_pdo_PopularisationController.updatePopularisation(
      jsonData
    );
    Test.stopTest();

    System.assertEquals(
      'Yes',
      updatedPopularisation.TB_Coordinator_Decision__c
    );
    System.assertEquals(
      UserInfo.getName(),
      updatedPopularisation.TB_Action_Contact_Coordinator_Decision__c
    );
    System.assertNotEquals(
      null,
      updatedPopularisation.TB_Action_Date_Time_Coordinator_Decision__c
    );
  }

  @isTest
  static void testUpdatePopularisationSendSurveyToDepositor() {
    TB_PDO_Popularisation__c popularisation = new TB_PDO_Popularisation__c();
    popularisation.Name = 'Test Popularisation';
    popularisation.TB_Send_Survey_to_Depositor_Decision__c = 'Yes';
    insert popularisation;

    String jsonData = JSON.serialize(popularisation);

    Test.startTest();
    TB_PDO_Popularisation__c updatedPopularisation = TB_pdo_PopularisationController.updatePopularisation(
      jsonData
    );
    Test.stopTest();

    System.assertEquals(
      'Yes',
      updatedPopularisation.TB_Send_Survey_to_Depositor_Decision__c
    );
    System.assertEquals(
      UserInfo.getName(),
      updatedPopularisation.TB_Action_Contact_Send_Survey_Decision__c
    );
    System.assertNotEquals(
      null,
      updatedPopularisation.TB_Action_Date_Time_Send_Survey_Decision__c
    );
  }
}