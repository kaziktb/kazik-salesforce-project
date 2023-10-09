/**
 * Created by kamilkwaczynski on 07/07/2022.
 */

public with sharing class TB_pdo_AchievementsController {
  static List<Schema.SObjectField> attributesToLabel = new List<Schema.SObjectField>{
    TB_PDO__c.TB_Affiliate_Statements_Status__c,
    TB_PDO__c.TB_Language_of_Publication__c,
    TB_PDO__c.TB_Type__c,
    TB_PDO__c.TB_Rights_Information__c
  };

  @AuraEnabled(Cacheable=true)
  public static List<AchievementWrapper> getMyAchievment(
    Integer limitSize,
    Integer offset,
    String filterValue
  ) {
    String query =
      'SELECT Id, ' +
      'toLabel(TB_Type__c), ' +
      'Name, ' +
      'TB_PDO_Status__c, ' +
      'TB_Title_Original__c, ' +
      'TB_PDO_Stage__c, ' +
      'TB_Main_Type_EN__c, ' +
      'TB_VoR_Correction_Source__c, ' +
      'TB_VoR_Correction__c, ' +
      'TB_Popularisation_Status__c, ' +
      'TB_Popularisation_Stage__c, ' +
      'TB_Main_Type_PL__c, ' +
      'TB_Disciplines__c, ' +
      'TB_DSpace_Status__c, ' +
      'TB_Journal_Title__c, ' +
      'TB_Version_Number__c, ' +
      'TB_Publisher_Ministerial__c, ' +
      'TB_Sub_Type__c, ' +
      'RecordType.DeveloperName, ' +
      'toLabel(RecordType.Name) ' +
      'FROM TB_PDO__c WHERE TB_Active__c = true AND TB_x_Show_VoR_Source_on_Portal__c = true ';
    if (filterValue != 'All') {
      String filterType = filterValue == 'To_Correct'
        ? 'TB_PDO_Status__c'
        : 'TB_DSpace_Status__c';
      String andIsNotToCorrect = filterType == 'TB_DSpace_Status__c'
        ? ' AND TB_PDO_Status__c != \'To_Correct\''
        : '';
      query +=
        ' AND ' +
        filterType +
        ' = \'' +
        filterValue +
        '\'' +
        andIsNotToCorrect;
    }
    query +=
      ' AND (((RecordType.DeveloperName = \'TB_Science_Data\' OR RecordType.DeveloperName = \'TB_Artistic_Achievement\') ' +
      'AND ((TB_Newest_Version__c = true AND TB_First_Version__c = false) OR (TB_First_Version__c = true AND TB_Current_Version__c = null))) OR (RecordType.DeveloperName != \'TB_Science_Data\' AND RecordType.DeveloperName != \'TB_Artistic_Achievement\'))' +
      ' ORDER BY CreatedDate DESC LIMIT :limitSize OFFSET :offset';

    List<TB_PDO__c> pdos = Database.query(query);

    Map<String, String> pickListValues = new Map<String, String>();
    Schema.DescribeFieldResult field = TB_PDO__c.TB_DSpace_Status__c.getDescribe();
    for (Schema.PicklistEntry f : field.getPicklistValues()) {
      pickListValues.put(f.getValue(), f.getLabel());
    }

    List<AchievementWrapper> achievementWrappers = new List<AchievementWrapper>();
    for (TB_PDO__c tbPdo : pdos) {
      AchievementWrapper aw = new AchievementWrapper();
      aw.labelNameStatus = pickListValues.get(tbPdo.TB_DSpace_Status__c);
      aw.pdoRecord = tbPdo;
      achievementWrappers.add(aw);
    }
    return achievementWrappers;
  }

  @AuraEnabled(Cacheable=true)
  public static List<StatusesWrapper> getMyUniqueStatus() {
    List<StatusesWrapper> valuesToReturnAsList = new List<StatusesWrapper>();

    Schema.DescribeFieldResult field = TB_PDO__c.TB_DSpace_Status__c.getDescribe();
    for (Schema.PicklistEntry f : field.getPicklistValues()) {
      StatusesWrapper sw = new StatusesWrapper();
      sw.apiNameStatus = f.getValue();
      sw.labelStatus = f.getLabel();
      valuesToReturnAsList.add(sw);
    }
    return valuesToReturnAsList;
  }

  @AuraEnabled(Cacheable=true)
  public static String getDSpaceUrls() {
    try {
      TB_PDO_URLs__c urls = [
        SELECT
          TB_DSpace_Redirect_New_Article__c,
          TB_DSpace_Redirect_New_Artistic__c,
          TB_DSpace_Redirect_New_Science_Data__c,
          TB_DSpace_Redirect_New_Book__c,
          TB_Space_Redirect_New_Artistic_Other__c,
          TB_DSpace_Redirect_New_Artistic_Works__c
        FROM TB_PDO_URLs__c
        LIMIT 1
      ];
      return JSON.serialize(urls, false);
    } catch (Exception e) {
      throw new AuraHandledException(
        TB_LogUtils.prepareAuraLog(
          e.getMessage(),
          TB_pdo_AchievementsController.class.getName(),
          e.getStackTraceString(),
          ''
        )
      );
    }
  }

  @AuraEnabled(Cacheable=true)
  public static List<StatusesWrapper> getPDORecordTypes() {
    Schema.DescribeSObjectResult pdoObjectRecordTypes = TB_PDO__c.SObjectType.getDescribe();
    List<Schema.RecordTypeInfo> info = pdoObjectRecordTypes.getRecordTypeInfos();
    List<StatusesWrapper> wrapper = new List<StatusesWrapper>();
    for (RecordTypeInfo recordTypeInfo : info) {
      StatusesWrapper sw = new StatusesWrapper();
      sw.labelStatus = recordTypeInfo.getName();
      sw.apiNameStatus = recordTypeInfo.getDeveloperName();
      wrapper.add(sw);
    }
    return wrapper;
  }

  @AuraEnabled(Cacheable=true)
  public static List<StatusesWrapper> getObjectPicklistStatuses(
    String obj,
    String picklist
  ) {
    List<StatusesWrapper> valuesToReturnAsList = new List<StatusesWrapper>();

    Schema.SObjectType sObj = Schema.getGlobalDescribe().get(obj);
    Schema.DescribeSObjectResult field = sObj.getDescribe(); //TB_PDO__c.TB_PDO_Status__c.getDescribe();
    Map<String, Schema.SObjectField> mapFields = field.fields.getMap();

    for (
      Schema.PicklistEntry f : mapFields.get(picklist)
        .getDescribe()
        .getPicklistValues()
    ) {
      StatusesWrapper sw = new StatusesWrapper();
      sw.apiNameStatus = f.getValue();
      sw.labelStatus = f.getLabel();
      valuesToReturnAsList.add(sw);
    }
    return valuesToReturnAsList;
  }

  @AuraEnabled(Cacheable=true)
  public static DataWrapper getAchievementDetails(String recordId) {
    try {
      String soqlQuery = 'SELECT ';
      // GET FIELDS OF PDO OBJECT
      Map<String, Schema.SObjectField> fieldsMap = Schema.SObjectType.TB_PDO__c.fields.getMap();
      soqlQuery += 'RecordType.DeveloperName,toLabel(RecordType.Name), TB_Depositor__r.TB_User__c,';
      for (Schema.SObjectField field : fieldsMap.values()) {
        soqlQuery += attributesToLabel.contains(field)
          ? 'toLabel(' + field + '),'
          : field + ',';
      }
      soqlQuery = soqlQuery.substring(0, soqlQuery.length() - 1);
      soqlQuery +=
        ' FROM TB_PDO__c WHERE TB_Active__c = true AND Id = \'' +
        recordId +
        '\' LIMIT 1';
      TB_PDO__c pdo = Database.query(soqlQuery);

      // GET FIELDS OF CONTACT OBJECT
      String contactQuery = 'SELECT ';
      Map<String, Schema.SObjectField> mapOfContactFields = Schema.SObjectType.Contact.fields.getMap();
      for (Schema.SObjectField field : mapOfContactFields.values()) {
        contactQuery += field + ',';
      }
      contactQuery = contactQuery.substring(0, contactQuery.length() - 1);
      contactQuery +=
        ' FROM Contact WHERE Id = \'' +
        pdo.TB_Depositor__c +
        '\' LIMIT 1';
      Contact contact = Database.query(contactQuery);

      // GET FIELD OF PARTICIPANTS OBJECT
      List<TB_PDO_Participant__c> participants = Database.query(
        participantsQueryBuilder(pdo.Id)
      );

      DataWrapper dw = new DataWrapper(pdo, contact, participants);

      return dw;
    } catch (Exception e) {
      throw new AuraHandledException(
        TB_LogUtils.prepareAuraLog(
          e.getMessage(),
          TB_pdo_AchievementsController.class.getName(),
          e.getStackTraceString(),
          ''
        )
      );
    }
  }

  @AuraEnabled(Cacheable=true)
  public static List<TB_PDO__c> getVorCorrection(Id mainPdoId) {
    return [
      SELECT Id
      FROM TB_PDO__c
      WHERE
        TB_VoR_Correction_Source__c = :mainPdoId
        AND TB_VoR_Correction__c = TRUE
        AND TB_Active__c = TRUE
      LIMIT 1
    ];
  }

  @AuraEnabled
  public static String getParticipants(Id pdoId) {
    try {
      List<TB_PDO_Participant__c> participants = Database.query(
        participantsQueryBuilder(pdoId)
      );
      return JSON.serialize(participants);
    } catch (Exception e) {
      throw new AuraHandledException(
        TB_LogUtils.prepareAuraLog(
          e.getMessage(),
          TB_pdo_AchievementsController.class.getName(),
          e.getStackTraceString(),
          ''
        )
      );
    }
  }

  @AuraEnabled(Cacheable=true)
  public static String getPolicyFileContent() {
    Boolean isPolish =
      UserInfo.getLanguage() == TB_pdo_Constants.POLISH_LANGUAGE_CODE;
    String policyDocumentCategoryByLanguage = isPolish
      ? TB_pdo_Constants.POLICY_DOCUMENT_CATEGORY
      : TB_pdo_Constants.POLICY_DOCUMENT_CATEGORY_EN;

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

    List<ContentDocumentLink> cdl = [
      SELECT ContentDocumentId
      FROM ContentDocumentLink
      WHERE
        LinkedEntityId = :accId
        AND ContentDocument.LatestPublishedVersion.TB_Category__c = :policyDocumentCategoryByLanguage
      ORDER BY ContentDocument.LatestPublishedVersion.CreatedDate DESC
      LIMIT 1
    ];
    if (cdl.size() == 0) {
      return '';
    }
    List<ContentVersion> cv = [
      SELECT ContentDocumentId, VersionData
      FROM ContentVersion
      WHERE ContentDocumentId = :cdl[0].ContentDocumentId
    ];
    String clearedHtml = TB_HtmlMergeFieldUtils.clearHtmlValue(
      cv[0].VersionData.toString()
    );

    return clearedHtml;
  }

  public static String participantsQueryBuilder(Id pdoId) {
    try {
      String participantQuery = 'SELECT ';
      Map<String, Schema.SObjectField> mapOfParticipants = Schema.SObjectType.TB_PDO_Participant__c.fields.getMap();
      participantQuery += 'TB_Contact__r.TB_User__c,';
      for (Schema.SObjectField field : mapOfParticipants.values()) {
        participantQuery += attributesToLabel.contains(field)
          ? 'toLabel(' + field + '),'
          : field + ',';
      }
      participantQuery = participantQuery.substring(
        0,
        participantQuery.length() - 1
      );

      participantQuery +=
        ' FROM TB_PDO_Participant__c WHERE TB_PDO__c = \'' +
        pdoId +
        '\' AND TB_Contact__c != null ORDER BY TB_Order__c ASC';
      return participantQuery;
    } catch (Exception e) {
      throw new AuraHandledException(
        TB_LogUtils.prepareAuraLog(
          e.getMessage(),
          TB_pdo_AchievementsController.class.getName(),
          e.getStackTraceString(),
          ''
        )
      );
    }
  }
  public class StatusesWrapper {
    @AuraEnabled
    public String labelStatus { get; set; }
    @AuraEnabled
    public String apiNameStatus { get; set; }
  }
  public class AchievementWrapper {
    @AuraEnabled
    public String labelNameStatus { get; set; }
    @AuraEnabled
    public TB_PDO__c pdoRecord { get; set; }
  }
  public class DataWrapper {
    @AuraEnabled
    public TB_PDO__c pdo { get; set; }
    @AuraEnabled
    public Contact contact { get; set; }
    @AuraEnabled
    public List<TB_PDO_Participant__c> participants { get; set; }
    public DataWrapper(
      TB_PDO__c pdo,
      Contact contact,
      List<TB_PDO_Participant__c> participants
    ) {
      this.pdo = pdo;
      this.contact = contact;
      this.participants = participants;
    }
  }
}