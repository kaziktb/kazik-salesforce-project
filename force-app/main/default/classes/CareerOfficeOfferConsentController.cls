public without sharing class CareerOfficeOfferConsentController {

    private static String ContextLanguage;

    @AuraEnabled(Cacheable=true)
    public static List<Consent> fetchConsents(String consentDefinitionBundleName, String pageContextLanguage) {
        ContextLanguage = pageContextLanguage;

        Id consentDefinitionBundleRecordTypeId = DT_Utils.getRecTypeIdByDevName(DT_Utils.ADMISSIONS_DICTIONARY_RT_CONSENT_DEFINITION_BUNDLE_DEV_NAME, TB_Admissions_Dictionary__c.SObjectType.getDescribe().getName());

        List<TB_Admissions_Dictionary__c> consents = [
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
        ];

        return createResultConsents(consents);
    }

    private static List<Consent> createResultConsents(List<TB_Admissions_Dictionary__c> consents) {
        List<Consent> resultConsents = new List<Consent>();

        if (consents == null || consents.isEmpty()) {
            AuraHandledException auraHandledException = new AuraHandledException(Label.BundleWithoutDefinitionErrorMessage);
            auraHandledException.setMessage(Label.BundleWithoutDefinitionErrorMessage);
            throw auraHandledException;
        }

        for (TB_Admissions_Dictionary__c consent : consents) {
            resultConsents.add(
                new Consent(
                    consent.Id,
                    consent.TB_Consent_Type__c,
                    consent.TB_Description_PL__c,
                    consent.TB_Description_EN__c
                )
            );
        }
        return resultConsents;
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

        public Consent(Id recordId, String type, String descriptionPL, String descriptionEN) {
            this.recordId = recordId;
            this.type = type;
            this.description = ContextLanguage == 'pl' ? descriptionPL : descriptionEN;
            this.isRequired = type == DT_Utils.ADMISSIONS_DICTIONARY_CONSENT_TYPE_TERMS_AND_CONDITIONS;
        }
    }
}