public inherited sharing class TB_vu_mSzafirService
{
    private static final String INIT_URL = '/mini-portal/api/files/init';
    private static final String LOGIN_URL = '/mini-portal/login';
    private static final String STATUS_URL = '/mini-portal/api/files/status/';
    private static final String DOWNLOAD_URL = '/mini-portal/api/files/signed/';
    private static final String DESTROY_URL = '/mini-portal/api/files/destroy/';
    private static final String GET_METHOD = 'GET';
    private static final String POST_METHOD = 'POST';
    
    @TestVisible
    private enum Mode {SHORT_TERM, LONG_TERM, CERT_GEN}
    private enum AuthMethod {MID, CKW, KIR}
    @TestVisible
    private enum SzafirMethod {STATUS, DOWNLOAD, DESTROY}
    
    public static SzafirInitResponse init(SzafirInitParams requestParams)
    {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(getRequestUrl()+INIT_URL);
        req.setMethod(POST_METHOD);
        req.setHeader('Content-Type',TB_vu_MultipartFormBuilder.CONTENT_TYPE);
        req.setTimeout(120000);
    
        String form64 = '';
        form64 += TB_vu_MultipartFormBuilder.writeBoundary();
        form64 += TB_vu_MultipartFormBuilder.writeBodyParameter('hauth', requestParams.hauth);
        form64 += TB_vu_MultipartFormBuilder.writeBoundary();
        
        if(String.isNotBlank(requestParams.p_urlSigningCompleted))
        {
            form64 += TB_vu_MultipartFormBuilder.writeBodyParameter('p_urlSigningCompleted', requestParams.p_urlSigningCompleted);
            form64 += TB_vu_MultipartFormBuilder.writeBoundary();
        }
        form64 += TB_vu_MultipartFormBuilder.writeBodyParameter('p_urlSigningCompletedNotification', '');
        form64 += TB_vu_MultipartFormBuilder.writeBoundary();
        if(requestParams.mode != Mode.LONG_TERM && requestParams.p_idpList != null)
        {
            form64 += TB_vu_MultipartFormBuilder.writeBodyParameter('p_idpList', JSON.serialize(requestParams.p_idpList,true));
            form64 += TB_vu_MultipartFormBuilder.writeBoundary();
        }
        if(requestParams.mode == Mode.CERT_GEN)
        {
            form64 += TB_vu_MultipartFormBuilder.writeBodyParameter('params', JSON.serialize(requestParams.params,true));
            form64 += TB_vu_MultipartFormBuilder.writeBoundary();
        }
        TB_vu_MultipartFormBuilder.WriteFileResult result = TB_vu_MultipartFormBuilder.writeFile('files', requestParams.version.Title, 'application/pdf', requestParams.version.VersionData);
        form64 += result.content;
        form64 += TB_vu_MultipartFormBuilder.writeBoundary(result.endingType);
    
        Blob formBlob = EncodingUtil.base64Decode(form64);
        String contentLength = String.valueOf(formBlob.size());
        req.setBodyAsBlob(formBlob);
        req.setHeader('Content-Length', contentLength);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
    
        return (SzafirInitResponse)JSON.deserialize(res.getBody(),SzafirInitResponse.class);
    }
    
    @AuraEnabled
    public static SzafirLoginParams getLoginParamsForCase(Id recordId, String redirectUrl)
    {
        Case processedCase;
        try
        {
            processedCase = [SELECT Id, RecordType.DeveloperName FROM Case WHERE Id = :recordId];
        }
        catch(Exception e)
        {
            throw new AuraHandledException('Couldn\'t find case');
        }
        String contentVersionCategory;
        if(processedCase.RecordType.DeveloperName == TB_vu_Constants.CERTIFICATE_CASE_RECORD_TYPE_DEVELOPER_NAME)
        {
            contentVersionCategory = 'Student_Certificate';
        }
        else if(processedCase.RecordType.DeveloperName == TB_vu_Constants.NOTIFICATION_CASE_RECORD_TYPE_DEVELOPER_NAME)
        {
            contentVersionCategory = 'Student_Notification';
        }
        else
        {
            throw new AuraHandledException('Unsupported RecordType');
        }
        ContentDocumentLink cdl = [SELECT Id, ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId AND ContentDocument.LatestPublishedVersion.TB_Category__c = :contentVersionCategory];
        return getLoginParams(cdl.ContentDocument.LatestPublishedVersionId, redirectUrl);
    }
    
    @AuraEnabled
    public static void updateCaseStatus(Id recordId)
    {
        update new Case(Id=recordId,Status='In_Progress',TB_Signature_Status__c='In Progress',TB_Signature_Status_Date_Time__c=Datetime.now());
    }
    
    @AuraEnabled
    public static SzafirLoginParams getLoginParams(Id contentVersionId, String redirectUrl)
    {
        TB_vu_mSzafir__c customSetting = TB_vu_mSzafir__c.getInstance();
        Blob privateKey = Blob.valueOf(customSetting.TB_HMAC_Key__c);
        if(redirectUrl == null)
        {
            redirectUrl = Url.getOrgDomainUrl().toExternalForm() + '?c__signedDocument=true';
        }
        SzafirInitParams params = new SzafirInitParams(contentVersionId,privateKey,Mode.LONG_TERM,redirectUrl);
        SzafirInitResponse response = init(params);
        if(String.isNotBlank(response.signingId) && response.fileIds != null && !response.fileIds.isEmpty())
        {
            ContentVersion version = new ContentVersion(Id=contentVersionId,TB_mSzafir_Signing_ID__c=response.signingId,TB_mSzafir_File_ID__c=response.fileIds[0],OwnerId=UserInfo.getUserId());
            update version;
            List<String> fileIds = new List<String>();
            fileIds.add(version.TB_mSzafir_File_ID__c);
            return new SzafirLoginParams(privateKey,version.TB_mSzafir_Signing_ID__c,fileIds, response.statusCode, response.status);
        }
        return new SzafirLoginParams(response.statusCode, response.status);
    }
    
    public static SzafirStatusResponse status(String signingId)
    {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(getRequestUrl()+STATUS_URL+signingId);
        req.setMethod(GET_METHOD);
        req.setTimeout(120000);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        return (SzafirStatusResponse)JSON.deserialize(res.getBody(),SzafirStatusResponse.class);
    }
    
    public static Object download(String signingId, String fileId)
    {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(getRequestUrl()+DOWNLOAD_URL+signingId+'/'+fileId);
        req.setMethod(GET_METHOD);
        req.setTimeout(120000);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
    
        try
        {
            return JSON.deserialize(res.getBody(),SzafirDownloadResponse.class);
        }
        catch(Exception e)
        {
            return res.getBodyAsBlob();
        }
    }
    
    public static SzafirDestroyResponse destroy(String signingId)
    {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(getRequestUrl()+DESTROY_URL+signingId);
        req.setMethod(GET_METHOD);
        req.setTimeout(120000);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
    
        return (SzafirDestroyResponse)JSON.deserialize(res.getBody(),SzafirDestroyResponse.class);
    }
    
    private static String getRequestUrl()
    {
        TB_vu_mSzafir__c customSetting = TB_vu_mSzafir__c.getInstance();
        return String.isBlank(customSetting.TB_Endpoint_URL__c) ? null : customSetting.TB_Endpoint_URL__c.removeEnd('/');
    }
    
    private static ContentVersion getContentVersionToSign(Id contentVersionId)
    {
        try
        {
            return [SELECT Id, Title, VersionData FROM ContentVersion WHERE Id = :contentVersionId];
        }
        catch(Exception e)
        {
            TB_vu_Utils.registerLog(e,TB_vu_mSzafirService.class,String.isBlank(contentVersionId)?'Missing ID':contentVersionId);
        }
        return null;
    }
    
    @AuraEnabled
    public static void enqueueFileDownload(Id caseId)
    {
        ContentDocumentLink cdl;
        try
        {
            cdl = [SELECT Id, ContentDocument.LatestPublishedVersion.TB_mSzafir_Signing_ID__c FROM ContentDocumentLink WHERE LinkedEntityId = :caseId AND (ContentDocument.LatestPublishedVersion.TB_Category__c = 'Student_Certificate' OR ContentDocument.LatestPublishedVersion.TB_Category__c = 'Student_Notification')];
        }
        catch(Exception e)
        {
            throw new AuraHandledException('Couldn\'t find certificate or notification');
        }
        System.enqueueJob(new SzafirTransactionFinalizer(cdl.ContentDocument.LatestPublishedVersion.TB_mSzafir_Signing_ID__c,caseId));
    }
    
    @TestVisible
    private class SzafirInitParams
    {
        final String hauth;
        final String p_urlSigningCompleted;
        final List<String> p_idpList;
        final SzafirCertParams params;
        final Mode mode;
        final ContentVersion version;
    
        @TestVisible
        SzafirInitParams(Id contentVersionId, Blob key, Mode p_mode, String p_urlSigningCompleted, List<String> p_idpList, SzafirCertParams params)
        {
            this.version = getContentVersionToSign(contentVersionId);
            this.hauth = EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(new HmacData(p_mode, p_urlSigningCompleted, p_idpList, key),true)));
            this.p_urlSigningCompleted = p_urlSigningCompleted;
            this.p_idpList = p_idpList;
            this.mode = p_mode;
            this.params = params;
        }
    
        @TestVisible
        SzafirInitParams(Id contentVersionId, Blob key, Mode p_mode, String p_urlSigningCompleted)
        {
            this(contentVersionId,key,p_mode,p_urlSigningCompleted,null,null);
        }
    }
    
    private class HmacData
    {
        final Long timestamp;
        final String mode;
        final String urlSigningCompleted;
        final List<String> idpList;
        final String hmac;
        
        HmacData(Mode p_mode, String p_urlSigningCompleted, List<String> p_idpList, Blob key)
        {
            this.timestamp = System.currentTimeMillis();
            this.mode = String.valueOf(p_mode);
            this.urlSigningCompleted = p_urlSigningCompleted;
            this.idpList = p_idpList;
            String hmacString = this.timestamp + this.mode;
            if(String.isNotBlank(this.urlSigningCompleted))
            {
                hmacString += this.urlSigningCompleted;
            }
            if(this.idpList != null)
            {
                hmacString += String.join(this.idpList,'');
            }
            this.hmac = EncodingUtil.convertToHex(Crypto.generateMac('hmacSHA256',Blob.valueOf(hmacString),key));
        }
    }
    
    public class SzafirLoginParams
    {
        @AuraEnabled public final String requestUrl;
        @AuraEnabled public final String hauth;
        @AuraEnabled public final Integer statusCode;
        @AuraEnabled public final String status;
    
        public SzafirLoginParams(Blob key, String sigId, List<String> fids, Integer statusCode, String status)
        {
            this.statusCode = statusCode;
            this.status = status;
            this.requestUrl = getRequestUrl() + LOGIN_URL;
            this.hauth = EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(new LoginHmacData(key, sigId, fids),true)));
        }
    
        public SzafirLoginParams(Integer statusCode, String status)
        {
            this.statusCode = statusCode;
            this.status = status;
            this.requestUrl = null;
            this.hauth = null;
        }
    }
    
    private class LoginHmacData
    {
        final Long timestamp;
        final String signingId;
        final List<String> fileIds;
        final String hmac;
    
        LoginHmacData(Blob key, String sigId, List<String> fids)
        {
            this.timestamp = System.currentTimeMillis();
            this.signingId = sigId;
            this.fileIds = fids;
            String hmacString = this.timestamp + this.signingId;
            if(this.fileIds != null)
            {
                hmacString += String.join(this.fileIds,'');
            }
            this.hmac = EncodingUtil.convertToHex(Crypto.generateMac('hmacSHA256',Blob.valueOf(hmacString),key));
        }
    }
    
    private class SzafirCertParams
    {
        final String policy;
        final Integer sigCount;
        final Boolean partnerExclusive;
        final String authMethod;
        
        SzafirCertParams(String policy, Integer sigCount, Boolean partnerExclusive, AuthMethod authMethod)
        {
            this.policy = policy;
            this.sigCount = sigCount;
            this.partnerExclusive = partnerExclusive;
            this.authMethod = String.valueOf(authMethod);
        }
    }
    
    public class SzafirInitResponse
    {
        public final String signingId;
        public final List<String> fileIds;
        public final Integer statusCode;
        public final String status;
        
        @TestVisible
        private SzafirInitResponse(String signingId, List<String> fileIds, Integer statusCode, String status)
        {
            this.signingId = signingId;
            this.fileIds = fileIds;
            this.statusCode = statusCode;
            this.status = status;
        }
    }
    
    public class SzafirStatusResponse
    {
        public final Boolean completed;
        public final Integer statusCode;
        public final String status;
        public final List<String> fileUrls;
        
        @TestVisible
        private SzafirStatusResponse(Boolean completed, Integer statusCode, String status, List<String> fileUrls)
        {
            this.completed = completed;
            this.statusCode = statusCode;
            this.status = status;
            this.fileUrls = fileUrls;
        }
    }
    
    public class SzafirDownloadResponse
    {
        public final Integer statusCode;
        public final String status;
        
        @TestVisible
        private SzafirDownloadResponse(Integer statusCode, String status)
        {
            this.statusCode = statusCode;
            this.status = status;
        }
    }
    
    public class SzafirDestroyResponse
    {
        public final Integer statusCode;
        public final String status;
    
        @TestVisible
        private SzafirDestroyResponse(Integer statusCode, String status)
        {
            this.statusCode = statusCode;
            this.status = status;
        }
    }
    
    public without sharing class SzafirTransactionFinalizer implements Queueable, Database.AllowsCallouts
    {
        private final String signingId;
        private List<ContentVersion> filesToOverwrite;
        @TestVisible
        private SzafirMethod currentMethod;
        private Set<Id> contentDocumentIdsForCaseUpdate;
        private Id relatedCaseId;
    
        public SzafirTransactionFinalizer(String signingId, Id relatedCaseId)
        {
            this.signingId = signingId;
            this.currentMethod = SzafirMethod.STATUS;
            this.contentDocumentIdsForCaseUpdate = new Set<Id>();
            this.relatedCaseId = relatedCaseId;
        }
    
        public void execute(QueueableContext context)
        {
            if(String.isBlank(signingId))
            {
                return;
            }
            switch on currentMethod
            {
                when STATUS
                {
                    checkSigningStatus();
                }
                when DOWNLOAD
                {
                    downloadSignedFiles();
                }
                when DESTROY
                {
                    destroyFinishedSigning();
                }
            }
        }
    
        private void checkSigningStatus()
        {
            SzafirStatusResponse response = status(signingId);
            if(!response.completed && response.statusCode!=0 && response.statusCode != null)
            {
                TB_vu_Utils.registerLog('Signing not completed',SzafirTransactionFinalizer.class.getName(),JSON.serializePretty(response),signingId);
                caseUpdate('Error');
                return;
            }
            this.currentMethod = SzafirMethod.DOWNLOAD;
            if(!Test.isRunningTest())
            {
                System.enqueueJob(this);
            }
        }
    
        private void downloadSignedFiles()
        {
            filesToOverwrite = [SELECT Id, Title, PathOnClient, ContentDocumentId, TB_mSzafir_File_ID__c, TB_mSzafir_Signing_ID__c FROM ContentVersion WHERE TB_mSzafir_Signing_ID__c = :this.signingId];
            if(filesToOverwrite.isEmpty())
            {
                TB_vu_Utils.registerLog('No File to replace found',SzafirTransactionFinalizer.class.getName(),'',signingId);
                caseUpdate('Error');
                return;
            }
            ContentVersion processedFile = filesToOverwrite.remove(0);
            Object response = download(signingId, processedFile.TB_mSzafir_File_ID__c);
            if(response instanceof SzafirDownloadResponse)
            {
                TB_vu_Utils.registerLog('Error Downloading File',SzafirTransactionFinalizer.class.getName(),JSON.serializePretty(response),signingId);
                caseUpdate('Error');
                return;
            }
            ContentVersion signedFile = processedFile.clone(false,true);
            signedFile.VersionData = (Blob)response;
            insert signedFile;
            contentDocumentIdsForCaseUpdate.add(processedFile.ContentDocumentId);
            if(filesToOverwrite.isEmpty())
            {
                this.currentMethod = SzafirMethod.DESTROY;
                if(!Test.isRunningTest())
                {
                    System.enqueueJob(this);
                }
            }
        }
    
        private void destroyFinishedSigning()
        {
            SzafirDestroyResponse response = destroy(signingId);
            if(response.statusCode!=0 && response.statusCode != null)
            {
                TB_vu_Utils.registerLog('Error Destroying the signing operation',SzafirTransactionFinalizer.class.getName(),JSON.serializePretty(response),signingId);
                caseUpdate('Error');
                return;
            }
            caseUpdate('Signed');
        }
        
        private void caseUpdate(String status)
        {
            if(relatedCaseId == null)
            {
                return;
            }
            Case caseToCheck = [SELECT Id, TB_Signature_Status__c, TB_Signature_Status_Date_Time__c FROM Case WHERE Id = :relatedCaseId];
            if(caseToCheck == null)
            {
                return;
            }
            if(caseToCheck.TB_Signature_Status__c != 'Signed')
            {
                update new Case(Id = relatedCaseId, TB_Signature_Status__c = status, TB_Signature_Status_Date_Time__c = Datetime.now());
            }
        }
    }
}