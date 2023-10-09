@isTest
public class TB_ClinicalExperienceMATest {
  public static List<Id> insertExperienceHelper() {
    List<Id> experienceIds = new List<Id>();
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

    TB_Experience_History__c currentExperience = new TB_Experience_History__c();
    currentExperience.TB_Workplace__c = 'Other';
    currentExperience.TB_Work_Type__c = 'Work';
    currentExperience.TB_Name__c = 'Test';
    currentExperience.TB_Start_Date__c = Date.valueOf('2012-09-09');
    currentExperience.TB_End_Date__c = Date.valueOf('2014-03-12');
    currentExperience.TB_Hours__c = 80.0;
    currentExperience.TB_Applicant__c = applicantId;
    currentExperience.TB_Application__c = applicationId;
    currentExperience.RecordTypeId = Schema.SObjectType.TB_Experience_History__c
      .getRecordTypeInfosByDeveloperName()
      .get('TB_Clinical_Experience_Prior_MA')
      .getRecordTypeId();
    insert currentExperience;
    experienceIds.add(currentExperience.id);
    experienceIds.add(applicantId);
    experienceIds.add(applicationId);
    return experienceIds;
  }

  @isTest
  public static void getWorkplaceTypesTest() {
    TB_Experience_History__c currentExperience = new TB_Experience_History__c();
    test.startTest();
    Map<String, String> workplaceTypes = TB_ClinicalExperienceMAController.getWorkplaceTypes();
    test.stopTest();
    System.assertNotEquals(0, workplaceTypes.size());
  }

  @isTest
  public static void getWorkTypesTest() {
    TB_Experience_History__c currentWorkplace = new TB_Experience_History__c();
    test.startTest();
    Map<String, String> workplaceTypes = TB_ClinicalExperienceMAController.getWorkplaceTypes();
    test.stopTest();
    System.assertNotEquals(0, workplaceTypes.size());
  }
  @isTest
  public static void getExperiencesTest() {
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
      List<Id> experienceIds = insertExperienceHelper();
      test.startTest();
      List<TB_Experience_History__c> experiences = TB_ClinicalExperienceMAController.getexperiences(
        experienceIds[1],
        experienceIds[2],
        'TB_Clinical_Experience_Prior_MA'
      );
      test.stopTest();
      System.assertNotEquals(0, experiences.size());
    }
  }
  @isTest
  public static void addExperienceTest() {
    List<Id> experienceIds = insertExperienceHelper();
    test.startTest();
    TB_ClinicalExperienceMAController.addExperience(
      'Other',
      'Work',
      'Test',
      Date.valueOf('2012-09-09'),
      Date.valueOf('2012-09-09'),
      80.0,
      experienceIds[1],
      experienceIds[2],
      'TB_Clinical_Experience_Prior_MA'
    );
    test.stopTest();
    List<TB_Experience_History__c> experiences = [
      SELECT Id
      FROM TB_Experience_History__c
      WHERE TB_application__c = :experienceIds[2]
    ];
    System.assertEquals(2, experiences.size());
  }
  @isTest
  public static void updateExperienceTest() {
    List<Id> experienceIds = insertExperienceHelper();
    test.startTest();
    TB_ClinicalExperienceMAController.updateExperience(
      experienceIds[0],
      'Other',
      'Work',
      'Test',
      Date.valueOf('2012-09-09'),
      Date.valueOf('2012-09-09'),
      120.0
    );
    test.stopTest();
    TB_Experience_History__c experience = [
      SELECT Id, TB_Workplace__c, TB_Hours__c
      FROM TB_Experience_History__c
      WHERE Id = :experienceIds[0]
    ];
    System.assertEquals(120.0, experience.TB_Hours__c);
  }
  @isTest
  public static void deleteExperienceTest() {
    List<Id> experienceIds = insertExperienceHelper();
    test.startTest();
    TB_ClinicalExperienceMAController.deleteExperience(experienceIds[0]);
    test.stopTest();
    List<TB_Experience_History__c> experiences = [
      SELECT Id
      FROM TB_Experience_History__c
      WHERE Id = :experienceIds[0]
    ];
    System.assertEquals(0, experiences.size());
  }
}