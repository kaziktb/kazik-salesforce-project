/**
    * Created by Dawid Machon on 01/03/2023
    */

global with sharing class TB_CreateEmailActivityTask {

    private final static String STATUS_EMAIL_SENT = '3';
    private final static String RELATION_TYPE = 'ToAddress';

    @InvocableMethod(label='Create Email Activity Task' description='save task as EmailActivity on related contact')
    public static void TB_CreateEmailActivityTask_MainClass(List<WrapperClass> entryList) {
        createActivity(entryList);
    }

    private static void createActivity(List<WrapperClass> entries) {
        List<EmailMessageRelation> emailMessageRelations = new List<EmailMessageRelation>();
        List<EmailMessage> emailMessages = new List<EmailMessage>();
        List<String> contactSFIDs = new List<String>();

        try {
            for (WrapperClass entry : entries) {
                EmailMessage emailMessage = generateEmailMessage(entry.subject, entry.fromName, entry.fromAddress, entry.relatedToId);
                contactSFIDs.add(entry.recordId);
                emailMessages.add(emailMessage);
            }
            insert emailMessages;

            Integer counter = 0;
            for (EmailMessage emailMessage : emailMessages) {
                String contactSFID = contactSFIDs[counter];
                EmailMessageRelation emailMessageRelation = generateEmailMessageRelation(emailMessage, contactSFID);
                emailMessageRelations.add(emailMessageRelation);
                counter++;
            }
            insert emailMessageRelations;
        }catch (Exception e) {
            TB_LogUtils.registerLog(e);
        }
    }

    private static EmailMessage generateEmailMessage(String subject, String fromName, String fromAddress, String relatedToId) {
        return new EmailMessage(
            Status = STATUS_EMAIL_SENT,
            RelatedToId = relatedToId,
            FromName = fromName,
            FromAddress = fromAddress,
            Subject = subject
        );
    }

    private static EmailMessageRelation generateEmailMessageRelation(EmailMessage emailMessage, String contactSFID) {
        return new EmailMessageRelation(
            EmailMessageId = emailMessage.Id,
            RelationId = contactSFID,
            RelationType = RELATION_TYPE
        );
    }

    global class WrapperClass {
        @InvocableVariable
        global Id recordId;
        @InvocableVariable
        global Id relatedToId;
        @InvocableVariable
        global String fromAddress;
        @InvocableVariable
        global String fromName;
        @InvocableVariable
        global String subject;
    }
}