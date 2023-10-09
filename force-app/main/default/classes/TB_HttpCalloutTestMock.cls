@isTest 
public class TB_HttpCalloutTestMock implements HttpCalloutMock {
    public static Boolean SetIsSuccess = true;
    public static final String ErrorMessage = 'Internal issues.';
    private Boolean IsSuccess;
    private Integer StatusCode;
    private String ResponseBody;

    public TB_HttpCalloutTestMock() {
        this(true);
    }

    public TB_HttpCalloutTestMock(Boolean is_success) {
        IsSuccess = is_success;
        StatusCode = TB_HttpCalloutTestMock.getCodeBySuccessFlag(is_success);
    }

    public TB_HttpCalloutTestMock(Boolean is_success, Integer status_code) {
        IsSuccess = is_success;
        StatusCode = status_code;
    }

    public TB_HttpCalloutTestMock(String body) {
        IsSuccess = true;
        StatusCode = TB_HttpCalloutTestMock.getCodeBySuccessFlag(IsSuccess);
        ResponseBody = body;
    }

    public HTTPResponse respond(HTTPRequest request) {
        if (String.isNotEmpty(ResponseBody)) {
            return getSuccessResponse(ResponseBody);
        }
        return IsSuccess ? getSuccessResponse(StatusCode) : getInternalErrorResponse(StatusCode);
    }

    public static Integer getCodeBySuccessFlag(Boolean is_success) {
        return (is_success) ? 200 : 999;
    }

    public static HttpResponse getInternalErrorResponse(String exception_thrown) {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(999);
        http_response.setStatus('Salesforce Internal Error');
        http_response.setBody('{"message" : "' + exception_thrown + '"}');
        return http_response;
    }

    public static HttpResponse getInternalErrorResponse(Integer status_code) {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(status_code);
        http_response.setStatus('Salesforce Internal Error');
        http_response.setBody('{"message" : "' + ErrorMessage + '"}');
        return http_response;
    }

    public static HttpResponse getSuccessResponse() {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(200);
        http_response.setStatus('OK');
        return http_response;
    }

    public static HttpResponse getSuccessResponse(Integer status_code) {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(status_code);
        http_response.setStatus('OK');
        return http_response;
    }

    public static HttpResponse getSuccessResponse(String body) {
        HttpResponse http_response = new HttpResponse();
        http_response.setStatusCode(200);
        http_response.setStatus('OK');
        http_response.setBody(body);
        return http_response;
    }
}