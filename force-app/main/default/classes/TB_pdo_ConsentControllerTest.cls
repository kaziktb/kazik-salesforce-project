@IsTest
private class TB_pdo_ConsentControllerTest {
  @TestSetup
  static void testSetup() {
    TB_Admissions_Dictionary__c consentBundle = TB_TestDataFactory.createConsentBundle(
      true
    );
    consentBundle.TB_Used_On__c = 'Affiliate_Statement';
    update consentBundle;
    TB_Admissions_Dictionary__c consentDefinition = TB_TestDataFactory.createConsent(
      'Informational',
      consentBundle.Id,
      true
    );
    consentDefinition.TB_Active__c = true;
    update consentDefinition;
  }

  @IsTest
  static void getCreatedConsentTest() {
    String admissionsType = 'Affiliate Statement';
    Integer expectedConsentSize = 1;
    Test.startTest();
    String result = TB_pdo_ConsentController.getConsents(admissionsType);
    Test.stopTest();
    List<TB_Admissions_Dictionary__c> deserializedResult = (List<TB_Admissions_Dictionary__c>) JSON.deserialize(
      result,
      List<TB_Admissions_Dictionary__c>.class
    );

    System.assertEquals(expectedConsentSize, deserializedResult.size());
  }
}