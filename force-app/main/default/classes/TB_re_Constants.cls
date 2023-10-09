public without sharing class TB_re_Constants {
    //HTTP Constants
    public static final String HTTP_HEADER_ACCEPT = 'Accept';
    public static final String HTTP_HEADER_CONTENT_TYPE = 'Content-Type';
    public static final String HTTP_METHOD_POST = 'POST';
    public static final Integer HTTP_STATUS_OK = 200;
    public static final Integer HTTP_STATUS_NO_CONTENT = 204;

    //Integration Provider Names
    public static final String TB_PROVIDER_SMS_API = 'SMS_Api';
    public static final String TB_PROVIDER_GOOGLE_AUTHORIZATION = 'Google_OAuth';
    public static final String TB_PROVIDER_GOOGLE_SERVICE = 'Google_Calendar';
    public static final String TB_PROVIDER_PAYU = 'TB_PayU';
    public static final String TB_PROVIDER_KREM = 'KReM_SIO';

    //Record Types
    public static final String ADMISSION_PROCESS_ADMISSION_PROCESS_RT = 'TB_Admissions_Process';
    public static final String ADMISSION_PROCESS_ADMISSION_STAGE_RT = 'TB_Admissions_Stage';
    public static final String ADMISSION_PROCESS_ADMISSION_STEP_RT = 'TB_Admissions_Step';
    public static final String PAYMENT_ADMISSIONS_FEE_RT_ID = Schema.SObjectType.TB_Payment__c.getRecordTypeInfosByDeveloperName().get('TB_Admissions_Fee').getRecordTypeId();
    public static final String ADMISSIONS_LOGIC_PROCESS_LOGIC_RT_ID = Schema.SObjectType.TB_Admissions_Logic__c.getRecordTypeInfosByDeveloperName().get('TB_Process_Logic').getRecordTypeId();
    public static final String ADMISSIONS_LOGIC_MESSAGE_LOGIC_RT = 'TB_Message_Logic';
    public static final String CONTACT_STUDENT_RT = 'TB_Student';
    public static final String CONTACT_APPLICANT_RT = 'TB_Applicant';
    public static final String CONTACT_EMPLOYEE_RT = 'TB_Employee';

    public static final Map<String, String> TB_DOCUMENT_GENERATOR_DICTIONARY = new Map<String, String>{
        'Application' => '',
        'Applicant' => 'hed__Applicant__r',
        'Agent' => 'hed__Preparer__r',
        'Decision_Maker' => 'TB_PD_Decision_Maker__r',
        'Approver' => 'TB_PD_Approver__r',
        'Offered_Product' => 'TB_Applying_To_Offered_Product__r'
    };

    //generic labels
    public static final String TB_RECORDID_LABEL = 'recordId';
    public static final String TB_SWPS_PROXY_LABEL = 'Proxy';
    public static final String TB_ACCOUNT_LABEL = 'Account';
    public static final String TB_APPLICATION_LABEL = 'Application';
    public static final String TB_CONTACT_LABEL = 'Contact';

    //TB_PdfControllerLwc
    public static final String TB_PARAM_HTML = 'html';
    public static final String TB_PARAM_PDF_EXTENSION = '.pdf';
    public static final String TB_PARAM_HTML_EXTENSION = '.html';
    public static final String TB_PARAM_UNEXPECTED_ERROR = 'Unexpected Error has occured';
    public static final String TB_CONTENT_DOCUMENT_ID_LABEL = 'contentDocumentId';
    public static final String TB_APP_ID_LABEL = 'applicationId';

    //TB_Experience_History__c
    public static final String TB_EDUCATION_EXP_HS_EXAM_METRIC_RT_ID = Schema.SObjectType.TB_Experience_History__c.getRecordTypeInfosByDeveloperName().get('TB_HS_Exam_Metric').getRecordTypeId();
    public static final String TB_EDUCATION_EXP_HS_EXAM_SUBJECT_METRIC_RT_ID  = Schema.SObjectType.TB_Experience_History__c.getRecordTypeInfosByDeveloperName().get('TB_HS_Exam_Subjects').getRecordTypeId();
    public static final String TB_EDUCATION_EXP_HIGHER_EDUCATION_RT_ID = Schema.SObjectType.TB_Experience_History__c.getRecordTypeInfosByDeveloperName().get('TB_Higher_Education').getRecordTypeId();
    public static final String TB_EDUCATION_EXP_POSTGRAD_EDUCATION_RT_ID = Schema.SObjectType.TB_Experience_History__c.getRecordTypeInfosByDeveloperName().get('TB_Postgraduate_Studies').getRecordTypeId();
    public static final String TB_EDUCATION_EXP_COURSE_AND_TRAIN_RT_ID = Schema.SObjectType.TB_Experience_History__c.getRecordTypeInfosByDeveloperName().get('TB_Courses_and_Trainings').getRecordTypeId();
    public static final String TB_PD_DIFFERENCES_EXP_RT_ID = Schema.SObjectType.TB_Experience_History__c.getRecordTypeInfosByDeveloperName().get('TB_Program_Differences').getRecordTypeId();
    public static final String TB_EDUCATION_EXP_LANGUAGE_CERTIFICATE_RT_DN = 'TB_Language_Certificate';
    public static final String RECORD_TYPE_DEVELOPER_NAME_TB_PROGRAM_DIFFERENCES = 'TB_Program_Differences';

    //Consent__c
    public static final String TB_SIGNED_CONSENT = 'Signed';
    public static final String TB_CONSENT_CONSENT_DEFINITION_RT_DEVNAME = 'TB_Consent_Definition';

    //hed_Application__c
    public static final String TB_APPLICATION_STATUS_CONDITIONALLY_ACCEPTED = 'Conditionally_Accepted';
    public static final String TB_APPLICATION_AGREEMENT_STATUS_CONCLUDED = 'Concluded';
    public static final String TB_APPLICATION_AGREEMENT_STATUS_TERMINATED = 'Terminated';
    public static final String TB_APP_APPLICANT_CITIZENSHIP_POLAND = 'Poland';
    public static final String TB_APP_EXAM_TYPE_POLISH_SINCE_2005 = 'New_Polish_HS_Exam_Since_2005';
    public static final String TB_APPLICATION_STATUS_CANCELLED = 'Cancelled';

    //TB_Application_Document__c
    public static final String TB_APP_DOCUMENT_CATEGORY_STUDY_AGREEMENT_ELECTRONIC = 'Study_Agreement_Electronic';
    public static final String TB_APP_DOCUMENT_TYPE_ELECTRONIC_TEMPLATE = 'Electronic_Template';
    public static final String TB_APP_DOCUMENT_TYPE_DYNAMIC_TEMPLATE = 'Dynamic_Template';
    public static final String TB_APP_DOCUMENT_TYPE_ELECTRONIC = 'Electronic';
    public static final String TB_APP_DOCUMENT_TYPE_SCAN = 'Scan';
    public static final String TB_APP_DOCUMENT_CAT_PD_DOCUMENT = 'PD_Document';
    public static final String TB_APP_DOCUMENT_STATUS_EMPTY = 'Empty';
    public static final String TB_APP_DOCUMENT_STATUS_TO_VERIFY = 'To_Verify';
    public static final String TB_APP_DOCUMENT_STATUS_VERIFIED = 'Verified';
    public static final String TB_APP_DOCUMENT_STATUS_CONCLUDED = 'Concluded';
    public static final String TB_APP_DOCUMENT_ANONYMISATION_STATUS_ANONYMIZED = 'Anonymized';
    public static final String TB_APP_DOCUMENT_TYPE_PHOTO = 'Photo';
    public static final String TB_APP_DOCUMENT_OUTPUT_FORMAT_ORIGINAL = 'Original';
    public static final String TB_PARAM_ZIP_EXTENSION = '.zip';

    public static final List<String> TB_PD_DOCUMENT_CATEGORIES = new List<String>{
        'PD_Study_Card', 'PD_Supplement', 'PD_Index_Excerpt',
        'PD_Index', 'PD_Diploma', 'PD_Language',
        'PD_Syllabus', 'PD_Other'
    };

    public static final String STEP_TYPE_DOCUMENT_COLLECTION = 'Document_Collection';
    public static final String PARAM_EMPTY_STRING = '';
    public static final String PARAM_WHITESPACE = ' ';

    //Case
    public static final String CASE_APPLICATION_REQUEST_RT_ID = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TB_Application_Request_Case').getRecordTypeId();

    //Communication Languages
    public static final String TB_COMMUNICATION_LANGUAGE_ENGLISH = 'English';
    public static final String TB_COMMUNICATION_LANGUAGE_POLISH = 'Polish';

    //TB_Application_Step_History__c
    public static final Id TB_APP_STEP_HISTORY_AGREEMENT_RT_ID = Schema.SObjectType.TB_Application_Step_History__c.getRecordTypeInfosByDeveloperName().get('TB_Step_Agreement_History').getRecordTypeId();
    public static final String TB_APP_STEP_HISTORY_STATUS_READ = 'Read';
    public static final String TB_APP_STEP_HISTORY_STATUS_CONCLUDED = 'Concluded';
    public static final String TB_APP_STEP_HISTORY_STATUS_ERROR = 'Error';
    public static final String TB_APP_STEP_HISTORY_STATUS_TERMINATED = 'Terminated';
    public static final String TB_APP_STEP_HISTORY_STATUS_DISPLAYED = 'Displayed';

    //Content Version
    public static final String TB_CONTENT_VERSION_CATEGORY_MAIN_PICTURE = 'Main_Picture';

    //Admissions Step Type
    public static final String TB_ADMISSIONS_STEP_TYPE_HS_EXAM_SCORE = 'HS_Exam_Score';

    //Admissions Content
    public static final String TB_ADMISSIONS_CONTENT_CONTENT_TYPE_ARTICLE = 'Article';
    public static final String TB_ADMISSIONS_CONTENT_CONTENT_TYPE_EXCEPTION = 'Exception';
    public static final String TB_ADMISSIONS_CONTENT_PRODUCT_GROUP_HIGHER_EDUCATION = 'Higher_Education';
    public static final String TB_ADMISSIONS_CONTENT_PRODUCT_GROUP_OTHER = 'Other';

    //Session Management
    public static final String TB_SESSION_PROPERTY_SOURCE_IP = 'SourceIp';

    //Profiles
    public static final String PROFILE_NAME_APPLICANT = 'SWPS Admissions - Applicant (Plus)';
    public static final String PROFILE_NAME_ADMINISTRATOR = 'System Administrator';

    //Roles
    public static final String ROLE_DEV_NAME_ADMIN = 'Admin';

    //Interview
    public static final String QUALIFICATION_ITEM_TYPE_INTERVIEW = 'Interview';

    //TB_Admissions_Dictionary__c
    public static final String ADMISSIONS_DICTIONARY_RT_COUNTRY_STATE_DEVNAME = 'TB_Country_State';
    public static final String ADMISSIONS_DICTIONARY_RT_COMMENT_DEVNAME = 'TB_Document_Comment';
    public static final String ADMISSIONS_DICTIONARY_RT_LANGUAGE_CERTIFICATE_DEVNAME = 'TB_Language_Certificate';
    public static final String ADMISSIONS_DICTIONARY_RT_ADMISSIONS_LIMIT_DEVNAME = 'TB_Admissions_Limit';
    public static final String ADMISSIONS_DICTIONARY_RT_ADMISSIONS_LIMIT_ID = Schema.SObjectType.TB_Admissions_Dictionary__c.getRecordTypeInfosByDeveloperName().get(ADMISSIONS_DICTIONARY_RT_ADMISSIONS_LIMIT_DEVNAME).getRecordTypeId();
    public static final String ADMISSIONS_DICTIONARY_RT_LANGUAGE_COURSE_DEVNAME = 'TB_Language_Course';
    public static final String ADMISSIONS_DICTIONARY_RT_LANGUAGE_COURSE_ASSIGNMENT_DEVNAME = 'TB_Language_Course_Assignment';
    public static final String ADMISSIONS_DICTIONARY_RT_RESIGNATION_REASON_ID = Schema.SObjectType.TB_Admissions_Dictionary__c.getRecordTypeInfosByDeveloperName().get('TB_Resignation_Reason').getRecordTypeId();
    public static final String ADMISSIONS_DICTIONARY_RT_DISCOUNT = Schema.SObjectType.TB_Admissions_Dictionary__c.getRecordTypeInfosByDeveloperName().get('TB_Discount').getRecordTypeId();
    public static final String ADMISSIONS_DICTIONARY_RT_HS_EXAM_SUBJECT = Schema.SObjectType.TB_Admissions_Dictionary__c.getRecordTypeInfosByDeveloperName().get('TB_High_School_Exam_Subject').getRecordTypeId();


    //Object API Name
    public static final String TB_OBJECT_API_NAME_ADMISSIONS_DICTIONARY = TB_Admissions_Dictionary__c.SObjectType.getDescribe().getName();
    public static final String TB_OBJECT_API_NAME_QUALIFICATION_REQUIREMENT = TB_Qualification_Requirement__c.SObjectType.getDescribe().getName();
    public static final String TB_OBJECT_API_NAME_OFFERED_PRODUCT = TB_Offered_Product__c.SObjectType.getDescribe().getName();
    public static final String TB_OFFERED_PRODUCT_RT_STUDY = Schema.SObjectType.TB_Offered_Product__c.getRecordTypeInfosByDeveloperName().get('TB_Study').getRecordTypeId();
    //TB_Qualification_Requirement__c
    public static final String TB_QUA_REQ_MIN_REC_TYPE_NAME = 'TB_HS_Exam_Minimum_Points';
    public static final String TB_QUA_REQ_CITIZENSHIP_DEPENDENCY_NON_POL = 'Non_Polish_Citizens';
    public static final String TB_QUA_REQ_CITIZENSHIP_DEPENDENCY_POL = 'Polish_Citizens';
    public static final String TB_QUA_REQ_EXAM_TYPE_POLISH_SINCE_2005 = 'New_Polish_HS_Exam_Since_2005';

    //TB Language to translate
    public static final String LANGUAGE_PL = 'PL';
    public static final String LANGUAGE_EN = 'EN';
    public final static String LANGUAGE_USER_PL = 'pl';

    //TB Article wrapper
    public static final String TB_ARTICLE_WRAPPER_TITLE_NAME = 'title';
    public static final String TB_ARTICLE_WRAPPER_LEAD_NAME = 'lead';
    public static final String TB_ARTICLE_WRAPPER_CONTENT_NAME = 'content';
    public static final String TB_ARTICLE_WRAPPER_URL_NAME = 'url';

    public static final List<String> TB_REJECTED_APPLICATIONS_STATUSES = new List<String>{
        'Cancelled', 'Declined', 'Resigned', 'Revoked'
    };

    //TB_AdmissionsSurvey__c
    public static final String TB_ADMISSIONS_SURVEY_QUESTION = 'Question';
    public static final String TB_ADMISSIONS_SURVEY_QUESTION_VALUE = 'Question Value';

    //TB_Admissions_Committee__c
    public static final String TB_ADMISSIONS_COMMITTEE_RT_COMMITTEE_MEMBER_ID = Schema.SObjectType.TB_Admissions_Committee__c.getRecordTypeInfosByDeveloperName().get('TB_Committee_Member').getRecordTypeId();

    //TB_Application_Qualification__c
    public static final String TB_APPLICATION_QUALIFICATION_TYPE_LANGUAGE_TEST = 'Language_Test';

    public static final Map<String, Map<String, String>> languageToFieldsTranMap = new Map<String, Map<String, String>>{
        TB_Constants.LANGUAGE_USER_PL => new Map<String, String>{
            'true' => 'Tak',
            'false' => 'Nie'
        },
        TB_Constants.LANGUAGE_EN => new Map<String, String>{
            'true' => 'Yes',
            'false' => 'No'
        }
    };

    public static final Map<String, Map<String, String>> languageToFieldsMap = new Map<String, Map<String, String>>{
        TB_Constants.LANGUAGE_PL => new Map<String, String>{
            TB_Admissions_Content__c.Id.getDescribe().name => TB_Admissions_Content__c.Id.getDescribe().name,
            TB_ARTICLE_WRAPPER_TITLE_NAME => TB_Admissions_Content__c.TB_Title_PL__c.getDescribe().name,
            TB_ARTICLE_WRAPPER_LEAD_NAME => TB_Admissions_Content__c.TB_Lead_PL__c.getDescribe().name,
            TB_ARTICLE_WRAPPER_CONTENT_NAME => TB_Admissions_Content__c.TB_Content_PL__c.getDescribe().name,
            TB_ARTICLE_WRAPPER_URL_NAME => TB_Admissions_Content__c.TB_Url_PL__c.getDescribe().name
        },
        TB_Constants.LANGUAGE_EN => new Map<String, String>{
            TB_Admissions_Content__c.Id.getDescribe().name => TB_Admissions_Content__c.Id.getDescribe().name,
            TB_ARTICLE_WRAPPER_TITLE_NAME => TB_Admissions_Content__c.TB_Title_EN__c.getDescribe().name,
            TB_ARTICLE_WRAPPER_LEAD_NAME => TB_Admissions_Content__c.TB_Lead_EN__c.getDescribe().name,
            TB_ARTICLE_WRAPPER_CONTENT_NAME => TB_Admissions_Content__c.TB_Content_EN__c.getDescribe().name,
            TB_ARTICLE_WRAPPER_URL_NAME => TB_Admissions_Content__c.TB_Url_EN__c.getDescribe().name
        }
    };

    //TB_AvatarsController
    public static final String PHOTO_ALREADY_UPLOADED_MESSAGE = 'Photo already uploaded';

    public static final String TB_AURA_ERROR_SEPARATOR = '|';
    public static final String TB_AURA_ERROR_SEPARATOR_SPLIT = '\\|';

    //Citizenship
    public static final String TB_APPLICANT_CITIZENSHIP_POLAND = 'Poland';
    public static final String TB_CITIZENSHIP_DEPENDENCY_EVERYONE = 'Everyone';
    public static final String TB_CITIZENSHIP_DEPENDENCY_POLISH_CITIZENS = 'Polish_Citizens';
    public static final String TB_CITIZENSHIP_DEPENDENCY_NON_POLISH_CITIZENS = 'Non_Polish_Citizens';

    public static final String TB_SEPARATOR_SEMICOLON = ';';
    public static final String TB_SEPARATOR_SLASH = '/';
    public static final String TB_SEPARATOR_HYPHEN = '-';
    public static final String ENCODING_SYSTEM_UTF_8 = 'UTF-8';
    public static final String CONTENT_LOCATION_SALESFORCE = 's';

    //DT_Type_of_Identity_Document__c
    public static final String TB_TYPE_OF_ID_PASSPORT = 'PASZPORT';
    public static final String TB_TYPE_OF_ID_FOREIGN_ID = 'ZAGRANICZNY_DOWOD_OSOBISTY';

    //TB_SpecializationChoice
    public static final String TB_SPECIALIZATION_CHOICE_RELATION_TYPE = 'Higher_Year_PD';
    public static final String TB_SPECIALIZATION_CHOICE_DEACTIVATION_MODE = 'Automatic';

    //Queueable Apex
    public static final String ASYNC_APEX_JOB_FAILED_STATUS = 'Failed';
    public static final String ASYNC_APEX_JOB_PROCESSING_STATUS = 'Processing';

    //Separators
    public static final String TB_SEPARATOR_FULL_STOP = '.';
    public static final String TB_SEPARATOR_UNDERSCORE = '_';

    //Tests
    public static final String TB_TEST_LABEL = 'test';

    //TB_Json_wrapper
    public static final String TB_JSON_WRAP_KEY_SET_PAR_IDS = 'tb_json_parent_ids';

    //Consent Types
    public static final String CONSENT_TYPE_MARKETING = 'Marketing';
    public static final String CONSENT_TYPE_TERMS_AND_CONDITION = 'Terms and Conditions';
    public static final String CONSENT_TYPE_INFORMATIONAL = 'Informational';
    public static final String CONSENT_STATUS_SEEN = 'Seen';
    public static final String CONSENT_STATUS_SIGNED = 'Signed';
    public static final String CONSENT_STATUS_REJECTED = 'Rejected';

    //Account Record Types Ids
    public static final String STUDENTS_ORGANIZATION_REC_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('DT_Students_Organization').getRecordTypeId();
    public static final String UNIVERSITY_DEPARTMENT_REC_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('University_Department').getRecordTypeId();

    //Account TB_Status__c Statuses
    public static final String ACTIVE_STATUS = 'Active';
    public static final List<String> ACTIVE_ORGANISATIONS_ACCOUNT_STATUSES = new List<String>{'Active'};
    public static final List<String> ORGANISATIONS_TO_APPROVE_ACCOUNT_STATUSES = new List<String>{'Draft', 'Pending_Approval'};

    //Affiliation hed__Role__c roles
    public static final String AFFILIATION_ROLE_MEMBER = 'SO_Member';
    public static final String AFFILIATION_ROLE_CHAIRMAN = 'SO_Chairman';
    public static final String AFFILIATION_ROLE_SUPERVISOR = 'SO_Supervisor';
    public static final List<String> NEW_ORGANISATION_ROLES = new List<String>{AFFILIATION_ROLE_MEMBER, AFFILIATION_ROLE_CHAIRMAN, AFFILIATION_ROLE_SUPERVISOR};

    //Affiliation hed__Status__c statuses
    public static final String AFFILIATION_STATUS_CURRENT = 'Current';
    public static final String AFFILIATION_STATUS_AWAITING = 'Awaiting';
    public static final String AFFILIATION_STATUS_REJECTED = 'Rejected';
    public static final String AFFILIATION_STATUS_PENDING_APPROVAL = 'Pending_Approval';
    public static final String AFFILIATION_STATUS_FORMER = 'Former';
    public static final List<String> NEW_ORGANISATIONS_STATUSES = new List<String>{AFFILIATION_STATUS_CURRENT, AFFILIATION_STATUS_AWAITING};
    public static final List<String> NEW_ORGANISATIONS_CURRENT_PENDING = new List<String>{AFFILIATION_STATUS_CURRENT, AFFILIATION_STATUS_PENDING_APPROVAL};

    //Affiliation TB_Level_of_Study__c values
    public static final String AFFILIATION_STUDY_LEVEL_BACHELOR = 'Bachelor';

    //Affiliation processes types
    public static final String ORG_LEAVING_PROCESS_TYPE = 'organizationLeaving';
    public static final String CANDIDATE_APPROVAL_PROCESS_TYPE = 'candidateApproval';

    //Link href to download file
    public static final String DOWNLOAD_FILE_HREF = '/sfc/servlet.shepherd/document/download/';

    //Student Organization Details - decisions types
    public static final String DECISION_CONFIRMED = 'confirmed';

    //Exceptions
    public static final String USER_UNAUTHORIZED = 'User unauthorized';

    //Consents checkbox classes
    public static final String CHECKED_CLASS = 'checkbox-input checkbox-input-checked';
    public static final String UNCHECKED_CLASS = 'checkbox-input checkbox-input-unchecked';
    public static final String ACTIVE_CLASS = 'checkmark checkmark-active no-select';
    public static final String INACTIVE_CLASS = 'checkmark checkmark-inactive no-select';

    //Contact constant values
    public static final String CONTACT_ROLE_STUDENT =  'Student';

    //Mass Mail Creator
    public static final String EMPTY_TEMPLATE_FOR_CREATOR = 'TB_Empty_Template_for_Create_and_Sent_Email';

    //KReM
    public static final String ERROR_OCCURRED = 'ERROR_OCCURRED';

}