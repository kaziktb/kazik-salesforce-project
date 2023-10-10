@IsTest
private class TB_CT_UserInfoTest {
    private static final String PROFILE_NAME_EMPLOYEE = 'SWPS Dean\'s Office Employee';
    private static final String PROFILE_NAME_DIDACTIC = 'SWPS Employee Community User';
    private static final String PERM_SET_COORDINATOR = 'TB_SWPS_Contract_Teachers_Coordinator';
    private static final String PERM_SET_DECISION_MAKER = 'TB_SWPS_Contract_Teachers_Decision_Maker';

    @TestSetup
    private static void setupMethod() {
        System.runAs(TB_DataFactory.createUser(TB_Constants.PROFILE_NAME_ADMINISTRATOR, TB_Constants.ROLE_DEV_NAME_ADMIN, false)) {
            UserRole portalRole = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
            Profile profileAdmin = [SELECT Id FROM Profile WHERE Name =: TB_Constants.PROFILE_NAME_ADMINISTRATOR LIMIT 1];

            User portalOwner = new User(
                    UserRoleId = portalRole.Id,
                    ProfileId = profileAdmin.Id,
                    Username = System.now().millisecond() + 'bruce.wayne@wayneenterprises.com',
                    Alias = 'batman',
                    Email = 'bruce.wayne@wayneenterprises.com',
                    EmailEncodingKey = 'UTF-8',
                    FirstName = 'Bruce',
                    LastName = 'Wayne',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    TimeZoneSidKey = 'America/Chicago'
            );
            insert portalOwner;

            Account didacticAccount = new Account(
                    Name = 'Henry',
                    OwnerId = portalOwner.Id
            );

            insert didacticAccount;

            Contact didacticContact = new Contact(
                    FirstName = 'Henry',
                    LastName = 'Cavill',
                    AccountId = didacticAccount.Id
            );

            insert didacticContact;

            User employeeCoordinator = new User(
                    ProfileId = [SELECT Id FROM Profile WHERE Name = :PROFILE_NAME_EMPLOYEE].Id,
                    LastName = 'employeeCoordinator',
                    Email = 'jack.sparrow@arrr.com',
                    Username = System.now().millisecond() + 'jack.sparrow@arrr.com',
                    Alias = 'Jacky',
                    TimeZoneSidKey = 'America/Los_Angeles',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US'
            );

            User employeeDecisionMaker = new User(
                    ProfileId = [SELECT Id FROM Profile WHERE Name = :PROFILE_NAME_EMPLOYEE].Id,
                    LastName = 'employeeDecisionMaker',
                    Email = 'louis@vuitton.fr',
                    Username = System.now().millisecond() + 'louis@vuitton.fr',
                    Alias = 'Louis',
                    TimeZoneSidKey = 'America/Los_Angeles',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US'
            );

            User didactic = new User(
                    ProfileId = [SELECT Id FROM Profile WHERE Name = :PROFILE_NAME_DIDACTIC].Id,
                    LastName = 'didactic',
                    Email = 'henry.cavill@witcher.com',
                    Username = 'henry.cavill@witcher.com' + System.currentTimeMillis(),
                    Alias = 'Geralt',
                    TimeZoneSidKey = 'America/Los_Angeles',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    ContactId = didacticContact.Id
            );

            insert new List<User>{employeeCoordinator, employeeDecisionMaker, didactic};

            Id coordinatorPermSetId = [SELECT Id FROM PermissionSet WHERE Name = :PERM_SET_COORDINATOR].Id;
            Id decisionMakerPermSetId = [SELECT Id FROM PermissionSet WHERE Name = :PERM_SET_DECISION_MAKER].Id;

            PermissionSetAssignment coordinatorPermSetAssignment = new PermissionSetAssignment(AssigneeId = employeeCoordinator.Id, PermissionSetId = coordinatorPermSetId);
            PermissionSetAssignment decisionMakerPermSetAssignment = new PermissionSetAssignment(AssigneeId = employeeDecisionMaker.Id, PermissionSetId = decisionMakerPermSetId);

            insert new List<PermissionSetAssignment>{coordinatorPermSetAssignment, decisionMakerPermSetAssignment};
        }
    }

    @IsTest
    static void getLicenseNameForEmployeeTest() {
        User employee = [SELECT Id FROM User WHERE LastName = 'employeeCoordinator' LIMIT 1];
        String licenseName;

        System.runAs(employee) {
            Test.startTest();
            licenseName = TB_CT_UserInfo.getUserProfileLicenseName();
            Test.stopTest();
        }

        Assert.isFalse(licenseName.contains('Customer Community Plus Login'), 'License for this user should not be \'Customer Community Plus Login\'');
    }

    @IsTest
    static void getLicenseNameForDidacticTest() {
        User didactic = [SELECT Id FROM User WHERE LastName = 'didactic' LIMIT 1];
        String licenseName;

        System.runAs(didactic) {
            Test.startTest();
            licenseName = TB_CT_UserInfo.getUserProfileLicenseName();
            Test.stopTest();
        }

        Assert.areEqual('Customer Community Plus Login', licenseName, 'License for this user should be \'Customer Community Plus Login\'');
    }

    @IsTest
    static void checkIfCoordinatorHasPermSet() {
        User employee = [SELECT Id FROM User WHERE LastName = 'employeeCoordinator' LIMIT 1];

        Test.startTest();
        TB_CT_UserInfo.UserPermissionSets userPermissionSets = TB_CT_UserInfo.getUserPermissionSets(employee.Id);
        Test.stopTest();

        Assert.isTrue(userPermissionSets.hasPermSetCoordinator);
        Assert.isFalse(userPermissionSets.hasPermSetDecisionMaker);
        Assert.isFalse(userPermissionSets.hasPermSetApplicantDidactic);
    }

    @IsTest
    static void checkIfDecisionMakerHasPermSet() {
        User employee = [SELECT Id FROM User WHERE LastName = 'employeeDecisionMaker' LIMIT 1];

        Test.startTest();
        TB_CT_UserInfo.UserPermissionSets userPermissionSets = TB_CT_UserInfo.getUserPermissionSets(employee.Id);
        Test.stopTest();

        Assert.isFalse(userPermissionSets.hasPermSetCoordinator);
        Assert.isTrue(userPermissionSets.hasPermSetDecisionMaker);
        Assert.isFalse(userPermissionSets.hasPermSetApplicantDidactic);
    }

    @IsTest
    static void checkIfApplicantHasPermSet() {
        User didactic = [SELECT Id FROM User WHERE LastName = 'didactic' LIMIT 1];

        Test.startTest();
        TB_CT_UserInfo.UserPermissionSets userPermissionSets = TB_CT_UserInfo.getUserPermissionSets(didactic.Id);
        Test.stopTest();

        Assert.isFalse(userPermissionSets.hasPermSetCoordinator);
        Assert.isFalse(userPermissionSets.hasPermSetDecisionMaker);
        Assert.isTrue(userPermissionSets.hasPermSetApplicantDidactic);
    }

    @IsTest
    static void checkUserPermissionSetsConstructor() {

        Test.startTest();
        TB_CT_UserInfo.UserPermissionSets userPermissionSets = new TB_CT_UserInfo.UserPermissionSets(true, false, true);
        Test.stopTest();

        Assert.isTrue(userPermissionSets.hasPermSetApplicantDidactic);
        Assert.isFalse(userPermissionSets.hasPermSetCoordinator);
        Assert.isTrue(userPermissionSets.hasPermSetDecisionMaker);
    }
}