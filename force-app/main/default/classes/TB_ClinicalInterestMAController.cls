public class TB_ClinicalInterestMAController {
  @AuraEnabled(cacheable=true)
  public static Map<String, String> getInterestTypes() {
    Map<String, String> interestTypes = new Map<String, String>();
    Schema.DescribeFieldResult fieldResult = TB_Experience_History__c.TB_Interest_Type__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry pickListVal : ple) {
      interestTypes.put(pickListVal.getValue(), pickListVal.getLabel());
    }
    return interestTypes;
  }

  @AuraEnabled
  public static List<TB_Experience_History__c> getInterests(
    String applicantId,
    String applicationId,
    String recordTypeName
  ) {
    String recordTypeId = Schema.SObjectType.TB_Experience_History__c
      .getRecordTypeInfosByDeveloperName()
      .get(recordTypeName)
      .getRecordTypeId();
    List<TB_Experience_History__c> interests = [
      SELECT
        Id,
        TB_Interest_Type__c,
        TB_Name__c,
        TB_Start_Date__c,
        TB_End_Date__c,
        TB_Hours__c
      FROM TB_Experience_History__c
      WHERE
        TB_Applicant__c = :applicantId
        AND TB_Application__c = :applicationId
        AND RecordTypeId = :recordTypeId
    ];
    return interests;
  }

  @AuraEnabled
  public static TB_Experience_History__c addInterest(
    String interestType,
    String name,
    Date startDate,
    Date endDate,
    Decimal hours,
    String applicantId,
    String applicationId,
    String recordTypeName
  ) {
    TB_Experience_History__c currentInterest = new TB_Experience_History__c();
    currentInterest.TB_Interest_Type__c = interestType;
    currentInterest.TB_Name__c = name;
    currentInterest.TB_Start_Date__c = startDate;
    currentInterest.TB_End_Date__c = endDate;
    currentInterest.TB_Hours__c = hours;
    currentInterest.TB_Applicant__c = applicantId;
    currentInterest.TB_Application__c = applicationId;
    currentInterest.RecordTypeId = Schema.SObjectType.TB_Experience_History__c
      .getRecordTypeInfosByDeveloperName()
      .get(recordTypeName)
      .getRecordTypeId();

    insert currentInterest;
    return currentInterest;
  }

  @AuraEnabled
  public static void updateInterest(
    String interestId,
    String interestType,
    String name,
    Date startDate,
    Date endDate,
    Decimal hours
  ) {
    TB_Experience_History__c interest = [
      SELECT
        Id,
        TB_Interest_Type__c,
        TB_Name__c,
        TB_Start_Date__c,
        TB_End_Date__c,
        TB_Hours__c
      FROM TB_Experience_History__c
      WHERE Id = :interestId
    ];
    interest.TB_Interest_Type__c = interestType;
    interest.TB_Name__c = name;
    interest.TB_Start_Date__c = startDate;
    interest.TB_End_Date__c = endDate;
    interest.TB_Hours__c = hours;
    update interest;
  }

  @AuraEnabled
  public static void deleteInterest(String interestId) {
    TB_Experience_History__c interest = [
      SELECT Id
      FROM TB_Experience_History__c
      WHERE Id = :interestId
    ];
    delete interest;
  }
}