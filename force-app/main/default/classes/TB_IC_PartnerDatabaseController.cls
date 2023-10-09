public with sharing class TB_IC_PartnerDatabaseController {
    @AuraEnabled(Cacheable=true)
    public static String getBusinessOrganizationRecordTypeId() {
        try {
            return Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(TB_IC_Constants.BUSINESS_ORGANIZATION_RECORD_TYPE).getRecordTypeId();
        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(), TB_IC_PartnerDatabaseController.class.getName(), e.getStackTraceString(), ''));
        }
    }

    @AuraEnabled
    public static List<Account> getPartners(String searchQuery, String orderByValue, String filterByIndustryValue, Decimal filterByRatingValueStart, Decimal filterByRatingValueEnd, Integer recordsLimit) {
        try {
            String query = 'SELECT Id, Name, DT_Company_Tax_Id__c, DT_KRS__c, DT_REGON__c, toLabel(Industry), TB_Partnership_Rating__c, DT_Partner_Email__c, Phone, Website\n' +
            '            FROM Account\n' +
            '            WHERE Id IN (SELECT AccountId FROM Contract WHERE Is_Individual_Internship__c = false AND Account.RecordTypeId = \'' + SObjectType.Account.getRecordTypeInfosByDeveloperName().get(TB_IC_Constants.BUSINESS_ORGANIZATION_RECORD_TYPE).getRecordTypeId() + '\') \n' +
            '            AND (Name LIKE \'' + searchQuery + '\' OR DT_Company_Tax_Id__c LIKE \'' + searchQuery + '\' OR DT_KRS__c LIKE \'' + searchQuery + '\' OR DT_REGON__c LIKE \'' + searchQuery + '\')\n';

        if(filterByIndustryValue != '%'){
            query +=  ' AND Industry = ' + '\'' + filterByIndustryValue + '\'\n';
        }
        
        if (filterByRatingValueStart != null) {
            query += 'AND TB_Partnership_Rating__c >= ' + filterByRatingValueStart + 'AND TB_Partnership_Rating__c <= ' + filterByRatingValueEnd + '\n';
        }
        query += 'ORDER BY ' + orderByValue + ' LIMIT ' + recordsLimit;

        return Database.query(query);
        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(), TB_IC_PartnerDatabaseController.class.getName(), e.getStackTraceString(), ''));
        }
    }
}