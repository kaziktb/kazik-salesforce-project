@IsTest
private class TB_CT_SearchExistingEmployeeTest {

    private static final String PARAM_TEST_FIRST_NAME = 'TestF';
    private static final String PARAM_TEST_LAST_NAME = 'TestL';
    private static final String PARAM_TEST_EMAIL = 'test@test.com';
    private static final String PARAM_TEST_PHONE = '111111111';
    private static final String PARAM_TEST_PESEL = '66010393329';
    private static final String PARAM_TEST_CITIZENSHIP = 'AD';
    private static final String PARAM_NOT_IN_DATABASE_PESEL = '00000000000';
    private static final String PARAM_NOT_IN_DATABASE_EMAIL = 'email@email.com';
    private static final Integer NUMBER_OF_RECORDS = 3;
    private static final String WORK_DEPARTMENT_EMAIL = 'work.dept@test.test';
    private static final String PARAM_TITLE = 'mgr';
    private static final Id CONTACT_EMPLOYEE_RECORD_TYPE_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('TB_Employee').getRecordTypeId();

    @TestSetup
    private static void setupMethod() {
        System.runAs(TB_DataFactory.createUser(TB_Constants.PROFILE_NAME_ADMINISTRATOR, TB_Constants.ROLE_DEV_NAME_ADMIN, false)) {
            insert new TB_TC_URLs__c(TB_Admissions_Portal__c = TB_Constants.TB_CT_ADMISSIONS_PORTAL);
            List<TB_App_Tracking__c> apps = new List<TB_App_Tracking__c>();
            for (Integer i = 0; i < NUMBER_OF_RECORDS; i++) {
                apps.add(
                        new TB_App_Tracking__c(
                                TB_First_Name__c = PARAM_TEST_FIRST_NAME,
                                TB_Last_Name__c = PARAM_TEST_LAST_NAME,
                                TB_Email__c = i + PARAM_TEST_EMAIL,
                                TB_Phone__c = PARAM_TEST_PHONE + i,
                                TB_Is_Foreigner__c = true
                        ));
            }
            Integer maxRetries = 3;
            Integer retries = 0;
            while (retries < maxRetries) {
                try {
                    insert apps;
                    break;
                } catch (Exception e) {
                    retries++;
                    TB_LogUtils.prepareAuraLog(
                    e.getMessage(), TB_CT_SearchExistingEmployeeTest.class.getName(),
                    e.getStackTraceString(), TB_Constants.PARAM_EMPTY_STRING);
                }
            }

            Id recordTypeId = Schema.SObjectType.Account.recordTypeInfosByDeveloperName.get(TB_Constants.TB_CT_RECORD_TYPE_UNI_DEPARTMENTS).getRecordTypeId();
            Account department = new Account(
                    Name = PARAM_TEST_LAST_NAME,
                    TB_Email__c = WORK_DEPARTMENT_EMAIL,
                    RecordTypeId = recordTypeId,
                    Type = TB_Constants.TB_CT_ACCOUNT_TYPE_FACULTY,
                    TB_Subtype__c = 'HE'
            );
            insert department;

            List<Contact> contacts = [
                    SELECT Id
                    FROM Contact
            ];
            for (TB_App_Tracking__c app : apps) {
                app.TB_Email__c = PARAM_TEST_EMAIL;
                app.TB_Phone__c = PARAM_TEST_PHONE;
                app.TB_Uni_Work_Department__c = department.Id;
            }
            update apps;

            for (Contact contact : contacts) {
                contact.RecordTypeId = CONTACT_EMPLOYEE_RECORD_TYPE_ID;
                contact.TB_Active__c = TRUE;
                contact.TB_Citizenship__c = PARAM_TEST_CITIZENSHIP;
                contact.hed__AlternateEmail__c = PARAM_TEST_EMAIL;
                contact.Email = PARAM_TEST_EMAIL;
                contact.hed__WorkPhone__c = PARAM_TEST_PHONE;
                contact.TB_Title_Grade__c = PARAM_TITLE;
                contact.TB_Administrative_Employee_Counter__c = 1;
                contact.TB_Didactic_Applicant_Counter_HE__c = 1;
            }
            update contacts;

            List<hed__Affiliation__c> affiliations = new List<hed__Affiliation__c>();
            for(Contact contact : contacts) {
                affiliations.add(new hed__Affiliation__c(
                    hed__Contact__c = contact.Id,
                    hed__Account__c = department.Id,
                    hed__Role__c = 'Employee',
                    hed__Status__c = 'Current',
                    TB_Employee_Affiliation_Type__c = 'Applicant'
                    ));
            }
            insert affiliations;
        }
    }

    @IsTest
    private static void searchExistingEmployeePhoneEmailTest() {
        List<Contact> contacts = [
                SELECT Id, hed__AlternateEmail__c, hed__WorkPhone__c, DT_PESEL__c
                FROM Contact
        ];
        List<Id> fixedSearchResult = new List<Id>();
        for(Contact contact : contacts) {
            fixedSearchResult.add(contact.Id);
        }
        Test.setFixedSearchResults(fixedSearchResult);

        Test.startTest();
        List<TB_CT_SearchExistingEmployeeController.ContactWrapper> result = TB_CT_SearchExistingEmployeeController.searchExistingEmployee(
                PARAM_TEST_PHONE,
                PARAM_TEST_EMAIL,
                null,
                null,
                null,
                null,
                null,
                null
        );
        Test.stopTest();

        System.assertEquals(NUMBER_OF_RECORDS, result.size());
    }


    @IsTest
    private static void searchExistingEmployeeNameTest() {
        List<Contact> contacts = [
                SELECT Id, hed__AlternateEmail__c, hed__WorkPhone__c, DT_PESEL__c
                FROM Contact
        ];
        List<Id> fixedSearchResult = new List<Id>();
        for(Contact contact : contacts) {
            fixedSearchResult.add(contact.Id);
        }
        Test.setFixedSearchResults(fixedSearchResult);

        Test.startTest();
        List<TB_CT_SearchExistingEmployeeController.ContactWrapper> result = TB_CT_SearchExistingEmployeeController.searchExistingEmployee(
                null,
                null,
                null,
                PARAM_TEST_FIRST_NAME,
                PARAM_TEST_LAST_NAME,
                PARAM_TEST_CITIZENSHIP,
                null,
                null
        );
        Test.stopTest();

        System.assertEquals(NUMBER_OF_RECORDS, result.size());
    }

    @IsTest
    private static void searchExistingEmployeePeselTest() {
        Contact contact = [
                SELECT Id
                FROM Contact
                LIMIT 1
        ];
        contact.DT_PESEL__c = PARAM_TEST_PESEL;
        contact.Birthdate = Date.newInstance(1966, 01, 03);
        contact.Salutation = 'Ms';
        update contact;
        List<Id> fixedSearchResult = new List<Id>();
        fixedSearchResult.add(contact.Id);
        Test.setFixedSearchResults(fixedSearchResult);

        Test.startTest();
        List<TB_CT_SearchExistingEmployeeController.ContactWrapper> result = TB_CT_SearchExistingEmployeeController.searchExistingEmployee(
                null,
                null,
                PARAM_TEST_PESEL,
                PARAM_TEST_FIRST_NAME,
                PARAM_TEST_LAST_NAME,
                PARAM_TEST_CITIZENSHIP,
                null,
                null
        );
        Test.stopTest();

        System.assertEquals(1, result.size());
    }

    @IsTest
    private static void searchExistingEmployeeBlankPhoneTest() {
        List<Contact> contacts = [
                SELECT Id, hed__AlternateEmail__c, hed__WorkPhone__c, DT_PESEL__c
                FROM Contact
        ];
        List<Id> fixedSearchResult = new List<Id>();
        for (Contact contact : contacts) {
            fixedSearchResult.add(contact.Id);
        }
        Test.setFixedSearchResults(fixedSearchResult);

        Test.startTest();
        List<TB_CT_SearchExistingEmployeeController.ContactWrapper> result = TB_CT_SearchExistingEmployeeController.searchExistingEmployee(
                null,
                null,
                null,
                PARAM_TEST_FIRST_NAME,
                PARAM_TEST_LAST_NAME,
                PARAM_TEST_CITIZENSHIP,
                null,
                null
        );
        Test.stopTest();

        System.assertEquals(NUMBER_OF_RECORDS, result.size());
    }

    @IsTest
    static void searchExistingEmployeeNegativeTest() {
        List<Id> fixedSearchResult = new List<Id>();
        fixedSearchResult.add(null);
        Test.setFixedSearchResults(fixedSearchResult);

        Test.startTest();
        List<TB_CT_SearchExistingEmployeeController.ContactWrapper> result = TB_CT_SearchExistingEmployeeController.searchExistingEmployee(
                '655456465456',
                PARAM_NOT_IN_DATABASE_EMAIL,
                PARAM_NOT_IN_DATABASE_PESEL,
                PARAM_TEST_FIRST_NAME,
                PARAM_TEST_LAST_NAME,
                PARAM_TEST_CITIZENSHIP,
                null,
                null
        );
        Test.stopTest();

        System.assertEquals(0, result.size());
    }

    @IsTest
    private static void searchExistingEmployeeNegativeBlankPhonePhoneTest() {
        List<Id> fixedSearchResult = new List<Id>();
        fixedSearchResult.add(null);
        Test.setFixedSearchResults(fixedSearchResult);

        Test.startTest();
        List<TB_CT_SearchExistingEmployeeController.ContactWrapper> result = TB_CT_SearchExistingEmployeeController.searchExistingEmployee(
                '',
                PARAM_NOT_IN_DATABASE_EMAIL,
                PARAM_NOT_IN_DATABASE_PESEL,
                PARAM_TEST_FIRST_NAME,
                PARAM_TEST_LAST_NAME,
                PARAM_TEST_CITIZENSHIP,
                null,
                null
        );
        Test.stopTest();

        System.assertEquals(0, result.size());
    }

    @IsTest
    private static void searchExistingEmployeePositiveDepartmentTest() {
        List<Id> fixedSearchResult = new List<Id>();
        for (Contact contact : [SELECT Id FROM Contact]) {
            fixedSearchResult.add(contact.Id);
        }
        Test.setFixedSearchResults(fixedSearchResult);
        Account department = [
                SELECT Id
                FROM Account
                WHERE RecordType.DeveloperName
                        = :TB_Constants.TB_CT_RECORD_TYPE_UNI_DEPARTMENTS
        ];
        Test.startTest();
        List<TB_CT_SearchExistingEmployeeController.ContactWrapper> result = TB_CT_SearchExistingEmployeeController.searchExistingEmployee(
                '',
                null,
                null,
                null,
                null,
                null,
                PARAM_TITLE,
                department.Id
        );
        Test.stopTest();

        System.assertEquals(NUMBER_OF_RECORDS, result.size());
    }

    @IsTest
    private static void searchExistingEmployeePositiveDuplicatesTest() {

        Test.startTest();
        TB_CT_SearchExistingEmployeeController.DuplicateWrapper wrapper = TB_CT_SearchExistingEmployeeController.checkDuplicates(PARAM_TEST_EMAIL,PARAM_TEST_PESEL);
        Test.stopTest();

        System.assert(wrapper.isDuplicateAppTracking);
    }

    @IsTest
    private static void searchExistingEmployeeNegativeDuplicatesTest() {

        Test.startTest();
        TB_CT_SearchExistingEmployeeController.DuplicateWrapper wrapper = TB_CT_SearchExistingEmployeeController.checkDuplicates('test@test.test','90090912334');
        Test.stopTest();

        System.assert(!wrapper.isDuplicateAppTracking);
        System.assert(!wrapper.isDuplicateContact);
    }

    @IsTest
    private static void searchExistingEmployeeFetchContactsTest() {

        Test.startTest();
        List<Contact> contacts = TB_CT_SearchExistingEmployeeController.fetchContacts();
        Test.stopTest();

        System.assertEquals(NUMBER_OF_RECORDS, contacts.size());
    }

    @IsTest
    private static void searchContactsNonEmptyListTest() {
        List<Contact> contacts = [SELECT Id FROM Contact];
        String searchTerm = 'Test';
        Id [] fixedSearchResults = new Id[contacts.size()];
        Integer counter = 0;
        for(Contact c : contacts) {
            fixedSearchResults[counter] = c.Id;
            counter++;
        }
        Test.setFixedSearchResults(fixedSearchResults);

        Test.startTest();
        List<LookupSearchResult> results = TB_CT_SearchExistingEmployeeController.searchContacts(searchTerm);
        Test.stopTest();

        Assert.areEqual(NUMBER_OF_RECORDS, results.size());
    }

    @IsTest
    private static void searchContactsEmptyListTest() {
        List<Contact> contacts = [SELECT Id FROM Contact];
        String searchTerm = 'Geralt';
        Id [] fixedSearchResults = new Id[contacts.size()];
        Integer counter = 0;
        for(Contact c : contacts) {
            fixedSearchResults[counter] = c.Id;
            counter++;
        }
        Test.setFixedSearchResults(fixedSearchResults);

        Test.startTest();
        List<LookupSearchResult> results = TB_CT_SearchExistingEmployeeController.searchContacts(searchTerm);
        Test.stopTest();

        Assert.areNotEqual(0, results.size());
    }

    @IsTest
    private static void searchExistingEmployeeFetchUniversityDepartmentsNotForSearchTest() {

        Test.startTest();
        List<Account> accounts = TB_CT_SearchExistingEmployeeController.fetchUniversityDepartments(false);
        Test.stopTest();

        System.assertEquals(1, accounts.size());
    }

    @IsTest
    private static void searchExistingEmployeeFetchUniversityDepartmentsForSearchTest() {
        System.runAs(TB_DataFactory.createUser(TB_Constants.PROFILE_NAME_ADMINISTRATOR, TB_Constants.ROLE_DEV_NAME_ADMIN, false)){
            Account department = [
                    SELECT Id
                    FROM Account
                    WHERE RecordType.DeveloperName
                            = :TB_Constants.TB_CT_RECORD_TYPE_UNI_DEPARTMENTS
            ];
            hed__Affiliation__c affiliation = new hed__Affiliation__c(hed__Account__c = department.Id);
            insert affiliation;
        }

        Test.startTest();
        List<Account> accounts = TB_CT_SearchExistingEmployeeController.fetchUniversityDepartments(true);
        Test.stopTest();

        System.assertEquals(1, accounts.size());
    }
}