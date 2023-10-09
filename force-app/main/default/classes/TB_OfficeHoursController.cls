public without sharing class TB_OfficeHoursController {
  @AuraEnabled
  public static hed__Application__c getApplicationData(String applicationId) {
    return (hed__Application__c) [
      SELECT
        Id,
        TB_Applicant_Citizenship__c,
        TB_x_Admissions_Office_For_Poles__c,
        TB_x_Admissions_Office_For_Foreigners__c
      FROM hed__Application__c
      WHERE Id = :applicationId
    ];
  }

  @AuraEnabled
  public static Account getOfficeData(String accountId) {
    return (Account) [
      SELECT
        Id,
        TB_Account_Name_EN__c,
        TB_Opening_Hours_EN__c,
        TB_Account_Name_PL__c,
        TB_Opening_Hours_PL__c
      FROM Account
      WHERE Id = :accountId
    ];
  }
}