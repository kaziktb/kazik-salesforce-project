/**
 * Created by Aneta on 08/06/2021.
 */

global with sharing class TB_CreateMailWrapper {
    @InvocableVariable @AuraEnabled
    public Id relatesTo;
    @InvocableVariable @AuraEnabled
    public String contactId;
    @InvocableVariable @AuraEnabled
    public String documentId;
    @InvocableVariable @AuraEnabled
    public List<String> recipientEmails;
    @InvocableVariable @AuraEnabled
    public String senderEmail;
    @InvocableVariable @AuraEnabled
    public String senderName;
    @InvocableVariable @AuraEnabled
    public String replyToEmail;
    @InvocableVariable @AuraEnabled
    public String ccEmail;
    @InvocableVariable @AuraEnabled
    public String templateApiName;
    @InvocableVariable @AuraEnabled
    public String templateId;
    @InvocableVariable @AuraEnabled
    public String fileName;
    @InvocableVariable @AuraEnabled
    public String file;
    @InvocableVariable @AuraEnabled
    public List<ContentVersion> contentVersions;
    @InvocableVariable @AuraEnabled
    public List<Id> contentVersionIds;
    @InvocableVariable @AuraEnabled
    public String orgWideAddressEmailId;

    @InvocableVariable @AuraEnabled
    public SObject record;
    @InvocableVariable @AuraEnabled
    public Boolean sendMailFlag;
    @InvocableVariable @AuraEnabled
    public String validEmailAddresses;
    @InvocableVariable @AuraEnabled
    public String link;

}