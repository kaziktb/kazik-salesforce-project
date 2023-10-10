@isTest
private without sharing class TB_IC_ContractDetailsControllerTest {
    private static final Id PARTNER_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();
    private static final Id DEPARTMENT_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('University_Department').getRecordTypeId();
    @TestSetup
    static void setup() {
        User testUser = TB_TestDataFactory.createUser('System Administrator', true);

        Account partnerAccount = TB_TestDataFactory.createAccounts(1, PARTNER_RECORD_TYPE_ID, true)[0];
        partnerAccount.Name = 'sample partner';
        partnerAccount.Industry = 'Banking';

        Account departmentAccount = TB_TestDataFactory.createAccounts(1, DEPARTMENT_RECORD_TYPE_ID, true)[0];
        departmentAccount.Name = 'sample department';
        update new List<Account>{partnerAccount, departmentAccount};

        Contract testContract = new Contract(
            AccountId = partnerAccount.Id,
            DT_Department__c = departmentAccount.Id,
            Status = 'Not_Implemented',
            StartDate = Date.today(),
            EndDate = Date.today().addMonths(6),
            CompanySignedDate = Date.today(),
            DT_Document_Type__c = 'Annex',
            DT_Domain__c = 'DZ0101N',
            DT_Discipline__c = 'DS010104N',
            TB_Cooperation_Rating__c = '2',
            DT_Rating_Comments__c = 'test', 
            DT_Scope_of_Cooperation__c = 'long text',
            DT_Financial_Conditions__c = 'long text'
        );
        insert testContract;
    }

    @isTest
    static void testGetContractDetails(){
        Contract contractId = [SELECT ID FROM Contract LIMIT 1];

        TB_IC_ContractDetailsController.ContractWrapper result = TB_IC_ContractDetailsController.getContractDetails(contractId.Id);

        Assert.areEqual('sample partner', result.AccountName);
        Assert.areEqual('sample department', result.DepartmentName);
        Assert.areEqual('Not Implemented', result.Status);
        Assert.areEqual(Date.today(), Date.valueOf(result.StartDate));
        Assert.areEqual(Date.today().addMonths(6), Date.valueOf(result.endDate));
        Assert.areEqual(Date.today(), Date.valueOf(result.CompanySignedDate));
        Assert.areEqual('Banking', result.Industry);
        Assert.areEqual('Annex', result.DocumentType);
        Assert.areEqual('Dziedzina nauk humanistycznych', result.Domain);
        Assert.areEqual('językoznawstwo', result.Discipline);
        Assert.areEqual('2', result.CooperationRating);
        Assert.areEqual('test', result.RatingComments);
        Assert.areEqual('long text', result.ScopeOfCooperation);
        Assert.areEqual('long text', result.FinancialConditions);
    }    
}