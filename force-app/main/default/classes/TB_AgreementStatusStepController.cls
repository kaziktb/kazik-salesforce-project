public with sharing class TB_AgreementStatusStepController {

    public static final String userIp = !Test.isRunningTest() ? Auth.SessionManagement.getCurrentSession().get(TB_Constants.TB_SESSION_PROPERTY_SOURCE_IP) : '8.8.8.8';

    @AuraEnabled
    public static String getConcludedAgreementUrl(Id applicationId) {
        return TB_AgreementConclusionController.getConcludedAgreementAppDocument(applicationId).TB_Download_URL__c;
    }
    
    @AuraEnabled
    public static void terminateAgreement(Id applicationId, String stepId, String stageId, String browserInfo) {
        hed__Application__c app = [
            SELECT TB_Agreement_Available_Termination_Type__c, TB_Agreement_Status__c,
                TB_x_Application_Status_For_Termination__c, hed__Application_Status__c
            FROM hed__Application__c
            WHERE Id = :applicationId
        ];

        if (app.TB_Agreement_Status__c == TB_Constants.TB_APPLICATION_AGREEMENT_STATUS_TERMINATED) {
            throw new AuraHandledException('You cannot terminate an already terminated agreement');
        }
        app.TB_Agreement_Status__c = TB_Constants.TB_APPLICATION_AGREEMENT_STATUS_TERMINATED;
        app.TB_Agreement_Termination_Type__c = app.TB_Agreement_Available_Termination_Type__c;
        app.TB_Agreement_Terminated_Date_Time__c = Datetime.now();

        update app;

        try {
            insertTerminatedStepHistory(applicationId,stepId,stageId, browserInfo);
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
        }
    }

    private static void insertTerminatedStepHistory(Id applicationId, String stepId, String stageId, String browserInfo) {
        TB_Application_Step_History__c stepHistory = new TB_Application_Step_History__c(
            RecordTypeId = TB_Constants.TB_APP_STEP_HISTORY_AGREEMENT_RT_ID,
            TB_Status__c = TB_Constants.TB_APP_STEP_HISTORY_STATUS_TERMINATED,
            TB_User_Name__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName(),
            TB_User_IP__c = userIp,
            TB_User_Browser__c = browserInfo,
            TB_Event_Date_Time__c = Datetime.now(),
            TB_Application__c = applicationId,
            TB_Admissions_Step__c = stepId,
            TB_Admissions_Stage__c = stageId
        );
        TB_AdmissionsStepHistoryController.insertHistory(stepHistory);
    }
}