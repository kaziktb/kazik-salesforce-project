public class TB_CreateOrUpdatePersonCallout extends TB_HttpCalloutFactory.HttpCalloutAbstractBuilder {

    private TB_CreateOrUpdatePersonRequest RequestBody;
    private String Token;
    public TB_CreateOrUpdatePersonCallout(TB_CreateOrUpdatePersonRequest request_body, String token) {
        super('CreateOrUpdatePerson');
        this.RequestBody = request_body;
        this.Token = token;
    }

    public HttpResponse getHttpResponse() {
        return this.HttpApiResponse;
    }

    @testVisible
    protected override String buildJsonBody() {
        return JSON.serialize(RequestBody,true).replace('"Number0":', '"Number":');
    }

    @testVisible
    protected override List<String> getEndpointParams() {
        return new List<String>{Token};
    }
}