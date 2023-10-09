@IsTest 
class TB_MergingContactDuplicatesTest {
    private static final String RESULT_SYSTEM_LOG_LIST_HAS_TO_BE_EMPTY = 'Result system log list has to be empty!';
    private static final String RESULT_CANNOT_BE_NULL = 'Result cannot be null!';
    private static final String RESULT_HAS_BE_CORRECT = 'Result has be correct!';
    private static final String RESULT_HAS_TO_BE_MERGE_CONTACT_WRAPPER = 'Result has to be MergeContactWrapper';
    private static final String REMAINING_CONTACT_CANNOT_BE_NULL = 'Remaining contact cannot be null!';
    private static final String DUPLICATE_CONTACT_CANNOT_BE_NULL = 'Duplicate contact cannot be null!';
    private static final String REMAINING_CONTACT_FIELD_LIST_CANNOT_BE_NULL = 'Remaining contact field list cannot be null!';
    private static final String DUPLICATE_CONTACT_FIELD_LIST_CANNOT_BE_NULL = 'Duplicate contact field list cannot be null!';
    private static final String REMAINING_CONTACT_RELATED_RECORD_LIST_CANNOT_BE_NULL = 'Remaining contact related record list cannot be null!';
    private static final String DUPLICATE_CONTACT_RELATED_RECORD_LIST_CANNOT_BE_NULL = 'Duplicate contact related record list cannot be null!';
    private static final String FIELDS_TO_MERGE_HAS_TO_BE_NULL = 'Fields to merge has to be null!';

    private static Boolean isWhithoutSystemLogs() {
        List<TB_Log__c> systemLogs = TB_QueryBuilder.create()
            .selectFields(new List<String>{'TB_Message__c', 'TB_Stack_Trace__c'})
            .fromSObject('TB_Log__c')
            .perform();
        for (TB_Log__c log : systemLogs) {
            System.debug(log);
        }
        return systemLogs.isEmpty();
    }

    private static TB_Duplicate_Log__c createDuplicateLog(String remainingContactId, String duplicateContactId) {
        return new TB_Duplicate_Log__c(
            TB_Contact__c = remainingContactId,
            TB_Matching_Contact__c = duplicateContactId,
            TB_Source_SObject_Type__c = 'Contact'
        );
    }

    private static TB_Duplicate_Log__c createDuplicateLogWithInsert(String remainingContactId, String duplicateContactId) {
        TB_Duplicate_Log__c result = createDuplicateLog(remainingContactId, duplicateContactId);
        insert result;
        return result;
    }

    private static List<TB_Duplicate_Log__c> createDuplicateLogListWithInsert(List<Contact> remainingContacts, List<Contact> duplicateContacts) {
        List<TB_Duplicate_Log__c> result = new List<TB_Duplicate_Log__c>();
        for (Integer i = 0; i < remainingContacts.size(); i++) {
            result.add(createDuplicateLog(remainingContacts[i].Id, duplicateContacts[i].Id));
        }
        insert result;
        return result;
    }

    private static TB_Duplicate_Contact_Object_Relation__mdt createDuplicateContactMetadata(String objectName, String fieldName) {
		return new TB_Duplicate_Contact_Object_Relation__mdt(
			DeveloperName = TB_re_TestDataFactory.generateUniqueText('TestMetadata'),
            TB_Related_Object_Name__c = objectName,
            TB_Contact_Lookup_Field_Name__c = fieldName
		);
	}

    private static List<TB_Duplicate_Contact_Object_Relation__mdt> createDuplicateContactMetadataList(List<String> objectNames, List<String> fieldNames) {
		List<TB_Duplicate_Contact_Object_Relation__mdt> result = new List<TB_Duplicate_Contact_Object_Relation__mdt>();
        for (Integer i = 0; i < objectNames.size(); i++) {
            result.add(createDuplicateContactMetadata(objectNames[i], fieldNames[i]));
        }
        return result;
	}

    @TestSetup
    private static void testSetup() {
        TB_StaticTest.setDoNotRunTriggers();
        insert new List<Contact>{TB_re_TestDataFactory.createContactFromLastName('TestMain'), TB_re_TestDataFactory.createContactFromLastName('TestDuplicate')};
    }

    @IsTest
	private static void getContactWrapperTest_SingleMdt() {
		System.runAs(TB_re_TestDataFactory.createAdminUser()) {
            Contact contact = [SELECT Id FROM Contact WHERE LastName = 'TestMain' LIMIT 1];
            Contact duplicateContact = [SELECT Id FROM Contact WHERE LastName = 'TestDuplicate' LIMIT 1];
            List<TB_Duplicate_Contact_Object_Relation__mdt> mdts = createDuplicateContactMetadataList(
                new List<String>{'hed__Application__c'}, 
                new List<String>{'hed__Applicant__c'}
            );

			Test.startTest();
                TB_MergingContactDuplicatesController.Wrapper resultWrapper = TB_MergingContactDuplicatesController.getContactWrapper(contact.Id, duplicateContact.Id, mdts);
			Test.stopTest();

            System.assert(isWhithoutSystemLogs(), RESULT_SYSTEM_LOG_LIST_HAS_TO_BE_EMPTY);
			System.assertNotEquals(null, resultWrapper, RESULT_CANNOT_BE_NULL);
            System.assert(resultWrapper.isCorrect, RESULT_HAS_BE_CORRECT);
            System.assert(resultWrapper instanceof TB_MergingContactDuplicatesController.MergeContactWrapper, RESULT_HAS_TO_BE_MERGE_CONTACT_WRAPPER);
            System.assertNotEquals(null, ((TB_MergingContactDuplicatesController.MergeContactWrapper) resultWrapper).remainingContact , REMAINING_CONTACT_CANNOT_BE_NULL);
            System.assertNotEquals(null, ((TB_MergingContactDuplicatesController.MergeContactWrapper) resultWrapper).duplicateContact , DUPLICATE_CONTACT_CANNOT_BE_NULL);
            System.assertNotEquals(null, ((TB_MergingContactDuplicatesController.MergeContactWrapper) resultWrapper).remainingContactWrappedFieldList, REMAINING_CONTACT_FIELD_LIST_CANNOT_BE_NULL);
            System.assertNotEquals(null, ((TB_MergingContactDuplicatesController.MergeContactWrapper) resultWrapper).duplicateContactWrappedFieldList , DUPLICATE_CONTACT_FIELD_LIST_CANNOT_BE_NULL);
            System.assertNotEquals(null, ((TB_MergingContactDuplicatesController.MergeContactWrapper) resultWrapper).remainingContactRelatedRecordsWrappedList, REMAINING_CONTACT_RELATED_RECORD_LIST_CANNOT_BE_NULL);
            System.assertNotEquals(null, ((TB_MergingContactDuplicatesController.MergeContactWrapper) resultWrapper).duplicateContactRelatedRecordsWrappedList , DUPLICATE_CONTACT_RELATED_RECORD_LIST_CANNOT_BE_NULL);
            System.assertEquals(null, ((TB_MergingContactDuplicatesController.MergeContactWrapper) resultWrapper).fieldApiNamesToMerge, FIELDS_TO_MERGE_HAS_TO_BE_NULL);
		}
	}

    @IsTest
	private static void getContactWrapperTest_ThreeMdts() {
		System.runAs(TB_re_TestDataFactory.createAdminUser()) {
            Contact contact = [SELECT Id FROM Contact WHERE LastName = 'TestMain' LIMIT 1];
            Contact duplicateContact = [SELECT Id FROM Contact WHERE LastName = 'TestDuplicate' LIMIT 1];
            List<TB_Duplicate_Contact_Object_Relation__mdt> mdts = createDuplicateContactMetadataList(
                new List<String>{'hed__Application__c', 'hed__Attribute__c', 'hed__Affiliation__c'}, 
                new List<String>{'hed__Applicant__c', 'hed__Contact__c', 'hed__Contact__c'}
            );

			Test.startTest();
                TB_MergingContactDuplicatesController.Wrapper resultWrapper = TB_MergingContactDuplicatesController.getContactWrapper(contact.Id, duplicateContact.Id, mdts);
			Test.stopTest();

            System.assert(isWhithoutSystemLogs(), RESULT_SYSTEM_LOG_LIST_HAS_TO_BE_EMPTY);
			System.assertNotEquals(null, resultWrapper, RESULT_CANNOT_BE_NULL);
            System.assert(resultWrapper.isCorrect, RESULT_HAS_BE_CORRECT);
            System.assert(resultWrapper instanceof TB_MergingContactDuplicatesController.MergeContactWrapper, RESULT_HAS_TO_BE_MERGE_CONTACT_WRAPPER);
            System.assertNotEquals(null, ((TB_MergingContactDuplicatesController.MergeContactWrapper) resultWrapper).remainingContact , REMAINING_CONTACT_CANNOT_BE_NULL);
            System.assertNotEquals(null, ((TB_MergingContactDuplicatesController.MergeContactWrapper) resultWrapper).duplicateContact , DUPLICATE_CONTACT_CANNOT_BE_NULL);
            System.assertNotEquals(null, ((TB_MergingContactDuplicatesController.MergeContactWrapper) resultWrapper).remainingContactWrappedFieldList, REMAINING_CONTACT_FIELD_LIST_CANNOT_BE_NULL);
            System.assertNotEquals(null, ((TB_MergingContactDuplicatesController.MergeContactWrapper) resultWrapper).duplicateContactWrappedFieldList , DUPLICATE_CONTACT_FIELD_LIST_CANNOT_BE_NULL);
            System.assertNotEquals(null, ((TB_MergingContactDuplicatesController.MergeContactWrapper) resultWrapper).remainingContactRelatedRecordsWrappedList, REMAINING_CONTACT_RELATED_RECORD_LIST_CANNOT_BE_NULL);
            System.assertNotEquals(null, ((TB_MergingContactDuplicatesController.MergeContactWrapper) resultWrapper).duplicateContactRelatedRecordsWrappedList, DUPLICATE_CONTACT_RELATED_RECORD_LIST_CANNOT_BE_NULL);
            System.assertEquals(3, ((TB_MergingContactDuplicatesController.MergeContactWrapper) resultWrapper).remainingContactRelatedRecordsWrappedList.size(), 'Remaining contact related record has to have size of 3!');
            System.assertEquals(3, ((TB_MergingContactDuplicatesController.MergeContactWrapper) resultWrapper).duplicateContactRelatedRecordsWrappedList.size(), 'Duplicate contact related record has to have size of 3!');
            System.assertEquals(null, ((TB_MergingContactDuplicatesController.MergeContactWrapper) resultWrapper).fieldApiNamesToMerge, FIELDS_TO_MERGE_HAS_TO_BE_NULL);
		}
	}

    @IsTest
	private static void getContactWrapperTest_NoMdts() {
		System.runAs(TB_re_TestDataFactory.createAdminUser()) {
            Contact contact = [SELECT Id FROM Contact WHERE LastName = 'TestMain' LIMIT 1];
            Contact duplicateContact = [SELECT Id FROM Contact WHERE LastName = 'TestDuplicate' LIMIT 1];
            List<TB_Duplicate_Contact_Object_Relation__mdt> mdts = new List<TB_Duplicate_Contact_Object_Relation__mdt>();

			Test.startTest();
                TB_MergingContactDuplicatesController.Wrapper resultWrapper = TB_MergingContactDuplicatesController.getContactWrapper(contact.Id, duplicateContact.Id, mdts);
			Test.stopTest();

            System.assert(isWhithoutSystemLogs(), RESULT_SYSTEM_LOG_LIST_HAS_TO_BE_EMPTY);
			System.assertNotEquals(null, resultWrapper, RESULT_CANNOT_BE_NULL);
            System.assert(resultWrapper.isCorrect, RESULT_HAS_BE_CORRECT);
            System.assert(resultWrapper instanceof TB_MergingContactDuplicatesController.MergeContactWrapper, RESULT_HAS_TO_BE_MERGE_CONTACT_WRAPPER);
            System.assertNotEquals(null, ((TB_MergingContactDuplicatesController.MergeContactWrapper) resultWrapper).remainingContact , REMAINING_CONTACT_CANNOT_BE_NULL);
            System.assertNotEquals(null, ((TB_MergingContactDuplicatesController.MergeContactWrapper) resultWrapper).duplicateContact , DUPLICATE_CONTACT_CANNOT_BE_NULL);
            System.assertNotEquals(null, ((TB_MergingContactDuplicatesController.MergeContactWrapper) resultWrapper).remainingContactWrappedFieldList, REMAINING_CONTACT_FIELD_LIST_CANNOT_BE_NULL);
            System.assertNotEquals(null, ((TB_MergingContactDuplicatesController.MergeContactWrapper) resultWrapper).duplicateContactWrappedFieldList , DUPLICATE_CONTACT_FIELD_LIST_CANNOT_BE_NULL);
            System.assertNotEquals(null, ((TB_MergingContactDuplicatesController.MergeContactWrapper) resultWrapper).remainingContactRelatedRecordsWrappedList, REMAINING_CONTACT_RELATED_RECORD_LIST_CANNOT_BE_NULL);
            System.assertNotEquals(null, ((TB_MergingContactDuplicatesController.MergeContactWrapper) resultWrapper).duplicateContactRelatedRecordsWrappedList, DUPLICATE_CONTACT_RELATED_RECORD_LIST_CANNOT_BE_NULL);
            System.assert(((TB_MergingContactDuplicatesController.MergeContactWrapper) resultWrapper).remainingContactRelatedRecordsWrappedList.isEmpty(), 'Remaining contact related record has to be empty!');
            System.assert(((TB_MergingContactDuplicatesController.MergeContactWrapper) resultWrapper).duplicateContactRelatedRecordsWrappedList.isEmpty(), 'Duplicate contact related record has to be empty!');
            System.assertEquals(null, ((TB_MergingContactDuplicatesController.MergeContactWrapper) resultWrapper).fieldApiNamesToMerge, FIELDS_TO_MERGE_HAS_TO_BE_NULL);
		}
	}

    @IsTest
	private static void getContactWrapperTest_InvalidId() {
		System.runAs(TB_re_TestDataFactory.createAdminUser()) {
            Contact contact = [SELECT Id FROM Contact WHERE LastName = 'TestMain' LIMIT 1];
            List<TB_Duplicate_Contact_Object_Relation__mdt> mdts = createDuplicateContactMetadataList(
                new List<String>{'hed__Application__c', 'hed__Attribute__c', 'hed__Affiliation__c'}, 
                new List<String>{'hed__Applicant__c', 'hed__Contact__c', 'hed__Contact__c'}
            );
			Test.startTest();
                TB_MergingContactDuplicatesController.Wrapper resultWrapper = TB_MergingContactDuplicatesController.getContactWrapper(contact.Id, 'InvalidId', mdts);
			Test.stopTest();

			System.assertNotEquals(null, resultWrapper, RESULT_CANNOT_BE_NULL);
            System.assert(!resultWrapper.isCorrect, 'Result cannot be correct!');
            System.assert(resultWrapper instanceof TB_MergingContactDuplicatesController.FailureResult, 'Result has to be FailureResult');
		}
	}

    @IsTest
	private static void getContactWrapperTest() {
		System.runAs(TB_re_TestDataFactory.createAdminUser()) {
            Contact contact = [SELECT Id FROM Contact WHERE LastName = 'TestMain' LIMIT 1];
            Contact duplicateContact = [SELECT Id FROM Contact WHERE LastName = 'TestDuplicate' LIMIT 1];

			Test.startTest();
                String result = TB_MergingContactDuplicatesController.getContactWrapper(contact.Id, duplicateContact.Id);
			Test.stopTest();

            System.assert(isWhithoutSystemLogs(), RESULT_SYSTEM_LOG_LIST_HAS_TO_BE_EMPTY);
			System.assert(!String.isBlank(result), 'Result cannot be blank!');
		}
	}

    @IsTest
	private static void getWrappedContactDuplicateLogsWrapperTest_NoLogs() {
		System.runAs(TB_re_TestDataFactory.createAdminUser()) {
            Contact contact = [SELECT Id FROM Contact WHERE LastName = 'TestMain' LIMIT 1];

			Test.startTest();
                TB_MergingContactDuplicatesController.Wrapper resultWrapper = TB_MergingContactDuplicatesController.getWrappedContactDuplicateLogsWrapper(contact.Id);
			Test.stopTest();

            System.assert(isWhithoutSystemLogs(), RESULT_SYSTEM_LOG_LIST_HAS_TO_BE_EMPTY);
			System.assertNotEquals(null, resultWrapper, RESULT_CANNOT_BE_NULL);
            System.assert(resultWrapper instanceof TB_MergingContactDuplicatesController.DuplicateLogsWrapper, 'Result has to be DuplicateLogsWrapper');
            System.assert(((TB_MergingContactDuplicatesController.DuplicateLogsWrapper)resultWrapper).logs.isEmpty(), 'Result wrapper logs has to be empty!');
		}
	}

    @IsTest
	private static void getWrappedContactDuplicateLogsWrapperTest() {
		System.runAs(TB_re_TestDataFactory.createAdminUser()) {
            Contact contact = [SELECT Id FROM Contact WHERE LastName = 'TestMain' LIMIT 1];
            Contact duplicateContact = [SELECT Id FROM Contact WHERE LastName = 'TestDuplicate' LIMIT 1];
            createDuplicateLogListWithInsert(new List<Contact>{contact, contact, contact}, new List<Contact>{duplicateContact, duplicateContact, duplicateContact});

			Test.startTest();
                TB_MergingContactDuplicatesController.Wrapper resultWrapper = TB_MergingContactDuplicatesController.getWrappedContactDuplicateLogsWrapper(contact.Id);
			Test.stopTest();

            System.assert(isWhithoutSystemLogs(), RESULT_SYSTEM_LOG_LIST_HAS_TO_BE_EMPTY);
			System.assertNotEquals(null, resultWrapper, RESULT_CANNOT_BE_NULL);
            System.assert(resultWrapper instanceof TB_MergingContactDuplicatesController.DuplicateLogsWrapper, 'Result has to be DuplicateLogsWrapper');
            System.assertEquals(3, ((TB_MergingContactDuplicatesController.DuplicateLogsWrapper)resultWrapper).logs.size(), 'Result wrapper logs number has to be equal to 10!');
		}
	}

    @IsTest
	private static void getWrappedContactDuplicateLogsWrapperTest_InvalidId() {
		System.runAs(TB_re_TestDataFactory.createAdminUser()) {

			Test.startTest();
                TB_MergingContactDuplicatesController.Wrapper resultWrapper = TB_MergingContactDuplicatesController.getWrappedContactDuplicateLogsWrapper('InvalidContactId');
			Test.stopTest();

			System.assertNotEquals(null, resultWrapper, RESULT_CANNOT_BE_NULL);
            System.assert(resultWrapper instanceof TB_MergingContactDuplicatesController.FailureResult, 'Result has to be FailureResult');
		}
	}

    @IsTest
	private static void getWrappedContactDuplicateLogsTest() {
		System.runAs(TB_re_TestDataFactory.createAdminUser()) {
            Contact contact = [SELECT Id FROM Contact WHERE LastName = 'TestMain' LIMIT 1];
			Test.startTest();
                String result = TB_MergingContactDuplicatesController.getWrappedContactDuplicateLogs(contact.Id);
			Test.stopTest();

            System.assert(isWhithoutSystemLogs(), RESULT_SYSTEM_LOG_LIST_HAS_TO_BE_EMPTY);
			System.assert(!String.isBlank(result), 'Result cannot be blank!');
		}
	}

    @IsTest
	private static void getWrappedDuplicateLogWrapperTest_CorrectLog() {
		System.runAs(TB_re_TestDataFactory.createAdminUser()) {
            System.runAs(TB_re_TestDataFactory.createAdminUser()) {
                Contact contactA = [SELECT Id FROM Contact WHERE LastName = 'TestMain' LIMIT 1];
                Contact contactB = [SELECT Id FROM Contact WHERE LastName = 'TestDuplicate' LIMIT 1];
                TB_Duplicate_Log__c log = createDuplicateLogWithInsert(contactA.Id, contactB.Id);

                Test.startTest();
                    TB_MergingContactDuplicatesController.Wrapper resultWrapper = TB_MergingContactDuplicatesController.getWrappedDuplicateLogWrapper(log.Id);
                Test.stopTest();
    
                System.assert(isWhithoutSystemLogs(), RESULT_SYSTEM_LOG_LIST_HAS_TO_BE_EMPTY);
                System.assertNotEquals(null, resultWrapper, RESULT_CANNOT_BE_NULL);
                System.assert(resultWrapper instanceof TB_MergingContactDuplicatesController.DuplicateLog, 'Result has to be DuplicateLog');
            }
        }
	}

    @IsTest
	private static void getWrappedDuplicateLogWrapperTest_LogWithoutContactField() {
		System.runAs(TB_re_TestDataFactory.createAdminUser()) {
            Contact contact = [SELECT Id FROM Contact WHERE LastName = 'TestMain' LIMIT 1];
            TB_Duplicate_Log__c log = new TB_Duplicate_Log__c(TB_Source_SObject_Id__c = contact.Id, TB_Source_SObject_Type__c = 'Contact');
            insert log;

			Test.startTest();
                TB_MergingContactDuplicatesController.Wrapper resultWrapper = TB_MergingContactDuplicatesController.getWrappedDuplicateLogWrapper(log.Id);
			Test.stopTest();

            System.assertNotEquals(null, resultWrapper, RESULT_CANNOT_BE_NULL);
            System.assert(resultWrapper instanceof TB_MergingContactDuplicatesController.FailureResult, 'Result has to be FailureResult');
		}
	}

    @IsTest
	private static void getWrappedDuplicateLogWrapperTest_InvalidId() {
		System.runAs(TB_re_TestDataFactory.createAdminUser()) {
			Test.startTest();
                TB_MergingContactDuplicatesController.Wrapper resultWrapper = TB_MergingContactDuplicatesController.getWrappedDuplicateLogWrapper('InvalidLogId');
			Test.stopTest();

            System.assertNotEquals(null, resultWrapper, RESULT_CANNOT_BE_NULL);
            System.assert(resultWrapper instanceof TB_MergingContactDuplicatesController.FailureResult, 'Result has to be FailureResult');
		}
	}

    @IsTest
	private static void getWrappedDuplicateLogTest() {
		System.runAs(TB_re_TestDataFactory.createAdminUser()) {
            Contact contactA = [SELECT Id FROM Contact WHERE LastName = 'TestMain' LIMIT 1];
            Contact contactB = [SELECT Id FROM Contact WHERE LastName = 'TestDuplicate' LIMIT 1];
            TB_Duplicate_Log__c log = createDuplicateLogWithInsert(contactA.Id, contactB.Id);

			Test.startTest();
                String result = TB_MergingContactDuplicatesController.getWrappedDuplicateLog(log.Id);
			Test.stopTest();

            System.assert(isWhithoutSystemLogs(), RESULT_SYSTEM_LOG_LIST_HAS_TO_BE_EMPTY);
			System.assert(!String.isBlank(result), 'Result cannot be blank!');
		}
	}

    @IsTest
	private static void mergeContactsWrapperTest_EmptyMtdList() {
		System.runAs(TB_re_TestDataFactory.createAdminUser()) {
            TB_StaticTest.setDoNotRunTriggers();
            Contact remainingContact = [SELECT Id FROM Contact WHERE LastName = 'TestMain' LIMIT 1];
            Contact duplicateContact = [SELECT Id FROM Contact WHERE LastName = 'TestDuplicate' LIMIT 1];
            remainingContact.LastName = 'MergingTestRemainingLastName';
            remainingContact.FirstName = 'MergingTestRemainingName';
            duplicateContact.LastName = 'MergingTestDuplicateLastName';
            duplicateContact.FirstName = 'MergingTestDuplicateName';
            duplicateContact.Email = 'MergingTestDuplicate@test.com';
            duplicateContact.OtherStreet = 'testStreet';
            update new List<Contact>{remainingContact, duplicateContact};
            TB_MergingContactDuplicatesController.MergeContactWrapper wrapper = new TB_MergingContactDuplicatesController.MergeContactWrapper(remainingContact, duplicateContact);
            wrapper.fieldApiNamesToMerge = new List<String>{'FirstName', 'OtherStreet'};

			Test.startTest();
                TB_MergingContactDuplicatesController.Wrapper resultWrapper = TB_MergingContactDuplicatesController.mergeFoundDuplicatedContacts(wrapper, new List<TB_Duplicate_Contact_Object_Relation__mdt>());
			Test.stopTest();

            Contact resultRemainingContact = (Contact) TB_QueryBuilder.create()
                .selectFields(new List<String>{'Id', 'FirstName', 'LastName', 'OtherStreet'})
                .fromSObject('Contact')
                .andWhereIdIsEqual(remainingContact.Id)
                .performSingle();
            Contact resultDuplicateContact = (Contact) TB_QueryBuilder.create()
                .selectId()
                .fromSObject('Contact')
                .andWhereIdIsEqual(duplicateContact.Id)
                .performSingleWithNull();

            System.assert(isWhithoutSystemLogs(), RESULT_SYSTEM_LOG_LIST_HAS_TO_BE_EMPTY);
			System.assertNotEquals(null, resultWrapper, RESULT_CANNOT_BE_NULL);
            System.assertNotEquals(null, resultRemainingContact, 'Result remaining contact cannot be null!');
            System.assertEquals(null, resultDuplicateContact, 'Result duplicate contact has to be null!');
            System.assertEquals('MergingTestDuplicateName', resultRemainingContact.FirstName, 'Result remaining contact has to have duplicate first name');
            System.assertEquals('testStreet', resultRemainingContact.OtherStreet, 'Result remaining contact has to have duplicate other street');
            System.assertNotEquals('MergingTestDuplicateLastName', resultRemainingContact.LastName, 'Result remaining contact cannot have duplicate last name');
            System.assert(resultWrapper instanceof TB_MergingContactDuplicatesController.SuccessResult, 'Result has to be SuccessResult');
		}
	}

    @IsTest
	private static void mergeContactsWrapperTest_WithoutRelatedRecords() {
		System.runAs(TB_re_TestDataFactory.createAdminUser()) {
            TB_StaticTest.setDoNotRunTriggers();
            Contact remainingContact = [SELECT Id FROM Contact WHERE LastName = 'TestMain' LIMIT 1];
            Contact duplicateContact = [SELECT Id FROM Contact WHERE LastName = 'TestDuplicate' LIMIT 1];
            remainingContact.LastName = 'MergingTestRemainingLastName';
            remainingContact.FirstName = 'MergingTestRemainingName';
            duplicateContact.LastName = 'MergingTestDuplicateLastName';
            duplicateContact.FirstName = 'MergingTestDuplicateName';
            duplicateContact.Email = 'MergingTestDuplicate@test.com';
            duplicateContact.OtherStreet = 'testStreet';
            update new List<Contact>{remainingContact, duplicateContact};
            TB_MergingContactDuplicatesController.MergeContactWrapper wrapper = new TB_MergingContactDuplicatesController.MergeContactWrapper(remainingContact, duplicateContact);
            wrapper.fieldApiNamesToMerge = new List<String>{'FirstName', 'OtherStreet'};
            List<TB_Duplicate_Contact_Object_Relation__mdt> mdts = createDuplicateContactMetadataList(
                new List<String>{'hed__Application__c', 'hed__Attribute__c', 'hed__Affiliation__c'}, 
                new List<String>{'hed__Applicant__c', 'hed__Contact__c', 'hed__Contact__c'}
            );

			Test.startTest();
                TB_MergingContactDuplicatesController.Wrapper resultWrapper = TB_MergingContactDuplicatesController.mergeFoundDuplicatedContacts(wrapper, mdts);
			Test.stopTest();

            Contact resultRemainingContact = (Contact) TB_QueryBuilder.create()
                .selectFields(new List<String>{'Id', 'FirstName', 'LastName', 'OtherStreet'})
                .fromSObject('Contact')
                .andWhereIdIsEqual(remainingContact.Id)
                .performSingle();
            Contact resultDuplicateContact = (Contact) TB_QueryBuilder.create()
                .selectId()
                .fromSObject('Contact')
                .andWhereIdIsEqual(duplicateContact.Id)
                .performSingleWithNull();

            System.assert(isWhithoutSystemLogs(), RESULT_SYSTEM_LOG_LIST_HAS_TO_BE_EMPTY);
			System.assertNotEquals(null, resultWrapper, RESULT_CANNOT_BE_NULL);
            System.assertNotEquals(null, resultRemainingContact, 'Result remaining contact cannot be null!');
            System.assertEquals(null, resultDuplicateContact, 'Result duplicate contact has to be null!');
            System.assertEquals('MergingTestDuplicateName', resultRemainingContact.FirstName, 'Result remaining contact has to have duplicate first name');
            System.assertEquals('testStreet', resultRemainingContact.OtherStreet, 'Result remaining contact has to have duplicate pesel');
            System.assertNotEquals('MergingTestDuplicateLastName', resultRemainingContact.LastName, 'Result remaining contact cannot have duplicate last name');
            System.assert(resultWrapper instanceof TB_MergingContactDuplicatesController.SuccessResult, 'Result has to be SuccessResult');
		}
	}

    @IsTest
	private static void mergeContactsWrapperTest_WithRelatedRecords() {
		System.runAs(TB_re_TestDataFactory.createAdminUser()) {
            Contact remainingContact = [SELECT Id FROM Contact WHERE LastName = 'TestMain' LIMIT 1];
            Contact duplicateContact = [SELECT Id FROM Contact WHERE LastName = 'TestDuplicate' LIMIT 1];
            TB_MergingContactDuplicatesController.MergeContactWrapper wrapper = new TB_MergingContactDuplicatesController.MergeContactWrapper(remainingContact, duplicateContact);
            wrapper.fieldApiNamesToMerge = new List<String>();
            List<TB_Duplicate_Contact_Object_Relation__mdt> mdts = createDuplicateContactMetadataList(
                new List<String>{'hed__Application__c', 'hed__Attribute__c', 'hed__Affiliation__c'}, 
                new List<String>{'hed__Applicant__c', 'hed__Contact__c', 'hed__Contact__c'}
            );
            Account testAccount = TB_re_TestDataFactory.createAccountWithInsert();
            TB_re_TestDataFactory.createAffiliationListWithInsert(duplicateContact, testAccount, 3);
            TB_re_TestDataFactory.createAttributeListWithInsert(duplicateContact, 3);

			Test.startTest();
                TB_MergingContactDuplicatesController.Wrapper resultWrapper = TB_MergingContactDuplicatesController.mergeFoundDuplicatedContacts(wrapper, mdts);
			Test.stopTest();

            Contact resultRemainingContact = (Contact) TB_QueryBuilder.create()
                .selectFields(new List<String>{'Id', 'FirstName', 'LastName', 'DT_PESEL__c'})
                .fromSObject('Contact')
                .andWhereIdIsEqual(remainingContact.Id)
                .performSingle();
            Contact resultDuplicateContact = (Contact) TB_QueryBuilder.create()
                .selectId()
                .fromSObject('Contact')
                .andWhereIdIsEqual(duplicateContact.Id)
                .performSingleWithNull();
            List<hed__Affiliation__c> resultAffiliations = (List<hed__Affiliation__c>) TB_QueryBuilder.create()
                .selectId()
                .fromSObject('hed__Affiliation__c')
                .andWhereFieldIsEqual('hed__Contact__c', remainingContact.Id)
                .perform();
            List<hed__Attribute__c> resultAttributes = (List<hed__Attribute__c>) TB_QueryBuilder.create()
                .selectId()
                .fromSObject('hed__Attribute__c')
                .andWhereFieldIsEqual('hed__Contact__c', remainingContact.Id)
                .perform();

           // System.assert(isWhithoutSystemLogs(), RESULT_SYSTEM_LOG_LIST_HAS_TO_BE_EMPTY);
			System.assertNotEquals(null, resultWrapper, RESULT_CANNOT_BE_NULL);
            System.assertNotEquals(null, resultRemainingContact, 'Result remaining contact cannot be null!');
            System.assertEquals(null, resultDuplicateContact, 'Result duplicate contact has to be null!');
            System.assertEquals(3, resultAffiliations.size(), 'Result affiliation size has to be equal to 3');
            System.assertEquals(3, resultAttributes.size(), 'Result attributes size has to be equal to 3');
            System.assert(resultWrapper instanceof TB_MergingContactDuplicatesController.SuccessResult, 'Result has to be SuccessResult');
		}
	}

    @IsTest
	private static void mergeContactsWrapperTest_WithRelatedRecords_WithLogs() {
		System.runAs(TB_re_TestDataFactory.createAdminUser()) {
            Contact remainingContact = [SELECT Id FROM Contact WHERE LastName = 'TestMain' LIMIT 1];
            Contact duplicateContact = [SELECT Id FROM Contact WHERE LastName = 'TestDuplicate' LIMIT 1];
            createDuplicateLogListWithInsert(new List<Contact>{duplicateContact, duplicateContact}, new List<Contact>{remainingContact, remainingContact});
            TB_MergingContactDuplicatesController.MergeContactWrapper wrapper = new TB_MergingContactDuplicatesController.MergeContactWrapper(remainingContact, duplicateContact);
            wrapper.fieldApiNamesToMerge = new List<String>();
            List<TB_Duplicate_Contact_Object_Relation__mdt> mdts = createDuplicateContactMetadataList(
                new List<String>{'hed__Application__c', 'hed__Attribute__c', 'hed__Affiliation__c'}, 
                new List<String>{'hed__Applicant__c', 'hed__Contact__c', 'hed__Contact__c'}
            );
            Account testAccount = TB_re_TestDataFactory.createAccountWithInsert();
            TB_re_TestDataFactory.createAffiliationListWithInsert(duplicateContact, testAccount, 3);
            TB_re_TestDataFactory.createAttributeListWithInsert(duplicateContact, 3);

			Test.startTest();
                TB_MergingContactDuplicatesController.Wrapper resultWrapper = TB_MergingContactDuplicatesController.mergeFoundDuplicatedContacts(wrapper, mdts);
			Test.stopTest();

            Contact resultRemainingContact = (Contact) TB_QueryBuilder.create()
                .selectFields(new List<String>{'Id', 'FirstName', 'LastName', 'DT_PESEL__c'})
                .fromSObject('Contact')
                .andWhereIdIsEqual(remainingContact.Id)
                .performSingle();
            Contact resultDuplicateContact = (Contact) TB_QueryBuilder.create()
                .selectId()
                .fromSObject('Contact')
                .andWhereIdIsEqual(duplicateContact.Id)
                .performSingleWithNull();
            List<hed__Affiliation__c> resultAffiliations = (List<hed__Affiliation__c>) TB_QueryBuilder.create()
                .selectId()
                .fromSObject('hed__Affiliation__c')
                .andWhereFieldIsEqual('hed__Contact__c', remainingContact.Id)
                .perform();
            List<hed__Attribute__c> resultAttributes = (List<hed__Attribute__c>) TB_QueryBuilder.create()
                .selectId()
                .fromSObject('hed__Attribute__c')
                .andWhereFieldIsEqual('hed__Contact__c', remainingContact.Id)
                .perform();
            List<TB_Duplicate_Log__c> resultLogs = (List<TB_Duplicate_Log__c>) TB_QueryBuilder.create()
                .selectId()
                .fromSObject('TB_Duplicate_Log__c')
                .perform();

            //System.assert(isWhithoutSystemLogs(), RESULT_SYSTEM_LOG_LIST_HAS_TO_BE_EMPTY);
			System.assertNotEquals(null, resultWrapper, RESULT_CANNOT_BE_NULL);
            System.assertNotEquals(null, resultRemainingContact, 'Result remaining contact cannot be null!');
            System.assertEquals(null, resultDuplicateContact, 'Result duplicate contact has to be null!');
            System.assertEquals(3, resultAffiliations.size(), 'Result affiliation size has to be equal to 3');
            System.assertEquals(3, resultAttributes.size(), 'Result attributes size has to be equal to 3');
            System.assert(resultLogs.isEmpty(), 'Result log list has to be empty');
            System.assert(resultWrapper instanceof TB_MergingContactDuplicatesController.SuccessResult, 'Result has to be SuccessResult');
		}
	}

    @IsTest
	private static void mergeContactsWrapperTest_WithRelatedRecords_Reversed() {
		System.runAs(TB_re_TestDataFactory.createAdminUser()) {
            Contact remainingContact = [SELECT Id FROM Contact WHERE LastName = 'TestMain' LIMIT 1];
            Contact duplicateContact = [SELECT Id FROM Contact WHERE LastName = 'TestDuplicate' LIMIT 1];
            remainingContact.FirstName = 'MergingTestRemainingName';
            TB_MergingContactDuplicatesController.MergeContactWrapper wrapper = new TB_MergingContactDuplicatesController.MergeContactWrapper(remainingContact, duplicateContact);
            wrapper.fieldApiNamesToMerge = new List<String>{'FirstName'};
            wrapper.isReversed = true;
            List<TB_Duplicate_Contact_Object_Relation__mdt> mdts = createDuplicateContactMetadataList(
                new List<String>{'hed__Application__c', 'hed__Attribute__c', 'hed__Affiliation__c'}, 
                new List<String>{'hed__Applicant__c', 'hed__Contact__c', 'hed__Contact__c'}
            );
            Account testAccount = TB_re_TestDataFactory.createAccountWithInsert();
            TB_re_TestDataFactory.createAffiliationListWithInsert(remainingContact, testAccount, 3);
            TB_re_TestDataFactory.createAttributeListWithInsert(remainingContact, 3);

			Test.startTest();
                TB_MergingContactDuplicatesController.Wrapper resultWrapper = TB_MergingContactDuplicatesController.mergeFoundDuplicatedContacts(wrapper, mdts);
			Test.stopTest();

            Contact resultRemainingContact = (Contact) TB_QueryBuilder.create()
                .selectId()
                .fromSObject('Contact')
                .andWhereIdIsEqual(remainingContact.Id)
                .performSingleWithNull();
            Contact resultDuplicateContact = (Contact) TB_QueryBuilder.create()
                .selectFields(new List<String>{'Id', 'FirstName', 'LastName', 'DT_PESEL__c'})
                .fromSObject('Contact')
                .andWhereIdIsEqual(duplicateContact.Id)
                .performSingle();
            List<hed__Affiliation__c> resultAffiliations = (List<hed__Affiliation__c>) TB_QueryBuilder.create()
                .selectId()
                .fromSObject('hed__Affiliation__c')
                .andWhereFieldIsEqual('hed__Contact__c', duplicateContact.Id)
                .perform();
            List<hed__Attribute__c> resultAttributes = (List<hed__Attribute__c>) TB_QueryBuilder.create()
                .selectId()
                .fromSObject('hed__Attribute__c')
                .andWhereFieldIsEqual('hed__Contact__c', duplicateContact.Id)
                .perform();

            //System.assert(isWhithoutSystemLogs(), RESULT_SYSTEM_LOG_LIST_HAS_TO_BE_EMPTY);
			System.assertNotEquals(null, resultWrapper, RESULT_CANNOT_BE_NULL);
            System.assertNotEquals(null, resultDuplicateContact, 'Result duplicate contact cannot be null!');
            System.assertEquals('MergingTestRemainingName', resultDuplicateContact.FirstName, 'Result duplicate contact field name has to be equal to MergingTestRemainingName!');
            System.assertEquals(null, resultRemainingContact, 'Result remaining contact has to be null!');
            System.assertEquals(3, resultAffiliations.size(), 'Result affiliation size has to be equal to 3');
            System.assertEquals(3, resultAttributes.size(), 'Result attributes size has to be equal to 3');
            System.assert(resultWrapper instanceof TB_MergingContactDuplicatesController.SuccessResult, 'Result has to be SuccessResult');
		}
	}

    @IsTest
	private static void getMergeContactTest() {
		System.runAs(TB_re_TestDataFactory.createAdminUser()) {
            Contact contact = [SELECT Id FROM Contact WHERE LastName = 'TestMain' LIMIT 1];
            Contact duplicateContact = [SELECT Id FROM Contact WHERE LastName = 'TestDuplicate' LIMIT 1];

			Test.startTest();
                String result = TB_MergingContactDuplicatesController.getContactWrapper(contact.Id, duplicateContact.Id);
			Test.stopTest();

            System.assert(isWhithoutSystemLogs(), RESULT_SYSTEM_LOG_LIST_HAS_TO_BE_EMPTY);
			System.assert(!String.isBlank(result), 'Result cannot be blank!');
		}
	}

    @IsTest
	private static void getMergeContactTest_InvalidId() {
		System.runAs(TB_re_TestDataFactory.createAdminUser()) {
            Contact testContact = [SELECT Id FROM Contact WHERE LastName = 'TestMain' LIMIT 1];

			Test.startTest();
                String result = TB_MergingContactDuplicatesController.getContactWrapper(testContact.Id, 'InvalidId');
			Test.stopTest();

            System.assert(!isWhithoutSystemLogs(), 'Result system log list cannot be empty!');
			System.assert(!String.isBlank(result), 'Result cannot be blank!');
		}
	}
}