public class TB_HttpCallout500Fail extends TB_HttpCalloutFactory.HttpCalloutAbstractBuilder{
    public TB_HttpCallout500Fail() {
        super('TB_HttpCallout500Fail');
    }
    
    public HttpResponse getHttpResponse() {
        return this.HttpApiResponse;
    }
}
