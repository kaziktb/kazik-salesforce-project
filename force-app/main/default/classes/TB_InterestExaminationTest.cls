@isTest
public without sharing class TB_InterestExaminationTest {
    @TestSetup
    static void testSetup() {
        insert new TB_Marketing_Cloud_API__c(
            TB_Auth_End_Point__c = 'https://test.com',
            TB_POST_End_Point__c = 'https://test.com'
        );
    }

    public static List<Id> dataFactory(){
        List<Id> testIds = new List<Id>();

        List<Contact> contacts = new List<Contact>();
        Contact tempContact1 = new Contact();
        tempContact1.LastName = 'Test1';
        tempContact1.hed__Citizenship__c = 'Poland';
        contacts.add(tempContact1);

        Contact tempContact2 = new Contact();
        tempContact2.LastName = 'Test2';
        tempContact2.hed__Citizenship__c = 'Germany';
        contacts.add(tempContact2);

        Contact tempContact3 = new Contact();
        tempContact3.LastName = 'Test3';
        contacts.add(tempContact3);

        insert contacts;
        
        TB_Offered_Product__c offeredProduct = new TB_Offered_Product__c();
        offeredProduct.Name = 'Test product';
        insert offeredProduct;

        TB_Related_Offered_Product__c relatedOfferedProduct = new TB_Related_Offered_Product__c();
        relatedOfferedProduct.TB_Active__c = true;
        relatedOfferedProduct.TB_Parent_Product__c = offeredProduct.id;
        relatedOfferedProduct.TB_Relation_Type__c = 'Interest_Examination_Reserve_List';
        relatedOfferedProduct.TB_Citizenship_Dependency__c = 'Everyone';
        relatedOfferedProduct.TB_Deactivation_Mode__c = 'Automatic';

        insert relatedOfferedProduct;

        TB_JSON_Wrapper__c wrapper = new TB_JSON_Wrapper__c();
        wrapper.TB_Object_Id__c = relatedOfferedProduct.Id;

        insert wrapper;
        
        List<hed__Application__c> applications = new List<hed__Application__c>();
        
        hed__Application__c application1 = new hed__Application__c();
        application1.hed__Applicant__c = contacts[0].id;
        application1.TB_Applying_To_Offered_Product__c = offeredProduct.id;
        application1.TB_Applicant_Citizenship__c = 'Poland';
        applications.add(application1);

        hed__Application__c application2 = new hed__Application__c();
        application2.hed__Applicant__c = contacts[1].id;
        application2.TB_Applying_To_Offered_Product__c = offeredProduct.id;
        application2.TB_Applicant_Citizenship__c = 'Germany';
        applications.add(application2);

        hed__Application__c application3 = new hed__Application__c();
        application3.hed__Applicant__c = contacts[2].id;
        application3.TB_Applying_To_Offered_Product__c = offeredProduct.id;
        applications.add(application3);
        
        insert applications;

        testIds.add(offeredProduct.id);

        for(Integer i = 0; i < applications.size(); i++){
            testIds.add(applications[i].Id);
        }
        
        return testIds;
    }

    @isTest
    public static void getApplicationDataTest(){
        List<Id> testIds = dataFactory();
        test.startTest();
        hed__Application__c application = TB_InterestExaminationController.getApplicationData(testIds[1]);
        test.stopTest();
        System.assertNotEquals(null, application.Id);
    }

    @isTest
    public static void getRelatedProductsTest(){
        List<Id> testIds = dataFactory();
        List<List<TB_Related_Offered_Product__c>> offeredProducts = new List<List<TB_Related_Offered_Product__c>>();
        test.startTest();
        offeredProducts.add(TB_InterestExaminationController.getRelatedProducts(testIds[1]));
        offeredProducts.add(TB_InterestExaminationController.getRelatedProducts(testIds[2]));
        offeredProducts.add(TB_InterestExaminationController.getRelatedProducts(testIds[3]));
        test.stopTest();
        System.assertEquals(3, offeredProducts.size());
    }

    @isTest
    public static void changeApplicationTest(){
        Test.setMock(HttpCalloutMock.class, new TB_MCClientQueueableBatchMock());
        List<Id> testIds = dataFactory();
        test.startTest();
        TB_InterestExaminationController.changeApplication(testIds[1], testIds[0]);
        test.stopTest();
        hed__Application__c application = [SELECT Id, hed__Applicant__c, hed__Application_Status__c FROM hed__Application__c WHERE Id = :testIds[1]];
        System.assertEquals('Cancelled', application.hed__Application_Status__c);
    }

    @isTest
    public static void confirmCurrentApplicationTest(){
        List<Id> testIds = dataFactory();
        test.startTest();
        TB_InterestExaminationController.confirmCurrentApplication(testIds[1]);
        test.stopTest();
        hed__Application__c application = [SELECT Id, TB_Interest_Examination_Confirmed__c FROM hed__Application__c WHERE Id = :testIds[1]];
        System.assertEquals(true, application.TB_Interest_Examination_Confirmed__c);
    }
}