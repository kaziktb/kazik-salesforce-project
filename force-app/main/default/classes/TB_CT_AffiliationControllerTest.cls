@IsTest
private class TB_CT_AffiliationControllerTest {
    private static final String DEPARTMENT_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('University_Department').getRecordTypeId();
    private static final String EMPLOYEE_RECORD_TYPE_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('TB_Employee').getRecordTypeId();
    private static final String TEST_NAME = 'TEST_TEST';


    @TestSetup
    private static void setupMethod() {
        System.runAs(TB_DataFactory.createUser('System Administrator', 'Admin', false)) {
            Account department = new Account(Name = TEST_NAME, RecordTypeId = DEPARTMENT_RECORD_TYPE_ID, Type = 'Faculty');
            insert department;
            Contact contact = new Contact(LastName = TEST_NAME, RecordTypeId = EMPLOYEE_RECORD_TYPE_ID);
            insert contact;

            hed__Affiliation__c affiliation = new hed__Affiliation__c(
                    hed__Contact__c = contact.Id,
                    hed__Account__c = department.Id,
                    hed__Role__c = 'Employee'
            );
            insert affiliation;
        }
    }

    @IsTest
    static void fetchAllAffiliationsByContactIdReturnNonEmptyListTest() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
        List<TB_CT_AffiliationController.AffiliationWrapper> affiliationWrappers = TB_CT_AffiliationController.fetchAllAffiliationsByContactId(contact.Id);
        Test.stopTest();

        Assert.areEqual(1, affiliationWrappers.size());
    }

    @IsTest
    static void fetchAllAffiliationsByContactIdReturnEmptyListTest() {
        Contact contact = new Contact(LastName = TEST_NAME, RecordTypeId = EMPLOYEE_RECORD_TYPE_ID);

        Test.startTest();
        List<TB_CT_AffiliationController.AffiliationWrapper> affiliationWrappers  = TB_CT_AffiliationController.fetchAllAffiliationsByContactId(contact.Id);
        Test.stopTest();

        Assert.areEqual(0, affiliationWrappers.size());
    }

    @IsTest
    static void shouldReturnAffiliationDepartmentInfoForApplicantTest() {
        hed__Affiliation__c affiliation = [SELECT Id FROM hed__Affiliation__c LIMIT 1];

        Test.startTest();
        Account depart = TB_CT_AffiliationController.fetchDepartmentAffiliationByAffiliationId(affiliation.Id);
        Test.stopTest();

        Assert.isNotNull(depart);
    }

    @IsTest
    static void shouldReturnAffiliationDepartmentInfoForExistingDidacticTest() {
        Account uni = [SELECT Id FROM Account WHERE Type = 'Faculty' LIMIT 1];
        uni.Type = 'Other';
        update uni;
        hed__Affiliation__c affiliation = [SELECT Id FROM hed__Affiliation__c LIMIT 1];

        Test.startTest();
        Account depart = TB_CT_AffiliationController.fetchDepartmentAffiliationByAffiliationId(affiliation.Id);
        Test.stopTest();

        Assert.isNotNull(depart);
    }

    @IsTest
    static void shouldNotReturnAffiliationDepartmentInfoTest() {
        Account uni = [SELECT Id FROM Account WHERE Type = 'Faculty' LIMIT 1];
        uni.TB_Active__c = false;
        update uni;
        hed__Affiliation__c affiliation = [SELECT Id FROM hed__Affiliation__c LIMIT 1];

        Account depart;
        Boolean isExceptionThrown = false;

        Test.startTest();
        try {
            depart = TB_CT_AffiliationController.fetchDepartmentAffiliationByAffiliationId(affiliation.Id);
        } catch (QueryException ex) {
            isExceptionThrown = true;
        }
        Test.stopTest();

        Assert.isNull(depart);
        Assert.isTrue(isExceptionThrown);
    }
}