@IsTest
public with sharing class TB_UserTriggerHandlerTest {
    private static final String PROFILE_CONTRACT_TEACHERS = 'SWPS Employee Community User';
    private static final String PROFILE_CT_DEANS_OFFICE = 'SWPS Dean\'s Office Employee';
    private final static String PERMISSION_SET_CT_APPLICANT = 'TB_SWPS_Contract_Teachers_Applicant_Didactic';

    @TestSetup
    static void makeData(){
        System.runAs(TB_DataFactory.createUser(TB_Constants.PROFILE_NAME_ADMINISTRATOR, TB_Constants.ROLE_DEV_NAME_ADMIN, false)){
            Contact ctContact = new Contact(LastName = 'CT');
            insert ctContact;

            User ctUser = TB_DataFactory.createUser(PROFILE_CONTRACT_TEACHERS, false);
            ctUser.FirstName = 'UserTrigger';
            ctUser.LastName = 'Test';
            ctUser.ContactId = ctContact.Id;
            insert ctUser;

            User ctDeansUser = TB_DataFactory.createUser(PROFILE_CT_DEANS_OFFICE, false);
            ctDeansUser.FirstName = 'UserTriggerDifferentProfile';
            ctDeansUser.LastName = 'TestDifferent';
            insert ctDeansUser;
        }
    }

    @IsTest
    private static void assignPermissionSetTest(){
        Contact contactCT = [SELECT Id FROM Contact WHERE LastName = 'CT' LIMIT 1];
        User userCT = [SELECT Id FROM User WHERE ContactId =:contactCT.Id];
        User userCTDean = [SELECT Id FROM User WHERE FirstName = 'UserTriggerDifferentProfile' LIMIT 1];

        Test.startTest();
        List<PermissionSetAssignment> psa = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =:userCT.Id];
        List<PermissionSetAssignment> psa2 = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =:userCTDean.Id AND PermissionSet.Name =:PERMISSION_SET_CT_APPLICANT];
        Test.stopTest();

        Assert.areNotEqual(null, psa, 'No permission set assignment found');
        Assert.isTrue(psa2.isEmpty());
    }
}