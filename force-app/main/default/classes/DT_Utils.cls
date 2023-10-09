/**
 * @description       : 
 * @author            : aleksandra.gonta-kacperska@devoteam.com
 * @group             :
 * @last modified on  : 01-28-2022
 * @last modified by  : aleksandra.gonta-kacperska@devoteam.com
 * Modifications Log 
 * Ver   Date         Author                                    Modification
 * 1.0   01-19-2021   aleksandra.gonta-kacperska@devoteam.com   Initial Version
**/
public with sharing class DT_Utils {
    public static final String ACCESS_EXCEPTION = 'No Access';
    public static final String SOBJ_ACCOUNT = 'Account';
    public static final String SOBJ_CASE = 'Case';
    public static final String SOBJ_CONTACT = 'Contact';
    public static final String SOBJ_OPPORTUNITY = 'Opportunity';
    public static final String SOBJ_INTERNSHIP = 'DT_Internship__c';
    public static final String SOBJ_JOB_OFFER = 'DT_Job_Offers__c';
    public static final String OPTION_ALL = '-- All --';
    public static final String SOBJ_USER = 'User';
    public static final String SOBJ_GROUP = 'Group';
    public static final String COMMUNITY_NAME = 'MySWPS';

    /** Account */
    public static final String ACCOUNT_CAMPUS_NAME_WARSZAWA = 'Warszawa';
    public static final String ACCOUNT_CAMPUS_NAME_KATOWICE = 'Katowice';
    public static final String ACCOUNT_CAMPUS_NAME_POZNAN = 'Poznań';
    public static final String ACCOUNT_CAMPUS_NAME_SOPOT = 'Sopot';
    public static final String ACCOUNT_CAMPUS_NAME_WROCLAW = 'Wrocław';

    public static final String ACCOUNT_ACADEMIC_PROGRAM_RECORD_TYPE_NAME = 'Academic_Program';
    public static final String ACCOUNT_EDUCATION_INSTITUTION_RECORD_TYPE_NAME = 'Educational_Institution';
    public static final String ACCOUNT_BUSINESS_ORGANIZATION_RECORD_TYPE_NAME = 'Business_Organization';
    public static final String ACCOUNT_ADMINISTRATIVE_RECORD_TYPE_NAME = 'Administrative';
    public static final String ACCOUNT_SPECIALTY_RECORD_TYPE_NAME = 'DT_Specialty';
    public static final String ACCOUNT_UNIVERSITY_DEPARTMENT_RECORD_TYPE_NAME = 'University_Department';

    public static final String ACCOUNT_TYPE_ACADEMIC_PROGRAM = 'Academic Program';
    public static final String ACCOUNT_TYPE_EDUCATIONAL_INSTITUTION = 'Educational Institution';
    public static final String ACCOUNT_TYPE_CAMPUS = 'Campus';
    public static final String ACCOUNT_TYPE_DEPARTMENT = 'Department';
    public static final String ACCOUNT_TYPE_ADMINISTRATIVE = 'Administrative';
    public static final String ACCOUNT_TYPE_SPECIALTY = 'Specialty';

    public static final String ACCOUNT_LEVEL_POSTGRADUATE = 'Postgraduate';
    public static final String ACCOUNT_LEVEL_BACHELOR = 'Bachelor';
    public static final String ACCOUNT_LEVEL_MASTER = 'Master';
    public static final String ACCOUNT_LEVEL_PHD = 'PhD';
    public static final String ACCOUNT_LEVEL_COURSE = 'Course';
    public static final String ACCOUNT_LEVEL_INTEGRATED_MASTER = 'Integrated_Master';
    public static final String ACCOUNT_LEVEL_SHORT_COURSE = 'Short_Course';

    // Admissions Dictionary
    public static final String ADMISSIONS_DICTIONARY_RT_CONSENT_DEFINITION_BUNDLE_DEV_NAME = 'TB_Consents_Definitions_Bundle';
    public static final String ADMISSIONS_DICTIONARY_USED_ON_CAREER_OFFICE_FORM_API_NAME = 'Career_Office_Form';
    public static final String ADMISSIONS_DICTIONARY_CONSENT_TYPE_TERMS_AND_CONDITIONS = 'Terms and Conditions';
    public static final String ADMISSIONS_DICTIONARY_CONSENT_TYPE_MARKETING = 'Marketing';

    /** Campaign **/
    public static final String CAMPAIGN_STATUS_IN_PROGRESS = 'In Progress';

    /** Campaign Member **/
    public static final String CAMPAIGN_MEMBER_STATUS_SENT = 'Sent';

    /** Case */
    // record types
    public static final String CASE_RECORD_TYPE_NAME_QUESTION = 'DT_Question';
    public static final String CASE_RECORD_TYPE_NAME_APPLICATION = 'DT_Application';
    public static final String CASE_RECORD_TYPE_NAME_CERTIFICATE = 'DT_Certificate';
    // types
    public static final String CASE_TYPE_QUESTION = 'Question';
    // categories and subcategories
    public static final String CASE_CATEGORY_ENROLMENTS = 'Enrollments_q';
    public static final String CASE_SUBCATEGORY_ENROLLMENT_REGISTRATION = 'Enrollment, Resignation from a Course';
    // origins
    public static final String CASE_ORIGIN_WEB = 'Web';
    // field api names
    public static final String CASE_DEPARTMENT_PICKLIST_FIELD_API_NAME = 'DT_Department_Picklist__c';
    public static final String CASE_LEVEL_OF_STUDIES_API_NAME = 'DT_Level_Of_studies__c';
    public static final String CASE_PHILOLOGICAL_LANGUAGE_FIELD_API_NAME = 'DT_Philological_Language__c';
    public static final String CASE_ACADEMIC_PROGRAM_PICKLIST_FIELD_API_NAME = 'DT_Academic_Program_Picklist__c';
    public static final String CASE_MODE_OF_STUDIES_API_NAME = 'DT_Mode_Of_Studies__c';
    public static final String CASE_LANGUAGE_OF_INSTRUCTION_FIELD_API_NAME = 'DT_Language_Of_Instruction__c';
    public static final String CASE_CATEGORY_API_NAME = 'hed__Category__c';
    public static final String CASE_SUBCATEGORY_API_NAME = 'DT_Subcategory__c';
    public static final String CASE_CAMPUS_PICKLIST_FIELD_API_NAME = 'DT_Campus_Picklist__c';
    public static final String CASE_FIELD_PROGRAM_ENROLLMENT_API_NAME = 'DT_Program_Enrollment__c';
    public static final String CASE_FIELD_OWNER_ID_API_NAME = 'OwnerId';
    public static final String CASE_FIELD_STATUS_API_NAME = 'Status';
    public static final String CASE_RECORD_ID_FIELD_API_NAME = 'RecordTypeId';

    // Consents
    public static final String CONSENT_STATUS_OPT_IN_API_NAME = 'Opt_In';
    public static final String CONSENT_SOURCE_TYPE_WWW_API_NAME = 'WWW';

    // routing channels
    public static final String CASE_SERVICE_ROUTING_CHANNEL = 'DT_CSS_Case_Routing';
    // statuses
    public static final String CASE_STATUS_IN_PROGRESS = 'In_Progress';
    public static final String CASE_STATUS_NEW = 'New';
    public static final String CASE_STATUS_CLOSED = 'Closed';
    public static final String CASE_STATUS_REOPENED = 'Reopened';
    // results
    public static final String CASE_RESULT_POSITIVE = 'Positive';

    // Contact
    public static final String CONTACT_STUDENT_RECORD_TYPE_DEV_NAME = 'TB_Student';

    // Content
    public static final String CONTENT_FILE_EXTENSION_PDF = '.pdf';
    public static final String CONTENT_LOCATION_SALESFORCE = 'S';
    public static final String CONTENT_SHARE_TYPE_VIEWER = 'V';
    public static final String CONTENT_VISIBILITY_ALL_USERS = 'AllUsers';

    // Email Service
    public static final String EMAIL_ORGANIZATION_WIDE_ADDRESS_CAREER_OFFICE_DISPLAY_NAME = 'Wspolpraca Biuro Karier';

    /** Entitlement */
    public static final String ENTITLEMENT_STATUS_ACTIVE = 'Active';
    public static final String ENTITLEMENT_TYPE_WEB_SUPPORT = 'Web Support';

    // Experience Cloud
    public static final String EXPERIENCE_CLOUD_LANGUAGE_ENGLISH = 'en-US';
    public static final String EXPERIENCE_CLOUD_LANGUAGE_POLISH = 'pl';
    
    /** Internship */
    public static final String INTERNSHIP_STATUS_NEW_OFFER = 'New Offer';
    public static final String INTERNSHIP_STATUS_PUBLISHED = 'Published';
    public static final String INTERNSHIP_STATUS_IN_PROGRESS = 'In Progress';
    public static final String INTERNSHIP_STATUS_REJECTED = 'Rejected';
    public static final String INTERNSHIP_INDUSTRY_ARCHITECTURE = 'Architecture';

    /** Internship Application */
    public static final String INTERNSHIP_APPLICATION_NUMBER_FORMAT = 'S/{0}/{1}';
    public static final String INTERNSHIP_APPLICATION_RECORD_TYPE_INSTITUTIONAL_NAME = 'DT_Institutional_Internship';
    public static final String INTERNSHIP_APPLICATION_RECORD_TYPE_INDIVIDUAL_NAME = 'DT_Individual_Internship';
    public static final String INTERNSHIP_APPLICATION_REFERRAL_ENGLISH_URL = '/apex/InternshipApplicationReferralEN';
    public static final String INTERNSHIP_APPLICATION_REFERRAL_POLISH_URL = '/apex/InternshipApplicationReferralPL';
    public static final String INTERNSHIP_APPLICATION_STATUS_DRAFT = 'Draft';
    public static final String INTERNSHIP_APPLICATION_STATUS_IN_PROGRESS = 'In_progress';
    public static final String INTERNSHIP_APPLICATION_STATUS_READY_TO_PROCEED = 'Internship_ready_to_proceed';
    public static final String INTERNSHIP_APPLICATION_STATUS_SUPERVISORS_REJECTION = 'Supervisors_Rejection';
    public static final String INTERNSHIP_APPLICATION_STATUS_SUPERVISORS_ACCEPTANCE = 'Supervisors_Acceptance';
    public static final String INTERNSHIP_APPLICATION_STATUS_CS_REJECTION = 'CS_Rejection';

    /** Internship Supervisor */
    public static final String INTERNSHIP_SUPERVISOR_TYPE_SUPERVISOR = 'Supervisor';

    /** Internship Requirement **/
    public static final String INTERNSHIP_REQUIREMENT_INTERNSHIP_HOURS_API_NAME = 'DT_Internship_Hours__c';
    public static final String INTERNSHIP_REQUIREMENT_SEMESTER_API_NAME = 'DT_Semester__c';

    /** Job Offer */
    public static final String JOB_OFFER_BUSINESS_CATEGORY_ADMINISTRATION = 'Administration';
    public static final String JOB_OFFER_CONFIRMED_BY_THE_EMPLOYER_ACCEPTED_VALUE = 'Accepted';
    public static final String JOB_OFFER_EMPLOYMENT_TYPE_B2B = 'B2B';
    public static final String JOB_OFFER_JOB_PLACEMENT_SUMMARY_ENGLISH_URL = '/apex/JobPlacementSummaryEN';
    public static final String JOB_OFFER_JOB_PLACEMENT_SUMMARY_POLISH_URL = '/apex/JobPlacementSummaryPL';
    public static final String JOB_OFFER_LANGUAGES_POLISH = 'Polish';
    public static final String JOB_OFFER_PREFFERED_LANGUAGE_ENGLISH = 'English';
    public static final String JOB_OFFER_PREFFERED_LANGUAGE_POLISH = 'Polish';
    public static final String JOB_OFFER_RECORD_TYPE_DEVELOPER_NAME_JOB_OFFER = 'DT_Job_Offer';
    public static final String JOB_OFFER_RECORD_TYPE_DEVELOPER_NAME_JOB_PLACEMENT = 'DT_Job_Placement';
    public static final String JOB_OFFER_REQUIRED_DOCUMENTS_CV_PL = 'CV PL';
    public static final String JOB_OFFER_STATUS_NEW_OFFER = 'New_Offer';
    public static final String JOB_OFFER_STATUS_PUBLISHED = 'Published';
    
    /** Program Enrollment */
    public static final String PROGRAM_ENROLLMENT_STATUS_BY_VDO_ACTIVE = 'Active';

    /** Knowledge */
    public static final String KNOWLEDGE_CAMPUS_VALUE_CSS_SWPS = 'CSS SWPS';
    public static final String KNOWLEDGE_PUBLISH_STATUS_ONLINE = 'Online';

    /** Program Enrolments */
    public static final String PROGRAM_ENROLMENT_STATUS_BY_VDO_ACTIVE = 'Active';
    public static final String PROGRAM_ENROLMENT_LEVEL_OF_STUDIES_POSTGRADUATE = 'Postgraduate';
    public static final String PROGRAM_ENROLMENT_LEVEL_OF_STUDIES_BACHELOR = 'Bachelor';
    public static final String PROGRAM_ENROLMENT_LEVEL_OF_STUDIES_MASTER = 'Master';
    public static final String PROGRAM_ENROLMENT_LEVEL_OF_STUDIES_INTEGRATED_MASTER = 'Integrated_Master';

    /** Program Plan */
    public static final String PROGRAM_PLAN_LEVEL_OF_STUDIES_BACHELOR = 'Bachelor';
    public static final String PROGRAM_PLAN_LEVEL_OF_STUDIES_POSTGRADUATE = 'Postgraduate';
    public static final String PROGRAM_PLAN_MODE_OF_STUDIES_FULL_TIME = 'Full_Time';
    public static final String PROGRAM_PLAN_PROFESSIONAL_TITLE_BACHELOR_OF_SCIENCE = 'BACHELOR_OF_SCIENCE';
    public static final String PROGRAM_PLAN_LANGUAGE_OF_INSTRUCTION_PL = 'PL';
    public static final String PROGRAM_PLAN_LANGUAGE_OF_INSTRUCTION_EN = 'EN';

    /** Pending Service Routing */
    public static final String PENDING_SERVICE_ROUTING_MODEL_MOST_AVAILABLE = 'MostAvailable';
    public static final String PENDING_SERVICE_ROUTING_TYPE_SKILLS_BASED = 'SkillsBased';

    /** Profiles */
    public static final String SWPS_STUDENT_PROFILE_NAME = 'SWPS Student';
    public static final String SWPS_EXTERNAL_FACULTY_PROFILE_NAME = 'SWPS External Faculty';
    public static final String SWPS_DEANS_OFFICE_EMPLOYEE_PROFILE_NAME = 'SWPS Dean\'s Office Employee';
    public static final String SWPS_CAREER_OFFICE_PROFILE_NAME = 'SWPS Career Office';
    public static final String SWPS_CONTRACT_MANAGER_PROFILE_NAME = 'SWPS Contract Manager';
    public static final String SWPS_CSPIS_ADMINISTRATOR_PROFILE_NAME = 'SWPS CSPiS Administrator';
    public static final String SWPS_CSPIS_COORDINATOR_PROFILE_NAME = 'SWPS CSPiS Coordinator';
    public static final String SWPS_CSPIS_COORDINATOR_PLATFORM_PROFILE_NAME = 'SWPS CSPiS Coordinator (Platform)';
    public static final String SWPS_ADMISSIONS_APPLICANT_PROFILE_NAME = 'SWPS Admissions - Applicant (Plus)';
    public static final String SWPS_PLATFORM_PROFILE_NAME = 'SWPS Employee Platform User';


    /** In case of implementing new permission sets or groups assignment, based on Profiles, please extend this set */
    public static final Set<String> PERMISSION_ASSIGNMENT_PROFILE_NAMES = new Set<String>{
        SWPS_STUDENT_PROFILE_NAME,
        SWPS_EXTERNAL_FACULTY_PROFILE_NAME,
        SWPS_DEANS_OFFICE_EMPLOYEE_PROFILE_NAME,
        SWPS_CAREER_OFFICE_PROFILE_NAME,
        SWPS_CONTRACT_MANAGER_PROFILE_NAME,
        SWPS_CSPIS_ADMINISTRATOR_PROFILE_NAME,
        SWPS_CSPIS_COORDINATOR_PROFILE_NAME,
        SWPS_CSPIS_COORDINATOR_PLATFORM_PROFILE_NAME
    };

    /** Tags */
    public static final String TAG_CATEGORY_PERSONAL = 'Personal';
    public static final String TAG_CATEGORY_SOCIAL = 'Social';
    public static final String TAG_CATEGORY_PROFESSIONAL = 'Professional';

    public static final String TAG_TYPE_COMPETENCES = 'Competences';
    public static final String TAG_TYPE_INTERESTS = 'Interests';

    /** Roles */
    public static final String USER_ROLE_ADMIN = 'Admin';

    /** Servlet */
    public static final String SERVLET_DOCUMENT_DOWNLOAD_URL = '/sfc/servlet.shepherd/document/download/';
    public static final String SERVLET_DOCUMENT_DOWNLOAD_OPERATION_CONTEXT_PARAM = '?operationContext=S1';

    /** System Languages */
    public static final String LANGUAGE_ENGLISH = 'en_US';
    public static final String LANGUAGE_POLISH = 'pl';

    /** Content Document Link Visibility*/
    public static final String VISIBILITY_TYPE_ALL_USERS = 'AllUsers';

    /** Content Document Link Share Settings*/
    public static final String SHARE_TYPE_INFERRED_PERMISSION = 'I';
    public static final String SHARE_TYPE_VIEWER_PERMISSION = 'V';
    public static final String SHARE_TYPE_COLLABORATOR_PERMISSION = 'C';

    /** Groups */
    public static final String CASE_MANAGEMENT_GROUP_NAME_ENROLLMENTS = 'DT_Enrollments';

    /** Knowledge Base Permission Sets*/
    public static final String PERMISSION_SET_NAME_KB_CSS_SWPS = 'DT_Knowledge_CSS_SWPS';
    public static final String PERMISSION_SET_NAME_KB_CSS_WARSZAWA = 'DT_Knowledge_CSS_Warszawa';
    public static final String PERMISSION_SET_NAME_KB_CSS_KATOWICE = 'DT_Knowledge_CSS_Katowice';
    public static final String PERMISSION_SET_NAME_KB_CSS_POZNAN = 'DT_Knowledge_CSS_Poznan';
    public static final String PERMISSION_SET_NAME_KB_CSS_SOPOT = 'DT_Knowledge_CSS_Sopot';
    public static final String PERMISSION_SET_NAME_KB_CSS_WROCLAW = 'DT_Knowledge_CSS_Wroclaw';
    public static final String PERMISSION_SET_NAME_KB_DC_KBA = 'DT_Knowledge_DC_KBA';
    public static final String PERMISSION_SET_NAME_KB_DC_KBC = 'DT_Knowledge_DC_KBC';
    public static final String PERMISSION_SET_NAME_KB_DC_KBG = 'DT_Knowledge_DC_KBG';
    public static final String PERMISSION_SET_NAME_KB_DC_KBL = 'DT_Knowledge_DC_KBL';
    public static final String PERMISSION_SET_NAME_KB_DC_KBS = 'DT_Knowledge_DC_KBS';
    public static final String PERMISSION_SET_NAME_KB_MANAGER = 'DT_Knowledge_Manager';
    public static final String PERMISSION_SET_NAME_KB_EDITOR = 'DT_Knowledge_Editor';
    public static final String PERMISSION_SET_NAME_KB_CAREER_OFFICE = 'DT_Knowledge_Career_Office';

    /** In case of new permission sets implementation, dedicated for Knowledge Base, please extend this set*/
    public static final Set<String> KNOWLEDGE_PERMISSION_SET_NAMES = new Set<String>{
        PERMISSION_SET_NAME_KB_CSS_SWPS,
        PERMISSION_SET_NAME_KB_CSS_WARSZAWA,
        PERMISSION_SET_NAME_KB_CSS_KATOWICE,
        PERMISSION_SET_NAME_KB_CSS_POZNAN,
        PERMISSION_SET_NAME_KB_CSS_SOPOT,
        PERMISSION_SET_NAME_KB_CSS_WROCLAW,
        PERMISSION_SET_NAME_KB_DC_KBA,
        PERMISSION_SET_NAME_KB_DC_KBC,
        PERMISSION_SET_NAME_KB_DC_KBG,
        PERMISSION_SET_NAME_KB_DC_KBL,
        PERMISSION_SET_NAME_KB_DC_KBS,
        PERMISSION_SET_NAME_KB_MANAGER,
        PERMISSION_SET_NAME_KB_EDITOR,
        PERMISSION_SET_NAME_KB_CAREER_OFFICE
    };

    public static final Map<String, String> CAMPUS_NAMES_TO_CSS_PERMISSION_SET_NAMES = new Map<String, String>{
        ACCOUNT_CAMPUS_NAME_WARSZAWA => PERMISSION_SET_NAME_KB_CSS_WARSZAWA,
        ACCOUNT_CAMPUS_NAME_KATOWICE => PERMISSION_SET_NAME_KB_CSS_KATOWICE,
        ACCOUNT_CAMPUS_NAME_POZNAN => PERMISSION_SET_NAME_KB_CSS_POZNAN,
        ACCOUNT_CAMPUS_NAME_SOPOT => PERMISSION_SET_NAME_KB_CSS_SOPOT,
        ACCOUNT_CAMPUS_NAME_WROCLAW => PERMISSION_SET_NAME_KB_CSS_WROCLAW
    };

    /** Profile Dedicated Permission Sets Groups*/
    public static final String PERMISSION_SET_GROUP_NAME_DEANS_OFFICE = 'DT_Deans_Office';
    public static final String PERMISSION_SET_GROUP_NAME_STUDENT = 'DT_Student';
    public static final String PERMISSION_SET_GROUP_NAME_POSTGRADUATE_STUDENT = 'DT_Postgraduate_Student';
    public static final String PERMISSION_SET_GROUP_NAME_CSPIS_ADMINISTRATOR = 'DT_CSPiS_Administrator';
    public static final String PERMISSION_SET_GROUP_NAME_CSPIS_COORDINATOR = 'DT_CSPiS_Coordinator';
    public static final String PERMISSION_SET_GROUP_NAME_CONTRACT_MANAGER = 'DT_Contract_Manager';
    public static final String PERMISSION_SET_GROUP_NAME_BIURO_KARIER = 'DT_Biuro_Karier';

    /** In case of new permission sets group implementation, used in User Trigger, please extend this set*/
    public static final Set<String> PROFILE_DEDICATED_PERMISSION_SET_GROUP_NAMES = new Set<String>{
        PERMISSION_SET_GROUP_NAME_DEANS_OFFICE,
        PERMISSION_SET_GROUP_NAME_STUDENT,
        PERMISSION_SET_GROUP_NAME_POSTGRADUATE_STUDENT
    };

     /** Object Id Prefix */
    public static final String TASK_ID_PREFIX = '00T';
    public static final String TEMPLATE_TASK_ID_PREFIX = 'a0m';
    public static final String SUCCESS_PLAN_ID_PREFIX = 'a0o';
    public static final String SUCCESS_PLAN_TEMPLATE_ID_PREFIX = 'a0n';

    /** Networks */
    public static final String NETWORK_NAME_MYSWPS = 'MySWPS';

    public static Id getRecTypeIdByDevName(String recordTypeDevName, String objectName) {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeDevName).getRecordTypeId();
    }

    public static Map<String, Id> fetchMapOfRecordTypeDevNames2Ids(Set<String> recordTypeDevNames, String objectName) {
        Map<String, Id> developerNames2Ids = new Map<String, Id>();
        for (RecordType rt : [
            SELECT Id, DeveloperName
            FROM RecordType
            WHERE DeveloperName IN :recordTypeDevNames
            AND SobjectType = :objectName
        ]) {
            developerNames2Ids.put(rt.DeveloperName, rt.Id);
        }
        return developerNames2Ids;
    }

    public static Set<Id> getRecTypeIdsByDevName(Set<String> recordTypeDevNames, String objectName) {
        return new Set<Id>(new Map<Id,RecordType>([
            SELECT Id
            FROM RecordType
            WHERE DeveloperName IN :recordTypeDevNames
                AND SobjectType =: objectName
        ]).keySet());
    }

    public static Id getProfileIdByName(String profileName){
        return [SELECT Id FROM Profile WHERE Name =:profileName LIMIT 1].Id;
    }

    public static Id getUserRoleIdByName(String roleName){
        return [SELECT Id FROM UserRole WHERE Name =: roleName LIMIT 1].Id;
    }

    public static Id getGroupIdByName(String groupName) {
        return [SELECT Id FROM Group WHERE DeveloperName = :groupName LIMIT 1].Id;
    }

    public static Id getPermissionSetIdByName(String permissionSetName){
        return [SELECT Id, Name FROM PermissionSet WHERE Name =: permissionSetName LIMIT 1].Id;
    }

    public static Id getPermissionGroupIdByName(String permissionGroupDeveloperName) {
        return [SELECT Id FROM PermissionSetGroup WHERE DeveloperName = :permissionGroupDeveloperName].Id;
    }

    public static Map<String, PermissionSet> getPermissionSetMapByNames(Set<String> names) {
        Map<String, PermissionSet> names2PermissionSets = new Map<String, PermissionSet>();
        List<PermissionSet> permissionSets = [SELECT Id, Name FROM PermissionSet WHERE Name IN:names];
        for (PermissionSet permissionSet : permissionSets) {
            names2PermissionSets.put(
                permissionSet.Name, permissionSet
            );
        }
        return names2PermissionSets;
    }

    public static Map<String, PermissionSetGroup> getPermissionSetGroupMapByNames(Set<String> names) {
        Map<String, PermissionSetGroup> names2PermissionSetGroups = new Map<String, PermissionSetGroup>();
        List<PermissionSetGroup> permissionSetGroups = [SELECT Id, DeveloperName FROM PermissionSetGroup WHERE DeveloperName IN:names];
        for (PermissionSetGroup permissionSetGroup : permissionSetGroups) {
            names2PermissionSetGroups.put(
                permissionSetGroup.DeveloperName, permissionSetGroup
            );
        }
        return names2PermissionSetGroups;
    }

    public static Map<String, Profile> getProfileMapByNames(Set<String> names) {
        Map<String, Profile> names2Profiles = new Map<String, Profile>();
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name IN:names];
        for (Profile profile : profiles) {
            names2Profiles.put(
                profile.Name, profile
            );
        }
        return names2Profiles;
    }

    @AuraEnabled
    public static String getCurrentUserLanguage(){
        return UserInfo.getLanguage();
    }

    @AuraEnabled
    public static void changeCurrentUserLanguage(String language) {
        update new User(
            Id = UserInfo.getUserId(),
            LanguageLocaleKey = language
        );
    }

    @AuraEnabled
    public static Boolean checkIfUserHasSpecifiedProfile(String profileName){
        return UserInfo.getProfileId() == getProfileIdByName(profileName);
    }

    public static Approval.ProcessResult submitForApproval(Id recordId, String comments){
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments(comments);
        req.setObjectId(recordId);
        Approval.ProcessResult result = Approval.process(req);
        System.debug('Approval Process Request: ' + result );
        return  result;
    }

    public static Boolean isFieldChanged(SObject oldRecord, SObject newRecord, String fieldApiName) {
        return (oldRecord == null && newRecord != null) ||
            oldRecord.get(fieldApiName) != newRecord.get(fieldApiName);
    }

    public static List<SObject> sortRecordCollectionByFieldValues(
        List<SObject> records, String fieldApiName, Set<String> fieldValues
    ) {
        List<SObject> recordsToReturn = new List<SObject>();
        for (SObject r : records) {
            if (r.get(fieldApiName) != null && fieldValues.contains(String.valueOf(r.get(fieldApiName)))) {
                recordsToReturn.add(r);
            }
        }
        return recordsToReturn;
    }

    public static User fetchUserDetailsById(Id userId){
        return [SELECT Id, ContactId FROM User WHERE Id = :userId LIMIT 1];
    }

    public static String getSiteUrlFromCommunity(String networkId) {
        String siteUrl;
        if (!Test.isRunningTest()) {
            ConnectApi.Community community = DT_Utils.fetchCommunityByNetworkId(networkId);
            siteUrl = community.siteUrl;
        } else {
            siteUrl = '';
        }
        return siteUrl;
    }

    public static String fetchNetworkIdByName(String networkName) {
        String networkId;
        if (Test.isRunningTest()) {
            Network networkMySWPS = [
                SELECT Name, Id
                FROM Network
                WHERE Name = :networkName
            ];
            networkId = networkMySWPS.Id;
        } else {
            networkId = Network.getNetworkId();
        }
        return networkId;
    }

    public static ConnectApi.Community fetchCommunityByNetworkId(String networkId) {
        return ConnectApi.Communities.getCommunity(networkId);
    }

    public static ContentVersion createContentVersionFromBlob(String name, Blob body, String contentLocation) {
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = ContentLocation;
        contentVersion.PathOnClient = name;
        contentVersion.Title = name;
        contentVersion.VersionData = body;
        return contentVersion;
    }

    public static ContentDocumentLink createContentDocumentLink(Id linkedEntityId, Id contentDocumentId, String shareType, String visibility) {
    ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
    contentDocumentLink.ContentDocumentId = contentDocumentId;
    contentDocumentLink.LinkedEntityId = linkedEntityId;
    contentDocumentLink.ShareType = shareType;
    contentDocumentLink.Visibility = visibility;
    return contentDocumentLink;
    }
}