public with sharing class TB_CT_SendDataForRegistrationController {
    public static String TEMPLATE_DEVNAME_PL = 'TB_Registration_Notification_PL';
    public static String TEMPLATE_DEVNAME_EN = 'TB_Registration_Notification_EN';


    @InvocableMethod(Label='sendEmail')
    public static void sendRegisterEmailNotification(List<AppTrackingWrapperClass> appTrackings) {
        try {
            Id appTrackingId = appTrackings[0].appTrackingId;
            TB_App_Tracking__c appTracking = [
                    SELECT Id, TB_Preferred_Language__c, TB_Dean_s_Office_Responsible__r.hed__WorkEmail__c,
                            TB_Email__c, TB_Dean_s_Office_Responsible__c
                    FROM TB_App_Tracking__c
                    WHERE Id = :appTrackingId
            ];
            String templateDevName = appTracking.TB_Preferred_Language__c == TB_Constants.TB_COMMUNICATION_LANGUAGE_POLISH ? TEMPLATE_DEVNAME_PL : TEMPLATE_DEVNAME_EN;
            EmailTemplate template = [
                    SELECT Id, HtmlValue, Body, Subject
                    FROM EmailTemplate
                    WHERE DeveloperName = :templateDevName
            ];
            List<TB_GenericSendEmailWithoutContact.WrapperClass> wrappers = new List<TB_GenericSendEmailWithoutContact.WrapperClass>();
            TB_GenericSendEmailWithoutContact.WrapperClass wrapper = new TB_GenericSendEmailWithoutContact.WrapperClass();
            wrapper.toAddress = appTracking.TB_Email__c;
            wrapper.htmlBody = template.HtmlValue;
            wrapper.plainTextBody = template.Body;
            wrapper.subject = template.Subject;
            wrapper.whatId = appTrackingId;
            wrapper.sendFromEmail = 'admissions@swps.edu.pl';
            wrappers.add(wrapper);
            TB_GenericSendEmailWithoutContact.sendEmail(wrappers);
        } catch(Exception e) {
            insert TB_LogUtils.registerLog(e.getMessage(), TB_CT_SendDataForRegistrationController.class);
        }
    }

    public class AppTrackingWrapperClass {
        @InvocableVariable
        public Id appTrackingId;
    }
}