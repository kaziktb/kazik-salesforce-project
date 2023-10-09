/**
 * Created by aleksandragonta-kacperska on 22/04/2022.
 */
@IsTest
public with sharing class DT_SpecialtySearchControllerTest {
   /* private static final string SPECIALTY_NAME = 'Specjalnosc';
    private static final string SPECIALTY = 'Specialty';

    @TestSetup
    public static void setup() {
        User adminUser = DT_DataFactory.createAdminUser();
        User studentUser;

        System.runAs(adminUser) {
            studentUser = DT_DataFactory.createStudentUser();

            Account department = DT_DataFactory.createAccounts(1, true, new Account(
                    RecordTypeId = DT_Utils.getRecTypeIdByDevName(DT_Utils.ACCOUNT_UNIVERSITY_DEPARTMENT_RECORD_TYPE_NAME, DT_Utils.SOBJ_ACCOUNT),
                    DT_Account_Type__c = DT_Utils.ACCOUNT_TYPE_DEPARTMENT
            ))[0];

            Account academicProgram = DT_DataFactory.createAccounts(1, true, new Account(
                    RecordTypeId = DT_Utils.getRecTypeIdByDevName(DT_Utils.ACCOUNT_ACADEMIC_PROGRAM_RECORD_TYPE_NAME, DT_Utils.SOBJ_ACCOUNT),
                    DT_Account_Type__c = DT_Utils.ACCOUNT_TYPE_ACADEMIC_PROGRAM,
                    ParentId = department.Id
            ))[0];

            DT_DataFactory.createAccounts(
                    1, true, new Account(
                            RecordTypeId = DT_Utils.getRecTypeIdByDevName(DT_Utils.ACCOUNT_SPECIALTY_RECORD_TYPE_NAME, DT_Utils.SOBJ_ACCOUNT),
                            DT_Specialty_PL__c = SPECIALTY_NAME,
                            DT_Specialty_EN__c = SPECIALTY_NAME,
                            DT_Account_Type__c = SPECIALTY,
                            DT_Has_Active_Students__c = true,
                            ParentId = academicProgram.Id
                    )
            );

            Contact studentContact = [SELECT Id FROM Contact WHERE Id = :studentUser.ContactId];

            DT_DataFactory.createProgramEnrollments(1, true, new hed__Program_Enrollment__c(
                    hed__Contact__c = studentContact.Id,
                    hed__Account__c = academicProgram.Id
            ));
        }
    }


    @IsTest
    public static void testSpecialtyResultsByName() {
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        User studentUser = DT_TestClassUtils.getUserByEmail(DT_DataFactory.USER_STUDENT_EMAIL);

        Test.startTest();
        System.runAs(studentUser) {
            results = DT_SpecialtySearchController.getSpecialtyResultsByName(SPECIALTY_NAME);
        }
        Test.stopTest();

        System.assert(results.size() > 0);
    }*/
}