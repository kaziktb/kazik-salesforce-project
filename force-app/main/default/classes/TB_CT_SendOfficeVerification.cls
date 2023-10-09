public with sharing class TB_CT_SendOfficeVerification {
    private static final String MERGE_TAG_URL_REGEX = '\\{!URL\\}';
    private static final String TEMPLATE_DEV_NAME = 'TB_App_Tracking_Data_Verification_By_Office';

    @InvocableMethod(Label='sendEmailToOffice')
    public static void sendEmailToOffice(List<AppTrackingWrapper> apps) {
        try {
            List<TB_GenericSendEmailWithoutContact.WrapperClass> wrappers = new List<TB_GenericSendEmailWithoutContact.WrapperClass>();
            TB_GenericSendEmailWithoutContact.WrapperClass wrapper = new TB_GenericSendEmailWithoutContact.WrapperClass();
            wrapper.sendFromEmail = apps[0].senderEmail;
            wrapper.whatId = apps[0].appTrackingId;
            wrapper.toAddress = apps[0].toAddress;
            EmailTemplate template = [
                    SELECT Id, HtmlValue, Body, Subject
                    FROM EmailTemplate
                    WHERE DeveloperName = :TEMPLATE_DEV_NAME
            ];
            String[] htmlBodyParts = template.HtmlValue.split(MERGE_TAG_URL_REGEX);
            String[] plainTextBodyParts = template.Body.split(MERGE_TAG_URL_REGEX);
            String urlTag = '<a href="' + apps[0].contactPreviewURL + '">' + 'Link' + '</a>';
            wrapper.htmlBody = String.join(htmlBodyParts, urlTag);
            wrapper.plainTextBody = String.join(plainTextBodyParts, urlTag);
            wrapper.subject = template.Subject;
            wrappers.add(wrapper);
            List<Messaging.SendEmailResult> results = TB_GenericSendEmailWithoutContact.sendEmail(wrappers);
        } catch(Exception e) {
            insert TB_LogUtils.registerLog(e.getMessage(), TB_CT_SendOfficeVerification.class);
        }
    }

    public class AppTrackingWrapper {
        @InvocableVariable
        public Id appTrackingId;

        @InvocableVariable
        public String templateDevNamePL;

        @InvocableVariable
        public String templateDevNameEN;

        @InvocableVariable
        public String toAddress;

        @InvocableVariable
        public String subject;

        @InvocableVariable
        public String contactPreviewURL;

        @InvocableVariable
        public String senderEmail;
    }
}