public with sharing class TB_QuickLoginController {
    public static String API_NAME_APPLICATION = 'hed__Application__c';
    public static String ADMISSION_COMMUNITY_NAME = 'SWPS - Admissions Portal';
    @AuraEnabled
    public static String getQuickLoginUrl(String recordId) {
        String contactId;
        try {
            String networkId = [
                    SELECT Id
                    FROM Network
                    WHERE Name = :ADMISSION_COMMUNITY_NAME
            ].Id;
            if (((Id) recordId).getSObjectType().getDescribe().getName() == API_NAME_APPLICATION) {
                contactId = [
                        SELECT hed__Applicant__c
                        FROM hed__Application__c
                        WHERE Id = :recordId
                ].hed__Applicant__c;
            } else {
                contactId = recordId;
            }
            String userId = [
                    SELECT TB_User__c
                    FROM Contact
                    WHERE ID = :contactId
            ].TB_User__c;
            return URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.su?oid=' + UserInfo.getOrganizationId() +
                    +'&retURL=&sunetworkid=' + networkId + '&sunetworkuserid=' + userId;
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }
}