public without sharing class CsStudentFinderController {
    
    @AuraEnabled
    public static List<SObject> query(String query) {
        try {
            return Database.query(query);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}