/**
 * Created by jowitakozlak on 01/09/2021.
 */

public without sharing class TB_AdmissionsFormsController {
    public static final String userIp = !Test.isRunningTest() ? Auth.SessionManagement.getCurrentSession().get(TB_Constants.TB_SESSION_PROPERTY_SOURCE_IP) : '8.8.8.8';

  static Map<String, String> stepTypeToComponent = new Map<String, String>{
    'Admissions_Fee' => 'paymentComponent',
    'Final_Verification' => 'verificationComponent',
    'Final_Verification_In_Progress' => 'verificationComponent',
    'PD_Verification' => 'verificationComponent',
    'PD_Verification_In_Progress' => 'verificationComponent',
    'PEU_Verification' => 'verificationComponent',
    'PEU_Verification_In_Progress' => 'verificationComponent',
    'Verification' => 'verificationComponent',
    'Verification_In_Progress' => 'verificationInProgressComponent',
    'Information' => 'informationComponent',
    'Verification_Result' => 'verificationComponent',
    'Address_Data' => 'addressComponent',
    'Higher_Education' => 'educationComponent',
    'Higher_Education_Postgrad' => 'educationComponent',
    'Payment_Tuition_Fee' => 'tuitionComponent',
    'HS_Exam_Diploma' => 'maturityExam',
    'HS_Exam_Score' => 'maturityExamScores',
    'Language_Certificates' => 'languageCertificates',
    'Document_Collection' => 'documentsToDownloadComponent',
    'PD_Results' => 'programDifferencesComponent',
    'Photo' => 'photoComponent',
    'Scholarships' => 'scholarshipComponent',
    'Current_Clinical_Workplace' => 'currentClinicalWorkplaceComponent',
    'Clinical_Experience_Prior_MA' => 'clinicalExperiencePriorMAComponent',
    'Clinical_Experience_After_MA' => 'clinicalExperienceAfterMAComponent',
    'Clinical_Interest_Prior_MA' => 'clinicalInterestPriorMAComponent',
    'Clinical_Interest_After_MA' => 'clinicalInterestAfterMAComponent',
    'CB_Psychology_Interest_Prior_MA' => 'CBPsychologyInterestPriorMAComponent',
    'CB_Psychology_Interest_After_MA' => 'CBPsychologyInterestAfterMAComponent',
    'Interview' => 'qualificationComponent',
    'Exam_Written' => 'qualificationComponent',
    'Exam_Oral' => 'qualificationComponent',
    'Moodle_Exam' => 'moodleOnlineExam',
    'Placement_Test' => 'moodleLangExam',
    'Placement_Test_Moodle' => 'moodleLangExamMoodle',
    'Agreement' => 'agreementConclusionComponent',
    'Agreement_Status' => 'agreementStatusComponent',
    'Interest_Examination_Reserve_List' => 'interestExaminationReserveListComponent',
    'Recommendation_Summer_Prep' => 'recommendationSummerPrepComponent',
    'Recommendation_Declined' => 'recommendationDeclinedComponent',
    'PhotoUpload' => 'photoUploadComponent',
    'Decision' => 'decisionComponent',
    'Survey' => 'admissionsSurvey',
    'PD_Multi_Document_Collection' => 'pdMultiDocumentComponent',
    'Language_Selection' => 'languageCourseSelection',
    'PD_Decision' => 'specializationChoice',
    'Personal_Information_View' => 'personalInformationView',
    'Address_Information_View' => 'addressInformationView'
  };

    public static List<TB_Application_Step_History__c> stepsHistory = new List<TB_Application_Step_History__c>();

    @AuraEnabled
    public static hed__Application__c getApplication (String applicationId) {
        return TB_ApplicationRetriever.retrieveAllApplicationFields(applicationId);
    }

    @AuraEnabled
    public static Boolean disableAdmissionsLogic () {
        TB_Admissions_Logic_Disable__c customSetting = TB_Admissions_Logic_Disable__c.getInstance(UserInfo.getUserId());
        if (customSetting != null) {
            return customSetting.TB_Disable_Logic__c;
        } else {
            return false;
        }
    }

    @AuraEnabled
    public static String getRedirectLogics(hed__Application__c application) {
        List<TB_JSON_Wrapper__c> jsonWrappers = [
            SELECT Id, TB_Wrapper_Value__c
            FROM TB_JSON_Wrapper__c
            WHERE TB_Parent_JSON_Wrapper__r.TB_Object_Id__c = :application.TB_Admissions_Process_Id__c
            AND TB_Record_Type_Dev_Name__c = 'TB_Redirect_Logic'
            ORDER BY TB_Order__c
        ];

        Set<TB_Admissions_Logic__c> admissionsLogics = new Set<TB_Admissions_Logic__c>();
        for (TB_JSON_Wrapper__c jsonWrapper : jsonWrappers) {
            TB_Admissions_Logic__c admissionsLogic = (TB_Admissions_Logic__c) JSON.deserialize(
                jsonWrapper.TB_Wrapper_Value__c, TB_Admissions_Logic__c.class
            );
            if (admissionsLogic.TB_Active__c == true) {
                admissionsLogics.add(admissionsLogic);
            }
        }

        return JSON.serialize(admissionsLogics);
    }

    @AuraEnabled
    public static String getAdmissionsStages (hed__Application__c application) {

        String recordTypeId = TB_SObjectUtils.getRecordTypeIdByDevName('TB_Application_Step_History__c','TB_Step_Status_History');
        stepsHistory = [
            SELECT Id, TB_Admissions_Stage__c, TB_Admissions_Step__c, TB_Comments__c, TB_Status__c
            FROM TB_Application_Step_History__c
            WHERE TB_Application__c = :application.Id
            AND RecordTypeId = :recordTypeId
            ORDER BY CreatedDate DESC
        ];
        List<TB_JSON_Wrapper__c> jsonWrappers = [
            SELECT Id, TB_Wrapper_Value__c
            FROM TB_JSON_Wrapper__c
            WHERE TB_Parent_JSON_Wrapper__r.TB_Object_Id__c = :application.TB_Admissions_Process_Id__c
            AND TB_Record_Type_Dev_Name__c = 'TB_Admissions_Stage'
            ORDER BY TB_Order__c
        ];
        List<Id> admissionsStagesIds = new List<Id>();

        Set<TB_Admissions_Process__c> admissionsStages = new Set<TB_Admissions_Process__c>();
        for (TB_JSON_Wrapper__c jsonWrapper : jsonWrappers) {
            TB_Admissions_Process__c admissionsStage = (TB_Admissions_Process__c) JSON.deserialize(
                jsonWrapper.TB_Wrapper_Value__c, TB_Admissions_Process__c.class
            );
            if (admissionsStage.TB_Active__c == true) {
                admissionsStages.add(admissionsStage);
                admissionsStagesIds.add(admissionsStage.Id);
            }
        }

        List<TB_JSON_Wrapper__c> jsonStepWrappers = [
            SELECT Id, TB_Wrapper_Value__c, TB_Parent_JSON_Wrapper__r.TB_Object_Id__c
            FROM TB_JSON_Wrapper__c
            WHERE TB_Parent_JSON_Wrapper__r.TB_Object_Id__c IN :admissionsStagesIds
            ORDER BY TB_Order__c
        ];
        Map<Id,Set<TB_Admissions_Process__c>> stageIdToSteps = new Map<Id,Set<TB_Admissions_Process__c>>();
        for(TB_Admissions_Process__c admissionsStage : admissionsStages) {

            Set<TB_Admissions_Process__c> admissionsSteps = new Set<TB_Admissions_Process__c>();
            for (TB_JSON_Wrapper__c singleWrapper : jsonStepWrappers) {

                TB_Admissions_Process__c admissionsStep = (TB_Admissions_Process__c) JSON.deserialize(
                    singleWrapper.TB_Wrapper_Value__c, TB_Admissions_Process__c.class
                );
                if (admissionsStep.TB_Active__c == true) {
                    if (singleWrapper.TB_Parent_JSON_Wrapper__r.TB_Object_Id__c == admissionsStage.Id) {
                        if (admissionsStep.TB_Step_Type__c != 'Language_Selection' || TB_LanguageCourseSelection.hasCourses(application.Id)) {
                            admissionsSteps.add(admissionsStep);
                        }
                    }
                }
            }
            stageIdToSteps.put(admissionsStage.Id, admissionsSteps);
        }

        List<AdmissionsStagesWrapper> stagesWrappers = new List<AdmissionsStagesWrapper>();
        for (TB_Admissions_Process__c admissionsStage : admissionsStages) {
            AdmissionsStagesWrapper singleWrapper = new AdmissionsStagesWrapper(admissionsStage);
            if (String.isNotBlank(admissionsStage.TB_Display_Logic__c)) {
                singleWrapper.jsonDisplay = admissionsStage.TB_Display_Logic_JSON__c;
            }
            if (String.isNotBlank(admissionsStage.TB_Edit_Logic__c)) {
                singleWrapper.jsonEdit = admissionsStage.TB_Edit_Logic_JSON__c;
            }
            singleWrapper.setAdmissionsSteps(getAdmissionsSteps(
                new List<TB_Admissions_Process__c>(stageIdToSteps.get(singleWrapper.ap.Id)),
                singleWrapper
            ));
            stagesWrappers.add(singleWrapper);
        }
        return JSON.serialize(stagesWrappers);
    }

    @AuraEnabled
    public static List<AdmissionsStepsWrapper> getAdmissionsSteps (
        List<TB_Admissions_Process__c> admissionsSteps,
        AdmissionsStagesWrapper stageWrapper
    ) {
        Integer stepsExpected = admissionsSteps.size();
        Map<Id,List<String>> stageStepIdToStatus = getStepsHistory(stepsHistory, stageWrapper, stepsExpected);

        List<AdmissionsStepsWrapper> stepsWrappers = new List<AdmissionsStepsWrapper>();
        if (stageStepIdToStatus.isEmpty()) {
            for (TB_Admissions_Process__c admissionsStep : admissionsSteps) {
                AdmissionsStepsWrapper singleWrapper = new AdmissionsStepsWrapper(
                    admissionsStep, true, false, false
                );
                if (String.isNotBlank(admissionsStep.TB_Display_Logic__c)) {
                    singleWrapper.jsonDisplay = admissionsStep.TB_Display_Logic_JSON__c;
                }
                if (String.isNotBlank(admissionsStep.TB_Edit_Logic__c)) {
                    singleWrapper.jsonEdit = admissionsStep.TB_Edit_Logic_JSON__c;
                }
                stepsWrappers.add(singleWrapper);
            }
        } else {
            for (TB_Admissions_Process__c admissionsStep : admissionsSteps) {
                String status = '';
                if (stageStepIdToStatus.get(admissionsStep.Id) != null) {
                    status = stageStepIdToStatus.get(admissionsStep.Id)[0];
                }

                AdmissionsStepsWrapper singleWrapper;
                if (status == 'To_Correct') {
                    singleWrapper = new AdmissionsStepsWrapper(
                        admissionsStep, false, false, true
                    );
                    if (String.isNotBlank(stageStepIdToStatus.get(admissionsStep.Id)[1])) {
                        singleWrapper.comments = stageStepIdToStatus.get(admissionsStep.Id)[1];
                        if (stageStepIdToStatus.get(admissionsStep.Id)[1].contains('<')) {
                            String commentsWithoutMarkers
                                = stageStepIdToStatus.get(admissionsStep.Id)[1].replaceAll('<[^>]+>',' ');
                            singleWrapper.clearComments = commentsWithoutMarkers;
                        } else {
                            singleWrapper.clearComments = singleWrapper.comments;
                        }
                    }
                } else if (String.isBlank(status) || status == 'In_Progress') {
                    singleWrapper = new AdmissionsStepsWrapper(
                        admissionsStep, true, false, false
                    );
                } else {
                    singleWrapper = new AdmissionsStepsWrapper(
                        admissionsStep, false, true, false
                    );
                }
                if (String.isNotBlank(admissionsStep.TB_Display_Logic__c)) {
                    singleWrapper.jsonDisplay = admissionsStep.TB_Display_Logic_JSON__c;
                }
                if (String.isNotBlank(admissionsStep.TB_Edit_Logic__c)) {
                    singleWrapper.jsonEdit = admissionsStep.TB_Edit_Logic_JSON__c;
                }
                stepsWrappers.add(singleWrapper);
            }
        }

        return stepsWrappers;
    }

    //be cautious with required steps
    @AuraEnabled
    public static Map<Id,List<String>> getStepsHistory (
        List<TB_Application_Step_History__c> stepsHistory,
        AdmissionsStagesWrapper stageWrapper,
        Integer stepsExpected
    ) {
        List<TB_Application_Step_History__c> stageStepsHistory = new List<TB_Application_Step_History__c>();
        Set<Id> stepsAlreadyAdded = new Set<Id>();
        for (TB_Application_Step_History__c stepHistory : stepsHistory) {
            if (
                stepHistory.TB_Admissions_Stage__c == stageWrapper.ap.Id
                && !stepsAlreadyAdded.contains(stepHistory.TB_Admissions_Step__c)
            ) {
                stageStepsHistory.add(stepHistory);
                stepsAlreadyAdded.add(stepHistory.TB_Admissions_Step__c);
            }
        }

        Map<Id,List<String>> stageStepIdToStatus = new Map<Id,List<String>>();
        for (TB_Application_Step_History__c stageStepHistory : stageStepsHistory) {
            stageStepIdToStatus.put(
                stageStepHistory.TB_Admissions_Step__c,
                new List<String>{stageStepHistory.TB_Status__c, stageStepHistory.TB_Comments__c}
            );
        }

//        Boolean stepsCompleted = true;
        for (TB_Application_Step_History__c stageStepHistory : stageStepsHistory) {
            if(stageStepHistory.TB_Status__c == 'To_Correct') {
//                stepsCompleted = false;
                stageWrapper.fixNeeded = true;
                break;
            }
        }
//        stageWrapper.stepsCompleted = stepsCompleted && stepsExpected == stageStepsHistory.size();

        return stageStepIdToStatus;
    }

    @AuraEnabled
    public static void createStepHistory (String applicationId, String stageId, String stepId, String stepData, String status, String browserInfo) {

        String recordTypeId = TB_SObjectUtils.getRecordTypeIdByDevName('TB_Application_Step_History__c','TB_Step_Status_History');
        List<TB_Application_Step_History__c> stepHistory;
        stepHistory = [
            SELECT Id
            FROM TB_Application_Step_History__c
            WHERE TB_Application__c = :applicationId
            AND TB_Admissions_Step__c = :stepId
            AND TB_Admissions_Stage__c = :stageId
            AND RecordTypeId = :recordTypeId
            ORDER BY CreatedDate DESC
        ];
        if (stepHistory.size() > 0) {
            stepHistory[0].TB_Status__c = status;
            stepHistory[0].TB_Step_Data__c = stepData;
            stepHistory[0].TB_User_Name__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
            stepHistory[0].TB_User_IP__c = userIp;
            stepHistory[0].TB_User_Browser__c = browserInfo;
            stepHistory[0].TB_Event_Date_Time__c = Datetime.now();
        } else {
            TB_Application_Step_History__c singleStepHistory = new TB_Application_Step_History__c(
                TB_Application__c = applicationId,
                TB_Admissions_Stage__c = stageId,
                TB_Admissions_Step__c = stepId,
                TB_Status__c = status,
                TB_Step_Data__c = stepData,
                TB_User_Name__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName(),
                TB_User_IP__c = userIp,
                TB_User_Browser__c = browserInfo,
                TB_Event_Date_Time__c = Datetime.now(),
                RecordTypeId = recordTypeId
            );
            stepHistory.add(singleStepHistory);
        }

        try {
            upsert stepHistory;
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e, TB_AdmissionsFormsController.class);
        }
    }

    @AuraEnabled
    public static Boolean blockFormAbsolutely(hed__Application__c application) {

        List<TB_Admissions_Read_Only_Status__mdt> statuses = TB_Admissions_Read_Only_Status__mdt.getAll().values();
        List<String> statusApiNames = new List<String>();
        for (TB_Admissions_Read_Only_Status__mdt status : statuses) {
            statusApiNames.add(status.DeveloperName);
        }
        if (statusApiNames.contains(application.hed__Application_Status__c)) {
            return true;
        } else {
            return false;
        }
    }
    @AuraEnabled
    public static String registerLastActionsOnApplication(hed__Application__c application, String action, String data, String stepId) {

        try {
            hed__Application__c newApplication = new hed__Application__c(Id=application.Id);
            Contact newContact = new Contact(Id=application.hed__Applicant__c);
            String currentUserId = UserInfo.getUserId();
            User currentUser = [SELECT Id, ContactId, Contact.TB_Test__c FROM User WHERE Id = :currentUserId];
            Datetime actionDatetime = System.now();
            if (action == 'update' || action == 'partial_update') {
                if (currentUser.ContactId == application.hed__Applicant__c) { //will admins update apps?
                    newApplication.TB_Last_Updated__c = actionDatetime;
                    newApplication.TB_Admissions_Step__c = stepId;
                }
                if (action == 'update' && String.isNotBlank(data)) {
                    updateStatus(data, newApplication, newContact);
                    if (data.contains('Contact.')) {
                        update newContact;
                    }
                }
                update newApplication;
            } else if (action == 'visit') {
                if (currentUser.ContactId == application.hed__Applicant__c) {
                    newApplication.TB_Last_Visited__c = actionDatetime;
                    update newApplication;
                }
            }

            return '200';
        } catch (Exception e) {
            return '500';
        }
    }

    public static void updateStatus(String data, hed__Application__c app, Contact con) {
        List<String> dataParts = data.split(';');
        for (String dataPart : dataParts) {
            String value;
            if (dataPart.substringAfter('=') == 'NULL' || dataPart.substringAfter('=') == 'BLANK') {
                value = null;
            } else {
                value = dataPart.substringAfter('\'').substringBefore('\'');
            }
            if (dataPart.contains('.')) {
                String objectName = dataPart.substringBefore('.');
                String fieldName = dataPart.substringAfter('.').substringBefore('=').trim();
                if (objectName == 'Contact') {
                    con.put(fieldName,value);
                } else if (objectName == 'Application') {
                    app.put(fieldName,value);
                }
            } else {
                String fieldName = dataPart.substringBefore('=');
                app.put(fieldName,value);
            }
        }
    }

    @AuraEnabled
    public static String clearComment(hed__Application__c application) {

        try {
            hed__Application__c newApplication = new hed__Application__c(Id=application.Id);
            newApplication.TB_Comments_To_Applicant__c = null;
            newApplication.TB_Comments_To_Applicant_Category__c = null;
            newApplication.TB_Comments_To_Applicant_Sent_On__c = null;
            update newApplication;

            return '200';
        } catch (Exception e) {
            return '500';
        }
    }

    @AuraEnabled
    public static Boolean validateExamResult(hed__Application__c application) {
        hed__Application__c app = [SELECT
                TB_Applicant_Citizenship__c,
                TB_Applying_To_Offered_Product__c,
                TB_HS_Exam_Score_Top_2__c,
                TB_HS_Exam_Type__c,
                TB_No_HS_Exam__c,
                TB_PD_Opt_In__c,
                TB_No_Exam_Type_Conversion__c

        FROM hed__Application__c
        WHERE Id =: application.Id];
        Boolean isPassed = true;
        Id offeredProductWrapperId = [SELECT Id From TB_JSON_Wrapper__c WHERE TB_Object_Id__c = :app.TB_Applying_To_Offered_Product__c]?.Id;
        if (offeredProductWrapperId != null) {
            List<TB_JSON_Wrapper__c> qualificationWrapperObjs = [
                SELECT TB_Wrapper_Value__c
                FROM TB_JSON_Wrapper__c
                WHERE TB_Parent_JSON_Wrapper__c = :offeredProductWrapperId
                AND TB_Object_API_Name__c = :TB_Qualification_Requirement__c.SObjectType.getDescribe().name
                AND TB_Record_Type_Dev_Name__c = :TB_Constants.TB_QUA_REQ_MIN_REC_TYPE_NAME
            ];
            for (TB_JSON_Wrapper__c qWrapper : qualificationWrapperObjs) {
                Map<String, Object> qualificationRecordMap = (Map<String, Object>) JSON.deserializeUntyped(qWrapper.TB_Wrapper_Value__c);
                if (
                        !app.TB_No_HS_Exam__c &&
                        !app.TB_PD_Opt_In__c &&
                        !app.TB_No_Exam_Type_Conversion__c &&
                        Boolean.valueOf(qualificationRecordMap.get(TB_Qualification_Requirement__c.fields.TB_Active__c.getDescribe().name))
                        && (app.TB_HS_Exam_Type__c == qualificationRecordMap.get(TB_Qualification_Requirement__c.TB_HS_Exam_Type__c.getDescribe().name)
                                || qualificationRecordMap.get(TB_Qualification_Requirement__c.TB_HS_Exam_Type__c.getDescribe().name) == null)
                        ) {
                    if (validateCitizenshipToStudyType(app.TB_Applicant_Citizenship__c, String.valueOf(qualificationRecordMap.get(TB_Qualification_Requirement__c.TB_Citizenship_Dependency__c.getDescribe().name)))) {
                        isPassed = app.TB_HS_Exam_Score_Top_2__c >= (Decimal) qualificationRecordMap.get(TB_Qualification_Requirement__c.TB_HS_Exam_Points__c.getDescribe().name);
                        break;
                    }
                }
            }
        }
        return isPassed;
    }

    private static Boolean validateCitizenshipToStudyType(String appCitizenship, String qualificationCitizenship) {
        Boolean isValidate = true;
        Set<String> polishCitizenship = new Set<String>{
            TB_Constants.TB_APP_APPLICANT_CITIZENSHIP_POLAND, 'PL'
        };
        if (qualificationCitizenship == TB_Constants.TB_QUA_REQ_CITIZENSHIP_DEPENDENCY_POL) {
            isValidate = polishCitizenship.contains(appCitizenship);
        } else if (qualificationCitizenship == TB_Constants.TB_QUA_REQ_CITIZENSHIP_DEPENDENCY_NON_POL) {
            isValidate = !polishCitizenship.contains(appCitizenship);
        }
        return isValidate;
    }

    public class AdmissionsStagesWrapper
    {
        @AuraEnabled public TB_Admissions_Process__c ap {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String nameLabel {get;set;}
        @AuraEnabled public List<AdmissionsStepsWrapper> admissionsSteps {get;set;}
        @AuraEnabled public Boolean stepsCompleted {get;set;}
        @AuraEnabled public Boolean stepsAheadCompleted {get;set;}
        @AuraEnabled public Integer lastActiveStepIndex {get;set;}
        @AuraEnabled public Boolean fixNeeded {get;set;}
        @AuraEnabled public String jsonDisplay {get;set;}
        @AuraEnabled public String jsonEdit {get;set;}
        @AuraEnabled public Boolean letDisplay {get;set;}
        @AuraEnabled public Boolean letEdit {get;set;}

        public AdmissionsStagesWrapper(TB_Admissions_Process__c ap)
        {
            this.ap = ap;
            this.name = ap.Name;
            this.nameLabel = '';
            this.stepsCompleted = false;
            this.stepsAheadCompleted = false;
            this.lastActiveStepIndex = 0;
            this.fixNeeded = false;
            this.letDisplay = false;
            this.letEdit = false;
            this.jsonDisplay = '';
            this.jsonEdit = '';
        }

        public void setAdmissionsSteps(List<AdmissionsStepsWrapper> admissionsSteps)
        {
            this.admissionsSteps = admissionsSteps;
        }
    }

  public class AdmissionsStepsWrapper {
    @AuraEnabled
    public TB_Admissions_Process__c ap { get; set; }
    @AuraEnabled
    public Boolean isGray { get; set; }
    @AuraEnabled
    public Boolean isActive { get; set; }
    @AuraEnabled
    public Boolean isCompleted { get; set; }
    @AuraEnabled
    public Boolean isError { get; set; }
    @AuraEnabled
    public String IdGray { get; set; }
    @AuraEnabled
    public String IdActive { get; set; }
    @AuraEnabled
    public String IdCompleted { get; set; }
    @AuraEnabled
    public String IdError { get; set; }
    @AuraEnabled
    public Boolean wasCompleted { get; set; }
    @AuraEnabled
    public Boolean wasError { get; set; }
    @AuraEnabled
    public Boolean wasGray { get; set; }
    @AuraEnabled
    public Boolean personalInformationView { get; set; }
    @AuraEnabled
    public Boolean addressInformationView { get; set; }
    @AuraEnabled
    public Boolean genericComponent { get; set; }
    @AuraEnabled
    public Boolean paymentComponent { get; set; }
    @AuraEnabled
    public Boolean verificationComponent { get; set; }
    @AuraEnabled
    public Boolean addressComponent { get; set; }
    @AuraEnabled
    public Boolean educationComponent { get; set; }
    @AuraEnabled
    public Boolean languageCertificatesComponent { get; set; }
    @AuraEnabled
    public Boolean verificationInProgressComponent { get; set; }
    @AuraEnabled
    public Boolean informationComponent { get; set; }
    @AuraEnabled
    public Boolean tuitionComponent { get; set; }
    @AuraEnabled
    public Boolean maturityExam { get; set; }
    @AuraEnabled
    public Boolean maturityExamScores { get; set; }
    @AuraEnabled
    public String comments { get; set; }
    @AuraEnabled
    public String clearComments { get; set; }
    @AuraEnabled
    public String jsonDisplay { get; set; }
    @AuraEnabled
    public String jsonEdit { get; set; }
    @AuraEnabled
    public Boolean letDisplay { get; set; }
    @AuraEnabled
    public Boolean letEdit { get; set; }
    @AuraEnabled
    public Boolean photoComponent { get; set; }
    @AuraEnabled
    public Boolean documentsToDownloadComponent { get; set; }
    @AuraEnabled
    public Boolean programDifferencesComponent {get;set;}
    @AuraEnabled
    public Boolean scholarshipComponent { get; set; }
    @AuraEnabled
    public Boolean currentClinicalWorkplaceComponent { get; set; }
    @AuraEnabled
    public Boolean clinicalExperiencePriorMAComponent { get; set; }
    @AuraEnabled
    public Boolean clinicalExperienceAfterMAComponent { get; set; }
    @AuraEnabled
    public Boolean clinicalInterestPriorMAComponent { get; set; }
    @AuraEnabled
    public Boolean clinicalInterestAfterMAComponent { get; set; }
    @AuraEnabled
    public Boolean CBPsychologyInterestPriorMAComponent { get; set; }
    @AuraEnabled
    public Boolean CBPsychologyInterestAfterMAComponent { get; set; }
    @AuraEnabled
    public Boolean qualificationComponent { get; set; }
    @AuraEnabled
    public Boolean moodleOnlineExam { get; set; }
    @AuraEnabled
    public Boolean moodleLangExam { get; set; }
    @AuraEnabled
    public Boolean moodleLangExamMoodle { get; set; }
    @AuraEnabled
    public Boolean agreementConclusionComponent { get; set; }
    @AuraEnabled
    public Boolean agreementStatusComponent { get; set; }
    @AuraEnabled
    public Boolean interestExaminationReserveListComponent { get; set; }
    @AuraEnabled
    public Boolean recommendationSummerPrepComponent { get; set; }
    @AuraEnabled
    public Boolean recommendationDeclinedComponent { get; set; }
    @AuraEnabled
    public Boolean photoUploadComponent { get; set; }
    @AuraEnabled
    public Boolean decisionComponent { get; set; }
    @AuraEnabled
    public Boolean admissionsSurvey { get; set; }
    @AuraEnabled
    public Boolean pdMultiDocumentComponent { get; set; }
    @AuraEnabled
    public Boolean languageCourseSelection { get; set; }
    @AuraEnabled
    public Boolean specializationChoice { get; set; }

    public AdmissionsStepsWrapper(
      TB_Admissions_Process__c ap,
      Boolean isGray,
      Boolean isCompleted,
      Boolean isError
    ) {
      this.ap = ap;
      this.isActive = false;
      this.isCompleted = isCompleted;
      this.isError = isError;
      this.isGray = isGray;
      this.IdGray = ap.Id + 'G';
      this.IdActive = ap.Id + 'A';
      this.IdCompleted = ap.Id + 'C';
      this.IdError = ap.Id + 'E';
      this.wasCompleted = this.isCompleted;
      this.wasError = this.isError;
      this.wasGray = this.isGray;
      this.personalInformationView =
        stepTypeToComponent.get(ap.TB_Step_Type__c) == 'personalInformationView';
      this.addressInformationView =
        stepTypeToComponent.get(ap.TB_Step_Type__c) == 'addressInformationView';
      this.paymentComponent =
        stepTypeToComponent.get(ap.TB_Step_Type__c) == 'paymentComponent';
      this.verificationComponent =
        stepTypeToComponent.get(ap.TB_Step_Type__c) == 'verificationComponent';
      this.addressComponent =
        stepTypeToComponent.get(ap.TB_Step_Type__c) == 'addressComponent';
      this.educationComponent =
        stepTypeToComponent.get(ap.TB_Step_Type__c) == 'educationComponent';
      this.languageCertificatesComponent =
        stepTypeToComponent.get(ap.TB_Step_Type__c) == 'languageCertificates';
      this.verificationInProgressComponent =
        stepTypeToComponent.get(ap.TB_Step_Type__c) ==
        'verificationInProgressComponent';
      this.informationComponent =
        stepTypeToComponent.get(ap.TB_Step_Type__c) ==
        'informationComponent';
      this.tuitionComponent =
        stepTypeToComponent.get(ap.TB_Step_Type__c) == 'tuitionComponent';
      this.maturityExam =
        stepTypeToComponent.get(ap.TB_Step_Type__c) == 'maturityExam';
      this.maturityExamScores =
        stepTypeToComponent.get(ap.TB_Step_Type__c) == 'maturityExamScores';
      this.documentsToDownloadComponent =
        stepTypeToComponent.get(ap.TB_Step_Type__c) ==
        'documentsToDownloadComponent';
      this.programDifferencesComponent =
        stepTypeToComponent.get(ap.TB_Step_Type__c) ==
        'programDifferencesComponent';
      this.pdMultiDocumentComponent = stepTypeToComponent.get(ap.TB_Step_Type__c) == 'pdMultiDocumentComponent';
        this.photoComponent =
        stepTypeToComponent.get(ap.TB_Step_Type__c) == 'photoComponent';
      this.scholarshipComponent =
        stepTypeToComponent.get(ap.TB_Step_Type__c) == 'scholarshipComponent';
      this.currentClinicalWorkplaceComponent =
        stepTypeToComponent.get(ap.TB_Step_Type__c) ==
        'currentClinicalWorkplaceComponent';
      this.clinicalExperiencePriorMAComponent =
        stepTypeToComponent.get(ap.TB_Step_Type__c) ==
        'clinicalExperiencePriorMAComponent';
      this.clinicalExperienceAfterMAComponent =
        stepTypeToComponent.get(ap.TB_Step_Type__c) ==
        'clinicalExperienceAfterMAComponent';
      this.clinicalInterestPriorMAComponent =
        stepTypeToComponent.get(ap.TB_Step_Type__c) ==
        'clinicalInterestPriorMAComponent';
      this.clinicalInterestAfterMAComponent =
        stepTypeToComponent.get(ap.TB_Step_Type__c) ==
        'clinicalInterestAfterMAComponent';
      this.CBPsychologyInterestPriorMAComponent =
        stepTypeToComponent.get(ap.TB_Step_Type__c) ==
        'CBPsychologyInterestPriorMAComponent';
      this.CBPsychologyInterestAfterMAComponent =
        stepTypeToComponent.get(ap.TB_Step_Type__c) ==
        'CBPsychologyInterestAfterMAComponent';
      this.agreementConclusionComponent =
        stepTypeToComponent.get(ap.TB_Step_Type__c) ==
        'agreementConclusionComponent';
      this.agreementStatusComponent =
        stepTypeToComponent.get(ap.TB_Step_Type__c) ==
        'agreementStatusComponent';
      this.qualificationComponent =
        stepTypeToComponent.get(ap.TB_Step_Type__c) == 'qualificationComponent';
      this.moodleOnlineExam =
        stepTypeToComponent.get(ap.TB_Step_Type__c) == 'moodleOnlineExam';
      this.moodleLangExam =
        stepTypeToComponent.get(ap.TB_Step_Type__c) == 'moodleLangExam';
      this.moodleLangExamMoodle =
        stepTypeToComponent.get(ap.TB_Step_Type__c) == 'moodleLangExamMoodle';
      this.interestExaminationReserveListComponent =
        stepTypeToComponent.get(ap.TB_Step_Type__c) ==
        'interestExaminationReserveListComponent';
      this.recommendationSummerPrepComponent =
        stepTypeToComponent.get(ap.TB_Step_Type__c) ==
        'recommendationSummerPrepComponent';
      this.recommendationDeclinedComponent =
        stepTypeToComponent.get(ap.TB_Step_Type__c) ==
        'recommendationDeclinedComponent';
      this.photoUploadComponent =
        stepTypeToComponent.get(ap.TB_Step_Type__c) == 'photoUploadComponent';
      this.decisionComponent =
        stepTypeToComponent.get(ap.TB_Step_Type__c) == 'decisionComponent';
      this.admissionsSurvey =
        stepTypeToComponent.get(ap.TB_Step_Type__c) == 'admissionsSurvey';
      this.languageCourseSelection =
        stepTypeToComponent.get(ap.TB_Step_Type__c) ==
        'languageCourseSelection';
      this.specializationChoice =
        stepTypeToComponent.get(ap.TB_Step_Type__c) == 'specializationChoice';
      this.genericComponent =
        !this.personalInformationView &&
        !this.addressInformationView &&
        !this.paymentComponent &&
        !this.verificationComponent &&
        !this.addressComponent &&
        !this.educationComponent &&
        !this.tuitionComponent &&
        !this.maturityExam &&
        !this.maturityExamScores &&
        !this.verificationInProgressComponent &&
        !this.informationComponent &&
        !this.languageCertificatesComponent &&
        !this.documentsToDownloadComponent &&
        !this.programDifferencesComponent &&
        !this.photoComponent &&
        !this.scholarshipComponent &&
        !this.currentClinicalWorkplaceComponent &&
        !this.clinicalExperiencePriorMAComponent &&
        !this.clinicalExperienceAfterMAComponent &&
        !this.clinicalInterestPriorMAComponent &&
        !this.clinicalInterestAfterMAComponent &&
        !this.CBPsychologyInterestPriorMAComponent &&
        !this.CBPsychologyInterestAfterMAComponent &&
        !this.qualificationComponent &&
        !this.agreementConclusionComponent &&
        !this.interestExaminationReserveListComponent &&
        !this.recommendationSummerPrepComponent &&
        !this.recommendationDeclinedComponent &&
        !this.pdMultiDocumentComponent &&
        !this.photoUploadComponent &&
        !this.decisionComponent &&
        !this.admissionsSurvey &&
        !this.languageCourseSelection &&
        !this.specializationChoice &&
        !this.moodleOnlineExam &&
        !this.moodleLangExamMoodle &&
        !this.moodleLangExam;
      this.comments = TB_Constants.PARAM_EMPTY_STRING;
      this.clearComments = TB_Constants.PARAM_EMPTY_STRING;
      this.letDisplay = false;
      this.letEdit = false;
      this.jsonDisplay = TB_Constants.PARAM_EMPTY_STRING;
      this.jsonEdit = TB_Constants.PARAM_EMPTY_STRING;
    }
  }
}