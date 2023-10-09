/**
 * Created by annaseveryna on 18/02/2022.
 */

global with sharing class TB_QualificationExamProtocolWrapper {
    @InvocableVariable @AuraEnabled
    public Id applicationId;

    @InvocableVariable @AuraEnabled
    public String applicantFullName;

    @InvocableVariable @AuraEnabled
    public String applicationName;

    @InvocableVariable @AuraEnabled
    public String qualificationIds;

    @InvocableVariable @AuraEnabled
    public List<TB_Application_Qualification__c> qualifications;

    @InvocableVariable @AuraEnabled
    public Boolean isMultiple;

    @InvocableVariable @AuraEnabled
    public List<Id> applicationIds;

    @InvocableVariable @AuraEnabled
    public Integer indexToStartWith;

    public String fileName;

    public PageReference pdfPageReference;
}