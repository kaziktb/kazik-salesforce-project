public with sharing class TB_ApplicationRetriever {
    private static final String ID_SUFFIX = 'Id';
    private static final String CUSTOM_OBJECT_SUFFIX = '__c';
    private static final String CUSTOM_OBJECT_RELATIONSHIP_SUFFIX = '__r';
    private static final String MAIN_OBJECT_NAME = 'hed__Application__c';
    private static List<String> types = new List<String>{
            'hed__Application__c', 'Contact', 'TB_Offered_Product__c'
    };

    @AuraEnabled
    public static hed__Application__c retrieveAllApplicationFields(String applicationId) {
        String fields = getQueryRecordWithParentFieldsString(MAIN_OBJECT_NAME);
        System.debug(fields);
        hed__Application__c application;
        try {
            application = Database.query('SELECT ' + fields + ' FROM hed__Application__c WHERE Id= :applicationId');
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e, applicationId, TB_ApplicationRetriever.class);
        }
        return application;
    }

    private static String getQueryRecordWithParentFieldsString(String parentSObjectDevName) {
        String queryExpression = '';
        List<String> relationshipsToResolveString = new List<String>();
        List<String> relationshipsToResolveType = new List<String>();
        Map<String, String> relationshipsToObject = new Map<String, String>();
        Map<String, Schema.SObjectField> objSchema = getSObjectFieldsForSObjectMap(parentSObjectDevName);
        Schema.DescribeFieldResult fieldObj;
        for (String field : objSchema.keySet()) {
            fieldObj = getSObjectFieldObj(objSchema, field);
            if (isSObjectFieldTypeReference(fieldObj) && types.contains(getSObjectFieldReferenceToObject(fieldObj))) {
                relationshipsToResolveString.add(getSObjectFieldStringDevName(fieldObj));
                relationshipsToResolveType.add(getSObjectFieldReferenceToObject(fieldObj));
                relationshipsToObject.put(getSObjectFieldStringDevName(fieldObj), getSObjectFieldReferenceToObject(fieldObj));
            } else {
                queryExpression = concatFieldToQuery(queryExpression, getSObjectFieldStringDevName(fieldObj));
            }
        }
        Map<String, List<String>> fieldsForParentRelationshipsMap = generateFieldsForSObject(relationshipsToResolveType);

        for (String obj : relationshipsToObject.keySet()) {

            queryExpression = concatListFieldsToQuery(queryExpression,
                    obj,
                    fieldsForParentRelationshipsMap.get(
                            relationshipsToObject.get(obj)));
        }

        return queryExpression;
    }

    private static String concatListFieldsToQuery(String query, String parentRel, List<String> newFields) {

        for (String field : newFields) {
            query = concatFieldToQuery(query,
                    concatRelationshipToField(
                            getCorrectRelationshipDevName(parentRel),
                            field
                    )
            );
        }
        return query;
    }

    private static String concatFieldToQuery(String query, String newField) {
        return String.isEmpty(query) ? query + newField : query + ',' + newField;
    }

    private static String concatRelationshipToField(String relField, String newField) {
        return relField + '.' + newField;
    }

    private static String getCorrectRelationshipDevName(String field) {

        if (field.endsWith(ID_SUFFIX)) {
            field.removeEnd(ID_SUFFIX);
        }
        if (field.endsWith(CUSTOM_OBJECT_SUFFIX)) {
            field = field.replace(CUSTOM_OBJECT_SUFFIX, CUSTOM_OBJECT_RELATIONSHIP_SUFFIX);
        }

        return field;
    }

    private static Map<String, List<String>> generateFieldsForSObject(List<String> objects) {
        Map<String, List<String>> mapObjectToFields = new Map<String, List<String>>();
        Schema.DescribeSObjectResult[] descResults =
                Schema.describeSObjects(objects);
        for (Schema.DescribeSObjectResult result : descResults) {
            mapObjectToFields.put(
                    getSObjectStringDevName(result),
                    new List<String>(
                            getSObjectFieldsForSObjectMap(getSObjectStringDevName(result)).keySet()
                    ));
        }
        return mapObjectToFields;
    }

    private static String getSObjectFieldReferenceToObject(Schema.DescribeFieldResult fieldDefinition) {
        //this method is only for standard relationships not for the polymorphic
        return String.valueOf(fieldDefinition.getReferenceTo()[0]);
    }

    private static String getSObjectFieldStringDevName(Schema.DescribeFieldResult fieldDefinition) {
        //this method is only for standard relationships not for the polymorphic
        return fieldDefinition.getName();
    }

    private static String getSObjectStringDevName(Schema.DescribeSObjectResult fieldDefinition) {
        //this method is only for standard relationships not for the polymorphic
        return fieldDefinition.getName();
    }

    private static Boolean isSObjectFieldTypeReference(Schema.DescribeFieldResult fieldDefinition) {
        return getSObjectFieldType(fieldDefinition) == Schema.DisplayType.REFERENCE;
    }

    private static Schema.DisplayType getSObjectFieldType(Schema.DescribeFieldResult fieldDefinition) {
        return fieldDefinition.getType();
    }

    private static Schema.DescribeFieldResult getSObjectFieldObj(Map<String, Schema.SObjectField> objFieldMap, String fieldName) {
        return objFieldMap.get(fieldName).getDescribe();
    }

    private static Map<String, Schema.SObjectField> getSObjectFieldsForSObjectMap(String obj) {
        return Schema.getGlobalDescribe().get(obj).getDescribe().fields.getMap();
    }

}