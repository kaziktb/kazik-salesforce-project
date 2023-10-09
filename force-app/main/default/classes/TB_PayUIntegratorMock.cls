public with sharing class TB_PayUIntegratorMock implements HttpCalloutMock  {
        HttpResponse res = new HttpResponse();


        public TB_PayUIntegratorMock(String methodType, String testType, String token ) {
            this(methodType, testType, token, null, null);
        }


        public TB_PayUIntegratorMock(String methodType, String testType, String token, String orderId, String redirectUri ){

            if (testType == 'success') {
                res.setStatusCode(200);
                if (methodType == 'createOrder') {
                    res.setBody('{"orderId":"' + orderId + '", "redirectUri" : "' + redirectUri + '"}');
                } else if (methodType == 'authorize') {
                    res.setBody('{"access_token":"' + token + '"}');
                }
            } else if (testType == 'fail') {
                res.setStatusCode(400);
            }
        }

        public HttpResponse respond(HttpRequest req) {
            return res;
        }
}