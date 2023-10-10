@isTest
private class TB_OpportunityLineItemHandlerTest {
   @TestSetup
   static void makeData(){
    Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('DT_Partnerships').getRecordTypeId();
        Account acc = new Account();
        acc.Name ='Test Name';
        insert acc;

        Product2 prod = new Product2(Name = 'Test Product', 
        Family = 'Cooperation_In_Degree_Program_Development',
        DT_Product_Family_PL__c = 'Współpraca w zakresie realizacji programu studiów');
        insert prod;

        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;

        Opportunity testOppo = new Opportunity();
        testOppo.RecordTypeId = recordTypeId;
        testOppo.Name = 'Test Opppo';
        testOppo.AccountId = acc.Id;
        testOppo.DT_Main_Product_Family__c = 'Cooperation_In_Degree_Program_Development';
        testOppo.Pricebook2Id = Test.getStandardPricebookId();
        testOppo.TB_Approval_Date__c = Date.today();
        testOppo.TB_Negotiation_Date__c = Date.today();
        testOppo.StageName = 'New';
        testOppo.CloseDate = Date.today() + 20;
        insert testOppo;
   }

   @IsTest
   private static void checkSameFamilyAndRedundantProduct(){
    List<OpportunityLineItem> newLineItems = new List<OpportunityLineItem>();
    List<Opportunity> oppo_parents = [SELECT Id FROM Opportunity Limit 1 ];
    List<Product2> prod_parents = [SELECT Id FROM Product2 Limit 1 ];

        OpportunityLineItem item = new OpportunityLineItem();
        item.OpportunityId = oppo_parents.get(0).Id;
        item.Product2Id = prod_parents.get(0).Id;
        item.Quantity = 1;
        item.TotalPrice = 12000;
        
    Test.startTest();
      insert item;
    Test.stopTest();

    System.assert(![SELECT ID FROM OpportunityLineItem].isEmpty(), 'Opportunity should be created' );
   }
}