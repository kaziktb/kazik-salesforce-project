/**
 * Created by adriangawryszewski on 2/21/22.
 */

public with sharing class TB_VDOExportMock implements HttpCalloutMock {
    HttpResponse res = new HttpResponse();

    public TB_VDOExportMock(String testType) {
        if (testType == 'success') {
            String body = '[{"status":"OK", "statusSaveDB":"OK",' +
                    '"candidateId":"0035r00000LfW40AAF",' +
                    '"applicationId":"a0Q5r000002MACHEA4",' +
                    '"errors":[]}]';
            res.setStatusCode(200);
            res.setBody(body);
        } else if (testType == 'fail') {
            String body = '[{"status":"FAILED","statusSaveDB":"FAILED",' +
                    '"candidateId":"0035r00000LfW40AAF",' +
                    '"applicationId":"a0Q5r000002MACHEA4",' +
                    '"errors":[' +
                    '"Identyfikator specializacji musi być uzupełniony"]}]';
            res.setStatusCode(400);
            res.setBody(body);
        }
    }

    public HttpResponse respond(HttpRequest req) {
        return res;
    }
}