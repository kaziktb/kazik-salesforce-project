public without sharing class CsAddAgreementController {
    
    @AuraEnabled(cacheable=true)
    public static List<ContractOptions> getRelatedContracts(String accountId) {
        if (accountId == null) {
            return null;
        }

        List<ContractOptions> options = new List<ContractOptions>();

        for (Contract contract : [SELECT Id, Name FROM Contract WHERE DT_Account__c = :accountId ORDER BY Name]) {
            options.add(new ContractOptions(contract.Name, contract.Id));
        }

        return options;
    }

    public class ContractOptions {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;

        public ContractOptions(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

}