public without sharing class MySwpsConsentCreator {
    public static void createConsentsForContact(Set<Id> consentDefinitionIds, String userDetails, String formUrl, Id contactId) {
        List<TB_Consent__c> consentsToCreate = new List<TB_Consent__c>();

        List<TB_Admissions_Dictionary__c> consentTemplates = [
            SELECT Id, Name, TB_Consent_Type__c, TB_Communication_Channel__c, TB_Description_EN__c, TB_Description_PL__c
            FROM TB_Admissions_Dictionary__c
            WHERE Id IN :consentDefinitionIds
                AND Id NOT IN (
                    SELECT TB_Consent_Definition__c
                    FROM TB_Consent__c
                    WHERE TB_Contact__c = :contactId
                )
        ];

        for (TB_Admissions_Dictionary__c consentTemplate : consentTemplates) {
            consentsToCreate.add(createConsentWithTemplate(consentTemplate, userDetails, formUrl, contactId));
        }

        insert consentsToCreate;
    }

    private static TB_Consent__c createConsentWithTemplate(TB_Admissions_Dictionary__c consentTemplate, String userDetails, String formUrl, Id contactId) {
        return new TB_Consent__c(
            TB_Consent_Definition__c = consentTemplate.Id,
            TB_Contact__c = contactId,
            Name = consentTemplate.Name,
            TB_Consent_Type__c = consentTemplate.TB_Consent_Type__c,
            TB_Communication_Channel__c = consentTemplate.TB_Communication_Channel__c,
            TB_Status__c = Constants.CONSENT_STATUS_OPT_IN_API_NAME,
            TB_Effective_From__c = System.now(),
            TB_Source_Type__c = Constants.CONSENT_SOURCE_TYPE_WWW_API_NAME,
            TB_User_Details__c = userDetails,
            TB_Source__c = formUrl,
            TB_Consent_Text_EN__c = consentTemplate.TB_Description_EN__c,
            TB_Consent_Text_PL__c = consentTemplate.TB_Description_PL__c
        );
    }
}