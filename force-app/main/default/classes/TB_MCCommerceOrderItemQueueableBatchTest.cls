/**
 * Created by Adam Czeczuk on 27/07/2022.
 */
@IsTest
public with sharing class TB_MCCommerceOrderItemQueueableBatchTest {

    @TestSetup
    static void testSetup() {

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        User u = new User(
                Username = 'test@swps.edu.pl.test',
                LastName = 'Testowy',
                Email = 'test@swps.edu.pl.test',
                Alias = 'test',
                ProfileId = p.Id,
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert u;

        Contact ct = new Contact(
                LastName = 'Testowy',
                TB_User__c = u.Id,
                Email = 'test@swps.edu.pl.test');
        insert ct;

        TB_Commerce_Order__c commerceOrder = new TB_Commerce_Order__c(
                TB_Status__c = 'New',
                TB_Customer__c = ct.id);
        insert commerceOrder;

        TB_Offered_Product__c offeredProduct = new TB_Offered_Product__c(
                Name = 'Kurs',
                TB_Product_Name_PL__c = 'Kurs PL',
                TB_Product_Name_EN__c = 'Kurs EN',
                TB_Ecommerce_Product_Group__c = 'Language_Courses',
                TB_Product_Profile__c = 'Language',
                TB_Level_Of_Advancement__c = 'Medium',
                TB_Group_Size__c = 10,
                TB_Mode_of_Classes__c = 'Online',
                TB_Duration_Days__c = 1,
                TB_Duration_Hours__c = 8,
                TB_Location__c = 'Online',
                TB_VAT_Rate__c = 'ZW',
                TB_Status__c = 'Launched');
        insert offeredProduct;

        TB_Offered_Product_Edition__c offeredProductEdition = new TB_Offered_Product_Edition__c(
                Name = 'Kurs',
                TB_Product_Name_PL__c = 'Kurs PL',
                TB_Product_Name_EN__c = 'Kurs EN',
                TB_Ecommerce_Product_Group__c = 'Language_Courses',
                TB_Product_Profile__c = 'Language',
                TB_Level_Of_Advancement__c = 'Medium',
                TB_Group_Size__c = 10,
                TB_Mode_of_Classes__c = 'Online',
                TB_Duration_Days__c = 1,
                TB_Duration_Hours__c = 8,
                TB_Location__c = 'Online',
                TB_VAT_Rate__c = 'ZW',
                TB_Status__c = 'Launched',
                TB_Start_Date__c = datetime.now()+1,
                TB_End_Date__c = datetime.now()+2,
                TB_Offered_Product__c = offeredProduct.id);
        insert offeredProductEdition;
                
        TB_Commerce_Order_Item__c commerceOrderItem = new TB_Commerce_Order_Item__c(
                TB_Item_Status__c = 'Reserved',
                TB_Commerce_Order__c = commerceOrder.id,
                TB_Offered_Product__c = offeredProduct.id,
                TB_Offered_Product_Edition__c = offeredProductEdition.id,
                TB_Customer__c = ct.id);
        insert commerceOrderItem;
        
        insert new TB_Marketing_Cloud_API__c(
                SetupOwnerId = UserInfo.getOrganizationId(),
                TB_Auth_End_Point__c = 'https://test.com',
                TB_POST_End_Point__c = 'https://test.com',
                TB_Client_Id__c = '123',
                TB_Secret__c = '123',
                TB_Grant_Type__c = 'token'
        ); 
    }

    @IsTest
    static void ClientCommerceTest() {
        Test.setMock(HttpCalloutMock.class, new TB_MCClientQueueableBatchMock());
        Id orderId = [SELECT Id FROM TB_Commerce_Order_Item__c LIMIT 1].Id;

        TB_MCClient.WrapperClass wc = new TB_MCClient.WrapperClass();
        wc.recordId = orderId;
        wc.eventKey = 'Test';
        wc.journey = 'Test';
        List<TB_MCClient.WrapperClass> wcList = new List<TB_MCClient.WrapperClass>();
        wcList.add(wc);

        Test.startTest();
        TB_MCCommerceOrderItemQueueableBatch batch = new TB_MCCommerceOrderItemQueueableBatch(wcList);
        Database.executeBatch(batch);
        Test.stopTest();
    }

    @IsTest
    static void ClientMCTest() {
        Test.setMock(HttpCalloutMock.class, new TB_MCClientQueueableBatchMock());
        Id orderItemId = [SELECT Id FROM TB_Commerce_Order_Item__c LIMIT 1].Id;

        TB_MCClient.WrapperClass wc = new TB_MCClient.WrapperClass();
        wc.recordId = orderItemId;
        wc.eventKey = 'Test';
        wc.journey = 'Test';
        List<TB_MCClient.WrapperClass> wcList = new List<TB_MCClient.WrapperClass>();
        wcList.add(wc);

        Test.startTest();
        TB_MCCommerceOrderItemQueueableBatch batch = new TB_MCCommerceOrderItemQueueableBatch(wcList);
        Database.executeBatch(batch);
        Test.stopTest();
    }
}