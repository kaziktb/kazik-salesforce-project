public without sharing class TB_IC_ContractDatabaseController {
    private static final String ALL_FAMILIES_FILTER_CRITERIA = 'ALL_FAMILIES';
    private static final String MAIN_GROUPS_FILTER_CRITERIA = 'MAIN_GROUPS';
    private static final String CONTRACT_ID_PREFIX = 'C-';

    public class ContractWrapper {
        @AuraEnabled public String Id { get; set; }
        @AuraEnabled public String ContractId { get; set; }
        @AuraEnabled public String Account_Name { get; set; }
        @AuraEnabled public String Document_Type { get; set; }
        @AuraEnabled public String Department { get; set; }
        @AuraEnabled public String Cooperation_Rating { get; set; }
        @AuraEnabled public String Domain { get; set; }
        @AuraEnabled public String Status { get; set; }
    }

    @AuraEnabled
    public static List<ContractWrapper> getContracts(String searchQuery, String orderByValue, String filterByDomainValue, String filterByStatusValue, String filterByProductFamilyValue, String filterByGroupValue, Integer recordsLimit) {
        try {
            String currentUserId = UserInfo.getUserId();
            String currentContactId = [SELECT Id FROM Contact WHERE TB_User__c = :currentUserId].Id;

            String query = 'SELECT Id, ContractNumber, Account.Name, toLabel(DT_Document_Type__c), DT_Department__r.Name, TB_Cooperation_Rating__c, DT_Domain__c, toLabel(Status), (SELECT DT_Family__c FROM Contract_Products__r)\n' +
                '            FROM Contract\n' +
                '            WHERE DT_Department__r.Name LIKE \'' + searchQuery + '\'\n' +
                '            AND Is_Individual_Internship__c = false ' +
                '            AND (DT_Domain__c ' + (filterByDomainValue == '%' ? '= NULL OR DT_Domain__c LIKE ' : '= ') + '\'' + filterByDomainValue + '\')\n' +
                '            AND Status ' + (filterByStatusValue == '%' ? 'LIKE ' : '= ') + '\'' + filterByStatusValue + '\'\n';

            if (filterByProductFamilyValue != ALL_FAMILIES_FILTER_CRITERIA) {
                query += 'AND Id IN (SELECT DT_Contract__c FROM DT_Contract_Product__c WHERE ' + (UserInfo.getLanguage() == 'pl' ? 'TB_Product_Family_PL__c ' : 'DT_Family__c ') + 'LIKE \'' + filterByProductFamilyValue + '\')\n';
            }

            if (filterByGroupValue == MAIN_GROUPS_FILTER_CRITERIA) {
                query += 'AND (DT_SWPS_Contact_Person__c = \'' + currentContactId + '\' OR DT_Additional_SWPS_Contact_Person__c = \'' + currentContactId + '\' OR DT_Company_Signed_By_Contact__c = \'' + currentContactId + '\' OR OwnerId = \'' + currentUserId + '\')\n';
            }

            query += 'ORDER BY ' + orderByValue + ' LIMIT ' + recordsLimit;

            List<ContractWrapper> contractWrappers = new List<ContractWrapper>();

            for (Contract contract : Database.query(query)) {
                ContractWrapper contractWrapper = new ContractWrapper();

                contractWrapper.Id = contract.Id;
                contractWrapper.ContractId = CONTRACT_ID_PREFIX + contract.ContractNumber;
                contractWrapper.Account_Name = contract.Account.Name;
                contractWrapper.Document_Type = contract.DT_Document_Type__c;
                contractWrapper.Department = contract.DT_Department__r.Name;
                contractWrapper.Cooperation_Rating = contract.TB_Cooperation_Rating__c;
                contractWrapper.Domain = contract.DT_Domain__c;
                contractWrapper.Status = contract.Status;

                contractWrappers.add(contractWrapper);
            }

            return contractWrappers;
        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(), TB_IC_ContractDatabaseController.class.getName(), e.getStackTraceString(), ''));
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> picklistValues(String objectName, String fieldName){
        Map<String, String> picklistMap = new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry ple : picklistValues){
            picklistMap.put(ple.getLabel(), ple.getValue());
        }  
        return picklistMap;
    }

    @AuraEnabled(cacheable=true)
    public static List<ContentVersionWrapper> getContractFiles(Id contractId) {
        List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId
                                                           FROM ContentDocumentLink
                                                           WHERE LinkedEntityId = :contractId];
        
        List<ContentVersionWrapper> contentVersions = new List<ContentVersionWrapper>();
        for(ContentDocumentLink cdl : contentDocumentLinks) {
            ContentVersion contentVersion = [SELECT Id, Title, FileType, ContentSize, VersionNumber, ContentUrl, SystemModstamp
                                             FROM ContentVersion
                                             WHERE ContentDocumentId = :cdl.ContentDocumentId
                                             ORDER BY SystemModstamp DESC
                                             LIMIT 1];
            
            ContentVersionWrapper wrapper = new ContentVersionWrapper(contentVersion);
            contentVersions.add(wrapper);
        }
        
        return contentVersions;
    }
    
    public class ContentVersionWrapper {
        @AuraEnabled public String Id;
        @AuraEnabled public String Title;
        @AuraEnabled public String FileType;
        @AuraEnabled public Integer ContentSize;
        
        public ContentVersionWrapper(ContentVersion cv) {
            this.Id = cv.Id;
            this.Title = cv.Title;
            this.FileType = cv.FileType;
            this.ContentSize = cv.ContentSize;
        }
    }
}