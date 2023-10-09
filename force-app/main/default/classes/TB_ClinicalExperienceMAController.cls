public class TB_ClinicalExperienceMAController {
  @AuraEnabled(cacheable=true)
  public static Map<String, String> getWorkplaceTypes() {
    Map<String, String> workplaceTypes = new Map<String, String>();
    Schema.DescribeFieldResult fieldResult = TB_Experience_History__c.TB_Workplace__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry pickListVal : ple) {
      workplaceTypes.put(pickListVal.getValue(), pickListVal.getLabel());
    }
    return workplaceTypes;
  }

  @AuraEnabled(cacheable=true)
  public static Map<String, String> getWorkTypes() {
    Map<String, String> workTypes = new Map<String, String>();
    Schema.DescribeFieldResult fieldResult = TB_Experience_History__c.TB_Work_Type__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry pickListVal : ple) {
      workTypes.put(pickListVal.getValue(), pickListVal.getLabel());
    }
    return workTypes;
  }

  @AuraEnabled
  public static List<TB_Experience_History__c> getExperiences(
    String applicantId,
    String applicationId,
    String recordTypeName
  ) {
    String recordTypeId = Schema.SObjectType.TB_Experience_History__c
      .getRecordTypeInfosByDeveloperName()
      .get(recordTypeName)
      .getRecordTypeId();
    List<TB_Experience_History__c> experiences = [
      SELECT
        Id,
        TB_Workplace__c,
        TB_Work_Type__c,
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
    return experiences;
  }

  @AuraEnabled
  public static TB_Experience_History__c addExperience(
    String workplaceType,
    String workType,
    String name,
    Date startDate,
    Date endDate,
    Decimal hours,
    String applicantId,
    String applicationId,
    String recordTypeName
  ) {
    TB_Experience_History__c currentExperience = new TB_Experience_History__c();
    currentExperience.TB_Workplace__c = workplaceType;
    currentExperience.TB_Work_Type__c = workType;
    currentExperience.TB_Name__c = name;
    currentExperience.TB_Start_Date__c = startDate;
    currentExperience.TB_End_Date__c = endDate;
    currentExperience.TB_Hours__c = hours;
    currentExperience.TB_Applicant__c = applicantId;
    currentExperience.TB_Application__c = applicationId;
    currentExperience.RecordTypeId = Schema.SObjectType.TB_Experience_History__c
      .getRecordTypeInfosByDeveloperName()
      .get(recordTypeName)
      .getRecordTypeId();

    insert currentExperience;
    return currentExperience;
  }

  @AuraEnabled
  public static void updateExperience(
    String experienceId,
    String workplaceType,
    String workType,
    String name,
    Date startDate,
    Date endDate,
    Decimal hours
  ) {
    TB_Experience_History__c experience = [
      SELECT
        Id,
        TB_Workplace__c,
        TB_Work_Type__c,
        TB_Name__c,
        TB_Start_Date__c,
        TB_End_Date__c,
        TB_Hours__c
      FROM TB_Experience_History__c
      WHERE Id = :experienceId
    ];
    experience.TB_Workplace__c = workplaceType;
    experience.TB_Work_Type__c = workType;
    experience.TB_Name__c = name;
    experience.TB_Start_Date__c = startDate;
    experience.TB_End_Date__c = endDate;
    experience.TB_Hours__c = hours;
    update experience;
  }

  @AuraEnabled
  public static void deleteExperience(String experienceId) {
    TB_Experience_History__c experience = [
      SELECT Id
      FROM TB_Experience_History__c
      WHERE Id = :experienceId
    ];
    delete experience;
  }
}