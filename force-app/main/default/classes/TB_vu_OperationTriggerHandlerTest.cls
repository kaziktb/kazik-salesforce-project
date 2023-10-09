/**
 * Created by Norbert Rzepa on 09.01.2023.
 */

@IsTest
public with sharing class TB_vu_OperationTriggerHandlerTest
{
    private static final String TEST_STRING = '<p>dshsrh<strong>jmikobsdfhkopmsdgFklppklmsdehtrp</strong></p>';
    private static final String ADMIN_PROFILE = 'System Administrator';
    private static final String ADMIN_ROLE = 'Admin';
    private static final String STUDENT_LAST_NAME = 'StudentLastName';
    private static final String DM_LAST_NAME = 'DMLastName';
    
    @TestSetup
    static void testSetup()
    {
        User user = TB_DataFactory.createUser(ADMIN_PROFILE, ADMIN_ROLE, false);
        user.LastName = DM_LAST_NAME;
        insert user;
    }
    
    @IsTest
    static void beforeUpdate()
    {
        Case testCase = new Case();
        insert testCase;

        TB_Operation__c testOperation = new TB_Operation__c();
        testOperation.TB_Case__c = testCase.Id;
        insert testOperation;

        testOperation.TB_Description_Rich_Text__c = TEST_STRING;

        Test.startTest();

        update testOperation;

        Test.stopTest();
        System.assertEquals('dshsrhjmikobsdfhkopmsdgFklppklmsdehtrp', [SELECT TB_Description__c FROM TB_Operation__c WHERE Id = :testOperation.Id].TB_Description__c);
    }

    @IsTest
    static void beforeInsert()
    {
        Case testCase = new Case();
        insert testCase;

        TB_Operation__c testOperation = new TB_Operation__c();
        testOperation.TB_Case__c = testCase.Id;
        testOperation.TB_Description_Rich_Text__c = TEST_STRING;

        Test.startTest();

        insert testOperation;

        Test.stopTest();
        System.assertEquals('dshsrhjmikobsdfhkopmsdgFklppklmsdehtrp', [SELECT TB_Description__c FROM TB_Operation__c WHERE Id = :testOperation.Id].TB_Description__c);
    }
    
    @IsTest
    static void testSaveApplicationPDFInsert()
    {
        Case testCase = new Case();
        testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TB_Student_Application_HE').getRecordTypeId();
        insert testCase;
        
        TB_Operation__c testOperation = new TB_Operation__c();
        testOperation.TB_Initial__c = true;
        testOperation.TB_Case__c = testCase.Id;
        
        Test.startTest();
        
        insert testOperation;
        
        Integer queueableJobs = Limits.getQueueableJobs();
        
        Test.stopTest();
        
        Assert.areEqual(1,queueableJobs);
    }
    
    @IsTest
    static void shouldShareOperationsOnInsert() {
        User user = [SELECT Id FROM User WHERE LastName = :DM_LAST_NAME];
        Contact dmContact = TB_TestDataFactory.createContact(false);
        dmContact.TB_User__c = user.Id;
        dmContact.TB_SS_Decision_Maker__c = true;
        Contact studentContact = new Contact(LastName = STUDENT_LAST_NAME);
        insert new List<Contact>{dmContact,studentContact};
        List<Case> cases = TB_TestDataFactory.createCases(1, 'test', studentContact.Id, true);
        TB_TestDataFactory.createOperation(studentContact.Id, cases[0].Id, '', true);
        
        Test.startTest();
        Integer numberOfFutureCalls = Limits.getFutureCalls();
        TB_Operation__c operation = TB_TestDataFactory.createOperation(studentContact.Id, cases[0].Id, '', false);
        operation.TB_Decision_Maker__c = dmContact.Id;
        insert operation;
        numberOfFutureCalls = Limits.getFutureCalls() - numberOfFutureCalls;
        Test.stopTest();
        
        Assert.areEqual(1,numberOfFutureCalls);
    }
    
    @IsTest
    static void shouldShareOperationsOnUpdate() {
        User user = [SELECT Id FROM User WHERE LastName = :DM_LAST_NAME];
        Contact dmContact = TB_TestDataFactory.createContact(false);
        dmContact.TB_User__c = user.Id;
        dmContact.TB_SS_Decision_Maker__c = true;
        Contact dmContact2 = new Contact(LastName = 'DM2');
        dmContact2.TB_SS_Decision_Maker__c = true;
        Contact studentContact = new Contact(LastName = STUDENT_LAST_NAME);
        insert new List<Contact>{dmContact,dmContact2,studentContact};
        List<Case> cases = TB_TestDataFactory.createCases(1, 'test', studentContact.Id, true);
        TB_TestDataFactory.createOperation(studentContact.Id, cases[0].Id, '', true);
        TB_Operation__c operation = TB_TestDataFactory.createOperation(studentContact.Id, cases[0].Id, '', false);
        operation.TB_Decision_Maker__c = dmContact.Id;
        insert operation;
        
        Test.startTest();
        Integer numberOfFutureCalls = Limits.getFutureCalls();
        operation.TB_Decision_Maker__c = dmContact2.Id;
        update operation;
        numberOfFutureCalls = Limits.getFutureCalls() - numberOfFutureCalls;
        Test.stopTest();
        
        Assert.areEqual(1,numberOfFutureCalls);
    }
}