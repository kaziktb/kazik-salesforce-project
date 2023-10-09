@IsTest
private class TB_MultiContactDuplicateSearchBatchTest {
    @IsTest
	private static void getRelatedObjectsQueryTest() {
		final String OBJECT_NAME = 'hed__Attribute__c';
		final String OBJECT_CONTACT_FIELD_NAME = 'hed__Contact__c';
		final List<String> OBJECT_MATCHING_FIELDS = new List<String>{'TB_x_Document_Search__c'};
		final List<String> CONTACT_MATCHING_FIELDS = new List<String>{'TB_x_Document_Search__c'};
		final String EXPECTED_RESULT = '( SELECT Id, TB_x_Document_Search__c , hed__Contact__r.TB_x_Document_Search__c , hed__Contact__c FROM hed__Attributes__r WHERE hed__Contact__c != null AND ( TB_x_Document_Search__c != null ) )';
		TB_MultiContactDuplicateSearchBatch batch = new TB_MultiContactDuplicateSearchBatch(
			OBJECT_NAME, 
			OBJECT_CONTACT_FIELD_NAME, 
			OBJECT_MATCHING_FIELDS, 
			CONTACT_MATCHING_FIELDS
		);
		Test.startTest();
			String resultQuery = batch.getRelatedObjectsQuery();
		Test.stopTest();

		System.assertEquals(EXPECTED_RESULT, resultQuery, 'Result has to be equal to expected related object query!');
	}

	@IsTest
	private static void startTest_CorrectLocator() {
		final String OBJECT_NAME = 'Contact';
		final List<String> OBJECT_MATCHING_FIELDS = new List<String>{'TB_x_Document_Search__c'};
		TB_MultiContactDuplicateSearchBatch batch = new TB_MultiContactDuplicateSearchBatch(
			OBJECT_NAME, 
			null, 
			OBJECT_MATCHING_FIELDS, 
			null
		);
		Test.startTest();
			Database.QueryLocator result = batch.start(null);
		Test.stopTest();

		System.assertNotEquals(null, result, 'Result query locator cannot to be null!');
	}

	@IsTest
	private static void startTest_OneRelatedRecord() {
		final String OBJECT_NAME = 'hed__Attribute__c';
		final String OBJECT_CONTACT_FIELD_NAME = 'hed__Contact__c';
		final List<String> OBJECT_MATCHING_FIELDS = new List<String>{'hed__Credential_Number__c'};
		final List<String> CONTACT_MATCHING_FIELDS = new List<String>{'LastName'};
		Contact testContact = TB_TestDataFactory.createContact();
		testContact.LastName = 'TEST DUPLICATE';
        insert testContact;
		hed__Attribute__c testAttribute = TB_TestDataFactory.prepareContactAttribute(testContact.Id, false);
		testAttribute.hed__Credential_Number__c = 'TEST DUPLICATE';
		insert testAttribute;
		TB_TestDataFactory.prepareContactAttribute(testContact.Id, true);
		TB_MultiContactDuplicateSearchBatch batch = new TB_MultiContactDuplicateSearchBatch(
			OBJECT_NAME, 
			OBJECT_CONTACT_FIELD_NAME, 
			OBJECT_MATCHING_FIELDS, 
			CONTACT_MATCHING_FIELDS
		);
		Test.startTest();
			Database.QueryLocator queryLocator = batch.start(null);
			List<Contact> contacts = Database.query(queryLocator.getQuery());
		Test.stopTest();

		System.assertNotEquals(null, queryLocator, 'Result query locator cannot to be null!');
		System.assertEquals(1, contacts.size(), 'Result contacts list size has to be equal to 1!');
		System.assertEquals(1, contacts[0].hed__Attributes__r.size(), 'Result contact attributes list size has to be equal to 1!');
	}

	@IsTest
	private static void batchTest() {
		final String OBJECT_NAME = 'hed__Attribute__c';
		final String OBJECT_CONTACT_FIELD_NAME = 'hed__Contact__c';
		final List<String> OBJECT_MATCHING_FIELDS = new List<String>{'hed__Credential_Number__c'};
		final List<String> CONTACT_MATCHING_FIELDS = new List<String>{'LastName'};
		Contact testContact = TB_TestDataFactory.createContact();
		testContact.LastName = 'TEST DUPLICATE';
        insert testContact;
		List<Contact> otherContacts = TB_TestDataFactory.prepareContacts(100, true, 'OTHER CONTACTS');
		hed__Attribute__c testAttribute = TB_TestDataFactory.prepareContactAttribute(testContact.Id, false);
		testAttribute.hed__Credential_Number__c = 'TEST DUPLICATE';
		insert testAttribute;
		TB_TestDataFactory.prepareContactAttributes(otherContacts, true);
		TB_MultiContactDuplicateSearchBatch batch = new TB_MultiContactDuplicateSearchBatch(
			OBJECT_NAME, 
			OBJECT_CONTACT_FIELD_NAME, 
			OBJECT_MATCHING_FIELDS, 
			CONTACT_MATCHING_FIELDS
		);
		Test.startTest();
			Database.QueryLocator queryLocator = batch.start(null);
			List<Contact> contacts = Database.query(queryLocator.getQuery());
			batch.execute(null, contacts);
			batch.finish(null);
		Test.stopTest();

		List<TB_Duplicate_Log__c> logs = [SELECT Id FROM TB_Duplicate_Log__c];
		List<Contact> contactsWithDuplicates = [SELECT Id FROM Contact WHERE TB_Has_Potential_Duplicate__c = true];

		System.assertEquals(1, contactsWithDuplicates.size(), 'Result contacts list size has to be equal to 1!');
		System.assertEquals(1, logs.size(), 'Result log list size has to be equal to 1!');
	}
}