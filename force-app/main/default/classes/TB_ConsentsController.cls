public virtual without sharing class TB_ConsentsController {
    @AuraEnabled
    public static String getConsents() {
        Map<Id,List<AdmissionConsentsWrapper>> consentsForBundle = new Map<Id,List<AdmissionConsentsWrapper>>();
        try {
            for (TB_JSON_Wrapper__c jsonWrapper : [
                SELECT TB_Wrapper_Value__c
                FROM TB_JSON_Wrapper__c
                WHERE TB_Object_API_Name__c = :TB_Constants.TB_OBJECT_API_NAME_ADMISSIONS_DICTIONARY
                AND TB_Record_Type_Dev_Name__c = :TB_Constants.TB_CONSENT_CONSENT_DEFINITION_RT_DEVNAME
                ORDER BY TB_Order__c
            ]
            ) {
                TB_Admissions_Dictionary__c singleDictionary
                    = (TB_Admissions_Dictionary__c) JSON.deserialize(jsonWrapper.TB_Wrapper_Value__c, TB_Admissions_Dictionary__c.class);
                if (
                    singleDictionary.TB_Consents_Bundle__c != null
                        && singleDictionary.TB_Active__c
                    ) {
                    if (consentsForBundle.containsKey(singleDictionary.TB_Consents_Bundle__c)) {
                        List<AdmissionConsentsWrapper> consents = consentsForBundle.get(singleDictionary.TB_Consents_Bundle__c);
                        consents.add(new AdmissionConsentsWrapper(singleDictionary));
                        consentsForBundle.put(singleDictionary.TB_Consents_Bundle__c, consents);
                    } else {
                        consentsForBundle.put(singleDictionary.TB_Consents_Bundle__c, new List<AdmissionConsentsWrapper>{
                            new AdmissionConsentsWrapper(singleDictionary)
                        });
                    }
                }
            }
            return JSON.serialize(consentsForBundle);
        }catch(Exception e) {
            TB_LogUtils.registerLog(e);
            return null;
        }
    }

    @AuraEnabled
    public static List<AdmissionConsentsWrapper> getRegistrationConsents(String language) {
        List<AdmissionConsentsWrapper> result = new List<AdmissionConsentsWrapper>();
        for (TB_Admissions_Dictionary__c singleDictionary : [
            SELECT Id, TB_Consent_Type__c, TB_Description_PL__c, TB_Description_EN__c
            FROM TB_Admissions_Dictionary__c
            WHERE RecordType.DeveloperName = 'TB_Consent_Definition' 
                AND TB_Consents_Bundle__r.TB_Used_On__c = 'Admissions_Registration_Form' 
                AND TB_Consents_Bundle__r.TB_Active__c = True 
                AND TB_Valid_From__c <= TODAY 
                AND (TB_Valid_To__c >= TODAY OR TB_Valid_To__c = null)
                AND TB_Active__c=True ORDER BY TB_Order__c
        ]){
            AdmissionConsentsWrapper singleWrapper = new AdmissionConsentsWrapper(singleDictionary);
            singleWrapper.displayDescriptionValue = (String) singleDictionary.get('TB_Description_' + language + '__c');
            result.add(singleWrapper);
        }
        return result;
    }

    public class AdmissionConsentsWrapper
    {
        @AuraEnabled public TB_Admissions_Dictionary__c consent {get;set;}
        @AuraEnabled public Boolean informationalFlag {get;set;}
        @AuraEnabled public Boolean marketingFlag {get;set;}
        @AuraEnabled public Boolean termsFlag {get;set;}
        @AuraEnabled public Boolean value {get;set;}
        @AuraEnabled public String checkboxClasses {get;set;}
        @AuraEnabled public String checkmarkClasses {get;set;}
        @AuraEnabled public String displayDescriptionValue {get;set;}

        public AdmissionConsentsWrapper(TB_Admissions_Dictionary__c admissionConsent) {
            this.consent = admissionConsent;
            this.informationalFlag = false;
            this.marketingFlag = false;
            this.termsFlag = false;
            this.value = false;
            this.checkboxClasses = value ? TB_re_Constants.CHECKED_CLASS : TB_re_Constants.UNCHECKED_CLASS;
            this.checkmarkClasses = value ? TB_re_Constants.ACTIVE_CLASS : TB_re_Constants.INACTIVE_CLASS;
            setConsentsFlag(admissionConsent);
        }

        private void setConsentsFlag(TB_Admissions_Dictionary__c admissionConsent) {
            switch on admissionConsent.TB_Consent_Type__c{
                when 'Terms and Conditions' {
                    this.termsFlag = true;
                }
                when 'Informational' {
                    this.informationalFlag = true;
                }
                when 'Marketing' {
                    this.marketingFlag = true;
                }
                when null {
                    this.informationalFlag = true;
                }
                when else {
                    this.informationalFlag = true;
                }
            }
        }
    }
}