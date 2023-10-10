public without sharing class TB_IC_ContractDetailsController {
    private static final String BLANK_VALUE = '-';
    private static final String CONTRACT_PREFIX = 'C-';

    public class ContractWrapper {
        @AuraEnabled public String Id { get; set; }
        @AuraEnabled public String ContractNumber { get; set; }
        @AuraEnabled public String AccountId { get; set; }
        @AuraEnabled public String AccountName { get; set; }
        @AuraEnabled public String RealizationAccountName { get; set; }
        @AuraEnabled public String Industry { get; set; }
        @AuraEnabled public String DocumentType { get; set; }
        @AuraEnabled public String Status { get; set; }
        @AuraEnabled public Boolean Annexed { get; set; }
        @AuraEnabled public String Annex { get; set; }
        @AuraEnabled public String DepartmentName { get; set; }
        @AuraEnabled public String Domain { get; set; }
        @AuraEnabled public String Discipline { get; set; }
        @AuraEnabled public String StartDate { get; set; }
        @AuraEnabled public String EndDate { get; set; }
        @AuraEnabled public Boolean IndefinitePeriod { get; set; }
        @AuraEnabled public String CooperationRating { get; set; }
        @AuraEnabled public String RatingComments { get; set; }
        @AuraEnabled public String ScopeOfCooperation { get; set; }
        @AuraEnabled public String FinancialConditions { get; set; }
        @AuraEnabled public String ContractValue { get; set; }
        @AuraEnabled public String CompanySignedDate { get; set; }
        @AuraEnabled public String AnnexedContractNumber { get; set; }
    }

    @AuraEnabled
    public static ContractWrapper getContractDetails(Id contractId) {
        Contract contractData = [
            SELECT Account.Name, DT_Realization_Account__r.Name, toLabel(Account.Industry), toLabel(DT_Document_Type__c), toLabel(Status),
                DT_Annexed__c, ContractNumber, DT_Annex__c, DT_Annex__r.ContractNumber, DT_Department__r.Name, toLabel(DT_Domain__c), toLabel(DT_Discipline__c), StartDate,
                EndDate, DT_Indefinite_Period__c, TB_Cooperation_Rating__c, DT_Rating_Comments__c,
                DT_Scope_of_Cooperation__c, DT_Financial_Conditions__c, DT_Contract_Value__c, CompanySignedDate
            FROM Contract
            WHERE Id = :contractId
        ];

        ContractWrapper contractWrapper = new ContractWrapper();
        contractWrapper.Id = contractData.Id;
        contractWrapper.ContractNumber = contractData.ContractNumber != null ? CONTRACT_PREFIX + contractData.ContractNumber : BLANK_VALUE;
        contractWrapper.AccountId = contractData.Account.Id;
        contractWrapper.AccountName = contractData.Account.Name;
        contractWrapper.RealizationAccountName = setValueForNull(contractData.DT_Realization_Account__r.Name);
        contractWrapper.Industry = setValueForNull(contractData.Account.Industry);
        contractWrapper.DocumentType = setValueForNull(contractData.DT_Document_Type__c);
        contractWrapper.Status = setValueForNull(contractData.Status);
        contractWrapper.Annexed = contractData.DT_Annexed__c;
        contractWrapper.Annex = contractData.DT_Annex__c;
        contractWrapper.DepartmentName = setValueForNull(contractData.DT_Department__r.Name);
        contractWrapper.Domain = setValueForNull(contractData.DT_Domain__c);
        contractWrapper.Discipline = setValueForNull(contractData.DT_Discipline__c);
        contractWrapper.StartDate = setValueForNull(contractData.StartDate);
        contractWrapper.EndDate = setValueForNull(contractData.EndDate);
        contractWrapper.IndefinitePeriod = contractData.DT_Indefinite_Period__c;
        contractWrapper.CooperationRating = setValueForNull(contractData.TB_Cooperation_Rating__c);
        contractWrapper.RatingComments = setValueForNull(contractData.DT_Rating_Comments__c);
        contractWrapper.ScopeOfCooperation = setValueForNull(contractData.DT_Scope_of_Cooperation__c);
        contractWrapper.FinancialConditions = setValueForNull(contractData.DT_Financial_Conditions__c);
        contractWrapper.ContractValue = setValueForNull(contractData.DT_Contract_Value__c);
        contractWrapper.CompanySignedDate = setValueForNull(contractData.CompanySignedDate);
        contractWrapper.AnnexedContractNumber = contractData.DT_Annex__r.ContractNumber != null ? CONTRACT_PREFIX + contractData.DT_Annex__r.ContractNumber : BLANK_VALUE;

        return contractWrapper;
    }

    private static String setValueForNull(Object value) {
        return value == null ? BLANK_VALUE : value instanceof Date 
                        ? String.valueOf((Date) value) : String.valueOf(value);
    }
    
}