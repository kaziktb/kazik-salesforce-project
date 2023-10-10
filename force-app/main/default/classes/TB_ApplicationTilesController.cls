/**
 * Created by Aneta on 23/08/2021.
 */

public with sharing class TB_ApplicationTilesController {
    @AuraEnabled
    public static String getContact() {
        User user = [SELECT ContactId FROM User WHERE Id =: UserInfo.getUserId()];
        try {
            Contact contact = [SELECT Id, TB_Test__c FROM Contact WHERE Id =: user.ContactId];
            return JSON.serialize(contact);
        }catch(Exception e) {
            return null;
        }
    }

    @AuraEnabled
    public static String getApplicationWrappers(String language, String contactId, Boolean isTest) {

        List<hed__Application__c> applications = getApplicationsForUserContact(contactId, isTest);
        if(applications == null) {
            return null;
        }else {
            List<ApplicationWrapper> applicationWrappers = new List<ApplicationWrapper>();
            try {
                for(hed__Application__c singleApplication : applications) {
                    ApplicationWrapper singleWrapper = new ApplicationWrapper(singleApplication, language);
                    applicationWrappers.add(singleWrapper);
                }
                return JSON.serialize(applicationWrappers);
            }catch(Exception e) {
                insert TB_LogUtils.registerLog(e);
                return 'FAILED_TO_CREATE_WRAPPERS';
            }
        }
    }

    private static List<hed__Application__c> getApplicationsForUserContact(String applicationContactId, Boolean isTest) {
        if (applicationContactId == null) {
            return null;
        } else {
            String dynamicQuery = 'SELECT Id, Name, hed__Application_Status__c, ' +
                    'toLabel(hed__Application_Status__c) hed__Application_Status_Label,' +
                    'TB_Status_For_Applicant_EN__c, TB_Status_For_Applicant_PL__c,' +
                    'TB_Applying_To_Offered_Product__r.TB_Course_PL__c, TB_Applying_To_Offered_Product__r.TB_Course_EN__c,' +
                    'TB_Mode_of_Study__c, toLabel(TB_Mode_of_Study__c) TB_Mode_of_Study_Label,' +
                    'TB_x_Mode_of_Study_EN__c, TB_x_Mode_of_Study_PL__c,' +
                    'TB_Level_of_Study__c, toLabel(TB_Level_of_Study__c) TB_Level_of_Study_Label,' +
                    'TB_x_Level_of_Study_EN__c, TB_x_Level_of_Study_PL__c,' +
                    'TB_x_Faculty_EN__c, TB_x_Faculty_PL__c, ' +
                    'TB_x_Campus_EN__c, TB_x_Campus_PL__c, ' +
                    'TB_x_Stage_For_Applicant_EN__c, TB_x_Stage_For_Applicant_PL__c, ' +
                    'TB_Comments_To_Applicant__c, TB_Comments_To_Applicant_Category__c,' +
                    'TB_Product_Group__c';
            dynamicQuery += ' FROM hed__Application__c ' +
                    'WHERE hed__Applicant__c = :applicationContactId';

            if (!isTest) {
                dynamicQuery += ' AND TB_Active__c = true AND TB_Archived__c = false AND TB_Anonymization_Status__c != \'Anonymized\' ';
            }
            dynamicQuery += ' ORDER BY CreatedDate DESC';

            try {
                List<hed__Application__c> applications = Database.query(dynamicQuery);
                return applications;
            } catch (Exception e) {
                insert TB_LogUtils.registerLog(e);
                return null;
            }
        }
    }


    public class ApplicationWrapper
    {
        @AuraEnabled public hed__Application__c app {get;set;}
        @AuraEnabled public String applicationHeader {get;set;}
        @AuraEnabled public Boolean detailsButtonFlag {get;set;}
        @AuraEnabled public Boolean sectionDisplayFlag {get;set;}
        @AuraEnabled public Boolean commentsDisplayFlag {get;set;}
        @AuraEnabled public String commentsCategory {get;set;}
        @AuraEnabled public String commentsDisplayValue {get;set;}
        @AuraEnabled public String commentsStyle {get;set;}
        @AuraEnabled public String commentsVariant {get;set;}
        @AuraEnabled public String commentLabelClass {get;set;}
        public ApplicationWrapper(hed__Application__c application, String languageFlag) {
            this.app = application;
            this.applicationHeader = getHeader(application, languageFlag);
            this.detailsButtonFlag = getDetailsButtonFlag(application.hed__Application_Status__c);
            this.sectionDisplayFlag = getSectionDisplayFlag(application.hed__Application_Status__c);
            this.commentsDisplayFlag = String.isNotBlank(application.TB_Comments_To_Applicant__c);
            this.commentsDisplayValue = getPlainTextValue(application.TB_Comments_To_Applicant__c);
            this.commentsStyle = 'margin-left:0.2em; vertical-align: super;';
            this.commentLabelClass = 'slds-item item-content-gray';
            String commentLabelClassNewComment = 'slds-item item-content';
            String commentCategorySuccess = 'utility:success';
            String commentCategoryWarning = 'utility:warning';
            String commentCategoryError = 'utility:error';
            String commentStyle = 'margin-left:0.2em; vertical-align: super; color:#2e844a!important;';

            if(this.commentsDisplayFlag) {
                this.commentLabelClass = commentLabelClassNewComment;
                switch on application.TB_Comments_To_Applicant_Category__c {
                    when 'Information' {
                        this.commentsCategory = commentCategorySuccess;
                        this.commentsStyle = commentStyle;
                    }
                    when 'Warning' {
                        this.commentsCategory = commentCategoryWarning;
                    }
                    when else {
                        this.commentsCategory = commentCategoryError;
                    }
                }
                this.commentsVariant = this.commentsCategory.substring(8);
            }
        }
    }

    private static String getHeader(hed__Application__c application, String language) {
        String header = '';
        if(application.get('TB_x_Faculty_'+ language +'__c') != null) {
            header += application.get('TB_x_Faculty_'+ language +'__c');
        }
        if(application.get('TB_x_Campus_' + language +'__c') != null) {
            header += ', ' + application.get('TB_x_Campus_' + language +'__c');
        }
        if(application.TB_Level_of_Study__c != null) {
            header += ', ' + application.get('TB_Level_of_Study_Label');
        }
        if(application.TB_Mode_of_Study__c != null) {
            header += ', ' + application.get('TB_Mode_of_Study_Label');
        }
        return header;
    }

    private static Boolean getDetailsButtonFlag(String appStatus) {
        TB_Application_Tiles_Configuration__c applicationStatuses = TB_Application_Tiles_Configuration__c.getOrgDefaults();
        List<String> detailsStatuses = new List<String>();
        if(applicationStatuses.TB_Details_Statuses__c != null) {
            detailsStatuses = applicationStatuses.TB_Details_Statuses__c.split(';');
        }
        return detailsStatuses.contains(appStatus);
    }

    private static String getPlainTextValue(String richTextValue) {
        if (richTextValue != null && richTextValue.contains('<')) {
            String plainText = richTextValue.replaceAll('<[^>]+>', ' ');
            return plainText;
        }
        return null;
    }

    private static Boolean getSectionDisplayFlag(String appStatus) {
        TB_Application_Tiles_Configuration__c applicationStatuses = TB_Application_Tiles_Configuration__c.getOrgDefaults();
        List<String> stageStatuses = new List<String>();
        if(applicationStatuses.TB_Section_Statuses__c != null) {
            stageStatuses = applicationStatuses.TB_Section_Statuses__c.split(';');
        }
        return !(stageStatuses.contains(appStatus));
    }
}