@isTest
private class TB_IC_FetchRelatedServicesTest {
    private static final String PARTNER_CONTACT_RECORD_TYPE_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('TB_Partner').getRecordTypeId();
    private static final String DEPARTMENT_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('University_Department').getRecordTypeId();
    private static final String PARTNER_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();
  
    @TestSetup
    static void makeData(){
        Id currUserId = UserInfo.getUserId();

        Account testAccount = new Account(Name = 'Test Account', RecordTypeId = PARTNER_RECORD_TYPE_ID, OwnerId = currUserId );

        Account department = new Account(Name = 'TEST', RecordTypeId = DEPARTMENT_RECORD_TYPE_ID, OwnerId = currUserId );
        insert new List<Account>{testAccount, department};

        Contact contactSignedBy = new Contact(
            firstName = 'contactSignedBy',
            lastName = 'TEST3',
            TB_Profession__c = 'TEST3',
            hed__WorkEmail__c = 'test3@test.test',
            hed__WorkPhone__c ='12345678',
            TB_x_Record_Type__c = 'TB_Partner',
            RecordTypeId = PARTNER_CONTACT_RECORD_TYPE_ID,
            OwnerId = currUserId 
        );
   
        Contract testContract = new Contract(
            AccountId = testAccount.Id,
            DT_Company_Signed_By_Contact__c = contactSignedBy.Id, 
            DT_Document_Type__c = 'Annex',
            Status = 'Not_Implemented',
            DT_Scope_of_Cooperation__c = 'testowy test',
            DT_Department__c = department.Id,
            OwnerId = currUserId
        );
        insert testContract;
        
        Product2 testProduct = new Product2(
            Name = 'Test Product', 
            DT_Product_Name_EN__c = 'Test Product EN', 
            Family = 'Career_Services_Contracts', 
            DT_Product_Family_PL__c = 'Umowy BK'
            );
            insert testProduct;

        DT_Contract_Product__c testContractProduct = new DT_Contract_Product__c(
            DT_Contract__c = testContract.Id, 
            DT_Product_Name__c = testProduct.Id
            );
        insert testContractProduct;     
    }
   
    @isTest
    static void testGetServices() {  

        Contract test = [SELECT Id FROM Contract LIMIT 1];

        List<Product2> relatedServicesList = TB_IC_FetchRelatedServices.getServices(test.Id);

        System.assertEquals(1, relatedServicesList.size());
    }
}   