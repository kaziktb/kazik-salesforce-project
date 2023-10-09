/**
 * Created by adriangawryszewski on 1/11/22.
 */

public with sharing class TB_UserUtils {

    public static User createNewUser(
            String firstname,
            String lastname,
            String email,
            String profileId,
            String defaultTimeZoneSidKey,
            String defaultLocaleSidKey,
            String emailEncodingKey,
            String languageLocaleKey,
            String contactId,
            String username,
            String fedId) {

        User u = new User();
        u.FirstName = firstname;
        u.LastName = lastname;
        u.Email = email;
        u.Username = username;
        if (fedId != null) {
            u.FederationIdentifier = fedId; //email is used as a NameId/FederationId for SWPS
        }
        if (profileId != null) {
            u.ProfileId = profileId;
        }
        if (username.length() < 38) {
            u.CommunityNickname = username;
        } else {
            u.CommunityNickname = username.substring(0, 38);
        }

        u.Alias = generateUserAlias(firstname, lastname);
        u.TimeZoneSidKey = defaultTimeZoneSidKey;
        u.LocaleSidKey = defaultLocaleSidKey;
        u.EmailEncodingKey = emailEncodingKey;
        u.LanguageLocaleKey = languageLocaleKey;
        if(contactId != null){
           u.ContactId = contactId; 
        }        
        
        return u;
    }

    public static PermissionSetAssignment assignPermSetToUser(String userId, String permSetId) {
        return new PermissionSetAssignment
                (PermissionSetId = permSetId, AssigneeId = userId);
    }

    public static TB_JITHandler_metadata__mdt getMetadataForUserType(String userType) {
        return [
                SELECT TB_Default_Email_Encoding__c,
                        TB_Default_Locale_Sid_Key__c,
                        TB_Default_Username_Prefix__c,
                        TB_Default_Username_Suffix__c,
                        TB_Default_Time_Zone_Sid_Key__c,
                        TB_Default_Profile__c,
                        TB_Default_Language_Key__c,
                        TB_Default_Contact_Record_Type__c, (
                        SELECT
                                MasterLabel,
                                TB_Permission_Set__c
                        FROM JITHandler_metadata_perm_sets__r
                )
                FROM TB_JITHandler_metadata__mdt
                WHERE TB_User_Type__c = :userType
                LIMIT 1
        ];
    }

    private static String generateUserAlias(String firstname, String lastname) {
        return firstname.substring(0, 2).toLowercase() + lastname.substring(0, 2).toLowercase();
    }

}
