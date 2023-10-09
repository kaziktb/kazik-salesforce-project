public without sharing class TB_OnlineConsultations {
  @AuraEnabled
  public static String getConsultationsURL(String applicationId) {
    String consulationsUrl;

    hed__Application__c application = [
      SELECT
        Name,
        hed__Applicant__c,
        TB_Applying_To_Offered_Product__c,
        TB_Applicant_Citizenship__c
      FROM hed__Application__c
      WHERE Id = :applicationId
    ];
    TB_Offered_Product__c product = new TB_Offered_Product__c();
    if (
      application.TB_Applicant_Citizenship__c == 'Poland' ||
      application.TB_Applicant_Citizenship__c == 'Polish' ||
      application.TB_Applicant_Citizenship__c == 'PL'
    ) {
      try {
        product = [
          SELECT TB_Online_Consultations_URL_PL__c
          FROM TB_Offered_Product__c
          WHERE
            Id = :application.TB_Applying_To_Offered_Product__c
            AND TB_Enable_Online_Consultations__c = TRUE
        ];
        if (product.TB_Online_Consultations_URL_PL__c != null) {
          consulationsUrl =
            product.TB_Online_Consultations_URL_PL__c +
            '&ApplicationId=' +
            application.Name;
        } else {
          consulationsUrl = null;
        }
      } catch (Exception e) {
        consulationsUrl = null;
      }
    } else if (application.TB_Applicant_Citizenship__c == null) {
      consulationsUrl = null;
    } else {
      try {
        product = [
          SELECT TB_Online_Consultations_URL_EN__c
          FROM TB_Offered_Product__c
          WHERE
            Id = :application.TB_Applying_To_Offered_Product__c
            AND TB_Enable_Online_Consultations__c = TRUE
        ];
        if (product.TB_Online_Consultations_URL_EN__c != null) {
          consulationsUrl =
            product.TB_Online_Consultations_URL_EN__c +
            '&ApplicationId=' +
            application.Name;
        } else {
          consulationsUrl = null;
        }
      } catch (Exception e) {
        consulationsUrl = null;
      }
    }
    return consulationsUrl;
  }
}