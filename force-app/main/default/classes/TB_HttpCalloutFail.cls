public class TB_HttpCalloutFail extends TB_HttpCalloutFactory.HttpCalloutAbstractBuilder{
    public TB_HttpCalloutFail() {
        super('TB_HttpCalloutFail');
    }
    
    public HttpResponse getHttpResponse() {
        return this.HttpApiResponse;
    }
}
