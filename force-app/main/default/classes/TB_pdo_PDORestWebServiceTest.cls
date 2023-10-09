@isTest
private class TB_pdo_PDORestWebServiceTest {
  private static final String pdoRestResource = '/services/apexrest/pdo/';
  private static final String draftRequest = '{\"actor\":\"hue.mungus+autor@gmail.com\",\"itemID\":\"6969-xxxx-dddd-69xde\",\"itemType\":\"Article\",\"eventType\":\"DRAFT\",\"metadataList\":{\"dspace_entity_type\":[{\"value\":\"Article\",\"position\":0,\"authority\":\"null\"}]},\"itemVersion\":null,\"workspaceLink\":\"http://localhost:4000/workspaceitems/888989/edit\",\"workflowLink\":null,\"repoLink\":null,\"editorComment\":null}';
  private static final String failedDraftRequest = '{\"actor\":\"hue.mungus+autor@gmail.com\",\"itemID\":\"6969-xxxx-dddd-69xdeee\",\"itemType\":\"Article\",\"eventType\":\"DRAFT\",\"metadataList\":{\"dspace_entity_type\":[{\"value\":\"Article\",\"position\":0,\"authority\":\"null\"}]},\"itemVersion\":null,\"workspaceLink\":\"http://localhost:4000/workspaceitems/888989/edit\",\"workflowLink\":null,\"repoLink\":null,\"editorComment\":null}';
  private static final String correctionDraftRequest = '{\"eventType\":\"DRAFT\",\"itemID\":\"4eb1fb34-d28a-4657-8dd5-a8b590f82a35\",\"actor\":\"hue.mungus+autor@gmail.com\",\"itemType\":\"Article\",\"metadataList\":{\"dc_description_version\":[{\"value\":\"final_published\",\"position\":0,\"authority\":\"null\"}],\"dc_identifier_doi\":[{\"value\":\"129121\",\"position\":0,\"authority\":\"null\"}],\"dc_title\":[{\"value\":\"test123\",\"position\":0,\"authority\":\"null\"}],\"dc_identifier_eissn\":[{\"value\":\"2504-3110\",\"position\":0,\"authority\":\"null\"}],\"dc_date_issued\":[{\"value\":\"2022\",\"position\":0,\"authority\":\"null\"}],\"dc_identifier_uri\":[{\"value\":\"https://repo-test.swps.edu.pl/handle/123456789/75\",\"position\":0,\"authority\":\"null\"}],\"dc_language\":[{\"value\":\"pl\",\"position\":0,\"authority\":\"null\"}],\"dc_description_provenance\":[{\"value\":\"\\\"SubmittedbyIwo(Student)Toczewski(itoczewski@swps.edu.pl)on2022-11-17T09:22:22Zworkflowstart=Step:editstep-action:claimaction\\\\nNo.ofbitstreams:0\\\"\\\\Step:editstep-action:editactionApprovedforentryintoarchivebyKamilHabaj(Redaktor)(kamil.habaj+redaktor@thinkbeyond.cloud)on2022-11-17T09:24:50Z(GMT)\\\\\\\"\\\"MadeavailableinDSpaceon2022-11-17T09:24:50Z(GMT).No.ofbitstreams:0\\\\nPreviousissuedate:2022\\\"\",\"position\":0,\"authority\":\"null\"}],\"dspace_entity_type\":[{\"value\":\"Article\",\"position\":0,\"authority\":\"null\"}],\"dc_title_journal\":[{\"value\":\"FractalandFractional\",\"position\":0,\"authority\":\"null\"}]},\"itemVersion\":1,\"workspaceLink\":\"https://repo-test.swps.edu.pl/workspaceitems/325/edit\",\"workflowLink\":null,\"repoLink\":null,\"editorComment\":null,\"correctionItemID\":\"1321-xxxx-qeas-7812\",\"originalVersionItemID\":null,\"newVersion\":false,\"correction\":true}';
  private static final String failCorrectionDraftWithWrongSourceRequest = '{\"eventType\":\"DRAFT\",\"itemID\":\"4eb1fb34-d28a-4657-8dd5-a8b590f82a35\",\"actor\":\"hue.mungus+autor@gmail.com\",\"itemType\":\"Article\",\"metadataList\":{\"dc_description_version\":[{\"value\":\"final_published\",\"position\":0,\"authority\":\"null\"}],\"dc_identifier_doi\":[{\"value\":\"129121\",\"position\":0,\"authority\":\"null\"}],\"dc_title\":[{\"value\":\"test123\",\"position\":0,\"authority\":\"null\"}],\"dc_identifier_eissn\":[{\"value\":\"2504-3110\",\"position\":0,\"authority\":\"null\"}],\"dc_date_issued\":[{\"value\":\"2022\",\"position\":0,\"authority\":\"null\"}],\"dc_identifier_uri\":[{\"value\":\"https://repo-test.swps.edu.pl/handle/123456789/75\",\"position\":0,\"authority\":\"null\"}],\"dc_language\":[{\"value\":\"pl\",\"position\":0,\"authority\":\"null\"}],\"dc_description_provenance\":[{\"value\":\"\\\"SubmittedbyIwo(Student)Toczewski(itoczewski@swps.edu.pl)on2022-11-17T09:22:22Zworkflowstart=Step:editstep-action:claimaction\\\\nNo.ofbitstreams:0\\\"\\\\Step:editstep-action:editactionApprovedforentryintoarchivebyKamilHabaj(Redaktor)(kamil.habaj+redaktor@thinkbeyond.cloud)on2022-11-17T09:24:50Z(GMT)\\\\\\\"\\\"MadeavailableinDSpaceon2022-11-17T09:24:50Z(GMT).No.ofbitstreams:0\\\\nPreviousissuedate:2022\\\"\",\"position\":0,\"authority\":\"null\"}],\"dspace_entity_type\":[{\"value\":\"Article\",\"position\":0,\"authority\":\"null\"}],\"dc_title_journal\":[{\"value\":\"FractalandFractional\",\"position\":0,\"authority\":\"null\"}]},\"itemVersion\":1,\"workspaceLink\":\"https://repo-test.swps.edu.pl/workspaceitems/325/edit\",\"workflowLink\":null,\"repoLink\":null,\"editorComment\":null,\"correctionItemID\":\"1321-xxxx-qeas-7812adasdasd\",\"originalVersionItemID\":null,\"newVersion\":false,\"correction\":true}';
  private static final String dataModificationRequest = '{\"eventType\":\"DATA_MODIFICATION\",\"itemID\":\"2222-xxxx-qeas-1111\",\"actor\":\"hue.mungus+autor@gmail.com\",\"itemType\":\"Article\",\"metadataList\":{\"dc_description_version\":[{\"value\":\"final_author\",\"position\":0,\"authority\":\"tak\"}],\"dc_identifier_doi\":[{\"value\":\"53643454\",\"position\":0,\"authority\":\"tak\"}],\"dc_title\":[{\"value\":\"TestintegracjiDspace-SalesForce-ScienceCloudDJ12.01\",\"position\":0,\"authority\":\"tak\"}],\"dc_type\":[{\"value\":\"ReviewArticle\",\"position\":0,\"authority\":\"tak\"}],\"dc_identifier_issn\":[{\"value\":\"1092-2172\",\"position\":0,\"authority\":\"tak\"}],\"dc_language\":[{\"value\":\"pl\",\"position\":0,\"authority\":\"tak\"}],\"dc_description_provenance\":[{\"value\":\"SubmittedbyDamianAutor(damian.jozefowski+autor@gmail.com)on2022-11-03T14:50:02Zworkflowstart=Step:editstep-action:claimaction\\nNo.ofbitstreams:0\",\"position\":0,\"authority\":\"nie\"}],\"dspace_entity_type\":[{\"value\":\"Article\",\"position\":0,\"authority\":\"tak\"}],\"dc_title_journal\":[{\"value\":\"MicrobiologyandMolecularBiologyReviews\",\"position\":0,\"authority\":\"tak\"}],\"dc_subject_pl\":[{\"value\":\"he\",\"position\":0,\"authority\":\"tak\"},{\"value\":\"hue\",\"position\":0,\"authority\":\"tak\"},{\"value\":\"ha\",\"position\":0,\"authority\":\"tak\"}],\"dc_subject_en\":[{\"value\":\"eee\",\"position\":0,\"authority\":\"tak\"},{\"value\":\"aaa\",\"position\":0,\"authority\":\"tak\"},{\"value\":\"yyy\",\"position\":0,\"authority\":\"tak\"}],\"dc_contributor_author\":[{\"value\":\"Golota,Andrzej\",\"place\":0,\"authority\":\"P8989898\"},{\"value\":\"Szpilka,Artur\",\"place\":1,\"authority\":\"P8982111\"},{\"value\":\"Michalczewski,Darek\",\"place\":1,\"authority\":\"\"}],\"dc_affiliation\":[{\"value\":\"jakasafiliacja\",\"place\":0,\"authority\":\"P999998\"},{\"value\":\"humany\",\"place\":0,\"authority\":\"P999998\"}],\"dc_contributor_editor\":[{\"value\":\"Golota,Andrzej\",\"place\":0,\"authority\":\"P8989898\"},{\"value\":\"Szpilka,Artur\",\"place\":1,\"authority\":\"P8982111\"},{\"value\":\"Michalczewski,Darek\",\"place\":1,\"authority\":\"\"}]},\"itemVersion\":3,\"workspaceLink\":\"http://localhost:4000/workspaceitems/291/edit\",\"workflowLink\":null,\"repoLink\":null,\"editorComment\":null}';
  private static final String deleteDraftRequest = '{\"actor\":\"hue.mungus+autor@gmail.com\",\"itemID\":\"2222-xxxx-qeas-1111\",\"itemType\":\"Article\",\"eventType\":\"DELETE_DRAFT\",\"metadataList\":null,\"itemVersion\":null,\"workspaceLink\":null,\"workflowLink\":null,\"repoLink\":null,\"editorComment\":null}';
  private static final String editorClaimRequest = '{\"actor\":\"hue.mungus+autor@gmail.com\",\"itemID\":\"2222-xxxx-qeas-1111\",\"itemType\":\"Article\",\"eventType\":\"EDITOR_CLAIM\",\"metadataList\":{\"dc_abstract_pl\":[{\"value\":\"2022\",\"position\":0,\"authority\":\"tak\"}],\"dc_date_accessioned\":[{\"value\":\"2022\",\"position\":0,\"authority\":\"tak\"}],\"dc_date_issued\":[{\"value\":\"2099\",\"position\":0,\"authority\":\"tak\"}],\"dc_abstract_en\":[{\"value\":\"2088\",\"position\":0,\"authority\":\"tak\"}],\"dc_description_version\":[{\"value\":\"final_author\",\"position\":0,\"authority\":\"tak\"}],\"dc_identifier_doi\":[{\"value\":\"53643454\",\"position\":0,\"authority\":\"tak\"}],\"dc_title\":[{\"value\":\"TestintegracjiDspace-SalesForce-ScienceCloudDJ12.01\",\"position\":0,\"authority\":\"tak\"}],\"dc_type\":[{\"value\":\"ReviewArticle\",\"position\":0,\"authority\":\"tak\"}],\"dc_identifier_issn\":[{\"value\":\"1092-2172\",\"position\":0,\"authority\":\"tak\"}],\"dc_language\":[{\"value\":\"pl\",\"position\":0,\"authority\":\"tak\"}],\"dspace_entity_type\":[{\"value\":\"Article\",\"position\":0,\"authority\":\"tak\"}],\"dc_title_journal\":[{\"value\":\"MicrobiologyandMolecularBiologyReviews\",\"position\":0,\"authority\":\"tak\"}],\"dc_subject_pl\":[{\"value\":\"he\",\"position\":0,\"authority\":\"tak\"},{\"value\":\"hue\",\"position\":0,\"authority\":\"tak\"},{\"value\":\"ha\",\"position\":0,\"authority\":\"tak\"}],\"dc_subject_en\":[{\"value\":\"eee\",\"position\":0,\"authority\":\"tak\"},{\"value\":\"aaa\",\"position\":0,\"authority\":\"tak\"},{\"value\":\"yyy\",\"position\":0,\"authority\":\"tak\"}],\"dc_contributor_author\":[{\"value\":\"Szpilka,Artur\",\"place\":0,\"authority\":\"P8982111\"},{\"value\":\"Michalczewski,Darek\",\"place\":1,\"authority\":\"\"},{\"value\":\"Golota,Andrzej\",\"place\":1,\"authority\":\"P8989898\"}]},\"itemVersion\":null,\"workspaceLink\":null,\"workflowLink\":\"http://localhost:4000/workflowitems/61/edit\",\"repoLink\":null,\"editorComment\":null}';
  private static final String editorRejectRequest = '{\"actor\":\"hue.mungus+autor@gmail.com\",\"itemID\":\"2222-xxxx-qeas-1111\",\"itemType\":\"Article\",\"eventType\":\"EDITOR_REJECT\",\"metadataList\":{\"dc_abstract_pl\":[{\"value\":\"2022\",\"position\":0,\"authority\":\"tak\"}],\"dc_date_accessioned\":[{\"value\":\"2022\",\"position\":0,\"authority\":\"tak\"}],\"dc_date_issued\":[{\"value\":\"2099\",\"position\":0,\"authority\":\"tak\"}],\"dc_abstract_en\":[{\"value\":\"2088\",\"position\":0,\"authority\":\"tak\"}],\"dc_description_version\":[{\"value\":\"final_author\",\"position\":0,\"authority\":\"tak\"}],\"dc_identifier_doi\":[{\"value\":\"53643454\",\"position\":0,\"authority\":\"tak\"}],\"dc_title\":[{\"value\":\"TestintegracjiDspace-SalesForce-ScienceCloudDJ12.01\",\"position\":0,\"authority\":\"tak\"}],\"dc_type\":[{\"value\":\"ReviewArticle\",\"position\":0,\"authority\":\"tak\"}],\"dc_identifier_issn\":[{\"value\":\"1092-2172\",\"position\":0,\"authority\":\"tak\"}],\"dc_language\":[{\"value\":\"pl\",\"position\":0,\"authority\":\"tak\"}],\"dspace_entity_type\":[{\"value\":\"Article\",\"position\":0,\"authority\":\"tak\"}],\"dc_title_journal\":[{\"value\":\"MicrobiologyandMolecularBiologyReviews\",\"position\":0,\"authority\":\"tak\"}],\"dc_subject_pl\":[{\"value\":\"he\",\"position\":0,\"authority\":\"tak\"},{\"value\":\"hue\",\"position\":0,\"authority\":\"tak\"},{\"value\":\"ha\",\"position\":0,\"authority\":\"tak\"}],\"dc_subject_en\":[{\"value\":\"eee\",\"position\":0,\"authority\":\"tak\"},{\"value\":\"aaa\",\"position\":0,\"authority\":\"tak\"},{\"value\":\"yyy\",\"position\":0,\"authority\":\"tak\"}],\"dc_contributor_author\":[{\"value\":\"Szpilka,Artur\",\"place\":0,\"authority\":\"P8982111\"},{\"value\":\"Michalczewski,Darek\",\"place\":1,\"authority\":\"\"},{\"value\":\"Golota,Andrzej\",\"place\":2,\"authority\":\"P8989898\"}]},\"itemVersion\":null,\"workspaceLink\":null,\"workflowLink\":\"http://localhost:4000/workflowitems/61/edit\",\"repoLink\":null,\"editorComment\":null}';
  private static final String depositArticleSendRequest = '{\"actor\":\"hue.mungus+autor@gmail.com\",\"itemID\":\"1321-xxxx-qeas-7812\",\"itemType\":\"Article\",\"eventType\":\"DEPOSIT\",\"metadataList\":{\"dc_subject_pl\":[{\"value\":\"final_author\",\"position\":0,\"authority\":\"\"}],\"dc_abstract_pl\":[{\"value\":\"final_author\",\"position\":0,\"authority\":\"\"}],\"dc_type\":[{\"value\":\"ReviewArticle\",\"position\":0,\"authority\":\"\"}],\"dc_date_accessioned\":[{\"value\":\"2022\",\"position\":0,\"authority\":\"\"}],\"dc_subject_en\":[{\"value\":\"test123\",\"position\":0,\"authority\":\"\"}],\"dc_identifier_doi\":[{\"value\":\"123123\",\"position\":0,\"authority\":\"\"}],\"dc_contributor_author\":[{\"value\":\"Szpilka,Artur\",\"position\":0,\"authority\":\"P8982111\"}],\"dc_title\":[{\"value\":\"test\",\"position\":0,\"authority\":\"\"}],\"dc_date_issued\":[{\"value\":\"2022\",\"position\":0,\"authority\":\"\"}],\"dc_identifier_issn\":[{\"value\":\"123-4567\",\"position\":0,\"authority\":\"\"}],\"dc_abstract_en\":[{\"value\":\"test2\",\"position\":0,\"authority\":\"\"}],\"dspace_entity_type\":[{\"value\":\"Article\",\"position\":0,\"authority\":\"\"}],\"dc_title_journal\":[{\"value\":\"Test\",\"position\":0,\"authority\":\"\"}],\"dc_description_version\":[{\"value\":\"final_published\",\"position\":0,\"authority\":\"\"}],\"dc_swps_sciencecloud\":[{\"value\":\"send\",\"position\":0,\"authority\":\"\"}]},\"itemVersion\":1,\"workspaceLink\":null,\"workflowLink\":null,\"repoLink\":\"http://localhost:4000/handle/swps/65\",\"editorComment\":null}';
  private static final String depositArticleNoSendRequest = '{\"actor\":\"hue.mungus+autor@gmail.com\",\"itemID\":\"1321-xxxx-qeas-7812\",\"itemType\":\"Article\",\"eventType\":\"DEPOSIT\",\"metadataList\":{\"dc_subject_pl\":[{\"value\":\"final_author\",\"position\":0,\"authority\":\"\"}],\"dc_abstract_pl\":[{\"value\":\"final_author\",\"position\":0,\"authority\":\"\"}],\"dc_type\":[{\"value\":\"ReviewArticle\",\"position\":0,\"authority\":\"\"}],\"dc_date_accessioned\":[{\"value\":\"2022\",\"position\":0,\"authority\":\"\"}],\"dc_subject_en\":[{\"value\":\"test123\",\"position\":0,\"authority\":\"\"}],\"dc_identifier_doi\":[{\"value\":\"123123\",\"position\":0,\"authority\":\"\"}],\"dc_contributor_author\":[{\"value\":\"Szpilka,Artur\",\"position\":0,\"authority\":\"P8982111\"}],\"dc_title\":[{\"value\":\"test\",\"position\":0,\"authority\":\"\"}],\"dc_date_issued\":[{\"value\":\"2022\",\"position\":0,\"authority\":\"\"}],\"dc_identifier_issn\":[{\"value\":\"123-4567\",\"position\":0,\"authority\":\"\"}],\"dc_abstract_en\":[{\"value\":\"test2\",\"position\":0,\"authority\":\"\"}],\"dspace_entity_type\":[{\"value\":\"Article\",\"position\":0,\"authority\":\"\"}],\"dc_title_journal\":[{\"value\":\"Test\",\"position\":0,\"authority\":\"\"}],\"dc_description_version\":[{\"value\":\"original_author\",\"position\":0,\"authority\":\"\"}],\"dc_swps_sciencecloud\":[{\"value\":\"nosend\",\"position\":0,\"authority\":\"\"}]},\"itemVersion\":1,\"workspaceLink\":null,\"workflowLink\":null,\"repoLink\":\"http://localhost:4000/handle/swps/65\",\"editorComment\":null}';
  private static final String depositScienceDataRequest = '{\"actor\":\"hue.mungus+autor@gmail.com\",\"itemID\":\"1321-xxxx-qeas-7812\",\"itemType\":\"Dataset\",\"eventType\":\"DEPOSIT\",\"metadataList\":{\"dc_subject_pl\":[{\"value\":\"final_author\",\"position\":0,\"authority\":\"\"}],\"dc_abstract_pl\":[{\"value\":\"final_author\",\"position\":0,\"authority\":\"\"}],\"dc_type\":[{\"value\":\"ReviewArticle\",\"position\":0,\"authority\":\"\"}],\"dc_date_accessioned\":[{\"value\":\"2022\",\"position\":0,\"authority\":\"\"}],\"dc_subject_en\":[{\"value\":\"test123\",\"position\":0,\"authority\":\"\"}],\"dc_identifier_doi\":[{\"value\":\"123123\",\"position\":0,\"authority\":\"\"}],\"dc_contributor_author\":[{\"value\":\"Szpilka,Artur\",\"position\":0,\"authority\":\"P8982111\"}],\"dc_title\":[{\"value\":\"test\",\"position\":0,\"authority\":\"\"}],\"dc_date_issued\":[{\"value\":\"2022\",\"position\":0,\"authority\":\"\"}],\"dc_identifier_issn\":[{\"value\":\"123-4567\",\"position\":0,\"authority\":\"\"}],\"dc_abstract_en\":[{\"value\":\"test2\",\"position\":0,\"authority\":\"\"}],\"dspace_entity_type\":[{\"value\":\"ScienceData\",\"position\":0,\"authority\":\"\"}],\"dc_title_journal\":[{\"value\":\"Test\",\"position\":0,\"authority\":\"\"}],\"dc_description_version\":[{\"value\":\"final_published\",\"position\":0,\"authority\":\"\"}],\"dc_swps_sciencecloud\":[{\"value\":\"send\",\"position\":0,\"authority\":\"\"}]},\"itemVersion\":1,\"workspaceLink\":null,\"workflowLink\":null,\"repoLink\":\"http://localhost:4000/handle/swps/65\",\"editorComment\":null}';

  private static TB_PDO__c pdo;

  @TestSetup
  static void setup() {
    List<TB_PDO__c> pdos = new List<TB_PDO__c>();
    List<Contact> contacts = new List<Contact>();

    Contact contactMain = new Contact();
    contactMain.FirstName = 'Hue';
    contactMain.LastName = 'Mungus';
    contactMain.hed__WorkEmail__c = 'hue.mungus+autor@gmail.com';
    contactMain.TB_ERP_Id__c = 'P8989898';
    contacts.add(contactMain);

    Contact secondaryContact = new Contact();
    secondaryContact.FirstName = 'Bogdan';
    secondaryContact.LastName = 'Boner';
    secondaryContact.hed__WorkEmail__c = 'hue.mungus+autor@gmail.com';
    secondaryContact.TB_ERP_Id__c = 'P8982111';
    contacts.add(secondaryContact);

    TB_PDO__c duplicatePdo = new TB_PDO__c();
    duplicatePdo.TB_Depositor__c = contactMain.id;
    duplicatePdo.TB_DSpace_Reference_Id__c = '6969-xxxx-dddd-69xdeee';
    pdos.add(duplicatePdo);

    TB_PDO__c sourcePdo = new TB_PDO__c();
    sourcePdo.TB_Depositor__c = contactMain.id;
    sourcePdo.TB_DSpace_Reference_Id__c = '1321-xxxx-qeas-7812';
    pdos.add(sourcePdo);

    TB_PDO__c testPdo = new TB_PDO__c();
    testPdo.TB_Depositor__c = contactMain.id;
    testPdo.TB_DSpace_Reference_Id__c = '2222-xxxx-qeas-1111';
    testPdo.TB_PDO_Status__c = 'To_Correct';
    testPdo.TB_DSpace_Status__c = 'Draft';
    pdos.add(testPdo);

    TB_PDO__c testPdo2 = new TB_PDO__c();
    testPdo2.TB_Depositor__c = contactMain.id;
    testPdo2.TB_DSpace_Reference_Id__c = '33333-xxxx-qeas-2222';
    testPdo2.TB_Sciencecloud_Status__c = 'Improve';
    testPdo2.TB_PDO_Status__c = 'In_Progress';
    testPdo2.TB_Sciencecloud_Reference_Id__c = '15744';
    testPdo2.TB_DSpace_Status__c = 'To_Verify';
    pdos.add(testPdo2);

    TB_PDO__c testPdo3 = new TB_PDO__c();
    testPdo3.TB_Depositor__c = contactMain.id;
    testPdo3.TB_DSpace_Reference_Id__c = '222333-aaaaa-bbbb-33333';
    testPdo3.TB_Sciencecloud_Status__c = 'Verified';
    testPdo3.TB_PDO_Status__c = 'In_Progress';
    testPdo3.TB_Sciencecloud_Reference_Id__c = '15749';
    testPdo3.TB_DSpace_Status__c = 'To_Verify';
    pdos.add(testPdo3);

    insert contacts;
    insert pdos;

    List<TB_PDO_Participant__c> currentParticipants = new List<TB_PDO_Participant__c>{
      new TB_PDO_Participant__c(
        TB_First_Name__c = 'Andrzej',
        TB_Last_Name__c = 'Golota',
        TB_PDO__c = testPdo.id
      ),
      new TB_PDO_Participant__c(
        TB_First_Name__c = 'Artur',
        TB_Last_Name__c = 'Szpilka',
        TB_PDO__c = testPdo.id
      ),
      new TB_PDO_Participant__c(
        TB_First_Name__c = 'Darek',
        TB_Last_Name__c = 'Michalczewski',
        TB_PDO__c = testPdo.id
      )
    };
    insert currentParticipants;

    TB_PDO_Automation_Disable__c setting = new TB_PDO_Automation_Disable__c(
      TB_Disable__c = true
    );
    insert setting;
  }

  @isTest
  static void checkIfDraftWithCorrectionFailed() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestUri = pdoRestResource;
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(
      TB_pdo_PDORestWebServiceTest.failCorrectionDraftWithWrongSourceRequest
    );
    RestContext.request = req;
    RestContext.response = res;
    String payload = req.requestBody.toString();
    Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(
      payload
    );
    Test.startTest();
    TB_pdo_PDORestWebService.Response actualResponse = TB_pdo_PDORestWebService.managePdo();
    Test.stopTest();
    TB_pdo_PDORestWebService.Response expectedResponse = new TB_pdo_PDORestWebService.Response(
      500,
      'No pdo with given source ID was found'
    );
    System.AssertEquals(expectedResponse.statusCode, actualResponse.statusCode);
    System.assertEquals(expectedResponse.message, actualResponse.message);
  }

  @isTest
  static void checkIfDraftWithCorrectionWasCreated() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestUri = pdoRestResource;
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(
      TB_pdo_PDORestWebServiceTest.correctionDraftRequest
    );
    RestContext.request = req;
    RestContext.response = res;
    String payload = req.requestBody.toString();
    Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(
      payload
    );
    Test.startTest();
    TB_pdo_PDORestWebService.Response actualResponse = TB_pdo_PDORestWebService.managePdo();
    Test.stopTest();
    Id pdoId = [
      SELECT Id
      FROM TB_PDO__c
      WHERE TB_DSpace_Reference_Id__c = '4eb1fb34-d28a-4657-8dd5-a8b590f82a35'
    ]
    .Id;
    TB_pdo_PDORestWebService.Response expectedResponse = new TB_pdo_PDORestWebService.Response(
      200,
      'Object inserted under Id ' + pdoId
    );
    System.AssertEquals(expectedResponse.statusCode, actualResponse.statusCode);
    System.AssertEquals(expectedResponse.message, actualResponse.message);
  }

  @isTest
  static void checkIfDraftWithoutCorrectionWasCreated() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestUri = pdoRestResource;
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(TB_pdo_PDORestWebServiceTest.draftRequest);
    RestContext.request = req;
    RestContext.response = res;
    String payload = req.requestBody.toString();
    Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(
      payload
    );
    Test.startTest();
    TB_pdo_PDORestWebService.Response actualResponse = TB_pdo_PDORestWebService.managePdo();
    Test.stopTest();
    Id pdoId = [
      SELECT Id
      FROM TB_PDO__c
      WHERE TB_DSpace_Reference_Id__c = '6969-xxxx-dddd-69xde'
    ]
    .Id;
    TB_pdo_PDORestWebService.Response expectedResponse = new TB_pdo_PDORestWebService.Response(
      200,
      'Object inserted under Id ' + pdoId
    );
    System.Assert(expectedResponse.statusCode == actualResponse.statusCode);
    System.Assert(expectedResponse.message == actualResponse.message);
  }

  @isTest
  static void checkDraftWithDuplicationFailRequest() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestUri = pdoRestResource;
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(
      TB_pdo_PDORestWebServiceTest.failedDraftRequest
    );
    RestContext.request = req;
    RestContext.response = res;

    String payload = req.requestBody.toString();
    Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(
      payload
    );

    Test.startTest();
    TB_pdo_PDORestWebService.Response actualResponse = TB_pdo_PDORestWebService.managePdo();
    Test.stopTest();
    TB_pdo_PDORestWebService.Response expectedResponse = new TB_pdo_PDORestWebService.Response(
      500,
      'Insert failed'
    );
    System.Assert(expectedResponse.statusCode == actualResponse.statusCode);
  }

  @isTest
  static void checkIfDataModificationPassedThrough() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestUri = pdoRestResource;
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(
      TB_pdo_PDORestWebServiceTest.dataModificationRequest
    );
    RestContext.request = req;
    RestContext.response = res;

    String payload = req.requestBody.toString();
    Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(
      payload
    );

    Test.startTest();
    TB_pdo_PDORestWebService.Response actualResponse = TB_pdo_PDORestWebService.managePdo();
    Test.stopTest();
    TB_pdo_PDORestWebService.Response expectedResponse = new TB_pdo_PDORestWebService.Response(
      200,
      'Updated successfully'
    );
    System.Assert(expectedResponse.statusCode == actualResponse.statusCode);
    System.Assert(expectedResponse.message == actualResponse.message);
  }

  @isTest
  static void checkIfRecordWasMarkedWithDeleteDraftCorrectly() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestUri = pdoRestResource;
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(
      TB_pdo_PDORestWebServiceTest.deleteDraftRequest
    );
    RestContext.request = req;
    RestContext.response = res;

    String payload = req.requestBody.toString();
    Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(
      payload
    );
    Test.startTest();
    TB_pdo_PDORestWebService.Response actualResponse = TB_pdo_PDORestWebService.managePdo();
    Test.stopTest();
    TB_pdo_PDORestWebService.Response expectedResponse = new TB_pdo_PDORestWebService.Response(
      200,
      'Record scheduled to be deleted'
    );
    TB_pdo_PDORestWebServiceTest.pdo = [
      SELECT
        TB_Active__c,
        TB_Deleted_at_DSpace__c,
        TB_Repository_Link__c,
        TB_Workflow_Link__c,
        TB_Workspace_Link__c
      FROM TB_PDO__c
      WHERE TB_DSpace_Reference_Id__c = '2222-xxxx-qeas-1111'
    ];
    System.Assert(expectedResponse.statusCode == actualResponse.statusCode);
    System.Assert(expectedResponse.message == actualResponse.message);
    System.Assert(TB_pdo_PDORestWebServiceTest.pdo.TB_Active__c == false);
    System.Assert(
      TB_pdo_PDORestWebServiceTest.pdo.TB_Deleted_at_DSpace__c == true
    );
    System.Assert(
      TB_pdo_PDORestWebServiceTest.pdo.TB_Repository_Link__c == null
    );
    System.Assert(TB_pdo_PDORestWebServiceTest.pdo.TB_Workflow_Link__c == null);
    System.Assert(
      TB_pdo_PDORestWebServiceTest.pdo.TB_Workspace_Link__c == null
    );
  }

  @isTest
  static void checkIfEditorClaimProcessCorrectly() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestUri = pdoRestResource;
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(
      TB_pdo_PDORestWebServiceTest.editorClaimRequest
    );
    RestContext.request = req;
    RestContext.response = res;

    String payload = req.requestBody.toString();
    Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(
      payload
    );
    Test.startTest();
    TB_pdo_PDORestWebService.Response actualResponse = TB_pdo_PDORestWebService.managePdo();

    Test.stopTest();
    TB_pdo_PDORestWebService.Response expectedResponse = new TB_pdo_PDORestWebService.Response(
      200,
      'Record updated with editor claim'
    );
    TB_pdo_PDORestWebServiceTest.pdo = [
      SELECT
        TB_Repository_Link__c,
        TB_Workflow_Link__c,
        TB_Workspace_Link__c,
        TB_PDO_Status__c,
        TB_DSpace_Status__c
      FROM TB_PDO__c
      WHERE TB_DSpace_Reference_Id__c = '2222-xxxx-qeas-1111'
    ];
    System.Assert(expectedResponse.statusCode == actualResponse.statusCode);
    System.Assert(expectedResponse.message == actualResponse.message);
    System.Assert(
      TB_pdo_PDORestWebServiceTest.pdo.TB_Repository_Link__c == null
    );
    System.Assert(
      TB_pdo_PDORestWebServiceTest.pdo.TB_Workflow_Link__c ==
      'http://localhost:4000/workflowitems/61/edit'
    );
    System.Assert(
      TB_pdo_PDORestWebServiceTest.pdo.TB_Workspace_Link__c == null
    );
    System.Assert(
      TB_pdo_PDORestWebServiceTest.pdo.TB_DSpace_Status__c ==
      'Verification_Pending'
    );
    System.Assert(
      TB_pdo_PDORestWebServiceTest.pdo.TB_PDO_Status__c == 'In_Progress'
    );
  }

  @isTest
  static void checkIfEditorRejectProcessCorrectly() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestUri = pdoRestResource;
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(
      TB_pdo_PDORestWebServiceTest.editorRejectRequest
    );
    RestContext.request = req;
    RestContext.response = res;

    String payload = req.requestBody.toString();
    Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(
      payload
    );
    Test.startTest();
    TB_pdo_PDORestWebService.Response actualResponse = TB_pdo_PDORestWebService.managePdo();

    Test.stopTest();
    TB_pdo_PDORestWebService.Response expectedResponse = new TB_pdo_PDORestWebService.Response(
      200,
      'Record updated with editor reject'
    );
    TB_pdo_PDORestWebServiceTest.pdo = [
      SELECT
        TB_Repository_Link__c,
        TB_Workflow_Link__c,
        TB_Workspace_Link__c,
        TB_PDO_Status__c,
        TB_DSpace_Status__c
      FROM TB_PDO__c
      WHERE TB_DSpace_Reference_Id__c = '2222-xxxx-qeas-1111'
    ];
    System.Assert(expectedResponse.statusCode == actualResponse.statusCode);
    System.Assert(expectedResponse.message == actualResponse.message);
    System.Assert(
      TB_pdo_PDORestWebServiceTest.pdo.TB_Repository_Link__c == null
    );
    System.Assert(
      TB_pdo_PDORestWebServiceTest.pdo.TB_Workflow_Link__c ==
      'http://localhost:4000/workflowitems/61/edit'
    );
    System.Assert(
      TB_pdo_PDORestWebServiceTest.pdo.TB_Workspace_Link__c == null
    );
    System.Assert(
      TB_pdo_PDORestWebServiceTest.pdo.TB_DSpace_Status__c ==
      'Verification_Pending'
    );
    System.Assert(
      TB_pdo_PDORestWebServiceTest.pdo.TB_PDO_Status__c == 'To_Correct'
    );
  }

  @isTest
  static void checkIfCorrectStatusesWereAppliedForArticleWithSendFlag() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestUri = pdoRestResource;
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(
      TB_pdo_PDORestWebServiceTest.depositArticleSendRequest
    );
    RestContext.request = req;
    RestContext.response = res;

    TB_pdo_SingleRequestMock fakeTokenResp = new TB_pdo_SingleRequestMock(
      200,
      'Complete',
      '{\"token_type\":\"Bearer\",\"scope\":\"User.Readprofileopenidemail\",\"expires_in\":4392,\"ext_expires_in\":4392,\"access_token\":\"eyJ0eXAiOiJKV1Q\",\"refresh_token\":\"0.AQIAOlg2y0Xk0k\",\"id_token\":\"eyJ0eXAiOiJKV\"}',
      null
    );
    TB_pdo_SingleRequestMock fakeSCresponse = new TB_pdo_SingleRequestMock(
      200,
      'Complete',
      '{\"article\":{\"authors\":[{\"id\":22759,\"title\":\"::0037a00001qNSt8AAG\",\"first_name\":\"ThinkBeyond\",\"last_name\":\"Demo\",\"employment\":false},{\"id\":22752,\"first_name\":null,\"last_name\":\"Sołtysiak(Autor)Apollinary::0037a00001j5xtUAAQ\",\"employment\":false}],\"id\":15732,\"title\":\"Olfactorypreferences,awarenessandsensitivity:individualandculturaldifference\",\"year\":2020,\"language\":\"eng\",\"language_data\":{\"abstracts\":[{\"language_code\":\"pol\",\"content\":\"Loremipsumdolorsitamet,consecteturadipiscingelit.Sedegestasfeugiatmetus,acpellentesquenibhmolestieeget.Sedrhoncusfinibusmattis.Vestibulumsitametsagittismetus.Aeneanmolestierisusatcommodoscelerisque.Suspendisseauctordoloratnuncsollicitudin,egetefficiturnibhmolestie.Phasellusuttellusmi.Sedeuturpisseddiamconguecondimentumsitametseddiam.Etiammollispulvinareros,idrutrumodiovulputateeget.Nullamalesuadasapieninurnaornare,egetmalesuadamiconsequat.Maecenasplaceratfermentumullamcorper.Aeneanposuerenibhmagna,nondapibusnibhfringillaquis.Nullafacilisi.Pellentesqueornareeuismodconvallis.\"},{\"language_code\":\"eng\",\"content\":\"Curabiturmolestieanullaiddapibus.Nuncsitametbibendummauris,inluctussem.Doneclorempurus,mollissedurnanon,elementumrhoncusleo.Nuncvulputateauguelacus,egettempormassacommodoac.Nullaidsodalesquam.Sedsitametaugueatipsumlaoreetultrices.Donecvenenatisnecdoloregetmaximus.Integertristique,estettristiqueeuismod,semdiamaliquetelit,incursuslacusliberoquisurna.Vivamusutesttincidunt,venenatisrisuseget,laciniaipsum.\"}],\"keywords\":[{\"language_code\":\"pol\",\"contents\":\"test,testowo,testowe\"},{\"language_code\":\"eng\",\"contents\":\"test,testing\"}]},\"projects\":[],\"journal\":{\"id\":31359,\"name\":\"Psychiatry,PsychotherapyandClinicalPsychology\",\"issn\":\"2220-1122\",\"eissn\":\"2414-2212\",\"mnisw_id\":25790},\"editing_source_texts\":false,\"translation_pl\":false,\"translation_other\":false,\"review_article\":true,\"issue\":\"4\",\"volume\":\"2\",\"pages\":\"6\",\"open_access\":{\"license\":null,\"sharing_date\":null,\"sharing_moment\":\"2022-11-25T09:21:50Z\",\"delivered\":false,\"sharing_way\":null,\"text_version\":\"FINAL_PUBLISHED\"},\"fee_act\":null,\"fee_free\":null,\"fee_project\":null,\"fee_other\":null,\"fee_amount\":null,\"external_id\":\"3260fdc8-6ff0-4316-ab3f-75c0e7925368\",\"external_ids\":[{\"name\":\"doi\",\"value\":\"99900-00090\"}],\"external_link\":\"https://repo-test.swps.edu.pl/handle/123456789/92\",\"achievement_attachments\":[],\"status\":\"accepted\",\"status_pbn\":\"do_not_send\",\"flags\":[]}}',
      null
    );

    Map<String, HttpCalloutMock> tokenAndDataResp = new Map<String, HttpCalloutMock>();
    tokenAndDataResp.put('callout:TB_Sciencecloud_Auth', fakeTokenResp);
    tokenAndDataResp.put(
      'callout:TB_Sciencecloud_pdo/achievements/external_id/1321-xxxx-qeas-7812',
      fakeSCresponse
    );
    HttpCalloutMock multiCalloutMock = new TB_pdo_MultiRequestMock(
      tokenAndDataResp
    );

    String payload = req.requestBody.toString();
    Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(
      payload
    );
    Test.setMock(HttpCalloutMock.class, multiCalloutMock);
    Test.startTest();
    TB_pdo_PDORestWebService.Response actualResponse = TB_pdo_PDORestWebService.managePdo();
    Test.stopTest();
    TB_pdo_PDORestWebService.Response expectedResponse = new TB_pdo_PDORestWebService.Response(
      200,
      'Record updated successfully'
    );
    TB_pdo_PDORestWebServiceTest.pdo = [
      SELECT
        TB_Repository_Link__c,
        TB_Workflow_Link__c,
        TB_Workspace_Link__c,
        TB_PDO_Status__c,
        TB_DSpace_Status__c,
        TB_Sciencecloud_Editor_Decision__c
      FROM TB_PDO__c
      WHERE TB_DSpace_Reference_Id__c = '1321-xxxx-qeas-7812'
    ];
    System.debug('in test PDO ');
    System.debug(TB_pdo_PDORestWebServiceTest.pdo);
    System.Assert(expectedResponse.statusCode == actualResponse.statusCode);
    System.Assert(expectedResponse.message == actualResponse.message);
    System.Assert(
      TB_pdo_PDORestWebServiceTest.pdo.TB_Repository_Link__c ==
      'http://localhost:4000/handle/swps/65'
    );
    System.Assert(TB_pdo_PDORestWebServiceTest.pdo.TB_Workflow_Link__c == null);
    System.Assert(
      TB_pdo_PDORestWebServiceTest.pdo.TB_Workspace_Link__c == null
    );
    System.AssertEquals(
      'Published', TB_pdo_PDORestWebServiceTest.pdo.TB_DSpace_Status__c
    );
    System.AssertEquals(
      'Published', TB_pdo_PDORestWebServiceTest.pdo.TB_PDO_Status__c
    );
    System.AssertEquals(
      'send', TB_pdo_PDORestWebServiceTest.pdo.TB_Sciencecloud_Editor_Decision__c
    );
  }

  @isTest
  static void checkIfCorrectStatusesWereAppliedForArticleWithNoSendFlag() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestUri = pdoRestResource;
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(
      TB_pdo_PDORestWebServiceTest.depositArticleNoSendRequest
    );
    RestContext.request = req;
    RestContext.response = res;

    TB_pdo_SingleRequestMock fakeTokenResp = new TB_pdo_SingleRequestMock(
      200,
      'Complete',
      '{\"token_type\":\"Bearer\",\"scope\":\"User.Readprofileopenidemail\",\"expires_in\":4392,\"ext_expires_in\":4392,\"access_token\":\"eyJ0eXAiOiJKV1Q\",\"refresh_token\":\"0.AQIAOlg2y0Xk0k\",\"id_token\":\"eyJ0eXAiOiJKV\"}',
      null
    );
    TB_pdo_SingleRequestMock fakeSCresponse = new TB_pdo_SingleRequestMock(
      200,
      'Complete',
      '{\"article\":{\"authors\":[{\"id\":22759,\"title\":\"::0037a00001qNSt8AAG\",\"first_name\":\"ThinkBeyond\",\"last_name\":\"Demo\",\"employment\":false},{\"id\":22752,\"first_name\":null,\"last_name\":\"Sołtysiak(Autor)Apollinary::0037a00001j5xtUAAQ\",\"employment\":false}],\"id\":15732,\"title\":\"Olfactorypreferences,awarenessandsensitivity:individualandculturaldifference\",\"year\":2020,\"language\":\"eng\",\"language_data\":{\"abstracts\":[{\"language_code\":\"pol\",\"content\":\"Loremipsumdolorsitamet,consecteturadipiscingelit.Sedegestasfeugiatmetus,acpellentesquenibhmolestieeget.Sedrhoncusfinibusmattis.Vestibulumsitametsagittismetus.Aeneanmolestierisusatcommodoscelerisque.Suspendisseauctordoloratnuncsollicitudin,egetefficiturnibhmolestie.Phasellusuttellusmi.Sedeuturpisseddiamconguecondimentumsitametseddiam.Etiammollispulvinareros,idrutrumodiovulputateeget.Nullamalesuadasapieninurnaornare,egetmalesuadamiconsequat.Maecenasplaceratfermentumullamcorper.Aeneanposuerenibhmagna,nondapibusnibhfringillaquis.Nullafacilisi.Pellentesqueornareeuismodconvallis.\"},{\"language_code\":\"eng\",\"content\":\"Curabiturmolestieanullaiddapibus.Nuncsitametbibendummauris,inluctussem.Doneclorempurus,mollissedurnanon,elementumrhoncusleo.Nuncvulputateauguelacus,egettempormassacommodoac.Nullaidsodalesquam.Sedsitametaugueatipsumlaoreetultrices.Donecvenenatisnecdoloregetmaximus.Integertristique,estettristiqueeuismod,semdiamaliquetelit,incursuslacusliberoquisurna.Vivamusutesttincidunt,venenatisrisuseget,laciniaipsum.\"}],\"keywords\":[{\"language_code\":\"pol\",\"contents\":\"test,testowo,testowe\"},{\"language_code\":\"eng\",\"contents\":\"test,testing\"}]},\"projects\":[],\"journal\":{\"id\":31359,\"name\":\"Psychiatry,PsychotherapyandClinicalPsychology\",\"issn\":\"2220-1122\",\"eissn\":\"2414-2212\",\"mnisw_id\":25790},\"editing_source_texts\":false,\"translation_pl\":false,\"translation_other\":false,\"review_article\":true,\"issue\":\"4\",\"volume\":\"2\",\"pages\":\"6\",\"open_access\":{\"license\":null,\"sharing_date\":null,\"sharing_moment\":\"2022-11-25T09:21:50Z\",\"delivered\":false,\"sharing_way\":null,\"text_version\":\"FINAL_PUBLISHED\"},\"fee_act\":null,\"fee_free\":null,\"fee_project\":null,\"fee_other\":null,\"fee_amount\":null,\"external_id\":\"3260fdc8-6ff0-4316-ab3f-75c0e7925368\",\"external_ids\":[{\"name\":\"doi\",\"value\":\"99900-00090\"}],\"external_link\":\"https://repo-test.swps.edu.pl/handle/123456789/92\",\"achievement_attachments\":[],\"status\":\"accepted\",\"status_pbn\":\"do_not_send\",\"flags\":[]}}',
      null
    );

    Map<String, HttpCalloutMock> tokenAndDataResp = new Map<String, HttpCalloutMock>();
    tokenAndDataResp.put('callout:TB_Sciencecloud_Auth', fakeTokenResp);
    tokenAndDataResp.put(
      'callout:TB_Sciencecloud_pdo/achievements/external_id/1321-xxxx-qeas-7812',
      fakeSCresponse
    );
    HttpCalloutMock multiCalloutMock = new TB_pdo_MultiRequestMock(
      tokenAndDataResp
    );

    String payload = req.requestBody.toString();
    Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(
      payload
    );
    Test.setMock(HttpCalloutMock.class, multiCalloutMock);
    Test.startTest();
    TB_pdo_PDORestWebService.Response actualResponse = TB_pdo_PDORestWebService.managePdo();
    Test.stopTest();
    TB_pdo_PDORestWebService.Response expectedResponse = new TB_pdo_PDORestWebService.Response(
      200,
      'Record updated successfully'
    );
    TB_pdo_PDORestWebServiceTest.pdo = [
      SELECT
        TB_Repository_Link__c,
        TB_Workflow_Link__c,
        TB_Workspace_Link__c,
        TB_PDO_Status__c,
        TB_DSpace_Status__c,
        TB_Sciencecloud_Editor_Decision__c
      FROM TB_PDO__c
      WHERE TB_DSpace_Reference_Id__c = '1321-xxxx-qeas-7812'
    ];
    System.debug('in test PDO ');
    System.debug(TB_pdo_PDORestWebServiceTest.pdo);
    System.Assert(expectedResponse.statusCode == actualResponse.statusCode);
    System.Assert(expectedResponse.message == actualResponse.message);
    System.Assert(
      TB_pdo_PDORestWebServiceTest.pdo.TB_Repository_Link__c ==
      'http://localhost:4000/handle/swps/65'
    );
    System.Assert(TB_pdo_PDORestWebServiceTest.pdo.TB_Workflow_Link__c == null);
    System.Assert(
      TB_pdo_PDORestWebServiceTest.pdo.TB_Workspace_Link__c == null
    );
    System.AssertEquals(
      'Released', TB_pdo_PDORestWebServiceTest.pdo.TB_DSpace_Status__c
      
    );
    System.AssertEquals(
      'Released', TB_pdo_PDORestWebServiceTest.pdo.TB_PDO_Status__c
      
    );
    System.AssertEquals(
      'nosend', TB_pdo_PDORestWebServiceTest.pdo.TB_Sciencecloud_Editor_Decision__c
    );
  }

  @isTest
  static void checkIfCorrectStatusesWereAppliedForDatasetDepositWithSendFlag() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestUri = pdoRestResource;
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(
      TB_pdo_PDORestWebServiceTest.depositScienceDataRequest
    );
    RestContext.request = req;
    RestContext.response = res;
    TB_pdo_SingleRequestMock fakeTokenResp = new TB_pdo_SingleRequestMock(
      200,
      'Complete',
      '{\"token_type\":\"Bearer\",\"scope\":\"User.Readprofileopenidemail\",\"expires_in\":4392,\"ext_expires_in\":4392,\"access_token\":\"eyJ0eXAiOiJKV1Q\",\"refresh_token\":\"0.AQIAOlg2y0Xk0k\",\"id_token\":\"eyJ0eXAiOiJKV\"}',
      null
    );
    TB_pdo_SingleRequestMock fakeSCresponse = new TB_pdo_SingleRequestMock(
      200,
      'Complete',
      '{\"dataset\":{\"authors\":[{\"id\":22759,\"title\":\"::0037a00001qNSt8AAG\",\"first_name\":\"ThinkBeyond\",\"last_name\":\"Demo\",\"employment\":false},{\"id\":22752,\"first_name\":null,\"last_name\":\"Sołtysiak(Autor)Apollinary::0037a00001j5xtUAAQ\",\"employment\":false}],\"id\":15732,\"title\":\"Olfactorypreferences,awarenessandsensitivity:individualandculturaldifference\",\"year\":2020,\"language\":\"eng\",\"language_data\":{\"abstracts\":[{\"language_code\":\"pol\",\"content\":\"Loremipsumdolorsitamet,consecteturadipiscingelit.Sedegestasfeugiatmetus,acpellentesquenibhmolestieeget.Sedrhoncusfinibusmattis.Vestibulumsitametsagittismetus.Aeneanmolestierisusatcommodoscelerisque.Suspendisseauctordoloratnuncsollicitudin,egetefficiturnibhmolestie.Phasellusuttellusmi.Sedeuturpisseddiamconguecondimentumsitametseddiam.Etiammollispulvinareros,idrutrumodiovulputateeget.Nullamalesuadasapieninurnaornare,egetmalesuadamiconsequat.Maecenasplaceratfermentumullamcorper.Aeneanposuerenibhmagna,nondapibusnibhfringillaquis.Nullafacilisi.Pellentesqueornareeuismodconvallis.\"},{\"language_code\":\"eng\",\"content\":\"Curabiturmolestieanullaiddapibus.Nuncsitametbibendummauris,inluctussem.Doneclorempurus,mollissedurnanon,elementumrhoncusleo.Nuncvulputateauguelacus,egettempormassacommodoac.Nullaidsodalesquam.Sedsitametaugueatipsumlaoreetultrices.Donecvenenatisnecdoloregetmaximus.Integertristique,estettristiqueeuismod,semdiamaliquetelit,incursuslacusliberoquisurna.Vivamusutesttincidunt,venenatisrisuseget,laciniaipsum.\"}],\"keywords\":[{\"language_code\":\"pol\",\"contents\":\"test,testowo,testowe\"},{\"language_code\":\"eng\",\"contents\":\"test,testing\"}]},\"projects\":[],\"journal\":{\"id\":31359,\"name\":\"Psychiatry,PsychotherapyandClinicalPsychology\",\"issn\":\"2220-1122\",\"eissn\":\"2414-2212\",\"mnisw_id\":25790},\"editing_source_texts\":false,\"translation_pl\":false,\"translation_other\":false,\"review_article\":true,\"issue\":\"4\",\"volume\":\"2\",\"pages\":\"6\",\"open_access\":{\"license\":null,\"sharing_date\":null,\"sharing_moment\":\"2022-11-25T09:21:50Z\",\"delivered\":false,\"sharing_way\":null,\"text_version\":\"FINAL_PUBLISHED\"},\"fee_act\":null,\"fee_free\":null,\"fee_project\":null,\"fee_other\":null,\"fee_amount\":null,\"external_id\":\"3260fdc8-6ff0-4316-ab3f-75c0e7925368\",\"external_ids\":[{\"name\":\"doi\",\"value\":\"99900-00090\"}],\"external_link\":\"https://repo-test.swps.edu.pl/handle/123456789/92\",\"achievement_attachments\":[],\"status\":\"accepted\",\"status_pbn\":\"do_not_send\",\"flags\":[]}}',
      null
    );
    Map<String, HttpCalloutMock> tokenAndDataResp = new Map<String, HttpCalloutMock>();
    tokenAndDataResp.put('callout:TB_Sciencecloud_Auth', fakeTokenResp);
    tokenAndDataResp.put(
      'callout:TB_Sciencecloud_pdo/achievements/external_id/1321-xxxx-qeas-7812',
      fakeSCresponse
    );
    HttpCalloutMock multiCalloutMock = new TB_pdo_MultiRequestMock(
      tokenAndDataResp
    );
    String payload = req.requestBody.toString();
    Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(
      payload
    );
    Test.setMock(HttpCalloutMock.class, multiCalloutMock);
    Test.startTest();
    TB_pdo_PDORestWebService.Response actualResponse = TB_pdo_PDORestWebService.managePdo();
    Test.stopTest();
    TB_pdo_PDORestWebService.Response expectedResponse = new TB_pdo_PDORestWebService.Response(
      200,
      'Record updated successfully'
    );
    TB_pdo_PDORestWebServiceTest.pdo = [
      SELECT
        TB_Repository_Link__c,
        TB_Workflow_Link__c,
        TB_Workspace_Link__c,
        TB_PDO_Status__c,
        TB_DSpace_Status__c
      FROM TB_PDO__c
      WHERE TB_DSpace_Reference_Id__c = '1321-xxxx-qeas-7812'
    ];
    System.Assert(expectedResponse.statusCode == actualResponse.statusCode);
    System.Assert(expectedResponse.message == actualResponse.message);
    System.Assert(
      TB_pdo_PDORestWebServiceTest.pdo.TB_Repository_Link__c ==
      'http://localhost:4000/handle/swps/65'
    );
    System.Assert(TB_pdo_PDORestWebServiceTest.pdo.TB_Workflow_Link__c == null);
    System.Assert(
      TB_pdo_PDORestWebServiceTest.pdo.TB_Workspace_Link__c == null
    );
    System.AssertEquals(
      'Published', TB_pdo_PDORestWebServiceTest.pdo.TB_DSpace_Status__c
    );
    System.AssertEquals(
      'Published', TB_pdo_PDORestWebServiceTest.pdo.TB_PDO_Status__c
    );
  }

  @isTest
  static void checkIfStatusesDuringSynchronizationWithScWereChanged() {
    List<String> ids = new List<String>{
      '33333-xxxx-qeas-2222',
      '222333-aaaaa-bbbb-33333'
    };
    TB_pdo_SingleRequestMock fakeTokenResp = new TB_pdo_SingleRequestMock(
      200,
      'Complete',
      '{\"token_type\":\"Bearer\",\"scope\":\"User.Readprofileopenidemail\",\"expires_in\":4392,\"ext_expires_in\":4392,\"access_token\":\"eyJ0eXAiOiJKV1Q\",\"refresh_token\":\"0.AQIAOlg2y0Xk0k\",\"id_token\":\"eyJ0eXAiOiJKV\"}',
      null
    );
    TB_pdo_SingleRequestMock fakeSCresponse = new TB_pdo_SingleRequestMock(
      200,
      'Complete',
      '{\"achievements\":[{\"article\":{\"id\":15744,\"external_id\":\"33333-xxxx-qeas-2222\",\"status\":\"for_approval\"}},{\"article\":{\"id\":15749,\"external_id\":\"222333-aaaaa-bbbb-33333\",\"status\":\"draft\"}}],\"pagination\":{\"page\":1,\"per_page\":2,\"pages\":1}}',
      null
    );
    Map<String, HttpCalloutMock> tokenAndDataResp = new Map<String, HttpCalloutMock>();
    tokenAndDataResp.put('callout:TB_Sciencecloud_Auth', fakeTokenResp);
    tokenAndDataResp.put(
      'callout:TB_Sciencecloud_pdo/achievements/statuses',
      fakeSCresponse
    );
    HttpCalloutMock multiCalloutMock = new TB_pdo_MultiRequestMock(
      tokenAndDataResp
    );
    Test.setMock(HttpCalloutMock.class, multiCalloutMock);
    Test.startTest();
    TB_pdo_PDORestWebService.synchronizePdoStatuses();
    Test.stopTest();
    List<TB_PDO__c> actualPdos = [
      SELECT TB_Sciencecloud_Status__c
      FROM TB_PDO__c
      WHERE TB_DSpace_Reference_Id__c IN :ids
      ORDER BY TB_Sciencecloud_Status__c
    ];
    System.assertEquals('Draft', actualPdos.get(0).TB_Sciencecloud_Status__c);
    System.assertEquals(
      'For_Approval', actualPdos.get(1).TB_Sciencecloud_Status__c
    );
  }
}