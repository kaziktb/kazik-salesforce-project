/**
 * Created by jowitakozlak on 22/06/2021.
 */

global with sharing class TB_SendMailWrapper {
    @InvocableVariable @AuraEnabled
    public Id relatesTo;
    @InvocableVariable @AuraEnabled
    public String contactId;
    @InvocableVariable @AuraEnabled
    public String recipientEmail;
    @InvocableVariable @AuraEnabled
    public String senderEmail;
    @InvocableVariable @AuraEnabled
    public String replyToEmail;
    @InvocableVariable @AuraEnabled
    public String ccEmail;
    @InvocableVariable @AuraEnabled
    public String templateId;
    @InvocableVariable @AuraEnabled
    public String templateDeveloperName;

    public TB_SendMailWrapper() {
    }

    public TB_SendMailWrapper(TB_Notification_Setting__mdt notificationSetting) {
        replyToEmail = notificationSetting.TB_Reply_To_Email__c;
        senderEmail = notificationSetting.TB_Sender_Email__c;
    }
}