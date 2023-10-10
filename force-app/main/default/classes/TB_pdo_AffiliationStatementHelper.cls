/**
 * Created by kamilkwaczynski on 16/08/2022.
 */

public with sharing class TB_pdo_AffiliationStatementHelper {
  public static void executeGeneratorPdf(
    List<TB_Affiliate_Statement__c> affiliations,
    List<TB_Affiliate_Statement__c> oldAffiliations
  ) {
    Map<Id, TB_Affiliate_Statement__c> newAffiliationsMap = new Map<Id, TB_Affiliate_Statement__c>(
      affiliations
    );
    Map<Id, TB_Affiliate_Statement__c> oldAffiliationsMap = new Map<Id, TB_Affiliate_Statement__c>(
      oldAffiliations
    );
    List<Id> affiliateIds = new List<Id>();
    for (Id id : newAffiliationsMap.keySet()) {
      TB_Affiliate_Statement__c oldAffiliation = oldAffiliationsMap.get(id);
      if (
        oldAffiliation.TB_Status__c == TB_pdo_Constants.NEW_STATUS &&
        newAffiliationsMap.get(id).TB_Status__c ==
        TB_pdo_Constants.STATUS_TO_SIGNATURE
      ) {
        affiliateIds.add(id);
      }
    }
    if (affiliateIds.size() > 0) {
      TB_pdo_PdfGeneratorController.generatePdfWithVFP(affiliateIds);
    }
  }
}