/**
 * Created by arturlydkowski on 05/07/2021.
 */

public without sharing class TB_DataCollectionTriggerHelper {
    private static Map<String, String> parentObjectToObjectPath = new Map<String, String>{
        'Employee Evaluation Stage' => '',
        'Employee Evaluation' => 'TB_Employee_Evaluation__r.',
        'Evaluator' => 'TB_Employee_Evaluation__r.TB_Evaluator__r.',
        'Evaluated' => 'TB_Employee_Evaluation__r.TB_Evaluated__r.',
        'Supervisor' => 'TB_Employee_Evaluation__r.TB_Supervisor__r.'
    };

    private static Map<String, String> objectToGetContactAttributeObjectToObjectPath = new Map<String, String>{
        'Evaluated Attribute' => 'TB_Employee_Evaluation__r.TB_Evaluated__r.'
    };

    private static Map<String, String> methodTypeToField = new Map<String, String>{
        'TargetId' => 'TB_Target_Object_Id__c',
        'SourceId' => 'TB_Source_Object_Id__c',
        'SourceField' => 'TB_Value_Text__c'
    };

    private static final Integer MAX_SIZE_LONG_TEXT = 131072;

    public static void fetchSourceAndTargetFields(List<TB_Data_Collection__c> dataCollections) {
        Map< Map<String, String>, Map<String, List<TB_Data_Collection__c>>> objectPathMapToDataCollectionByMethodType
            = new Map<Map<String, String>, Map<String, List<TB_Data_Collection__c>>> {
                parentObjectToObjectPath => new Map<String, List<TB_Data_Collection__c>> {
                    'SourceId' => new List<TB_Data_Collection__c>(),
                    'SourceField' => new List<TB_Data_Collection__c>(),
                    'TargetId' => new List<TB_Data_Collection__c>()
                },
                objectToGetContactAttributeObjectToObjectPath => new Map<String, List<TB_Data_Collection__c>> {
                    'SourceId' => new List<TB_Data_Collection__c>(),
                    'SourceField' => new List<TB_Data_Collection__c>(),
                    'TargetId' => new List<TB_Data_Collection__c>()
                }
            };

        Set<Id> employeeEvaluationStageIds = new Set<Id>();

        for (TB_Data_Collection__c singleDataCollection : dataCollections) {
            for (Map<String, String> objectPathMap : objectPathMapToDataCollectionByMethodType.keySet()) {
                Map<String, List<TB_Data_Collection__c>> methodTypeToDataCollections
                    = objectPathMapToDataCollectionByMethodType.get(objectPathMap);

                if (isSourceIdToFill(singleDataCollection, objectPathMap)) {
                    methodTypeToDataCollections.get('SourceId').add(singleDataCollection);
                    employeeEvaluationStageIds.add(singleDataCollection.TB_Employee_Evaluation_Stage__c);
                }

                if (isSourceFieldToFill(singleDataCollection, objectPathMap)) {
                    methodTypeToDataCollections.get('SourceField').add(singleDataCollection);
                    employeeEvaluationStageIds.add(singleDataCollection.TB_Employee_Evaluation_Stage__c);
                }

                if (isTargetIdToFill(singleDataCollection, objectPathMap)) {
                    methodTypeToDataCollections.get('TargetId').add(singleDataCollection);
                    employeeEvaluationStageIds.add(singleDataCollection.TB_Employee_Evaluation_Stage__c);
                }
            }
        }

        if (!employeeEvaluationStageIds.isEmpty()) {
            fetchSourceAndTargetFieldsFromParents(objectPathMapToDataCollectionByMethodType.get(parentObjectToObjectPath), employeeEvaluationStageIds);
            fetchSourceAndTargetFieldsFromContactAttribute(objectPathMapToDataCollectionByMethodType.get(objectToGetContactAttributeObjectToObjectPath), employeeEvaluationStageIds);
        }
    }

    private static void fetchSourceAndTargetFieldsFromParents (
        Map<String, List<TB_Data_Collection__c>> methodTypeToDataCollections,
        Set<Id> employeeEvaluationStageIds
    ) {
        String query = prepareQueryToGeEmployeeEvaluationStages(
            methodTypeToDataCollections, employeeEvaluationStageIds, true, parentObjectToObjectPath
        );

        List<TB_Employee_Evaluation_Stage__c> employeeEvaluationStages = Database.query(query);

        Map<Id, TB_Employee_Evaluation_Stage__c> idToEmployeeEvaluationStages
            = new Map<Id, TB_Employee_Evaluation_Stage__c> (employeeEvaluationStages);

        for (String method : methodTypeToDataCollections.keySet()) {
            for (TB_Data_Collection__c singleDataCollection : methodTypeToDataCollections.get(method)) {
                String value = prepareFieldValue(idToEmployeeEvaluationStages, singleDataCollection, method, parentObjectToObjectPath, true);
                if (method == 'SourceField') {
                    if (singleDataCollection.TB_Data_Type__c == 'Text (Long)') {
                        singleDataCollection.put('TB_Value_Long_Text__c', value);
                    } else {
                        singleDataCollection.put('TB_Value_Text__c', value);
                    }
                } else {
                    singleDataCollection.put(methodTypeToField.get(method), value);
                }
            }
        }
    }

    private static void fetchSourceAndTargetFieldsFromContactAttribute (
        Map<String, List<TB_Data_Collection__c>> methodTypeToDataCollections,
        Set<Id> employeeEvaluationStageIds
    ) {

        String query = prepareQueryToGeEmployeeEvaluationStages(
            methodTypeToDataCollections, employeeEvaluationStageIds, false, objectToGetContactAttributeObjectToObjectPath
        );

        List<TB_Employee_Evaluation_Stage__c> employeeEvaluationStages = Database.query(query);

        Map<Id, TB_Employee_Evaluation_Stage__c> idToEmployeeEvaluationStages
            = new Map<Id, TB_Employee_Evaluation_Stage__c> (employeeEvaluationStages);

        Map<Id, Set<TB_Data_Collection__c>> evaluatedIdToDataCollections = new Map<Id, Set<TB_Data_Collection__c>>();
        Set<String> uniqueFieldsToQuery = new Set<String>();

        String allRecordFiltersTogether = '';
        for (String method : methodTypeToDataCollections.keySet()) {
            for (TB_Data_Collection__c singleDataCollection : methodTypeToDataCollections.get(method)) {
                String evaluatedId = prepareFieldValue(idToEmployeeEvaluationStages, singleDataCollection, method, objectToGetContactAttributeObjectToObjectPath,false);
                if (!evaluatedIdToDataCollections.containsKey(evaluatedId)) {
                    evaluatedIdToDataCollections.put(evaluatedId, new Set<TB_Data_Collection__c>());
                }
                evaluatedIdToDataCollections.get(evaluatedId).add(singleDataCollection);

                allRecordFiltersTogether += singleDataCollection.TB_Record_Filter__c + '; ';

                uniqueFieldsToQuery.add(singleDataCollection.TB_Source_Object_Field__c);
            }
        }

        for (String attributeField : hed__Attribute__c.getSObjectType().getDescribe().fields.getMap().keySet()) {
            if (allRecordFiltersTogether.containsIgnoreCase(attributeField)) {
                uniqueFieldsToQuery.add(attributeField);
            }
        }
        uniqueFieldsToQuery.remove(null);

        Set<Id> evaluatedIds = evaluatedIdToDataCollections.keySet();
        String contactWithAttributeQuery = prepareContactWithAttributeQuery(uniqueFieldsToQuery, evaluatedIds);
        List<Contact> evaluatedWithAttributes = Database.query(contactWithAttributeQuery);

        Map<Id, Contact> idToEvaluatedWithAttributes = new Map<Id, Contact> (evaluatedWithAttributes);

        for (Id evaluatedId : idToEvaluatedWithAttributes.keySet()) {
            for (hed__Attribute__c attribute : idToEvaluatedWithAttributes.get(evaluatedId).hed__Attributes__r) {
                for (TB_Data_Collection__c singleDataCollection : evaluatedIdToDataCollections.get(evaluatedId)) {
                    Boolean isCorrectRecord = true;
                    if (String.isNotBlank(singleDataCollection.TB_Record_Filter__c)) {
                        List<String> splittedFilters = singleDataCollection.TB_Record_Filter__c.deleteWhitespace().split('&&');
                        for (String singleFilter : splittedFilters) {
                            List<String> fieldAndRequirement = singleFilter.split('=');
                            String fieldName = fieldAndRequirement[0].trim();
                            String expectedValue = fieldAndRequirement[1].trim();
                            String attributeFieldValue = String.valueOf(attribute.get(fieldName));
                            if (String.isBlank(attributeFieldValue)
                                || !attributeFieldValue.equalsIgnoreCase(expectedValue)
                                ) {
                                isCorrectRecord = false;
                                break;
                            }
                        }
                    }

                    if (isCorrectRecord) {
                        singleDataCollection.TB_Target_Object_Id__c = attribute.Id;
                        singleDataCollection.TB_Source_Object_Id__c = attribute.Id;
                        singleDataCollection.TB_Value_Text__c = String.valueOf(
                            attribute.get(singleDataCollection.TB_Source_Object_Field__c)
                        );
                        // To decrease number of loops for the Data Collection values if it founds proper Attribute
                        evaluatedIdToDataCollections.get(evaluatedId).remove(singleDataCollection);
                    }
                }
            }
        }
    }

    private static String prepareContactWithAttributeQuery(Set<String> uniqueFieldsToQuery, Set<Id> evaluatedIds) {
        String contactWithAttributeQuery = 'SELECT Id, ';
        contactWithAttributeQuery += '(SELECT Id,';
        for (String fieldToQuery : uniqueFieldsToQuery) {
            contactWithAttributeQuery += fieldToQuery + ',';
        }
        contactWithAttributeQuery = contactWithAttributeQuery.removeEnd(',');
        contactWithAttributeQuery += ' FROM hed__Attributes__r ';
        contactWithAttributeQuery += ' ORDER BY CreatedDate ASC) ';
        contactWithAttributeQuery += ' FROM Contact';
        contactWithAttributeQuery += ' WHERE Id IN :evaluatedIds';
        return contactWithAttributeQuery;
    }

    public static void setTargetValues(List<TB_Data_Collection__c> dataCollections,
        Map<Id,TB_Data_Collection__c> idToOldDataCollections
    ) {
        Map<Id, SObject> objectsToUpdate = new Map<Id, SObject>();

        for (TB_Data_Collection__c dataColl : dataCollections) {
            if ( String.isBlank(dataColl.TB_Target_Object_Id__c)
                || String.isBlank(dataColl.TB_Target_Object_Field__c)
                || String.isBlank(dataColl.TB_Target_Object__c)
                || (
                    dataColl.TB_Value_Text__c == idToOldDataCollections.get(dataColl.Id).TB_Value_Text__c
                    && dataColl.TB_Value_Long_Text__c == idToOldDataCollections.get(dataColl.Id).TB_Value_Long_Text__c
                )
                ) {
                continue;
            }

            Id objectId = dataColl.TB_Target_Object_Id__c;
            SObject sObj;
            if (objectsToUpdate.containsKey(objectId)) {
                sObj = objectsToUpdate.get(objectId);
            } else {
                sObj = objectId.getSobjectType().newSObject();
                sObj.Id = objectId;
            }

            String value = dataColl.TB_Value_Text__c;

            String type = String.isNotBlank(dataColl.TB_Target_Object_Field_Type__c) ?
                dataColl.TB_Target_Object_Field_Type__c :
                dataColl.TB_Data_Type__c;

            switch on type {
                when 'Checkbox' {
                    if (value == null) {
                        value = 'false';
                    }
                    sObj.put(dataColl.TB_Target_Object_Field__c, Boolean.valueOf(value));
                }
                when 'Date' {
                    sObj.put(dataColl.TB_Target_Object_Field__c, Date.valueOf(value));
                }
                when 'Number' {
                    if (value == null) {
                        value = '0';
                    }
                    sObj.put(dataColl.TB_Target_Object_Field__c, Decimal.valueOf(value));
                }
                when 'Text (Long)' {
                    sObj.put(dataColl.TB_Target_Object_Field__c, dataColl.TB_Value_Long_Text__c);
                }
                when else {
                    sObj.put(dataColl.TB_Target_Object_Field__c, value);
                }
            }

            objectsToUpdate.put(objectId, sObj);
        }

        update objectsToUpdate.values();
    }

    public static void updateJsonField (List<TB_Data_Collection__c> dataCollections) {
        Map<Id, Set<TB_Data_Collection__c>> emplEvalStageIdToNewDataCollection
            = prepareEmplEvalStageId2NewDataCollection(dataCollections);

        Map<Id, List<TB_JSON_Wrapper__c>> employeeEvaluationStageIdsToJsonWrapper
            = getEmployeeEvaluationStageIdsToJsonWrapper(emplEvalStageIdToNewDataCollection.keySet());

        List<TB_JSON_Wrapper__c> wrappersToDelete = new List<TB_JSON_Wrapper__c>();
        for (String employeeEvaluationStageId : employeeEvaluationStageIdsToJsonWrapper.keySet()) {
            wrappersToDelete.addAll(
                employeeEvaluationStageIdsToJsonWrapper.get(employeeEvaluationStageId)
            );
        }

        Map<Id, Map<Id, TB_Data_Collection__c>> emplEvalStageIdToJsonDataCollIdToDataColl
            = prepareEmplEvalStageIdToJsonDataCollIdToDataColl(employeeEvaluationStageIdsToJsonWrapper);

        for (Id stageId : emplEvalStageIdToNewDataCollection.keySet()) {
            for (TB_Data_Collection__c dataCollection : emplEvalStageIdToNewDataCollection.get(stageId)) {
                emplEvalStageIdToJsonDataCollIdToDataColl?.get(stageId).put(dataCollection.Id, dataCollection);
            }
        }
        emplEvalStageIdToJsonDataCollIdToDataColl.remove(null);

        List<TB_JSON_Wrapper__c> jsonWrappers = prepareJsonWrappers(emplEvalStageIdToJsonDataCollIdToDataColl);

        try {
            insert jsonWrappers;
            delete wrappersToDelete;
        } catch (Exception e) {
            TB_LogUtils.registerLog(e, TB_DataCollectionTriggerHelper.class);
        }
    }

    private static Boolean isSourceFieldToFill (TB_Data_Collection__c dataCollection, Map<String, String> mapToValidate) {
        return !dataCollection.TB_Lower_Evaluation__c
            && String.isNotBlank(dataCollection.TB_Source_Object__c)
            && String.isNotBlank(dataCollection.TB_Source_Object_Field__c)
            && mapToValidate.containsKey(dataCollection.TB_Source_Object__c);
    }

    private static Boolean isSourceIdToFill (TB_Data_Collection__c dataCollection, Map<String, String> mapToValidate) {
        return !dataCollection.TB_Lower_Evaluation__c
            && String.isNotBlank(dataCollection.TB_Source_Object__c)
            && String.isNotBlank(dataCollection.TB_Source_Object_Field__c)
            && String.isBlank(dataCollection.TB_Source_Object_Id__c)
            && mapToValidate.containsKey(dataCollection.TB_Source_Object__c);
    }

    private static Boolean isTargetIdToFill (TB_Data_Collection__c dataCollection, Map<String, String> mapToValidate) {
        return !dataCollection.TB_Lower_Evaluation__c
            && String.isNotBlank(dataCollection.TB_Target_Object__c)
            && String.isNotBlank(dataCollection.TB_Target_Object_Field__c)
            && String.isBlank(dataCollection.TB_Target_Object_Id__c)
            && mapToValidate.containsKey(dataCollection.TB_Target_Object__c);
    }


    private static Map<Id, Set<TB_Data_Collection__c>> prepareEmplEvalStageId2NewDataCollection(List<TB_Data_Collection__c> dataCollections) {

        Map<Id, Set<TB_Data_Collection__c>> emplEvalStageIdToNewDataCollection = new Map<Id, Set<TB_Data_Collection__c>>();
        for (TB_Data_Collection__c dataCollection : dataCollections) {
            if (!emplEvalStageIdToNewDataCollection.containsKey(dataCollection.TB_Employee_Evaluation_Stage__c)) {
                emplEvalStageIdToNewDataCollection.put (
                    dataCollection.TB_Employee_Evaluation_Stage__c,
                    new Set<TB_Data_Collection__c>()
                );
            }

            emplEvalStageIdToNewDataCollection
                .get(dataCollection.TB_Employee_Evaluation_Stage__c)
                .add(dataCollection);
        }

        return emplEvalStageIdToNewDataCollection;
    }

    private static Map<Id, Map<Id, TB_Data_Collection__c>> prepareEmplEvalStageIdToJsonDataCollIdToDataColl (
        Map<Id, List<TB_JSON_Wrapper__c>> stagesToWrappers
    ) {
        Map<Id, Map<Id, TB_Data_Collection__c>> emplEvalStageIdToJsonDataCollIdToDataColl
            = new Map<Id, Map<Id, TB_Data_Collection__c>>();

        for (Id stageId : stagesToWrappers.keySet()) {
            emplEvalStageIdToJsonDataCollIdToDataColl.put(stageId, new Map<Id, TB_Data_Collection__c>());

            if (!stagesToWrappers.get(stageId).isEmpty()) {
                Set<TB_Data_Collection__c> dataCollectionsFromJson = new Set<TB_Data_Collection__c>();
                for (TB_JSON_Wrapper__c jsonWrapper : stagesToWrappers.get(stageId)) {
                    dataCollectionsFromJson.addAll(
                        (Set<TB_Data_Collection__c>) System.JSON.deserialize (
                            jsonWrapper.TB_Wrapper_Value__c,
                            Set<TB_Data_Collection__c>.class
                        )
                    );

                    for (TB_Data_Collection__c singleDataCollectionFromJson : dataCollectionsFromJson) {
                        emplEvalStageIdToJsonDataCollIdToDataColl
                            .get(stageId)
                            .put(singleDataCollectionFromJson.Id, singleDataCollectionFromJson);
                    }
                }
            }
        }

        return emplEvalStageIdToJsonDataCollIdToDataColl;
    }

    private static List<TB_JSON_Wrapper__c> prepareJsonWrappers (
        Map<Id, Map<Id, TB_Data_Collection__c>> emplEvalStageIdToJsonDataCollIdToDataColl
    ) {
        List<TB_JSON_Wrapper__c> jsonWrappers = new List<TB_JSON_Wrapper__c>();

        for (Id stageId : emplEvalStageIdToJsonDataCollIdToDataColl.keySet()) {

            List<TB_Data_Collection__c> newDataCollections
                = emplEvalStageIdToJsonDataCollIdToDataColl.get(stageId).values();
            List<List<TB_Data_Collection__c>> splittedDataCollections
                = new List<List<TB_Data_Collection__c>> {newDataCollections};

            if (JSON.serialize(newDataCollections).length() > MAX_SIZE_LONG_TEXT) {
                splittedDataCollections = splitDataCollections(newDataCollections);
            }

            Integer orderIndex = 0;
            for (List<TB_Data_Collection__c> singleListOfDataCollections : splittedDataCollections) {
                jsonWrappers.add (
                    new TB_JSON_Wrapper__c (
                        TB_Object_Id__c = stageId,
                        TB_Object_API_Name__c = stageId.getSobjectType().getDescribe().name,
                        TB_Wrapper_Value__c = JSON.serialize(singleListOfDataCollections),
                        TB_Order__c = orderIndex++
                    )
                );
            }
        }

        return jsonWrappers;
    }

    private static List<List<TB_Data_Collection__c>> splitDataCollections(
        List<TB_Data_Collection__c> dataCollections
    ) {
        List<List<TB_Data_Collection__c>> resultDataCollections
            = new List<List<TB_Data_Collection__c>>{dataCollections};

        for (Integer i = 0; i < resultDataCollections.size(); i++) {

            if (JSON.serialize(resultDataCollections[i]).length() > MAX_SIZE_LONG_TEXT) {
                List<List<TB_Data_Collection__c>> dataCollectionsToAdd = splitList(resultDataCollections.remove(i));
                for (Integer j = dataCollectionsToAdd.size() - 1; j >= 0 ; j--) {
                    if (resultDataCollections.isEmpty()) {
                        resultDataCollections.add(dataCollectionsToAdd[j]);
                    }
                    resultDataCollections.add(i, dataCollectionsToAdd[j]);
                }
                i--;
            }
        }

        return resultDataCollections;
    }

    private static List<List<TB_Data_Collection__c>> splitList(List<TB_Data_Collection__c> dataCollections) {
        List<TB_Data_Collection__c> newDataCollections = new List<TB_Data_Collection__c>();
        for (Integer i = 0; i < dataCollections.size() / 2 + 1; i++) {
            newDataCollections.add(dataCollections.remove(0));
        }

        return new List<List<TB_Data_Collection__c>> {newDataCollections, dataCollections};
    }

    private static String prepareQueryToGeEmployeeEvaluationStages (
        Map<String, List<TB_Data_Collection__c>> methodTypeToDataCollections,
        Set<Id> employeeEvaluationStageIds,
        Boolean includeSourceField,
        Map<String, String> objectPathMap
    ) {
        String query = 'SELECT ';
        Set<String> uniqueFieldsToSelect = new Set<String>{'Id,'};

        for (String method : methodTypeToDataCollections.keySet()) {
            String objectName;
            String field;
            List<TB_Data_Collection__c> dataCollections = methodTypeToDataCollections.get(method);

            for (TB_Data_Collection__c dataColl : dataCollections) {
                switch on method {
                    when 'SourceId' {
                        objectName = dataColl.TB_Source_Object__c;
                        field = 'Id';
                    }
                    when 'TargetId' {
                        objectName = dataColl.TB_Target_Object__c;
                        field = 'Id';
                    }
                    when 'SourceField' {
                        if (includeSourceField) {
                            objectName = dataColl.TB_Source_Object__c;
                            field = dataColl.TB_Source_Object_Field__c;
                        }
                    }
                }

                String objectPaths = objectPathMap?.get(objectName);
                if (objectPaths != null) {
                    uniqueFieldsToSelect.add(objectPaths + field + ',');
                }
            }
        }

        for (String singleField : uniqueFieldsToSelect) {
            query += singleField;
        }

        query = query.removeEnd(',');

        query += ' FROM TB_Employee_Evaluation_Stage__c';
        query += ' WHERE Id IN :employeeEvaluationStageIds';

        return query;
    }

    private static String prepareFieldValue (
        Map<Id, TB_Employee_Evaluation_Stage__c> idToEmployeeEvaluationStages,
        TB_Data_Collection__c dataColl,
        String method,
        Map<String, String> objectPathMap,
        Boolean includeSourceField
    ) {
        String objectName;
        String field;

        switch on method {
            when 'SourceId' {
                objectName = dataColl.TB_Source_Object__c;
                field = 'Id';
            }
            when 'TargetId' {
                objectName = dataColl.TB_Target_Object__c;
                field = 'Id';
            }
            when 'SourceField' {
                if (includeSourceField) {
                    objectName = dataColl.TB_Source_Object__c;
                    field = dataColl.TB_Source_Object_Field__c;
                }
            }
        }

        if (objectName == null) {
            return null;
        }

        String objectPaths = objectPathMap.get(objectName);

        List<String> objectRelations = objectPaths.split('\\.');
        SObject obj = idToEmployeeEvaluationStages.get(dataColl.TB_Employee_Evaluation_Stage__c);
        Integer objectRelationsSize = objectRelations.size();
        for (Integer i = 0; i < objectRelationsSize; i++) {
            String path = objectRelations[i];
            if (String.isNotBlank(path)) {
                obj = obj.getSObject(path);
            }
        }

        return String.valueOf(obj?.get(field));
    }

    private static Map<Id, List<TB_JSON_Wrapper__c>> getEmployeeEvaluationStageIdsToJsonWrapper(Set<Id> stageIds) {

        Map<Id, List<TB_JSON_Wrapper__c>> employeeEvaluationStageIdsToJsonWrapper = new Map<Id, List<TB_JSON_Wrapper__c>>();
        for (Id singleId : stageIds) {
            employeeEvaluationStageIdsToJsonWrapper.put(singleId, new List<TB_JSON_Wrapper__c>());
        }

        List<TB_JSON_Wrapper__c> jsonWrappers = [
            SELECT Id, TB_Object_Id__c, TB_Wrapper_Value__c, TB_Order__c
            FROM TB_JSON_Wrapper__c
            WHERE TB_Object_Id__c IN :stageIds
            ORDER BY TB_Order__c ASC
        ];

        for (TB_JSON_Wrapper__c singleJsonWrapper : jsonWrappers) {
            employeeEvaluationStageIdsToJsonWrapper
                .get(singleJsonWrapper.TB_Object_Id__c)
                .add(singleJsonWrapper);
        }

        return employeeEvaluationStageIdsToJsonWrapper;
    }
}