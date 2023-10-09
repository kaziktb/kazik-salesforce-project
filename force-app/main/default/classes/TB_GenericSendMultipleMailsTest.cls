/**
 * Created by jowitakozlak on 22/06/2021.
 */

@isTest
public with sharing class TB_GenericSendMultipleMailsTest {

    static TB_Notification_Setting__mdt notificationSetting;
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
            ProfileId = [SELECT Id FROM Profile WHERE Name  = 'System Administrator'].Id,
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
        List<TB_SendMultipleMailWrapper> messages = new List<TB_SendMultipleMailWrapper>{getListOfMessages()};

        Test.startTest();
        TB_GenericSendMultipleMails.sendMultipleMails(messages);
        Test.stopTest();

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void sendMailPositiveInvalidTemplateId() {
        List<TB_SendMultipleMailWrapper> messages = new List<TB_SendMultipleMailWrapper>{getListOfMessages()};
        messages[0].sendMailWrappers[0].templateId = null;

        Test.startTest();
        TB_GenericSendMultipleMails.sendMultipleMails(messages);
        Test.stopTest();

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void sendMailNegativeNoRecipients() {
        List<TB_SendMultipleMailWrapper> messages = new List<TB_SendMultipleMailWrapper>{getListOfMessages()};
        messages[0].sendMailWrappers[0].recipientEmail = null;

        Test.startTest();
        TB_GenericSendMultipleMails.sendMultipleMails(messages);
        Test.stopTest();

        System.assertEquals(1,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void sendMailNegativeNoReplyToEmail() {
        List<TB_SendMultipleMailWrapper> messages = new List<TB_SendMultipleMailWrapper>{getListOfMessages()};
        messages[0].sendMailWrappers[0].replyToEmail = '';

        Test.startTest();
        TB_GenericSendMultipleMails.sendMultipleMails(messages);
        Test.stopTest();

        System.assertEquals(1,[SELECT Id FROM TB_Log__c].size());
    }

    public static TB_SendMultipleMailWrapper getListOfMessages() {
        notificationSetting = [
            SELECT TB_Reply_To_Email__c, TB_Sender_Email__c
            FROM TB_Notification_Setting__mdt
            WHERE Label =: 'Basic Setting'
        ];
        senderEmail = notificationSetting.TB_Sender_Email__c;
        replyToEmail = notificationSetting.TB_Reply_To_Email__c;

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

        TB_SendMultipleMailWrapper messages = new TB_SendMultipleMailWrapper();
        messages.sendMailWrappers = new List<TB_SendMailWrapper>();
        TB_SendMailWrapper message = new TB_SendMailWrapper();
        message.relatesTo = (Id)relatesTo;
        message.contactId = existingContact.Id;
        message.recipientEmail = existingContact.Email;
        message.senderEmail = senderEmail;
        message.replyToEmail = replyToEmail;
        message.ccEmail = ccEmail;
        message.templateId = templateId;
        message.templateDeveloperName = templateDeveloperName;
        messages.sendMailWrappers.add(message);

        return messages;
    }
}