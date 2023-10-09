@IsTest
private class TB_vu_mSzafirServiceTest
{
    private static final String ENDPOINT_URL = 'https://szafir.swps.edu.pl/';
    private static final String PRIVATE_KEY = String.valueOf(Crypto.generateAesKey(128));
    
    @TestSetup
    static void setup()
    {
        TB_vu_mSzafir__c customSetting = new TB_vu_mSzafir__c(TB_Endpoint_URL__c=ENDPOINT_URL,TB_HMAC_Key__c=PRIVATE_KEY);
        insert customSetting;
        ContentVersion cv = new ContentVersion(Title='Document To Sign',VersionData=Blob.valueOf('testVersion'),PathOnClient='doc.pdf',TB_Category__c = 'Student_Certificate',TB_mSzafir_Signing_ID__c='testSigningId');
        insert cv;
    }
    
    @IsTest
    static void testInit()
    {
        TB_vu_mSzafir__c customSetting = TB_vu_mSzafir__c.getInstance();
        Blob privateKey = Blob.valueOf(customSetting.TB_HMAC_Key__c);
        ContentVersion cv = [SELECT Id FROM ContentVersion WHERE Title = 'Document To Sign'];
        TB_vu_mSzafirService.SzafirInitParams params = new TB_vu_mSzafirService.SzafirInitParams(cv.Id,privateKey,TB_vu_mSzafirService.Mode.LONG_TERM,null);
        
        Test.setMock(HttpCalloutMock.class,new TB_vu_mSzafirMock());
        Test.startTest();
        TB_vu_mSzafirService.SzafirInitResponse response = TB_vu_mSzafirService.init(params);
        Test.stopTest();
        
        Assert.areEqual(null,response.statusCode);
        Assert.areEqual(null,response.status);
        Assert.areNotEqual(null,response.signingId);
        Assert.areNotEqual(null,response.fileIds);
        Assert.areEqual(1,response.fileIds.size());
    }
    
    @IsTest
    static void testInitFail()
    {
        TB_vu_mSzafir__c customSetting = TB_vu_mSzafir__c.getInstance();
        Blob privateKey = Blob.valueOf(customSetting.TB_HMAC_Key__c);
        ContentVersion cv = [SELECT Id FROM ContentVersion WHERE Title = 'Document To Sign'];
        TB_vu_mSzafirService.SzafirInitParams params = new TB_vu_mSzafirService.SzafirInitParams(cv.Id,privateKey,TB_vu_mSzafirService.Mode.LONG_TERM,null);
    
        TB_vu_mSzafirMock.positiveResponse = false;
        Test.setMock(HttpCalloutMock.class,new TB_vu_mSzafirMock());
        Test.startTest();
        TB_vu_mSzafirService.SzafirInitResponse response = TB_vu_mSzafirService.init(params);
        Test.stopTest();
        
        Assert.areEqual(205,response.statusCode);
        Assert.areEqual('Empty file',response.status);
        Assert.areEqual(null,response.signingId);
        Assert.areEqual(null,response.fileIds);
    }
    
    @IsTest
    static void testgetLoginParamsForCase()
    {
        Case testCase = new Case();
        testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TB_Student_Certificate_HE').getRecordTypeId();
        insert testCase;
        ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'Document To Sign'];
        ContentDocumentLink link = new ContentDocumentLink
        (
            LinkedEntityId=testCase.Id,
            ContentDocumentId=cv.ContentDocumentId,
            ShareType = 'I',
            Visibility = 'AllUsers'
        );
        insert link;
        
        Test.setMock(HttpCalloutMock.class,new TB_vu_mSzafirMock());
        Test.startTest();
        TB_vu_mSzafirService.SzafirLoginParams response = TB_vu_mSzafirService.getLoginParamsForCase(testCase.Id,null);
        Test.stopTest();
        
        Assert.areEqual(null,response.statusCode);
        Assert.areEqual(null,response.status);
        Assert.areEqual(ENDPOINT_URL+'mini-portal/login',response.requestUrl);
        Assert.areNotEqual(null,response.hauth);
    }
    
    @IsTest
    static void testgetLoginParamsForCaseFail()
    {
        Case testCase = new Case();
        testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TB_Student_Certificate_HE').getRecordTypeId();
        insert testCase;
        ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'Document To Sign'];
        ContentDocumentLink link = new ContentDocumentLink
        (
            LinkedEntityId=testCase.Id,
            ContentDocumentId=cv.ContentDocumentId,
            ShareType = 'I',
            Visibility = 'AllUsers'
        );
        insert link;
        
        TB_vu_mSzafirMock.positiveResponse = false;
        Test.setMock(HttpCalloutMock.class,new TB_vu_mSzafirMock());
        Test.startTest();
        TB_vu_mSzafirService.SzafirLoginParams response = TB_vu_mSzafirService.getLoginParamsForCase(testCase.Id,null);
        Test.stopTest();
    
        Assert.areEqual(205,response.statusCode);
        Assert.areEqual('Empty file',response.status);
        Assert.areEqual(null,response.requestUrl);
        Assert.areEqual(null,response.hauth);
    }
    
    @IsTest
    static void testStatus()
    {
        TB_vu_mSzafirMock.method = TB_vu_mSzafirMock.SzafirMethod.STATUS;
        Test.setMock(HttpCalloutMock.class,new TB_vu_mSzafirMock());
        Test.startTest();
        TB_vu_mSzafirService.SzafirStatusResponse response = TB_vu_mSzafirService.status('testSigningId');
        Test.stopTest();
        
        Assert.isTrue(response.completed);
        Assert.areEqual(0,response.statusCode);
        Assert.areEqual('OK',response.status);
        Assert.areEqual(1,response.fileUrls.size());
    }
    
    @IsTest
    static void testStatusFail()
    {
        TB_vu_mSzafirMock.method = TB_vu_mSzafirMock.SzafirMethod.STATUS;
        TB_vu_mSzafirMock.positiveResponse = false;
        Test.setMock(HttpCalloutMock.class,new TB_vu_mSzafirMock());
        Test.startTest();
        TB_vu_mSzafirService.SzafirStatusResponse response = TB_vu_mSzafirService.status('testSigningId');
        Test.stopTest();
        
        Assert.isFalse(response.completed);
        Assert.areEqual(522,response.statusCode);
        Assert.areEqual('Test Error',response.status);
        Assert.isTrue(response.fileUrls.isEmpty());
    }
    
    @IsTest
    static void testDownload()
    {
        TB_vu_mSzafirMock.method = TB_vu_mSzafirMock.SzafirMethod.DOWNLOAD;
        Test.setMock(HttpCalloutMock.class,new TB_vu_mSzafirMock());
        Test.startTest();
        Object response = TB_vu_mSzafirService.download('testSigningId', 'testFileId');
        Test.stopTest();
        
        Assert.isTrue(response instanceof Blob);
        Assert.areEqual(Blob.valueOf('Test Content'),(Blob)response);
    }
    
    @IsTest
    static void testDownloadFail()
    {
        TB_vu_mSzafirMock.method = TB_vu_mSzafirMock.SzafirMethod.DOWNLOAD;
        TB_vu_mSzafirMock.positiveResponse = false;
        Test.setMock(HttpCalloutMock.class,new TB_vu_mSzafirMock());
        Test.startTest();
        Object response = TB_vu_mSzafirService.download('testSigningId','testFileId');
        Test.stopTest();
    
        Assert.isTrue(response instanceof TB_vu_mSzafirService.SzafirDownloadResponse);
        TB_vu_mSzafirService.SzafirDownloadResponse castResponse = (TB_vu_mSzafirService.SzafirDownloadResponse)response;
        Assert.areEqual(220,castResponse.statusCode);
        Assert.areEqual('No file',castResponse.status);
    }
    
    @IsTest
    static void testDestroy()
    {
        TB_vu_mSzafirMock.method = TB_vu_mSzafirMock.SzafirMethod.DESTROY;
        Test.setMock(HttpCalloutMock.class,new TB_vu_mSzafirMock());
        Test.startTest();
        TB_vu_mSzafirService.SzafirDestroyResponse response = TB_vu_mSzafirService.destroy('testSigningId');
        Test.stopTest();
        
        Assert.areEqual(0,response.statusCode);
        Assert.areEqual('OK',response.status);
    }
    
    @IsTest
    static void testDestroyFail()
    {
        TB_vu_mSzafirMock.method = TB_vu_mSzafirMock.SzafirMethod.DESTROY;
        TB_vu_mSzafirMock.positiveResponse = false;
        Test.setMock(HttpCalloutMock.class,new TB_vu_mSzafirMock());
        Test.startTest();
        TB_vu_mSzafirService.SzafirDestroyResponse response = TB_vu_mSzafirService.destroy('testSigningId');
        Test.stopTest();
        
        Assert.areEqual(220,response.statusCode);
        Assert.areEqual('Unknown ID',response.status);
    }
    
    @IsTest
    static void updateCaseStatusTest()
    {
        Case testCase = new Case();
        testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TB_Student_Certificate_HE').getRecordTypeId();
        insert testCase;
        
        Test.startTest();
        TB_vu_mSzafirService.updateCaseStatus(testCase.Id);
        Test.stopTest();
        
        Case testedCase = [SELECT Id, Status, TB_Signature_Status__c, TB_Signature_Status_Date_Time__c FROM Case WHERE Id = :testCase.Id];
        Assert.areEqual('In_Progress',testedCase.Status);
        Assert.areEqual('In Progress',testedCase.TB_Signature_Status__c);
        Assert.isNotNull(testedCase.TB_Signature_Status__c);
    }
    
    @IsTest
    static void testEnqueueFileDownload()
    {
        ContentVersion cv = new ContentVersion(Title='Document To Sign',VersionData=Blob.valueOf('testVersion'),PathOnClient='doc.pdf',TB_Category__c = 'Student_Certificate');
        insert cv;
        Case certCase = new Case();
        certCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TB_Student_Certificate_HE').getRecordTypeId();
        insert certCase;
        ContentVersion cvInserted = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId = cvInserted.ContentDocumentId, LinkedEntityId = certCase.Id, ShareType = 'I', Visibility = 'AllUsers');
        insert cdl;
        
        Test.startTest();
        Integer queueableJobs = Limits.getQueueableJobs();
        Boolean exceptionThrown = false;
        try
        {
            TB_vu_mSzafirService.enqueueFileDownload(certCase.Id);
        }
        catch(Exception e)
        {
            exceptionThrown = true;
        }
        queueableJobs = Limits.getQueueableJobs() - queueableJobs;
        Test.stopTest();
        
        Assert.areEqual(1,queueableJobs);
        Assert.isFalse(exceptionThrown);
    }
    
    @IsTest
    static void testSzafirTransactionFinalizerStatus()
    {
        Case certCase = new Case();
        certCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TB_Student_Certificate_HE').getRecordTypeId();
        insert certCase;
        TB_vu_mSzafirMock.method = TB_vu_mSzafirMock.SzafirMethod.STATUS;
        Test.setMock(HttpCalloutMock.class,new TB_vu_mSzafirMock());
        Test.startTest();
        TB_vu_mSzafirService.SzafirTransactionFinalizer queueable = new TB_vu_mSzafirService.SzafirTransactionFinalizer('testSigningId',certCase.Id);
        System.enqueueJob(queueable);
        Test.stopTest();
        
        List<TB_Log__c> logs = [SELECT Id FROM TB_Log__c];
        Assert.areEqual(0,logs.size());
        Assert.isNull([SELECT Id, TB_Signature_Status__c FROM Case WHERE Id = :certCase.Id].TB_Signature_Status__c);
    }
    
    @IsTest
    static void testSzafirTransactionFinalizerStatusFail()
    {
        Case certCase = new Case();
        certCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TB_Student_Certificate_HE').getRecordTypeId();
        insert certCase;
        TB_vu_mSzafirMock.method = TB_vu_mSzafirMock.SzafirMethod.STATUS;
        TB_vu_mSzafirMock.positiveResponse = false;
        Test.setMock(HttpCalloutMock.class,new TB_vu_mSzafirMock());
        Test.startTest();
        TB_vu_mSzafirService.SzafirTransactionFinalizer queueable = new TB_vu_mSzafirService.SzafirTransactionFinalizer('testSigningId',certCase.Id);
        System.enqueueJob(queueable);
        Test.stopTest();
        
        List<TB_Log__c> logs = [SELECT Id FROM TB_Log__c];
        Assert.areEqual(1,logs.size());
        Assert.areEqual('Error',[SELECT Id, TB_Signature_Status__c FROM Case WHERE Id = :certCase.Id].TB_Signature_Status__c);
    }
    
    @IsTest
    static void testSzafirTransactionFinalizerDownload()
    {
        Case certCase = new Case();
        certCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TB_Student_Certificate_HE').getRecordTypeId();
        insert certCase;
        ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'Document To Sign'];
        ContentDocumentLink link = new ContentDocumentLink
                (
                        LinkedEntityId=certCase.Id,
                        ContentDocumentId=cv.ContentDocumentId,
                        ShareType = 'I',
                        Visibility = 'AllUsers'
                );
        insert link;
        TB_vu_mSzafirMock.method = TB_vu_mSzafirMock.SzafirMethod.DOWNLOAD;
        Test.setMock(HttpCalloutMock.class,new TB_vu_mSzafirMock());
        Test.startTest();
        TB_vu_mSzafirService.SzafirTransactionFinalizer queueable = new TB_vu_mSzafirService.SzafirTransactionFinalizer('testSigningId',certCase.Id);
        queueable.currentMethod = TB_vu_mSzafirService.SzafirMethod.DOWNLOAD;
        System.enqueueJob(queueable);
        Test.stopTest();
        
        List<TB_Log__c> logs = [SELECT Id FROM TB_Log__c];
        Assert.areEqual(0,logs.size());
        Assert.isNull([SELECT Id, TB_Signature_Status__c FROM Case WHERE Id = :certCase.Id].TB_Signature_Status__c);
    }
    
    @IsTest
    static void testSzafirTransactionFinalizerDownloadFail()
    {
        Case certCase = new Case();
        certCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TB_Student_Certificate_HE').getRecordTypeId();
        insert certCase;
        ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'Document To Sign'];
        ContentDocumentLink link = new ContentDocumentLink
                (
                        LinkedEntityId=certCase.Id,
                        ContentDocumentId=cv.ContentDocumentId,
                        ShareType = 'I',
                        Visibility = 'AllUsers'
                );
        insert link;
        TB_vu_mSzafirMock.method = TB_vu_mSzafirMock.SzafirMethod.DOWNLOAD;
        TB_vu_mSzafirMock.positiveResponse = false;
        Test.setMock(HttpCalloutMock.class,new TB_vu_mSzafirMock());
        Test.startTest();
        TB_vu_mSzafirService.SzafirTransactionFinalizer queueable = new TB_vu_mSzafirService.SzafirTransactionFinalizer('testSigningId',certCase.Id);
        queueable.currentMethod = TB_vu_mSzafirService.SzafirMethod.DOWNLOAD;
        System.enqueueJob(queueable);
        Test.stopTest();
        
        List<TB_Log__c> logs = [SELECT Id FROM TB_Log__c];
        Assert.areEqual(1,logs.size());
        Assert.areEqual('Error',[SELECT Id, TB_Signature_Status__c FROM Case WHERE Id = :certCase.Id].TB_Signature_Status__c);
    }
    
    @IsTest
    static void testSzafirTransactionFinalizerDownloadFailNoFile()
    {
        Case certCase = new Case();
        certCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TB_Student_Certificate_HE').getRecordTypeId();
        insert certCase;
        TB_vu_mSzafirMock.method = TB_vu_mSzafirMock.SzafirMethod.DOWNLOAD;
        Test.setMock(HttpCalloutMock.class,new TB_vu_mSzafirMock());
        Test.startTest();
        TB_vu_mSzafirService.SzafirTransactionFinalizer queueable = new TB_vu_mSzafirService.SzafirTransactionFinalizer('falseSigningId',certCase.Id);
        queueable.currentMethod = TB_vu_mSzafirService.SzafirMethod.DOWNLOAD;
        System.enqueueJob(queueable);
        Test.stopTest();
        
        List<TB_Log__c> logs = [SELECT Id FROM TB_Log__c];
        Assert.areEqual(1,logs.size());
        Assert.areEqual('Error',[SELECT Id, TB_Signature_Status__c FROM Case WHERE Id = :certCase.Id].TB_Signature_Status__c);
    }
    
    @IsTest
    static void testSzafirTransactionFinalizerDestroy()
    {
        Case certCase = new Case();
        certCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TB_Student_Certificate_HE').getRecordTypeId();
        insert certCase;
        TB_vu_mSzafirMock.method = TB_vu_mSzafirMock.SzafirMethod.DESTROY;
        Test.setMock(HttpCalloutMock.class,new TB_vu_mSzafirMock());
        Test.startTest();
        TB_vu_mSzafirService.SzafirTransactionFinalizer queueable = new TB_vu_mSzafirService.SzafirTransactionFinalizer('testSigningId',certCase.Id);
        queueable.currentMethod = TB_vu_mSzafirService.SzafirMethod.DESTROY;
        System.enqueueJob(queueable);
        Test.stopTest();
        
        List<TB_Log__c> logs = [SELECT Id FROM TB_Log__c];
        Assert.areEqual(0,logs.size());
        Assert.areEqual('Signed',[SELECT Id, TB_Signature_Status__c FROM Case WHERE Id = :certCase.Id].TB_Signature_Status__c);
    }
    
    @IsTest
    static void testSzafirTransactionFinalizerDestroyFail()
    {
        Case certCase = new Case();
        certCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TB_Student_Certificate_HE').getRecordTypeId();
        insert certCase;
        TB_vu_mSzafirMock.method = TB_vu_mSzafirMock.SzafirMethod.DESTROY;
        TB_vu_mSzafirMock.positiveResponse = false;
        Test.setMock(HttpCalloutMock.class,new TB_vu_mSzafirMock());
        Test.startTest();
        TB_vu_mSzafirService.SzafirTransactionFinalizer queueable = new TB_vu_mSzafirService.SzafirTransactionFinalizer('testSigningId',certCase.Id);
        queueable.currentMethod = TB_vu_mSzafirService.SzafirMethod.DESTROY;
        System.enqueueJob(queueable);
        Test.stopTest();
        
        List<TB_Log__c> logs = [SELECT Id FROM TB_Log__c];
        Assert.areEqual(1,logs.size());
        Assert.areEqual('Error',[SELECT Id, TB_Signature_Status__c FROM Case WHERE Id = :certCase.Id].TB_Signature_Status__c);
    }
}