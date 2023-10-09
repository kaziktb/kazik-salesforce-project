/**
 * Created by Aneta on 05/01/2022.
 */

public without sharing class TB_RequestModalController {

    public static String COMPLETED_STATUS = 'Completed';
    public static String GRADUATION_STATUS = 'Graduation';
    public static String LEVEL_OF_STUDY_POSTGRAD = 'Postgraduate';
    @AuraEnabled
    public static String getApplicationForRequest(String applicationId, Boolean isForEducation) {
        try {
            TB_Admissions_Dictionary__c request = getRequiredRequest();
            hed__Application__c application = [
                    SELECT Name, hed__Applicant__c, TB_Product_Group__c, TB_Product_Name__c,
                            TB_No_Diploma__c, TB_No_Diploma_Request_Sent__c, TB_Active__c,
                            hed__Application_Status__c, TB_Communication_Language__c,
                            TB_x_Campus_PL__c, TB_x_Campus_EN__c,
                            TB_Mode_of_Study__c, toLabel(TB_Mode_of_Study__c) TB_Mode_of_Study_Label,
                            TB_x_Level_of_Study_EN__c, TB_x_Level_of_Study_PL__c,
                            TB_Level_of_Study__c, toLabel(TB_Level_of_Study__c) TB_Level_of_Study_Label,
                            TB_No_Other_Education__c, TB_No_Required_Diploma__c, TB_Renewal__c
                    FROM hed__Application__c
                    WHERE Id = :applicationId
            ];
            Boolean isRequiredRequest = handleIsNoDiplomaRequest(application, isForEducation) && request != null;
            ApplicationWrapper applicationWrapper = new ApplicationWrapper(application, isRequiredRequest, request);
            return JSON.serialize(applicationWrapper);
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return 'EXCEPTION_FROM_GET_APPLICATION_REQUEST';
        }
    }

    @AuraEnabled
    public static Boolean handleIsNoDiplomaRequest(hed__Application__c application, Boolean isForEducation) {
        if(application.TB_Active__c
                && !application.TB_No_Diploma_Request_Sent__c
                && application.TB_Level_of_Study__c == LEVEL_OF_STUDY_POSTGRAD
                && !application.TB_Renewal__c
                && matchApplicationStatus(application.hed__Application_Status__c)
        ) {
            if(application.TB_No_Required_Diploma__c) {
                return true;
            }else {
                return isForEducation ? checkEducationHistory(application) : false;
            }
        }else {
            return false;
        }
    }

    private static Boolean checkEducationHistory(hed__Application__c application) {
        Map<Id,Contact> individualContacts = TB_EducationHistoryController.getContactsFromIndividual(application.hed__Applicant__c);
        if([
                SELECT Id
                FROM hed__Education_History__c
                WHERE (hed__Contact__c =: application.hed__Applicant__c OR hed__Contact__c IN: individualContacts.keySet())
                AND TB_SWPS_Education__c = TRUE
                AND hed__Status__c IN: new List<String>{ COMPLETED_STATUS, GRADUATION_STATUS}
        ].size() > 0) {
            return false;
        }else if(!application.TB_No_Other_Education__c && [
                SELECT Id
                FROM TB_Experience_History__c
                WHERE TB_Application__c =: application.Id
                AND TB_Not_Diploma__c = FALSE
        ].size() > 0) {
            return false;
        }else {
            return true;
        }
    }

    private static Boolean matchApplicationStatus(String status) {
        List<String> applicationStatuses = new List<String>{'Accepted','Conditionally_Accepted','Cancelled','Revoked'};
        return !(applicationStatuses.contains(status));
    }

    private static TB_Admissions_Dictionary__c getRequiredRequest() {
        List<TB_JSON_Wrapper__c> jsonWrappers = [
                SELECT TB_Wrapper_Value__c, TB_Object_API_Name__c, TB_Record_Type_Dev_Name__c
                FROM TB_JSON_Wrapper__c
                WHERE TB_Object_API_Name__c = 'TB_Admissions_Dictionary__c'
                AND TB_Record_Type_Dev_Name__c = 'TB_Application_Request'
        ];
        List<TB_Admissions_Dictionary__c> requests = new List<TB_Admissions_Dictionary__c>();
        for(TB_JSON_Wrapper__c singleWrapper : jsonWrappers) {
            TB_Admissions_Dictionary__c singleDictionary = (TB_Admissions_Dictionary__c) JSON.deserialize(singleWrapper.TB_Wrapper_Value__c, TB_Admissions_Dictionary__c.class);
            if(singleDictionary.TB_Active__c && singleDictionary.TB_Request__c
                    && matchDates(singleDictionary.TB_Valid_From__c, singleDictionary.TB_Valid_To__c)
            ) {
                requests.add(singleDictionary);
            }
        }
        switch on requests.size() {
            when 0 {
                return null;
            }
            when 1 {
                return requests[0];
            }
            when else {
                return getLatestRequest(requests);
            }
        }
    }

    private static TB_Admissions_Dictionary__c getLatestRequest(List<TB_Admissions_Dictionary__c> requests) {
        TB_Admissions_Dictionary__c latestRecord = new TB_Admissions_Dictionary__c();
        latestRecord = requests[0];

        for(TB_Admissions_Dictionary__c singleRequest : requests) {
            if(singleRequest.LastModifiedDate > latestRecord.LastModifiedDate) {
                latestRecord = singleRequest;
            }
        }
        return latestRecord;
    }

    private static Boolean matchDates(Date validFrom, Date validTo) {
        return validFrom <= Date.today() && validTo >= Date.today();
    }

    public class ApplicationWrapper {
        @AuraEnabled public hed__Application__c application {get;set;}
        @AuraEnabled public String applicationHeader {get;set;}
        @AuraEnabled public Boolean isRequiredRequest {get;set;}
        @AuraEnabled public TB_Admissions_Dictionary__c request {get;set;}

        public ApplicationWrapper(hed__Application__c application, Boolean isRequiredRequest, TB_Admissions_Dictionary__c request) {
            this.application = application;
            this.isRequiredRequest = isRequiredRequest;
            this.applicationHeader = TB_SObjectUtils.getApplicationHeader(application, application.TB_Communication_Language__c);
            this.request = request;
        }
    }

    @AuraEnabled
    public static String updateApplicationNoDiplomaRequestCheckbox(String applicationId) {
        hed__Application__c application = new hed__Application__c(
                Id = applicationId,
                TB_No_Diploma_Request_Sent__c = true
        );
        try {
            update application;
            return 'SUCCESS';
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return 'FAILED';
        }
    }
}