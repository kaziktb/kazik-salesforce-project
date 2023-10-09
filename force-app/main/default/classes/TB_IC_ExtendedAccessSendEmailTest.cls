@isTest
private class TB_IC_ExtendedAccessSendEmailTest {
    private static final String PARTNER_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();

    @TestSetup
    static void testSetup(){
        System.runAs(TB_DataFactory.createUser(TB_Constants.PROFILE_NAME_ADMINISTRATOR, TB_Constants.ROLE_DEV_NAME_ADMIN, false)) {
        User uSender = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = :TB_Constants.PROFILE_NAME_ADMINISTRATOR].Id,
            LastName = 'Sender',
            Email = 'sender@xxxx.xcom',
            Username = 'sender@xxxx.xcom' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        
        User uOwner = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = :TB_Constants.PROFILE_NAME_ADMINISTRATOR].Id,
            LastName = 'Owner',
            Email = 'owner@xxxx.xcom',
            Username = 'owner@xxxx.xcom' + System.currentTimeMillis(),
            CompanyName = 'TEST2',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US' 
        );
        insert new List<User>{uSender, uOwner};

        Account testAccount = new Account(
            Name = 'Test Account Partner',
            OwnerId = uOwner.Id,
            RecordTypeId = PARTNER_RECORD_TYPE_ID
        );
        insert testAccount;

        Contact senderContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            hed__WorkEmail__c = 'john@doe.unknown',
            TB_User__c = uSender.Id
        );

        Contact ownerContact = new Contact(
            FirstName = 'Jack',
            LastName = 'Sparrow',
            hed__WorkEmail__c = 'jack@sparrow.pirate',
            TB_User__c = uOwner.Id
        );
        insert new List<Contact>{senderContact, ownerContact};
        
        EmailTemplate emailTemplate = new EmailTemplate(
            isActive = true,
            Name = 'Test_Ic_EmailTemplate',
            DeveloperName = 'Test_Ic_EmailTemplate',
            TemplateType = 'text',
            Subject = 'test',
            HTMLValue = '<html>{!Contact_Name} {!TB_User__c} {!Partner_Name} {!Partner_Id} {!Portal_Address}</html>',
            FolderId =  UserInfo.getUserId()
        );
        insert emailTemplate;
        }
    }


    @isTest
    static void testSendEmailWithTemplate() {
        Account testAccount = [SELECT Id, OwnerId FROM Account WHERE Name = 'Test Account Partner' LIMIT 1];
        Contact ownerContact = [SELECT Id, hed__WorkEmail__c FROM Contact Where TB_User__c = :testAccount.OwnerId LIMIT 1];
        Contact senderContact = [SELECT Id FROM Contact WHERE hed__WorkEmail__c = 'john@doe.unknown' LIMIT 1];
        EmailTemplate emailTemplate = [SELECT DeveloperName FROM EmailTemplate WHERE Name = 'Test_Ic_EmailTemplate' LIMIT 1];

        TB_IC_ExtendedAccessSendEmail.WrapperClass testWrapper = new TB_IC_ExtendedAccessSendEmail.WrapperClass();
        testWrapper.partnerId = testAccount.Id;
        testWrapper.senderContactId = senderContact.Id;
        testWrapper.recipientEmail = ownerContact.hed__WorkEmail__c;
        testWrapper.templateDeveloperName = emailTemplate.DeveloperName;
        testWrapper.portalAddress = 'https://swps.edu.com.invalid';
        
        Test.startTest();
        List<String> result = TB_IC_ExtendedAccessSendEmail.sendEmailWithTemplate(new List<TB_IC_ExtendedAccessSendEmail.WrapperClass>{testWrapper});
        Test.stopTest();
        
        System.assertEquals('Email sent successfully.', result[0], 'Email not sent, Expected: "Email sent successfully."');
    }
}