/**
 * Created by krzysztofkalata on 09.04.2021.
 */

public with sharing class TB_SmsApiIntegrator {
    transient HttpRequest req;
    TB_Webservice_Credential__mdt smsApiCredential;
    Map<String, String> wsNameToEndpoint;
    String providerName = TB_Constants.TB_PROVIDER_SMS_API;

    public TB_SmsApiIntegrator() {
        smsApiCredential = [
                SELECT TB_WSC_Token__c, TB_WSC_Endpoint__c
                FROM TB_Webservice_Credential__mdt
                WHERE DeveloperName = :providerName
        ];
        wsNameToEndpoint = TB_WebserviceUtils.createServiceNameToEndpoint(providerName);
    }

    public HttpResponse sendSMS (String phoneNumbers, String messageText, String sender) {
        req = new HttpRequest();
        String reqString = smsApiCredential.TB_WSC_Endpoint__c + wsNameToEndpoint.get('Send SMS');
        req.setEndpoint(reqString);

        Map<String, Object> bodyMap = new Map<String, Object>{
                'access_token' => smsApiCredential.TB_WSC_Token__c,
                'to' => phoneNumbers,
                'message' => messageText,
                'encoding' => 'utf-8'
        };
        if (sender != null) bodyMap.put('from', sender);

        HttpResponse resp = TB_WebserviceUtils.sendPostRequest(req, bodyMap);
        TB_WebserviceUtils.throwExceptionWhenIntegrationFails(resp, new TB_SMSApiIntegratorException(resp.getBody()));
        return resp;
    }


    public class TB_SMSApiIntegratorException extends TB_CustomWithStackTraceException {
    }



}