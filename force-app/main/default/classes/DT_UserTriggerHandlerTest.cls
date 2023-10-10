@IsTest
private class DT_UserTriggerHandlerTest {
    private static final String CONTACT_USER_TEST_EMAIL = 'test_contact@devoteam.test123';
    private static final String TEST_ACCOUNT_NAME = 'Student Administrative Account';

    @TestSetup
    static void dataInit(){
        DT_DataFactory.createAdminUser();
    }

    @IsTest
    static void assignDeansOfficePermissionsTestScenario() {
        User adminUser = DT_TestClassUtils.getUserByEmail(DT_DataFactory.PERSONAL_DATA_TEST_ADMIN_EMAIL);
        User deansOfficeUser;
        Test.startTest();
        System.runAs(adminUser){
            deansOfficeUser = DT_DataFactory.createUsers(
                1,true, new User(
                    ProfileId = DT_Utils.getProfileIdByName(DT_Utils.SWPS_DEANS_OFFICE_EMPLOYEE_PROFILE_NAME)
                )
            ).get(0);
        }
        Test.stopTest();

        DT_UserTriggerHandler.fetchProfileAndPermissionUtils();

        Set<Id> assignedPermissions = DT_UserTriggerHandler.getMapUserIds2SetOfPermissionSetIds(
            new Set<Id>{deansOfficeUser.Id}
        ).get(deansOfficeUser.Id);

        /** Assignment to Permission Set Group is represented by assignment to
         *  Permission Set with the same Name (Developer Name) but has permission type Group*/
        System.assertEquals(true, assignedPermissions.contains(
            DT_Utils.getPermissionSetIdByName(DT_Utils.PERMISSION_SET_GROUP_NAME_DEANS_OFFICE)
        ));
    }

    @IsTest
    static void assignPostgraduateFacultyPermissionsTestScenario() {
        User adminUser = DT_TestClassUtils.getUserByEmail(DT_DataFactory.PERSONAL_DATA_TEST_ADMIN_EMAIL);
        Contact postgraduateFacultyContact;
        User postgraduateFacultyUser;

        System.runAs(adminUser) {
            Account account = DT_DataFactory.createAccounts(
                1, true, new Account(
                    Name = TEST_ACCOUNT_NAME,
                    RecordTypeId = DT_Utils.getRecTypeIdByDevName (
                        DT_Utils.ACCOUNT_ADMINISTRATIVE_RECORD_TYPE_NAME, DT_Utils.SOBJ_ACCOUNT
                    ),
                    DT_Account_Type__c = DT_Utils.ACCOUNT_TYPE_ADMINISTRATIVE
                )
            ).get(0);

            postgraduateFacultyContact = DT_DataFactory.createContacts(
                1, true, new Contact(
                    AccountId = account.Id,
                    Email = CONTACT_USER_TEST_EMAIL,
                    DT_Is_Postgraduate_Student__c = false,
                    DT_Is_Student__c = false,
                    DT_Is_Postgraduate_Faculty__c = true
                )
            ).get(0);
        }

        Test.startTest();
        System.runAs(adminUser){
            postgraduateFacultyUser = DT_DataFactory.createStudentUser(
                postgraduateFacultyContact.Email, postgraduateFacultyContact
            );
        }
        Test.stopTest();

        DT_UserTriggerHandler.fetchProfileAndPermissionUtils();

        Set<Id> assignedPermissions = DT_UserTriggerHandler.getMapUserIds2SetOfPermissionSetIds(
            new Set<Id>{postgraduateFacultyUser.Id}
        ).get(postgraduateFacultyUser.Id);

        /** Assignment to Permission Set Group is represented by assignment to
         *  Permission Set with the same Name (Developer Name) but has permission type Group*/
        System.assertEquals(true, assignedPermissions.contains(
            DT_Utils.getPermissionSetIdByName(DT_Utils.PERMISSION_SET_GROUP_NAME_STUDENT)
        ));
        System.assertEquals(true, assignedPermissions.contains(
            DT_UserTriggerHandler.apiNames2KnowledgePermissionSets.get(DT_Utils.PERMISSION_SET_NAME_KB_DC_KBL).Id
        ));
    }

    @IsTest
    static void assignHigherStudentPermissionsTestScenario() {

        User adminUser = DT_TestClassUtils.getUserByEmail(DT_DataFactory.PERSONAL_DATA_TEST_ADMIN_EMAIL);

        Contact studentContact;

        Account academicProgram;
        hed__Program_Plan__c programPlan;
        hed__Program_Enrollment__c programEnrollment;
        User studentUser;

        System.runAs(adminUser){

            studentContact = DT_DataFactory.createStudentContact(CONTACT_USER_TEST_EMAIL);

            /** Academic Program */
            academicProgram = DT_DataFactory.createTestAcademicProgram(
                true, null, null
            );

            /** Program Plan */
            programPlan = DT_DataFactory.createProgramPlans(
                1, true, new hed__Program_Plan__c(
                    hed__Account__c = academicProgram.Id
                )
            ).get(0);

            /** Program Enrollment */
            programEnrollment = DT_DataFactory.createProgramEnrollments(
                1, true, new hed__Program_Enrollment__c(
                    hed__Account__c = academicProgram.Id,
                    hed__Program_Plan__c = programPlan.Id,
                    hed__Contact__c = studentContact.Id
                )
            ).get(0);
        }

        Test.startTest();
            System.runAs(adminUser){
                studentUser = DT_DataFactory.createStudentUser(studentContact.Email, studentContact);
            }
        Test.stopTest();

        DT_UserTriggerHandler.fetchProfileAndPermissionUtils();

        Set<Id> assignedPermissions = DT_UserTriggerHandler.getMapUserIds2SetOfPermissionSetIds(
            new Set<Id>{studentUser.Id}
        ).get(studentUser.Id);

        /** Assignment to Permission Set Group is represented by assignment to
         *  Permission Set with the same Name (Developer Name) but has permission type Group*/
        System.assertEquals(true, assignedPermissions.contains(
            DT_Utils.getPermissionSetIdByName(DT_Utils.PERMISSION_SET_GROUP_NAME_STUDENT)
        ));
        System.assertEquals(true, assignedPermissions.contains(
            DT_UserTriggerHandler.apiNames2KnowledgePermissionSets.get(DT_Utils.PERMISSION_SET_NAME_KB_CAREER_OFFICE).Id
        ));
        System.assertEquals(true, assignedPermissions.contains(
            DT_UserTriggerHandler.apiNames2KnowledgePermissionSets.get(DT_Utils.PERMISSION_SET_NAME_KB_CSS_KATOWICE).Id
        ));
        System.assertEquals(true, assignedPermissions.contains(
            DT_UserTriggerHandler.apiNames2KnowledgePermissionSets.get(DT_Utils.PERMISSION_SET_NAME_KB_CSS_SWPS).Id
        ));
    }

    @IsTest
    static void assignPostgraduateStudentPermissionsTestScenario() {

        User adminUser = DT_TestClassUtils.getUserByEmail(DT_DataFactory.PERSONAL_DATA_TEST_ADMIN_EMAIL);

        Contact postgraduateStudentContact;

        List<Account> academicPrograms = new List<Account>();
        List<hed__Program_Plan__c> programPlans = new List<hed__Program_Plan__c>();
        List<hed__Program_Enrollment__c> programEnrollments = new List<hed__Program_Enrollment__c>();
        User postgraduateStudentUser;

        System.runAs(adminUser){
            Account account = DT_DataFactory.createAccounts(
                1, true, new Account(
                    Name = TEST_ACCOUNT_NAME,
                    RecordTypeId = DT_Utils.getRecTypeIdByDevName (
                        DT_Utils.ACCOUNT_ADMINISTRATIVE_RECORD_TYPE_NAME, DT_Utils.SOBJ_ACCOUNT
                    ),
                    DT_Account_Type__c = DT_Utils.ACCOUNT_TYPE_ADMINISTRATIVE
                )
            ).get(0);

            postgraduateStudentContact = DT_DataFactory.createContacts(
                1, true, new Contact(
                    AccountId = account.Id,
                    Email = CONTACT_USER_TEST_EMAIL,
                    DT_Is_Postgraduate_Student__c = true,
                    DT_Is_Student__c = false
                )
            ).get(0);

            /** Create Educational Institution, Campus and Department*/
            Account department = DT_DataFactory.createTestDepartment(true, null);

            /** Academic Program 1 */
            academicPrograms.add(
                DT_DataFactory.createAccounts(
                1, false, new Account(
                    Name = 'TestCourse, 3st, A, Ka',
                    DT_Profile__c = 'General academic',
                    DT_Level__c = DT_Utils.ACCOUNT_LEVEL_POSTGRADUATE,
                    DT_Study_Field_EN__c = 'TestEn',
                    DT_Study_Field_PL__c = 'TestPL',
                    DT_VDO_ID__c = '1000',
                    ParentId = department.Id,
                    DT_Polon_1_Code__c = '8000',
                    DT_Polon_2_Code__c = '1000',
                    DT_Creation_Date__c = Date.today().addDays(-300),
                    DT_Legal_Basis_Date__c = Date.today().addDays(-300),
                    DT_Fos_Status__c = 'Active',
                    RecordTypeId = DT_Utils.getRecTypeIdByDevName (
                        DT_Utils.ACCOUNT_ACADEMIC_PROGRAM_RECORD_TYPE_NAME, DT_Utils.SOBJ_ACCOUNT
                    ),
                    DT_Account_Type__c = DT_Utils.ACCOUNT_TYPE_ACADEMIC_PROGRAM
                )).get(0)
            );

            /** Academic Program 2 */
            academicPrograms.add(
                DT_DataFactory.createAccounts(
                    1, false, new Account(
                        Name = 'TestCourse2, 3st, A, Ka',
                        DT_Profile__c = 'General academic',
                        DT_Level__c = DT_Utils.ACCOUNT_LEVEL_POSTGRADUATE,
                        DT_Study_Field_EN__c = 'TestEn2',
                        DT_Study_Field_PL__c = 'TestPL2',
                        DT_VDO_ID__c = '2000',
                        ParentId = department.Id,
                        DT_Polon_1_Code__c = '7000',
                        DT_Polon_2_Code__c = '2000',
                        DT_Creation_Date__c = Date.today().addDays(-300),
                        DT_Legal_Basis_Date__c = Date.today().addDays(-300),
                        DT_Fos_Status__c = 'Active',
                        RecordTypeId = DT_Utils.getRecTypeIdByDevName (
                            DT_Utils.ACCOUNT_ACADEMIC_PROGRAM_RECORD_TYPE_NAME, DT_Utils.SOBJ_ACCOUNT
                        ),
                        DT_Account_Type__c = DT_Utils.ACCOUNT_TYPE_ACADEMIC_PROGRAM
                    )).get(0)
            );

            insert academicPrograms;

            /** Program Plan 1 */
            programPlans.add(
                DT_DataFactory.createProgramPlans(
                    1, false, new hed__Program_Plan__c(
                        hed__Account__c = academicPrograms.get(0).Id,
                        Name = 'Test-Program1',
                        DT_VDO_ID__c = '180'
                    )
                ).get(0)
            );

            /** Program Plan 2 */
            programPlans.add(
                DT_DataFactory.createProgramPlans(
                    1, false, new hed__Program_Plan__c(
                        hed__Account__c = academicPrograms.get(1).Id,
                        DT_Product_Code__c = 'K-128-0-5-N-91', // KBC product code,
                        Name = 'Test-Program2',
                        DT_VDO_ID__c = '200'
                    )
                ).get(0)
            );

            insert programPlans;

            /** Program Enrollment 1 */
            programEnrollments.add(
                DT_DataFactory.createProgramEnrollments(
                    1, false, new hed__Program_Enrollment__c(
                        hed__Account__c = academicPrograms.get(0).Id,
                        hed__Program_Plan__c = programPlans.get(0).Id,
                        hed__Contact__c = postgraduateStudentContact.Id,
                        DT_Level_Of_Studies__c = DT_Utils.PROGRAM_ENROLMENT_LEVEL_OF_STUDIES_POSTGRADUATE,
                        DT_VDO_ID__c = '1'
                    )
                ).get(0)
            );

            /** Program Enrollment 2 */
            programEnrollments.add(
                DT_DataFactory.createProgramEnrollments(
                    1, false, new hed__Program_Enrollment__c(
                        hed__Account__c = academicPrograms.get(1).Id,
                        hed__Program_Plan__c = programPlans.get(1).Id,
                        hed__Contact__c = postgraduateStudentContact.Id,
                        DT_Level_Of_Studies__c = DT_Utils.PROGRAM_ENROLMENT_LEVEL_OF_STUDIES_POSTGRADUATE,
                        DT_VDO_ID__c = '2'
                    )
                ).get(0)
            );

            insert programEnrollments;
        }

        Test.startTest();
        System.runAs(adminUser){
            postgraduateStudentUser = DT_DataFactory.createStudentUser(
                postgraduateStudentContact.Email, postgraduateStudentContact
            );
        }
        Test.stopTest();

        DT_UserTriggerHandler.fetchProfileAndPermissionUtils();

        Set<Id> assignedPermissions = DT_UserTriggerHandler.getMapUserIds2SetOfPermissionSetIds(
            new Set<Id>{postgraduateStudentUser.Id}
        ).get(postgraduateStudentUser.Id);


        /** Assignment to Permission Set Group is represented by assignment to
         *  Permission Set with the same Name (Developer Name) but has permission type Group*/
        System.assertEquals(true, assignedPermissions.contains(
            DT_Utils.getPermissionSetIdByName(DT_Utils.PERMISSION_SET_GROUP_NAME_STUDENT)
        ));
        System.assertEquals(true, assignedPermissions.contains(
            DT_UserTriggerHandler.apiNames2KnowledgePermissionSets.get(DT_Utils.PERMISSION_SET_NAME_KB_DC_KBC).Id
        ));
        System.assertEquals(true, assignedPermissions.contains(
            DT_UserTriggerHandler.apiNames2KnowledgePermissionSets.get(DT_Utils.PERMISSION_SET_NAME_KB_DC_KBS).Id
        ));
    }

    @IsTest
    static void processApplicantsOnProfileChange() {

        User adminUser = DT_TestClassUtils.getUserByEmail(DT_DataFactory.PERSONAL_DATA_TEST_ADMIN_EMAIL);

        Contact studentContact;

        Account academicProgram;
        hed__Program_Plan__c programPlan;
        hed__Program_Enrollment__c programEnrollment;
        User studentUser;

        System.runAs(adminUser){

            studentContact = DT_DataFactory.createStudentContact(CONTACT_USER_TEST_EMAIL);

            /** Academic Program */
            academicProgram = DT_DataFactory.createTestAcademicProgram(
                true, null, null
            );

            /** Program Plan */
            programPlan = DT_DataFactory.createProgramPlans(
                1, true, new hed__Program_Plan__c(
                    hed__Account__c = academicProgram.Id
                )
            ).get(0);

            /** Program Enrollment */
            programEnrollment = DT_DataFactory.createProgramEnrollments(
                1, true, new hed__Program_Enrollment__c(
                    hed__Account__c = academicProgram.Id,
                    hed__Program_Plan__c = programPlan.Id,
                    hed__Contact__c = studentContact.Id
                )
            ).get(0);
        }

        System.runAs(adminUser){
            studentUser = DT_DataFactory.createApplicantUser(studentContact.Email, studentContact);
        }

        Test.startTest();
        studentUser.ProfileId = DT_Utils.getProfileIdByName(DT_Utils.SWPS_STUDENT_PROFILE_NAME);
        update studentUser;
        Test.stopTest();

        DT_UserTriggerHandler.fetchProfileAndPermissionUtils();

        Set<Id> assignedPermissions = DT_UserTriggerHandler.getMapUserIds2SetOfPermissionSetIds(
            new Set<Id>{studentUser.Id}
        ).get(studentUser.Id);

        /** Assignment to Permission Set Group is represented by assignment to
         *  Permission Set with the same Name (Developer Name) but has permission type Group*/
        System.assertEquals(true, assignedPermissions.contains(
            DT_Utils.getPermissionSetIdByName(DT_Utils.PERMISSION_SET_GROUP_NAME_STUDENT)
        ));
        System.assertEquals(true, assignedPermissions.contains(
            DT_UserTriggerHandler.apiNames2KnowledgePermissionSets.get(DT_Utils.PERMISSION_SET_NAME_KB_CAREER_OFFICE).Id
        ));
        System.assertEquals(true, assignedPermissions.contains(
            DT_UserTriggerHandler.apiNames2KnowledgePermissionSets.get(DT_Utils.PERMISSION_SET_NAME_KB_CSS_KATOWICE).Id
        ));
        System.assertEquals(true, assignedPermissions.contains(
            DT_UserTriggerHandler.apiNames2KnowledgePermissionSets.get(DT_Utils.PERMISSION_SET_NAME_KB_CSS_SWPS).Id
        ));
    }
}