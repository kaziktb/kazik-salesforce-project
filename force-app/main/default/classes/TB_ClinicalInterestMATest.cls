@isTest
public class TB_ClinicalInterestMATest {
  public static List<Id> insertInterestHelper() {
    List<Id> interestIds = new List<Id>();
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

    TB_Experience_History__c currentInterest = new TB_Experience_History__c();
    currentInterest.TB_Interest_Type__c = 'conference';
    currentInterest.TB_Name__c = 'Test';
    currentInterest.TB_Start_Date__c = Date.valueOf('2012-09-09');
    currentInterest.TB_End_Date__c = Date.valueOf('2014-03-12');
    currentInterest.TB_Hours__c = 80.0;
    currentInterest.TB_Applicant__c = applicantId;
    currentInterest.TB_Application__c = applicationId;
    currentInterest.RecordTypeId = Schema.SObjectType.TB_Experience_History__c
      .getRecordTypeInfosByDeveloperName()
      .get('TB_Clinical_Interest_Prior_MA')
      .getRecordTypeId();
    insert currentInterest;
    interestIds.add(currentInterest.id);
    interestIds.add(applicantId);
    interestIds.add(applicationId);
    return interestIds;
  }

  @isTest
  public static void getInterestTypesTest() {
    TB_Experience_History__c currentInterest = new TB_Experience_History__c();
    test.startTest();
    Map<String, String> interestTypes = TB_ClinicalInterestMAController.getInterestTypes();
    test.stopTest();
    System.assertNotEquals(0, interestTypes.size());
  }

  @isTest
  public static void getInterestsTest() {
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
      List<Id> interestIds = insertInterestHelper();
      test.startTest();
      List<TB_Experience_History__c> interests = TB_ClinicalInterestMAController.getinterests(
        interestIds[1],
        interestIds[2],
        'TB_Clinical_Interest_Prior_MA'
      );
      test.stopTest();
      System.assertNotEquals(0, interests.size());
    }
  }
  @isTest
  public static void addInterestTest() {
    List<Id> interestIds = insertInterestHelper();
    test.startTest();
    TB_ClinicalInterestMAController.addInterest(
      'conference',
      'Test',
      Date.valueOf('2012-09-09'),
      Date.valueOf('2012-09-09'),
      80.0,
      interestIds[1],
      interestIds[2],
      'TB_Clinical_Interest_Prior_MA'
    );
    test.stopTest();
    List<TB_Experience_History__c> interests = [
      SELECT Id
      FROM TB_Experience_History__c
      WHERE TB_application__c = :interestIds[2]
    ];
    System.assertEquals(2, interests.size());
  }
  @isTest
  public static void updateInterestTest() {
    List<Id> interestIds = insertInterestHelper();
    test.startTest();
    TB_ClinicalInterestMAController.updateInterest(
      interestIds[0],
      'conference',
      'Test',
      Date.valueOf('2012-09-09'),
      Date.valueOf('2012-09-09'),
      120.0
    );
    test.stopTest();
    TB_Experience_History__c interest = [
      SELECT Id, TB_Workplace__c, TB_Hours__c
      FROM TB_Experience_History__c
      WHERE Id = :interestIds[0]
    ];
    System.assertEquals(120.0, interest.TB_Hours__c);
  }
  @isTest
  public static void deleteInterestTest() {
    List<Id> interestIds = insertInterestHelper();
    test.startTest();
    TB_ClinicalInterestMAController.deleteInterest(interestIds[0]);
    test.stopTest();
    List<TB_Experience_History__c> interests = [
      SELECT Id
      FROM TB_Experience_History__c
      WHERE Id = :interestIds[0]
    ];
    System.assertEquals(0, interests.size());
  }
}