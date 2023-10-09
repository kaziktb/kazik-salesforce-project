/**
 * Created by jowitakozlak on 22/06/2021.
 */

@isTest
public with sharing class TB_AuraGenericSendMailTest {

    static String relatesTo = '';
    static String recipientEmail = '';
    static String ccEmail = '';
    static String contactId = '';
    static String senderEmail = '';
    static String replyToEmail = '';
    static String templateId = '';
    static String templateDeveloperName = '';

    @TestSetup
    static void testSetup() {

        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u;

        EmailTemplate emailTemplate = new EmailTemplate();
        emailTemplate.isActive = true;
        emailTemplate.Name = 'Test_EmailTemplate';
        emailTemplate.DeveloperName = 'Test_EmailTemplate';
        emailTemplate.TemplateType = 'text';
        emailTemplate.FolderId = UserInfo.getUserId();
        insert emailTemplate;

        System.runAs(u) {
            Contact contact = new Contact();
            contact.LastName = 'Doe';
            contact.Email = '1@gmail.com';
            insert contact;
        }
    }

    @IsTest
    static void sendMailPositive() {
        List<TB_AuraGenericSendMail.WrapperClass> messages = new List<TB_AuraGenericSendMail.WrapperClass>();
        messages = getListOfMessages();

        Test.startTest();
        TB_AuraGenericSendMail.sendMail(messages);
        Test.stopTest();

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void sendMailPositiveInvalidTemplateId() {
        List<TB_AuraGenericSendMail.WrapperClass> messages = new List<TB_AuraGenericSendMail.WrapperClass>();
        messages = getListOfMessages();
        messages[0].templateId = null;

        Test.startTest();
        TB_AuraGenericSendMail.sendMail(messages);
        Test.stopTest();

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void sendMailNegativeNoRecipients() {
        List<TB_AuraGenericSendMail.WrapperClass> messages = new List<TB_AuraGenericSendMail.WrapperClass>();
        messages = getListOfMessages();
        messages[0].recipientEmail = null;

        Test.startTest();
        TB_AuraGenericSendMail.sendMail(messages);
        Test.stopTest();

        System.assertEquals(1,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void sendMailNegativeNoReplyToEmail() {
        List<TB_AuraGenericSendMail.WrapperClass> messages = new List<TB_AuraGenericSendMail.WrapperClass>();
        messages = getListOfMessages();
        messages[0].replyToEmail = '';

        Test.startTest();
        TB_AuraGenericSendMail.sendMail(messages);
        Test.stopTest();

        System.assertEquals(1,[SELECT Id FROM TB_Log__c].size());
    }

    public static List<TB_AuraGenericSendMail.WrapperClass> getListOfMessages() {
        senderEmail = 'zzl.egzamin@swps.edu.pl';
        replyToEmail = 'zzl.egzamin@swps.edu.pl';

        Contact existingContact = [
            SELECT Id, LastName, Email, AccountId
            FROM Contact
            WHERE Email =: '1@gmail.com'
        ];
        relatesTo = existingContact.AccountId;
        contactId = existingContact.Id;
        recipientEmail = existingContact.Email;
        EmailTemplate existingEmailTemplate = [
            SELECT Id, DeveloperName
            FROM EmailTemplate
            WHERE DeveloperName =: 'Test_EmailTemplate'
        ];
        templateId = existingEmailTemplate.Id;
        templateDeveloperName = existingEmailTemplate.DeveloperName;

        ContentVersion contVerFile = new ContentVersion();
        contVerFile.VersionData = Blob.valueOf('Some Text');
        contVerFile.Title = 'Test';
        contVerFile.PathOnClient = 'Test';
        insert contVerFile;
        ContentDocumentLink contDocFile = new ContentDocumentLink();
        contDocFile.ContentDocumentId = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id = :contVerFile.Id
        ].ContentDocumentId;
        contDocFile.LinkedEntityId = existingContact.Id;
        contDocFile.ShareType = 'I';
        contDocFile.Visibility = 'AllUsers';
        insert contDocFile;

        List<TB_AuraGenericSendMail.WrapperClass> messages = new List<TB_AuraGenericSendMail.WrapperClass>();
        TB_AuraGenericSendMail.WrapperClass message = new TB_AuraGenericSendMail.WrapperClass();
        message.relatesTo = (Id)relatesTo;
        message.contactId = existingContact.Id;
        message.recipientEmail = existingContact.Email;
        message.senderEmail = senderEmail;
        message.replyToEmail = replyToEmail;
        message.ccEmail = ccEmail;
        message.templateId = templateId;
        message.templateDeveloperName = templateDeveloperName;
        message.documentId = contDocFile.ContentDocumentId;
        messages.add(message);

        return messages;
    }
}