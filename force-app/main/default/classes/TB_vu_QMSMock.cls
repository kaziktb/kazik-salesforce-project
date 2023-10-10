@IsTest
global class TB_vu_QMSMock implements HttpCalloutMock
{
    global static Boolean positiveResponse = true;
    global static QMSMethod method = QMSMethod.TOKEN;
    
    @TestVisible
    private enum QMSMethod {TOKEN, CANCEL}
    
    global HttpResponse respond(HttpRequest request)
    {
        Object responseObject;
        switch on method
        {
            when TOKEN
            {
                responseObject = getTokenResponse();
            }
            when CANCEL
            {
                responseObject = getCancelResponse();
            }
        }
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(JSON.serialize(responseObject));
        response.setStatusCode(positiveResponse?200:400);
        if(method == QMSMethod.TOKEN)
        {
            method = QMSMethod.CANCEL;
        }
        return response;
    }
    
    private static TB_vu_QMSCancelInvocable.TokenResponse getTokenResponse()
    {
        TB_vu_QMSCancelInvocable.TokenResponse responseObject;
        if(positiveResponse)
        {
            responseObject = new TB_vu_QMSCancelInvocable.TokenResponse
                    (
                            generateGUID()
                    );
        }
        return responseObject;
    }
    
    private static Object getCancelResponse()
    {
        Object responseObject;
        if(positiveResponse)
        {
            responseObject = true;
        }
        else
        {
            responseObject = false;
        }
        return responseObject;
    }
    
    private static String generateGUID()
    {
        Blob b = Crypto.generateAesKey(128);
        String h = EncodingUtil.convertToHex(b);
        String guid = h.substring(0,8)+ '-' + h.substring(8,12) + '-' + h.substring(12,16) + '-' + h.substring(16,20) + '-' + h.substring(20);
        return guid;
    }
}