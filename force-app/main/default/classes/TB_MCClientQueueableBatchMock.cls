/**
 * Created by Adam Czeczuk on 14/10/2021.
 */

public with sharing class TB_MCClientQueueableBatchMock implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode(200);
        return res;
    }
}