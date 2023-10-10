/**
 * Created by Aneta on 03/08/2021.
 */

public with sharing class TB_SendNotificationProcessCompleted {

    public static void SendNotificationToProcessAdministrator(String processId, Boolean executeFlag) {

        String query='SELECT Id FROM EmailTemplate WHERE DeveloperName=';
        query+= executeFlag ? '\'TB_Evaluation_Process_Configuration_Completed\'' : '\'TB_Evaluation_Process_Configuration_Completed_Failed\'';
        EmailTemplate emailTemplate =  Database.query(query);

        TB_Notification_Setting__mdt basicSetting = TB_Notification_Setting__mdt.getInstance('TB_Basic_Setting');

        TB_Employee_Evaluation_Process__c evaluationProcess = [
                SELECT Id, TB_Administrator__c, TB_Administrator__r.Id, TB_Administrator__r.hed__WorkEmail__c
                FROM TB_Employee_Evaluation_Process__c
                WHERE Id = :processId
        ];

        List<TB_AuraGenericSendMail.WrapperClass> listMailWrappers = new List<TB_AuraGenericSendMail.WrapperClass>();
        TB_AuraGenericSendMail.WrapperClass mailWrapper = new TB_AuraGenericSendMail.WrapperClass();
        mailWrapper.relatesTo = processId;
        mailWrapper.contactId = evaluationProcess.TB_Administrator__c;
        mailWrapper.recipientEmail= evaluationProcess.TB_Administrator__r.hed__WorkEmail__c;
        mailWrapper.senderEmail = basicSetting.TB_Sender_Email__c;
        mailWrapper.replyToEmail = basicSetting.TB_Reply_To_Email__c;
        mailWrapper.templateId = emailTemplate.Id;

        if(UserInfo.getUserEmail() != evaluationProcess.TB_Administrator__r.hed__WorkEmail__c) {
            mailWrapper.ccEmail = UserInfo.getUserEmail();
        }

        listMailWrappers.add(mailWrapper);
        TB_AuraGenericSendMail.sendMail(listMailWrappers);
    }
}