/**
 * Created by Aneta on 29/05/2023.
 */

public with sharing class TB_DocGenControllerMock implements HttpCalloutMock{

    private Integer statusCode;
    private String status;
    public TB_DocGenControllerMock(Integer statusCode, String message) {
        this.statusCode = statusCode;
        this.status = message;
    }

    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('content-disposition', 'attachment; filename="TestFileName.pdf"; filename*=UTF-8\'\'TestFileName.pdf');
        if(this.statusCode == 200) {
            String file = 'Test file';
            res.setBody(JSON.serialize(Blob.valueOf(file)));
        }
        res.setStatusCode(this.statusCode);
        res.setStatus(this.status);
        return res;
    }
}