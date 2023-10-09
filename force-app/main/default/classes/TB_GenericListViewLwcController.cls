/**
 * Created by arturlydkowski on 08/07/2021.
 */

public with sharing class TB_GenericListViewLwcController {
    @AuraEnabled
    public static List<Object> getObjects(String objectName, String fields, String filter, String orderBy, Integer limitRecords) {

        String query = 'SELECT ';
        for (String field : fields.split(';')) {
            query += field + ', ';
        }
        query = query.substringBeforeLast(',');
        query += ' FROM ' + objectName;
        if (filter != null) {
            filter = filter.replaceAll('\\{userId\\}', '\'' + UserInfo.getUserId() + '\'');
            query += ' WHERE ' + filter;
        }
        if (orderBy != null) {
            query += ' ORDER BY ' + orderBy;
        }
        if (limitRecords != null) {
            query += ' LIMIT ' + limitRecords;
        }

        return Database.query(query);
    }

    @AuraEnabled
    public static List<Object> getFields(String objectName, String fields, String linkingField) {

        List<String> fieldDevNames = fields.split(';');

        SObject sObj = Schema.getGlobalDescribe().get(ObjectName).newSObject();
        Map<String, SObjectField> sObjectNameToSobjectField = sObj.getSObjectType().getDescribe().fields.getMap();


        List<Map<String,Object>> fieldWrappers = new List<Map<String, Object>>();
        for (String fieldDevName : fieldDevNames) {
            if (sObjectNameToSobjectField.containsKey(fieldDevName)) {
                Schema.DescribeFieldResult describeField = sObjectNameToSobjectField.get(fieldDevName).getDescribe();
                Map<String, Object> fieldWrapper = new Map<String, Object>();
                fieldWrapper.put('label',describeField.getLabel());
                fieldWrapper.put('sortable', 'true');

                if (fieldDevName == linkingField) {
                    fieldWrapper.put('fieldName', 'linkingField');
                    fieldWrapper.put('type', 'url');
                    fieldWrapper.put('typeAttributes',
                        new Map<String, Object> {
                            'label' => new Map<String, String> {
                                'fieldName' => fieldDevName
                             },
                            'target' => '_blank'
                        }
                    );
                } else {
                    fieldWrapper.put('fieldName', describeField.getName());
                    fieldWrapper.put('type',describeField.getType().name());
                    if(fieldWrapper.get('type') == 'PICKLIST') {
                        fieldWrapper.put('fieldName', describeField.getName() + '_Label');
                    }
                }
                fieldWrappers.add(fieldWrapper);
            }
        }
        return fieldWrappers;
    }

    @AuraEnabled
    public static List<String> getFieldsApiNames (String fields, String link) {

        List<String> fieldsList = new List<String>(fields.split(';'));
        if(link != null) {
            fieldsList.addAll(fetchApiNamesFromLink(link));
        }
        return fieldsList;
    }

    public static List<String> fetchApiNamesFromLink (String link) {

        List<String> apiNames = new List<String>();
        while(link.contains('{')) {
            apiNames.add(link.substringBetween('{','}'));
            link = link.substringAfter('}');
        }

        return apiNames;
    }
}