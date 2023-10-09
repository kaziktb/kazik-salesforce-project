@isTest
public class TB_pdo_SingleRequestMock implements HttpCalloutMock {
  protected Integer code;
  protected String status;
  protected String bodyAsString;
  protected Blob bodyAsBlob;
  protected Map<String, String> respHeaders;

  public TB_pdo_SingleRequestMock(
    Integer code,
    String status,
    String body,
    Map<String, String> headers
  ) {
    this.code = code;
    this.status = status;
    this.bodyAsString = body;
    this.respHeaders = headers;
  }
  public TB_pdo_SingleRequestMock(
    Integer code,
    String status,
    Blob body,
    Map<String, String> headers
  ) {
    this.code = code;
    this.status = status;
    this.bodyAsBlob = body;
    this.respHeaders = headers;
  }

  public HttpResponse respond(HttpRequest req) {
    HttpResponse resp = new HttpResponse();
    resp.setStatus(status);
    resp.setStatusCode(code);
    if (bodyAsBlob != null) {
      resp.setBodyAsBlob(bodyAsBlob);
    } else {
      resp.setBody(bodyAsString);
    }
    if (respHeaders != null) {
      for (String key : respHeaders.keySet()) {
        resp.setHeader(key, respHeaders.get(key));
      }
    }
    return resp;
  }
}