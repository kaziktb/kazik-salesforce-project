public class TB_HttpCalloutSuccess extends TB_HttpCalloutFactory.HttpCalloutAbstractBuilder{
    public TB_HttpCalloutSuccess() {
        super('TB_HttpCalloutSuccess');
    }
    
    public HttpResponse getHttpResponse() {
        return this.HttpApiResponse;
    }
}
