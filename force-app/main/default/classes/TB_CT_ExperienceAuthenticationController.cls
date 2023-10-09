public without sharing class TB_CT_ExperienceAuthenticationController {
    private static final String EMPLOYEE_CONTACT_RT_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('TB_Employee').getRecordTypeId();

    public class UserAuthenticationWrapper {
        public Boolean isSuccess;
        public String message;
    }

    @AuraEnabled
    public static String getContractTeacherPortal() {
        List<TB_TC_URLs__c> admissionsPortal = [
                SELECT TB_Admissions_Portal__c
                FROM TB_TC_URLs__c
        ];

        return admissionsPortal[0].TB_Admissions_Portal__c;
    }

    @AuraEnabled
    public static String sendChangePasswordEmail(String email) {
        UserAuthenticationWrapper wrapper = new UserAuthenticationWrapper();
        wrapper.isSuccess = true;
        Contact applicantContact;

        List<User> usr = [
                SELECT Id, IsActive, FirstName, TB_Verification_Code__c
                FROM User
                WHERE Email = :email AND TB_Verification_Code__c != NULL
        ];

        if (usr.isEmpty()) {
            wrapper.message = 'USER_VERIFICATION.USER_NOT_FOUND';
            wrapper.isSuccess = false;
        } else {
            try {
                applicantContact = [SELECT Id FROM Contact WHERE TB_User__c = :usr[0].Id];
                Map<String, Object> resetPasswordFlowParameters = new Map<String, Object>{
                        'RecordId' => applicantContact.Id,
                        'MessageType' => 'PasswordReset',
                        'FirstName' => usr[0].FirstName,
                        'EmailAddress' => email,
                        'URL' => getContractTeacherPortal() +
                                'login/ForgotPassword/?verificationCode=' +
                                usr[0].TB_Verification_Code__c
                };
                Flow.Interview.TB_Contract_Teachers_Account_Handling_Notification resetPasswordFlow = new Flow.Interview.TB_Contract_Teachers_Account_Handling_Notification(
                        resetPasswordFlowParameters
                );

                resetPasswordFlow.start();
                if (resetPasswordFlow.success) {
                    wrapper.isSuccess = true;
                } else {
                    wrapper.isSuccess = false;
                }
            } catch (Exception e) {
                insert TB_LogUtils.registerLog(e);
                throw new AuraHandledException(e.getMessage());

            }
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
        ];

        if (usr.isEmpty()) {
            wrapper.message = 'USER_VERIFICATION.USER_NOT_FOUND';
        } else if (!usr[0].IsActive) {
            wrapper.message = 'USER_VERIFICATION.USER_INACTIVE';
        } else {
            try {
                if (!Test.isRunningTest()) {
                    System.setPassword(usr[0].Id, password);
                }
                wrapper.isSuccess = true;
                wrapper.message = 'USER_FORGOT_PASSWORD.SUCCESS';
            } catch (Exception e) {
                wrapper.message = e.getMessage();
            }
        }

        return JSON.serialize(wrapper);
    }

    @AuraEnabled
    public static String doLogin(String username, String password) {
        UserAuthenticationWrapper wrapper = new UserAuthenticationWrapper();
        wrapper.isSuccess = false;

        List<User> usr = [
                SELECT Id, IsActive, Username
                FROM User
                WHERE Email = :username AND TB_Verification_Code__c != NULL
                AND Contact.RecordTypeId = :EMPLOYEE_CONTACT_RT_ID
        ];

        if (usr.isEmpty()) {
            wrapper.message = 'USER_VERIFICATION.USER_NOT_FOUND';
            wrapper.isSuccess = false;
        } else if (!usr[0].IsActive) {
            wrapper.message = 'USER_VERIFICATION.USER_INACTIVE';
        } else {
            ApexPages.PageReference pageRef;
            if (Test.isRunningTest()) {
                try {
                    pageRef = new PageReference([SELECT TB_Admissions_Portal__c FROM TB_TC_URLs__c LIMIT 1].TB_Admissions_Portal__c);
                } catch (Exception e) {
                    wrapper.message = 'TEST_ERROR';
                }
            } else {
                try {
                    pageRef = Site.login(usr[0].Username, password, null);
                } catch (Exception e) {
                    wrapper.message = 'USER_VERIFICATION.PASSWORD_NOT_MATCH';
                }
            }
            if (pageRef != null) {
                wrapper.message = pageRef.getUrl();
                wrapper.isSuccess = true;
            }
        }

        return JSON.serialize(wrapper);
    }
}