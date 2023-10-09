/**
 * Created by Aneta on 16/09/2021.
 */

@IsTest
private class TB_NewAdmissionControllerTest {

    public static String productCode = '123';
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

        createAdmissionDictionaryLimit(true, 1, 'Higher_Education');
        createAdmissionDictionaryLimit(true, 1, 'Other');

        TB_Admissions_Campaign__c campaign = new TB_Admissions_Campaign__c(
            TB_Active__c = true,
            TB_Status__c = 'Launched'
        );
        insert campaign;

        TB_Admissions_Process__c process = TB_TestDataFactory.createAdmissionProcess(false);
        insert process;

        TB_Offered_Product__c product = createActiveStudyProduct('Wrapper_Product', campaign.Id, true, process.Id, true);
        createActiveStudyProduct('Limit_Product', campaign.Id, false, process.Id, true);

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

        TB_Offered_Product__c productOther = TB_TestDataFactory.createOfferedProduct(false);
        productOther.RecordTypeId = TB_re_Constants.TB_OFFERED_PRODUCT_RT_STUDY;
        insert productOther;

        hed__Application__c applicationOtherGroup = new hed__Application__c();
        applicationOtherGroup.TB_Applying_To_Offered_Product__c = productOther.Id;
        applicationOtherGroup.hed__Applicant__c = contact.Id;
        applicationOtherGroup.TB_Active__c = true;
        applicationOtherGroup.TB_Archived__c = false;
        insert applicationOtherGroup;

        Account account = new Account(
                Name = 'Test'
        );
        insert account;

        hed__Term__c term = new hed__Term__c(
                hed__Account__c = account.Id
        );
        insert term;

        TB_Admissions_Dictionary__c dictionary = new TB_Admissions_Dictionary__c(
                RecordTypeId = TB_re_Constants.ADMISSIONS_DICTIONARY_RT_ADMISSIONS_LIMIT_ID,
                TB_Limit__c = 0,
                TB_Academic_Year__c = term.Id,
                TB_Offered_Product_Code__c = productCode
        );
        insert dictionary;
    }

    @IsTest
    private static void getAllOfferedProductsForTestUser() {
        Test.startTest();
        String result = TB_NewAdmissionController.getAllOfferedProducts(true);
        Test.stopTest();
        List<TB_NewAdmissionController.OfferedProductWrapper> productWrappers
            = (List<TB_NewAdmissionController.OfferedProductWrapper>) JSON.deserialize(result, List<TB_NewAdmissionController.OfferedProductWrapper>.class);
        System.assertEquals(2, productWrappers.size());
    }

    @IsTest
    private static void getHiddenOfferedProductWrapperAvailable() {
        TB_Offered_Product__c product = [SELECT Id FROM TB_Offered_Product__c WHERE TB_Available_on_Portal__c = true LIMIT 1];
        Test.startTest();
        String result = TB_NewAdmissionController.getHiddenOfferedProductWrapper(product.Id);
        Test.stopTest();
        TB_NewAdmissionController.OfferedProductWrapper productWrapper
            = (TB_NewAdmissionController.OfferedProductWrapper) JSON.deserialize(result, TB_NewAdmissionController.OfferedProductWrapper.class);
        System.assertEquals(true, productWrapper != null);
    }

    @IsTest
    private static void getHiddenOfferedProductWrapperNotAvailable() {
        TB_Offered_Product__c product = [SELECT Id FROM TB_Offered_Product__c WHERE TB_Available_on_Portal__c = false LIMIT 1];
        Test.startTest();
        String result = TB_NewAdmissionController.getHiddenOfferedProductWrapper(product.Id);
        Test.stopTest();
        System.assertEquals('EMPTY.OFFERED_PRODUCT_NOT_AVAILABLE_ON_PORTAL',result);
    }

    @IsTest
    private static void getHiddenOfferedProductWrapperProductDoesNotExist() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        String result = TB_NewAdmissionController.getHiddenOfferedProductWrapper(contact.Id);
        Test.stopTest();
        System.assertEquals('EMPTY.OFFERED_PRODUCT_DOES_NOT_EXIST',result);
    }

    @IsTest
    private static void getNumberOfApplicationsByProductCodePositive() {
        hed__Term__c term = [SELECT Id FROM hed__Term__c LIMIT 1];
        Contact contact = [SELECT Id, TB_Test__c FROM Contact WHERE LastName = 'WithoutApplication' LIMIT 1];
        TB_Offered_Product__c product = [SELECT Id, TB_Product_Group__c  FROM TB_Offered_Product__c WHERE Name = 'Wrapper_Product' LIMIT 1];
        product.TB_Product_Code__c = 'W-' + productCode;
        product.TB_Academic_Year__c = term.Id;

        TB_Admissions_Dictionary__c dictionary = [SELECT Id, TB_Product_Group__c, TB_Limit__c FROM TB_Admissions_Dictionary__c WHERE TB_Product_Group__c =: product.TB_Product_Group__c];
        dictionary.TB_Limit__c = 2;
        update dictionary;

        hed__Application__c application = new hed__Application__c();
        application.TB_Applying_To_Offered_Product__c = product.Id;
        application.hed__Applicant__c = contact.Id;
        application.hed__Term__c = term.Id;
        application.TB_Test__c = false;
        insert application;

        TB_Offered_Product__c newProduct = TB_TestDataFactory.createOfferedProduct(false);
        newProduct.Name = 'Other_Product';
        newProduct.TB_Product_Group__c = 'Other';
        newProduct.TB_Product_Code__c = 'Z-' + productCode;
        newProduct.TB_Status__c = 'Launched';
        newProduct.TB_Active__c = true;
        newProduct.TB_Admissions_Campaign__c = [SELECT Id FROM TB_Admissions_Campaign__c LIMIT 1].Id;
        newProduct.TB_Product_Start_Date__c = System.now();
        newProduct.TB_Product_End_Date__c = System.now().addDays(10);
        newProduct.TB_Test__c = true;
        newProduct.TB_Admissions_Process__c = [SELECT Id FROM TB_Admissions_Process__c LIMIT 1].Id;
        newProduct.TB_Academic_Year__c = term.Id;
        newProduct.RecordTypeId = TB_re_Constants.TB_OFFERED_PRODUCT_RT_STUDY;
        insert newProduct;

        Test.startTest();
        String exceptionCode =  TB_NewAdmissionController.createNewApplication(JSON.serialize(newProduct), JSON.serialize(contact), true, true);
        Test.stopTest();
        System.assertEquals('NEW_ADMISSION.PRODUCT_CODE_LIMITS_VALIDATION.TOAST.EXCEPTION', exceptionCode);
    }
    
    @IsTest
    private static void getHiddenOfferedProductWrapperNullId() {
        Test.startTest();
        String result = TB_NewAdmissionController.getHiddenOfferedProductWrapper(null);
        Test.stopTest();
        System.assertEquals('EMPTY.OFFERED_PRODUCT_DOES_NOT_EXIST',result);
    }

    @IsTest
    private static void getAllOfferedProducts() {
        Test.startTest();
        String result = TB_NewAdmissionController.getAllOfferedProducts(false);
        Test.stopTest();
        List<TB_NewAdmissionController.OfferedProductWrapper> productWrappers
            = (List<TB_NewAdmissionController.OfferedProductWrapper>) JSON.deserialize(result, List<TB_NewAdmissionController.OfferedProductWrapper>.class);
        System.assertEquals(1, productWrappers.size());
    }

    @IsTest
    private static void createNewApplicationForTestContact() {
        Contact contact = [SELECT Id, TB_Test__c FROM Contact WHERE LastName = 'Kowalski' LIMIT 1];
        contact.TB_Test__c = true;
        TB_Offered_Product__c product = [SELECT Id, TB_Product_Group__c  FROM TB_Offered_Product__c WHERE Name = 'Wrapper_Product' LIMIT 1];
        Test.startTest();
        String exceptionCode =  TB_NewAdmissionController.createNewApplication(JSON.serialize(product), JSON.serialize(contact), true, true);
        Test.stopTest();
        System.assertEquals(18, exceptionCode.length());
    }

    @IsTest
    private static void createNewApplicationValidationException() {
        Contact contact = [SELECT Id, TB_Test__c FROM Contact WHERE LastName='Kowalski' LIMIT 1];
        contact.TB_Test__c = false;
        TB_Offered_Product__c product = [SELECT Id, TB_Product_Group__c  FROM TB_Offered_Product__c WHERE Name = 'Wrapper_Product' LIMIT 1];
        Test.startTest();
        String exceptionCode = TB_NewAdmissionController.createNewApplication(JSON.serialize(product), JSON.serialize(contact),true, false);
        Test.stopTest();
        System.assertEquals('NEW_ADMISSION.ACTIVE_APPLICATION_VALIDATION.EXCEPTION',exceptionCode);
    }

    @IsTest
    private static void createNewApplicationLimitsValidationException() {
        Contact contact = [SELECT Id, TB_Test__c FROM Contact WHERE LastName='Kowalski' LIMIT 1];
        contact.TB_Test__c = false;
        TB_Offered_Product__c product = [SELECT Id, TB_Product_Group__c  FROM TB_Offered_Product__c WHERE Name = 'Limit_Product' LIMIT 1];
        product.TB_Product_Group__c = 'Higher_Education';
        Test.startTest();
        TB_NewAdmissionController.createNewApplication(JSON.serialize(product), JSON.serialize(contact), false, false);
        Test.stopTest();
    }

    @IsTest
    private static void createNewApplicationGroupLimitsException() {
        Contact contact = [SELECT Id, TB_Test__c FROM Contact WHERE LastName='Kowalski' LIMIT 1];
        contact.TB_Test__c = false;
        TB_Offered_Product__c product = [SELECT Id, TB_Product_Group__c  FROM TB_Offered_Product__c WHERE Name = 'Limit_Product' LIMIT 1];
        product.TB_Product_Group__c = 'Other';

        Test.startTest();
        TB_NewAdmissionController.createNewApplication(JSON.serialize(product), JSON.serialize(contact), false, false);
        Test.stopTest();
    }
    
    @IsTest
    private static void createNewApplicationPositiveInsert() {
        Contact contact = [SELECT Id, TB_Test__c FROM Contact WHERE LastName = 'WithoutApplication' LIMIT 1];
        contact.TB_Test__c = false;
        TB_Offered_Product__c product = [SELECT Id, TB_Product_Group__c, TB_Product_Code__c FROM TB_Offered_Product__c WHERE Name = 'Wrapper_Product' LIMIT 1];
        Test.startTest();
        String exceptionCode = TB_NewAdmissionController.createNewApplication(JSON.serialize(product), JSON.serialize(contact), true, false);
        Test.stopTest();
        System.assertEquals(18, exceptionCode.length());
    }

    @IsTest
    private static void createConsentsForNewApplication() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        List<TB_ConsentsController.AdmissionConsentsWrapper> wrappers = new List<TB_ConsentsController.AdmissionConsentsWrapper>();
        TB_Admissions_Dictionary__c consent = [SELECT Id, TB_Description_PL__c, TB_Description_EN__c, TB_Consent_Type__c FROM TB_Admissions_Dictionary__c WHERE Name = 'Consent' LIMIT 1];
        TB_ConsentsController.AdmissionConsentsWrapper singleWrapper = new TB_ConsentsController.AdmissionConsentsWrapper(consent);
        wrappers.add(singleWrapper);

        Test.startTest();
        Boolean result = TB_NewAdmissionController.createConsentsForNewApplication(application.Id,JSON.serialize(wrappers),'url');
        Test.stopTest();
        System.assertEquals(true,result);
    }

    @IsTest
    private static void canApplicantApplyPositive() {
        Contact contact = [SELECT Id FROM Contact WHERE TB_x_Personal_Information__c = false LIMIT 1];
        Test.startTest();
        Boolean result = TB_NewAdmissionController.canApplicantApply(contact.Id);
        Test.stopTest();
        System.assertEquals(false,result);
    }

    @IsTest
    private static void canApplicantApplyNegative() {
        Test.startTest();
        Boolean result = TB_NewAdmissionController.canApplicantApply([SELECT Id FROM hed__Application__c LIMIT 1].Id);
        Test.stopTest();
        System.assertEquals(false,result);
    }

    @IsTest
    private static void createConsentsForNewApplicationWithoutConsent() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];

        Test.startTest();
        Boolean result = TB_NewAdmissionController.createConsentsForNewApplication(application.Id, null,'url');
        Test.stopTest();
        System.assertEquals(true,result);
    }

    @IsTest
    private static void createConsentsForNewApplicationNegative() {
        hed__Application__c application = [SELECT Id FROM hed__Application__c LIMIT 1];
        Test.startTest();
        TB_NewAdmissionController.createConsentsForNewApplication(application.Id, ' ','url');
        Test.stopTest();
        System.assertEquals(1,[SELECT Id FROM TB_Log__c].size());
    }


    private static TB_Admissions_Dictionary__c createAdmissionDictionaryLimit(Boolean withInsert, Integer limitCount, String productGroup) {
        TB_Admissions_Dictionary__c limitDictionary = new TB_Admissions_Dictionary__c(
                Name = 'Limit' + productGroup,
                TB_Active__c = true,
                TB_Limit__c = limitCount,
                TB_Product_Group__c = productGroup,
                RecordTypeId = TB_re_Constants.ADMISSIONS_DICTIONARY_RT_ADMISSIONS_LIMIT_ID
        );
        if(withInsert) {
            insert limitDictionary;
        }
        return limitDictionary;
    }

    private static TB_Offered_Product__c createActiveStudyProduct(String name, Id campaignId, Boolean isTest, Id processId, Boolean withInsert) {
        TB_Offered_Product__c product = TB_TestDataFactory.createOfferedProduct(false);
        product.Name = name;
        product.TB_Product_Group__c = 'Higher_Education';
        product.TB_Status__c = 'Launched';
        product.TB_Active__c = true;
        product.TB_Admissions_Campaign__c = campaignId;
        product.TB_Product_Start_Date__c = System.now();
        product.TB_Product_End_Date__c = System.now().addDays(10);
        product.TB_Test__c = isTest;
        product.TB_Admissions_Process__c = processId;
        product.RecordTypeId = TB_re_Constants.TB_OFFERED_PRODUCT_RT_STUDY;

        if(withInsert) {
            insert product;
        }
        return product;
    }
}