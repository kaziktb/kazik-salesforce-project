
public with sharing class TB_CT_Utils {
    @AuraEnabled(Cacheable=true)
    public static Id getRecordTypeIdByDeveloperName(String developerName) {
        return [SELECT Id FROM RecordType WHERE DeveloperName =: developerName LIMIT 1].Id;
    }
}