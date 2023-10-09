public with sharing class TB_MergingContactDuplicatesController {
    final static List<String> FORBIDDEN_FIELDS = new List<String>{'Id', 'CreatedDate', 'RecordTypeId', 'CreatedById', 'LastModifiedDate', 'LastModifiedById', 'SystemModstamp', 'LastViewedDate', 'LastReferencedDate', 'MailingAddress', 'OtherAddress', 'IsDeleted', 'Name', 'PhotoUrl', 'TB_Customer_Id_Tech__c'};
    final static String INCORRECT_LOG_TAG = 'INCORRECT_LOG';

    @AuraEnabled
    public static String mergeContacts(String mergeContactWrapperJson) {
        Wrapper result;
        try {
            MergeContactWrapper wrapper = new MergeContactWrapper(mergeContactWrapperJson);
            List<TB_Duplicate_Contact_Object_Relation__mdt> objectRelationMdts = getDuplicateContactObjectRelations();
            result = mergeFoundDuplicatedContacts(wrapper, objectRelationMdts != null ? objectRelationMdts : new List<TB_Duplicate_Contact_Object_Relation__mdt>());
        } catch (Exception ex) {
            result = new FailureResult(ex);
            insert TB_LogUtils.registerLog(ex);
        }
        return result.wrap();
    }

    @AuraEnabled
    public static String getContactWrapper(String remainingContactId, String duplicateContactId) {
        Wrapper result;
        try {
            List<TB_Duplicate_Contact_Object_Relation__mdt> objectRelationMdts = getDuplicateContactObjectRelations();
            result = getContactWrapper(remainingContactId, duplicateContactId, objectRelationMdts != null ? objectRelationMdts : new List<TB_Duplicate_Contact_Object_Relation__mdt>());
        } catch (Exception ex) {
            result = new FailureResult(ex);
            insert TB_LogUtils.registerLog(ex);
        }
        return result.wrap();
    }

    @AuraEnabled
    public static String getWrappedContactDuplicateLogs(String contactId) {
        return getWrappedContactDuplicateLogsWrapper(contactId).wrap();
    }

    @AuraEnabled
    public static String getWrappedDuplicateLog(String recordId) {
        return getWrappedDuplicateLogWrapper(recordId).wrap();
    }

    @TestVisible
    private static Wrapper mergeFoundDuplicatedContacts(MergeContactWrapper wrapper, List<TB_Duplicate_Contact_Object_Relation__mdt> objectRelationMdts) {
        try {
            Contact remainingContactToUpdate = wrapper.isReversed ? wrapper.duplicateContact : wrapper.remainingContact;
            Contact duplicateContactToDelete = wrapper.isReversed ? wrapper.remainingContact : wrapper.duplicateContact;
            List<TB_Duplicate_Log__c> logsToDelete = getRelatedContactDuplicateLogs(duplicateContactToDelete.Id);
            for (String fieldApiName : wrapper.fieldApiNamesToMerge) {
                remainingContactToUpdate.put(fieldApiName, duplicateContactToDelete.get(fieldApiName));
            }
            Map<String, List<String>> objectNamesToFieldsMap = getContactChildSObjectToFieldListMap(objectRelationMdts);
            List<TB_SObjectUtils.RelatedObjects> relatedObjectsList = TB_SObjectUtils.getRelatedObjectsList(objectNamesToFieldsMap, duplicateContactToDelete.Id);
            for (TB_SObjectUtils.RelatedObjects relatedObjects : relatedObjectsList) {
                relatedObjects.changeParentObjectId(remainingContactToUpdate.Id);
            }
            List<SObject> objectsToUpdate = TB_SObjectUtils.mergeRelatedObjectsToSObjects(relatedObjectsList);
            objectsToUpdate.add(remainingContactToUpdate);
            
            List<SObject> objectsToDelete = new List<SObject>();
            objectsToDelete.addAll(logsToDelete);
            objectsToDelete.add(duplicateContactToDelete);

            update objectsToUpdate;
            delete objectsToDelete;
            return new SuccessResult();
        } catch (Exception ex) {
            insert TB_LogUtils.registerLog(ex);
            return new FailureResult(ex);
        }
    }

    @TestVisible
    private static Wrapper getContactWrapper(String remainingContactId, String duplicateContactId, List<TB_Duplicate_Contact_Object_Relation__mdt> objectRelationMdts) {
        Wrapper wrapper;
        try {
            Contact remainingContact = (Contact) TB_SObjectUtils.getSObjectWithAllFieldsWithLookupNames(remainingContactId);
            Contact duplicateContact = (Contact) TB_SObjectUtils.getSObjectWithAllFieldsWithLookupNames(duplicateContactId);
            wrapper = new MergeContactWrapper(remainingContact, duplicateContact);
            Map<String, List<String>> objectNamesToFieldsMap = getContactChildSObjectToFieldListMap(objectRelationMdts);
            ((MergeContactWrapper) wrapper).generateWrappedFieldLists();
            ((MergeContactWrapper) wrapper).generateRelatedRecordsFieldLists(objectNamesToFieldsMap);
            filterFieldsFrom((MergeContactWrapper) wrapper);
        } catch (Exception ex) {
            wrapper = new FailureResult(ex);
            insert TB_LogUtils.registerLog(ex);
        }
        return wrapper;
    }

    @TestVisible
    private static Wrapper getWrappedContactDuplicateLogsWrapper(String contactId) {
        Wrapper wrapper;
        List<DuplicateLog> wrapperLogs = new List<DuplicateLog>();
        Set<String> contactIds = new Set<String>();
        try {
            List<TB_Duplicate_Log__c> logs = getRelatedContactDuplicateLogs(contactId);
            for (TB_Duplicate_Log__c log : logs) {
                contactIds.add(log.TB_Contact__c);
                contactIds.add(log.TB_Matching_Contact__c);
            }
            Map<Id, SObject> contactMap = contactIds.isEmpty() ? new Map<Id, SObject>() : TB_QueryBuilder.create()
                .selectId()
                .selectField('Name')
                .fromSObject('Contact')
                .andWhereFieldIsInSet('Id', contactIds)
                .performMap();
            for (TB_Duplicate_Log__c log : logs) {
                wrapperLogs.add(new DuplicateLog(log, (Contact) contactMap.get(log.TB_Contact__c), (Contact) contactMap.get(log.TB_Matching_Contact__c), contactId));
            }
            wrapper = new DuplicateLogsWrapper(wrapperLogs);
        } catch (Exception ex) {
            wrapper = new FailureResult(ex);
            insert TB_LogUtils.registerLog(ex);
        }
        return wrapper;
    }

    @TestVisible
    private static Wrapper getWrappedDuplicateLogWrapper(String recordId) {
        Wrapper wrapper;
        TB_Duplicate_Log__c log;
        try {
            log = (TB_Duplicate_Log__c) TB_QueryBuilder.create()
                .selectFields(new List<String>{'TB_Contact__c', 'TB_Matching_Contact__c', 'CreatedDate', 'TB_Contact_Matching_Field_Name__c'})
                .fromSObject('TB_Duplicate_Log__c')
                .andWhereFieldIsEqual('TB_Source_SObject_Type__c', 'Contact')
                .andWhereFieldIsNotNull('TB_Contact__c')
                .andWhereFieldIsNotNull('TB_Matching_Contact__c')
                .andWhereIdIsEqual(recordId)
                .performSingle();
            wrapper = new DuplicateLog(log, log.TB_Contact__c, log.TB_Matching_Contact__c);
        } catch (Exception ex) {
            wrapper = new FailureResult(ex);
            if (log != null) {
                insert TB_LogUtils.registerLog(ex);
            } else {
                ((FailureResult) wrapper).message = INCORRECT_LOG_TAG;
            }
        }
        return wrapper;
    }

    private static List<TB_Duplicate_Contact_Object_Relation__mdt> getDuplicateContactObjectRelations() {
        return TB_QueryBuilder.create()
            .selectFields(new List<String>{'TB_Contact_Lookup_Field_Name__c', 'TB_Related_Object_Name__c'})
            .fromSObject('TB_Duplicate_Contact_Object_Relation__mdt')
            .andWhereFieldIsEqual('TB_Active__c', true)
            .perform();
    }

    private static Map<String, List<String>> getContactChildSObjectToFieldListMap(List<TB_Duplicate_Contact_Object_Relation__mdt> objectRelationMdts) {
        Map<String, List<String>> result = new Map<String, List<String>>();
        for (TB_Duplicate_Contact_Object_Relation__mdt mdt : objectRelationMdts) {
            List<String> fields = result.containsKey(mdt.TB_Related_Object_Name__c) ? result.get(mdt.TB_Related_Object_Name__c) : new List<String>();
            fields.add(mdt.TB_Contact_Lookup_Field_Name__c);
            result.put(mdt.TB_Related_Object_Name__c, fields);
        }
        return result;
    }

    private static List<TB_Duplicate_Log__c> getRelatedContactDuplicateLogs(String contactId) {
        return TB_QueryBuilder.create()
            .selectFields(new List<String>{'TB_Contact__c', 'TB_Matching_Contact__c', 'CreatedDate', 'TB_Contact_Matching_Field_Name__c'})
            .fromSObject('TB_Duplicate_Log__c')
            .openConditionBracket()
                .andWhereFieldIsEqual('TB_Source_SObject_Type__c', 'Contact')
                .andWhereFieldIsNotNull('TB_Contact__c')
                .andWhereFieldIsNotNull('TB_Matching_Contact__c')
            .closeConditionBracket()
            .openConditionBracket()
                .andWhereFieldIsEqual('TB_Contact__c', contactId)
                .orWhereFieldIsEqual('TB_Matching_Contact__c', contactId)
            .closeConditionBracket()
            .perform();
    }

    private static void filterFieldsFrom(MergeContactWrapper wrapper) {
        List<TB_SObjectUtils.FieldWrapper> filteredRemainingContactWrappedFieldList = new List<TB_SObjectUtils.FieldWrapper>();
        List<TB_SObjectUtils.FieldWrapper> filteredDuplicateContactWrappedFieldList = new List<TB_SObjectUtils.FieldWrapper>();
        for (Integer i = 0; i < wrapper.remainingContactWrappedFieldList.size(); i++) {
            if ( !FORBIDDEN_FIELDS.contains(wrapper.remainingContactWrappedFieldList[i].apiName) ) {
                filteredRemainingContactWrappedFieldList.add(wrapper.remainingContactWrappedFieldList[i]);
                filteredDuplicateContactWrappedFieldList.add(wrapper.duplicateContactWrappedFieldList[i]);
            }
        }
        wrapper.remainingContactWrappedFieldList = filteredRemainingContactWrappedFieldList;
        wrapper.duplicateContactWrappedFieldList = filteredDuplicateContactWrappedFieldList;
    }

    public abstract class Wrapper{
        public Boolean isCorrect;
        public String wrap() {
            return JSON.serialize(this);
        }
    }

    public class MergeContactWrapper extends Wrapper{
        public Id remainingContactId;
        public Id duplicateContactId;
        public Contact remainingContact;
        public Contact duplicateContact;
        public List<TB_SObjectUtils.FieldWrapper> remainingContactWrappedFieldList;
        public List<TB_SObjectUtils.FieldWrapper> duplicateContactWrappedFieldList;
        public List<TB_SObjectUtils.FieldWrapper> remainingContactRelatedRecordsWrappedList;
        public List<TB_SObjectUtils.FieldWrapper> duplicateContactRelatedRecordsWrappedList;
        public List<String> fieldApiNamesToMerge;
        public Boolean isReversed;

        public MergeContactWrapper(Contact remainingContact, Contact duplicateContact) {
            this.remainingContact = remainingContact;
            this.duplicateContact = duplicateContact;
            this.remainingContactId = remainingContact.Id;
            this.duplicateContactId = duplicateContact.Id;
            this.isCorrect = true;
            this.isReversed = false;
        }

        public MergeContactWrapper(String jsonString) {
            Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            this.remainingContactId = (Id) parsedJson.get('remainingContactId');
            this.duplicateContactId = (Id) parsedJson.get('duplicateContactId');
            this.remainingContact = (Contact) JSON.deserialize(JSON.serialize(parsedJson.get('remainingContact')), Contact.class);
            this.duplicateContact = (Contact) JSON.deserialize(JSON.serialize(parsedJson.get('duplicateContact')), Contact.class);
            this.fieldApiNamesToMerge = new List<String>();
            for (Object fieldObject : (List<Object>)parsedJson.get('fieldApiNamesToMerge')) {
                this.fieldApiNamesToMerge.add(String.valueOf(fieldObject));
            }
            this.isReversed = (Boolean) parsedJson.get('isReversed');
        }

        public void generateWrappedFieldLists() {
            remainingContactWrappedFieldList = TB_SObjectUtils.getAllFieldsWrapperListFrom(remainingContactId, false);
            duplicateContactWrappedFieldList = TB_SObjectUtils.getAllFieldsWrapperListFrom(duplicateContactId, false);
        }

        public void generateRelatedRecordsFieldLists(Map<String, List<String>> objectNamesToFieldsMap) {
            remainingContactRelatedRecordsWrappedList = TB_SObjectUtils.getRelatedRecordsCounterFieldWrapperListsFrom(objectNamesToFieldsMap, remainingContactId);
            duplicateContactRelatedRecordsWrappedList = TB_SObjectUtils.getRelatedRecordsCounterFieldWrapperListsFrom(objectNamesToFieldsMap, duplicateContactId);
        }
    }

    public class DuplicateLog extends Wrapper {
        public Id id;
        public Id remainingContactId;
        public Id duplicateContactId;
        public String remainingContactName;
        public String duplicateContactName;
        public String matchingField;
        public String otherContactName;
        public String otherContactId;
        public Date createdDate;
        public DuplicateLog(TB_Duplicate_Log__c log, Contact remainingContact, Contact duplicateContact) {
            this.Id = log.Id;
            this.remainingContactId = remainingContact.Id;
            this.duplicateContactId = duplicateContact.Id;
            this.remainingContactName = remainingContact.Name;
            this.duplicateContactName = duplicateContact.Name;
            this.createdDate = Date.newInstance(log.CreatedDate.year(), log.CreatedDate.month(), log.CreatedDate.day());
            this.matchingField = log.TB_Contact_Matching_Field_Name__c;
            this.isCorrect = true;
        }

        public DuplicateLog(TB_Duplicate_Log__c log, Contact remainingContact, Contact duplicateContact, Id mainContactId) {
            this(log, remainingContact, duplicateContact);
            this.otherContactName = remainingContact.Id == mainContactId ? duplicateContact.Name : remainingContact.Name;
            this.otherContactId = remainingContact.Id == mainContactId ? duplicateContact.Id : remainingContact.Id; 
        }

        public DuplicateLog(TB_Duplicate_Log__c log, Id remainingContactId, Id duplicateContactId) {
            this.Id = log.Id;
            this.remainingContactId = remainingContactId;
            this.duplicateContactId = duplicateContactId;
            this.createdDate = Date.newInstance(log.CreatedDate.year(), log.CreatedDate.month(), log.CreatedDate.day());
            this.matchingField = log.TB_Contact_Matching_Field_Name__c;
            this.isCorrect = true;
        }
    }

    public class DuplicateLogsWrapper extends Wrapper {
        public List<DuplicateLog> logs;
        public DuplicateLogsWrapper(List<DuplicateLog> logs) {
            this.logs = logs;
            this.isCorrect = true;
        }
    }

    public class FailureResult extends Wrapper{
        public String message;
        public FailureResult(Exception ex) {
            this.message = ex.getMessage();
            this.isCorrect = false;
        }
    }

    public class SuccessResult extends Wrapper{
        public SuccessResult() {
            this.isCorrect = true;
        }
    }
}