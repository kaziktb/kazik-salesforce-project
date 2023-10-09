@IsTest
private class TB_CT_DeactivateUserTest {
    private static final String MOBILE_VAL = 'Mobile';
    private static final String EMAIL_ONE_VALUE = 'testtest@gmail.com';
    private static final String EMAIL_TWO_VALUE = 'testtest1@gmail.com';

    @TestSetup
    static void makeData(){
        Id profileId;
        Contact cont;
        Contact cont1;
        System.runAs(TB_DataFactory.createUser(TB_Constants.PROFILE_NAME_ADMINISTRATOR, TB_Constants.ROLE_DEV_NAME_ADMIN, false)) {
            insert new TB_TC_URLs__c(TB_Admissions_Portal__c = TB_Constants.TB_CT_ADMISSIONS_PORTAL);
            TB_App_Tracking__c testInput = new TB_App_Tracking__c();
            testInput.TB_Email__c = 'app'+EMAIL_ONE_VALUE;
            testInput.TB_Phone__c = '809890890';
            testInput.TB_PESEL__c = '78040152352';
            testInput.TB_Last_Name__c = 'Test Last Name';
            testInput.TB_Middle_Name__c = 'Test Middle Name';
            testInput.TB_First_Name__c = 'Test First Name';
                
        Account acc = new Account(Name = 'Test Name',
        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Administrative').getRecordTypeId() );
        insert acc;
        profileId = [SELECT Id FROM Profile WHERE Name = 'SWPS Employee Community User' LIMIT 1].Id;
        cont = new Contact(
            FirstName = 'First Name', 
            LastName = 'Last Name',
            MiddleName = 'Middle Name',
            AccountId = acc.Id,
            hed__AlternateEmail__c = EMAIL_ONE_VALUE,
            Phone = '12345678',
            hed__PreferredPhone__c = MOBILE_VAL,
            MobilePhone = '12345678',
            TB_x_Disable_User__c = false,
            TB_x_User_Synced__c = false
            );
        insert cont;
        cont1= new Contact(
            FirstName = 'First Name1', 
            LastName = 'Last Name1',
            MiddleName = 'Middle Name1',
            AccountId = acc.Id,
            hed__AlternateEmail__c = EMAIL_TWO_VALUE,
            Phone = '123456781',
            hed__PreferredPhone__c = MOBILE_VAL,
            MobilePhone = '1234567812',
            TB_x_User_Synced__c = true
            );
        insert cont1;
        insert new User(
            ProfileId = profileId,
            LastName = 'lastName',
            Email = EMAIL_ONE_VALUE,
            Username = EMAIL_ONE_VALUE + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'teacher',
            Alias = 'teacher',
            TimeZoneSidKey = 'Europe/Prague',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'pl_PL',
            ContactId = cont.Id,
            TB_Verification_Code__c = '1231231230'
          );
          insert new User(
            ProfileId = profileId,
            LastName = 'lastName1',
            Email = EMAIL_TWO_VALUE,
            Username = EMAIL_TWO_VALUE + System.currentTimeMillis(),
            CompanyName = 'TEST1',
            Title = 'teacher1',
            Alias = 'teacher1',
            TimeZoneSidKey = 'Europe/Prague',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'pl_PL',
            ContactId = cont1.Id,
            IsActive = true
          );

        TB_Admissions_Dictionary__c consentBundle = TB_TestDataFactory.createConsentBundle(false);
        insert consentBundle;
        TB_Admissions_Dictionary__c consentTerms = TB_TestDataFactory.createConsent('Terms and Conditions',  consentBundle.Id, false);
        insert consentTerms;
        insert testInput;
    }
}
    @IsTest
    private static void testUpdateUser(){
        Set<Id> contactsToDel = new Set<Id>();
        Set<Id> accountsToDel =  new Set<Id>();
        Set<Id> usersToDeactivate =  new Set<Id>();
        
        for(User u : [SELECT Id FROM User WHERE Email = :EMAIL_ONE_VALUE OR Email = :EMAIL_TWO_VALUE]){
            usersToDeactivate.add(u.Id);
        }
        for(Account a : [SELECT Id FROM Account]){
            accountsToDel.add(a.Id);
        }
        for(Contact c : [SELECT Id FROM Contact]){
            contactsToDel.add(c.Id);
        }
        Test.startTest();
             System.enqueueJob(new TB_CT_DeactivateUser(contactsToDel,accountsToDel,usersToDeactivate,false));
        Test.stopTest();

        List<Contact> contacts = [SELECT Id, TB_x_Disable_User__c FROM Contact WHERE Id IN:contactsToDel];
        for(Contact con : contacts) {
            Assert.areEqual(true, con.TB_x_Disable_User__c, 'Contact with ID: '+ con.Id+' is set to deactivation');
        }
       
    } 


    @IsTest
    private static void testAddErrorLog(){

        Test.startTest();
            TB_CT_DeactivateUser.addErrorLog('Test Error Add');
        Test.stopTest();

        List<TB_Log__c> out = [SELECT Id FROM TB_Log__c LIMIT 1];

        System.assert(!out.isEmpty(),'Error Should be created');
    } 
}
