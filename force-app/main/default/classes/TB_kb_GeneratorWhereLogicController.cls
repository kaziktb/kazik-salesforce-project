public without sharing class TB_kb_GeneratorWhereLogicController {
    private static final String ITEM_ID = 'itemId';
    private static final String FIELD = 'field';
    private static final String OPERATOR = 'operator';
    private static final String VALUE = 'value';
    private static final String SELECT_FOR_QUERY = 'SELECT Id FROM ';
    private static final String WHERE_FOR_QUERY = ' WHERE ';
    private static final List<String> VALUE_TYPES_WITHOUT_QUOTES = new List<String>{
        'BOOLEAN',
        'DATETIME',
        'DOUBLE',
        'INTEGER',
        'LONG',
        'DATE'
    };

    @AuraEnabled(Cacheable=true)
    public static String getQueryResults(String jsonData, String logic, String objectApi) {
        List<Object> filters = (List<Object>) JSON.deserializeUntyped(jsonData);
        List<String> logicSeparated = logic.split(' ');
        String columns;

        String soqlQuery = SELECT_FOR_QUERY + objectApi + WHERE_FOR_QUERY;
        Map<String,Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(objectApi).getDescribe().fields.getMap();

        for (Object filter : filters) {
            Map<String, Object> filterMap = (Map<String, Object>) filter;

            Integer itemId = (Integer) filterMap.get(ITEM_ID);
            String field = (String) filterMap.get(FIELD);
            String operator = (String) filterMap.get(OPERATOR);
            String value = (String) filterMap.get(VALUE);
            String valueType = String.valueOf(fieldsMap.get(field).getDescribe().getType());

            for (Integer i = 0; i < logicSeparated.size(); i++) {
                if (logicSeparated[i] == String.valueOf(itemId)) {
                    logicSeparated[i] = VALUE_TYPES_WITHOUT_QUOTES.contains(valueType) ? field + ' ' + operator +  value  : field + ' ' + operator + ' \'' + value + '\'';
                    break;
                }
            }
        }
        logic = String.join(logicSeparated, ' ');
        List<SObject> records = new List<SObject>();
        try {
            records = Database.query(soqlQuery + logic);
        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_kb_GeneratorWhereLogicController.class.getName(),e.getStackTraceString(),UserInfo.getUserId()));
        }
        return soqlQuery + logic;
    }

    @AuraEnabled
    public static void modifyGroupAssignmentLogic(Id recordId, String logic){
        try {
            TB_Public_Group_Assignment__c recordToModify = [SELECT Id, TB_Group_Assignment_Logic__c FROM TB_Public_Group_Assignment__c WHERE Id =: recordId LIMIT 1];
            recordToModify.TB_Group_Assignment_Logic__c = logic;
            update recordToModify;
        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_kb_GeneratorWhereLogicController.class.getName(),e.getStackTraceString(),recordId));
        }
    }
}