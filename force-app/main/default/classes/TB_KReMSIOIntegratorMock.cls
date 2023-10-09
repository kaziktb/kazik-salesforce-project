public with sharing class TB_KReMSIOIntegratorMock implements HttpCalloutMock {

    @TestVisible final static String resultsPositive
        = '{\n' +
            '  "response": [\n' +
            '    {\n' +
            '      "studentResult": {\n' +
            '        "results": [\n' +
            '          {\n' +
            '            "code": "IN_p_R_p_211",\n' +
            '            "points": 72\n' +
            '          },\n' +
            '          {\n' +
            '            "code": "JA_p_P_p_211",\n' +
            '            "points": 100\n' +
            '          },\n' +
            '          {\n' +
            '            "code": "JA_p_R_p_211",\n' +
            '            "points": 100\n' +
            '          },\n' +
            '          {\n' +
            '            "code": "PO_p_P_p_211",\n' +
            '            "points": 63\n' +
            '          },\n' +
            '          {\n' +
            '            "code": "MA_p_P_p_211",\n' +
            '            "points": 100\n' +
            '          },\n' +
            '          {\n' +
            '            "code": "MA_p_R_p_211",\n' +
            '            "points": 62\n' +
            '          }\n' +
            '        ],\n' +
            '        "pesel": "66666666666"\n' +
            '      },\n' +
            '      "errorCode": 0\n' +
            '    }\n' +
            '  ],\n' +
            '  "responseCode": 0\n' +
            '}';
    @TestVisible final static String sheetsPositive
        = '[\n' +
                    '  {\n' +
                    '    "code": "IN_p_D_a",\n' +
                    '    "subject": "informatyka",\n' +
                    '    "level": "dwujęzyczny",\n' +
                    '    "type": "pisemny",\n' +
                    '    "language": "angielski"\n' +
                    '  },\n' +
                    '  {\n' +
                    '    "code": "JA_u_D_a",\n' +
                    '    "subject": "język angielski ",\n' +
                    '    "level": "dwujęzyczny",\n' +
                    '    "type": "ustny",\n' +
                    '    "language": "angielski"\n' +
                    '  },\n' +
                    '  {\n' +
                    '    "code": "PO_p_D_a",\n' +
                    '    "subject": "język polski ",\n' +
                    '    "level": "zestaw zadań",\n' +
                    '    "type": "pisemny",\n' +
                    '    "language": "angielski"\n' +
                    '  },\n' +
                    '  {\n' +
                    '    "code": "MA_p_R_z",\n' +
                    '    "subject": "matematyka",\n' +
                    '    "level": "rozszerzony",\n' +
                    '    "type": "pisemny",\n' +
                    '    "language": "łemkowski"\n' +
                    '  }\n' +
                    ']';

    @TestVisible final static String resultsNegative = '{\n' +
            '  "details": "error"\n,' +
            '  "status": 500\n' +
            '}';

    HttpResponse res = new HttpResponse();
    Map<String, String> wsNameToEndpoint;
    public Boolean positiveResult;

    public TB_KReMSIOIntegratorMock(String testType){
        this.positiveResult = testType.contains('Positive');
        res.setHeader('accept', 'text/plain');
        wsNameToEndpoint = TB_WebserviceUtils.createServiceNameToEndpoint(TB_re_Constants.TB_PROVIDER_KREM);
        if (testType == 'resultsPositive') {
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody(resultsPositive);
        } else if (testType == 'sheetsPositive') {
            res.setStatusCode(200);
            res.setBody(sheetsPositive);
        }else if(testType == 'resultsNegative') {
            res.setStatusCode(500);
            res.setBody(resultsNegative);
        }
    }

    public HttpResponse respond(HttpRequest req) {
        if (wsNameToEndpoint.get('Results') != null) {
            if (req.getEndpoint().contains(wsNameToEndpoint.get('Results'))) {
                res.setBody(this.positiveResult ? resultsPositive : resultsNegative);
            }
        } else if (wsNameToEndpoint.get('Sheets') != null) {
            if (req.getEndpoint().contains(wsNameToEndpoint.get('Sheets'))) {
                res.setBody(sheetsPositive);
            }
        }
        return res;
    }
    
}