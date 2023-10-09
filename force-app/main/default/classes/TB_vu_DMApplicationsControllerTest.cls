@IsTest
private class TB_vu_DMApplicationsControllerTest
{
    private static final String CONVERSATION_RECORD_TYPE_DEVELOPER_NAME = 'TB_Conversation';
    private static final String DECISION_RECORD_TYPE_DEVELOPER_NAME = 'TB_Decision';
    
    @TestSetup
    static void setup()
    {
        Account account = new Account(Name='Test Account');
        insert account;
        Contact studentContact = TB_TestDataFactory.createContact(false);
        studentContact.LastName = 'Kowalski';
        studentContact.Birthdate = Date.newInstance(1997,2,21);
        studentContact.AccountId = account.Id;
        insert studentContact;
        Contact dmContact = TB_TestDataFactory.createContact(false);
        dmContact.FirstName = 'Decision';
        dmContact.LastName = 'Maker';
        dmContact.Birthdate = Date.newInstance(1971,6,6);
        dmContact.AccountId = account.Id;
        dmContact.TB_SS_Decision_Maker__c = true;
        insert dmContact;
        Case testCase = new Case(
                Subject = 'Test',
                Status = 'New',
                ContactId = studentContact.Id,
                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TB_Student_Application_HE').getRecordTypeId()
        );
        insert testCase;
        TB_Operation__c initialOperation = new TB_Operation__c();
        initialOperation.TB_Type__c = 'External_Comment';
        initialOperation.TB_Case__c = testCase.Id;
        initialOperation.TB_Contact__c = testCase.ContactId;
        initialOperation.TB_Author__c = 'Student';
        initialOperation.TB_Description_Rich_Text__c = '<p>Podanie</p>';
        initialOperation.TB_Publish__c = true;
        initialOperation.TB_Initial__c = true;
        initialOperation.RecordTypeId = Schema.SObjectType.TB_Operation__c.getRecordTypeInfosByDeveloperName().get(CONVERSATION_RECORD_TYPE_DEVELOPER_NAME).getRecordTypeId();
        insert initialOperation;
        ContentVersion cv = new ContentVersion (
                PathOnClient = 'CaseAttachment',
                Title = 'CaseAttachment',
                VersionData = Blob.valueOf('Test'),
                ContentLocation = 's'
        );
        insert cv;
        ContentDocument cd = [SELECT Id FROM ContentDocument WHERE Id IN (SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'CaseAttachment')];
        ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId = cd.Id, LinkedEntityId = initialOperation.Id, ShareType = 'I', Visibility = 'AllUsers');
        insert cdl;
    }
    
    @IsTest
    static void testFetchCaseWrappersShouldBeEmpty()
    {
        Case studentCase = [SELECT Id, ContactId FROM Case WHERE Subject LIKE 'Test'];
        Contact dmContact = [SELECT Id FROM Contact WHERE FirstName LIKE 'Decision'];
        
        TB_Operation__c commentOperation = new TB_Operation__c();
        commentOperation.TB_Type__c = 'External_Comment';
        commentOperation.TB_Case__c = studentCase.Id;
        commentOperation.TB_Contact__c = studentCase.ContactId;
        commentOperation.TB_Author__c = 'Student';
        commentOperation.TB_Description_Rich_Text__c = '<p>Podanie</p>';
        commentOperation.TB_Publish__c = true;
        commentOperation.RecordTypeId = Schema.SObjectType.TB_Operation__c.getRecordTypeInfosByDeveloperName().get(CONVERSATION_RECORD_TYPE_DEVELOPER_NAME).getRecordTypeId();
        insert commentOperation;
        
        List<TB_vu_DMApplicationsController.CaseWrapper> wrappers = TB_vu_DMApplicationsController.fetchCaseWrappers(dmContact.Id);
        
        System.assert(wrappers.isEmpty());
    }
    
    @IsTest
    static void testFetchCaseWrappers()
    {
        Case studentCase = [SELECT Id, ContactId FROM Case WHERE Subject LIKE 'Test' LIMIT 1];
        Contact dmContact = [SELECT Id FROM Contact WHERE FirstName LIKE 'Decision' LIMIT 1];
        
        TB_Operation__c decisionRequestOperation = new TB_Operation__c();
        decisionRequestOperation.TB_Type__c = 'Request_For_A_Decision';
        decisionRequestOperation.TB_Case__c = studentCase.Id;
        decisionRequestOperation.TB_Contact__c = studentCase.ContactId;
        decisionRequestOperation.TB_Decision_Maker__c = dmContact.Id;
        decisionRequestOperation.TB_Author__c = 'Host';
        decisionRequestOperation.TB_Description_Rich_Text__c = '<p>Prosze o decyzje</p>';
        decisionRequestOperation.TB_Is_Decision__c = false;
        decisionRequestOperation.TB_Publish__c = true;
        decisionRequestOperation.RecordTypeId = Schema.SObjectType.TB_Operation__c.getRecordTypeInfosByDeveloperName().get(DECISION_RECORD_TYPE_DEVELOPER_NAME).getRecordTypeId();
        insert decisionRequestOperation;
        ContentVersion cv = new ContentVersion (
                PathOnClient = 'OperationAttachment',
                Title = 'OperationAttachment',
                VersionData = Blob.valueOf('Test'),
                ContentLocation = 's'
        );
        insert cv;
        ContentDocument cd = [SELECT Id FROM ContentDocument WHERE Id IN (SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'OperationAttachment')];
        ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId = cd.Id, LinkedEntityId = decisionRequestOperation.Id, ShareType = 'I', Visibility = 'AllUsers');
        insert cdl;
        
        List<TB_vu_DMApplicationsController.CaseWrapper> wrappers = TB_vu_DMApplicationsController.fetchCaseWrappers(dmContact.Id);
        
        System.assertEquals(1,wrappers.size());
    }
    
    @IsTest
    static void shouldReturnOneCaseComment(){
        Case studentCase = [SELECT Id FROM Case WHERE Subject LIKE 'Test' LIMIT 1];

        Test.startTest();
        List<TB_vu_DMApplicationsController.CommentWrapper> commentWrapper = TB_vu_DMApplicationsController.fetchCaseComments(studentCase.Id);
        Test.stopTest();

        Assert.isTrue(commentWrapper.size()==1);
    }

    @IsTest
    static void throwAnError_whenInvalidIdIsPassedToFetchCaseComments(){
        Case studentCase = [SELECT Id FROM Case WHERE Subject LIKE 'Test' LIMIT 1];
        Boolean isException = false;

        Test.startTest();
        try {
            List<TB_vu_DMApplicationsController.CommentWrapper> commentWrapper = TB_vu_DMApplicationsController.fetchCaseComments('INVALID');
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        Assert.isTrue(isException);
    }
}