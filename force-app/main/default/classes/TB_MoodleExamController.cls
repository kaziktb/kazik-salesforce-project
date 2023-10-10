public without sharing class TB_MoodleExamController {

    @AuraEnabled
    public static TB_Application_Qualification__c getQualiObject(String applicationId) {
        try {
            hed__Application__c app = [
                    SELECT Id, TB_Qualification__c
                    FROM hed__Application__c
                    WHERE Id = :applicationId
            ];
            return [
                    SELECT
                            TB_Qualification_Available__c,
                            TB_Moodle_Exam_ID__c,
                            TB_Moodle_Exam_Started__c,
                            TB_Moodle_Id__c,
                            TB_Moodle_Password__c,
                            TB_Moodle_Username__c,
                            TB_Qualification_Available_From__c,
                            TB_Qualification_Available_To__c,
                            TB_Moodle_Test_Result_Points__c,
                            TB_Moodle_Test_Result_Percent__c,
                            TB_Qualification_Type__c,
                            TB_Qualification_Requirement__r.TB_Qualification_Type__c
                    From TB_Application_Qualification__c
                    WHERE Id = :app.TB_Qualification__c
                    AND TB_Active__c = TRUE
            ] ;
        } catch (Exception e) {
            throw new AuraHandledException(TB_LogUtils.prepareAuraLog(e.getMessage(), TB_MoodleExamController.class.getName(), e.getStackTraceString(), applicationId));
        }
    }

    @AuraEnabled
    public static TB_Application_Qualification__c getQualiObjectToLang(String applicationId) {
        try{
            return [
                    SELECT
                            TB_Qualification_Available__c,
                            TB_Moodle_Exam_ID__c,
                            TB_Moodle_Exam_Started__c,
                            TB_Moodle_Id__c,
                            TB_Moodle_Password__c,
                            TB_Moodle_Username__c,
                            TB_Qualification_Available_From__c,
                            TB_Qualification_Available_To__c,
                            TB_Moodle_Test_Result_Points__c,
                            TB_Moodle_Test_Result_Percent__c,
                            TB_Qualification_Requirement__r.TB_Qualification_Type__c
                    From TB_Application_Qualification__c
                    WHERE TB_Application__c =: applicationId
                    AND TB_Active__c = TRUE
                    AND TB_Qualification_Type__c=: TB_Constants.TB_APPLICATION_QUALIFICATION_TYPE_LANGUAGE_TEST
                    AND TB_Moodle_Exam_ID__c!=NULL
                    ORDER BY CreatedDate DESC
            ].get(0) ;
        } catch (Exception e) {
            throw new AuraHandledException(TB_LogUtils.prepareAuraLog(e.getMessage(), TB_MoodleExamController.class.getName(), e.getStackTraceString(), applicationId));
        }
    }

    @AuraEnabled
    public static String getOneClickLink(String appQuaId) {
        try {
            TB_Application_Qualification__c appQua = [
                    SELECT
                            TB_Moodle_Id__c,
                            TB_Moodle_Exam_ID__c,
                            TB_Moodle_Username__c,
                            TB_Moodle_Exam_Started__c,
                            TB_Qualification_Available_To__c,
                            TB_Application__r.hed__Applicant__r.Email
                    FROM TB_Application_Qualification__c
                    WHERE ID = :appQuaId
            ];

            TB_MoodleWebService.WrapperClass wrapper = new TB_MoodleWebService.WrapperClass();
            wrapper.courseUrl = appQua?.TB_Moodle_Exam_ID__c;
            wrapper.email = appQua?.TB_Application__r.hed__Applicant__r.Email;
            wrapper.methodToken = TB_MoodleConstants.API_FUNCTION_LOG_USER;
            wrapper.username = appQua?.TB_Moodle_Username__c;
            Map<String, String> result = (Map<String, String>) TB_MoodleWebService.rightMoodleMethod(wrapper, null);
            if (!appQua.TB_Moodle_Exam_Started__c) {
                appQua.TB_Moodle_Exam_Started__c = true;
                update appQua;
            }
            return result.get(TB_MoodleConstants.API_PARAM_LOGIN_URL);
        } catch (Exception e) {
            if (!e.getMessage().contains(TB_Constants.TB_AURA_ERROR_SEPARATOR)) {
                e = new AuraHandledException(TB_LogUtils.prepareAuraLog(e.getMessage(), TB_MoodleExamController.class.getName(), e.getStackTraceString(), appQuaId));
            }
            throw e;
        }
    }

    @AuraEnabled
    public static TB_Application_Qualification__c checkExamResult(String appQuaId, String moodleUserId, String courseId) {
        try {
            TB_MoodleWebService.WrapperClass wrapper = new TB_MoodleWebService.WrapperClass();
            wrapper.moodleUserId = moodleUserId;
            wrapper.courseId = courseId.split('=').get(1).split(TB_MoodleConstants.USER_USERNAME).get(0);
            wrapper.methodToken = TB_MoodleConstants.FUNC_COURSE_RESULT;
            wrapper.appQualId = appQuaId;
            TB_Application_Qualification__c result = (TB_Application_Qualification__c) TB_MoodleWebService.rightMoodleMethod(wrapper, null);
            if (result.TB_Moodle_Test_Result_Percent__c != null) {
                update result;
            }
            return result;
        } catch (Exception e) {
            if (!e.getMessage().contains(TB_Constants.TB_AURA_ERROR_SEPARATOR)) {
                e = new AuraHandledException(TB_LogUtils.prepareAuraLog(e.getMessage(), TB_MoodleExamController.class.getName(), e.getStackTraceString(), appQuaId));
            }
            throw e;
        }
    }

    @AuraEnabled
    public static void resetExam(String recordId){
        try{
        TB_Application_Qualification__c appQ = [
                SELECT
                        Id,
                        TB_Moodle_Id__c,
                        TB_Moodle_Exam_ID__c,
                        TB_Application__r.hed__Applicant__r.FirstName,
                        TB_Application__r.hed__Applicant__r.LastName,
                        TB_Application__r.hed__Applicant__r.Email,
                        TB_Application__r.Name
                From TB_Application_Qualification__c
                WHERE Id = :recordId
        ];
            TB_MoodleWebService.WrapperClass wrapper = new TB_MoodleWebService.WrapperClass();
            wrapper.methodToken = TB_MoodleConstants.FUNC_CREATE_AND_ENROL_USER;
            //wrapper.moodleUserId = appQ.TB_Moodle_Id__c;
            wrapper.courseId = appQ.TB_Moodle_Exam_ID__c.split('=').get(1).split(TB_MoodleConstants.USER_USERNAME).get(0);
            wrapper.appQualId = appQ.Id;
            wrapper.applicationName = appQ.TB_Application__r.Name;
            wrapper.firstname = appQ.TB_Application__r.hed__Applicant__r.FirstName;
            wrapper.lastname = appQ.TB_Application__r.hed__Applicant__r.LastName;
            wrapper.email = appQ.TB_Application__r.hed__Applicant__r.Email;
            Object result = TB_MoodleWebService.rightMoodleMethod(wrapper, null);
            if (result instanceof TB_Application_Qualification__c) {
                TB_Application_Qualification__c appQuaToSave = (TB_Application_Qualification__c) result;
                appQuaToSave.Id = appQ.Id;
                appQuaToSave.TB_Moodle_Test_Result_Percent__c = null;
                appQuaToSave.TB_Moodle_Test_Result_Points__c = null;
                appQuaToSave.TB_Moodle_Exam_Started__c = false;
                update appQuaToSave;
            } else {
                throw new AuraHandledException(TB_LogUtils.prepareAuraLog(TB_MoodleConstants.RESPONSE_INVALID_RESULT, TB_MoodleExamController.class.getName(), '', recordId));
            }

        }catch (Exception e){
            throw new AuraHandledException(TB_LogUtils.prepareAuraLog(e.getMessage(), TB_MoodleExamController.class.getName(), e.getStackTraceString(), recordId));
        }
    }

}