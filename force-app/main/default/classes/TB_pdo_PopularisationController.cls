public with sharing class TB_pdo_PopularisationController {
  @AuraEnabled
  public static PopularisationWrapper getPopularisationDetails(
    String recordId
  ) {
    TB_PDO_Popularisation__c popularisation = [
      SELECT
        Id,
        TB_PDO__r.RecordType.DeveloperName,
        TB_PDO__r.TB_Repository_Link__c,
        TB_PDO__r.TB_Title_Original__c,
        TB_PDO__r.TB_Sub_Type__c,
        TB_PDO__r.TB_Depositor__r.TB_User__c,
        TB_PDO_Disciplines__c,
        TB_Coordinator_Comment__c,
        TB_Press_Centre_and_Public_Affairs__r.TB_User__c,
        TB_Press_Centre_Marketing_Comment__c,
        TB_Send_to_Coordinator_Decision__c,
        TB_Marketing_Department__r.TB_User__c,
        TB_Send_Survey_to_Depositor_Comment__c,
        TB_Send_Survey_to_Depositor_Decision__c,
        TB_Discipline_Coordinator__r.TB_User__c,
        TB_Status__c,
        TB_Popularisation_Need_Priority__c,
        TB_Text_Preparation_Marketing__c,
        TB_Text_Preparation_Press_Centre__c,
        TB_Text_Preparation_Marketing_Person__c,
        TB_Text_Preparation_Press_Centre_Person__c,
        TB_Text_Ready_Date_Time__c,
        TB_Popularisation_Links__c,
        TB_PDO_Survey_URL__c,
        TB_Stage__c,
        toLabel(TB_PDO__r.TB_Type__c)
      FROM TB_PDO_Popularisation__c
      WHERE Id = :recordId
      LIMIT 1
    ];

    PopularisationWrapper popularisationWrapper = new PopularisationWrapper();
    popularisationWrapper.popularisation = popularisation;
    popularisationWrapper.statusesOfDecisions = getObjectPicklistStatuses(
      'TB_PDO_Popularisation__c',
      'TB_Coordinator_Decision__c'
    );
    popularisationWrapper.statusesOfDecisionsSendToCoordinator = getObjectPicklistStatuses(
      'TB_PDO_Popularisation__c',
      'TB_Send_to_Coordinator_Decision__c'
    );
    popularisationWrapper.statusesOfDecisionSurveyToDepositor = getObjectPicklistStatuses(
      'TB_PDO_Popularisation__c',
      'TB_Send_Survey_to_Depositor_Decision__c'
    );
    popularisationWrapper.admissionsDictionaries = getAdmissionCoordinators();
    popularisationWrapper.popularisationPriority = getObjectPicklistStatuses(
      'TB_PDO_Popularisation__c', 
      'TB_Popularisation_Need_Priority__c');
    List<TB_Admissions_Dictionary__c> coordinator = getPreferredDisciplineFrom(
      popularisation.TB_PDO_Disciplines__c
    );
    if (coordinator.size() != 0) {
      popularisationWrapper.preferredCoordinator = coordinator[0]
        .TB_Discipline_Coordinator__c;
    }

    return popularisationWrapper;
  }

  @AuraEnabled
  public static TB_PDO_Popularisation__c updatePopularisation(String data) {
    TB_PDO_Popularisation__c popularisation = (TB_PDO_Popularisation__c) JSON.deserialize(
      data,
      TB_PDO_Popularisation__c.class
    );
    if (!String.isEmpty(popularisation.TB_Send_to_Coordinator_Decision__c)) {
      popularisation.TB_Action_Contact_Coordinator_Decision__c = UserInfo.getName();
      popularisation.TB_Action_Date_Time_Marketing_Decision__c = Datetime.now();
    } else if (!String.isEmpty(popularisation.TB_Coordinator_Decision__c)) {
      popularisation.TB_Action_Contact_Coordinator_Decision__c = UserInfo.getName();
      popularisation.TB_Action_Date_Time_Coordinator_Decision__c = Datetime.now();
    } else if (
      !String.isEmpty(popularisation.TB_Send_Survey_to_Depositor_Decision__c)
    ) {
      popularisation.TB_Action_Contact_Send_Survey_Decision__c = UserInfo.getName();
      popularisation.TB_Action_Date_Time_Send_Survey_Decision__c = Datetime.now();
    }

    update popularisation;

    return popularisation;
  }

  @AuraEnabled(Cacheable=true)
  public static Map<String, String> getObjectPicklistStatuses(
    String obj,
    String picklist
  ) {
    Schema.SObjectType sObj = Schema.getGlobalDescribe().get(obj);
    Schema.DescribeSObjectResult field = sObj.getDescribe();
    Map<String, Schema.SObjectField> mapFields = field.fields.getMap();
    Map<String, String> mapToReturn = new Map<String, String>();
    for (
      Schema.PicklistEntry picklistValues : mapFields.get(picklist)
        .getDescribe()
        .getPicklistValues()
    ) {
      mapToReturn.put(picklistValues.getValue(), picklistValues.getLabel());
    }
    return mapToReturn;
  }

  public static List<TB_Admissions_Dictionary__c> getAdmissionCoordinators() {
    String disciplineCoordinatorRTId = Schema.SObjectType.TB_Admissions_Dictionary__c.getRecordTypeInfosByDeveloperName()
      .get('TB_Discipline_Coordinator')
      .getRecordTypeId();
    List<TB_Admissions_Dictionary__c> disciplineCoordinators = [
      SELECT
        Id,
        TB_Discipline_Coordinator__c,
        TB_Discipline_Coordinator__r.Name,
        TB_Discipline__c,
        Name
      FROM TB_Admissions_Dictionary__c
      WHERE RecordTypeId = :disciplineCoordinatorRTId AND TB_Active__c = TRUE
    ];
    return disciplineCoordinators;
  }

  private static List<TB_Admissions_Dictionary__c> getPreferredDisciplineFrom(
    String popularisationDisciplines
  ) {
    List<TB_Admissions_Dictionary__c> disciplineCoordinator = new List<TB_Admissions_Dictionary__c>();
    if (!String.isBlank(popularisationDisciplines)) {
      disciplineCoordinator = [
        SELECT TB_Discipline_Coordinator__c
        FROM TB_Admissions_Dictionary__c
        WHERE TB_Discipline__c = :popularisationDisciplines.split(',')[0]
      ];
    }
    return disciplineCoordinator;
  }

  public class PopularisationWrapper {
    @AuraEnabled
    public TB_PDO_Popularisation__c popularisation { get; set; }
    @AuraEnabled
    public Map<String, String> statusesOfDecisions { get; set; }
    @AuraEnabled
    public Map<String, String> popularisationPriority { get; set; }
    @AuraEnabled
    public Map<String, String> statusesOfDecisionSurveyToDepositor { get; set; }
    @AuraEnabled
    public Map<String, String> statusesOfDecisionsSendToCoordinator {
      get;
      set;
    }
    @AuraEnabled
    public List<TB_Admissions_Dictionary__c> admissionsDictionaries {
      get;
      set;
    }
    @AuraEnabled
    public Id preferredCoordinator { get; set; }
  }
}