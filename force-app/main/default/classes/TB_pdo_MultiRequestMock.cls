@isTest
public class TB_pdo_MultiRequestMock implements HttpCalloutMock {
  Map<String, HttpCalloutMock> requests;

  public TB_pdo_MultiRequestMock(Map<String, HttpCalloutMock> requests) {
    this.requests = requests;
  }

  public HttpResponse respond(HttpRequest req) {
    HttpCalloutMock mock;
    try {
      mock = requests.get(req.getEndpoint());
    } catch (Exception e) {
      System.debug(e);
    }
    return mock.respond(req);
  }

  public void addRequestMock(String url, HttpCalloutMock mock) {
    requests.put(url, mock);
  }
}