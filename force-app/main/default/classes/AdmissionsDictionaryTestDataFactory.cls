public class AdmissionsDictionaryTestDataFactory {
    public static List<TB_Admissions_Dictionary__c> createCareerOfficeConsentBundle(Integer amountOfRecords, Boolean withInsert) {
        Id consentDefinitionBundleRecordTypeId = Utils.getRecordTypeIdByDevName(TB_Admissions_Dictionary__c.getSObjectType(), Constants.ADMISSIONS_DICTIONARY_RECORD_TYPE_CONSENT_DEFINITION_BUNDLE_DEV_NAME);

        List<TB_Admissions_Dictionary__c> bundles = new List<TB_Admissions_Dictionary__c>();
        for (Integer i = 0; i < amountOfRecords; i++) {
            bundles.add(new AdmissionsDictionaryTestData()
                .withUsedOn(Constants.ADMISSIONS_DICTIONARY_USED_ON_CAREER_OFFICE_FORM_API_NAME)
                .withRecordTypeId(consentDefinitionBundleRecordTypeId).get());
        }

        if (withInsert) {
            insert bundles;
        }

        return bundles;
    }

    public static List<TB_Admissions_Dictionary__c> createCareerOfficeConsentDefinition(Integer amountOfRecords, Id bundleId, String consentType, Boolean withInsert) {
        Id consentDefinitionRecordTypeId = Utils.getRecordTypeIdByDevName(TB_Admissions_Dictionary__c.getSObjectType(), TB_Constants.TB_CONSENT_CONSENT_DEFINITION_RT_DEVNAME);

        List<TB_Admissions_Dictionary__c> consentDefinitions = new List<TB_Admissions_Dictionary__c>();
        for (Integer i = 0; i < amountOfRecords; i++) {
            consentDefinitions.add(new AdmissionsDictionaryTestData()
                .withDescriptionEN(AdmissionsDictionaryTestData.DEFAULT_DESCRIPTION_EN)
                .withDescriptionPL(AdmissionsDictionaryTestData.DEFAULT_DESCRIPTION_PL)
                .withConsentType(consentType)
                .withConsentBundle(bundleId)
                .withRecordTypeId(consentDefinitionRecordTypeId).get());
        }

        if (withInsert) {
            insert consentDefinitions;
        }

        return consentDefinitions;
    }

}