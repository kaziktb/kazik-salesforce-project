/**
 * Created by jakubWrzodek on 19/01/23.
 */
@IsTest
private class TB_MultiContactAffiliationTriggerTest {
	private static TB_Contact_Affiliation_Counter__mdt createAffiliationCounterMetadata(String contactCounterName) {
		return new TB_Contact_Affiliation_Counter__mdt(
			TB_Contact_Counter_API_Name__c = contactCounterName,
			DeveloperName = TB_re_TestDataFactory.generateUniqueText('TestMetadata')
		);
	}
	@IsTest
	private static void filterAffiliationsTest() {
		System.runAs(TB_re_TestDataFactory.createAdminUser()) {
			List<Contact> testContacts = TB_re_TestDataFactory.createContactListWithInsert(10);
			List<Account> testAccounts = TB_re_TestDataFactory.createAccountListWithInsert(10);
			Map<Id, hed__Affiliation__c> testOldAffiliationMap = TB_re_TestDataFactory.createAffiliationMap(testContacts, testAccounts);
			List<hed__Affiliation__c> testNewAffiliations = new List<hed__Affiliation__c>();
			Integer counter = 0;
			for (hed__Affiliation__c affiliation : testOldAffiliationMap.values()) {
				counter++;
				hed__Affiliation__c testAffiliation = TB_re_TestDataFactory.createAffiliation(testContacts[counter-1], testAccounts[counter-1]);
				testAffiliation.Id = affiliation.Id;
				if (Math.mod(counter, 3) == 0) {
					testAffiliation.TB_Level_of_Study__c = 'TestValueB';
				}
				testNewAffiliations.add(testAffiliation);
			}

			Test.startTest();
				List<hed__Affiliation__c> testResult = TB_MultiContactAffiliationTriggerHandler.filterAffiliations(testOldAffiliationMap, testNewAffiliations);
			Test.stopTest();

			System.assertEquals(3, testResult.size(), 'Size of result list has to be equal to 3!');
		}
	}

	@IsTest
	private static void isAffiliationMatchingToRuleTest_IsMatching() {
		System.runAs(TB_re_TestDataFactory.createAdminUser()) {
			hed__Affiliation__c testAffiliation = TB_re_TestDataFactory.createAffiliationWithContactAndAccount();
			testAffiliation.put('hed__Role__c', TB_re_Constants.CONTACT_ROLE_STUDENT);
			testAffiliation.put('TB_Level_of_Study__c', 'MatchingLevelOfStudy');
			TB_Contact_Affiliation_Counter__mdt metadata = createAffiliationCounterMetadata('Student_PG');
			metadata.put(TB_MultiContactAffiliationTriggerHandler.AFFILIATION_FIELDS_TO_MDT_FIELDS_MAP.get('hed__Role__c'), TB_re_Constants.CONTACT_ROLE_STUDENT);
			metadata.put(TB_MultiContactAffiliationTriggerHandler.AFFILIATION_FIELDS_TO_MDT_FIELDS_MAP.get('TB_Level_of_Study__c'), 'MatchingLevelOfStudy');

			Test.startTest();
				Boolean testResult = TB_MultiContactAffiliationTriggerHandler.isAffiliationMatchingToRule(testAffiliation, metadata);
			Test.stopTest();

			System.assert(testResult, 'Result has to be true!');
		}
	}

	@IsTest
	private static void isAffiliationMatchingToRuleTest_IsNotMatching() {
		System.runAs(TB_re_TestDataFactory.createAdminUser()) {
			hed__Affiliation__c testAffiliation = TB_re_TestDataFactory.createAffiliationWithContactAndAccount();
			testAffiliation.hed__Role__c = TB_re_Constants.CONTACT_ROLE_STUDENT;
			testAffiliation.TB_Level_of_Study__c = 'MatchingLevelOfStudy';
			TB_Contact_Affiliation_Counter__mdt metadata = createAffiliationCounterMetadata('Student_PG');
			metadata.put(TB_MultiContactAffiliationTriggerHandler.AFFILIATION_FIELDS_TO_MDT_FIELDS_MAP.get('hed__Role__c'), 'NotMatchingRole');
			metadata.put(TB_MultiContactAffiliationTriggerHandler.AFFILIATION_FIELDS_TO_MDT_FIELDS_MAP.get('TB_Level_of_Study__c'), 'MatchingLevelOfStudy');

			Test.startTest();
				Boolean testResult = TB_MultiContactAffiliationTriggerHandler.isAffiliationMatchingToRule(testAffiliation, metadata);
			Test.stopTest();

			System.assert(!testResult, 'Result has to be false!');
		}
	}

	@IsTest
	private static void updateParentContactPersonTypeCountersTest() {
		System.runAs(TB_re_TestDataFactory.createAdminUser()) {
			TB_StaticTest.setDoNotRunTriggers();
			Contact testContact = TB_re_TestDataFactory.createContact();
			testContact.TB_Student_Counter_HE__c = 99;
			insert testContact;
	
			List<Contact> testContacts = TB_re_TestDataFactory.createContactListWithInsert(10);
			List<Account> testAccounts = TB_re_TestDataFactory.createAccountListWithInsert(10);
			List<hed__Affiliation__c> testAffiliations = TB_re_TestDataFactory.createAffiliationList(testContacts, testAccounts);
			for (Integer i = 0; i < testAffiliations.size(); i++) {
				testAffiliations[i].hed__Contact__c = testContact.Id;
				if (Math.mod(i, 3) == 0) {
					testAffiliations[i].hed__Role__c = TB_re_Constants.CONTACT_ROLE_STUDENT;
				} else if (Math.mod(i, 2) == 0) {
					testAffiliations[i].TB_Level_of_Study__c = TB_re_Constants.AFFILIATION_STUDY_LEVEL_BACHELOR;
				}
			}
			insert testAffiliations;

			TB_Contact_Affiliation_Counter__mdt metadataA = createAffiliationCounterMetadata('TB_Student_Counter_PG__c');
			metadataA.put(TB_MultiContactAffiliationTriggerHandler.AFFILIATION_FIELDS_TO_MDT_FIELDS_MAP.get('hed__Role__c'), TB_re_Constants.CONTACT_ROLE_STUDENT);
			TB_Contact_Affiliation_Counter__mdt metadataB = createAffiliationCounterMetadata('TB_Student_Counter_HE__c');
			metadataB.put(TB_MultiContactAffiliationTriggerHandler.AFFILIATION_FIELDS_TO_MDT_FIELDS_MAP.get('TB_Level_of_Study__c'), TB_re_Constants.AFFILIATION_STUDY_LEVEL_BACHELOR);

			Test.startTest();
				TB_MultiContactAffiliationTriggerHandler.updateParentContactPersonTypeCounters(
					new List<hed__Affiliation__c>{ testAffiliations[0] }, 
					new List<TB_Contact_Affiliation_Counter__mdt>{ metadataA, metadataB }
				);
			Test.stopTest();

			Contact resultContact = [SELECT TB_Student_Counter_PG__c, TB_Student_Counter_HE__c FROM Contact WHERE Id = :testContact.Id];
			System.debug(resultContact);

			System.assertEquals(4, resultContact.TB_Student_Counter_PG__c, 'Result counter Student_PG has to be equal to 4!');
			System.assertEquals(3, resultContact.TB_Student_Counter_HE__c, 'Result counter Student_HE has to be equal to 3!');
		}
	}

	@IsTest
	private static void updateParentContactPersonTypeCountersTest_OneContactField() {
		System.runAs(TB_re_TestDataFactory.createAdminUser()) {
			TB_StaticTest.setDoNotRunTriggers();
			Contact testContact = TB_re_TestDataFactory.createContact();
			testContact.TB_Student_Counter_HE__c = 99;
			insert testContact;
	
			List<Contact> testContacts = TB_re_TestDataFactory.createContactListWithInsert(10);
			List<Account> testAccounts = TB_re_TestDataFactory.createAccountListWithInsert(10);
			List<hed__Affiliation__c> testAffiliations = TB_re_TestDataFactory.createAffiliationList(testContacts, testAccounts);
			for (Integer i = 0; i < testAffiliations.size(); i++) {
				testAffiliations[i].hed__Contact__c = testContact.Id;
				if (Math.mod(i, 3) == 0) {
					testAffiliations[i].hed__Role__c = TB_re_Constants.CONTACT_ROLE_STUDENT;
				} else if (Math.mod(i, 2) == 0) {
					testAffiliations[i].TB_Level_of_Study__c = TB_re_Constants.AFFILIATION_STUDY_LEVEL_BACHELOR;
				}
			}
			insert testAffiliations;

			TB_Contact_Affiliation_Counter__mdt metadataA = createAffiliationCounterMetadata('TB_Student_Counter_HE__c');
			metadataA.put(TB_MultiContactAffiliationTriggerHandler.AFFILIATION_FIELDS_TO_MDT_FIELDS_MAP.get('hed__Role__c'), TB_re_Constants.CONTACT_ROLE_STUDENT);
			TB_Contact_Affiliation_Counter__mdt metadataB = createAffiliationCounterMetadata('TB_Student_Counter_HE__c');
			metadataB.put(TB_MultiContactAffiliationTriggerHandler.AFFILIATION_FIELDS_TO_MDT_FIELDS_MAP.get('TB_Level_of_Study__c'), TB_re_Constants.AFFILIATION_STUDY_LEVEL_BACHELOR);

			Test.startTest();
				TB_MultiContactAffiliationTriggerHandler.updateParentContactPersonTypeCounters(
					new List<hed__Affiliation__c>{ testAffiliations[0] }, 
					new List<TB_Contact_Affiliation_Counter__mdt>{ metadataA, metadataB }
				);
			Test.stopTest();

			Contact resultContact = [SELECT TB_Student_Counter_PG__c, TB_Student_Counter_HE__c FROM Contact WHERE Id = :testContact.Id];
			System.debug(resultContact);

			System.assertEquals(7, resultContact.TB_Student_Counter_HE__c, 'Result counter Student_HE has to be equal to 7!');
		}
	}

	@IsTest
	private static void updateParentContactPersonTypeCountersTest_NoMdts() {
		System.runAs(TB_re_TestDataFactory.createAdminUser()) {
			TB_StaticTest.setDoNotRunTriggers();

			Test.startTest();
				TB_MultiContactAffiliationTriggerHandler.updateParentContactPersonTypeCounters(
					new List<hed__Affiliation__c>{TB_re_TestDataFactory.createAffiliationWithContactAndAccount()}, 
					new List<TB_Contact_Affiliation_Counter__mdt>()
				);
			Test.stopTest();
		}
	}

	@IsTest
	private static void futureUpdateParentContactPersonTypeCountersNullIds() {
		Test.startTest();
			TB_MultiContactAffiliationTriggerHandler.futureUpdateParentContactPersonTypeCounters(null);
		Test.stopTest();
		System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
	}
}