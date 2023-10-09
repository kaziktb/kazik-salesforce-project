@IsTest
public class CareerOfficeOfferConsentControllerTest {
    private static final String PageContextLanguagePL = 'pl';
    private static final String PageContextLanguageEN = 'en-US';
    
    @TestSetup
    static void setup() {
        AdmissionsDictionaryTestDataFactory.createCareerOfficeConsentBundle(1, true);
    }

    @IsTest
    public static void fetchConsentsTermsAndConditionsPLSuccess() {
        TB_Admissions_Dictionary__c bundle = [SELECT Id, Name FROM TB_Admissions_Dictionary__c WHERE TB_Consents_Bundle__c = NULL LIMIT 1];
        AdmissionsDictionaryTestDataFactory.createCareerOfficeConsentDefinition(1, bundle.Id, DT_Utils.ADMISSIONS_DICTIONARY_CONSENT_TYPE_TERMS_AND_CONDITIONS, true);

        Test.startTest();
        CareerOfficeOfferConsentController.Consent consent = CareerOfficeOfferConsentController.fetchConsents(bundle.Name, PageContextLanguagePL)[0];
        Test.stopTest();

        Assert.areEqual(AdmissionsDictionaryTestData.DEFAULT_DESCRIPTION_PL, consent.description);
        Assert.areEqual(DT_Utils.ADMISSIONS_DICTIONARY_CONSENT_TYPE_TERMS_AND_CONDITIONS, consent.type);
        Assert.areEqual(true, consent.isRequired);
    }

    @IsTest
    public static void fetchConsentsMarketingENSuccess() {
        TB_Admissions_Dictionary__c bundle = [SELECT Id, Name FROM TB_Admissions_Dictionary__c WHERE TB_Consents_Bundle__c = NULL LIMIT 1];
        AdmissionsDictionaryTestDataFactory.createCareerOfficeConsentDefinition(1, bundle.Id, DT_Utils.ADMISSIONS_DICTIONARY_CONSENT_TYPE_MARKETING, true);

        Test.startTest();
        CareerOfficeOfferConsentController.Consent consent = CareerOfficeOfferConsentController.fetchConsents(bundle.Name, PageContextLanguageEN)[0];
        Test.stopTest();

        Assert.areEqual(AdmissionsDictionaryTestData.DEFAULT_DESCRIPTION_EN, consent.description);
        Assert.areEqual(DT_Utils.ADMISSIONS_DICTIONARY_CONSENT_TYPE_MARKETING, consent.type);
        Assert.areEqual(false, consent.isRequired);
    }

    @IsTest
    public static void fetchConsentsEmptyBundleSuccess() {
        TB_Admissions_Dictionary__c bundle = [SELECT Id, Name FROM TB_Admissions_Dictionary__c WHERE TB_Consents_Bundle__c = NULL LIMIT 1];
        AuraHandledException auraException;
        
        Test.startTest();
        try {
            CareerOfficeOfferConsentController.fetchConsents(bundle.Name, PageContextLanguageEN);
        } catch (AuraHandledException auraHandledException) {
            auraException = auraHandledException;
        }
        Test.stopTest();

        Assert.isNotNull(auraException);
        Assert.areEqual(Label.BundleWithoutDefinitionErrorMessage, auraException.getMessage());
    }

}