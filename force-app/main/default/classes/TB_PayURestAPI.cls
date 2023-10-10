@RestResource(UrlMapping='/PayU/*')
global without sharing class TB_PayURestAPI {
    @HttpPost
    global static String retrieveResultPost() {
        String bodyString = RestContext.request.requestBody.toString();
        String openPayuSignature = RestContext.request.headers.get('OpenPayu-Signature');
        String signature = openPayuSignature.substringBetween('signature=', ';');
        String algorithm = openPayuSignature.substringBetween('algorithm=', ';');
        String orderId = String.valueOf(TB_WebserviceUtils.fetchFieldValueFromJSON('order.orderId', bodyString));

        TB_Payment__c payment = new TB_Payment__c (
            TB_Header_JSON__c = JSON.serialize(RestContext.request.headers),
            TB_Body_JSON__c = bodyString,
            TB_Signature__c = signature,
            TB_Alghoritm__c = algorithm,
            TB_Transaction_Order_Number__c = orderId
        );

        Boolean isSignatureValid = validateSignature(signature, algorithm, bodyString);

        if (isSignatureValid) {
            payment.TB_Is_Signature_Valid__c = 'Yes';
            payment.TB_Provider_Status__c = String.valueOf(TB_WebserviceUtils.fetchFieldValueFromJSON('order.status', bodyString));
            if (payment.TB_Provider_Status__c == 'COMPLETED') {
                payment.TB_Paid_Amount__c = Decimal.valueOf(
                    String.valueOf(TB_WebserviceUtils.fetchFieldValueFromJSON('order.totalAmount', bodyString))
                );
                payment.TB_Paid_Amount__c = payment.TB_Paid_Amount__c/100;
                String localReceiptDateTime = String.valueOf(TB_WebserviceUtils.fetchFieldValueFromJSON('localReceiptDateTime', bodyString));
                Datetime dt = (DateTime)JSON.deserialize('"' + localReceiptDateTime + '"', DateTime.class);
                payment.TB_Transaction_Finished_On__c = dt;
            }
        } else {
            payment.TB_Is_Signature_Valid__c = 'No';
        }

        try {
            insert TB_LogUtils.registerLog(JSON.serialize(payment), TB_PayURestAPI.class);
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
        }

        try {
            upsert payment TB_Transaction_Order_Number__c;
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
        }

        
        return null;
    }

    private static Boolean validateSignature(String payUSignature, String algorithm, String bodyString) {
        String md5UniqueKey = TB_Technical_Key__mdt.getInstance('TB_PayU_MD5_Key').TB_Value__c;
        String expectedSignature =
            EncodingUtil.convertToHex (
                Crypto.generateDigest(algorithm, Blob.valueOf(bodyString + md5UniqueKey)));
        return payUSignature == expectedSignature;
    }
}