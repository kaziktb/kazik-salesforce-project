/**
 * Created by jowitakozlak on 22/06/2021.
 */

global with sharing class TB_GenericSendMultipleMails {
    @TestVisible
    private static List<TB_AuraGenericSendMail.WrapperClass> wrapperClasses = new List<TB_AuraGenericSendMail.WrapperClass>();

    @InvocableMethod(label='sendMultipleMails')
    global static void sendMultipleMails(List<TB_SendMultipleMailWrapper> multipleMailWrappers) {
        for (TB_SendMultipleMailWrapper multipleMailWrapper : multipleMailWrappers) {
            for (TB_SendMailWrapper sendMailWrapper : multipleMailWrapper.sendMailWrappers) {
                TB_AuraGenericSendMail.WrapperClass wrapper = new TB_AuraGenericSendMail.WrapperClass();
                wrapper.contactId = sendMailWrapper.contactId;
                wrapper.ccEmail = sendMailWrapper.ccEmail;
                wrapper.recipientEmail = sendMailWrapper.recipientEmail;
                wrapper.relatesTo = sendMailWrapper.relatesTo;
                wrapper.replyToEmail = sendMailWrapper.replyToEmail;
                wrapper.senderEmail = sendMailWrapper.senderEmail;
                wrapper.templateId = sendMailWrapper.templateId;
                wrapper.templateDeveloperName = sendMailWrapper.templateDeveloperName;
                wrapperClasses.add(wrapper);
            }
        }

        Database.executeBatch(new TB_GenericSendMultipleMailsBatch(wrapperClasses),50);
    }
    
}