@RestResource(UrlMapping='/contacts/*')
global with sharing class TB_pdo_ContactRestWebService {
  private static final String currentStatus = 'Current';
  private static final String agreement = 'Agreement';
  private static final String research = 'Research';
  private static final String department = 'University Department';
  @HttpGet
  global static List<Contact> getEmployeeCatalog() {
    List<Contact> contacts = new List<Contact>();
    RestRequest req = RestContext.request;
    List<String> organizationType = new List<String>{
      TB_pdo_Constants.CATHEDRAL,
      TB_pdo_Constants.INSTITUTE,
      TB_pdo_Constants.INSTITUTION,
      TB_pdo_Constants.CENTER
    };
    List<String> availableAffiliations = new List<String>{
      TB_pdo_Constants.AEBS,
      TB_pdo_Constants.AEDS,
      TB_pdo_Constants.AERS,
      TB_pdo_Constants.DSSS,
      TB_pdo_Constants.NETS
    };
    String filter = EncodingUtil.urlDecode(
        req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1),
        'UTF-8'
      )
      .trim();
    String[] userInput = filter.substringAfter('=')
      .trim()
      .replaceAll(' +', ' ')
      .split(' ');
    String contactQuery = '';
    Map<String, Contact> idToContact = new Map<String, Contact>();
    Id employeeRTId = Schema.Sobjecttype.Contact.getRecordTypeInfosByName()
      .get(TB_pdo_Constants.EMPLOYEE_RT)
      .getRecordTypeId();
    Id attributeRTId = Schema.Sobjecttype.hed__Attribute__c.getRecordTypeInfosByName()
      .get(TB_pdo_Constants.CREDENTIAL_RT)
      .getRecordTypeId();
    List<hed__Affiliation__c> affiliations = new List<hed__Affiliation__c>();
    if (userInput.size() == 1) {
      contactQuery =
        'SELECT Id, TB_ERP_Id__c, FirstName, LastName, hed__WorkEmail__c, TB_ORCID__c, (SELECT ID, TB_Discipline__c, TB_Discipline_Percentage_Share__c FROM hed__Attributes__r WHERE hed__End_Date__c = NULL AND TB_Discipline__c != NULL AND hed__Start_Date__c < TODAY AND RecordTypeId =: attributeRTId), (SELECT ID, Name, hed__Account__r.Name, hed__Account__r.ParentId, hed__Account__r.Parent.ParentId ,hed__Account__r.Type, hed__Account__r.Parent.Name, hed__Account__r.Parent.Type, hed__Account__r.Parent.Parent.Name, hed__Account__r.Parent.Parent.Type, TB_Employee_Affiliation_Type__c,TB_Organization_Unit_Type__c FROM hed__Affl_Accounts__r WHERE TB_Employment_Group__c IN :availableAffiliations AND hed__Status__c = :currentStatus AND hed__Affiliation_Type__c = :department AND TB_Organization_Unit_Type__c IN :organizationType AND (TB_Employee_Affiliation_Type__c = :agreement OR TB_Employee_Affiliation_Type__c = :research)) FROM Contact WHERE RecordTypeId = :employeeRTId AND TB_Current_Employment_Group__c IN :availableAffiliations AND (Name LIKE \'%' +
        userInput[0] +
        '%\' OR TB_ORCID__c LIKE \'%' +
        userInput[0] +
        '%\' OR TB_ERP_Id__c LIKE  \'%' +
        userInput[0] +
        '%\' OR TB_x_Non_diacritic_First_Name__c LIKE \'%' +
        userInput[0] +
        '%\' OR TB_x_Non_diacritic_Last_Name__c LIKE \'%' +
        userInput[0] +
        '%\') LIMIT 15';
    } else {
      contactQuery =
        'SELECT Id, TB_ERP_Id__c, FirstName, LastName, hed__WorkEmail__c, TB_ORCID__c, (SELECT ID, TB_Discipline__c, TB_Discipline_Percentage_Share__c FROM hed__Attributes__r WHERE hed__End_Date__c = NULL AND TB_Discipline__c != NULL AND hed__Start_Date__c < TODAY AND RecordTypeId =: attributeRTId), (SELECT ID, Name, hed__Account__r.Name, hed__Account__r.ParentId, hed__Account__r.Parent.ParentId, hed__Account__r.Type, hed__Account__r.Parent.Name, hed__Account__r.Parent.Type, hed__Account__r.Parent.Parent.Name, hed__Account__r.Parent.Parent.Type, TB_Employee_Affiliation_Type__c,TB_Organization_Unit_Type__c FROM hed__Affl_Accounts__r WHERE hed__Status__c = :currentStatus AND hed__Affiliation_Type__c = :department AND TB_Organization_Unit_Type__c IN :organizationType AND (TB_Employee_Affiliation_Type__c = :agreement OR TB_Employee_Affiliation_Type__c = :research)) FROM Contact WHERE RecordTypeId = :employeeRTId AND TB_Current_Employment_Group__c IN :availableAffiliations AND (( FirstName LIKE \'' +
        userInput[0] +
        '%\' AND LastName LIKE \'%' +
        userInput[1] +
        '%\' ) OR (FirstName LIKE \'' +
        userInput[1] +
        '%\' AND LastName LIKE \'%' +
        userInput[0] +
        '%\') OR ( TB_x_Non_diacritic_First_Name__c LIKE \'' +
        userInput[0] +
        '%\' AND TB_x_Non_diacritic_Last_Name__c LIKE \'%' +
        userInput[1] +
        '%\' ) OR (TB_x_Non_diacritic_First_Name__c LIKE \'' +
        userInput[1] +
        '%\' AND TB_x_Non_diacritic_Last_Name__c LIKE \'%' +
        userInput[0] +
        '%\') OR TB_ORCID__c LIKE \'%' +
        userInput[0] +
        '%\' OR TB_ERP_Id__c LIKE \'%' +
        userInput[0] +
        '%\') LIMIT 15';
    }
    try {
      contacts = Database.query(contactQuery);
    } catch (Exception e) {
      System.debug(e);
    }
    System.debug(contacts);
    List<Contact> employees = new List<Contact>();
    if (contacts.size() > 0) {
      for (Contact contact : contacts) {
        Account account;
        for (hed__Affiliation__c affiliation : contact.hed__Affl_Accounts__r) {
          if (
            affiliation.TB_Employee_Affiliation_Type__c.equals(
              TB_pdo_Constants.AGREEMENT
            ) &&
            (affiliation.TB_Organization_Unit_Type__c.equals(
              TB_pdo_Constants.INSTITUTION
            ) ||
            affiliation.TB_Organization_Unit_Type__c.equals(
              TB_pdo_Constants.CATHEDRAL
            ) ||
            affiliation.TB_Organization_Unit_Type__c.equals(
              TB_pdo_Constants.CENTER
            ))
          ) {
            account = affiliation.hed__Account__r;
            System.debug(JSON.serialize(account));
            while (
              account.ParentId != null && (!account.Type.equals(TB_pdo_Constants.DEPARTMENT) && !account.Type.equals(TB_pdo_Constants.INSTITUTE) && !account.Type.equals('Other') && !account.Type.equals(TB_pdo_Constants.CENTER)) 
            )
            {
              System.debug(account.Parent);
              if(account.Parent != null) {
                account = account.Parent;
                System.debug('po acc');
              }
            }
            affiliation.hed__Account__r = account;
            affiliation.hed__Account__r.Parent = null;
            affiliation.hed__Account__r.ParentId = null;
          } else if (
            affiliation.TB_Employee_Affiliation_Type__c.equals(
              TB_pdo_Constants.RESEARCH
            ) &&
            (affiliation.TB_Organization_Unit_Type__c.equals(
              TB_pdo_Constants.INSTITUTE
            )
            ||
            affiliation.TB_Organization_Unit_Type__c.equals(
              TB_pdo_Constants.CENTER))
          ) {
            account = affiliation.hed__Account__r;
            while (
              !account.Type.equals(TB_pdo_Constants.INSTITUTE) && !account.Type.equals(TB_pdo_Constants.CENTER)
            ) {
              System.debug(account.Parent);
              account = account.Parent;
              System.debug('po acc R');  
            }
            affiliation.hed__Account__r = account;
            affiliation.hed__Account__r.Parent = null;
            affiliation.hed__Account__r.ParentId = null;
          }
        }
        employees.add(contact);
      }
    }
    return employees;
  }
}