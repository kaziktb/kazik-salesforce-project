@IsTest
public with sharing class TB_TuitionFeePaymentsControllerTest {

    private static final Integer packetSize = 500;

    @TestSetup
    static void testSetup() {
        Contact contact = TB_TestDataFactory.createContact(false);
        contact.TB_Is_Candidate__c = true;
        contact.TB_Tuition_Bank_Account_PLN__c = '321';
        contact.TB_Tuition_Bank_Account_EUR__c = '123';
        insert contact;
        hed__Application__c application = TB_TestDataFactory.createApplicationWithNestedLookup(false, contact.Id);
        application.hed__Initial_Creation_Date__c = System.today();
        application.TB_Tuition_Fee__c = 1000;
        application.TB_Tuition_Fee_Currency__c = 'EUR';
        insert application;
        TB_Payment__c payment = TB_TestDataFactory.createPayment(false, application.Id);
        payment.RecordTypeId = TB_SObjectUtils.getRecordTypeIdByDevName('TB_Payment__c', 'TB_Tuition_Fee');
        payment.TB_Contact__c = contact.Id;
        payment.TB_Payment_Date__c = System.today();
        payment.TB_Paid_Amount__c = 1000;
        payment.TB_Currency__c = 'EUR';
        payment.TB_Bank_Account_Number__c = '123';
        insert payment;
    }

    static void prepareCache() {
        TB_TuitionFeePaymentsController.getPayments(
            'Name',
            '',
            '',
            '',
            true,
            packetSize,
            ''
        );
        TB_TuitionFeePaymentsController.getContacts(
            'Name',
            'TB_Is_Candidate__c = TRUE',
            1,
            packetSize,
            ''
        );
        TB_TuitionFeePaymentsController.getApplications(
            'Name',
            '',
            1,
            packetSize,
            ''
        );
    }

    @IsTest
    static void getPaymentsPositive() {
        Test.startTest();
        TB_TuitionFeePaymentsController.getPayments(
            'Name',
            '',
            '',
            '',
            true,
            packetSize,
            ''
        );
        Test.stopTest();

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void getContactsPositive() {
        TB_TuitionFeePaymentsController.getPayments(
            'Name',
            '',
            '',
            '',
            true,
            packetSize,
            ''
        );
        Test.startTest();
        TB_TuitionFeePaymentsController.getContacts(
            'Name',
            'TB_Is_Candidate__c = TRUE',
            1,
            packetSize,
            ''
        );
        Test.stopTest();

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void getApplicationsPositive() {
        TB_TuitionFeePaymentsController.getPayments(
            'Name',
            '',
            '',
            '',
            true,
            packetSize,
            ''
        );
        TB_TuitionFeePaymentsController.getContacts(
            'Name',
            'TB_Is_Candidate__c = TRUE',
            1,
            packetSize,
            ''
        );
        Test.startTest();
        TB_TuitionFeePaymentsController.getApplications(
            'Name',
            '',
            1,
            packetSize,
            ''
        );
        Test.stopTest();

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void getRefreshDatePositive() {
        prepareCache();
        Test.startTest();
        TB_TuitionFeePaymentsController.getRefreshDate('');
        Test.stopTest();

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void retrieveRelatedDataPositive() {
        prepareCache();
        Test.startTest();
        List<TB_TuitionFeePaymentsController.TuitionFeePaymentWrapper> result = TB_TuitionFeePaymentsController.retrieveRelatedData(
            'Name',
            'Name',
            'Name',
            '0.0025',
            1,
            1,
            1,
            100,
            1,
            '',
            '',
            ''
        );
        Test.stopTest();

        System.assertEquals(1,result.size());
        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void getUserLanguagePositive() {
        Test.startTest();
        String result = TB_TuitionFeePaymentsController.getUserLanguage();
        Test.stopTest();

        System.assertNotEquals(null,result);
        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void retrieveColumnDataPositive() {
        Test.startTest();
        String resultJSON = TB_TuitionFeePaymentsController.retrieveColumnData(
            true, false,
            'Name',
            'Name',
            'Name'
        );
        Test.stopTest();

        List<TB_TuitionFeePaymentsController.ResponseWrapper> result =
            (List<TB_TuitionFeePaymentsController.ResponseWrapper>) JSON.deserialize(
                resultJSON, List<TB_TuitionFeePaymentsController.ResponseWrapper>.class);

        System.assertEquals(5,result.size());
    }

}