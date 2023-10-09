public with sharing class TB_KReMSIOIntegrator {

    public static Map<Integer,String> getResultCodes() {
        List<TB_KReM_Response_Code__mdt> resultCodeObjects = TB_KReM_Response_Code__mdt.getAll().values();
        Map<Integer,String> resultCodeToDetail = new Map<Integer,String>();
        for (TB_KReM_Response_Code__mdt resultCodeObject : resultCodeObjects) {
            resultCodeToDetail.put(Integer.valueOf(resultCodeObject.TB_Code__c), resultCodeObject.TB_Message__c);
        }
        return resultCodeToDetail;
    }

    public static HttpResponse getResults(List<String> pesels) {
        TB_Webservice_Credential__mdt credential = TB_Webservice_Credential__mdt.getInstance(TB_re_Constants.TB_PROVIDER_KREM);
        Map<String, String> wsNameToEndpoint = TB_WebserviceUtils.createServiceNameToEndpoint(TB_re_Constants.TB_PROVIDER_KREM);
        String reqString = credential.TB_WSC_Endpoint__c + wsNameToEndpoint.get('Results');

        HttpRequest req = new HttpRequest();
        req.setEndpoint(TB_WebserviceUtils.prepareUrl(
            new Map<String, Object>{'token' => credential.TB_WSC_Token__c},
            reqString)
        );
        req.setHeader('accept', 'text/plain');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(new KReMWrapper(credential.TB_WSC_Token__c, pesels)));
        req.setMethod('POST');

        HttpResponse res = new Http().send(req);
        return res;
    }

    public static List<SubjectWrapper> getSheets() {
        TB_Webservice_Credential__mdt credential = TB_Webservice_Credential__mdt.getInstance(TB_re_Constants.TB_PROVIDER_KREM);
        Map<String, String> wsNameToEndpoint = TB_WebserviceUtils.createServiceNameToEndpoint(TB_re_Constants.TB_PROVIDER_KREM);
        String reqString = credential.TB_WSC_Endpoint__c + wsNameToEndpoint.get('Sheets');

        HttpRequest req = new HttpRequest();
        req.setEndpoint(TB_WebserviceUtils.prepareUrl(
            new Map<String, Object>{'token' => credential.TB_WSC_Token__c},
            reqString)
        );
        req.setHeader('accept', 'text/plain');
        req.setMethod('GET');

        HttpResponse res = new Http().send(req);
        List<SubjectWrapper> subjectWrappers = new List<SubjectWrapper>();
        if (res.getStatusCode() == TB_Constants.HTTP_STATUS_OK) {
            subjectWrappers = (List<SubjectWrapper>) JSON.deserialize(res.getBody(), List<SubjectWrapper>.class);
        }
        return subjectWrappers;
    }

    @AuraEnabled
    public static String getRetrievedResults(List<String> pesels, Boolean forLWC) {
        HttpResponse res = getResults(pesels);
        Map<String,Object> body = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        if (res.getStatusCode() == TB_Constants.HTTP_STATUS_OK) {
            return JSON.serialize(parseResponseBody(body));
        } else {
            String statusCodeAndDetail = TB_re_Constants.ERROR_OCCURRED + ': ' + res.getBody();
            TB_AuraUtils.createLog(statusCodeAndDetail);
            if (forLWC) {
                return TB_re_Constants.ERROR_OCCURRED + ': ' + String.valueOf(body.get('title'));
            } else {
                return statusCodeAndDetail;
            }
        }
    }

    public static Body parseResponseBody(Map<String,Object> body) {
        Map<Integer,String> resultCodeToDetail = getResultCodes();
        List<Response> retrievedResponses = new List<Response>();
        for (Object rawResponse : (List<Object>) body.get('response')) {
            Map<String, Object> response = (Map<String, Object>) rawResponse;
            Object rawStudentResult = response.get('studentResult');
            List<Result> retrievedResults = new List<Result>();
            Map<String, Object> studentResult = (Map<String, Object>) rawStudentResult;
            for (Object rawResult : (List<Object>) studentResult.get('results')) {
                Map<String, Object> result = (Map<String, Object>) rawResult;
                retrievedResults.add(new Result(String.valueOf(result.get('code')), Integer.valueOf(result.get('points'))));
            }
            retrievedResponses.add(
                new Response(
                    Integer.valueOf(response.get('errorCode')),
                    new StudentResult(String.valueOf(studentResult.get('pesel')), retrievedResults),
                    resultCodeToDetail.get(Integer.valueOf(response.get('errorCode')))
                )
            );
        }
        return new Body(
            Integer.valueOf(body.get('responseCode')),
            retrievedResponses,
            resultCodeToDetail.get(Integer.valueOf(body.get('responseCode')))
        );
    }

    @AuraEnabled
    public static ApplicationWrapper getApplication(Id recordId) {
        hed__Application__c app = [
            SELECT TB_HS_Exam_Type__c, TB_No_HS_Exam__c, hed__Applicant__r.DT_PESEL__c
            FROM hed__Application__c
            WHERE Id = :recordId
        ];
        return new ApplicationWrapper(
            app.TB_HS_Exam_Type__c == TB_Constants.TB_APP_EXAM_TYPE_POLISH_SINCE_2005
                && !app.TB_No_HS_Exam__c && String.isNotBlank(app.hed__Applicant__r.DT_PESEL__c),
            app.hed__Applicant__r.DT_PESEL__c
        );
    }

    public class ApplicationWrapper {
        @AuraEnabled public Boolean isKReMIntegrationAvailable;
        @AuraEnabled public String pesel;

        public ApplicationWrapper(Boolean isKReMIntegrationAvailable, String pesel) {
            this.isKReMIntegrationAvailable = isKReMIntegrationAvailable;
            this.pesel = pesel;
        }
    }

    public class KReMWrapper {
        public String token;
        public List<String> pesels;

        public KReMWrapper(String token, List<String> pesels) {
            this.token = token;
            this.pesels = pesels;
        }
    }

    public class Body {
        public Integer responseCode;
        public List<Response> responses;
        public String responseCodeDetail;

        public Body(Integer responseCode, List<Response> responses, String responseCodeDetail) {
            this.responseCode = responseCode;
            this.responses = responses;
            this.responseCodeDetail = responseCodeDetail;
        }
    }

    public class Response {
        public Integer errorCode;
        public StudentResult studentResult;
        public String errorCodeDetail;

        public Response(Integer errorCode, StudentResult studentResult, String errorCodeDetail) {
            this.errorCode = errorCode;
            this.studentResult = studentResult;
            this.errorCodeDetail = errorCodeDetail;
        }
    }

    public class StudentResult {
        public String pesel;
        public List<Result> results;

        public StudentResult(String pesel, List<Result> results) {
            this.pesel = pesel;
            this.results = results;
        }
    }

    public class Result {
        @AuraEnabled public String code;
        @AuraEnabled public Integer points;

        public Result(String code, Integer points) {
            this.code = code;
            this.points = points;
        }
    }

    public class SubjectWrapper {
        public String code;
        public String subject;
        public String level;
        public String type;
        public String language;

        public SubjectWrapper(String code, String subject, String level, String type, String language) {
            this.code = code;
            this.subject = subject;
            this.level = level;
            this.type = type;
            this.language = language;
        }
    }

}