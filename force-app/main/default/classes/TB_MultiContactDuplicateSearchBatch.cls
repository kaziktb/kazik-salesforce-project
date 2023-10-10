global class TB_MultiContactDuplicateSearchBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	final private String LOG_MATCHING_CONTACT_FIELD_NAME = 'TB_Matching_Contact__c';
	final private String CONTACT_MATCHING_FIELD_NAME = 'TB_Matching_Field_Name__c';
	final private String CONTACT_DUPLICATE_CHECBOX_FIELD_NAME = 'TB_Has_Potential_Duplicate__c';
	private Boolean isNotContactToContactComparison;
	public String objectName;
	private String objectPluralName;
	public String objectContactFieldName;
	public List<String> objectMatchingFields;
	public List<String> contactMatchingFields;
	private String objectContactRelationPluralName;
	private String objectContactRelationName;
	private List<SObject> objects = new List<SObject>();
	private List<Contact> contacts = new List<Contact>();

	public TB_MultiContactDuplicateSearchBatch(
		String objectName,		
		String objectContactFieldName,
		List<String> objectMatchingFields,
		List<String> contactMatchingFields
	) {
		this.objectName = objectName;
		this.objectContactFieldName = objectContactFieldName;
		this.objectMatchingFields = objectMatchingFields;
		this.contactMatchingFields = contactMatchingFields;
		this.objectPluralName = TB_SObjectUtils.getSObjectRelationPluralName(objectName);
		this.isNotContactToContactComparison = objectContactFieldName != null && objectContactFieldName != '';
		if (isNotContactToContactComparison) {
			this.objectContactRelationName = TB_SObjectUtils.getSObjectRelationName(objectContactFieldName);
			this.objectContactRelationPluralName = TB_SObjectUtils.getSObjectRelationPluralName(objectContactFieldName);
		}
	}

	public Database.QueryLocator start(Database.BatchableContext context) {
		List<String> fields = isNotContactToContactComparison ? this.contactMatchingFields : this.objectMatchingFields;
		String fieldsToGetString = TB_SObjectUtils.getFieldsToSelectAsString(fields);
		String insideSelectLoop = isNotContactToContactComparison ? ', ' + getRelatedObjectsQuery() : '';
		String query = 
			' SELECT Id, ' + fieldsToGetString + insideSelectLoop + 
			' FROM Contact' + 
			' WHERE ' + CONTACT_DUPLICATE_CHECBOX_FIELD_NAME +' = false AND ' + CONTACT_MATCHING_FIELD_NAME + ' = null';
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext context, List<Contact> scope) {
		contacts.addAll(scope);
		if (isNotContactToContactComparison) {
			for (Contact contact : scope) {
				if (contact.getSobjects(objectPluralName) != null) {
					objects.addAll(contact.getSobjects(objectPluralName));
				}
			}
		} else {
			objects.addAll(scope);
		}
	}

	public void finish(Database.BatchableContext context) {
		List<TB_Duplicate_Log__c> allLogsToInsert = new List<TB_Duplicate_Log__c>();
		List<Contact> allContactsToUpdate = new List<Contact>();
		for (Contact contact : contacts) {
			Boolean hasDuplicate = false;
			for (SObject comparedObject : objects) {
				if (!hasDuplicate) {
					for (Integer i = 0; i < objectMatchingFields.size(); i++) {
						String comparedObjectFieldName = objectMatchingFields[i];
						String comparedContactFieldName = isNotContactToContactComparison ?
							contactMatchingFields[i] :
							objectMatchingFields[i];
						if (contact.Id != comparedObject.Id && comparedObject.get(comparedObjectFieldName) == contact.get(comparedContactFieldName)) {
							hasDuplicate = true;
							TB_Duplicate_Log__c log = new TB_Duplicate_Log__c(
								TB_Contact__c = contact.Id,
								TB_Matching_Field_Name__c = comparedObjectFieldName,
								TB_Contact_Matching_Field_Name__c = comparedContactFieldName,
								TB_Source_SObject_Id__c = comparedObject.Id,
								TB_Source_SObject_Type__c = objectName
							);
							log.put(LOG_MATCHING_CONTACT_FIELD_NAME, isNotContactToContactComparison ?
								comparedObject.get(objectContactFieldName) :
								comparedObject.Id);
							allLogsToInsert.add(log);
							contact.put(CONTACT_DUPLICATE_CHECBOX_FIELD_NAME, true);
							allContactsToUpdate.add(contact);
						}
					}
				}
			}
		}
		if (!isNotContactToContactComparison) {
			allLogsToInsert = filterDuplicateLogs(allLogsToInsert);
		}
		TB_SObjectUtils.safetyMassInsertSObjects(allLogsToInsert);
		TB_SObjectUtils.safetyMassUpdateSObjects(allContactsToUpdate);
	}

	@TestVisible
	private String getRelatedObjectsQuery() {
		String fieldsToGetString = TB_SObjectUtils.getFieldsToSelectAsString(objectMatchingFields);
		String fieldsConditionsString = TB_SObjectUtils.getFieldsAsNotNullConditionsString(objectMatchingFields);
		String relatedFieldsToGetString = TB_SObjectUtils.getFieldsToSelectAsString(contactMatchingFields, objectContactRelationName + '.');
		return 	'( SELECT Id, ' + fieldsToGetString + ', ' + relatedFieldsToGetString + ', ' + objectContactFieldName + 
				' FROM ' + objectPluralName + 
				' WHERE ' + objectContactFieldName + ' != null AND ' + fieldsConditionsString + ' )';
	}

	private List<TB_Duplicate_Log__c> filterDuplicateLogs(List<TB_Duplicate_Log__c> logs) {
		Map<String, TB_Duplicate_Log__c> filterMap = new Map<String, TB_Duplicate_Log__c>();
		for (TB_Duplicate_Log__c log : logs) {
			String key = log.TB_Contact__c > log.TB_Source_SObject_Id__c ? 
				log.TB_Contact__c + log.TB_Source_SObject_Id__c :
				log.TB_Source_SObject_Id__c + log.TB_Contact__c;
			filterMap.put(key, log);
		}
		return filterMap.values();
	}
}