@IsTest
private class TB_vu_ActiveOrganisTableControllerTest {
    private static final String LANGUAGE_PL = 'PL';
    private static final Integer NUMBER_OF_ACCOUNTS = 20;
    private static final Integer NUMBER_OF_UNIVERSITY_DEPARTMENT_ACCOUNTS = 2;
    private static final Integer PREDEFINED_LIMIT = 10;

    @TestSetup
    static void testSetup() {
        Test.startTest();
        List<Account> accs = TB_TestDataFactory.createAccounts(
            NUMBER_OF_ACCOUNTS,
            TB_Constants.STUDENTS_ORGANIZATION_REC_TYPE_ID,
            false
        );
        List<Account> univDepartmentAccs = TB_TestDataFactory.createAccounts(
            NUMBER_OF_UNIVERSITY_DEPARTMENT_ACCOUNTS,
            TB_Constants.UNIVERSITY_DEPARTMENT_REC_TYPE_ID,
            false
        );
        for(Account a : univDepartmentAccs)
        {
            a.Type = TB_Constants.FACULTY_VALUE;
            a.Name = 'Wydział ' + a.Name;
            a.BillingCity = 'Warszawa';
        }
        accs.addAll(univDepartmentAccs);
        for (Account a : accs) {
            a.TB_Status__c = TB_Constants.ACTIVE_STATUS;
        }
        insert accs;
        Test.stopTest();
    }

    @IsTest
    static void shouldReturnPredefinedNumberOfAccountRecords() {
        // given
        // when
        Test.startTest();
        List<TB_vu_ActiveOrganisTableController.ActiveOrganisationsAccountWrapper> accs = TB_vu_ActiveOrganisTableController.getAccounts(
            PREDEFINED_LIMIT,
            0,
            null,
            LANGUAGE_PL
        );
        Test.stopTest();

        // then
        System.assertEquals(PREDEFINED_LIMIT, accs.size(), 'Query should return predefined number of account records');
    }

    @IsTest
    static void shouldReturnFacultyAccounts() {
        // given
        Account facultyAcc = [SELECT Id FROM Account WHERE Type = :TB_Constants.FACULTY_VALUE LIMIT 1];
        Account studentOrgAcc = [
            SELECT Id
            FROM Account
            WHERE RecordTypeId = :TB_Constants.STUDENTS_ORGANIZATION_REC_TYPE_ID
            LIMIT 1
        ];
        studentOrgAcc.ParentId = facultyAcc.Id;
        studentOrgAcc.TB_Organisation_Type__c = 'Scientific_Organisation';
        update new List<Account>{ facultyAcc, studentOrgAcc };

        TB_vu_ActiveOrganisTableController.FilterValues fvFaculty = new TB_vu_ActiveOrganisTableController.FilterValues();
        fvFaculty.value = '';
        fvFaculty.type = TB_Constants.FACULTY_VALUE;
        fvFaculty.recId = facultyAcc.Id;
        TB_vu_ActiveOrganisTableController.FilterValues fvType = new TB_vu_ActiveOrganisTableController.FilterValues();
        fvType.value = 'Scientific_Organisation';
        fvType.type = TB_Constants.TYPE_VALUE;
        fvType.recId = '';
        TB_vu_ActiveOrganisTableController.FilterValues fvCampus = new TB_vu_ActiveOrganisTableController.FilterValues();
        fvCampus.value = 'Warszawa';
        fvCampus.type = TB_Constants.CAMPUS_VALUE;
        fvCampus.recId = '';

        // when
        Test.startTest();
        List<TB_vu_ActiveOrganisTableController.ActiveOrganisationsAccountWrapper> accs = TB_vu_ActiveOrganisTableController.getAccounts(
            PREDEFINED_LIMIT,
            0,
            new List<TB_vu_ActiveOrganisTableController.FilterValues>{ fvFaculty, fvType, fvCampus },
            LANGUAGE_PL
        );
        Test.stopTest();

        // then
        System.assertEquals(1, accs.size(), 'Query should return one Faculty account');
        System.assertEquals(
            studentOrgAcc.Id,
            accs[0].Id,
            'Query should return student organisation acc related to specified campus'
        );
    }

    @IsTest
    static void shouldReturnUniversityDepartmentAccounts() {
        // given

        // when
        Test.startTest();
        List<Account> accs = TB_vu_ActiveOrganisTableController.getFilterValues();
        Test.stopTest();

        // then
        System.assertEquals(2, accs.size(), 'Query should return 2 university department accounts');
    }
}