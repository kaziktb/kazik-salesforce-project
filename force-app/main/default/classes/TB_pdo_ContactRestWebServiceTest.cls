@isTest
private class TB_pdo_ContactRestWebServiceTest {
  private static String endpoint;
  private static final String contactRestResource = '/services/apexrest/contacts/';

  @TestSetup
  static void setup() {
    TB_pdo_ContactRestWebServiceTest.endpoint =
      Url.getOrgDomainUrl().toExternalForm() + contactRestResource;
    System.debug(TB_pdo_ContactRestWebServiceTest.endpoint);
    Id attributeRTId = Schema.Sobjecttype.hed__Attribute__c.getRecordTypeInfosByName()
      .get('Credential')
      .getRecordTypeId();
    Id employeeRTId = Schema.Sobjecttype.Contact.getRecordTypeInfosByName()
      .get('Employee')
      .getRecordTypeId();
    Id accRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName()
      .get('University Department')
      .getRecordTypeId();
    List<Contact> contacts = new List<Contact>();

    Account accMain = new Account();
    accMain.DT_Short_Name__c = 'Wydział_WNH';
    accMain.Type = 'Faculty';
    accMain.DT_VDO_ID__c = '99';
    accMain.Name = 'Wydział Nauk';
    accMain.RecordTypeId = accRTId;
    accMain.TB_Active__c = true;
    insert accMain;

    Account acc = new Account();
    acc.DT_Short_Name__c = 'WNH_Kat_Ang_test';
    accMain.Type = 'Cathedral';
    acc.DT_VDO_ID__c = '272';
    acc.Name = 'Katedra anglistyki';
    acc.RecordTypeId = accRTId;
    acc.TB_Active__c = true;
    acc.ParentId = accMain.Id;
    insert acc;

    Contact validContact = new Contact();
    validContact.FirstName = 'Jan';
    validContact.LastName = 'Dzban';
    validContact.TB_ERP_Id__c = 'P9131912';
    validContact.hed__UniversityEmail__c = 'jandzban@gmail.com';
    validContact.TB_ORCID__c = '11231-1312-41231-31321';
    validContact.TB_Current_Employment_Group__c = 'AEBS';
    validContact.RecordTypeId = employeeRTId;
    contacts.add(validContact);

    Contact invalidContact = new Contact();
    invalidContact.FirstName = 'Artur';
    invalidContact.LastName = 'Szpilka';
    invalidContact.TB_ERP_Id__c = 'P342342';
    invalidContact.hed__UniversityEmail__c = 'szpila@gmail.com';
    invalidContact.TB_ORCID__c = '4123-132-5-3131321';
    invalidContact.RecordTypeId = employeeRTId;
    contacts.add(invalidContact);

    insert contacts;

    hed__Affiliation__c affl = new hed__Affiliation__c();
    affl.hed__Status__c = 'Current';
    affl.TB_Employee_Affiliation_Type__c = 'Agreement';
    affl.hed__Contact__c = validContact.id;
    affl.hed__Account__c = acc.id;
    insert affl;

    hed__Attribute__c attribute = new hed__Attribute__c();
    attribute.hed__Start_Date__c = System.today() - 2;
    attribute.TB_Discipline_Percentage_Share__c = '50';
    attribute.hed__Attribute_Type__c = 'Discipline';
    attribute.TB_Discipline__c = 'literaturoznawstwo';
    attribute.hed__Contact__c = validContact.id;
    attribute.RecordTypeId = attributeRTId;
    insert attribute;
  }

  @isTest
  static void checkIfReturnsValidContact() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestUri = '/services/apexrest/contacts/filter%3Ddzban';
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    Test.startTest();
    List<Contact> contacts = TB_pdo_ContactRestWebService.getEmployeeCatalog();
    Test.stopTest();
    System.assertEquals(contacts.size(), 1);
  }

  @isTest
  static void checkIfDoesntReturnContactWithMissingData() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestUri = '/services/apexrest/contacts/filter%3Dszpilka';
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    Test.startTest();
    List<Contact> contacts = TB_pdo_ContactRestWebService.getEmployeeCatalog();
    Test.stopTest();
    System.debug(contacts);
    System.assertEquals(contacts.size(), 0);
  }
}