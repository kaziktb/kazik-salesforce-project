@isTest
private class TB_IC_ContractDatabaseControllerTest {
    @TestSetup
    static void setup() {
        String businessOrganizationRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('University_Department').getRecordTypeId();

        User testUser = TB_TestDataFactory.createUser('System Administrator', true);

        Account testAccount = TB_TestDataFactory.createAccounts(1, businessOrganizationRecordTypeId, true)[0];
        testAccount.Name = 'Sample department';
        update testAccount;

        Contact testContact = TB_TestDataFactory.createContact(true);
        testContact.TB_User__c = testUser.Id;
        update testContact;

        Contract testContract = TB_TestDataFactory.createContract(true, testAccount.Id);
        testContract.DT_Department__c = testAccount.Id;
        testContract.Name = 'Sample contract';
        update testContract;

        ContentVersion testContentVersions = new ContentVersion(
            Title = 'Test Content ',
            VersionData = Blob.valueOf('Test Content'),
            ContentLocation = 'S',
            PathOnClient = 'test.pfg',
            FirstPublishLocationId = testContract.Id
        );
        insert testContentVersions;
    }

    @isTest
    static void testGetContracts() {
        Test.startTest();

        User testUser = [SELECT Id FROM User WHERE LastName = 'last'];
        System.runAs(testUser) {
            String searchQuery = '%';
            String orderByValue = 'ContractNumber ASC';
            String filterByDomainValue = '%';
            String filterByStatusValue = '%';
            String filterByProductFamilyValue = 'ALL_FAMILIES';
            String filterByGroupValue = 'ALL_GROUPS';
            Integer recordsLimit = 10;

            List<TB_IC_ContractDatabaseController.ContractWrapper> contracts = TB_IC_ContractDatabaseController.getContracts(searchQuery, orderByValue, filterByDomainValue, filterByStatusValue, filterByProductFamilyValue, filterByGroupValue, recordsLimit);

            System.assertNotEquals(null, contracts, 'Contracts should not be null');
            System.assertEquals(1, contracts.size(), 'There should be 1 contract returned');
            System.assertEquals('C-', contracts[0].ContractId.substring(0, 2), 'ContractId should start with "C-"');
        }

        Test.stopTest();
    }

    @isTest
    static void testGetContractFiles(){
        Contract contract = [SELECT ID FROM Contract LIMIT 1];
        
        Test.startTest();
        List<TB_IC_ContractDatabaseController.ContentVersionWrapper> contentVersions = TB_IC_ContractDatabaseController.getContractFiles(contract.Id);
        Test.stopTest();
        
        System.assertEquals(1, contentVersions.size());
    }

    @isTest
    static void testGetPicklistValues(){

        Map<String, String> result = TB_IC_ContractDatabaseController.picklistValues('Contract', 'Status');

        System.assertNotEquals(null, result, 'Returned map should not be null');
    }
}
