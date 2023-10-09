/**
 * @description       : PDO acceptance main flow
 * @author            : jakub.wrzodek@thinkbeyond.cloud
 * Modifications Log
 * Ver   Date         Author
 * 1.0   01-11-2022   Jakub Wrzodek
 **/
public with sharing class TB_PDO_BonusApplicationsController {
  @AuraEnabled
  public static String getBonusApplications() {
    JsonListResponse response = new JsonListResponse();
    try {
      List<TB_PDO__c> pdos = getPdos();
      List<TB_PDO_Participant__c> participants = getParticipants();
      List<SimplePdoDataWrapper> wrappedPdos = wrapPdosWithParticipants(
        pdos,
        participants
      );
      response.code = TB_pdo_Constants.SUCCESS_CODE;
      response.data = wrappedPdos;
    } catch (Exception exe) {
      response.code = TB_pdo_Constants.SERVER_ERROR_CODE;
      response.error = exe.getTypeName();
    }
    return response.wrap();
  }

  @AuraEnabled
  public static String getBonusApplication(String recordId) {
    JsonResponse response = new JsonResponse();
    try {
      DetailedPdoDataWrapper wrapper = getObjectNameFromRecordId(recordId) ==
        TB_pdo_Constants.PDO_OBJECT_NAME
        ? getWrapperFromPdoId(recordId)
        : getWrapperFromParticipantId(recordId);
      response.code = TB_pdo_Constants.SUCCESS_CODE;
      response.data = wrapper;
    } catch (Exception exe) {
      response.code = TB_pdo_Constants.SERVER_ERROR_CODE;
      response.error = exe.getTypeName();
    }
    return response.wrap();
  }

  @AuraEnabled(Cacheable=true)
  public static String getBonusApplicationStatusDetails(String recordId) {
    JsonResponse response = new JsonResponse();
    try {
      String status = getObjectNameFromRecordId(recordId) ==
        TB_pdo_Constants.PDO_OBJECT_NAME
        ? getPdoWithoutStatusOrUserCondition(recordId)
            .TB_Bonus_Application_Status__c
        : getParticipant(recordId).TB_Bonus_Application_Status__c;
      PdoStatusDataWrapper wrapper = new PdoStatusDataWrapper(recordId, status);
      response.code = TB_pdo_Constants.SUCCESS_CODE;
      response.data = wrapper;
    } catch (Exception exe) {
      response.code = TB_pdo_Constants.SERVER_ERROR_CODE;
      response.error = exe.getTypeName();
    }
    return response.wrap();
  }

  @AuraEnabled(Cacheable=true)
  public static String getBonusApplicationStatuses() {
    JsonSetResponse response = new JsonSetResponse();
    try {
      Set<String> applicationStatuses = new Set<String>();
      Schema.DescribeFieldResult fieldResult = TB_PDO_Participant__c.TB_Bonus_Application_Status__c.getDescribe();
      List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
      for (Schema.PicklistEntry value : picklistValues) {
        applicationStatuses.add(
          performStatusCustomMapping(value.getLabel().replace('_', ' '))
        );
      }
      response.code = TB_pdo_Constants.SUCCESS_CODE;
      response.data = applicationStatuses;
    } catch (Exception exe) {
      response.code = TB_pdo_Constants.SERVER_ERROR_CODE;
      response.error = exe.getTypeName();
    }
    return response.wrap();
  }

  @AuraEnabled
  public static String updateParticipants(String participantsJson) {
    JsonResponse response = new JsonResponse();
    try {
      List<TB_PDO_Participant__c> participants = (List<TB_PDO_Participant__c>) JSON.deserialize(
        participantsJson,
        List<TB_PDO_Participant__c>.class
      );
      update participants;
      response.code = TB_pdo_Constants.SUCCESS_CODE;
    } catch (Exception exe) {
      response.code = TB_pdo_Constants.SERVER_ERROR_CODE;
      response.error = exe.getTypeName();
    }
    return response.wrap();
  }

  @AuraEnabled
  public static String acceptBonusApplication(String bonusAppJson) {
    JsonResponse response = new JsonResponse();
    try {
      TB_PDO__c pdo = (TB_PDO__c) JSON.deserialize(
        bonusAppJson,
        TB_PDO__c.class
      );
      pdo.TB_Bonus_Application_Status__c = TB_pdo_Constants.CONFIRMATION_PENDING_STATUS;
      update pdo;
      response.code = TB_pdo_Constants.SUCCESS_CODE;
    } catch (Exception exe) {
      response.code = TB_pdo_Constants.SERVER_ERROR_CODE;
      response.error = exe.getTypeName();
    }
    return response.wrap();
  }

  @AuraEnabled
  public static String acceptParticipantSharing(String participantJson) {
    JsonResponse response = new JsonResponse();
    try {
      TB_PDO_Participant__c participant = (TB_PDO_Participant__c) JSON.deserialize(
        participantJson,
        TB_PDO_Participant__c.class
      );
      participant.TB_Bonus_Application_Status__c = TB_pdo_Constants.TO_VERIFY_STATUS;
      update participant;
      response.code = TB_pdo_Constants.SUCCESS_CODE;
    } catch (Exception exe) {
      response.code = TB_pdo_Constants.SERVER_ERROR_CODE;
      response.error = exe.getTypeName();
    }
    return response.wrap();
  }

  private static List<SimplePdoDataWrapper> wrapPdosWithParticipants(
    List<TB_PDO__c> pdos,
    List<TB_PDO_Participant__c> participants
  ) {
    List<SimplePdoDataWrapper> result = TB_PDO_BonusApplicationsController.wrapToSimpleDataList(
      pdos
    );
    List<TB_PDO_Participant__c> filteredParticipants = new List<TB_PDO_Participant__c>();
    List<String> pdoIds = new List<String>();
    for (TB_PDO__c pdo : pdos) {
      pdoIds.add(pdo.Id);
    }
    for (TB_PDO_Participant__c participant : participants) {
      if (!pdoIds.contains(participant.TB_PDO__c)) {
        filteredParticipants.add(participant);
      }
    }
    result.addAll(wrapToSimpleDataListFromParticipants(filteredParticipants));
    return result;
  }

  private static DetailedPdoDataWrapper getWrapperFromPdoId(String recordId) {
    TB_PDO__c pdo = getPdo(recordId);
    DetailedPdoDataWrapper wrapper = TB_PDO_BonusApplicationsController.wrapToDetailedData(
      pdo
    );
    wrapper.rejectionJustification = pdo.TB_BA_Rejection_Justification__c;
    wrapper.pdsnComment = pdo.TB_BA_PDSN_Comment__c;
    wrapper.isPdo = true;
    return wrapper;
  }

  private static DetailedPdoDataWrapper getWrapperFromParticipantId(
    String recordId
  ) {
    TB_PDO_Participant__c participant = getParticipant(recordId);
    TB_PDO__c pdo = getPdoWithoutStatusOrUserCondition(participant.TB_PDO__c);
    DetailedPdoDataWrapper wrapper = TB_PDO_BonusApplicationsController.wrapToDetailedData(
      pdo
    );
    wrapper.participantId = participant.Id;
    wrapper.participant = new ParticipationDataWrapper(
      participant.Id,
      participant.TB_Contact__r.Name,
      participant.TB_Bonus_Application_Share__c,
      participant.TB_Bonus_Application_Status__c,
      participant.TB_Contact__r.TB_User__c
    );
    wrapper.participantShare = wrapper.participantShare != null
      ? Math.floor(participant.TB_Bonus_Application_Share__c)
      : null;
    wrapper.status = performStatusCustomMapping(
      participant.TB_Bonus_Application_Status__c
    );
    wrapper.amount = participant.TB_Bonus_Application_Share_Amount__c;
    wrapper.rejectionJustification = pdo.TB_BA_Rejection_Justification__c;
    wrapper.pdsnComment = pdo.TB_BA_PDSN_Comment__c;
    return wrapper;
  }

  private static List<StatusDataWrapper> getStatuses(
    Schema.DescribeFieldResult fieldResult
  ) {
    Set<String> applicationStatuses = new Set<String>();
    List<StatusDataWrapper> wrappedApplicationStatuses = new List<StatusDataWrapper>();
    List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry value : picklistValues) {
      applicationStatuses.add(performStatusCustomMapping(value.getLabel()));
    }
    Integer index = 1;
    for (String status : applicationStatuses) {
      wrappedApplicationStatuses.add(new StatusDataWrapper(index, status));
      index += 1;
    }
    return wrappedApplicationStatuses;
  }

  private static String getObjectNameFromRecordId(String recordId) {
    String result;
    try {
      result = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
    } catch (Exception exe) {
      result = null;
    }
    return result;
  }

  private static TB_PDO__c getPdo(String recordId, Boolean checkStatusOrUser) {
    Id userId = UserInfo.getUserId();
    return [
      SELECT
        Id,
        TB_Title_Original__c,
        toLabel(TB_Bonus_Application_Status__c),
        TB_BA_Score__c,
        TB_Year_of_Publication__c,
        TB_Journal_Title__c,
        TB_Affiliations__c,
        TB_DOI__c,
        TB_Sub_Type__c,
        TB_Version_Number__c,
        TB_Disciplines__c,
        RecordType.DeveloperName,
        toLabel(TB_Type__c),
        TB_Publisher__c,
        TB_BA_Depositor_Comment__c,
        TB_BA_Rejection_Justification__c,
        TB_BA_PDSN_Comment__c
      FROM TB_PDO__c
      WHERE
        Id = :recordId
        AND TB_Active__c = TRUE
        AND TB_Bonus_Application_Status__c != NULL
        AND (TB_Active__c != :checkStatusOrUser
        OR TB_Depositor__r.TB_User__c = :userId)
        AND (TB_Active__c != :checkStatusOrUser
        OR TB_Bonus_Application_Status__c = :TB_pdo_Constants.NEW_STATUS
        OR TB_Bonus_Application_Status__c = :TB_pdo_Constants.TO_CORRECT_STATUS)
    ];
  }

  private static TB_PDO__c getPdo(String recordId) {
    return getPdo(recordId, true);
  }

  private static TB_PDO__c getPdoWithoutStatusOrUserCondition(String recordId) {
    return getPdo(recordId, false);
  }

  private static List<TB_PDO__c> getPdos() {
    Id userId = UserInfo.getUserId();
    return [
      SELECT
        Id,
        TB_Title_Original__c,
        toLabel(TB_Bonus_Application_Status__c),
        TB_BA_Score__c,
        TB_Disciplines__c,
        TB_Year_of_Publication__c,
        RecordType.DeveloperName,
        toLabel(TB_Type__c),
        TB_Sub_Type__c,
        CreatedDate
      FROM TB_PDO__c
      WHERE
        TB_Depositor__r.TB_User__c = :userId
        AND TB_Active__c = TRUE
        AND (TB_Bonus_Application_Status__c = :TB_pdo_Constants.NEW_STATUS
        OR TB_Bonus_Application_Status__c = :TB_pdo_Constants.TO_CORRECT_STATUS)
        AND TB_Bonus_Application__c = TRUE
    ];
  }

  private static TB_PDO_Participant__c getParticipant(String recordId) {
    Id userId = UserInfo.getUserId();
    return [
      SELECT
        Id,
        TB_PDO__c,
        toLabel(TB_Bonus_Application_Status__c),
        TB_PDO__r.TB_Disciplines__c,
        TB_Contact__r.Name,
        TB_Bonus_Application_Share__c,
        TB_Bonus_Application_Share_Amount__c,
        TB_Contact__r.TB_User__c
      FROM TB_PDO_Participant__c
      WHERE
        Id = :recordId
        AND TB_Active__c = TRUE
        AND TB_Contact__r.TB_User__c = :userId
        AND TB_Bonus_Application_Status__c != :TB_pdo_Constants.NEW_STATUS
        AND TB_Bonus_Application_Status__c != NULL
    ];
  }

  private static List<TB_PDO_Participant__c> getParticipants() {
    Id userId = UserInfo.getUserId();
    return [
      SELECT
        Id,
        TB_PDO__c,
        TB_PDO__r.TB_Title_Original__c,
        toLabel(TB_Bonus_Application_Status__c),
        TB_PDO__r.TB_BA_Score__c,
        TB_PDO__r.TB_Disciplines__c,
        TB_PDO__r.TB_Year_of_Publication__c,
        TB_PDO__r.TB_Sub_Type__c,
        TB_PDO__r.RecordType.DeveloperName,
        toLabel(TB_PDO__r.TB_Type__c),
        TB_Bonus_Application_Share__c,
        TB_Bonus_Application_Share_Amount__c,
        CreatedDate
      FROM TB_PDO_Participant__c
      WHERE
        TB_Active__c = TRUE
        AND TB_Contact__r.TB_User__c = :userId
        AND TB_Bonus_Application_Status__c != :TB_pdo_Constants.NEW_STATUS
        AND TB_Bonus_Application_Status__c != NULL
        AND TB_Bonus_Application__c = TRUE
        AND TB_PDO__r.TB_Bonus_Application__c = TRUE
    ];
  }

  private static List<SimplePdoDataWrapper> wrapToSimpleDataList(
    List<TB_PDO__c> pdos
  ) {
    List<SimplePdoDataWrapper> result = new List<SimplePdoDataWrapper>();
    for (TB_PDO__c pdo : pdos) {
      SimplePdoDataWrapper wrapper = new SimplePdoDataWrapper(
        pdo.Id,
        pdo.TB_Title_Original__c,
        pdo.TB_Bonus_Application_Status__c.replace('_', ' '),
        pdo.TB_Type__c,
        pdo.TB_BA_Score__c,
        pdo.TB_Year_of_Publication__c,
        pdo.CreatedDate.format(TB_pdo_Constants.DATA_FORMAT),
        pdo.TB_Disciplines__c,
        pdo.RecordType.DeveloperName,
        pdo.TB_Sub_Type__c
      );
      wrapper.isPdo = true;
      result.add(wrapper);
    }
    return result;
  }

  private static List<SimplePdoDataWrapper> wrapToSimpleDataListFromParticipants(
    List<TB_PDO_Participant__c> participants
  ) {
    List<SimplePdoDataWrapper> result = new List<SimplePdoDataWrapper>();
    for (TB_PDO_Participant__c participant : participants) {
      SimplePdoDataWrapper wrapper = new SimplePdoDataWrapper(
        participant.TB_PDO__c,
        participant.TB_PDO__r.TB_Title_Original__c,
        participant.TB_Bonus_Application_Status__c != null
          ? participant.TB_Bonus_Application_Status__c.replace('_', ' ')
          : null,
        participant.TB_PDO__r.TB_Type__c,
        participant.TB_PDO__r.TB_BA_Score__c,
        participant.TB_PDO__r.TB_Year_of_Publication__c,
        participant.CreatedDate.format(TB_pdo_Constants.DATA_FORMAT),
        participant.TB_PDO__r.TB_Disciplines__c,
        participant.TB_PDO__r.RecordType.DeveloperName,
        participant.TB_PDO__r.TB_Sub_Type__c
      );
      wrapper.participantId = participant.Id;
      wrapper.participantShare = participant.TB_Bonus_Application_Share__c !=
        null
        ? Math.floor(participant.TB_Bonus_Application_Share__c)
        : null;
      result.add(wrapper);
    }
    return result;
  }

  private static DetailedPdoDataWrapper wrapToDetailedData(TB_PDO__c pdo) {
    return new DetailedPdoDataWrapper(
      pdo.Id,
      pdo.TB_Title_Original__c,
      pdo.TB_Bonus_Application_Status__c.replace('_', ' '),
      pdo.TB_Type__c,
      pdo.TB_BA_Score__c,
      pdo.TB_Year_of_Publication__c,
      pdo.TB_Publisher__c,
      pdo.TB_BA_Depositor_Comment__c,
      pdo.TB_Disciplines__c,
      pdo.RecordType.DeveloperName,
      pdo.TB_Journal_Title__c,
      pdo.TB_Affiliations__c,
      pdo.TB_DOI__c,
      pdo.TB_Version_Number__c,
      pdo.TB_Sub_Type__c
    );
  }

  private static String performStatusCustomMapping(String status) {
    switch on status {
      when 'To_Verify', 'To Verify' {
        return TB_pdo_Constants.VERIFICATION_STATUS;
      }
      when 'To_Payout', 'To Payout', 'Validated' {
        return TB_pdo_Constants.READY_STATUS;
      }
      when 'Przesłany do weryfikacji' {
        return TB_pdo_Constants.VERIFICATION_STATUS_PL;
      }
      when 'Zweryfikowany', 'Do wypłaty' {
        return TB_pdo_Constants.READY_STATUS_PL;
      }
      when else {
        return status;
      }
    }
  }

  private static List<ParticipationDataWrapper> getParticipationListJson(
    String pdoId
  ) {
    List<ParticipationDataWrapper> result = new List<ParticipationDataWrapper>();
    List<TB_PDO_Participant__c> participants = [
      SELECT
        Id,
        TB_Contact__r.Name,
        TB_Bonus_Application_Share__c,
        TB_Bonus_Application_Status__c,
        TB_Contact__r.TB_User__c
      FROM TB_PDO_Participant__c
      WHERE
        TB_PDO__c = :pdoId
        AND TB_Active__c = TRUE
        AND TB_Bonus_Application__c = TRUE
    ];
    for (TB_PDO_Participant__c participant : participants) {
      result.add(
        new ParticipationDataWrapper(
          participant.Id,
          participant.TB_Contact__r.Name,
          participant.TB_Bonus_Application_Share__c,
          participant.TB_Bonus_Application_Status__c.replace('_', ' '),
          participant.TB_Contact__r.TB_User__c
        )
      );
    }
    return result;
  }

  public virtual class Wrapper {
  }

  public class JsonResponse {
    public Wrapper data { get; set; }
    public String error { get; set; }
    public Integer code { get; set; }
    public String wrap() {
      return JSON.serialize(this);
    }
  }

  public class JsonListResponse {
    public List<Wrapper> data { get; set; }
    public String error { get; set; }
    public Integer code { get; set; }
    public String wrap() {
      return JSON.serialize(this);
    }
  }

  public class JsonSetResponse {
    public Set<String> data { get; set; }
    public String error { get; set; }
    public Integer code { get; set; }
    public String wrap() {
      return JSON.serialize(this);
    }
  }

  public class SimplePdoDataWrapper extends Wrapper {
    public String id { get; set; }
    public Boolean isArtisticAchievment { get; set; }
    public Boolean isToConfirm { get; set; }
    public String title { get; set; }
    public String status { get; set; }
    public String type { get; set; }
    public Decimal score { get; set; }
    public String publicationYear { get; set; }
    public Decimal participantShare { get; set; }
    public String participantId { get; set; }
    public Decimal createdDate { get; set; }
    public Boolean isPdo { get; set; }
    public String disciplines { get; set; }
    public String recordType { get; set; }
    public String subType { get; set; }
    public SimplePdoDataWrapper(
      String id,
      String title,
      String status,
      String type,
      Decimal score,
      String publicationYear,
      String createdDate,
      String disciplines,
      String recordType,
      String subType
    ) {
      this.id = id;
      this.title = title;
      this.status = performStatusCustomMapping(status);
      this.isToConfirm = this.status == TB_pdo_Constants.TO_CONFIRM_STATUS;
      this.type = type;
      this.score = score;
      this.publicationYear = publicationYear;
      this.createdDate = Decimal.valueOf(createdDate);
      this.isPdo = false;
      this.disciplines = disciplines;
      this.recordType = recordType;
      this.isArtisticAchievment =
        recordType == TB_pdo_Constants.ARTISTIC_ACHIEVEMENT;
      this.subType = subType;
    }
  }

  public class DetailedPdoDataWrapper extends Wrapper {
    public String id { get; set; }
    public Boolean isArtisticAchievment { get; set; }
    public String title { get; set; }
    public String status { get; set; }
    public String type { get; set; }
    public Decimal score { get; set; }
    public String publicationYear { get; set; }
    public String publisher { get; set; }
    public String comments { get; set; }
    public Decimal participantShare { get; set; }
    public List<ParticipationDataWrapper> participations { get; set; }
    public ParticipationDataWrapper participant { get; set; }
    public String participantId { get; set; }
    public Boolean isPdo { get; set; }
    public Decimal amount { get; set; }
    public String rejectionJustification { get; set; }
    public String pdsnComment { get; set; }
    public String disciplines { get; set; }
    public String recordType { get; set; }
    public String journalTitle { get; set; }
    public String affiliations { get; set; }
    public String doi { get; set; }
    public String versionNumber { get; set; }
    public String subType { get; set; }
    public DetailedPdoDataWrapper(
      String id,
      String title,
      String status,
      String type,
      Decimal score,
      String publicationYear,
      String publisher,
      String comments,
      String disciplines,
      String recordType,
      String journalTitle,
      String affiliations,
      String doi,
      String versionNumber,
      String subType
    ) {
      this.id = id;
      this.title = title;
      this.status = performStatusCustomMapping(status);
      this.type = type;
      this.score = score;
      this.publicationYear = publicationYear;
      this.isArtisticAchievment =
        recordType == TB_pdo_Constants.ARTISTIC_ACHIEVEMENT;
      this.participations = getParticipationListJson(id);
      this.publisher = publisher;
      this.comments = comments;
      this.isPdo = false;
      this.disciplines = disciplines;
      this.recordType = recordType;
      this.journalTitle = journalTitle;
      this.affiliations = affiliations;
      this.doi = doi;
      this.versionNumber = versionNumber;
      this.subType = subType;
    }
  }

  public class ParticipationDataWrapper extends Wrapper {
    public String id { get; set; }
    public String contactName { get; set; }
    public Decimal share { get; set; }
    public String status { get; set; }
    public Boolean isToConfirm { get; set; }
    public String userId { get; set; }
    public ParticipationDataWrapper(
      String id,
      String contactName,
      Decimal share,
      String status,
      String userId
    ) {
      this.id = id;
      this.contactName = contactName;
      this.share = share != null ? Math.floor(share) : 0;
      this.status = status;
      this.isToConfirm = status == TB_pdo_Constants.TO_CONFIRM_STATUS;
      this.userId = userId;
    }
  }

  public class StatusDataWrapper extends Wrapper {
    public Integer index { get; set; }
    public String label { get; set; }
    public StatusDataWrapper(Integer index, String label) {
      this.index = index;
      this.label = label;
    }
  }

  public class PdoStatusDataWrapper extends Wrapper {
    public String id { get; set; }
    public String status { get; set; }
    public List<StatusDataWrapper> statuses { get; set; }
    public Boolean isPdo { get; set; }
    public PdoStatusDataWrapper(String id, String status) {
      this.id = id;
      this.status = performStatusCustomMapping(status);
      Schema.DescribeFieldResult fieldResult = getObjectNameFromRecordId(id) ==
        TB_pdo_Constants.PDO_OBJECT_NAME
        ? TB_PDO__c.TB_Bonus_Application_Status__c.getDescribe()
        : TB_PDO_Participant__c.TB_Bonus_Application_Status__c.getDescribe();
      this.statuses = getStatuses(fieldResult);
      this.isPdo =
        getObjectNameFromRecordId(id) == TB_pdo_Constants.PDO_OBJECT_NAME;
    }
  }
}