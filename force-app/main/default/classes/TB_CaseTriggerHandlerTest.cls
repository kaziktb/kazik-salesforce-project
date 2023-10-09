/**
 * Created by Marcin Kozub on 19/10/2022.
 */

@IsTest
private class TB_CaseTriggerHandlerTest {
    private static final String USER_LAST_NAME = 'CaseTest';
    private static final Datetime POSITIVE_TEST_DATETIME = Datetime.newInstance(2022, 02, 02, 12, 0, 0);
    private static final Datetime NEGATIVE_TEST_DATETIME = Datetime.newInstance(2021, 02, 02, 12, 0, 0);
    private static final String TEST_STRING = '<p>dshsrh<strong>jmikobsdfhkopmsdgFklppklmsdehtrp</strong></p>';

    @TestSetup
    private static void setupTest(){
        System.runAs(TB_DataFactory.createUser(TB_Constants.PROFILE_NAME_ADMINISTRATOR, TB_Constants.ROLE_DEV_NAME_ADMIN, false)){
            Contact contact = new Contact(LastName = USER_LAST_NAME);
            insert contact;
        }
    }

    @IsTest
    static void testUpdateDescriptionUpdate()
    {
        Case testCase = new Case();
        testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TB_Student_Question_HE').getRecordTypeId();
        insert testCase;

        testCase.TB_Description_Rich_Text__c = TEST_STRING;

        Test.startTest();

        update testCase;

        Test.stopTest();
        System.assertEquals('dshsrhjmikobsdfhkopmsdgFklppklmsdehtrp', [SELECT Description FROM Case WHERE Id = :testCase.Id].Description);
    }

    @IsTest
    static void testUpdateDescriptionInsert()
    {
        Case testCase = new Case();
        testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TB_Student_Question_HE').getRecordTypeId();
        testCase.TB_Description_Rich_Text__c = TEST_STRING;

        Test.startTest();

        insert testCase;

        Test.stopTest();
        System.assertEquals('dshsrhjmikobsdfhkopmsdgFklppklmsdehtrp', [SELECT Description FROM Case WHERE Id = :testCase.Id].Description);
    }

    @IsTest
    static void testSaveApplicationPDFWrongRecordType()
    {
        Case testCase = new Case();
        testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TB_Student_Question_HE').getRecordTypeId();
        insert testCase;

        Test.startTest();

        testCase.Status = 'Closed';
        update testCase;
        Integer queueableJobs = Limits.getQueueableJobs();

        Test.stopTest();

        System.assertEquals(0,queueableJobs);
    }

    @IsTest
    static void testSaveApplicationPDFUpdateNotClosed()
    {
        Case testCase = new Case();
        testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TB_Student_Application_HE').getRecordTypeId();
        insert testCase;

        Test.startTest();

        testCase.TB_Description_Rich_Text__c = '<p>Test</p>';
        update testCase;
        Integer queueableJobs = Limits.getQueueableJobs();

        Test.stopTest();

        System.assertEquals(0,queueableJobs);
    }

    @IsTest
    static void testSaveApplicationPDFUpdate()
    {
        Case testCase = new Case();
        testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TB_Student_Application_HE').getRecordTypeId();
        insert testCase;

        Test.startTest();

        testCase.Status = 'Closed';
        update testCase;
        Integer queueableJobs = Limits.getQueueableJobs();

        Test.stopTest();

        System.assertEquals(1,queueableJobs);
    }

    @IsTest
    static void insertCasePositiveTest() {
        Contact contact = [
                SELECT Id
                FROM Contact
                LIMIT 1
        ];
        Case c = new Case(ContactId = contact.Id);

        Test.startTest();
        insert c;
        Test.stopTest();

        Case c2 = [
                SELECT TB_Last_Activity_Date__c
                FROM Case
                WHERE Id =: c.Id
        ];
        System.assertEquals(POSITIVE_TEST_DATETIME, c2.TB_Last_Activity_Date__c, 'Last activity date should be returned.');
    }
    @IsTest
    static void insertCaseNegativeTest() {
        Contact contact = [
                SELECT Id
                FROM Contact
                LIMIT 1
        ];
        Case c = new Case(ContactId = contact.Id);

        Test.startTest();
        insert c;
        Test.stopTest();

        Case c2 = [
                SELECT TB_Last_Activity_Date__c
                FROM Case
                WHERE Id =: c.Id
        ];
        System.assertNotEquals(NEGATIVE_TEST_DATETIME, c2.TB_Last_Activity_Date__c, 'Last activity date should be returned.');
    }
    @IsTest
    static void updateCasePositiveTest() {
        Contact contact = [
                SELECT Id
                FROM Contact
                LIMIT 1
        ];

        Case c = new Case(ContactId = contact.Id, TB_CT_Case_Category__c = 'Contact', TB_CT_Case_Subcategory__c = 'Student affairs');
        insert c;

        Test.startTest();
        update c;
        Test.stopTest();

        Case c2 = [
                SELECT TB_Last_Activity_Date__c
                FROM Case
                WHERE Id =: c.Id
        ];
        System.assertEquals(POSITIVE_TEST_DATETIME, c2.TB_Last_Activity_Date__c, 'Last activity date should be returned.');
    }
    @IsTest
    static void updateCaseNegativeTest() {
        Contact contact = [
                SELECT Id
                FROM Contact
                LIMIT 1
        ];
        Case c = new Case(ContactId = contact.Id);
        insert c;

        Test.startTest();
        update c;
        Test.stopTest();

        Case c2 = [
                SELECT TB_Last_Activity_Date__c
                FROM Case
                WHERE Id =: c.Id
        ];
        System.assertNotEquals(NEGATIVE_TEST_DATETIME, c2.TB_Last_Activity_Date__c, 'Last activity date should be returned.');
    }

    @IsTest
    static void testFillMeetingDateTimeEmailAfterInsert()
    {
        Case testCase = new Case();
        testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TB_Student_Meeting_HE').getRecordTypeId();
        testCase.TB_Meeting_DateTime__c = Datetime.newInstance(2022, 02, 02, 12, 0, 0);
        
        Test.startTest();
        insert testCase;
        Test.stopTest();

        Assert.isTrue([SELECT TB_Meeting_Time_Email__c FROM Case WHERE Id =: testCase.Id].TB_Meeting_Time_Email__c != null);
    }

    @IsTest
    static void testFillMeetingDateTimeEmailAfterUpdate()
    {
        Case testCase = new Case();
        testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TB_Student_Meeting_HE').getRecordTypeId();
        
        insert testCase;
        Test.startTest();
        testCase.TB_Meeting_DateTime__c = Datetime.newInstance(2022, 02, 02, 12, 0, 0);
        update testCase;
        Test.stopTest();

        Assert.isTrue([SELECT TB_Meeting_Time_Email__c FROM Case WHERE Id =: testCase.Id].TB_Meeting_Time_Email__c != null);
    }
}