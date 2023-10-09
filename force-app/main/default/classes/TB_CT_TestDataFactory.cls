public with sharing class TB_CT_TestDataFactory {
   private static final String EMAIL_VERIFIED_NAME = 'Rekrutacja Uniwersytet SWPS';

    public static void insertCTUrls(){
        TB_TC_URLs__c url = new TB_TC_URLs__c(TB_Admissions_Portal__c  = TB_Constants.TB_CT_ADMISSIONS_PORTAL);   
        insert url;
    }

    public static void insertCTEmail(){
        OrgWideEmailAddress address = [
            SELECT Id, Address
            FROM OrgWideEmailAddress
            WHERE DisplayName =: EMAIL_VERIFIED_NAME
            LIMIT 1
        ];
        TB_CT_Contract_Teachers_Email__c ctEmail = new TB_CT_Contract_Teachers_Email__c(TB_CT_Email__c = address.Address);
        insert ctEmail;
    }
}