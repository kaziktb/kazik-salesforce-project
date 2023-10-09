/**
 * Created by jowitakozlak on 09/12/2021.
 */

public with sharing class TB_GoogleIntegratorRetrieverMock implements HttpCalloutMock{
    @TestVisible final static String authorizationPositive
        = '{"access_token": "token", "expires_in": 10000}';
    @TestVisible final static String insertEventPositive
        = '{"hangoutLink": "meet.google.com/x", "id": "123"}';
    @TestVisible final static String deleteEventPositive
        = '';

    HttpResponse res = new HttpResponse();
    Map<String, String> serviceNameToEndpoint;

    public TB_GoogleIntegratorRetrieverMock(String testType){
        res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        res.setStatusCode(200);
        if (testType == 'authorizationPositive') {
            serviceNameToEndpoint = TB_WebserviceUtils.createServiceNameToEndpoint(TB_Constants.TB_PROVIDER_GOOGLE_AUTHORIZATION);
            res.setBody(authorizationPositive);
        } else if (testType == 'authorizationNegative') {
            serviceNameToEndpoint = TB_WebserviceUtils.createServiceNameToEndpoint(TB_Constants.TB_PROVIDER_GOOGLE_AUTHORIZATION);
            res.setStatusCode(401);
        } else if (testType == 'insertEventPositive') {
            serviceNameToEndpoint = TB_WebserviceUtils.createServiceNameToEndpoint(TB_Constants.TB_PROVIDER_GOOGLE_SERVICE);
            res.setBody(insertEventPositive);
        } else if (testType == 'deleteEventPositive') {
            serviceNameToEndpoint = TB_WebserviceUtils.createServiceNameToEndpoint(TB_Constants.TB_PROVIDER_GOOGLE_SERVICE);
            res.setStatusCode(204);
        }
    }

    public HttpResponse respond(HttpRequest req) {
        if(serviceNameToEndpoint.get('Authorize')!=null){
            if(req.getEndpoint().contains(serviceNameToEndpoint.get('Authorize'))) {
                res.setBody(authorizationPositive);
            }
        } else if(serviceNameToEndpoint.get('Insert Event')!=null){
            Map<String, String> authNameToEndpoint = TB_WebserviceUtils.createServiceNameToEndpoint(TB_Constants.TB_PROVIDER_GOOGLE_AUTHORIZATION);
            if(req.getEndpoint().contains(authNameToEndpoint.get('Authorize'))) {
                res.setBody(authorizationPositive);
            } else if (req.getMethod()=='POST') {
                res.setBody(insertEventPositive);
            } else if(req.getMethod()=='DELETE') {
                res.setBody(deleteEventPositive);
            }
        }
        return res;
    }
}