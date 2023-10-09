@IsTest
public class CsAddAgreementControllerTest {

    static final String CONTRACT_NAME = 'Contract 1';
    
    @TestSetup
    static void setup() {
        Account account = new AccountTestData().save().get();
        new ContractTestData()
            .withName(CONTRACT_NAME)
            .withAccount(account.Id)
            .withDTAccount(account.Id)
            .save();
    }

    @IsTest
    static void getRelatedContractsTest() {
        Id accountId = [SELECT Id FROM Account].Id;
        Id contractId = [SELECT Id FROM Contract WHERE DT_Account__c = :accountId].Id;
        List<CsAddAgreementController.ContractOptions> options = new List<CsAddAgreementController.ContractOptions>();
        
        Test.startTest();
        options = CsAddAgreementController.getRelatedContracts(accountId);
        Test.stopTest();

        Assert.areEqual(CONTRACT_NAME, options[0].label);
        Assert.areEqual(contractId, options[0].value);
    }

}