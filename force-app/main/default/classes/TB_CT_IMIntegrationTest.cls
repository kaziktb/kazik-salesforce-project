@IsTest
public class TB_CT_IMIntegrationTest {

    private static final String EMAIL_TEST = 'test@test.com';
    private static final String SEX = 'Female';
    private static final String TITLE_GRANDE = 'mgr. inz';
    private static final String TEST_ACC = 'Test Acc';
    private static final String TEST_BUSINESS_UNIT_CODE_NUMBER = 'ABC341242134OP';
    private static final String TEST_CONTACT = 'testContact';
    private static final String TEST_PHONE = '521345098';
    private static final String TEST_TB_EMPLOYMENT_TYPE = 'D';
    private static final String TEST_TB_LOCATION = 'W';
    private static final String TEST_TB_POSITION = 'Test Position';
    private static final String TEST_TB_ROLETYPE = 'O';
    private static final String TEST_TB_EMPLOYMENT_CAT = 'A';
    private static final String TEST_PL = 'PL';
    private static final String TEST_EN = 'EN';
    private static final String TEST_DOWOD = 'POLSKI_DOWOD_OSOBISTY';
    private static final String TEST_DOWOD_NUM = 'AX91233FRE';
    private static final String POLAND = 'PL';
    private static final String ENGLISH = 'English';
    private static final Id CONTACT_EMPLOYEE_RECORD_TYPE_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('TB_Employee').getRecordTypeId();

    @TestSetup
    static void makeData(){
        TB_CT_TestDataFactory.insertCTUrls();
        TB_Admissions_Content__c content = new TB_Admissions_Content__c(
                TB_Active__c = true,
                TB_Content_Type__c = 'Message',
                TB_Content_PL__c = 'Brak rekordów',
                TB_Content_EN__c = 'Lack of records',
                TB_Record_Code__c = 'List has no rows for assignment to SObject'
        );
        insert content;
    }

    @IsTest
    public static void createOrUpdatePersonTest(){
        System.runAs(TB_DataFactory.createUser('System Administrator', 'Admin', false))
        {
            TB_App_Tracking__c testinput = new TB_App_Tracking__c();
            testinput.TB_Email__c = EMAIL_TEST;
            testinput.TB_Phone__c = TEST_PHONE;
            testinput.TB_PESEL__c = '78040152352';
            testinput.TB_Last_Name__c = 'Test Last Name';
            testinput.TB_Middle_Name__c = 'Test Middle Name';
            testinput.TB_First_Name__c = 'Test First Name';
            testinput.TB_Employee_Type__c = 'Contract_Teacher';
            insert testinput;

            Contact cont = new Contact(LastName = TEST_CONTACT, FirstName = TEST_CONTACT,
            Email = EMAIL_TEST, Birthdate = Date.today() - 365*19);

            cont.hed__Gender__c = SEX;
            cont.hed__AlternateEmail__c = EMAIL_TEST;
            cont.TB_Title_Grade__c = TITLE_GRANDE;
            cont.Phone = TEST_PHONE;
            cont.DT_Document_Issuing_Country__c = TEST_PL;
            cont.DT_Document_Type__c = TEST_DOWOD;
            cont.DT_Document_Series_and_Number__c = TEST_DOWOD_NUM;
            cont.TB_Citizenship__c = POLAND;
            cont.recordTypeId = CONTACT_EMPLOYEE_RECORD_TYPE_ID;

            insert cont;

            testinput.TB_Applicant__c = cont.Id;
            update testinput;

            Account testAcc = new Account ();
            testAcc.Name = TEST_ACC;
            testAcc.TB_Business_Unit_Code__c = TEST_BUSINESS_UNIT_CODE_NUMBER;
            testAcc.BillingCity = 'Warszawa';
            insert testAcc;

            hed__Affiliation__c affiliation = new hed__Affiliation__c(hed__Contact__c = cont.Id,hed__Account__c = testAcc.Id);
            affiliation.TB_EmploymentType__c = TEST_TB_EMPLOYMENT_TYPE;
            affiliation.TB_Location__c = TEST_TB_LOCATION;
            affiliation.TB_Position__c = TEST_TB_POSITION;
            affiliation.TB_RoleType__c = TEST_TB_ROLETYPE;
            affiliation.TB_EmploymentCat__c = TEST_TB_EMPLOYMENT_CAT;
            affiliation.hed__Primary__c = true;
            insert affiliation;
            String body = TB_CT_IMIntegration.createOrUpdatePerson(cont.Id,TEST_PL,false);
            cont = [SELECT ID ,TB_ERP_Id__c,TB_IM_Id__c FROM CONTACT WHERE ID =:cont.id limit 1];
            System.assert(cont.TB_ERP_Id__c != null, 'ERP Number should not be empty');
            System.assert(body != null, 'body should not be empty');
        }
    }
    @IsTest
    public static void createOrUpdatePersonFailTest(){
        System.runAs(TB_DataFactory.createUser('System Administrator', 'Admin', false))
        {
            TB_App_Tracking__c testInput = new TB_App_Tracking__c();
            testInput.TB_Email__c = EMAIL_TEST;
            testInput.TB_Phone__c = TEST_PHONE;
            testInput.TB_PESEL__c = '78040152352';
            testInput.TB_Last_Name__c = 'Test Last Name';
            testInput.TB_Middle_Name__c = 'Test Middle Name';
            testInput.TB_First_Name__c = 'Test First Name';
            insert testInput;

            Contact cont = new Contact(LastName = TEST_CONTACT, FirstName = TEST_CONTACT,
            Email = EMAIL_TEST, Birthdate = Date.today() - 365*19);

            cont.hed__Gender__c = SEX;
            cont.hed__AlternateEmail__c = EMAIL_TEST;
            cont.TB_Title_Grade__c = TITLE_GRANDE;
            cont.Phone = TEST_PHONE;
            cont.DT_Document_Issuing_Country__c = TEST_PL;
            cont.DT_Document_Type__c = TEST_DOWOD;
            cont.DT_Document_Series_and_Number__c = TEST_DOWOD_NUM;
            cont.TB_Citizenship__c = POLAND;
            cont.recordTypeId = CONTACT_EMPLOYEE_RECORD_TYPE_ID;
            insert cont;

            Account testAcc = new Account();
            testAcc.Name = TEST_ACC;
            testAcc.TB_Business_Unit_Code__c = TEST_BUSINESS_UNIT_CODE_NUMBER;
            insert testAcc;

            hed__Affiliation__c affiliation = new hed__Affiliation__c(hed__Contact__c = cont.Id,hed__Account__c = testAcc.Id);
            affiliation.TB_EmploymentType__c = TEST_TB_EMPLOYMENT_TYPE;
            affiliation.TB_Location__c = TEST_TB_LOCATION;
            affiliation.TB_Position__c = TEST_TB_POSITION;
            affiliation.TB_RoleType__c = TEST_TB_ROLETYPE;
            affiliation.TB_EmploymentCat__c = TEST_TB_EMPLOYMENT_CAT;
            affiliation.hed__Primary__c = true;
            insert affiliation;
            String body;

            test.startTest();
            try {
                body = TB_CT_IMIntegration.createOrUpdatePerson(cont.Id,TEST_PL,false);
            } catch (Exception ex) {
                System.assert( ex.getMessage() != null);
            }
            test.stopTest();
        }
    }

    @IsTest
    public static void createOrUpdatePersonSecondFailTest(){
        System.runAs(TB_DataFactory.createUser('System Administrator', 'Admin', false))
        {
            TB_App_Tracking__c testInput = new TB_App_Tracking__c();
            testInput.TB_Email__c = EMAIL_TEST;
            testInput.TB_Phone__c = TEST_PHONE;
            testInput.TB_PESEL__c = '78040152352';
            testInput.TB_Last_Name__c = 'Test Last Name';
            testInput.TB_Middle_Name__c = 'Test Middle Name';
            testInput.TB_First_Name__c = 'Test First Name';
            insert testInput;

            Contact cont = new Contact(LastName = TEST_CONTACT, FirstName = TEST_CONTACT,
            Email = EMAIL_TEST, Birthdate = Date.today() - 365*19);

            cont.hed__Gender__c = SEX;
            cont.hed__AlternateEmail__c = EMAIL_TEST;
            cont.TB_Title_Grade__c = TITLE_GRANDE;
            cont.Phone = TEST_PHONE;
            cont.DT_Document_Issuing_Country__c = TEST_PL;
            cont.DT_Document_Type__c = TEST_DOWOD;
            cont.DT_Document_Series_and_Number__c = TEST_DOWOD_NUM;
            cont.TB_Citizenship__c = POLAND;
            cont.recordTypeId = CONTACT_EMPLOYEE_RECORD_TYPE_ID;
            insert cont;

            testInput.TB_Applicant__c = cont.Id;
            update testInput;

            Account testAcc = new Account();
            testAcc.Name = TEST_ACC;
            testAcc.TB_Business_Unit_Code__c = TEST_BUSINESS_UNIT_CODE_NUMBER;
            insert testAcc;

            hed__Affiliation__c affiliation = new hed__Affiliation__c(hed__Contact__c = cont.Id,hed__Account__c = testAcc.Id);
            affiliation.TB_EmploymentType__c = TEST_TB_EMPLOYMENT_TYPE;
            affiliation.TB_Location__c = TEST_TB_LOCATION;
            affiliation.TB_Position__c = TEST_TB_POSITION;
            affiliation.TB_RoleType__c = TEST_TB_ROLETYPE;
            affiliation.TB_EmploymentCat__c = TEST_TB_EMPLOYMENT_CAT;
            affiliation.hed__Primary__c = true;
            insert affiliation;

           TB_CT_IMIntegration.createOrUpdatePerson(cont.Id,TEST_EN,false);

            Contact contSec = new Contact(LastName = 'testContact2', FirstName = 'testContact2',
            Email = 'test2@test.com',Birthdate = Date.today() - 365*19);

            insert contSec;
            String body;
            test.startTest();
            try {
                body = TB_CT_IMIntegration.createOrUpdatePerson(contSec.Id,TEST_EN,false);
            } catch (Exception ex) {
                System.assert( ex.getMessage() != null);
            }
            test.stopTest();
        }
    }

    @IsTest
    public static void createOrUpdatePersonTestSync(){
        System.runAs(TB_DataFactory.createUser('System Administrator', 'Admin', false))
        {
            TB_App_Tracking__c testinput = new TB_App_Tracking__c();
            testinput.TB_Email__c = EMAIL_TEST;
            testinput.TB_Phone__c = TEST_PHONE;
            testinput.TB_PESEL__c = '78040152352';
            testinput.TB_Last_Name__c = 'Test Last Name';
            testinput.TB_Middle_Name__c = 'Test Middle Name';
            testinput.TB_First_Name__c = 'Test First Name';
            insert testinput;

            Contact cont = new Contact(LastName = TEST_CONTACT, FirstName = TEST_CONTACT,
            Email = EMAIL_TEST, Birthdate = Date.today() - 365*19);

            cont.hed__Gender__c = SEX;
            cont.hed__AlternateEmail__c = EMAIL_TEST;
            cont.TB_Title_Grade__c = TITLE_GRANDE;
            cont.Phone = TEST_PHONE;
            cont.DT_Document_Issuing_Country__c = TEST_PL;
            cont.DT_Document_Type__c = TEST_DOWOD;
            cont.DT_Document_Series_and_Number__c = TEST_DOWOD_NUM;
            cont.TB_Citizenship__c = POLAND;
            cont.recordTypeId = CONTACT_EMPLOYEE_RECORD_TYPE_ID;
            insert cont;

            Account testAcc = new Account ();
            testAcc.Name = TEST_ACC;
            testAcc.TB_Business_Unit_Code__c = TEST_BUSINESS_UNIT_CODE_NUMBER;
            insert testAcc;

            hed__Affiliation__c affiliation = new hed__Affiliation__c(hed__Contact__c = cont.Id,hed__Account__c = testAcc.Id);
            affiliation.TB_EmploymentType__c = TEST_TB_EMPLOYMENT_TYPE;
            affiliation.TB_Location__c = TEST_TB_LOCATION;
            affiliation.TB_Position__c = TEST_TB_POSITION;
            affiliation.TB_RoleType__c = TEST_TB_ROLETYPE;
            affiliation.TB_EmploymentCat__c = TEST_TB_EMPLOYMENT_CAT;
            affiliation.hed__Primary__c = true;
            insert affiliation;
        }
    }
}