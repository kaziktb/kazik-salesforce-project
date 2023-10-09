global class CareerOfficeOfferConsentCreator {
    @InvocableMethod(
        Label='Career Office Offer - Create consent for contact'
        Description='Creates TB_Consent__c records for contact based on user selection on Career Office Offer forms. If provided consent is already created for given contact another consent wont be created'
        Category='Career Office Offer'
    )
    global static void createConsentsForContact(List<CareerOfficeOfferConsentCreatorRequest> requests) {
        List<TB_Consent__c> consentsToCreate = new List<TB_Consent__c>();

        if (requests.isEmpty()) {
            return;
        }

        CareerOfficeOfferConsentCreatorRequest request = requests[0];

        List<TB_Admissions_Dictionary__c> consentTemplates = [
            SELECT Id, Name, TB_Consent_Type__c, TB_Communication_Channel__c, TB_Description_EN__c, TB_Description_PL__c
            FROM TB_Admissions_Dictionary__c
            WHERE Id IN :request.consentDefinitionIds
                AND Id NOT IN (
                    SELECT TB_Consent_Definition__c
                    FROM TB_Consent__c
                    WHERE TB_Contact__c = :request.contactId
            )
        ];

        for (TB_Admissions_Dictionary__c consentTemplate : consentTemplates) {
            consentsToCreate.add(createConsentWithTemplate(consentTemplate, request));
        }

        insert consentsToCreate;
    }

    private static TB_Consent__c createConsentWithTemplate(TB_Admissions_Dictionary__c consentTemplate, CareerOfficeOfferConsentCreatorRequest request) {
        return new TB_Consent__c(
            TB_Consent_Definition__c = consentTemplate.Id,
            TB_Contact__c = request.contactId,
            Name = consentTemplate.Name,
            TB_Consent_Type__c = consentTemplate.TB_Consent_Type__c,
            TB_Communication_Channel__c = consentTemplate.TB_Communication_Channel__c,
            TB_Status__c = DT_Utils.CONSENT_STATUS_OPT_IN_API_NAME,
            TB_Effective_From__c = System.now(),
            TB_Source_Type__c = DT_Utils.CONSENT_SOURCE_TYPE_WWW_API_NAME,
            TB_User_Details__c = request.userDetails,
            TB_Source__c = request.formUrl,
            TB_Consent_Text_EN__c = consentTemplate.TB_Description_EN__c,
            TB_Consent_Text_PL__c = consentTemplate.TB_Description_PL__c
        );
    }

    global class CareerOfficeOfferConsentCreatorRequest {
        @InvocableVariable(label='Contact record id' required=true)
        public Id contactId;
        @InvocableVariable(label='Consent definition ids' description='Checked consent definition ids from career office offer form' required=true)
        public List<Id> consentDefinitionIds;
        @InvocableVariable(label='Form URL' description='Career Office Offer form url' required=true)
        public String formUrl;
        @InvocableVariable(label='User details' description='Information about user from his browser' required=true)
        public String userDetails;
    }
}