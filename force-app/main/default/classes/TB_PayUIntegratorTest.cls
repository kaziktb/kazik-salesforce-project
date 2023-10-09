@IsTest
public with sharing class TB_PayUIntegratorTest {
    static final String accessToken = 'fdgsfhrtetfdsghegdh53245u6ytgf';

    @IsTest
    static void authorizePositiveTest() {
        Test.setMock(HttpCalloutMock.class, new TB_PayUIntegratorMock('authorize','success', accessToken));

        TB_PayUIntegrator integrator = new TB_PayUIntegrator();

        Test.startTest();
        integrator.authorize();
        Test.stopTest();
        System.assertEquals(accessToken, integrator.bearerToken);
    }

    @IsTest
    static void authorizeNegativeTest() {
        Test.setMock(HttpCalloutMock.class, new TB_PayUIntegratorMock('authorize','fail', accessToken));

        TB_PayUIntegrator integrator;
        Boolean isExceptionThrown = false;

        Test.startTest();

        try {
            integrator = new TB_PayUIntegrator();
            integrator.authorize();
        } catch (Exception e ) {
            isExceptionThrown = true;
        }
        Test.stopTest();

        System.assert(isExceptionThrown);
        System.assertEquals(null, integrator.bearerToken);
    }

    @IsTest
    static void createOrderTest() {
        String orderId = '123';
        String redirectUri = 'http://localhost.com';
        Test.setMock(HttpCalloutMock.class, new TB_PayUIntegratorMock('createOrder','success', null, orderId, redirectUri));

        TB_PayUIntegrator integrator = new TB_PayUIntegrator();
        hed__Application__c application = TB_TestDataFactory.createApplicationWithRelatedObjects(true);

        Test.startTest();
        HttpResponse resp = integrator.createOrder('123', application);
        Test.stopTest();

        System.assert([SELECT Id FROM TB_Log__c].isEmpty());

        String orderIdFromResponse = String.valueOf(TB_WebserviceUtils.fetchFieldValueFromJSON('orderId', resp.getBody()));
        String redirectUriFromResponse = String.valueOf(TB_WebserviceUtils.fetchFieldValueFromJSON('redirectUri', resp.getBody()));
        System.assertEquals(orderId, orderIdFromResponse);
        System.assertEquals(redirectUriFromResponse, redirectUri);
    }
}