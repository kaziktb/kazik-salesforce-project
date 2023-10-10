/**
 * Created by kamilkwaczynski on 11/08/2022.
 */

public without sharing class TB_pdo_PdfGeneratorController {
  private static final String FILE_EXTENSION = '.pdf';
  private static final String CONTENT_LOCATION = 'S';
  private static final String UNDERSCORE = '_';
  private static final String UNDERSCORE_DRAFT = '_draft';

  @Future(Callout=true)
  public static void generatePdfWithVFP(List<Id> affiliationIds) {
    Id affiliateId = affiliationIds[0];
    TB_Affiliate_Statement__c affiliateWithPdoRelation = [
      SELECT
        TB_PDO__r.TB_Type__c,
        TB_PDO__r.RecordType.DeveloperName,
        TB_Contact__r.Name,
        TB_PDO__r.TB_DSpace_Reference_Id__c
      FROM TB_Affiliate_Statement__c
      WHERE Id = :affiliateId
    ];

    String achievementTemplateCategory = affiliateWithPdoRelation.TB_PDO__r.RecordType.DeveloperName ==
      TB_pdo_Constants.ARTISTIC_ACHIEVEMENT_TYPE
      ? TB_pdo_Constants.ARTISTIC_ACHIEVEMENT_FILE_TEMPLATE_CATEGORY
      : TB_pdo_Constants.SCIENCE_ACHIEVEMENT_FILE_TEMPLATE_CATEGORY;

    String accountIdWithTemplate = [
      SELECT TB_PDO_Account__c
      FROM TB_SWPS_Document_Template_Account_Ids__c
    ]
    .TB_PDO_Account__c;

    Id accId = [
      SELECT Id
      FROM Account
      WHERE DT_VDO_ID__c = :accountIdWithTemplate
    ]
    .Id;

    ContentDocumentLink cdl = [
      SELECT ContentDocumentId
      FROM ContentDocumentLink
      WHERE
        LinkedEntityId = :accId
        AND ContentDocument.LatestPublishedVersion.TB_Category__c = :achievementTemplateCategory
      LIMIT 1
    ];

    PageReference vfp = new PageReference('/apex/TB_pdo_PdfGenerator');
    vfp.getParameters()
      .put(
        TB_pdo_Constants.PARAM_RECORD_IDS,
        cdl.ContentDocumentId +
        ',' +
        affiliateId
      );

    String fileNameBuild =
      affiliateWithPdoRelation.TB_Contact__r.Name.replaceAll(' ', '_') +
      UNDERSCORE +
      affiliateWithPdoRelation.TB_PDO__r.TB_DSpace_Reference_Id__c +
      UNDERSCORE_DRAFT;

    ContentVersion cv = new ContentVersion();
    cv.ContentLocation = CONTENT_LOCATION;
    cv.TB_Category__c = TB_pdo_Constants.AFFILIATE_STATEMENT_TEMPLATE_PARTICIPANT;
    cv.PathOnClient = fileNameBuild + FILE_EXTENSION;
    cv.Title = fileNameBuild;
    cv.VersionData = !Test.isRunningTest()
      ? vfp.getContentAsPDF()
      : Blob.valueOf('PDF content for test');

    try {
      insert cv;
    } catch (DmlException exc) {
      insert TB_LogUtils.registerLog(exc);
    }

    cv = [
      SELECT Id, ContentDocumentId, Title
      FROM ContentVersion
      WHERE Id = :cv.Id AND IsLatest = TRUE
    ];

    ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
    contentDocumentLink.ContentDocumentId = cv.ContentDocumentId;
    contentDocumentLink.LinkedEntityId = affiliateId;
    contentDocumentLink.ShareType = TB_pdo_Constants.CONTENT_SHARE_TYPE_V;
    contentDocumentLink.Visibility = TB_pdo_Constants.CONTENT_VISIBILITY;

    try {
      insert contentDocumentLink;
    } catch (DmlException exc) {
      System.debug(exc.getMessage());
    }
  }
}