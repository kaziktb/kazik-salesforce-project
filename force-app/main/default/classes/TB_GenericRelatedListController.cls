/**
 * Created by kacperjachowicz on 26/08/2021.
 */

public with sharing class TB_GenericRelatedListController {

    @AuraEnabled (Cacheable = true)
    public static List<SObject> retrieveRelatedData(String fieldApis, String objectName,Id recordId, String standardFilter, String sortOrder) {
        try {
            return Database.query('SELECT ' + fieldApis + ' FROM ' + objectName + ' WHERE ' + standardFilter + ' ORDER BY ' + sortOrder);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteData(List<Id> recordIds, String objectName) {
        try {
            List<SObject> recordsToDelete = Database.query('SELECT ID ' + ' FROM ' + objectName + ' WHERE Id IN :recordIds');
            delete recordsToDelete;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static String retrieveColumnData(String fieldApis, String objectName, Boolean sortable, Boolean editable) {
        try {
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType leadSchema = schemaMap.get(objectName);
            Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
            List<Object> responseWrappers = new List<Object>();
            List<String> listOfFields = fieldApis.split(',');
            Integer iterator = 1;

            for (SObjectField fieldName : fieldMap.values()) {
                if (listOfFields.contains(String.valueOf(fieldName))) {
                    ResponseWrapper responseWrapper = new ResponseWrapper();
                    responseWrapper.label = fieldMap.get(String.valueOf(fieldName)).getDescribe().getLabel();
                    responseWrapper.fieldName = String.valueOf(fieldName);
                    responseWrapper.sortable = sortable;
                    responseWrapper.editable = editable;
                    responseWrapper.id = iterator;
                    responseWrappers.add(responseWrapper);
                    iterator++;
                }
            }
            TypeWrapper typeWrapper = new TypeWrapper();
            typeWrapper.type = 'action';
            typeWrapper.typeAttributes = new RowActions(new List<Object>{
                    new Actions('View', 'show_details')
            });
            responseWrappers.add(typeWrapper);

            return JSON.serialize(responseWrappers);
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
        }
        return null;
    }

    public class TypeWrapper {
        public String type;
        public Object typeAttributes;

        public TypeWrapper() {
        }
    }

    public class ResponseWrapper {
        public Integer id;
        public String label;
        public String fieldName;
        public Boolean sortable;
        public Boolean editable;

        public ResponseWrapper() {
        }
    }

    public class RowActions {
        public List<Object> rowActions;

        public RowActions(List<Object> rowActions) {
            this.rowActions = rowActions;
        }
    }
    public class Actions {
        public String label;
        public String name;

        public Actions(String label, String name) {
            this.label = label;
            this.name = name;
        }
    }

}