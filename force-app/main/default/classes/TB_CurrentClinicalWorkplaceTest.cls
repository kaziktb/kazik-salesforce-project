@isTest
private without sharing class TB_CurrentClinicalWorkplaceTest {
  public static List<Id> insertWorkplaceHelper() {
    List<Id> workplaceIds = new List<Id>();
    Contact tempContact = new Contact();
    tempContact.LastName = 'Test';
    insert tempContact;
    String applicantId = tempContact.id;

    TB_Offered_Product__c offeredProduct = new TB_Offered_Product__c();
    offeredProduct.Name = 'Test product';
    insert offeredProduct;

    hed__Application__c application = new hed__Application__c();
    application.hed__Applicant__c = applicantId;
    application.TB_Applying_To_Offered_Product__c = offeredProduct.id;
    insert application;
    String applicationId = application.id;

    TB_Experience_History__c currentWorkplace = new TB_Experience_History__c();
    currentWorkplace.TB_Workplace__c = 'Other';
    currentWorkplace.TB_Name__c = 'Test';
    currentWorkplace.TB_Hours_Weekly__c = 80.0;
    currentWorkplace.TB_Applicant__c = applicantId;
    currentWorkplace.TB_Application__c = applicationId;
    currentWorkplace.RecordTypeId = Schema.SObjectType.TB_Experience_History__c
      .getRecordTypeInfosByDeveloperName()
      .get('TB_Current_Workplace')
      .getRecordTypeId();
    insert currentWorkplace;
    workplaceIds.add(currentWorkplace.id);
    workplaceIds.add(applicantId);
    workplaceIds.add(applicationId);
    return workplaceIds;
  }

  @isTest
  public static void getWorkplaceTypesTest() {
    TB_Experience_History__c currentWorkplace = new TB_Experience_History__c();
    test.startTest();
    Map<String, String> workplaceTypes = TB_CurrentClinicalWorkplaceController.getWorkplaceTypes();
    test.stopTest();
    System.assertNotEquals(0, workplaceTypes.size());
  }

  @isTest
  public static void getWorkplacesTest() {
    Profile adminProfile = [
      SELECT Id
      FROM Profile
      WHERE Name = 'System Administrator'
    ];
    List<User> adminUsers = [
      SELECT Id
      FROM User
      WHERE ProfileId = :adminProfile.id AND IsActive = TRUE
    ];

    System.runAs(adminUsers[0]) {
      List<Id> workplaceIds = insertWorkplaceHelper();
      test.startTest();
      List<TB_Experience_History__c> workplaces = TB_CurrentClinicalWorkplaceController.getWorkplaces(
        workplaceIds[1],
        workplaceIds[2]
      );
      test.stopTest();
      System.assertNotEquals(0, workplaces.size());
    }
  }
  @isTest
  public static void addWorkplaceTest() {
    List<Id> workplaceIds = insertWorkplaceHelper();
    test.startTest();
    TB_CurrentClinicalWorkplaceController.addWorkplace(
      'Other',
      'Test',
      80.0,
      workplaceIds[1],
      workplaceIds[2]
    );
    test.stopTest();
    List<TB_Experience_History__c> workplaces = [
      SELECT Id
      FROM TB_Experience_History__c
      WHERE TB_application__c = :workplaceIds[2]
    ];
    System.assertEquals(2, workplaces.size());
  }
  @isTest
  public static void updateWorkplaceTest() {
    List<Id> workplaceIds = insertWorkplaceHelper();
    test.startTest();
    TB_CurrentClinicalWorkplaceController.updateWorkplace(
      workplaceIds[0],
      'other',
      'Test',
      120.0
    );
    test.stopTest();
    TB_Experience_History__c workplace = [
      SELECT Id, TB_Workplace__c, TB_Hours_Weekly__c
      FROM TB_Experience_History__c
      WHERE Id = :workplaceIds[0]
    ];
    System.assertEquals(120.0, workplace.TB_Hours_Weekly__c);
  }
  @isTest
  public static void deleteWorkplaceTest() {
    List<Id> workplaceIds = insertWorkplaceHelper();
    test.startTest();
    TB_CurrentClinicalWorkplaceController.deleteWorkplace(workplaceIds[0]);
    test.stopTest();
    List<TB_Experience_History__c> workplaces = [
      SELECT Id
      FROM TB_Experience_History__c
      WHERE Id = :workplaceIds[0]
    ];
    System.assertEquals(0, workplaces.size());
  }
}