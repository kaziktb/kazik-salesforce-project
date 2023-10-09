public without sharing class SObjectWithoutSharingUtils {
    public static List<SObject> fetchSObjectList(String query, Map<String, Object> bindMap, AccessLevel accessLevelMode) {
        return Database.queryWithBinds(String.escapeSingleQuotes(query), bindMap, accessLevelMode);
    }

    public static void insertSObjectList(List<SObject> records, AccessLevel accessLevelMode) {
        Database.insert(records, accessLevelMode);
    }

    public static void deleteSObjectList(List<SObject> records, AccessLevel accessLevelMode) {
        Database.delete(records, accessLevelMode);
    }
}