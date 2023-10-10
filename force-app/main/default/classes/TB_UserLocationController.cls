/**
 * Created by Aneta on 07/12/2021.
 */

public without sharing class TB_UserLocationController {

    @AuraEnabled
    public static String checkIsAllowedCountry() {
        String currentCountry = getCountryFromLastUserLoginHistory();
        if (currentCountry == null || currentCountry == 'NOT_LOGGED_USER') {
            return 'NOT_LOGGED';
        } else {
            return checkISOCodeList(currentCountry);
        }
    }
    
    @AuraEnabled
    public static String getCountryByIp(String ipAddress) {
        try {
            AuthSession authSession =  [
                SELECT LoginGeoId
                FROM AuthSession
                WHERE SourceIp =: ipAddress
                LIMIT 1
            ];
            LoginGeo lg = [
                SELECT CountryIso
                FROM LoginGeo
                WHERE Id =: authSession.LoginGeoId
            ];
            return checkISOCodeList(lg.CountryIso);
        } catch(Exception e) {
            return 'ALLOW';
        }
    }

    private static String getCountryFromLastUserLoginHistory() {
        try {
            LoginHistory loginHistory = [
                SELECT CountryIso
                FROM LoginHistory
                WHERE UserId =: UserInfo.getUserId()
                ORDER BY LoginTime DESC
                LIMIT 1
            ];
            return loginHistory.CountryIso;
        } catch(Exception e) {
            return 'NOT_LOGGED_USER';
        }
    }

    private static String checkISOCodeList(String currentCountry) {
        try {
            List<TB_Admission_Black_List_ISO_Code__mdt> isoCodes = [SELECT TB_Country_ISO_Code__c FROM TB_Admission_Black_List_ISO_Code__mdt];
            for (TB_Admission_Black_List_ISO_Code__mdt singleCode : isoCodes) {
                if (singleCode.TB_Country_ISO_Code__c == currentCountry) {
                    return 'BLOCKED_COUNTRY';
                }
            }
            return 'ALLOW';
        }catch(Exception e) {
            return 'ALLOW';
        }
    }
}