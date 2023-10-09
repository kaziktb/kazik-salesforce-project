@IsTest
public with sharing class TB_PaymentComponentControllerTest {
    @IsTest
    static void getApplicationTest() {
        hed__Application__c application = TB_TestDataFactory.createApplicationWithRelatedObjects(true);

        Test.startTest();
        hed__Application__c retrievedApplication = TB_PaymentComponentController.getApplication(application.Id);
        Test.stopTest();
        System.assertEquals(application.Id, retrievedApplication.Id);
    }

    @IsTest
    static void getNewestPaymentTest() {
        hed__Application__c application = TB_TestDataFactory.createApplicationWithRelatedObjects(true);
        TB_Payment__c payment = TB_TestDataFactory.createPayment(true, application.Id);
        Test.startTest();
        TB_Payment__c newestPayment = TB_PaymentComponentController.getNewestOpenPayment(application.Id);
        Test.stopTest();
        System.assertEquals(payment.Id, newestPayment.Id);
    }

    @IsTest
    static void createPaymentTest() {
        hed__Application__c application = TB_TestDataFactory.createApplicationWithRelatedObjects(false);
        application.TB_Admissions_Fee_Currency__c = 'PLN';
        insert application;

        String orderId = '123';
        String redirectUri = 'http://localhost.com';
        Test.setMock(HttpCalloutMock.class, new TB_PayUIntegratorMock('createOrder','success', null, orderId, redirectUri));
        TB_Technical_Key__mdt technicalKey = [SELECT Id, TB_Value__c FROM TB_Technical_Key__mdt WHERE DeveloperName = 'TB_PayU_Pos_Id'];
        String posId = technicalKey.TB_Value__c;

        Test.startTest();
        TB_PaymentComponentController.createPayment(application);
        Test.stopTest();

        TB_Payment__c payment = [
            SELECT Id, TB_Transaction_Order_Number__c, TB_Uri__c, TB_Pos_Id__c, TB_Application__c, TB_Contact__c,
                TB_Amount__c, TB_Currency__c, TB_Payment_Date__c, RecordTypeId, TB_Payment_Title__c, TB_Payment_Method__c
            FROM TB_Payment__c
        ];

        System.assertEquals(orderId, payment.TB_Transaction_Order_Number__c);
        System.assertEquals(redirectUri, payment.TB_Uri__c);
        System.assertEquals(posId, payment.TB_Pos_Id__c);
        System.assertEquals(application.Id, payment.TB_Application__c);
        System.assertEquals(application.hed__Applicant__c, payment.TB_Contact__c);
        System.assertEquals(application.TB_Admissions_Fee__c, payment.TB_Amount__c);
        System.assertEquals(application.TB_Admissions_Fee_Currency__c, payment.TB_Currency__c);
        System.assertEquals(Date.today(), payment.TB_Payment_Date__c);
        System.assertEquals(TB_Constants.PAYMENT_ADMISSIONS_FEE_RT_ID, payment.RecordTypeId);
        System.assertEquals('SWPS University - Admissions fee: ' + application.Name, payment.TB_Payment_Title__c);
        System.assertEquals('PayU', payment.TB_Payment_Method__c);
    }

    @IsTest
    static void getDependantPicklistByApiNamePositive() {
        Test.startTest();
        String resultJSON = TB_StringUtils.getDependantPicklistByApiName('hed__Application__c','TB_No_Admissions_Fee_Reason__c','Higher_Education');
        Test.stopTest();

        TB_StringUtils.PicklistWrapper result = (TB_StringUtils.PicklistWrapper) JSON.deserialize(
            resultJSON, TB_StringUtils.PicklistWrapper.class);

        System.assertNotEquals(0, result.choicesValues.size());
    }

    @IsTest
    static void getNewestCompletedPaymentPositive() {
        hed__Application__c application = TB_TestDataFactory.createApplicationWithRelatedObjects(true);
        TB_Payment__c payment = TB_TestDataFactory.createPayment(false, application.Id);
        payment.TB_Provider_Status__c = 'COMPLETED';
        insert payment;

        Test.startTest();
        TB_Payment__c newestPayment = TB_PaymentComponentController.getNewestCompletedPayment(application.Id);
        Test.stopTest();

        System.assertEquals(payment.Id, newestPayment.Id);
    }
}