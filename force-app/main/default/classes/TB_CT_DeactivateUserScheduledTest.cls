@IsTest
public with sharing class TB_CT_DeactivateUserScheduledTest {  
    private static final Id ACCOUNT_REC_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Administrative').getRecordTypeId();
    private static final Id EMPLOYEE_RECORD_TYPE_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('TB_Employee').getRecordTypeId();
    private static final String FIRST_NAME = 'User';
    private static final String LAST_NAME = 'Test';
    private static final String MIDDLE_NAME = 'Schedule';
    private static final String PHONE = '809890890';
    private static final String PHONE_TWO = '809890590';
    private static final String PESEL = '78040152352';
    private static final String EMAIL = 'test@email.com';
    private static final String EMAIL_TWO = 'test2@email.com';
    private static final String EMAIL_THREE = 'test3@email.com';
    private static final String CRON_EXP = '0 02 15 05 APR ? 2045';

    @TestSetup
    static void makeData(){
        System.runAs(TB_DataFactory.createUser(TB_Constants.PROFILE_NAME_ADMINISTRATOR, TB_Constants.ROLE_DEV_NAME_ADMIN, false)){
        TB_App_Tracking__c testInput = new TB_App_Tracking__c();
            testInput.TB_Email__c = EMAIL;
            testInput.TB_Phone__c = PHONE;
            testInput.TB_PESEL__c = PESEL;
            testInput.TB_Last_Name__c = LAST_NAME;
            testInput.TB_Middle_Name__c = MIDDLE_NAME;
            testInput.TB_First_Name__c = FIRST_NAME;
                
        Account acc = new Account(Name = 'Test Name',
        RecordTypeId = ACCOUNT_REC_TYPE_ID);
        insert acc;
        String profileId = [SELECT Id FROM Profile WHERE Name = 'SWPS Employee Community User' LIMIT 1].Id;
        Contact contactSynced = new Contact(
            FirstName = FIRST_NAME, 
            LastName = LAST_NAME,
            MiddleName = MIDDLE_NAME,
            AccountId = acc.Id,
            hed__AlternateEmail__c = EMAIL,
            Phone = PHONE,
            MobilePhone = PHONE,
            TB_x_Disable_User__c = true,
            TB_x_User_Synced__c = true,
            RecordTypeId = EMPLOYEE_RECORD_TYPE_ID
            );
        Contact contactNotSynced= new Contact(
            FirstName = FIRST_NAME + '1', 
            LastName = LAST_NAME + '1',
            MiddleName = MIDDLE_NAME + '1',
            AccountId = acc.Id,
            hed__AlternateEmail__c = EMAIL_TWO,
            Phone = PHONE_TWO,
            hed__PreferredPhone__c = PHONE_TWO,
            MobilePhone = PHONE_TWO,
            TB_x_Disable_User__c = true,
            TB_x_User_Synced__c = false,
            RecordTypeId = EMPLOYEE_RECORD_TYPE_ID
            );
        Contact contactEnabled= new Contact(
            FirstName = FIRST_NAME + '2', 
            LastName = LAST_NAME + '2',
            MiddleName = MIDDLE_NAME + '2',
            AccountId = acc.Id,
            hed__AlternateEmail__c = EMAIL_THREE,
            MobilePhone = PHONE_TWO,
            TB_x_Disable_User__c = false,
            TB_x_User_Synced__c = false,
            RecordTypeId = EMPLOYEE_RECORD_TYPE_ID
            );


        insert new List<Contact>{contactSynced, contactNotSynced, contactEnabled};
        User userSynced =  new User(
            ProfileId = profileId,
            LastName = LAST_NAME,
            Email = EMAIL,
            Username = EMAIL + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'teacher',
            Alias = 'teacher',
            TimeZoneSidKey = 'Europe/Prague',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'pl_PL',
            TB_Verification_Code__c = '1231231230',
            ContactId = contactSynced.Id
          );
          User userNOTSynced = new User(
            ProfileId = profileId,
            LastName = LAST_NAME + '1',
            Email = EMAIL_TWO,
            Username = EMAIL_TWO + System.currentTimeMillis(),
            CompanyName = 'TEST1',
            Title = 'teacher1',
            Alias = 'teacher1',
            TimeZoneSidKey = 'Europe/Prague',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'pl_PL',
            IsActive = true,
            ContactId = contactNotSynced.Id
          );

          User userActive = new User(
            ProfileId = profileId,
            LastName = LAST_NAME + '2',
            Email = EMAIL_THREE,
            Username = EMAIL_THREE + System.currentTimeMillis(),
            CompanyName = 'TEST1',
            Title = 'teacher1',
            Alias = 'teacher1',
            TimeZoneSidKey = 'Europe/Prague',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'pl_PL',
            IsActive = true,
            ContactId = contactEnabled.Id
          );

        insert new List<User>{userActive, userNOTSynced, userSynced};
        contactSynced.TB_User__c = userSynced.Id;
        contactNotSynced.TB_User__c = userNOTSynced.Id;
        contactEnabled.TB_User__c =userActive.Id;
        update new List<Contact>{contactSynced, contactNotSynced, contactEnabled};
        }
    }


    @IsTest
    private static void testSchedulable() {
      Test.startTest();
      String jobId  = System.schedule('Deactivate User Schedulable', CRON_EXP, new TB_CT_DeactivateUserScheduled());
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
      Test.stopTest();
      Assert.areEqual(CRON_EXP,  ct.CronExpression);
      Assert.areEqual(0, ct.TimesTriggered);
      Assert.areEqual('2045-04-05 15:02:00', String.valueOf(ct.NextFireTime));
    }
}