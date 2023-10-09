public without sharing class TB_ExperienceAuthenticationController extends TB_ConsentsController {

    private static final String APPLICANT_METADATA_TYPE = 'Applicant';
    private static final String MORE_THAN_ONE_CONTACT = 'MORE_THAN_ONE_CONTACT';
    private static final String PORTAL_USER_EXISTS_FOR_CONTACT = 'PORTAL_USER_EXISTS_FOR_CONTACT';
    private static final String APPLICANT_CONTACT_RT_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('TB_Applicant').getRecordTypeId();

    @AuraEnabled
    public static String doLogin(String username, String password) {
        UserAuthenticationWrapper wrapper = new UserAuthenticationWrapper();
        wrapper.isSuccess = false;

        List<User> usr = [
                SELECT Id, IsActive, Username
                FROM User
                WHERE Email = :username AND TB_Verification_Code__c != NULL
                AND Contact.RecordTypeId = :APPLICANT_CONTACT_RT_ID
        ];

        if (usr.isEmpty()) {
            wrapper.message = 'USER_VERIFICATION.USER_NOT_FOUND';
            wrapper.isSuccess = false;
        } else if (!usr[0].IsActive) {
            wrapper.message = 'USER_VERIFICATION.USER_INACTIVE';
        } else {
            ApexPages.PageReference pageRef;
            try {
                pageRef = Site.login(usr[0].Username, password, null);
            } catch (Exception e) {
                wrapper.message = 'USER_VERIFICATION.PASSWORD_NOT_MATCH';
            }
            if (pageRef != null) {
                wrapper.message = pageRef.getUrl();
                wrapper.isSuccess = true;
            }
        }

        return JSON.serialize(wrapper);
    }

    @AuraEnabled
    public static Boolean doesEmailExist(String username) {
        try {
            List<User> users = new List<User>();
            users = [
                    SELECT Id, Name
                    FROM User
                    WHERE Email = :username
                    AND Contact.RecordTypeId = :APPLICANT_CONTACT_RT_ID
            ];

            return !users.isEmpty();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String registerUser(
            String firstName,
            String lastName,
            String email,
            String password
    ) {
        User u;
        String accountId;
        TB_JITHandler_metadata__mdt metadata;
        try {
            metadata = TB_UserUtils.getMetadataForUserType(APPLICANT_METADATA_TYPE);
            String verificationCode = EncodingUtil.convertToHex(
                    Crypto.generateDigest('MD5', Blob.valueOf(email))
            );

            List<Contact> currentContact = [
                    SELECT Id, AccountId, Account.IsCustomerPortal
                    FROM Contact
                    WHERE
                    hed__AlternateEmail__c = :email
                    AND RecordTypeId = :APPLICANT_CONTACT_RT_ID
            ];

            u = TB_UserUtils.createNewUser(
                    firstName,
                    lastName,
                    email,
                    null,
                    metadata.TB_Default_Time_Zone_Sid_Key__c,
                    metadata.TB_Default_Locale_Sid_Key__c,
                    metadata.TB_Default_Email_Encoding__c,
                    metadata.TB_Default_Language_Key__c,
                    null,
                    metadata.TB_Default_Username_Prefix__c
                        + verificationCode
                        + System.now().getTime() / 1000
                        + metadata.TB_Default_Username_Suffix__c,
                    null
            );
            u.TB_Verification_Code__c = verificationCode;
            u.TB_Registration_Url__c = Url.getSalesforceBaseUrl().toExternalForm();


            if (currentContact.size() == 1) {
                if (!currentContact[0].Account.IsCustomerPortal) {

                    u.ContactId = currentContact[0].Id;
                    accountId = currentContact[0].AccountId;
                } else {
                    return PORTAL_USER_EXISTS_FOR_CONTACT;
                }
            } else if (currentContact.size() == 0) {
                Account portalAccount = new Account();
                portalAccount.Name = firstName + ' ' + lastName;
                try {
                    insert portalAccount;
                } catch (Exception e) {
                    insert TB_LogUtils.registerLog(e, TB_ExperienceAuthenticationController.class);
                }
                accountId = portalAccount.Id;
            } else {
                return MORE_THAN_ONE_CONTACT;
            }

            String userId = Site.createExternalUser(u, accountId, password);


            sendNotificationToCandidate(firstname, email, verificationCode);
            //async to speed up a process
            Contact contact = [
                    SELECT Id
                    FROM Contact
                    WHERE Accountid = :accountId
                    LIMIT 1
            ];
            deactivateUser(userId);
            updateContactWithExtraDetails(contact.Id, email, userId);

            return contact.Id;
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);

            if (!Test.isRunningTest()) {
                throw new AuraHandledException(e.getMessage());
            }
            return e.getMessage();
        }
    }

    @Future
    private static void deactivateUser(String userId) {
        update new User(Id = userId, IsActive = false);
    }

    @Future
    private static void updateContactWithExtraDetails(String contactId, String email, String userId) {

        Contact contact = new Contact (Id = contactId);
        contact.email = email;
        contact.hed__AlternateEmail__c = email;
        contact.RecordTypeId = APPLICANT_CONTACT_RT_ID;
        contact.TB_User__c = userId;
        try {
            update contact;
        } catch(Exception e) {
            insert TB_LogUtils.registerLog(e, TB_ExperienceAuthenticationController.class);
        }
    }

    @future
    private static void sendNotificationToCandidate(String firstName, String email, String verificationCode){
        Map<String, Object> accountActivationFlowParameters = new Map<String, Object>{
                'MessageType' => 'AccountActivation',
                'FirstName' => firstName,
                'EmailAddress' => email,
                'URL' => getAdmissionsPortal() +
                        'logUser/verification/?verificationCode=' +
                        verificationCode
        };
        Flow.Interview.TB_Admissions_Applicant_Account_Handling_Notifications accountActivationFlow = new Flow.Interview.TB_Admissions_Applicant_Account_Handling_Notifications(
                accountActivationFlowParameters
        );
        accountActivationFlow.start();
    }

    @AuraEnabled
    public static String verifyUser(String verificationCode) {
        UserAuthenticationWrapper wrapper = new UserAuthenticationWrapper();
        wrapper.isSuccess = true;

        List<User> usr = [
                SELECT Id, IsActive
                FROM User
                WHERE TB_Verification_Code__c = :verificationCode
        ];

        if (usr.isEmpty()) {
            wrapper.message = 'USER_VERIFICATION.USER_NOT_FOUND';
            wrapper.isSuccess = false;
        } else if (usr[0].IsActive) {
            wrapper.message = 'USER_VERIFICATION.USER_ALREADY_ACTIVATED';
        } else {
            update new User(Id = usr[0].Id, IsActive = true);
            wrapper.message = 'USER_VERIFICATION.SUCCESS';
        }

        return JSON.serialize(wrapper);
    }

    @AuraEnabled
    public static String sendChangePasswordEmail(String email) {
        UserAuthenticationWrapper wrapper = new UserAuthenticationWrapper();
        wrapper.isSuccess = true;

        List<User> usr = [
                SELECT Id, IsActive, FirstName, TB_Verification_Code__c
                FROM User
                WHERE Email = :email AND TB_Verification_Code__c != NULL
                AND Contact.RecordType.DeveloperName = 'TB_Applicant'
        ];

        if (usr.isEmpty()) {
            wrapper.message = 'USER_VERIFICATION.USER_NOT_FOUND';
            wrapper.isSuccess = false;
        } else {
            Map<String, Object> resetPasswordFlowParameters = new Map<String, Object>{
                    'MessageType' => 'PasswordReset',
                    'FirstName' => usr[0].FirstName,
                    'EmailAddress' => email,
                    'URL' => getAdmissionsPortal() +
                            'login/ForgotPassword/?verificationCode=' +
                            usr[0].TB_Verification_Code__c
            };
            Flow.Interview.TB_Admissions_Applicant_Account_Handling_Notifications resetPasswordFlow = new Flow.Interview.TB_Admissions_Applicant_Account_Handling_Notifications(
                    resetPasswordFlowParameters
            );
            resetPasswordFlow.start();
        }

        return JSON.serialize(wrapper);
    }

    @AuraEnabled
    public static String resetPassword(String verificationCode, String password) {
        UserAuthenticationWrapper wrapper = new UserAuthenticationWrapper();
        wrapper.isSuccess = false;

        List<User> usr = [
                SELECT Id, IsActive
                FROM User
                WHERE TB_Verification_Code__c = :verificationCode
                AND Contact.RecordTypeId = :APPLICANT_CONTACT_RT_ID
        ];

        if (usr.isEmpty()) {
            wrapper.message = 'USER_VERIFICATION.USER_NOT_FOUND';
        } else if (!usr[0].IsActive) {
            wrapper.message = 'USER_VERIFICATION.USER_INACTIVE';
        } else {
            try {
                System.setPassword(usr[0].Id, password);
                wrapper.isSuccess = true;
                wrapper.message = 'USER_FORGOT_PASSWORD.SUCCESS';
            } catch (Exception e) {
                wrapper.message = e.getMessage();
            }
        }

        return JSON.serialize(wrapper);
    }

    public class UserAuthenticationWrapper {
        public Boolean isSuccess;
        public String message;
    }

    @AuraEnabled
    public static Boolean createConsentsForNewUser(
            String contactId,
            String admissionConsents,
            String communityUrl
    ) {
        Set<AdmissionConsentsWrapper> wrappers;
        try {
            if (admissionConsents != null) {
                wrappers = (Set<AdmissionConsentsWrapper>) JSON.deserialize(
                        admissionConsents,
                        Set<AdmissionConsentsWrapper>.class
                );
            } else {
                return true;
            }
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return false;
        }

        List<TB_Consent__c> consents = new List<TB_Consent__c>();
        for (AdmissionConsentsWrapper singleWrapper : wrappers) {
            TB_Consent__c singleConsent = new TB_Consent__c(
                    Name = singleWrapper.consent.Name,
                    TB_Contact__c = contactId,
                    TB_Effective_From__c = System.now(),
                    TB_Source__c = communityUrl,
                    TB_Source_Type__c = 'WWW',
                    TB_Consent_Text_EN__c = singleWrapper.consent.TB_Description_EN__c,
                    TB_Consent_Text_PL__c = singleWrapper.consent.TB_Description_PL__c,
                    TB_Consent_Definition_Id__c = singleWrapper.consent.Id,
                    TB_Consent_Type__c = singleWrapper.consent.TB_Consent_Type__c,
                    TB_Status__c = getStatusForConsent(singleWrapper)
            );
            consents.add(singleConsent);
        }
        try {
            insert consents;
            return true;
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return false;
        }
    }

    private static String getStatusForConsent(
            AdmissionConsentsWrapper singleWrapper
    ) {
        switch on singleWrapper.consent.TB_Consent_Type__c {
            when 'Informational' {
                return 'Seen';
            }
            when 'Marketing', 'Terms and Conditions' {
                return singleWrapper.value ? 'Opt_In' : 'Lack';
            }
        }
        return null;
    }

    @AuraEnabled
    public static String getAdmissionsPortal() {
        List<TB_Admission_URLs__c> admissionsPortal = [
                SELECT TB_Admissions_Portal__c
                FROM TB_Admission_URLs__c
        ];

        return admissionsPortal[0].TB_Admissions_Portal__c;
    }
}