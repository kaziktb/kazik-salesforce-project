@isTest
private without sharing class TB_SpecializationChoiceTest {
    @TestSetup
    public static void dataFactory() {
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
        relatedOfferedProduct.TB_Relation_Type__c = TB_Constants.TB_SPECIALIZATION_CHOICE_RELATION_TYPE;
        relatedOfferedProduct.TB_Citizenship_Dependency__c = TB_Constants.TB_CITIZENSHIP_DEPENDENCY_EVERYONE;
        relatedOfferedProduct.TB_Deactivation_Mode__c = TB_Constants.TB_SPECIALIZATION_CHOICE_DEACTIVATION_MODE;

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
    }

    @isTest
    public static void getApplicationDataTest() {
        String applicationId = [SELECT Id FROM hed__Application__c][0].Id;
        test.startTest();
        hed__Application__c application = TB_SpecializationChoice.getApplicationData(applicationId);
        test.stopTest();
        System.assertNotEquals(null, application.Id);
    }

    @isTest
    public static void getConsentOptionsTest() {
        test.startTest();
        Map<String, String> consentOptions = TB_SpecializationChoice.getConsentOptions();
        test.stopTest();
        System.assertNotEquals(0, consentOptions.size());
    }

    @isTest
    public static void getRelatedProductsTest() {
        List<hed__Application__c> applications = [SELECT Id FROM hed__Application__c];
        List<List<TB_Related_Offered_Product__c>> offeredProducts = new List<List<TB_Related_Offered_Product__c>>();
        test.startTest();
        offeredProducts.add(TB_SpecializationChoice.getRelatedProducts(applications[0].id, '2'));
        offeredProducts.add(TB_SpecializationChoice.getRelatedProducts(applications[1].id, '3'));
        offeredProducts.add(TB_SpecializationChoice.getRelatedProducts(applications[2].id, '4'));
        test.stopTest();
        System.assertEquals(3, offeredProducts.size());
    }

    @isTest
    public static void setApplicationTest() {
        String applicationId = [SELECT Id FROM hed__Application__c][0].Id;

        Map<String, String> consentOptions = TB_SpecializationChoice.getConsentOptions();
        List<String> consentList = consentOptions.values();
        Boolean isSuccess = TB_SpecializationChoice.setSpecialization(applicationId, consentList[0], 'Test');

        System.assertEquals(true, isSuccess);
    }
}