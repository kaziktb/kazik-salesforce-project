@IsTest
private class TB_CT_ExperienceAuthenticationContTest {
    private static final String MOBILE_VAL = 'Mobile';
    private static final String EMAIL_ONE_VALUE = 'testtest@gmail.com';
    private static final String EMAIL_TWO_VALUE = 'testtest1@gmail.com';
    private static final String USER_SHOULD_BE_CREATED = 'User should be created there';
    private static final String CONTRACT_TEACHERS_PROFILE_NAME = 'SWPS Employee Community User';
    private static final Id EMPLOYEE_RECORD_TYPE_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('TB_Employee').getRecordTypeId();
    private static final Id ADMINISTRATIVE_ACCOUNT_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Administrative').getRecordTypeId();

    @TestSetup
    static void makeData(){

        System.runAs(TB_DataFactory.createUser(TB_Constants.PROFILE_NAME_ADMINISTRATOR, TB_Constants.ROLE_DEV_NAME_ADMIN, false)) {
            insert new TB_TC_URLs__c(TB_Admissions_Portal__c = TB_Constants.TB_CT_ADMISSIONS_PORTAL);

            TB_App_Tracking__c appTracking = new TB_App_Tracking__c(
                    TB_Email__c = EMAIL_ONE_VALUE,
                    TB_Phone__c = '809890890',
                    TB_PESEL__c = '78040152352',
                    TB_First_Name__c = 'Goha',
                    TB_Last_Name__c = 'Magical',
                    TB_Generated_Verification_Code_Valid_Dat__c = Date.today()
            );

            Account acc = new Account(
                    Name = 'Daniel Magical',
                    RecordTypeId = ADMINISTRATIVE_ACCOUNT_RECORD_TYPE_ID,
                    TB_Subtype__c = 'HE'
            );
            insert acc;

            Id profileId = [SELECT Id FROM Profile WHERE Name = :CONTRACT_TEACHERS_PROFILE_NAME LIMIT 1].Id;

            Contact cont = new Contact(
                    FirstName = 'Daniel',
                    LastName = 'Magical',
                    AccountId = acc.Id,
                    Email = EMAIL_ONE_VALUE,
                    hed__AlternateEmail__c = EMAIL_ONE_VALUE,
                    Phone = '12345678',
                    hed__PreferredPhone__c = MOBILE_VAL,
                    MobilePhone = '12345678',
                    TB_Didactic_Applicant_Counter_HE__c = 1,
                    RecordTypeId = EMPLOYEE_RECORD_TYPE_ID,
                    TB_Active__c = true
            );
            Contact cont1 = new Contact(
                    FirstName = 'Nikola',
                    LastName = 'Magical',
                    AccountId = acc.Id,
                    Email = EMAIL_TWO_VALUE,
                    hed__AlternateEmail__c = EMAIL_TWO_VALUE,
                    Phone = '123456781',
                    hed__PreferredPhone__c = MOBILE_VAL,
                    MobilePhone = '1234567812',
                    TB_Didactic_Applicant_Counter_HE__c = 1,
                    RecordTypeId = EMPLOYEE_RECORD_TYPE_ID,
                    TB_Active__c = true
            );
            insert new List<Contact> {cont, cont1};
            List<hed__Affiliation__c> affiliations = new List<hed__Affiliation__c>();
            for (Integer i = 0; i < 2; i++) {
            hed__Affiliation__c temp = new hed__Affiliation__c(
                    hed__Contact__c = cont.Id,
                    hed__Account__c = acc.Id,
                    hed__Role__c = 'Employee',
                    hed__Status__c = 'Current',
                    TB_Employee_Affiliation_Type__c = 'Applicant'
                    );
                    if(i == 1) {
                        temp.hed__Contact__c = cont1.Id;
                    }
                    affiliations.add(temp);
            }
            insert affiliations;
            User usr = new User(
                    ProfileId = profileId,
                    LastName = 'Magical',
                    Email = EMAIL_ONE_VALUE,
                    Username = EMAIL_ONE_VALUE + System.currentTimeMillis(),
                    CompanyName = 'TEST',
                    Title = 'teacher',
                    Alias = 'teacher',
                    TimeZoneSidKey = 'Europe/Prague',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'pl_PL',
                    TB_Verification_Code__c = '1231231230',
                    ContactId = cont.Id
            );
            User usr1 = new User(
                    ProfileId = profileId,
                    LastName = 'Magikal',
                    Email = EMAIL_TWO_VALUE,
                    Username = EMAIL_TWO_VALUE + System.currentTimeMillis(),
                    CompanyName = 'TEST1',
                    Title = 'teacher1',
                    Alias = 'teacher1',
                    TimeZoneSidKey = 'Europe/Prague',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'pl_PL',
                    IsActive = true,
                    TB_Verification_Code__c = '1231231239',
                    ContactId = cont1.Id
            );
            insert new List<User>{usr, usr1};

            cont.TB_User__c = usr.Id;
            cont1.TB_User__c = usr1.Id;
            update new List<Contact>{cont, cont1};

            TB_Admissions_Dictionary__c consentBundle = TB_TestDataFactory.createConsentBundle(false);
            insert consentBundle;

            insert TB_TestDataFactory.createConsent('Terms and Conditions',  consentBundle.Id, false);

            insert appTracking;
    }
}

    @IsTest
    private static void sendChangePasswordEmailTest(){
        String output;
        Boolean sendPassCheck = true;

        System.runAs(TB_DataFactory.createUser('System Administrator', 'Admin', false)){
            try {
                Test.startTest();
                output = TB_CT_ExperienceAuthenticationController.sendChangePasswordEmail(EMAIL_ONE_VALUE);
                Test.stopTest();
            } catch (Exception ex) {
                sendPassCheck = false;
            }

        }

        User createdUser = [SELECT Id FROM User WHERE Email = :EMAIL_ONE_VALUE LIMIT 1];
        TB_CT_ExperienceAuthenticationController.UserAuthenticationWrapper wrap =
                (TB_CT_ExperienceAuthenticationController.UserAuthenticationWrapper) JSON.deserialize(output, TB_CT_ExperienceAuthenticationController.UserAuthenticationWrapper.class);

        Assert.isTrue(sendPassCheck, 'No Error Should occur during Change password');
        Assert.isNotNull(createdUser, USER_SHOULD_BE_CREATED);
        Assert.isTrue(wrap.isSuccess, 'Change password should be successful');
    }

    @IsTest
    private static void resetPasswordTest(){
        User created_user = [SELECT Id, TB_Verification_Code__c FROM User WHERE Email = :EMAIL_TWO_VALUE LIMIT 1];
        String output;
        Boolean sendPassReset = true;

        System.runAs(TB_DataFactory.createUser('System Administrator', 'Admin', false)){
            try {
                Test.startTest();
                output = TB_CT_ExperienceAuthenticationController.resetPassword(created_user.TB_Verification_Code__c,'TESTPassword1231!');
                Test.stopTest();
            } catch (Exception ex) {
                sendPassReset = false;
            }

        }

        User createdUser = [SELECT Id FROM User WHERE Email = :EMAIL_TWO_VALUE LIMIT 1];
        TB_CT_ExperienceAuthenticationController.UserAuthenticationWrapper wrap =
                (TB_CT_ExperienceAuthenticationController.UserAuthenticationWrapper) JSON.deserialize(output, TB_CT_ExperienceAuthenticationController.UserAuthenticationWrapper.class);

        Assert.isTrue(sendPassReset, 'No Error Should occur during reset password');
        Assert.isNotNull(createdUser, USER_SHOULD_BE_CREATED);
        Assert.isTrue(wrap.isSuccess, 'Reset password should be successful');
    }



    @IsTest
    private static void doLoginTestNegative() {
        String output;

        Test.startTest();
        output = TB_CT_ExperienceAuthenticationController.doLogin('jacek.placek2@gmail.com', 'OBAMA');
        Test.stopTest();

        TB_CT_ExperienceAuthenticationController.UserAuthenticationWrapper wrap =
                (TB_CT_ExperienceAuthenticationController.UserAuthenticationWrapper) JSON.deserialize(output, TB_CT_ExperienceAuthenticationController.UserAuthenticationWrapper.class);

        Assert.isFalse(wrap.isSuccess, 'Login should be unsuccessful');
        Assert.areEqual(wrap.message, 'USER_VERIFICATION.USER_NOT_FOUND', 'Messages Should be equal');
    }

    @IsTest
    private static void doLoginTestPositive() {
        String output;
        TB_App_Tracking__c app = [
                SELECT TB_Generated_Password__c
                FROM TB_App_Tracking__c
                WHERE TB_Email__c = :EMAIL_ONE_VALUE
                LIMIT 1
        ];

        Test.startTest();
        output = TB_CT_ExperienceAuthenticationController.doLogin(EMAIL_ONE_VALUE, app.TB_Generated_Password__c);
        Test.stopTest();

        TB_CT_ExperienceAuthenticationController.UserAuthenticationWrapper wrap =
                (TB_CT_ExperienceAuthenticationController.UserAuthenticationWrapper) JSON.deserialize(output, TB_CT_ExperienceAuthenticationController.UserAuthenticationWrapper.class);

        Assert.isTrue(wrap.isSuccess, 'Login should be successful');
    }
}
