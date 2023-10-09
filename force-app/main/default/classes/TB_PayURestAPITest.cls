@IsTest
public with sharing class TB_PayURestAPITest {
    private static String body = '{' +
        '"order":{' +
        '   "orderId":"5DJQP8J86D211208GUEST000P01",' +
        '   "orderCreateDate":"2021-12-08T15:48:36.389+01:00",' +
        '   "notifyUrl":"https://devtbyd-swpsuniversity.cs160.force.com/AdmissionsPortal/services/apexrest/PayU?applicationId=a0Q5r000002Iu1YEAS",' +
        '   "customerIp":"127.0.0.1",' +
        '   "merchantPosId":"422038",' +
        '   "description":"SWPS University - Admissions fee: 85 PLN",' +
        '   "currencyCode":"PLN",' +
        '   "totalAmount":"8500",' +
        '   "buyer":{' +
        '      "customerId":"guest",' +
        '      "email":"artur.lydkowski+20@thinkbeyond.cloud",' +
        '      "firstName":"artur",' +
        '      "lastName":"artur"' +
        '   },' +
        '   "payMethod":{' +
        '      "amount":"8500",' +
        '      "type":"PBL"' +
        '   },' +
        '   "status":"COMPLETED",' +
        '   "products":[' +
        '      {' +
        '         "name":"SWPS University - Admissions fee: 85 PLN",' +
        '         "unitPrice":"8500",' +
        '         "quantity":"1"' +
        '      }' +
        '   ]' +
        '},' +
        '"localReceiptDateTime":"2021-12-08T15:48:42.651+01:00",' +
        '"properties":[' +
        '   {' +
        '      "name":"PAYMENT_ID",' +
        '      "value":"5003061799"' +
        '   }' +
        ']' +
    '}';

    @IsTest
    static void retrieveResultPostPositiveTest() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        TB_Technical_Key__mdt technicalKey = [SELECT Id, TB_Value__c FROM TB_Technical_Key__mdt WHERE DeveloperName = 'TB_PayU_MD5_Key'];
        String md5UniqueKey = technicalKey.TB_Value__c;

        String signature = EncodingUtil.convertToHex (Crypto.generateDigest('MD5', Blob.valueOf(body + md5UniqueKey)));
        String payUSignature = 'sender=checkout;signature=' + signature + ';algorithm=MD5;content=DOCUMENT';
        req.addHeader('OpenPayu-Signature', payUSignature);

        req.requestBody = Blob.valueOf(body);

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        TB_PayURestAPI.retrieveResultPost();
        Test.stopTest();

        TB_Payment__c payment = getPayment();

        System.assertEquals('{"OpenPayu-Signature":"' + payUSignature + '"}', payment.TB_Header_JSON__c);
        System.assertEquals(body, payment.TB_Body_JSON__c);
        System.assertEquals(signature, payment.TB_Signature__c);
        System.assertEquals('COMPLETED', payment.TB_Provider_Status__c);
        System.assertEquals('MD5', payment.TB_Alghoritm__c);
        System.assertEquals('5DJQP8J86D211208GUEST000P01', payment.TB_Transaction_Order_Number__c);
        System.assertEquals('Yes', payment.TB_Is_Signature_Valid__c);
        System.assertEquals(85, payment.TB_Paid_Amount__c);
        System.assertEquals('2021-12-08 14:48:42', String.valueOfGmt(payment.TB_Transaction_Finished_On__c));
    }

    @IsTest
    static void retrieveResultPostWrongSignatureTest() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        TB_Technical_Key__mdt technicalKey = [SELECT Id, TB_Value__c FROM TB_Technical_Key__mdt WHERE DeveloperName = 'TB_PayU_MD5_Key'];
        String md5UniqueKey = technicalKey.TB_Value__c;

        String signature = 'abbcds';
        String payUSignature = 'sender=checkout;signature=' + signature + ';algorithm=MD5;content=DOCUMENT';
        req.addHeader('OpenPayu-Signature', payUSignature);

        req.requestBody = Blob.valueOf(body);

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        TB_PayURestAPI.retrieveResultPost();
        Test.stopTest();

        TB_Payment__c payment = getPayment();

        System.assertEquals('{"OpenPayu-Signature":"' + payUSignature + '"}', payment.TB_Header_JSON__c);
        System.assertEquals(body, payment.TB_Body_JSON__c);
        System.assertEquals(signature, payment.TB_Signature__c);
        System.assertEquals('MD5', payment.TB_Alghoritm__c);
        System.assertEquals('5DJQP8J86D211208GUEST000P01', payment.TB_Transaction_Order_Number__c);
        System.assertEquals('No', payment.TB_Is_Signature_Valid__c);
        System.assertEquals(null, payment.TB_Paid_Amount__c);
        System.assertEquals(null, String.valueOfGmt(payment.TB_Transaction_Finished_On__c));
    }

    private static TB_Payment__c getPayment() {
        return [SELECT Id, TB_Header_JSON__c, TB_Body_JSON__c, TB_Signature__c, TB_Alghoritm__c, TB_Transaction_Order_Number__c, TB_Paid_Amount__c, TB_Transaction_Finished_On__c, TB_Is_Signature_Valid__c, TB_Provider_Status__c FROM TB_Payment__c];
    }
}