public with sharing class TB_pdo_FileUploadController { // GENERATED PDF
  @AuraEnabled
  public static String uploadChunkedFile(
    Id recordId,
    String fileName,
    String fileContent,
    String contentVersionId
  ) {
    try {
      Id contentVersionIdToReturn;
      fileContent = EncodingUtil.urlDecode(fileContent, 'UTF-8');
      if (String.isBlank(contentVersionId)) {
        TB_Affiliate_Statement__c affiliateWithPdoRelation = [
          SELECT
            TB_PDO__r.TB_Type__c,
            TB_Contact__r.Name,
            TB_PDO__r.TB_DSpace_Reference_Id__c
          FROM TB_Affiliate_Statement__c
          WHERE Id = :recordId
        ];

        String fileNameBuild =
          affiliateWithPdoRelation.TB_Contact__r.Name.replaceAll(' ', '_') +
          '_' +
          affiliateWithPdoRelation.TB_PDO__r.TB_DSpace_Reference_Id__c;
        ContentVersion cv = new ContentVersion();
        cv.Title = fileNameBuild;
        cv.VersionData = EncodingUtil.base64Decode(fileContent);
        cv.PathOnClient =
          '/' +
          fileNameBuild +
          '.' +
          fileName.substringAfterLast('.');
        cv.IsMajorVersion = false;
        cv.TB_Category__c = TB_pdo_Constants.CONTENT_VERSION_ASF_CATEGORY;
        insert cv;

        Id contentDocId = [
          SELECT Id, ContentDocumentId
          FROM ContentVersion
          WHERE Id = :cv.Id
        ]
        .ContentDocumentId;
        ContentDocumentLink cdl = new ContentDocumentLink();

        cdl.ContentDocumentId = contentDocId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = TB_pdo_Constants.CONTENT_SHARE_TYPE_V;
        cdl.Visibility = TB_pdo_Constants.CONTENT_VISIBILITY;
        insert cdl;
        contentVersionIdToReturn = cv.Id;
      } else {
        ContentVersion cv = [
          SELECT Id, VersionData, ContentDocumentId
          FROM ContentVersion
          WHERE Id = :contentVersionId
        ];
        String existingFileContent = EncodingUtil.base64Encode(cv.VersionData);
        cv.VersionData = EncodingUtil.base64Decode(
          existingFileContent + fileContent
        );
        contentVersionIdToReturn = contentVersionId;
        update cv;
      }
      return contentVersionIdToReturn;
    } catch (Exception e) {
      throw new AuraHandledException(
        TB_LogUtils.prepareAuraLog(
          e.getMessage(),
          TB_pdo_FileUploadController.class.getName(),
          e.getStackTraceString(),
          ''
        )
      );
    }
  }
  @AuraEnabled
  public static void deleteFile(Id recordId) {
    try {
      delete [
        SELECT Id
        FROM ContentDocument
        WHERE
          Id = :[
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE
              LinkedEntityId = :recordId
              AND ContentDocument.LatestPublishedVersion.TB_Category__c = :TB_pdo_Constants.CONTENT_VERSION_ASF_CATEGORY
            ORDER BY ContentDocument.LatestPublishedVersion.CreatedDate DESC
            LIMIT 1
          ]
          .ContentDocumentId
      ];
    } catch (Exception e) {
      throw new AuraHandledException(
        TB_LogUtils.prepareAuraLog(
          e.getMessage(),
          TB_pdo_FileUploadController.class.getName(),
          e.getStackTraceString(),
          ''
        )
      );
    }
  }
  @AuraEnabled
  public static String getRegulationsFileByAccountId(Id recordId) {
    try {
      List<ContentDocumentLink> cdl = [
        SELECT ContentDocumentId
        FROM ContentDocumentLink
        WHERE
          LinkedEntityId = :recordId
          AND ContentDocument.LatestPublishedVersion.TB_Category__c = :TB_pdo_Constants.CONTENT_VERSION_ASF_CATEGORY
        ORDER BY ContentDocument.LatestPublishedVersion.CreatedDate DESC
        LIMIT 1
      ];
      if (cdl.size() == 0) {
        return '';
      }
      List<ContentVersion> cv = [
        SELECT ContentDocumentId, FileExtension, Title, ContentSize
        FROM ContentVersion
        WHERE ContentDocumentId = :cdl[0].ContentDocumentId
      ];
      if (cv.size() == 0) {
        return '';
      }

      DataWrapper dw = new DataWrapper();
      dw.title = cv[0].Title;
      dw.contentDocumentId = cv[0].ContentDocumentId;
      dw.contentSize = String.valueOf(cv[0].ContentSize);
      dw.fileExtension = cv[0].FileExtension;
      return JSON.serialize(dw);
    } catch (Exception e) {
      throw new AuraHandledException(
        TB_LogUtils.prepareAuraLog(
          e.getMessage(),
          TB_pdo_FileUploadController.class.getName(),
          e.getStackTraceString(),
          ''
        )
      );
    }
  }
  class DataWrapper {
    @AuraEnabled
    public String contentDocumentId { get; set; }
    @AuraEnabled
    public String title { get; set; }
    @AuraEnabled
    public String fileExtension { get; set; }
    @AuraEnabled
    public String contentSize { get; set; }
  }
}