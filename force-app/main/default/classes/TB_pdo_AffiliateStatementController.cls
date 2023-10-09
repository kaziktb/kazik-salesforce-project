/*
 * Created by kamilkwaczynski on 13/09/2022.
 */

public with sharing class TB_pdo_AffiliateStatementController {
  @AuraEnabled(Cacheable=true)
  public static List<TB_Affiliate_Statement__c> getAffiliates(
    Integer limitSize,
    Integer offset,
    String filterValue
  ) {
    Id currentUserId = UserInfo.getUserId();
    String query =
      'SELECT ' +
      'TB_PDO__r.TB_Year_of_Publication__c,' +
      'TB_PDO__r.TB_Title_Original__c,' +
      'TB_PDO__r.RecordType.DeveloperName,' +
      'TB_PDO__r.TB_Main_Type_EN__c,' +
      'TB_PDO__r.TB_Main_Type_PL__c,' +
      'TB_PDO__r.TB_Sub_Type__c,' +
      'toLabel(TB_PBN_Affiliation__c),' +
      'TB_Status__c ' +
      'FROM TB_Affiliate_Statement__c';
    if (filterValue != 'All') {
      query +=
        ' WHERE TB_Status__c = \'' +
        filterValue +
        '\' AND TB_PDO__c != null ';
    } else {
      query += ' WHERE TB_PDO__c != null ';
    }
    query += 'AND TB_Contact__r.TB_User__c =: currentUserId ORDER BY CreatedDate DESC LIMIT :limitSize OFFSET :offset';

    List<TB_Affiliate_Statement__c> affiliates = Database.query(query);
    return affiliates;
  }

  @AuraEnabled(Cacheable=true)
  public static String getAffiliation(String pdoId) {
    //Get affiliationId by loggedUser and Current PDO ID
    Id userId = UserInfo.getUserId();
    TB_PDO_Participant__c participant = [
      SELECT Id, TB_Affiliate_Statement__c
      FROM TB_PDO_Participant__c
      WHERE TB_PDO__c = :pdoId AND TB_Contact__r.TB_User__c = :userId
      LIMIT 1
    ];

    TB_Affiliate_Statement__c affiliateStatement = [
      SELECT
        Id,
        TB_Status__c,
        TB_PBN_Affiliation__c,
        TB_DAN_Comment__c,
        TB_Sub_Status__c,
              TB_Contact__c
      FROM TB_Affiliate_Statement__c
      WHERE Id = :participant.TB_Affiliate_Statement__c
    ];
    return JSON.serialize(affiliateStatement);
  }

  @AuraEnabled
  public static void updateAffiliateStatementStatus(String affiliateId, String newDiscipline) {
    TB_Affiliate_Statement__c affiliateStatement = [
      SELECT Id, TB_Status__c
      FROM TB_Affiliate_Statement__c
      WHERE Id = :affiliateId
    ];
    affiliateStatement.TB_Status__c = TB_pdo_Constants.STATUS_TO_SIGNATURE;
    affiliateStatement.TB_PBN_Affiliation__c = newDiscipline;

    if (!Test.isRunningTest()) {
      update affiliateStatement;
    }
  }
  @AuraEnabled
  public static String getAffiliationDetails(String recordId) {
    TB_Affiliate_Statement__c affiliate = [
      SELECT
        Id,
        TB_PDO__c,
        TB_PBN_Affiliation__c,
        TB_Status__c,
        TB_Contact__c,
        toLabel(TB_PDO__r.RecordType.Name),
        TB_PDO__r.TB_Journal_Title__c,
        TB_PDO__r.TB_Title_Original__c,
        TB_PDO__r.TB_DOI__c,
        TB_PDO__r.TB_Year_of_Publication__c,
        toLabel(TB_PDO__r.TB_DSpace_Status__c),
        TB_PDO__r.TB_Edition_Number_Tech__c
      FROM TB_Affiliate_Statement__c
      WHERE Id = :recordId
    ];

    return JSON.serialize(affiliate);
  }

  @AuraEnabled
  public static String getAffiliationStatementFile(String recordId) {
    List<ContentDocumentLink> fileLink = [
      SELECT ContentDocumentId
      FROM ContentDocumentLink
      WHERE
        LinkedEntityId = :recordId
        AND ContentDocument.LatestPublishedVersion.TB_Category__c = :TB_pdo_Constants.AFFILIATE_STATEMENT_TEMPLATE_PARTICIPANT
      LIMIT 1
    ];
    if (fileLink.size() == 0) {
      return '';
    }
    ContentVersion doc = [
      SELECT ContentDocumentId, FileExtension, Title
      FROM ContentVersion
      WHERE ContentDocumentId = :fileLink[0].ContentDocumentId
    ];
    Map<Id, String> mapIdTitle = new Map<Id, String>();
    mapIdTitle.put(doc.ContentDocumentId, doc.Title);
    return JSON.serialize(mapIdTitle);
  }
}