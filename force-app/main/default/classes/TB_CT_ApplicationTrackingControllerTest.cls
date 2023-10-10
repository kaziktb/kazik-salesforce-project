@IsTest
private class TB_CT_ApplicationTrackingControllerTest {
    private static final String DEPARTMENT_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('University_Department').getRecordTypeId();
    private static final String DEPARTMENT_TYPE = 'Faculty';
    private static final String EMPLOYEE_TYPE = 'Contract_Teacher';
    private static final String TEST_NAME = 'Joseph';
    private static final String PHONE_NUMBER = '123456789';
    private static final String EMAIL = 'red@flag.ru';
    private static final String PROCESS_CANCELED = 'Process_Cancelled';
    private static final String PROCESS_NEW = 'New';
    private static final String TYPE_OF_STUDIES = 'Higher_Education';

    @TestSetup
    private static void setupMethod() {
        System.runAs(TB_DataFactory.createUser('System Administrator', 'Admin', false)) {
            Account department = new Account(Name = TEST_NAME, RecordTypeId = DEPARTMENT_RECORD_TYPE_ID, Type = DEPARTMENT_TYPE);
            insert department;

            Contact coordinator = new Contact(LastName = TEST_NAME, DT_Is_Employee__c = true);
            insert coordinator;

            TB_TC_URLs__c url = new TB_TC_URLs__c(TB_Admissions_Portal__c = 'https://devtbydct-swpsuniversity.cs174.force.com');
            insert url;

            TB_App_Tracking__c appTracking = new TB_App_Tracking__c(
                    TB_First_Name__c = TEST_NAME,
                    TB_Last_Name__c = TEST_NAME,
                    TB_Employee_Type__c = EMPLOYEE_TYPE,
                    TB_Phone__c = PHONE_NUMBER,
                    TB_Email__c = EMAIL,
                    TB_Process_Status__c = PROCESS_NEW,
                    TB_Uni_Work_Department__c = department.Id,
                    TB_Is_Foreigner__c = true,
                    TB_Responsible_Coordinator__c = coordinator.Id
            );
            insert appTracking;
        }
    }

    @IsTest
    static void fetchAllAppsTrackingReturnNonEmptyListTest() {
        Test.startTest();
        List<TB_CT_ApplicationTrackingController.AppTrackingWrapper> appTrackingWrappers = TB_CT_ApplicationTrackingController.getAppTrackingByFilters(null, null, null, null, null, null, null, 0, 210);
        Test.stopTest();

        System.assertEquals(1, appTrackingWrappers.size());
    }

    @IsTest
    static void fetchAllAppsTrackingReturnEmptyListTest() {
        TB_App_Tracking__c appTracking = [SELECT Id FROM TB_App_Tracking__c LIMIT 1];
        delete appTracking;

        Test.startTest();
        List<TB_CT_ApplicationTrackingController.AppTrackingWrapper> appTrackingWrappers = TB_CT_ApplicationTrackingController.getAppTrackingByFilters(null, null, null, null, null, null, null, 0, 210);
        Test.stopTest();

        System.assertEquals(0, appTrackingWrappers.size());
    }

    @IsTest
    static void fetchAppsTrackingBySearchFilterTest() {
        String searchTerm = TEST_NAME.substring(0, 3);

        Test.startTest();
        List<TB_CT_ApplicationTrackingController.AppTrackingWrapper> wrappers = TB_CT_ApplicationTrackingController.getAppTrackingByFilters(searchTerm, null, null, null, null, null, null, 0, 210);
        Test.stopTest();

        Assert.areEqual(1, wrappers.size());
        Assert.isTrue(wrappers[0].teacherFullName.contains(searchTerm) || wrappers[0].email.contains(searchTerm) || wrappers[0].phone.contains(searchTerm));
    }

    @IsTest
    static void fetchAppsTrackingByAllFiltersTest() {
        Account depart = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        String searchTerm = TEST_NAME.substring(0, 3);

        Test.startTest();
        List<TB_CT_ApplicationTrackingController.AppTrackingWrapper> wrappers = TB_CT_ApplicationTrackingController.getAppTrackingByFilters(searchTerm, 'ASCENDING', depart.Id, con.Id, true, 'New', false, 0, 210);
        Test.stopTest();

        Assert.areEqual(1, wrappers.size());
        Assert.isTrue(wrappers[0].teacherFullName.contains(searchTerm) || wrappers[0].email.contains(searchTerm) || wrappers[0].phone.contains(searchTerm));
        Assert.areEqual(depart.Id, wrappers[0].uniWorkDepartment);
        Assert.areEqual(con.Id, wrappers[0].coordinatorId);
        Assert.isTrue(wrappers[0].isForeigner);
        Assert.isTrue(wrappers[0].status.equals('New'));
        Assert.isFalse(wrappers[0].isMine);
    }

    @IsTest
    static void getAppTrackingByIdReturnObject() {
        TB_App_Tracking__c appTracking = [SELECT Id FROM TB_App_Tracking__c LIMIT 1];

        Test.startTest();
        TB_CT_ApplicationTrackingController.AppTrackingWrapper appTrackingWrapper = TB_CT_ApplicationTrackingController.getAppTrackingById(appTracking.Id);
        Test.stopTest();

        Assert.isNotNull(appTrackingWrapper);
    }

    @IsTest
    static void getAppTrackingByIdThrowException() {
        TB_App_Tracking__c appTracking = [SELECT Id FROM TB_App_Tracking__c LIMIT 1];
        Id appTrackingId = appTracking.Id;
        delete appTracking;

        Boolean exceptionOccurred = false;

        Test.startTest();
        try {
            TB_CT_ApplicationTrackingController.AppTrackingWrapper appTrackingWrapper = TB_CT_ApplicationTrackingController.getAppTrackingById(appTrackingId);
        } catch (AuraHandledException e) {
            exceptionOccurred = true;
        }
        Test.stopTest();

        Assert.isTrue(exceptionOccurred);
    }

    @IsTest
    static void getAllDepartmentsReturnNonEmptyListTest() {
        Test.startTest();
        List<Account> departments = TB_CT_ApplicationTrackingController.getAllDepartments();
        Test.stopTest();

        System.assertEquals(1, departments.size());
    }

    @IsTest
    static void getAllDepartmentsReturnEmptyListTest() {
        Account department = [SELECT Id FROM Account LIMIT 1];
        department.TB_Active__c = false;
        update department;

        Test.startTest();
        List<Account> departments = TB_CT_ApplicationTrackingController.getAllDepartments();
        Test.stopTest();

        System.assertEquals(0, departments.size());
    }

    @IsTest
    static void cancelProcessPositiveTest(){
        TB_App_Tracking__c appTracking = [SELECT TB_Process_Status__c FROM TB_App_Tracking__c LIMIT 1];

        Test.startTest();
        TB_CT_ApplicationTrackingController.cancelProcess(appTracking.Id);
        Test.stopTest();

        appTracking = [SELECT TB_Process_Status__c FROM TB_App_Tracking__c LIMIT 1];
        System.assertEquals(PROCESS_CANCELED, appTracking.TB_Process_Status__c);
    }
}