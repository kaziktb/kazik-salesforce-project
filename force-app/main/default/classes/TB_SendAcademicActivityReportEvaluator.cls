/**
 * Created by Aneta on 30/06/2021.
 */

public with sharing class TB_SendAcademicActivityReportEvaluator {

    public static TB_Notification_Setting__mdt basicSetting
        = TB_Notification_Setting__mdt.getInstance('TB_Basic_Setting');

    public static EmailTemplate evaluatedReminderTemplate = [
        SELECT Id, DeveloperName
        FROM EmailTemplate
        WHERE DeveloperName =: 'TB_Academic_Activity_Report_Evaluator_Reminder'
    ];

    @InvocableMethod(label='sendAcademicActivityReportToEvaluator')
    public static void sendAcademicActivityReportToEvaluator() {
        
        Integer days = Integer.valueOf(TB_Days_For_Reminder__mdt.getInstance('TB_Report_Evaluator_Reminder').TB_How_Many_Days_Earlier__c);
        Date reminderDate = Date.today().addDays(days);

        List<TB_Employee_Evaluation_Stage__c> evaluationStages = [
            SELECT Id, TB_Employee_Stage_Type__c, TB_Evaluation_Stage_End_Date__c, TB_Evaluation_Stage_Status__c,
                    TB_Employee_Evaluation__r.TB_Evaluator__c, TB_Employee_Evaluation__r.TB_Evaluator__r.hed__WorkEmail__c,
                    TB_Employee_Evaluation__c, TB_Evaluator__c
            FROM TB_Employee_Evaluation_Stage__c
            WHERE TB_Evaluation_Stage_End_Date__c = :reminderDate
            AND TB_Employee_Stage_Type__c = 'Academic Activity Report'
            AND TB_Evaluation_Stage_Status__c IN ('New', 'In Progress')
        ];

        List<TB_SendMailWrapper> sendMailWrappers = new List<TB_SendMailWrapper>();

        Set<String> uniqueEvaluators = new Set<String>();
        for(TB_Employee_Evaluation_Stage__c evaluationStage : evaluationStages) {
            if (!uniqueEvaluators.contains(evaluationStage.TB_Evaluator__c)) {
                uniqueEvaluators.add(evaluationStage.TB_Evaluator__c);
                sendMailWrappers.add(assignEvaluatorMessageDetails(evaluationStage));
            }
        }
        TB_SendMultipleMailWrapper multipleMailWrapper = new TB_SendMultipleMailWrapper();
        multipleMailWrapper.sendMailWrappers = sendMailWrappers;
        TB_GenericSendMultipleMails.sendMultipleMails(new List<TB_SendMultipleMailWrapper>{multipleMailWrapper});
    }

    private static TB_SendMailWrapper assignEvaluatorMessageDetails(TB_Employee_Evaluation_Stage__c evaluationStage) {
        TB_SendMailWrapper sendMailWrapper = new TB_SendMailWrapper(basicSetting);
        sendMailWrapper.contactId = evaluationStage.TB_Employee_Evaluation__r.TB_Evaluator__c;
        sendMailWrapper.recipientEmail = evaluationStage.TB_Employee_Evaluation__r.TB_Evaluator__r.hed__WorkEmail__c;
        sendMailWrapper.templateId = evaluatedReminderTemplate.Id;
        sendMailWrapper.templateDeveloperName = evaluatedReminderTemplate.DeveloperName;
        sendMailWrapper.relatesTo = evaluationStage.TB_Employee_Evaluation__c;
        return sendMailWrapper;
    }
}