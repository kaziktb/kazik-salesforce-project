/**
 * Created by Aneta on 17/05/2021.
 */

global with sharing class TB_CreateEmailToSendController {

    static List<Map<String,String>> recordsList = new List<Map<String, String>>();

    @AuraEnabled
    public static String createEmailTemplate(String subject, String htmlValue, String enhancedLetterheadId) {
        try {
            return insertTemplate(subject, htmlValue, enhancedLetterheadId);
        }catch (EmailTemplateException e) {
            return 'EXCEPTION_EMAIL_TEMPLATE_' + e.getMessage();
        }catch (Exception e) {
            return 'EXCEPTION_' + e.getMessage();
        }
    }
    @AuraEnabled
    public static String sendMassEmailForApplication(
        List<Map<String, String>>  recordObjects, String objectType,
        String emailTemplateId, List<Id> contentVersionIds
    ){
        List<TB_CreateMailWrapper> mailWrappers = new List<TB_CreateMailWrapper>();
        Set<String> emptyEmailList = new Set<String>();
            recordsList = recordObjects;
            for(Map<String,String> singleRecord: recordsList) {
                if(singleRecord.get('emailList') != null) {
                    TB_CreateMailWrapper mailWrapper = new TB_CreateMailWrapper();
                    mailWrapper.contactId = singleRecord.get('contactId');
                    mailWrapper.recipientEmails = singleRecord.get('emailList').split(',');
                    mailWrapper.templateApiName = 'TB_Empty_Template_for_Create_and_Sent_Email';
                    mailWrapper.templateId = emailTemplateId;
                    mailWrapper.senderEmail = singleRecord.get('senderEmail');
                    mailWrapper.replyToEmail = singleRecord.get('senderEmail');
                    mailWrapper.orgWideAddressEmailId = singleRecord.get('orgWideAddressId');

                    if (objectType == 'hed__Application__c') {
                        mailWrapper.relatesTo = singleRecord.get('recordId');
                    }
                    mailWrappers.add(mailWrapper);
                }else {
                    emptyEmailList.add(singleRecord.get('contactId'));
                }
            }

            if(mailWrappers.size() >= 1) {
                mailWrappers[0].contentVersionIds = contentVersionIds;
            }
            String result;
            try {
                Database.executeBatch(new TB_CreateEmailToSendBatch(mailWrappers, emailTemplateId),50);
                result = 'true';
                if(emptyEmailList.size() > 0) {
                    result = JSON.serialize(emptyEmailList);
                }

            } catch (Exception e) {
                insert TB_LogUtils.registerLog(e, TB_AuraGenericSendMail.class);
                result = 'false';
            }
        return result;
    }

    @AuraEnabled
    public static List<ContentVersion> getListOfFiles(String files) {
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        try {
            if(files != null) {
                List<FileWrapper> wrappers = (List<FileWrapper>) JSON.deserialize(files, List<FileWrapper>.class);
                for (FileWrapper singleWrapper : wrappers) {
                    ContentVersion contVerFile = new ContentVersion(
                            VersionData = EncodingUtil.base64Decode(singleWrapper.VersionData),
                            Title = singleWrapper.Title,
                            ContentLocation = 's',
                            PathOnClient = singleWrapper.Title,
                            Description = 'Email Attachment'
                    );
                    contentVersions.add(contVerFile);
                }
                insert contentVersions;
            }
        }catch(Exception e){
            insert TB_LogUtils.registerLog(e);
        }
        return  contentVersions;
    }

    public class FileWrapper {
        public String Title {get;set;}
        public String VersionData {get;set;}
    }

    @InvocableMethod(label='sendMail')
    global static void sendSingleEmailMessages(List<TB_CreateMailWrapper> mailWrappers) {
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

        for (TB_CreateMailWrapper mailWrapper : mailWrappers) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setWhatId(mailWrapper.relatesTo);
            message.setTemplateID(mailWrapper.templateId);
            message.setTargetObjectId(mailWrapper.contactId);
            message.setTreatTargetObjectAsRecipient(false);
            message.setSenderDisplayName(mailWrapper.senderName);
            message.setReplyTo(mailWrapper.senderEmail);
            message.setOrgWideEmailAddressId(mailWrapper.orgWideAddressEmailId);
            message.setUseSignature(false);
            message.setBccSender(false);
            message.setSaveAsActivity(true);
            message.toAddresses = mailWrapper.recipientEmails;

            if(mailWrappers[0].contentVersionIds != null && mailWrappers[0].contentVersionIds.size()>0) {
                message.setEntityAttachments(mailWrappers[0].contentVersionIds);
            }
            messages.add(message);
        }

        try {
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(messages, false);
            System.debug(results);
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e, TB_AuraGenericSendMail.class);
        }
    }

    @AuraEnabled
    public static List<EmailTemplate> getEmailTemplate(String recordId) {
        return [SELECT Id, Body, Subject, HtmlValue FROM EmailTemplate WHERE Id=:recordId LIMIT 1];
    }

    @AuraEnabled
    public static List<EnhancedLetterhead> getEnhancedLetterhead(String recordId) {
        return [SELECT Id, LetterheadFooter, LetterheadHeader, Name FROM EnhancedLetterhead WHERE Id=:recordId LIMIT 1];
    }

    private static String insertTemplate(String subject, String htmlValue, String enhancedLetterheadId) {
        try {
            EmailTemplate emailTemplate = new EmailTemplate(
                    Name = 'MASS_MAIL_CREATOR_' + UserInfo.getUserId()  + '_' + System.currentTimeMillis(),
                    Subject = subject,
                    HtmlValue = htmlValue,
                    EnhancedLetterheadId = enhancedLetterheadId,
                    DeveloperName = 'MASS_MAIL_CREATOR_' + UserInfo.getUserId() + '_' + System.currentTimeMillis(),
                    FolderId = [SELECT Id, DeveloperName, FolderId, Folder.Name FROM EmailTemplate WHERE Name =: 'TB_Empty_Template_for_Create_and_Sent_Email'].FolderId,
                    TemplateType = 'custom',
                    IsActive = true,
                    UiType = 'SFX',
                    RelatedEntityType = 'Contact'
            );
            insert emailTemplate;
            return emailTemplate.Id;
        }catch (Exception e) {
            if(e.getMessage().contains('FIELD_INTEGRITY_EXCEPTION')) {
                throw new EmailTemplateException('FIELD_INTEGRITY_EXCEPTION');
            }else {
                throw new AuraHandledException(e.getMessage());
            }
        }
    }

    public static void deleteTemplateAfterSendMails(Id emailTemplateId) {
        try {
            delete [SELECT Id FROM EmailTemplate WHERE Id =: emailTemplateId];
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
        }
    }

    @AuraEnabled
    public static List<Map<String,String>> getObjectRecords(String objectType, String senderEmailType , String queryFilters, List<String> emailApiNames) {
        if(objectType != null && emailApiNames != null) {
            Map<String, Id> orgWideAddressesMap = new Map<String, Id>();
            if (senderEmailType == 'xdocSenderEmail') {
                List<OrgWideEmailAddress> orgWideEmailAddresses = getAllOrgWideAddresses();
                for (OrgWideEmailAddress singleOrgWideEmail : orgWideEmailAddresses) {
                    orgWideAddressesMap.put(singleOrgWideEmail.Address, singleOrgWideEmail.Id);
                }
            }
            List<Map<String, String>> recordsList = new List<Map<String, String>>();

            String query = 'SELECT Id ';
            if (objectType == 'hed__Application__c') {
                query += ', hed__Applicant__c, TB_x_Sender_Email__c ';
            }
            for (String singleEmailApiName : emailApiNames) {
                query += ', ' + singleEmailApiName;
            }
            query += ' FROM ' + queryFilters;

            List<SObject> objectWithMails;
            try {
                objectWithMails = Database.query(query);
            } catch (Exception e) {
                insert TB_LogUtils.registerLog(e, TB_AuraGenericSendMail.class);
            }

            if (objectWithMails != null) {
                for (SObject objectRecord : objectWithMails) {
                    Map<String, String> singleRecord = new Map<String, String>();
                    String emailAddresses = '';
                    for (String emailApiName : emailApiNames) {
                        emailApiName = emailApiName.trim();
                        if (objectRecord.get(emailApiName) != null) {
                            emailAddresses += (String.valueOf(objectRecord.get(emailApiName))) + ',';
                        }
                    }
                    singleRecord.put('emailList', removeLastChar(emailAddresses));
                    String contactId = '';
                    if (objectType == 'Contact') {
                        contactId = objectRecord.Id;
                    } else if (objectType == 'hed__Application__c') {
                        contactId = String.valueOf(objectRecord.get('hed__Applicant__c'));
                    }
                    singleRecord.put('contactId', contactId);
                    singleRecord.put('recordId', objectRecord.Id);

                    switch on senderEmailType {
                        when 'userAddressEmail' {
                            //singleRecord.put('orgWideAddressId',null);
                        }
                        when 'xdocSenderEmail' {
                            singleRecord.put('orgWideAddressId', orgWideAddressesMap.get(String.valueOf(objectRecord.get('TB_x_Sender_Email__c'))));
                        }
                        when else {
                            singleRecord.put('orgWideAddressId', senderEmailType);
                        }
                    }
                    recordsList.add(singleRecord);
                }
            }
            return recordsList;
        }else {
            return null;
        }
    }

    @AuraEnabled
    public static List<OrgWideEmailAddress> getAllOrgWideAddresses() {
        return [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress ALL ROWS];
    }

    private static String removeLastChar(String s) {
        return (s == null || s.length() == 0) ? null : (s.substring(0, s.length() - 1));
    }

    private class EmailTemplateException extends Exception {
    }

    @AuraEnabled
    public static String deleteFile(String contentDocumentId) {
        try {
            delete new ContentDocument(Id = contentDocumentId);
            return 'SUCCESS';
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return 'FAILED ' + e.getMessage();
        }
    }
}