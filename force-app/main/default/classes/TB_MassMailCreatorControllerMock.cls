/**
 * Created by Aneta on 31/01/2023.
 */

public with sharing class TB_MassMailCreatorControllerMock implements  HttpCalloutMock{

    public String objectApiName;

    public TB_MassMailCreatorControllerMock(String objectType) {
        this.objectApiName = objectType;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"query":"SELECT Id FROM ' + objectApiName + '"}');
        res.setStatusCode(200);
        return res;
    }
}