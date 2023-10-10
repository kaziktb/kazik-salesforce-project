@IsTest
private class TB_vu_ApplicationPreviewControllerTest
{
    private static final String APPLICATION_RT_DEVNAME = 'TB_Student_Application_HE';
    private static final String CASE_STATUS_CLOSED = 'Closed';
    
    @IsTest
    static void testEnqueuePDFGenerationNull()
    {
        Test.startTest();
        
        List<Case> cases;
        
        TB_vu_ApplicationPreviewController.enqueuePDFGeneration(cases);
        Integer queueableJobs = Limits.getQueueableJobs();
        
        Test.stopTest();
        
        System.assertEquals(0,queueableJobs);
    }
    
    @IsTest
    static void testEnqueuePDFGenerationEmpty()
    {
        Test.startTest();
        
        TB_vu_ApplicationPreviewController.enqueuePDFGeneration(new List<Case>());
        Integer queueableJobs = Limits.getQueueableJobs();
        
        Test.stopTest();
        
        System.assertEquals(0,queueableJobs);
    }
    
    @IsTest
    static void testEnqueuePDFGenerationOperations()
    {
        Case testCase = new Case();
        testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(APPLICATION_RT_DEVNAME).getRecordTypeId();
        insert testCase;
        
        TB_Operation__c newOperation = new TB_Operation__c(
                TB_Author__c = 'Student',
                TB_Case__c = testCase.Id,
                TB_Publish__c = true,
                RecordTypeId = Schema.SObjectType.TB_Operation__c.getRecordTypeInfosByDeveloperName().get('TB_Conversation').getRecordTypeId(),
                TB_Type__c = 'External_Comment',
                TB_Initial__c = true
        );
    
        insert newOperation;
        
        Test.startTest();
        
        TB_vu_ApplicationPreviewController.enqueuePDFGeneration(new List<TB_Operation__c>{newOperation});
        Integer queries = Limits.getQueries();
        Integer queueables = Limits.getQueueableJobs();
        
        Test.stopTest();
        
        System.assertEquals(1,queries);
        System.assertEquals(1,queueables);
    }
    
    @IsTest
    static void testEnqueuePDFGenerationCases()
    {
        Case testCase = new Case();
        testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(APPLICATION_RT_DEVNAME).getRecordTypeId();
        testCase.Status = CASE_STATUS_CLOSED;
        insert testCase;
        
        Test.startTest();
        
        TB_vu_ApplicationPreviewController.enqueuePDFGeneration(new List<Case>{testCase});
        Integer queries = Limits.getQueries();
        Integer queueables = Limits.getQueueableJobs();
        
        Test.stopTest();
        
        System.assertEquals(1,queries);
        System.assertEquals(1,queueables);
    }
    
    @IsTest
    static void testGetCase()
    {
        Case testCase = new Case();
        testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(APPLICATION_RT_DEVNAME).getRecordTypeId();
        testCase.Status = CASE_STATUS_CLOSED;
        insert testCase;
        
        Test.startTest();
        
        Case queriedCase = TB_vu_ApplicationPreviewController.getCase(testCase.Id);
        
        Test.stopTest();
        
        System.assertNotEquals(null,queriedCase);
    }
    
    @IsTest
    static void testGetCaseFail()
    {
        Boolean correctException;
        Test.startTest();
        try
        {
            TB_vu_ApplicationPreviewController.getCase('ID');
        }
        catch(Exception e)
        {
            correctException = e instanceof AuraHandledException;
        }
        Test.stopTest();
    
        List<TB_Log__c> logs = [SELECT Id, TB_Message__c FROM TB_Log__c WHERE TB_Related_Record_ID__c = 'ID'];
        System.assert(correctException);
        System.assertEquals(1,logs.size());
        System.assert(logs[0].TB_Message__c.contains('Invalid Case ID: '));
    }
}