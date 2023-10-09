@isTest
public without sharing class TB_ConsentsControllerTest {
    @TestSetup
    static void testSetup() {
        TB_Admissions_Dictionary__c consentBundle = TB_TestDataFactory.createConsentBundle(false);
        insert consentBundle;

        TB_Admissions_Dictionary__c consent = TB_TestDataFactory.createConsent('Informational', consentBundle.Id, false);
        insert consent;

        TB_Admissions_Dictionary__c consentMarketing = TB_TestDataFactory.createConsent('Marketing', consentBundle.Id, false);
        insert consentMarketing;

        TB_Admissions_Dictionary__c consentTerms = TB_TestDataFactory.createConsent('Terms and Conditions',  consentBundle.Id, false);
        insert consentTerms;

        TB_Admissions_Dictionary__c limitDictionary = new TB_Admissions_Dictionary__c(
            Name = 'Limit',
            TB_Active__c = true,
            TB_Limit__c = 1,
            TB_Product_Group__c = 'Higher_Education',
            RecordTypeId = Schema.SObjectType.TB_Admissions_Dictionary__c.getRecordTypeInfosByDeveloperName().get('TB_Admissions_Limit').getRecordTypeId()
        );
        insert limitDictionary;

        TB_Admissions_Campaign__c campaign = new TB_Admissions_Campaign__c(
            TB_Active__c = true,
            TB_Status__c = 'Launched'
        );
        insert campaign;

        TB_Admissions_Process__c process = TB_TestDataFactory.createAdmissionProcess(false);
        insert process;

        TB_Offered_Product__c product = TB_TestDataFactory.createOfferedProduct(false);
        product.Name = 'Wrapper_Product';
        product.TB_Product_Group__c = 'Higher_Education';
        product.TB_Status__c = 'Launched';
        product.TB_Active__c = true;
        product.TB_Admissions_Campaign__c = campaign.Id;
        product.TB_Product_Start_Date__c = System.now();
        product.TB_Product_End_Date__c = System.now().addDays(10);
        product.TB_Test__c = true;
        product.TB_Admissions_Process__c = process.Id;
        insert product;

        TB_Offered_Product__c productForLimits = TB_TestDataFactory.createOfferedProduct(false);
        productForLimits.Name = 'Limit_Product';
        productForLimits.TB_Product_Group__c = 'Higher_Education';
        productForLimits.TB_Status__c = 'Launched';
        productForLimits.TB_Active__c = true;
        productForLimits.TB_Admissions_Campaign__c = campaign.Id;
        productForLimits.TB_Product_Start_Date__c = System.now();
        productForLimits.TB_Product_End_Date__c = System.now().addDays(10);
        productForLimits.TB_Test__c = true;
        productForLimits.TB_Admissions_Process__c = process.Id;
        insert productForLimits;

        Contact contact = TB_TestDataFactory.createContact(false);
        contact.LastName = 'Kowalski';
        insert contact;

        Contact contactWithoutApplication = TB_TestDataFactory.createContact(false);
        contactWithoutApplication.LastName = 'WithoutApplication';
        insert contactWithoutApplication;

        hed__Application__c application = new hed__Application__c();
        application.TB_Applying_To_Offered_Product__c = product.Id;
        application.hed__Applicant__c = contact.Id;
        application.TB_Test__c = false;
        insert application;
    }

    @isTest
    public static void getConsentsTest(){
        String consentBundleId = [SELECT Id FROM TB_Admissions_Dictionary__c WHERE Name = 'Consent Bundle' LIMIT 1].Id;
        Test.startTest();
        String result = TB_ConsentsController.getConsents();
        Test.stopTest();
        Map<Id,List<TB_ConsentsController.AdmissionConsentsWrapper>> wrappersMap
            = (Map<Id,List<TB_ConsentsController.AdmissionConsentsWrapper>>) JSON.deserialize(result, Map<Id,List<TB_ConsentsController.AdmissionConsentsWrapper>>.class);
        System.assertEquals(1, wrappersMap.size());
        System.assertEquals(3, wrappersMap.get(consentBundleId).size());
        System.assertEquals(0, [SELECT Id FROM TB_Log__c].size());
    }
}