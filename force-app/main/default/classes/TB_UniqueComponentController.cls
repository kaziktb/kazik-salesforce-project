public without sharing class TB_UniqueComponentController {

    public static List<String> currencyFieldNames = new List<String> {
        'PLN', 'EUR'
    };

    @AuraEnabled
    public static ContactsWrapper getContactForAddressComponent (String applicationId) {

        try {
            hed__Application__c application = [
                SELECT Id, hed__Applicant__c
                FROM hed__Application__c
                WHERE Id = :applicationId
            ];
            Id contactId = application.hed__Applicant__c;

            String query = ''
                + ' SELECT Id, TB_City_or_Village__c, TB_Other_Mailing_Address__c,'
                + ' OtherAddress, OtherCountry, OtherStreet, OtherPostalCode, OtherCity, OtherState,'
                + ' MailingAddress, MailingCountry, MailingStreet, MailingPostalCode, MailingCity, MailingState,'
                + ' OtherCountryCode, MailingCountryCode, OtherStateCode, MailingStateCode'
                + ' FROM Contact'
                + ' WHERE Id = :contactId';

            Contact contact = (Contact) Database.query(query);
            ContactsWrapper contactWrapper = new ContactsWrapper(contact);

            return contactWrapper;
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    @AuraEnabled
    public static String updateContact(String contactJSON) {

        String errorMessage = '';
        List<TB_Log__c> logs = new List<TB_Log__c>();
        try {
            Contact contact = (Contact) JSON.deserialize(contactJSON, Contact.class);

            if (contact != null) {
                Database.SaveResult result = Database.update(
                    contact,
                    false
                );
                if (!result.isSuccess()) {
                    for (Database.Error error : result.getErrors()) {
                        if (String.isNotBlank(error.getMessage())) {
                            if(error.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                                String errorLine = error.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION, ').substringBefore(': [');
                                errorMessage = errorLine;
                            } else {
                                errorMessage = error.getMessage();
                            }
                            logs.add(TB_LogUtils.registerLog(error.getMessage(), TB_UniqueComponentController.class));
                        } else {
                            errorMessage = System.Label.TB_Toast_Error_Message_Wrong;
                            logs.add(TB_LogUtils.registerLog(error.getMessage(), TB_UniqueComponentController.class));
                        }
                    }
                }
            }
        } catch (Exception e) {
            errorMessage = System.Label.TB_Toast_Error_Message_Wrong;
            logs.add(TB_LogUtils.registerLog(e));
        }

        insert logs;

        return errorMessage;
    }

    @AuraEnabled
    public static ApplicationWrapper getApplicationForTuitionComponent (String applicationId) {

        try {
            hed__Application__c application = [
                SELECT Id, TB_Applying_To_Offered_Product__r.TB_Tuition_Fee_PLN_1_Instalment__c,
                    TB_Applying_To_Offered_Product__r.TB_Tuition_Fee_PLN_2_Instalment__c,
                    TB_Applying_To_Offered_Product__r.TB_Tuition_Fee_PLN_10_Instalment__c,
                    TB_Applying_To_Offered_Product__r.TB_Tuition_Fee_EUR_1_Instalment__c,
                    TB_Applying_To_Offered_Product__r.TB_Tuition_Fee_EUR_2_Instalment__c,
                    TB_Applying_To_Offered_Product__r.TB_Tuition_Fee_EUR_10_Instalment__c,
                    TB_Tuition_Instalment__c, TB_Tuition_Fee__c, TB_Tuition_Fee_Currency__c,
                    TB_Tuition_Fee_Base_Amount__c, TB_Hide_Tuition_Amounts__c,
                    TB_Employer_Address__c, TB_Employer_City__c, TB_Employer_Country__c,
                    TB_Employer_Name__c, TB_Employer_VAT_ID__c, TB_Employer_ZIP__c,
                    TB_Tripartite_Agreement__c, TB_Self_Employed__c, TB_Pro_Forma_Invoice_Requested__c,
                    hed__Applicant__r.hed__Citizenship__c, TB_Product_Group__c
                FROM hed__Application__c
                WHERE Id = :applicationId
            ];

            ApplicationWrapper applicationWrapper = new ApplicationWrapper(application);

            return applicationWrapper;
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    @AuraEnabled
    public static String updateApplication(String applicationJSON) {

        String errorMessage = '';
        List<TB_Log__c> logs = new List<TB_Log__c>();
        try {
            hed__Application__c application = (hed__Application__c) JSON.deserialize(applicationJSON, hed__Application__c.class);

            if (application != null) {
                Database.SaveResult result = Database.update(
                    application,
                    false
                );
                if (!result.isSuccess()) {
                    for (Database.Error error : result.getErrors()) {
                        if (String.isNotBlank(error.getMessage())) {
                            if(error.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                                String errorLine = error.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION, ').substringBefore(': [');
                                errorMessage = errorLine;
                            } else {
                                errorMessage = error.getMessage();
                            }
                            logs.add(TB_LogUtils.registerLog(error.getMessage(), TB_UniqueComponentController.class));
                        } else {
                            errorMessage = System.Label.TB_Toast_Error_Message_Wrong;
                            logs.add(TB_LogUtils.registerLog(error.getMessage(), TB_UniqueComponentController.class));
                        }
                    }
                }
            }
        } catch (Exception e) {
            errorMessage = System.Label.TB_Toast_Error_Message_Wrong;
            logs.add(TB_LogUtils.registerLog(e));
        }

        insert logs;

        return errorMessage;
    }

    @AuraEnabled
    public static List<TB_Admissions_Dictionary__c> getStates() {

        try {
            List<TB_JSON_Wrapper__c> jsonWrappers = [
                SELECT Id, TB_Wrapper_Value__c
                FROM TB_JSON_Wrapper__c
                WHERE TB_Record_Type_Dev_Name__c = 'TB_Country_State'
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

    public class ApplicationWrapper {
        @AuraEnabled public hed__Application__c app { get; set; }
        @AuraEnabled public List<String> radioChoicesValues { get; set; }
        @AuraEnabled public List<String> radioChoicesLabels { get; set; }
        @AuraEnabled public String currencyLabel { get; set; }
        @AuraEnabled public Boolean hideTuitionAmounts { get; set; }
        @AuraEnabled public Boolean polishCitizenship { get; set; }

        public ApplicationWrapper(hed__Application__c app) {

            this.app = app;
            this.hideTuitionAmounts = app.TB_Hide_Tuition_Amounts__c;
            this.polishCitizenship = app.hed__Applicant__r.hed__Citizenship__c == 'Poland';
            setRadioChoicesPicklists(app);
        }

        public void setRadioChoicesPicklists(hed__Application__c app)
        {
            List<String> values = new List<String>();
            List<String> labels = new List<String>();
            TB_Offered_Product__c offeredProduct = (TB_Offered_Product__c ) app.getSObject('TB_Applying_To_Offered_Product__r');

            for (String singleFieldName : currencyFieldNames) {
                String annually = String.valueOf(offeredProduct.get('TB_Tuition_Fee_' + singleFieldName + '_1_Instalment__c'));
                String termly = String.valueOf(offeredProduct.get('TB_Tuition_Fee_' + singleFieldName + '_2_Instalment__c'));
                String monthly = String.valueOf(offeredProduct.get('TB_Tuition_Fee_' + singleFieldName + '_10_Instalment__c'));
                if (annually != null) {
                    this.currencyLabel = singleFieldName;
                    values.add(annually);
                    labels.add('01');
                    if (termly != null) {
                        values.add(termly);
                        labels.add('02');
                    }
                    if (monthly != null) {
                        values.add(monthly);
                        labels.add('10');
                    }
                }
            }

            this.radioChoicesValues = values;
            this.radioChoicesLabels = labels;
        }
    }

    public class ContactsWrapper {
        @AuraEnabled public Contact con { get; set; }
        @AuraEnabled public List<String> countryChoicesValues { get; set; }
        @AuraEnabled public List<String> countryChoicesLabels { get; set; }
        @AuraEnabled public List<String> stateChoicesValues { get; set; }
        @AuraEnabled public List<String> stateChoicesLabels { get; set; }

        public ContactsWrapper(Contact con) {
            List<List<String>> countryValuesAndLabelsPrioritized = TB_StringUtils.getPolandOnTop(new List<List<String>>{
                TB_StringUtils.getPicklistValuesOrLabelsSortedByLabel('Contact','OtherCountryCode','values'),
                TB_StringUtils.getPicklistValuesOrLabelsSortedByLabel('Contact','OtherCountryCode','labels')
            });
            List<List<String>> stateValuesAndLabelsPrioritized = new List<List<String>>{
                TB_StringUtils.getPicklistValuesOrLabelsSortedByLabel('Contact','OtherStateCode','values'),
                TB_StringUtils.getPicklistValuesOrLabelsSortedByLabel('Contact','OtherStateCode','labels')
            };

            this.con = con;
            this.countryChoicesValues = countryValuesAndLabelsPrioritized[0];
            this.countryChoicesLabels = countryValuesAndLabelsPrioritized[1];
            this.stateChoicesValues = stateValuesAndLabelsPrioritized[0];
            this.stateChoicesLabels = stateValuesAndLabelsPrioritized[1];
        }
    }
}