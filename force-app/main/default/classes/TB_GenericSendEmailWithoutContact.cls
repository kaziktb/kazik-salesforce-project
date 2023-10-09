global with sharing class TB_GenericSendEmailWithoutContact {

   @InvocableMethod(Label='sendMailWithoutContact')
    global static void sendEmailInvocable(List<WrapperClass> wrappers) {
        sendEmail(wrappers);
    }

    public static List<Messaging.SendEmailResult> sendEmail(List<WrapperClass> wrappers) {
        List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();
        try {
            List<String> sendFromEmails = new List<String>();
            for (WrapperClass wrapper : wrappers) {
                sendFromEmails.add(wrapper.sendFromEmail);
            }
            List<OrgWideEmailAddress> orgWideEmailAddresses = [
                    SELECT Address
                    FROM OrgWideEmailAddress
                    WHERE Address IN :sendFromEmails
            ];
            Map<String, Id> addressToId = new Map<String, Id>();
            for (OrgWideEmailAddress address : orgWideEmailAddresses) {
                addressToId.put(address.Address, address.Id);
            }
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            for (WrapperClass wrapper : wrappers) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{
                    wrapper.toAddress
            });
            email.setTreatBodiesAsTemplate(true);
            email.setHtmlBody(wrapper.htmlBody);
            email.setPlainTextBody(wrapper.plainTextBody);
            email.setSubject(wrapper.subject);
                email.setOrgWideEmailAddressId(addressToId.get(wrapper.sendFromEmail));
                email.setCharset('UTF-8');
            if (!String.isBlank(wrapper.whatId)) {
                email.setWhatId(wrapper.whatId);
            }
            if (!String.isBlank(wrapper.targetObjectId)) {
                email.setTargetObjectId(wrapper.targetObjectId);
            }
                emails.add(email);
            }
            results = Messaging.sendEmail(emails);
        } catch(Exception e) {
            insert TB_LogUtils.registerLog(e.getMessage(), TB_GenericSendEmailWithoutContact.class);
        }
        return results;
    }

    global class WrapperClass {
        @InvocableVariable
        global String toAddress;

        @InvocableVariable
        global Id whatId;

        @InvocableVariable
        global String htmlBody;

        @InvocableVariable
        global String plainTextBody;

        @InvocableVariable
        global String subject;

        @InvocableVariable
        global String sendFromEmail;

        @InvocableVariable
        global Id targetObjectId;
    }
}