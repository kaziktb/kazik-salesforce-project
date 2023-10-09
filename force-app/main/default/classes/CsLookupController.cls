public without sharing class CsLookupController {
    
    @AuraEnabled(cacheable=true)
    public static List<SObject> search(String searchTerm, String fieldName, String objectName, Boolean withUniqueValues) {
        String searchString = '\'%' + String.escapeSingleQuotes(searchTerm.trim()) + '%\'';
        String field = String.isBlank(fieldName) ? 'Name' : fieldname;
        String query = 'SELECT {0} FROM {1} WHERE {0} LIKE {2} LIMIT 5';
        query = String.format(query, new List<Object>{field, objectName, searchString});

        List<SObject> records = Database.query(query);

        if (withUniqueValues) {
            Map<String, SObject> field2Record = new Map<String, SObject>();

            for (SObject record : records) {
                field2Record.put(String.valueOf(record.get(field)), record);
            }

            records = field2Record.values();
        }

        return records;
    }

}