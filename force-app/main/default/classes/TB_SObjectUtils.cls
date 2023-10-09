public with sharing class TB_SObjectUtils {
    public enum DLM_ACTIONS {INSERT_ACTION, UPDATE_ACTION, UPSERT_ACTION, DELETE_ACTION}
    final private static Integer DLM_RECORDS_LIMIT = 10000;
	final private static Integer DLM_TRANSACTION_LIMIT = 10;

    public static Map<String, String> createFieldToFieldStringMap(List<sObject> objects, SObjectField keyField, SObjectField valueField) {
        Map<String, String> fieldToFieldMap = new Map<String, String>();
        for (sObject obj : objects) {
            if (!String.isEmpty((String) obj.get(keyField))) {
                fieldToFieldMap.put(String.valueOf(obj.get(keyField)), String.valueOf(obj.get(valueField)));
            }
        }
        return fieldToFieldMap;
    }

    public static Set<String> createIdFieldValueSet(List<SObject> collection, SObjectField field) {
        Set<String> result = new Set<String>();
        for (SObject so : collection) {
            result.add((String) so.get(field));
        }
        return result;
    }

    public static String getRecordTypeNameById(String objectName, Id strRecordTypeId) {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(strRecordTypeId).getDeveloperName();
    }

    public static String getRecordTypeIdByDevName(String objectName, String recordTypeDevName) {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeDevName).getRecordTypeId();
    }

    public static List<SObject> filterNotNull(List<SObject> sobjects, SObjectField field) {
        return filterOtherThan(sobjects, field, null);
    }

    public static List<SObject> filterOtherThan(List<SObject> sobjects, SObjectField field, Object value) {
        List<SObject> filtered = new List<SObject>();
        for (SObject sobj : sobjects) {
            if (sobj.get(field) !== value) {
                filtered.add(sobj);
            }
        }
        return filtered;
    }

    public static String getApplicationHeader(hed__Application__c application, String communicationLanguage) {
        String header = '';
        String language = (communicationLanguage == 'Polish' || communicationLanguage == null) ? 'PL' : 'EN';
        header += application.Name;
        if (application.get('TB_Product_Name__c') != null) {
            header += ' - ' + application.get('TB_Product_Name__c');
        }
        if (application.get('TB_x_Campus_' + language + '__c') != null) {
            header += ', ' + application.get('TB_x_Campus_' + language + '__c');
        }
        if (application.TB_Level_of_Study__c != null) {
            header += ', ' + application.get('TB_Level_of_Study_Label');
        }
        if (application.TB_Mode_of_Study__c != null) {
            header += ', ' + application.get('TB_Mode_of_Study_Label');
        }
        return header;
    }

    public static String getPicklistTranslate(String value, SObjectField field){
        String returnValue = value;
        for (Schema.PicklistEntry pe : field.getDescribe().getPicklistValues()){
            if (value == pe.getValue()) {
                returnValue = pe.getLabel();
                break;
            }
        }
        return returnValue;
    }

    public static List<String> getListStringsFromObjectList(List<sObject> inputList, SObjectField field) {
        List<String> fieldValueList = new List<String>();
        for (sObject obj : inputList) {
            fieldValueList.add((String)obj.get(field));
        }
        return fieldValueList;
    }

    public static Boolean safetyMassInsertSObjects(List<SObject> sObjects) {
        return safetyMassDlmSObjects(sObjects, DLM_ACTIONS.INSERT_ACTION);
    }

    public static Boolean safetyMassUpdateSObjects(List<SObject> sObjects) {
        return safetyMassDlmSObjects(sObjects, DLM_ACTIONS.UPDATE_ACTION);
    }

    public static Boolean safetyMassUpsertSObjects(List<SObject> sObjects) {
        return safetyMassDlmSObjects(sObjects, DLM_ACTIONS.UPSERT_ACTION);
    }

    public static Boolean safetyMassDeleteSObjects(List<SObject> sObjects) {
        return safetyMassDlmSObjects(sObjects, DLM_ACTIONS.DELETE_ACTION);
    }

    private static Boolean safetyMassDlmSObjects(List<SObject> sObjects, DLM_ACTIONS action) {
        Boolean isProcessRunCorrectly = true;
		List<SObject> sObjectsToDlm = new List<SObject>();
		Integer recordCounter = 0;
		Integer transactionCounter = 0;
		for (SObject obj : sObjects) {
			recordCounter++;
			if (transactionCounter != DLM_TRANSACTION_LIMIT && recordCounter == DLM_RECORDS_LIMIT) {
				transactionCounter++;
				recordCounter = 0;
				isProcessRunCorrectly = performDlmAction(sObjectsToDlm, action);
				sObjectsToDlm = new List<SObject>();
			}
			sObjectsToDlm.add(obj);
		}
        if (recordCounter < DLM_RECORDS_LIMIT) {
            isProcessRunCorrectly = performDlmAction(sObjectsToDlm, action);
        } else {
            isProcessRunCorrectly = false;
            insert TB_LogUtils.registerLog(new DmlException('Safety mass DLM SObjects limit exceeded on TB_SObjectUtils.safetyMassDlmSObjects!'));
        }
        return isProcessRunCorrectly;
	}

    private static Boolean performDlmAction(List<SObject> sObjects, DLM_ACTIONS action) {
        Boolean isProcessRunCorrectly = true;
        try {
            switch on action {
                when INSERT_ACTION {
                    insert sObjects;
                }
                when UPDATE_ACTION { 
                    update sObjects;
                }
                when UPSERT_ACTION { 
                    upsert sObjects;
                }
                when DELETE_ACTION { 
                    delete sObjects;
                }
            } 
        } catch (Exception ex) {
            isProcessRunCorrectly = false;
            insert TB_LogUtils.registerLog(ex);
        }
        return isProcessRunCorrectly;
    }

    public static String getFieldsToSelectAsString(Set<String> fields) {
		return getFieldsToSelectAsString(new List<String>(fields), '');
	}

    public static String getFieldsToSelectAsString(List<String> fields) {
		return getFieldsToSelectAsString(fields, '');
	}

    public static String getFieldsToSelectWithIdAsString(Set<String> fields) {
        fields.add('Id');
		return getFieldsToSelectAsString(new List<String>(fields));
	}

    public static String getFieldsToSelectWithIdAsString(List<String> fields) {
		return getFieldsToSelectWithIdAsString(new Set<String>(fields));
	}

	public static String getFieldsToSelectAsString(List<String> fields, String prefix) {
		String result = '';
		for (Integer i = 0; i < fields.size(); i++) {
			result += prefix + fields.get(i) + ', ';
		}
		return result.removeEnd(', ') + ' ';
	}

    public static String getFieldsToSetConditionAsString(List<String> fields) {
		String result = '( ';
		for (Integer i = 0; i < fields.size(); i++) {
			result += '\'' + fields.get(i) + '\', ';
		}
		return result.removeEnd(', ') + ' )';
	}

	public static String getFieldsAsNotNullConditionsString(List<String> fields) {
		String result = '( ';
		for (Integer i = 0; i < fields.size(); i++) {
			result += fields.get(i) + 
				(i != fields.size() - 1 ? ' != null OR ' : ' != null )');
		}
		return result;
	}

    public static String getSObjectRelationName(String sObjectName) {
        return sObjectName.replace('__c', '__r');
    }

    public static String getSObjectRelationPluralName(String sObjectName) {
        return getSObjectRelationName(sObjectName) != sObjectName ?
            sObjectName.replace('__c', 's__r') :
            sObjectName + 's';
    }

    public static List<Id> getIds(List<SObject> sObjects) {
        List<Id> ids = new List<Id>();
        for (SObject sObj : sObjects) {
            ids.add(sObj.Id);
        }
        return ids;
    }

    public static String getChildRecordsToSelectString(String relationName, List<String> fieldsToSelect) {
        fieldsToSelect.add('Id');
		return '( SELECT ' + getFieldsToSelectAsString(fieldsToSelect) + ' FROM ' + relationName + ')';
    }

    public static String getParentRelationNameFrom(String parentObjectName, String childObjectName, String childFieldName) {
        Schema.SObjectType sobjType = Schema.getGlobalDescribe().get(parentObjectName);
        Schema.DescribeSObjectResult objectDescribe = sobjType.getDescribe();
        for (Schema.ChildRelationship childRelationship : objectDescribe.getChildRelationships()) {
            String objectName = childRelationship.getChildSObject().getDescribe().getName();
            String fieldName = childRelationship.getField().getDescribe().getName();
            if (objectName == childObjectName && fieldName == childFieldName) {
                return childRelationship.getRelationshipName();
            }
        }
		return null;
    }

    public static Schema.DescribeSObjectResult getParentSObjectDescribeFrom(String parentObjectName, String childRelationName, String childFieldName) {
        Schema.SObjectType sobjType = Schema.getGlobalDescribe().get(parentObjectName);
        Schema.DescribeSObjectResult objectDescribe = sobjType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
        for(String fieldName : fieldMap.keySet()) {
            Schema.SObjectField field = fieldMap.get(fieldName);
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            for(Schema.SObjectType reference : fieldDescribe.getReferenceTo()) {
                if (childRelationName == fieldDescribe.getRelationshipName() && childFieldName == getNameField(reference)) {
                    return reference.getDescribe();
                }
            }
        }
        return null;
    }

    public static String getParentSObjectLabelFrom(String parentObjectName, String childRelationName, String childFieldName) {
        return getParentSObjectDescribeFrom(parentObjectName, childRelationName, childFieldName).getLabel();
    }

    public static String getParentSObjectNameFrom(String parentObjectName, String childRelationName, String childFieldName) {
        return getParentSObjectDescribeFrom(parentObjectName, childRelationName, childFieldName).getName();
    }

    public static List<Schema.SObjectField> getAllFieldsFrom(String objectName) {
        Schema.SObjectType sobjType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objectDescribe = sobjType.getDescribe();
        return objectDescribe.fields.getMap().values();
    }

    public static List<String> getAllFieldsAsStringListFrom(String objectName) {
        List<String> result = new List<String>();
        for(Schema.SObjectField field : getAllFieldsFrom(objectName)) {
            result.add(field.getDescribe().getName());
        }
        return result;
    }

    public static Map<String, String> getAllParentFieldToNameFieldMapFrom(String objectName) {
        Map<String, String> result = new Map<String, String>();
        Schema.SObjectType sobjType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objectDescribe = sobjType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
        for(String fieldName : fieldMap.keySet()) {
            Schema.SObjectField field = fieldMap.get(fieldName);
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            for(Schema.SObjectType reference : fieldDescribe.getReferenceTo()) {
                String nameField = getNameField(reference);
                result.put(fieldDescribe.getName(), fieldDescribe.getRelationshipName() + '.' + nameField);
            }
        }
        return result;
    }

    public static String getNameField(String objectName) {
        Schema.SObjectType sobjType = Schema.getGlobalDescribe().get(objectName);
        return getNameField(sobjType);
    }

    public static String getNameField(Schema.SObjectType sobjType) {
        Schema.DescribeSObjectResult objDescribe = sobjType.getDescribe();
        Map<String, SObjectField> fieldsMap = objDescribe.fields.getMap();
        for (Schema.SObjectField field : fieldsMap.values()) {
            if (field.getDescribe().isNameField()) {
                return field.getDescribe().getName();
            }
        }
        return null;
    }

    public static Map<String, String> getChildFieldToParentRelationNameMap(String parentObjectName, String childObjectName, List<String> childFieldsNames) {
        Map<String, String> result = new Map<String, String>();
        for (String childFieldName : childFieldsNames) {
            result.put(childObjectName + '.' + childFieldName, getParentRelationNameFrom(parentObjectName, childObjectName, childFieldName));
        }
		return result;
    }

    public static List<RelatedObjects> getRelatedObjectsList(Map<String, List<String>> objectNamesToFieldsMap, Id parentObjectId) {
        List<RelatedObjects> result = new List<RelatedObjects>();
        Map<String, List<SObject>> objectNameToRelatedObjectsMap = getObjectNameToRelatedObjectsMap(objectNamesToFieldsMap, parentObjectId);
        for (String objectName : objectNamesToFieldsMap.keySet()) {
            RelatedObjects relatedObjects = new RelatedObjects(objectName, parentObjectId, objectNamesToFieldsMap.get(objectName));
            relatedObjects.objects = objectNameToRelatedObjectsMap.get(objectName);
            result.add(relatedObjects);
        }
        return result;
    }

    private static Map<String, List<SObject>> getObjectNameToRelatedObjectsMap(Map<String, List<String>> objectNamesToFieldsMap, Id parentObjectId) {
        Map<String, List<SObject>> result = new Map<String, List<SObject>>();
        if (objectNamesToFieldsMap.isEmpty()) {
            return result;
        }
        SObject parent;
        try {
            String parentObjectName = parentObjectId.getSObjectType().getDescribe().getName();
            Map<String, String> childFieldToParentRelationNameMap = new Map<String, String>();
            List<String> insideSelectLoops = new List<String>{'Id'};
            TB_QueryBuilder.Query query= TB_QueryBuilder.create()
                .selectId()
                .fromSObject(parentObjectName)
                .andWhereFieldIsEqual('Id', parentObjectId);
            for (String objectName : objectNamesToFieldsMap.keySet()) {
                List<String> fieldsToSelect = objectNamesToFieldsMap.get(objectName);
                childFieldToParentRelationNameMap.putAll(getChildFieldToParentRelationNameMap(parentObjectName, objectName, fieldsToSelect));
                for (String fieldName : fieldsToSelect) {
                    query.openInnerQuery(objectName, fieldName)
                        .selectFields(fieldsToSelect)
                        .closeInnerQuery();
                }
            }
            parent = query.performSingle();
            for (String objectName : objectNamesToFieldsMap.keySet()) {
                List<String> fieldsToSelect = objectNamesToFieldsMap.get(objectName);
                for (String fieldName : fieldsToSelect) {
                    List<SObject> relatedObjects = parent.getSObjects(childFieldToParentRelationNameMap.get(objectName + '.' + fieldName));
                    List<SObject> previousObjects = result.get(objectName);
                    if (previousObjects != null) {
                        relatedObjects.addAll(previousObjects);
                    }
                    result.put(objectName, relatedObjects);
                }
            }
        } catch (Exception ex) {
            insert TB_LogUtils.registerLog(ex);
        }
        return result;
    }

    public static RelatedObjects getRelatedObjectWithQuery(String objectName, Id parentObjectId, List<String> parentObjectRelationNames) {
        RelatedObjects relatedObjects = new RelatedObjects(objectName, parentObjectId, parentObjectRelationNames);
        relatedObjects.objects = relatedObjects.getRelatedSObjects();
        return relatedObjects;
    }

    public static RelatedObjects getRelatedObjectWithQuery(String objectName, Id parentObjectId, String parentObjectRelationName) {
        return getRelatedObjectWithQuery(objectName, parentObjectId, new List<String>{parentObjectRelationName});
    }

    public static List<SObject> mergeRelatedObjectsToSObjects(List<RelatedObjects> relatedObjectsList) {
        Set<SObject> result = new Set<SObject>();
        for (RelatedObjects relatedObjects : relatedObjectsList) {
            if (relatedObjects.objects != null) {
                result.addAll(relatedObjects.objects);
            }
        }
        return new List<SObject>(result);
    }

    public static String getSObjectLabelFromSObjectApiName(String objectName) {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().getLabel();
    }

    public static String getSObjectPlularLabelFromSObjectApiName(String objectName) {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().getLabelPlural();
    }

    public static String getSObjectLabelFromId(Id recordId) {
        return recordId.getSobjectType().getDescribe().getLabel();
    }

    public static String getSObjectTypeFromId(Id recordId) {
        return recordId.getSObjectType().getDescribe().getName();
    }

    public static SObject getSObjectWithAllFields(Id objectId, String objectType) {
        try {
            TB_QueryBuilder.Query query = TB_QueryBuilder.create()
                .selectFields(getAllFieldsAsStringListFrom(objectType))
                .fromSObject(objectType)
                .andWhereIdIsEqual(objectId);
            return query.performSingle();
        } catch (Exception ex) {
            insert TB_LogUtils.registerLog(ex);
            return null;
        }
    }

    public static SObject getSObjectWithAllFieldsWithLookupNames(Id recordId) {
        String objectType = getSObjectTypeFromId(recordId);
        try {
            TB_QueryBuilder.Query query = TB_QueryBuilder.create()
                .selectFields(getAllFieldsAsStringListFrom(objectType))
                .selectFields(getAllParentFieldToNameFieldMapFrom(objectType).values())
                .fromSObject(objectType)
                .andWhereIdIsEqual(recordId);
            return query.performSingle();
        } catch (Exception ex) {
            insert TB_LogUtils.registerLog(ex);
            return null;
        }
    }

    public static List<FieldWrapper> getAllFieldsWrapperListFrom(Id recordId, Boolean withFormulaFields) {
        List<FieldWrapper> result = new List<FieldWrapper>();
        String objectType = getSObjectTypeFromId(recordId);
        SObject obj = getSObjectWithAllFieldsWithLookupNames(recordId);
        List<Schema.SObjectField> fields = getAllFieldsFrom(objectType);
        Map<String, String> parentFieldToNameFieldMap = getAllParentFieldToNameFieldMapFrom(objectType);
        for (Schema.SObjectField field : fields) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            if (withFormulaFields || !fieldDescribe.isCalculated()) {
                Boolean isLookup = !fieldDescribe.getReferenceTo().isEmpty();
                String parentRelationWithNameField = parentFieldToNameFieldMap.get(fieldDescribe.getName());
                String parentNameField = isLookup ? parentRelationWithNameField.substringAfter('.') : null;
                String parentObjectName = isLookup ? parentRelationWithNameField.substringBefore('.') : null;
                Object labelValue = isLookup ? 
                    obj.getSobject(parentObjectName) != null ?
                        obj.getSobject(parentObjectName).get(parentNameField) :
                        obj.get(fieldDescribe.getName()) :
                    obj.get(fieldDescribe.getName());
                result.add(new FieldWrapper(
                    fieldDescribe.getName(), 
                    obj.get(fieldDescribe.getName()), 
                    isLookup ? getParentSObjectLabelFrom(objectType, parentObjectName, parentNameField) + ' ' + parentNameField + ' (' + parentObjectName + ')': fieldDescribe.getLabel(), 
                    labelValue, 
                    isLookup
                ));
            }
        }
        return result;
    }

    public static List<FieldWrapper> getRelatedRecordsCounterFieldWrapperListsFrom(Map<String, List<String>> objectNamesToFieldsMap, Id recordId) {
        List<FieldWrapper> result = new List<FieldWrapper>();
        String objectType = getSObjectTypeFromId(recordId);
        List<TB_SObjectUtils.RelatedObjects> relatedObjectsList = TB_SObjectUtils.getRelatedObjectsList(objectNamesToFieldsMap, recordId);
        for (TB_SObjectUtils.RelatedObjects relatedObjects : relatedObjectsList) {
            FieldWrapper field = new FieldWrapper(
                relatedObjects.objectName, 
                relatedObjects.objects != null ? relatedObjects.objects.size() : 0, 
                getSObjectPlularLabelFromSObjectApiName(relatedObjects.objectName)
            );
            field.isCounter = true;
            result.add(field);
        }
        return result;
    }

    public with sharing class RelatedObjects {
        public final String objectName;
        public final Id parentObjectId;
        public final String parentObjectName;
        public final List<String> parentObjectRelationNames;
        public List<SObject> objects;
        public Boolean isValid;

        public void changeParentObjectId(Id newParentObjectId) {
            if (objects != null) {
                for (SObject obj : objects) {
                    for (String field : parentObjectRelationNames) {
                        if (obj.get(field) == parentObjectId) {
                            obj.put(field, newParentObjectId);
                        }
                    }
                }
            }
        }

        private RelatedObjects(String objectName, Id parentObjectId, List<String> parentObjectRelationNames) {
            this.objectName = objectName;
            this.parentObjectId = parentObjectId;
            this.parentObjectRelationNames = parentObjectRelationNames;
            this.isValid = true;
            try {
                this.parentObjectName = Id.valueOf(parentObjectId).getSObjectType().getDescribe().getName();
            } catch (Exception ex) {
                this.isValid = false;
                insert TB_LogUtils.registerLog(ex);
            }
        }

        public List<SObject> getRelatedSObjects() {
            List<SObject> result;
            TB_QueryBuilder.Query query= TB_QueryBuilder.create()
                .selectFields(parentObjectRelationNames)
                .fromSObject(objectName)
                .orWhereFieldsAreEqual(parentObjectRelationNames, parentObjectId);
            try {
                result = query.perform();
            } catch (Exception ex) {
                isValid = false;
                insert TB_LogUtils.registerLog(ex);
            }
            return result;
        }
    }

    public with sharing class FieldWrapper {
        public String apiName;
        public Object value;
        public String label;
        public Object labelValue;
        public Boolean isLookup;
        public Boolean isCounter;

        public FieldWrapper(String apiName, Object value, String label, Object labelValue, Boolean isLookup) {
            this.apiName = apiName;
            this.label = label;
            this.value = value;
            this.labelValue = labelValue;
            this.isLookup = isLookup;
            this.isCounter = false;
        }

        public FieldWrapper(String apiName, Object value, String label, Object labelValue) {
            this(apiName, value, label, labelValue, false);
        }

        public FieldWrapper(String apiName, Object value, String label) {
            this(apiName, value, label, value, false);
        }
    }
}