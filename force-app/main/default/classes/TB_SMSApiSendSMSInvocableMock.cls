public with sharing class TB_SMSApiSendSMSInvocableMock implements HttpCalloutMock {

    HttpResponse res = new HttpResponse();

    public TB_SMSApiSendSMSInvocableMock(String testType){
        if (testType == 'success') {
            res.setStatusCode(200);
        } else if (testType == 'fail') {
            res.setStatusCode(400);
        }
    }

    public HttpResponse respond(HttpRequest req) {
        return res;
    }

}