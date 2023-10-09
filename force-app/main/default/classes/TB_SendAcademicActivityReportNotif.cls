/**
 * Created by jowitakozlak on 23/06/2021.
 */
public with sharing class TB_SendAcademicActivityReportNotif {

    public static List<TB_Employee_Evaluation_Stage__c> evaluationStages = [
        SELECT Id, TB_Employee_Stage_Type__c, TB_First_Reminder_Date__c,
            TB_Second_Reminder_Date__c, TB_First_Reminder_Recipient__c, TB_Second_Reminder_Recipient__c,
            TB_Evaluation_Stage_Status__c, TB_Evaluated__c, TB_Evaluated__r.hed__WorkEmail__c,
            TB_Employee_Evaluation__c, TB_Administrator__c, TB_Administrator__r.hed__WorkEmail__c
        FROM TB_Employee_Evaluation_Stage__c
        WHERE TB_Employee_Stage_Type__c = 'Academic Activity Report'
        AND TB_Evaluation_Stage_Status__c IN ('New', 'In Progress')
    ];

    public static TB_Notification_Setting__mdt basicSetting
        = TB_Notification_Setting__mdt.getInstance('TB_Basic_Setting');

    public static List<EmailTemplate> emailTemplates = [
        SELECT Id, DeveloperName
        FROM EmailTemplate
        WHERE DeveloperName IN (
            'TB_Academic_Activity_Report_Evaluated_Reminder',
            'TB_Academic_Activity_Report_Process_Administrator_Reminder'
        )
    ];

    @InvocableMethod(label='sendAcademicActivityReportFirstSecondReminder')
    public static void sendAcademicActivityReportFirstSecondReminder() {

        List<TB_SendMailWrapper> sendMailWrappers = new List<TB_SendMailWrapper>();

        EmailTemplate evaluatedTemplate;
        EmailTemplate administratorTemplate;
        if (emailTemplates[0].DeveloperName.contains('Evaluated')) {
            evaluatedTemplate = emailTemplates[0];
            administratorTemplate = emailTemplates[1];
        } else {
            evaluatedTemplate = emailTemplates[1];
            administratorTemplate = emailTemplates[0];
        }

        //evaluationStage.get('TB_' + number + 'Reminder_Date__c');
        // TODO jak będzie czas- to przepisać na dynamiczne
        Set<String> evaluationStageUniqueAdministrators = new Set<String>();
        for(TB_Employee_Evaluation_Stage__c evaluationStage : evaluationStages) {
            if(!(evaluationStageUniqueAdministrators.contains(evaluationStage.TB_Administrator__c))){
                if( (
                    evaluationStage.TB_First_Reminder_Date__c == System.today()
                        && evaluationStage.TB_First_Reminder_Recipient__c == 'Process Administrator'
                )
                    || (
                    evaluationStage.TB_Second_Reminder_Date__c == System.today()
                        && evaluationStage.TB_Second_Reminder_Recipient__c == 'Process Administrator'
                )
                    ) {
                    evaluationStageUniqueAdministrators.add(evaluationStage.TB_Administrator__c);
                    sendMailWrappers.add(assignMessageDetails(
                        evaluationStage,
                        administratorTemplate,
                        evaluationStage.TB_Administrator__c,
                        evaluationStage.TB_Administrator__r.hed__WorkEmail__c
                    ));
                }
            }
        }

        for(TB_Employee_Evaluation_Stage__c evaluationStage : evaluationStages) {
            if( (
                    evaluationStage.TB_First_Reminder_Date__c == System.today()
                    && evaluationStage.TB_First_Reminder_Recipient__c == 'Evaluated'
                ) || (
                    evaluationStage.TB_Second_Reminder_Date__c == System.today()
                    && evaluationStage.TB_Second_Reminder_Recipient__c == 'Evaluated'
                )
            ) {
                sendMailWrappers.add(assignMessageDetails(
                    evaluationStage,
                    evaluatedTemplate,
                    evaluationStage.TB_Evaluated__c,
                    evaluationStage.TB_Evaluated__r.hed__WorkEmail__c
                ));
            }
        }

        // TODO Stworzyć konstruktor z sendMailWrappers
        TB_SendMultipleMailWrapper multipleMailWrapper = new TB_SendMultipleMailWrapper();
        multipleMailWrapper.sendMailWrappers = sendMailWrappers;
        try {
            TB_GenericSendMultipleMails.sendMultipleMails(new List<TB_SendMultipleMailWrapper>{multipleMailWrapper});
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e, TB_SendAcademicActivityReportNotif.class);
        }
    }

    private static TB_SendMailWrapper assignMessageDetails(
        TB_Employee_Evaluation_Stage__c evaluationStage, EmailTemplate emailTemplate, Id contactId, String email
    ) {
        TB_SendMailWrapper sendMailWrapper = new TB_SendMailWrapper();
        sendMailWrapper.replyToEmail = basicSetting.TB_Reply_To_Email__c;
        sendMailWrapper.senderEmail = basicSetting.TB_Sender_Email__c;
        sendMailWrapper.contactId = contactId;
        sendMailWrapper.recipientEmail = email;
        sendMailWrapper.templateId = emailTemplate.Id;
        sendMailWrapper.templateDeveloperName = emailTemplate.DeveloperName;
        sendMailWrapper.relatesTo = evaluationStage.TB_Employee_Evaluation__c;
        return sendMailWrapper;
    }

}