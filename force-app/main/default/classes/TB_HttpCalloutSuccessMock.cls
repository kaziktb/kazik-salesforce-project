public  class TB_HttpCalloutSuccessMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        TB_Http_Callout_Mock__mdt callout_mock = [
            SELECT Response__c, Response_Code__c, Status__c
            FROM TB_Http_Callout_Mock__mdt
            WHERE DeveloperName = 'TB_HttpCalloutSuccessMock'
        ];

        response.setStatus(callout_mock.Status__c);
        response.setStatusCode(Integer.valueOf(callout_mock.Response_Code__c));
        response.setBody(callout_mock.Response__c);
        return response;
    }
}
