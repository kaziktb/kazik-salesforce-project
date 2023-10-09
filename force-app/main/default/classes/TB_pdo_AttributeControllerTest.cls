@IsTest
private class TB_pdo_AttributeControllerTest {
  @TestSetup
  static void testSetup() {
    Contact con = new Contact(LastName = 'Test');
    insert con;
    RecordType rtCredential = [
      SELECT Id
      FROM RecordType
      WHERE SobjectType = 'hed__Attribute__c' AND DeveloperName = 'Credential'
      LIMIT 1
    ];
    hed__Attribute__c attr = new hed__Attribute__c();
    attr.RecordTypeId = rtCredential.Id;
    attr.hed__Attribute_Type__c = 'Discipline';
    attr.hed__Start_Date__c = Date.today().addDays(-3);
    attr.Name = 'Test Discipline';
    attr.TB_Discipline_Order__c = 1;
    attr.hed__Contact__c = con.Id;
    insert attr;
  }
  @IsTest
  static void shouldReturnListWithOneAttribute() {
    Integer expectedResultOfList = 1;
    Contact con = [SELECT Id FROM Contact WHERE LastName = 'Test' LIMIT 1];

    Test.startTest();
    List<hed__Attribute__c> attributesResult = TB_pdo_AttributeController.getAttributes(
      'Credential',
      'Discipline',
      con.Id
    );
    Test.stopTest();

    System.assertEquals(expectedResultOfList, attributesResult.size());
  }
}