public without sharing class TB_IC_RelatedContractController {
    private static final String BLANK_VALUE = '-';
        
    @AuraEnabled(Cacheable=true)
    public static List<ContractWrapper> fetchRelatedPartnerContract(Id partnerId) {

        List<ContractWrapper> PartnerContractWrappers = new List<ContractWrapper>();
        List<Contract> contracts = [SELECT Id, ContractNumber, DT_Document_Type__c, DT_Department__c, TB_Cooperation_Rating__c, Status FROM Contract WHERE AccountId = :partnerId AND Is_Individual_Internship__c = false];
        
        for (Contract record : contracts) {
            ContractWrapper PartnerContractWrapper = new ContractWrapper();
            PartnerContractWrapper.setValues(
                    record.Id,
                    record.ContractNumber,
                    record.DT_Document_Type__c,
                    record.DT_Department__c,
                    record.TB_Cooperation_Rating__c,
                    record.Status
            );
            PartnerContractWrappers.add(PartnerContractWrapper);
        }
        return PartnerContractWrappers;
    }

    public class ContractWrapper {
        @AuraEnabled public Id id;
        @AuraEnabled public String contractNumber;
        @AuraEnabled public String typeOfDocument;
        @AuraEnabled public String department;
        @AuraEnabled public String rating;
        @AuraEnabled public String status;

        public void setValues(
                Id id,
                String contractNumber,
                String typeOfDocument,
                String department,
                String rating,
                String status
        ) {
            this.id = id;
            this.contractNumber = setValueForNull(ContractNumber);
            this.typeOfDocument = setValueForNull(typeOfDocument);
            this.department = setValueForNull(department);
            this.rating = setValueForNull(rating);
            this.status = setValueForNull(status);
        }
    }

    private static String setValueForNull(String value) {
        return (value == null) ? BLANK_VALUE : value;
    }
}