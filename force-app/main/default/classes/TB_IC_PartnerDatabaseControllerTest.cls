@isTest
private class TB_IC_PartnerDatabaseControllerTest {
    private static final Id DEPARTMENT_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('University_Department').getRecordTypeId();
    @testSetup
    static void setup() {
        Account department = new Account(Name = 'Department', RecordTypeId = DEPARTMENT_RECORD_TYPE_ID);
        insert department;

        List<Account> accounts = new List<Account>();
        for(Integer i = 0; i < 5; i++) {
            Account acc = new Account(
                Name = 'Test Account ' + i,
                RecordTypeId = TB_IC_PartnerDatabaseController.getBusinessOrganizationRecordTypeId(),
                Industry = 'Banking',
                TB_Partnership_Rating__c = i + 1,
                DT_Company_Tax_Id__c = '123456789',
                DT_KRS__c = 'KRS123456789',
                DT_REGON__c = 'REGON123456789',
                DT_Partner_Email__c = 'test' + i + '@example.com',
                Phone = '123-456-7890',
                Website = 'http://example.com'
            );
            accounts.add(acc);
        }
        insert accounts;

        List<Contract> contracts = new List<Contract>();
        for(Account acc : accounts) {
            Contract con = new Contract(
                AccountId = acc.Id,
                DT_Document_Type__c = 'Annex',
                DT_Department__c = department.Id,
                TB_Cooperation_Rating__c = String.valueOf(acc.TB_Partnership_Rating__c),
                Status = 'Not_Implemented',
                Name = 'Test Contract',
                StartDate = Date.today(),
                EndDate = Date.today().addMonths(6)
            );
            contracts.add(con);
        }
        insert contracts;    
    }

    @isTest
    static void testGetBusinessOrganizationRecordTypeId() {
        String recordTypeId = TB_IC_PartnerDatabaseController.getBusinessOrganizationRecordTypeId();
        System.assertEquals(
            Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(TB_IC_Constants.BUSINESS_ORGANIZATION_RECORD_TYPE).getRecordTypeId(),
            recordTypeId,
            'getBusinessOrganizationRecordTypeId() method did not return the correct record type Id'
        );
    }

    @isTest
    static void testGetPartners() {
        List<Account> searchResult = TB_IC_PartnerDatabaseController.getPartners('Test Account 0', 'Name ASC', 'Banking', 0, 5, 1);
        System.assertEquals(1, searchResult.size(), 'Search query did not return the expected result');

        List<Account> orderByResult = TB_IC_PartnerDatabaseController.getPartners('%', 'TB_Partnership_Rating__c DESC', 'Banking', 0, 5, 5);
        System.assertEquals(5, orderByResult.size(), 'orderByValue did not return the expected number of records');
        System.assertEquals(5.00, orderByResult[0].TB_Partnership_Rating__c, 'orderByValue did not sort records correctly');

        List<Account> filterByIndustryResult = TB_IC_PartnerDatabaseController.getPartners('%', 'Name ASC', 'Finance', 0, 5, 5);
        System.assertEquals(0, filterByIndustryResult.size(), 'filterByIndustryValue did not return the expected number of records');

        List<Account> filterByRatingResult = TB_IC_PartnerDatabaseController.getPartners('%', 'Name ASC', 'Banking', 3, 5, 5);
        System.assertEquals(3, filterByRatingResult.size(), 'filterByRatingValue did not return the expected number of records');
        for(Account acc : filterByRatingResult) {
           System.assert(acc.TB_Partnership_Rating__c >= 3 && acc.TB_Partnership_Rating__c <= 5, 'filterByRatingValue did not filter records correctly');
        }

        List<Account> limitResult = TB_IC_PartnerDatabaseController.getPartners('%', 'Name ASC', 'Banking', 0, 5, 2);
        System.assertEquals(2, limitResult.size(), 'recordsLimit did not limit the number of records returned');
    }
}
