/**
 * Created by Aneta on 08/10/2021.
 */

public without sharing class TB_CancelApplicationController {

    static String CANCEL_APP_EXCEPTION = 'CANCEL_APPLICATION.EXCEPTION';
    static String CANCEL_APP_SUCCESS = 'CANCEL_APPLICATION.SUCCESS';
    @AuraEnabled
    public static List<AdmissionReasonWrapper> getResignationReasons() {

        List<AdmissionReasonWrapper> reasonWrappers = new List<AdmissionReasonWrapper>();
        for(TB_Admissions_Dictionary__c singleDictionary : [
                SELECT Id, TB_Display_Name_PL__c, TB_Display_Name_EN__c, Name
                FROM TB_Admissions_Dictionary__c
                WHERE TB_Active__c =: true
                AND RecordTypeId =: TB_Constants.ADMISSIONS_DICTIONARY_RT_RESIGNATION_REASON_ID
                ORDER BY TB_Order__c
        ]) {
            AdmissionReasonWrapper singleWrapper = new AdmissionReasonWrapper(singleDictionary);
            reasonWrappers.add(singleWrapper);
        }
        return reasonWrappers;
    }

    @AuraEnabled
    public static String cancelApplication(String applicationId, String resignationReasonId, String resignationDetailsInfo) {
        try {
            hed__Application__c application = [SELECT hed__Application_Status__c FROM hed__Application__c WHERE Id = :applicationId];
            application.TB_Application_Status_On_Cancel__c = application.hed__Application_Status__c;
            application.TB_Resignation_Reason_Id__c = resignationReasonId;
            application.TB_Resignation_Reason_Details__c = resignationDetailsInfo;
            application.hed__Application_Status__c = TB_Constants.TB_APPLICATION_STATUS_CANCELLED;
            application.TB_Cancellation_Date_Time__c = System.now();
            update application;
            return CANCEL_APP_SUCCESS;
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return CANCEL_APP_EXCEPTION;
        }
    }

    @AuraEnabled
    public static List<String> getStatusesForCancelApplication() {
        try {
            List<String> detailsStatuses = new List<String>();
            TB_Application_Tiles_Configuration__c applicationStatuses = TB_Application_Tiles_Configuration__c.getOrgDefaults();
            if (applicationStatuses.TB_Details_Statuses__c != null) {
                detailsStatuses = applicationStatuses.TB_Details_Statuses__c.split(';');
            }
            return detailsStatuses;
        }catch(Exception e) {
            return null;
        }
    }

    public class AdmissionReasonWrapper {
        @AuraEnabled public TB_Admissions_Dictionary__c reason {get;set;}

        public AdmissionReasonWrapper(TB_Admissions_Dictionary__c reason) {
            this.reason = reason;
        }
    }
}