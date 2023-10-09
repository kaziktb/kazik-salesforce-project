public class TB_CurrentClinicalWorkplaceController {
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

  @AuraEnabled
  public static List<TB_Experience_History__c> getWorkplaces(
    String applicantId,
    String applicationId
  ) {
    String recordTypeId = Schema.SObjectType.TB_Experience_History__c
      .getRecordTypeInfosByDeveloperName()
      .get('TB_Current_Workplace')
      .getRecordTypeId();
    List<TB_Experience_History__c> workplaces = [
      SELECT Id, TB_Workplace__c, TB_Hours_Weekly__c, TB_Name__c
      FROM TB_Experience_History__c
      WHERE
        TB_Applicant__c = :applicantId
        AND TB_Application__c = :applicationId
        AND RecordTypeId = :recordTypeId
    ];
    return workplaces;
  }

  @AuraEnabled
  public static TB_Experience_History__c addWorkplace(
    String workplaceType,
    String name,
    Decimal workplaceWeeklyTime,
    String applicantId,
    String applicationId
  ) {
    TB_Experience_History__c currentWorkplace = new TB_Experience_History__c();
    currentWorkplace.TB_Workplace__c = workplaceType;
    currentWorkplace.TB_Name__c = name;
    currentWorkplace.TB_Hours_Weekly__c = workplaceWeeklyTime;
    currentWorkplace.TB_Applicant__c = applicantId;
    currentWorkplace.TB_Application__c = applicationId;
    currentWorkplace.RecordTypeId = Schema.SObjectType.TB_Experience_History__c
      .getRecordTypeInfosByDeveloperName()
      .get('TB_Current_Workplace')
      .getRecordTypeId();

    insert currentWorkplace;
    return currentWorkplace;
  }

  @AuraEnabled
  public static void updateWorkplace(
    String workplaceId,
    String workplaceType,
    String name,
    Decimal workplaceWeeklyTime
  ) {
    TB_Experience_History__c workplace = [
      SELECT Id, TB_Workplace__c, TB_Name__c, TB_Hours_Weekly__c
      FROM TB_Experience_History__c
      WHERE Id = :workplaceId
    ];
    workplace.TB_Workplace__c = workplaceType;
    workplace.TB_Name__c = name;
    workplace.TB_Hours_Weekly__c = workplaceWeeklyTime;
    update workplace;
  }

  @AuraEnabled
  public static void deleteWorkplace(String workplaceId) {
    TB_Experience_History__c workplace = [
      SELECT Id
      FROM TB_Experience_History__c
      WHERE Id = :workplaceId
    ];
    delete workplace;
  }
}