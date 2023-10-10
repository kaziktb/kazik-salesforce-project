public without sharing class CsIndividualInternshipAgreementCtrl {

    private static final String CAREER_OFFICE_ACCOUNT_NAME = 'Biuro Karier';

    @AuraEnabled(cacheable=true)
    public static Id getRelatedContractId(String offerId) {
        List<Career_Services_Offer_Contract__c> offerContracts = [
            SELECT Contract__c
            FROM Career_Services_Offer_Contract__c
            WHERE Career_Services_Offer__c = :offerId
            LIMIT 1
        ];

        return offerContracts.isEmpty() ? null : offerContracts[0].Contract__c;
    }

    @AuraEnabled(cacheable=true)
    public static Id getCareerOfficeAccountId() {
        List<Account> accounts = [
            SELECT Id
            FROM Account
            WHERE RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_DEPARTMENT_API_NAME
                AND Name = :CAREER_OFFICE_ACCOUNT_NAME
            LIMIT 1
        ];

        return accounts.isEmpty() ? null : accounts[0].Id;
    }
    
}