public without sharing class TB_vu_UserInfo {
    @AuraEnabled(Cacheable=true)
    public static String getUserProfileLicenseName() {
        return [SELECT Profile.UserLicense.Name FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1].Profile.UserLicense.Name;
    }
}