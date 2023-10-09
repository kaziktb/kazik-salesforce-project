/**
 * Created by kamilkwaczynski on 29/07/2022.
 */

public with sharing class TB_pdo_ConsentController {
  @AuraEnabled(Cacheable=true)
  public static String getConsents(String admissionsType) {
    List<TB_Admissions_Dictionary__c> admissions = [
      SELECT
        Name,
        TB_Description_EN__c,
        TB_Description_PL__c,
        TB_Consent_Type__c
      FROM TB_Admissions_Dictionary__c
      WHERE
        toLabel(TB_Consents_Bundle__r.TB_Used_On__c) = :admissionsType
        AND TB_Active__c = TRUE
    ];

    return JSON.serialize(admissions);
  }
}