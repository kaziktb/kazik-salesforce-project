@IsTest
private class TB_vu_UserInfoTest {
    private static final String PROFILE_NAME_EMPLOYEE = 'SWPS Dean\'s Office Employee';
    private static final String PROFILE_NAME_DIDACTIC = 'SWPS Contract Teachers';

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

            User employee = new User(
                    ProfileId = [SELECT Id FROM Profile WHERE Name = :PROFILE_NAME_EMPLOYEE].Id,
                    LastName = 'employee',
                    Email = 'jack.sparrow@arrr.com',
                    Username = System.now().millisecond() + 'jack.sparrow@arrr.com',
                    Alias = 'Jacky',
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

            insert new List<User>{employee, didactic};
        }
    }

    @IsTest
    static void getLicenseNameForEmployeeTest() {
        User employee = [SELECT Id FROM User WHERE LastName = 'employee' LIMIT 1];
        String licenseName;

        System.runAs(employee) {
            Test.startTest();
            licenseName = TB_vu_UserInfo.getUserProfileLicenseName();
            Test.stopTest();
        }

        Assert.isFalse(licenseName.contains('Customer Community Login'), 'License for this user should not be \'Customer Community Login\'');
    }

    @IsTest
    static void getLicenseNameForDidacticTest() {
        User didactic = [SELECT Id FROM User WHERE LastName = 'didactic' LIMIT 1];
        String licenseName;

        System.runAs(didactic) {
            Test.startTest();
            licenseName = TB_vu_UserInfo.getUserProfileLicenseName();
            Test.stopTest();
        }

        Assert.areEqual('Customer Community Login', licenseName, 'License for this user should be \'Customer Community Login\'');
    }
}