public with sharing class TB_re_UserProfileController {

    @AuraEnabled
    public static Contact getContact(Id contactId) {
        return [
            SELECT Id, hed__AlternateEmail__c, Salutation, FirstName, MiddleName, LastName, TB_Family_Name__c,
                hed__Citizenship__c, DT_Place_of_Birth__c, DT_Country_of_Birth__c, TB_Pole_s_Card__c,
                TB_Has_PESEL__c, DT_PESEL__c, DT_Type_of_Identity_Document__c, DT_Document_Series_and_Number__c,
                DT_Document_Issuing_Country__c, TB_Mother_s_Name__c, TB_Mother_s_Surname__c, TB_Father_s_Name__c,
                TB_Father_s_Surname__c, MobilePhone, OtherPhone, TB_x_Document_Search__c, TB_City_or_Village__c,
                TB_Other_Mailing_Address__c, OtherAddress, OtherCountry, OtherStreet, OtherPostalCode, OtherCity,
                OtherState, MailingAddress, MailingCountry, MailingStreet, MailingPostalCode, MailingCity,
                MailingState, OtherCountryCode, MailingCountryCode, OtherStateCode, MailingStateCode,
                TB_ICE_Contact_Phone__c, TB_ICE_Contact_Person__c, TB_Study_Level_Interest__c,
                TB_x_Personal_Information__c, TB_x_Address_Information__c, TB_Birthdate_Day__c,
                TB_Birthdate_Month__c, TB_Birthdate_Year__c
            FROM Contact
            WHERE Id = :contactId
        ];
    }

    @AuraEnabled
    public static Map<String, TB_StringUtils.PicklistWrapper> getPicklistValues() {
        List<String> fieldNames = new List<String>{
            'Salutation',
            'hed__Citizenship__c',
            'DT_Country_of_Birth__c',
            'DT_Type_of_Identity_Document__c',
            'DT_Document_Issuing_Country__c',
            'OtherCountryCode',
            'OtherStateCode',
            'MailingCountryCode',
            'MailingStateCode',
            'TB_Study_Level_Interest__c'
        };
        Map<String, TB_StringUtils.PicklistWrapper> fieldNameToPicklistValues = new Map<String, TB_StringUtils.PicklistWrapper>();
        TB_StringUtils.PicklistWrapper picklistWrapper;
        for (String fieldName : fieldNames) {
            picklistWrapper = TB_StringUtils.getPicklistWrapperByApiName(TB_re_Constants.TB_CONTACT_LABEL, fieldName);
            if (fieldName == 'Salutation') {
                List<String> values = new List<String>();
                List<String> labels = new List<String>();
                for (Integer i = 0; i < picklistWrapper.choicesValues.size(); i++) {
                    if (
                        picklistWrapper.choicesValues[i] == 'Mr.'
                            || picklistWrapper.choicesValues[i] == 'Ms.'
                        ) {
                        values.add(picklistWrapper.choicesValues[i]);
                        labels.add(picklistWrapper.choicesLabels[i]);
                    }
                }
                picklistWrapper.choicesValues = values;
                picklistWrapper.choicesLabels = labels;
            }
            if (fieldName == 'DT_Type_of_Identity_Document__c') {
                List<String> values = new List<String>();
                List<String> labels = new List<String>();
                for (Integer i = 0; i < picklistWrapper.choicesValues.size(); i++) {
                    if (
                        picklistWrapper.choicesValues[i] == TB_re_Constants.TB_TYPE_OF_ID_PASSPORT
                            || picklistWrapper.choicesValues[i] == TB_re_Constants.TB_TYPE_OF_ID_FOREIGN_ID
                        ) {
                        values.add(picklistWrapper.choicesValues[i]);
                        labels.add(picklistWrapper.choicesLabels[i]);
                    }
                }
                picklistWrapper.choicesValues = values;
                picklistWrapper.choicesLabels = labels;
            }
            fieldNameToPicklistValues.put(fieldName, picklistWrapper);
        }
        return fieldNameToPicklistValues;
    }

    @AuraEnabled
    public static Boolean isAnAdult(Integer year, Integer month, Integer day) {
        try {
            Date birthdate = Date.newInstance(year, month, day);
            return birthdate.addYears(18) <= System.today();
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    @AuraEnabled
    public static List<TB_Admissions_Dictionary__c> getStates() {

        try {
            List<TB_JSON_Wrapper__c> jsonWrappers = [
                SELECT Id, TB_Wrapper_Value__c
                FROM TB_JSON_Wrapper__c
                WHERE TB_Record_Type_Dev_Name__c = :TB_re_Constants.ADMISSIONS_DICTIONARY_RT_COUNTRY_STATE_DEVNAME
            ];

            Set<TB_Admissions_Dictionary__c> admissionsDictionaries = new Set<TB_Admissions_Dictionary__c>();
            for (TB_JSON_Wrapper__c jsonWrapper : jsonWrappers) {
                TB_Admissions_Dictionary__c admissionsDictionary = (TB_Admissions_Dictionary__c) JSON.deserialize(
                    jsonWrapper.TB_Wrapper_Value__c, TB_Admissions_Dictionary__c.class
                );
                if (admissionsDictionary.TB_Active__c == true) {
                    admissionsDictionaries.add(admissionsDictionary);
                }
            }

            return new List<TB_Admissions_Dictionary__c>(admissionsDictionaries);
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    @AuraEnabled
    public static String updateContact(Contact contact) {
        update contact;
        return null;
    }

}