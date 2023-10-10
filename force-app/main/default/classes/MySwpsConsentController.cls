public without sharing class MySwpsConsentController {

    @AuraEnabled(Cacheable=true)
    public static List<Consent> fetchConsents(String consentDefinitionBundleName, String pageContextLanguage) {
        Id consentDefinitionBundleRecordTypeId = Utils.getRecordTypeIdByDevName(TB_Admissions_Dictionary__c.SObjectType, Constants.ADMISSIONS_DICTIONARY_RECORD_TYPE_CONSENT_DEFINITION_BUNDLE_DEV_NAME);
        List<Consent> resultConsents = new List<Consent>();

        for (TB_Admissions_Dictionary__c consent : [
            SELECT
                Id,
                Name,
                TB_Consent_Type__c,
                TB_Description_PL__c,
                TB_Description_EN__c,
                TB_Order__c
            FROM TB_Admissions_Dictionary__c
            WHERE TB_Consents_Bundle__r.Name = :consentDefinitionBundleName
                AND TB_Consents_Bundle__r.RecordTypeId = :consentDefinitionBundleRecordTypeId
            ORDER BY TB_Order__c ASC
        ]) {
            resultConsents.add(
                new Consent(
                    consent.Id,
                    consent.TB_Consent_Type__c,
                    consent.TB_Description_PL__c,
                    consent.TB_Description_EN__c,
                    pageContextLanguage
                )
            );
        }

        if (!resultConsents.isEmpty()) {
            return resultConsents;
        }

        AuraHandledException auraHandledException = new AuraHandledException(Label.BundleWithoutDefinitionErrorMessage);
        auraHandledException.setMessage(Label.BundleWithoutDefinitionErrorMessage);
        throw auraHandledException;
    }

    @TestVisible
    private class Consent {
        @AuraEnabled
        public Id recordId;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public Boolean isRequired;
        @AuraEnabled
        public Boolean isChecked = false;
        @AuraEnabled
        public String description;

        public Consent(Id recordId, String type, String descriptionPL, String descriptionEN, String pageContextLanguage) {
            this.recordId = recordId;
            this.type = type;
            this.description = pageContextLanguage == 'pl' ? descriptionPL : descriptionEN;
            this.isRequired = type == Constants.ADMISSIONS_DICTIONARY_CONSENT_TYPE_TERMS_AND_CONDITIONS;
        }
    }
}