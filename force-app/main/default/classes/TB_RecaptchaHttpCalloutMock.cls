@isTest
global class TB_RecaptchaHttpCalloutMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"success": true, "score": 0.75, "action": "userRegistration", "challenge_ts": "2021-12-22T21:34:46+0000", "hostname": "localhost"}');
        response.setStatusCode(200);
        return response;
    }
}