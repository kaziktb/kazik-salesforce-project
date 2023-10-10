@isTest
public with sharing class TB_IC_RelatedContractControllerTest {
    private static final Id DEPARTMENT_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('University_Department').getRecordTypeId();
    private static final Id PARTNER_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();
   
    @TestSetup
    private static void setupMethod() {
        System.runAs(TB_DataFactory.createUser(TB_Constants.PROFILE_NAME_ADMINISTRATOR, TB_Constants.ROLE_DEV_NAME_ADMIN, false)) {
 
            Account partner = new Account(Name = 'Partner', RecordTypeId = PARTNER_RECORD_TYPE_ID);
            Account department = new Account(Name = 'Department', RecordTypeId = DEPARTMENT_RECORD_TYPE_ID);
            insert new List<Account>{partner, department};
            
            Contract contract = new Contract(
                DT_Document_Type__c = 'Annex',
                DT_Department__c = department.Id,
                AccountId = partner.Id,
                TB_Cooperation_Rating__c = '4',
                Status = 'Not_Implemented',
                Name = 'Test Contract',
                StartDate = Date.today(),
                EndDate = Date.today().addMonths(6)
            );
            insert contract;
        }
    }

    @isTest
    static void fetchRelatedPartnerContractsNonEmptyList() {
        Account partner = [SELECT Id FROM Account WHERE Name = 'Partner' LIMIT 1];
        
        Test.startTest();
        List<TB_IC_RelatedContractController.ContractWrapper> partnerContractWrappers = TB_IC_RelatedContractController.fetchRelatedPartnerContract(partner.Id);
        Test.stopTest();

        System.assertEquals(1, partnerContractWrappers.size(), 'Error! Any contract found, Expected: 1');
    }

    @isTest
    static void fetchRelatedPartnerContractEmptyList() {
        Account partner = [SELECT Id FROM Account WHERE Name = 'Partner' LIMIT 1];
        List<Contract> contracts = [SELECT Id FROM Contract WHERE AccountId = :partner.Id];
        delete contracts;

        Test.startTest();
        List<TB_IC_RelatedContractController.ContractWrapper> partnerContractWrappers = TB_IC_RelatedContractController.fetchRelatedPartnerContract(partner.Id);
        Test.stopTest();

        System.assertEquals(0, partnerContractWrappers.size(), 'Error! Contract found, Expected: 0');
    }
}