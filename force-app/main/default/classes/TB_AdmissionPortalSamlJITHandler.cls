/**
 * Created by adriangawryszewski on 1/11/22.
 */

global with sharing class TB_AdmissionPortalSamlJITHandler implements Auth.SamlJitHandler {

    public class TB_AdmissionPortalSamlJITHandlerException extends Exception {
    }
    // CAS Attributes
    private static final String SAML_ATTRIBUTE_FIRST_NAME_LABEL = 'firstName';
    private static final String SAML_ATTRIBUTE_LASTNAME_LABEL = 'lastName';
    private static final String SAML_ATTRIBUTE_EMPLOYEE_TYPE_LABEL = 'employeeType';
    private static final String SAML_ATTRIBUTE_EMPLOYEE_TYPE_STUDENT = 'Student';
    private static final String SAML_ATTRIBUTE_EMPLOYEE_TYPE_EMPLOYEE = 'Worker';
    private static final String SAML_ATTRIBUTE_EMPLOYEE_IM_ID_LABEL = 'employeeID';// in case if we need to store IM Id in future

    private static final String TB_DEFAULT_EMAIL_ENCODING = 'UTF-8';
    private static final String TB_LANGUAGE_LOCALE_KEY = 'en_US';
    private static final String TB_LOCALE_SID_KEY = 'pl_PL';
    private static final String TB_TIME_ZONE_SID_KEY = 'Europe/Prague';
    private static final String STUDENT_USERNAME_SUFFIX = '@st.swps.edu.pl';
    private static final String STUDENT_USERNAME_PREFIX = 'Applicant';


    global User createUser(
            Id samlSsoProviderId,
            Id communityId,
            Id portalId,
            String federationIdentifier,
            Map<String, String> attributes,
            String assertion) {
        /*User u;
        List<Contact> contacts = getContactForFederationId(attributes.get(SAML_ATTRIBUTE_EMPLOYEE_TYPE_LABEL), federationIdentifier);
        if (contacts == null || contacts.isEmpty()) {
            //no contact creation on any time
        } else if (contacts.size() == 1) {
             u = createNewUserFromSAML(federationIdentifier, attributes, contacts[0].Id, contacts[0].TB_Customer_Id__c);
        } else {
            insert TB_LogUtils.registerLog('CAS Exception >> More than one contact for email: ' + federationIdentifier, TB_AdmissionPortalSamlJITHandler.class);
            //throw new TB_AdmissionPortalSamlJITHandlerException('Something went wrong with your registration request. Please contact Admission Office');
        }
        return u;*/
        return null;
    }

    global void updateUser(Id userId,
            Id samlSsoProviderId,
            Id communityId,
            Id portalId,
            String federationIdentifier,
            Map<String, String> attributes,
            String assertion) {
    }


    private User createNewUserFromSAML(
            String federationIdentifier,
            Map<String, String> attributes,
            String contactId,
            String customerId
            ) {

        TB_JITHandler_metadata__mdt metadata = getMetadataForUserType(attributes.get(SAML_ATTRIBUTE_EMPLOYEE_TYPE_LABEL));
        Profile p = [SELECT Id FROM Profile WHERE Name = :metadata.TB_Default_Profile__c];
        String username = null;//metadata.TB_Default_Student_Username_Prefix__c + customerId + metadata.TB_Default_Student_Username_Suffix__c;

        User u = TB_UserUtils.createNewUser(
                attributes.get(SAML_ATTRIBUTE_FIRST_NAME_LABEL),
                attributes.get(SAML_ATTRIBUTE_LASTNAME_LABEL),
                federationIdentifier,
                p.Id,
                metadata.TB_Default_Time_Zone_Sid_Key__c,
                metadata.TB_Default_Locale_Sid_Key__c,
                metadata.TB_Default_Email_Encoding__c,
                metadata.TB_Default_Language_Key__c,
                contactId,
                username,
                federationIdentifier
        );

        try {
            insert u;
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e, TB_AdmissionPortalSamlJITHandler.class);
            return null;
        }
        return u;
    }

    //metadata mapping - Profile + Perm Sets + Default User values
    private TB_JITHandler_metadata__mdt getMetadataForUserType(String userType) {
        return null;/*[
                SELECT TB_Default_Email_Encoding__c,
                        TB_Default_Locale_Sid_Key__c,
                        TB_Default_Student_Username_Prefix__c,
                        TB_Default_Student_Username_Suffix__c,
                        TB_Default_Time_Zone_Sid_Key__c,
                        TB_Default_Profile__c,
                        TB_Default_Language_Key__c,
                        TB_Default_Contact_Record_Type__c, (
                        SELECT
                                MasterLabel
                        FROM JITHandler_metadata_perm_sets__r
                )
                FROM TB_JITHandler_metadata__mdt
                WHERE TB_User_Type__c = :userType
                LIMIT 1
        ];*/
    }

    private List<Contact> getContactForFederationId(String userType, String email) {
        List<Contact> contacts;
        contacts = [
                SELECT Id,
                        TB_Customer_Id__c
                FROM Contact
                WHERE
                (Email = :email OR
                hed__UniversityEmail__c = :email OR
                hed__WorkEmail__c = :email OR
                hed__AlternateEmail__c = :email)
                AND RecordType.DeveloperName = :userType
        ];

        return contacts;
    }
}