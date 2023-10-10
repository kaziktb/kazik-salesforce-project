@IsTest
global class TB_vu_mSzafirMock implements HttpCalloutMock
{
    global static Boolean positiveResponse = true;
    global static SzafirMethod method = SzafirMethod.INIT;
    
    @TestVisible
    private enum SzafirMethod {INIT, STATUS, DOWNLOAD, DESTROY}
    
    global HttpResponse respond(HttpRequest request)
    {
        Object responseObject;
        switch on method
        {
            when INIT
            {
                responseObject = getInitResponse();
            }
            when STATUS
            {
                responseObject = getStatusResponse();
            }
            when DOWNLOAD
            {
                responseObject = getDownloadResponse();
            }
            when DESTROY
            {
                responseObject = getDestroyResponse();
            }
        }
        HttpResponse response = new HttpResponse();
        if(method == SzafirMethod.DOWNLOAD && positiveResponse)
        {
            response.setHeader('Content-Disposition', 'attachment; filename=’<filename>’');
            response.setBodyAsBlob((Blob)responseObject);
        }
        else
        {
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(responseObject));
        }
        response.setStatusCode(positiveResponse?200:400);
        return response;
    }
    
    private static TB_vu_mSzafirService.SzafirInitResponse getInitResponse()
    {
        TB_vu_mSzafirService.SzafirInitResponse responseObject;
        if(positiveResponse)
        {
            responseObject = new TB_vu_mSzafirService.SzafirInitResponse
                    (
                            generateGUID(),
                            new List<String> {generateGUID()},
                            null,
                            null
                    );
        }
        else
        {
            responseObject = new TB_vu_mSzafirService.SzafirInitResponse
                    (
                            null,
                            null,
                            205,
                            'Empty file'
                    );
        }
        return responseObject;
    }
    
    private static TB_vu_mSzafirService.SzafirStatusResponse getStatusResponse()
    {
        TB_vu_mSzafirService.SzafirStatusResponse responseObject;
        if(positiveResponse)
        {
            responseObject = new TB_vu_mSzafirService.SzafirStatusResponse
                    (
                            true,
                            0,
                            'OK',
                            new List<String>{'https://szafir.swps.edu.pl/mini-portal/api/files/signed/'+generateGUID()+'/'+generateGUID()}
                    );
        }
        else
        {
            responseObject = new TB_vu_mSzafirService.SzafirStatusResponse
                    (
                            false,
                            522,
                            'Test Error',
                            new List<String>{}
                    );
        }
        return responseObject;
    }
    
    private static Object getDownloadResponse()
    {
        Object responseObject;
        if(positiveResponse)
        {
            responseObject = Blob.valueOf('Test Content');
        }
        else
        {
            responseObject = new TB_vu_mSzafirService.SzafirDownloadResponse
                    (
                            220,
                            'No file'
                    );
        }
        return responseObject;
    }
    
    private static TB_vu_mSzafirService.SzafirDestroyResponse getDestroyResponse()
    {
        TB_vu_mSzafirService.SzafirDestroyResponse responseObject;
        if(positiveResponse)
        {
            responseObject = new TB_vu_mSzafirService.SzafirDestroyResponse
                    (
                            0,
                            'OK'
                    );
        }
        else
        {
            responseObject = new TB_vu_mSzafirService.SzafirDestroyResponse
                    (
                            220,
                            'Unknown ID'
                    );
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