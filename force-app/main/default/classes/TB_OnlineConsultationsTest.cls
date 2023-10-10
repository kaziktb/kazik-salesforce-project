@isTest
public without sharing class TB_OnlineConsultationsTest {

    @isTest
    public static void getConsultationsURLTest(){

        List<Contact> contacts = new List<Contact>();

        Contact tempContact1 = new Contact();
        tempContact1.LastName = 'Test1';
        tempContact1.hed__Citizenship__c = 'Poland';
        contacts.add(tempContact1);

        Contact tempContact2 = new Contact();
        tempContact2.LastName = 'Test2';
        tempContact2.hed__Citizenship__c = 'Germany';
        contacts.add(tempContact2);

        insert contacts;

        List<TB_Offered_Product__c> products = new List<TB_Offered_Product__c>();

        TB_Offered_Product__c product1 = new TB_Offered_Product__c();
        product1.TB_Online_Consultations_URL_PL__c = 'https://www.google.com';
        products.add(product1);

        TB_Offered_Product__c product2 = new TB_Offered_Product__c();
        product2.TB_Online_Consultations_URL_EN__c = 'https://www.google.com';
        products.add(product2);

        TB_Offered_Product__c product3 = new TB_Offered_Product__c();
        products.add(product3);

        TB_Offered_Product__c product4 = new TB_Offered_Product__c();
        products.add(product4);

        insert products;

        products[0].TB_Enable_Online_Consultations__c = true;
        products[1].TB_Enable_Online_Consultations__c = true;

        update products;

        List<hed__Application__c> applications = new List<hed__Application__c>();

        hed__Application__c application1 = new hed__Application__c();
        application1.hed__Applicant__c = contacts[0].id;
        application1.TB_Applying_To_Offered_Product__c = products[0].id;
        application1.TB_Applicant_Citizenship__c = 'Poland';
        applications.add(application1);

        hed__Application__c application2 = new hed__Application__c();
        application2.hed__Applicant__c = contacts[1].id;
        application2.TB_Applying_To_Offered_Product__c = products[1].id;
        application2.TB_Applicant_Citizenship__c = 'Germany';
        applications.add(application2);

        hed__Application__c application3 = new hed__Application__c();
        application3.hed__Applicant__c = contacts[0].id;
        application3.TB_Applying_To_Offered_Product__c = products[2].id;
        application3.TB_Applicant_Citizenship__c = 'Poland';
        applications.add(application3);

        hed__Application__c application4 = new hed__Application__c();
        application4.hed__Applicant__c = contacts[1].id;
        application4.TB_Applying_To_Offered_Product__c = products[3].id;
        application4.TB_Applicant_Citizenship__c = 'Germany';
        applications.add(application4);

        insert applications;

        test.startTest();
        String applicationTest1 = TB_OnlineConsultations.getConsultationsURL(applications[0].id);
        String applicationTest2 = TB_OnlineConsultations.getConsultationsURL(applications[1].id);
        String applicationTest3 = TB_OnlineConsultations.getConsultationsURL(applications[2].id);
        String applicationTest4 = TB_OnlineConsultations.getConsultationsURL(applications[3].id);
        test.stopTest();

        System.assertNotEquals(null, applicationTest1);
        System.assertNotEquals(null, applicationTest2);
        System.assertEquals(null, applicationTest3);
        System.assertEquals(null, applicationTest4);
    }
}