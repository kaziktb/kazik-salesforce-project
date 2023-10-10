/**
 * Created by adriangawryszewski on 11/17/22.
 */

global with sharing class TB_SWPSJITGenericHandler implements Auth.SamlJitHandler {

// CAS Attributes
    private static final String SAML_ATTRIBUTE_FIRST_NAME_LABEL = 'firstName';
    private static final String SAML_ATTRIBUTE_LASTNAME_LABEL = 'lastName';
    private static final String SAML_ATTRIBUTE_EMPLOYEE_TYPE_LABEL = 'employeeType';
    private static final String SAML_ATTRIBUTE_EMPLOYEE_TYPE_STUDENT = 'Student';
    private static final String SAML_ATTRIBUTE_EMPLOYEE_TYPE_EMPLOYEE = 'Worker';
    private static final String SF_ATTRIBUTE_EMPLOYEE_TYPE = 'Employee';
    private static final String SAML_ATTRIBUTE_EMPLOYEE_IM_ID_LABEL = 'employeeID';// in case if we need to store IM Id in future

    global User createUser(
            Id samlSsoProviderId,
            Id communityId,
            Id portalId,
            String federationIdentifier,
            Map<String, String> attributes,
            String assertion) {
        User u;
        String userType = attributes.get(SAML_ATTRIBUTE_EMPLOYEE_TYPE_LABEL) == SAML_ATTRIBUTE_EMPLOYEE_TYPE_EMPLOYEE ? SF_ATTRIBUTE_EMPLOYEE_TYPE : attributes.get(SAML_ATTRIBUTE_EMPLOYEE_TYPE_LABEL);  
        List<Contact> contacts = getContactForFederationId(userType, federationIdentifier);
        System.debug('userType' + userType);
        if (contacts == null || contacts.isEmpty()) {
            System.debug('CAS Exception >> No contact for email: ');
            insertLogObject('CAS Exception >> No contact for email: ', federationIdentifier);
        } else if (contacts.size() == 1) {
            System.debug('CAS Exception >> There are contact for email: ');
            TB_JITHandler_metadata__mdt metadata = getMetadataForUserType(attributes.get(SAML_ATTRIBUTE_EMPLOYEE_TYPE_LABEL));
            System.debug('metadata' + metadata);
            try {
                u = createNewUserFromSAML(federationIdentifier, attributes, contacts[0], metadata);
            } catch(Exception e){
                System.debug(e.getMessage());
            }
            Set<String> permSetsIds = createFieldValueSet((List<sObject>) metadata.JITHandler_metadata_perm_sets__r, 'TB_Permission_Set__c');
            if (!permSetsIds.isEmpty()) {
                addPermissionSetsToUser(u.Id, permSetsIds);
            }
        } else {
            System.debug('CAS Exception >> More than one contact for email:');
            insertLogObject('CAS Exception >> More than one contact for email: ', federationIdentifier);
        }
        return u;
    }

    global void updateUser(Id userId,
            Id samlSsoProviderId,
            Id communityId,
            Id portalId,
            String federationIdentifier,
            Map<String, String> attributes,
            String assertion) {

        User u = [SELECT Id, IsActive FROM USER WHERE Id = :userId];
        if (!u.IsActive) {
            User usr = new User(
                    Id = userId,
                    IsActive = true
            );
            try {
                update usr;
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }
    }


    @future
    private static void addPermissionSetsToUser(String userId, Set<String> permissionSets) {
        List<PermissionSetAssignment> permSetsToInsert = new List<PermissionSetAssignment>();
        List<PermissionSet> permissionSetsObjects = [SELECT Id FROM PermissionSet WHERE Name IN :permissionSets];
        for (PermissionSet ps : permissionSetsObjects) {
            permSetsToInsert.add(TB_UserUtils.assignPermSetToUser(userId, ps.Id));
        }
        try {
            insert permSetsToInsert;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    private User createNewUserFromSAML(
            String federationIdentifier,
            Map<String, String> attributes,
            Contact contact,
            TB_JITHandler_metadata__mdt metadata
    ) {

        Profile p = [SELECT Id FROM Profile WHERE Name = :metadata.TB_Default_Profile__c];
        String username = metadata.TB_Default_Username_Prefix__c + contact.TB_Customer_Id__c + metadata.TB_Default_Username_Suffix__c;
        
        String contactId = attributes.get(SAML_ATTRIBUTE_EMPLOYEE_TYPE_LABEL) == SAML_ATTRIBUTE_EMPLOYEE_TYPE_EMPLOYEE ? null : contact.Id;

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
            updateContactWithUserField(contact.Id, u.Id);
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e, TB_SWPSJITGenericHandler.class);
            return null;
        }
        return u;
    }

//metadata mapping - Profile + Perm Sets + Default User values
    private static TB_JITHandler_metadata__mdt getMetadataForUserType(String userType) {
        return TB_UserUtils.getMetadataForUserType(userType);
    }

    private List<Contact> getContactForFederationId(String userType, String email) {
        List<Contact> contacts;
        contacts = [
                SELECT Id,
                        TB_Customer_Id__c
                FROM Contact
                WHERE
                (hed__UniversityEmail__c = :email OR hed__WorkEmail__c = :email)
                AND RecordType.Name = :userType
        ];

        return contacts;
    }

    private static Set<String> createFieldValueSet(List<SObject> collection, String field) {
        Set<String> result = new Set<String>();
        for (SObject so : collection) {
            result.add((String) so.get(field));
        }
        return result;
    }
    @future
    private static void updateContactWithUserField(String contactId, String userId) {
        Contact ct = new Contact(
                Id = contactId,
                TB_User__c = userId
        );
        try {
            update ct;
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e, TB_AdmissionPortalSamlJITHandler.class);
        }
    }
    private User insertLogObject(String errorMessage, String fedId) {
        TB_LogUtils.registerLog(errorMessage + fedId, TB_SWPSJITGenericHandler.class);
        //insertLogObjectFuture(errorMessage, fedId);
        return null;
    }

    @future
    private static void insertLogObjectFuture(String errorMessage, String fedId) {
        try {
            insert TB_LogUtils.registerLog(errorMessage + fedId, TB_SWPSJITGenericHandler.class);
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e, TB_AdmissionPortalSamlJITHandler.class);
        }
    }
}
