/**
 * Created by jowitakozlak on 22/06/2021.
 */

global without sharing class TB_AuraGenericSendMail {

    private class TB_AuraGenericSendMailException extends Exception {
    }

    @InvocableMethod(label='sendMail')
    global static void sendMail (List<WrapperClass> wrapperClasses) {
        Map<String, String> contentDocToVersion;
        Map<String, String> emailAddressToId;
        List<OrgWideEmailAddress> emailAddresses;

        Map<Integer, Id> wrapperIndexToEmailTemplateId = prepareEmailTemplates(wrapperClasses);

        if (!String.isBlank(wrapperClasses[0].senderEmail)) {
            emailAddresses = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = :wrapperClasses[0].senderEmail];
        }

        if (emailAddresses != null && !emailAddresses.isEmpty()) {
            emailAddressToId = TB_SObjectUtils.createFieldToFieldStringMap(emailAddresses, OrgWideEmailAddress.Address, OrgWideEmailAddress.Id);
        }

        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        if (!wrapperClasses.isEmpty()) {

            List<Id> agreementDocIds = new List<Id>();
            for (WrapperClass wc : wrapperClasses) {
                if (!String.isBlank(wc.documentId)) {
                    agreementDocIds.add((Id) wc.documentId);
                }
            }
            if (!agreementDocIds.isEmpty()) {
                contentDocToVersion = TB_SObjectUtils.createFieldToFieldStringMap(
                    [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :agreementDocIds],
                    ContentVersion.ContentDocumentId,
                    ContentVersion.Id
                );
            }

            List<TB_Log__c> logs = new List<TB_Log__c>();
            for (WrapperClass wrapperClass : wrapperClasses) {

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                if (wrapperIndexToEmailTemplateId.containsKey(wrapperClass.wrapperIndex)) {
                    mail.setTemplateId(wrapperIndexToEmailTemplateId.get(wrapperClass.wrapperIndex));
                } else {
                    mail.setTemplateId(wrapperIndexToEmailTemplateId.values()[0]);
                }
                mail.setTargetObjectId(wrapperClass.contactId);
                mail.setTreatTargetObjectAsRecipient(false);
                if (emailAddressToId != null && !emailAddressToId.isEmpty()) {
                    mail.setOrgWideEmailAddressId(emailAddressToId.get(wrapperClass.senderEmail));
                }

                try {
                    if (!String.isBlank(wrapperClass.replyToEmail)) {
                        mail.setReplyTo(wrapperClass.replyToEmail);
                    } else {
                        throw new TB_AuraGenericSendMailException('ReplyTo email can\'t be null');
                    }
                } catch (Exception e) {
                    logs.add(TB_LogUtils.registerLog(e, TB_AuraGenericSendMail.class));
                }

                String[] toAddresses = new String[]{
                    wrapperClass.recipientEmail
                };
                if (!String.isBlank(wrapperClass.ccEmail)) {
                    toAddresses.add(wrapperClass.ccEmail);
                }
                mail.setToAddresses(toAddresses);
                if (!String.isBlank(wrapperClass.relatesTo)) {
                    mail.setWhatId(wrapperClass.relatesTo);
                }
                if (agreementDocIds.contains(wrapperClass.documentId)) {
                    mail.setEntityAttachments(new List<String>{
                        contentDocToVersion.get(wrapperClass.documentId)
                    });
                }

                messages.add(mail);
            }
            if (!logs.isEmpty()) {
                insert logs;
            }
        }

        try {
            Messaging.SendEmailResult [] results = Messaging.sendEmail(messages, false);
            List<TB_Log__c> mailErrorMessageLogs = new List<TB_Log__c>();

            for (Messaging.SendEmailResult mse : results) {
                if (!mse.isSuccess()) {
                    mailErrorMessageLogs.add(TB_LogUtils.errorMailMessage(createErrorBodyMessage(mse.getErrors()), TB_AuraGenericSendMail.class));
                }
            }
            if (!mailErrorMessageLogs.isEmpty()) {
                insert mailErrorMessageLogs;
            }
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e, TB_AuraGenericSendMail.class);
        }
    }

    public static Map<Integer,Id> prepareEmailTemplates(List<WrapperClass> wrapperClasses) {
        Map<Integer, Id> wrapperIndexToEmailTemplateId = new Map<Integer, Id>();
        Map<Integer, String> wrapperIndexToEmailTemplateDevName = new Map<Integer, String>();
        Integer index = 0;
        for (WrapperClass wrapper : wrapperClasses) {
            wrapper.wrapperIndex = index;
            if (wrapper.templateId instanceof Id) {
                wrapperIndexToEmailTemplateId.put(wrapper.wrapperIndex, wrapper.templateId);
            } else {
                wrapperIndexToEmailTemplateDevName.put(wrapper.wrapperIndex, wrapper.templateDeveloperName);
            }
            index++;
        }

        List<EmailTemplate> emailTemplates = [
            SELECT Id, DeveloperName
            FROM EmailTemplate
            WHERE DeveloperName IN :wrapperIndexToEmailTemplateDevName.values()
        ];

        for (EmailTemplate emailTemplate : emailTemplates) {
            for (Integer wrapperId : wrapperIndexToEmailTemplateDevName.keySet()) {
                if (emailTemplate.DeveloperName == wrapperIndexToEmailTemplateDevName.get(wrapperId)) {
                    wrapperIndexToEmailTemplateId.put(wrapperId, emailTemplate.Id);
                }
            }
        }
        return wrapperIndexToEmailTemplateId;
    }

    public static String createErrorBodyMessage(Messaging.SendEmailError[] errorList) {
        String errorBody = '';
        for (Messaging.SendEmailError error : errorList) {
            errorBody = errorBody + 'Fields: ' + error.getFields() + ';/n';
            errorBody = errorBody + 'Code: ' + error.getStatusCode() + ';/n';
            errorBody = errorBody + 'Message: ' + error.getMessage() + ';/n';
            errorBody = errorBody + 'Target Object Id: ' + error.getTargetObjectId() + ';/n';
        }
        return errorBody;
    }

    global class WrapperClass {
        global Integer wrapperIndex;
        @InvocableVariable
        global Id relatesTo;
        @InvocableVariable
        global String contactId;
        @InvocableVariable
        global String recipientEmail;
        @InvocableVariable
        global String senderEmail;
        @InvocableVariable
        global String replyToEmail;
        @InvocableVariable
        global String ccEmail;
        @InvocableVariable
        global String templateId;
        @InvocableVariable
        global String templateDeveloperName;
        @InvocableVariable
        global String documentId;
    }
}