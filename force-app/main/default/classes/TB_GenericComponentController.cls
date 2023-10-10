public without sharing class TB_GenericComponentController {

    public static Map<String, String> parentObjectToObjectPath = new Map<String, String>{
        TB_Constants.TB_APPLICATION_LABEL => '',
        TB_Constants.TB_CONTACT_LABEL => hed__Application__c.hed__Applicant__c.getDescribe().getRelationshipName()
    };
    public static Map<String, String> labelToAPIName = new Map<String, String>{
        TB_Constants.TB_APPLICATION_LABEL => hed__Application__c.SObjectType.getDescribe().getName(),
        TB_Constants.TB_CONTACT_LABEL => Contact.SObjectType.getDescribe().getName()
    };
    public static List<String> sourceFieldsWithPath = new List<String>();
    public static List<String> targetFieldsWithPath = new List<String>();
    public static Map<Id, SObject> objectsToUpdate = new Map<Id, SObject>();

    @AuraEnabled
    public static List<DataDefinitionWrapper> getStepsData (String stepId, String applicationId) {
        try {
            Map<Id, TB_JSON_Wrapper__c> dataDefinitionIdToJsonWrapper = new Map<Id, TB_JSON_Wrapper__c>();
            Set<TB_Admissions_Data_Definition__c> dataDefinitions = new Set<TB_Admissions_Data_Definition__c>();

            List<TB_JSON_Wrapper__c> jsonStepsDataWrappers = [
                SELECT Id, TB_Wrapper_Value__c
                FROM TB_JSON_Wrapper__c
                WHERE TB_Parent_JSON_Wrapper__r.TB_Object_Id__c = :stepId
                AND TB_Object_API_Name__c = 'TB_Admissions_Step_Data__c'
                ORDER BY TB_Order__c
            ];

            for (TB_JSON_Wrapper__c jsonWrapper : jsonStepsDataWrappers) {
                TB_Admissions_Step_Data__c stepData = (TB_Admissions_Step_Data__c) JSON.deserialize(
                    jsonWrapper.TB_Wrapper_Value__c, TB_Admissions_Step_Data__c.class
                );
                if (stepData.TB_Active__c == true) {
                    dataDefinitionIdToJsonWrapper.put(stepData.TB_Admissions_Data_Definition__c, new TB_JSON_Wrapper__c());
                }
            }

            List<TB_JSON_Wrapper__c> jsonDataDefinitionWrappers = [
                SELECT Id, TB_Wrapper_Value__c, TB_Object_Id__c
                FROM TB_JSON_Wrapper__c
                WHERE TB_Object_Id__c IN :dataDefinitionIdToJsonWrapper.keySet()
            ];

            for (TB_JSON_Wrapper__c jsonWrapper : jsonDataDefinitionWrappers) {
                dataDefinitionIdToJsonWrapper.put(jsonWrapper.TB_Object_Id__c, jsonWrapper);
            }

            for (Id key : dataDefinitionIdToJsonWrapper.keySet()) {
                TB_Admissions_Data_Definition__c dataDefinition = (TB_Admissions_Data_Definition__c) JSON.deserialize(
                    dataDefinitionIdToJsonWrapper.get(key).TB_Wrapper_Value__c, TB_Admissions_Data_Definition__c.class
                );
                if (dataDefinition.TB_Active__c == true) {
                    if (dataDefinition.TB_Source_Object__c == TB_Constants.TB_CONTACT_LABEL) {
                        sourceFieldsWithPath.add(parentObjectToObjectPath.get(TB_Constants.TB_CONTACT_LABEL) + '.' + dataDefinition.TB_Source_Object_Field__c);
                    } else if (dataDefinition.TB_Source_Object__c == TB_Constants.TB_APPLICATION_LABEL) {
                        sourceFieldsWithPath.add(dataDefinition.TB_Source_Object_Field__c);
                    }
                    dataDefinitions.add(dataDefinition);
                }
            }

            hed__Application__c application = getApplication('Source', applicationId);

            List<DataDefinitionWrapper> dataWrappers = new List<DataDefinitionWrapper>();
            for (TB_Admissions_Data_Definition__c dataDefinition : dataDefinitions) {
                DataDefinitionWrapper singleWrapper = new DataDefinitionWrapper(dataDefinition, application);

                fillValues('Source', singleWrapper.dd, singleWrapper, application);

                if (dataDefinition.TB_Data_Type__c == 'Checkbox') {
                    if (String.isBlank(singleWrapper.textValue)) {
                        singleWrapper.checkboxValue = false;
                    } else {
                        singleWrapper.checkboxValue = Boolean.valueOf(singleWrapper.textValue);
                    }
                }
                if (dataDefinition.TB_Data_Type__c == 'Text (Long)') {
                    if (String.isBlank(singleWrapper.longTextValue)) {
                        singleWrapper.charactersLeft = dataDefinition.TB_Characters__c;
                    } else {
                        singleWrapper.charactersLeft = dataDefinition.TB_Characters__c - singleWrapper.longTextValue.length();
                    }
                }
                if (dataDefinition.TB_Purpose__c != 'Data_Display') {
                    if (dataDefinition.TB_Label_PL__c != null && dataDefinition.TB_Label_PL__c.contains('<')) {
                        String nameWithoutMarkersPL = dataDefinition.TB_Label_PL__c.replaceAll('<[^>]+>', ' ');
                        singleWrapper.clearNamePl = nameWithoutMarkersPL;
                    } else {
                        singleWrapper.clearNamePl = dataDefinition.TB_Label_PL__c;
                    }
                    if (dataDefinition.TB_Label_EN__c != null && dataDefinition.TB_Label_EN__c.contains('<')) {
                        String nameWithoutMarkersEN = dataDefinition.TB_Label_EN__c.replaceAll('<[^>]+>', ' ');
                        singleWrapper.clearNameEn = nameWithoutMarkersEN;
                    } else {
                        singleWrapper.clearNameEn = dataDefinition.TB_Label_EN__c;
                    }
                    //merge
                    if (dataDefinition.TB_Info_PL__c != null && dataDefinition.TB_Info_PL__c.contains('<')) {
                        String infoWithoutMarkersPL = dataDefinition.TB_Info_PL__c.replaceAll('<[^>]+>', ' ');
                        singleWrapper.clearFieldLevelHelpPl = infoWithoutMarkersPL;
                    } else {
                        singleWrapper.clearFieldLevelHelpPl = dataDefinition.TB_Info_PL__c;
                    }
                    if (dataDefinition.TB_Info_EN__c != null && dataDefinition.TB_Info_EN__c.contains('<')) {
                        String infoWithoutMarkersEN = dataDefinition.TB_Info_EN__c.replaceAll('<[^>]+>', ' ');
                        singleWrapper.clearFieldLevelHelpEn = infoWithoutMarkersEN;
                    } else {
                        singleWrapper.clearFieldLevelHelpEn = dataDefinition.TB_Info_EN__c;
                    }
                }
                //can be shortened
                if (dataDefinition.TB_Source_Object_Field__c == 'hed__Preferred_Email__c') {
                    List<String> values = new List<String>();
                    List<String> labels = new List<String>();
                    for (Integer i = 0; i < singleWrapper.picklistChoicesValues.size(); i++) {
                        if (
                            singleWrapper.picklistChoicesValues[i] == 'Alternate'
                                || singleWrapper.picklistChoicesValues[i] == 'University'
                            ) {
                            values.add(singleWrapper.picklistChoicesValues[i]);
                            labels.add(singleWrapper.picklistChoicesLabels[i]);
                        }
                    }
                    singleWrapper.picklistChoicesValues = values;
                    singleWrapper.picklistChoicesLabels = labels;
                }
                if (dataDefinition.TB_Source_Object_Field__c == 'Salutation') {
                    List<String> values = new List<String>();
                    List<String> labels = new List<String>();
                    for (Integer i = 0; i < singleWrapper.picklistChoicesValues.size(); i++) {
                        if (
                            singleWrapper.picklistChoicesValues[i] == 'Mr.'
                                || singleWrapper.picklistChoicesValues[i] == 'Ms.'
                            ) {
                            values.add(singleWrapper.picklistChoicesValues[i]);
                            labels.add(singleWrapper.picklistChoicesLabels[i]);
                        }
                    }
                    singleWrapper.picklistChoicesValues = values;
                    singleWrapper.picklistChoicesLabels = labels;
                }
                if (dataDefinition.TB_Source_Object_Field__c == 'DT_Type_of_Identity_Document__c') {
                    List<String> values = new List<String>();
                    List<String> labels = new List<String>();
                    for (Integer i = 0; i < singleWrapper.picklistChoicesValues.size(); i++) {
                        if (
                            singleWrapper.picklistChoicesValues[i] == 'PASZPORT'
                                || singleWrapper.picklistChoicesValues[i] == 'ZAGRANICZNY_DOWOD_OSOBISTY'
                            ) {
                            values.add(singleWrapper.picklistChoicesValues[i]);
                            labels.add(singleWrapper.picklistChoicesLabels[i]);
                        }
                    }
                    singleWrapper.picklistChoicesValues = values;
                    singleWrapper.picklistChoicesLabels = labels;
                }
                dataWrappers.add(singleWrapper);
            }

            return dataWrappers;
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    public static hed__Application__c getApplication(String method, String applicationId) {

        List<String> fields = new List<String>();
        if (method == 'Source') {
            fields = sourceFieldsWithPath;
        } else if (method == 'Target') {
            fields = targetFieldsWithPath;
        }
        String joinedFields = String.join(fields, ',');
        joinedFields = joinedFields.removeEnd(',');
        if (String.isNotBlank(joinedFields)) {
            joinedFields = ', ' + joinedFields;
        }
        String citizenship = '';
        if (!joinedFields.contains('hed__Citizenship__c')) {
            citizenship = ', hed__Applicant__r.hed__Citizenship__c';
        }
        String query = ''
            + ' SELECT Id, TB_Applying_To_Offered_Product__r.TB_Product_Group__c,'
            + ' hed__Applicant__r.TB_x_Document_Search__c,'
            + ' hed__Applicant__r.hed__WorkEmail__c, hed__Applicant__r.hed__PreferredPhone__c,'
            + ' TB_MBA__c' + citizenship + joinedFields
            + ' FROM hed__Application__c'
            + ' WHERE Id = :applicationId';
        return (hed__Application__c ) Database.query(query);
    }

    @AuraEnabled
    public static Boolean isAnAdult(String birthDate) {
        try {
            Date birthDateToCheck = Date.valueOf(birthDate);
            return birthDateToCheck.addYears(18) <= System.today();
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    @AuraEnabled
    public static Boolean isTooYoung(String birthDate) {
        try {
            Date birthDateToCheck = Date.valueOf(birthDate);
            return birthDateToCheck.addYears(15) > System.today();
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    public static void fillValues(
        String method,
        TB_Admissions_Data_Definition__c dataDefinition,
        DataDefinitionWrapper singleWrapper,
        hed__Application__c application
    ) {
        if (method == 'Source') {
            if (dataDefinition.TB_Source_Object__c == TB_Constants.TB_CONTACT_LABEL) {
                Contact contact = (Contact) application.getSObject(parentObjectToObjectPath.get(TB_Constants.TB_CONTACT_LABEL));
                if (dataDefinition.TB_Characters__c <= 255 || dataDefinition.TB_Characters__c == null) {
                    singleWrapper.textValue = String.valueOf(contact.get(dataDefinition.TB_Source_Object_Field__c));
                } else {
                    singleWrapper.longTextValue = String.valueOf(contact.get(dataDefinition.TB_Source_Object_Field__c));
                }
            } else if (dataDefinition.TB_Source_Object__c == TB_Constants.TB_APPLICATION_LABEL) {
                if (dataDefinition.TB_Characters__c <= 255 || dataDefinition.TB_Characters__c == null) {
                    singleWrapper.textValue = String.valueOf(application.get(dataDefinition.TB_Source_Object_Field__c));
                } else {
                    singleWrapper.longTextValue = String.valueOf(application.get(dataDefinition.TB_Source_Object_Field__c));
                }
            }
            if(dataDefinition.TB_Data_Type__c == 'Picklist' && String.isNotBlank(singleWrapper.textValue)) {
                singleWrapper.setPicklistValue(dataDefinition);
            }
        } else if (method == 'Target') {
            if (dataDefinition.TB_Target_Object__c == TB_Constants.TB_CONTACT_LABEL) {
                Contact contact = (Contact) application.getSObject(parentObjectToObjectPath.get(TB_Constants.TB_CONTACT_LABEL));
                if (dataDefinition.TB_Characters__c <= 255 || dataDefinition.TB_Characters__c == null) {
                    if (dataDefinition.TB_Data_Type__c == 'Date') {
                        contact.put(dataDefinition.TB_Target_Object_Field__c, Date.valueOf(singleWrapper.textValue));
                    } else if (dataDefinition.TB_Data_Type__c == 'Number') {
                        contact.put(dataDefinition.TB_Target_Object_Field__c, Decimal.valueOf(singleWrapper.textValue));
                    } else if (dataDefinition.TB_Data_Type__c == 'Checkbox') {
                        if (singleWrapper.textValue == 'true') {
                            contact.put(dataDefinition.TB_Target_Object_Field__c, true);
                        } else {
                            contact.put(dataDefinition.TB_Target_Object_Field__c, false);
                        }
                    } else {
                        contact.put(dataDefinition.TB_Target_Object_Field__c, singleWrapper.textValue);
                    }
                } else {
                    contact.put(dataDefinition.TB_Target_Object_Field__c, singleWrapper.longTextValue);
                }
                objectsToUpdate.put(contact.Id, contact);
                objectsToUpdate.put(application.Id, application);
            } else if (dataDefinition.TB_Target_Object__c == TB_Constants.TB_APPLICATION_LABEL) {
                if (dataDefinition.TB_Characters__c <= 255 || dataDefinition.TB_Characters__c == null) {
                    if (dataDefinition.TB_Data_Type__c == 'Date') {
                        application.put(dataDefinition.TB_Target_Object_Field__c, Date.valueOf(singleWrapper.textValue));
                    } else if (dataDefinition.TB_Data_Type__c == 'Number') {
                        application.put(dataDefinition.TB_Target_Object_Field__c, Decimal.valueOf(singleWrapper.textValue));
                    } else if (dataDefinition.TB_Data_Type__c == 'Checkbox') {
                        if (singleWrapper.textValue == 'true') {
                            application.put(dataDefinition.TB_Target_Object_Field__c, true);
                        } else {
                            application.put(dataDefinition.TB_Target_Object_Field__c, false);
                        }
                    } else {
                        application.put(dataDefinition.TB_Target_Object_Field__c, singleWrapper.textValue);
                    }
                } else {
                    application.put(dataDefinition.TB_Target_Object_Field__c, singleWrapper.longTextValue);
                }
                objectsToUpdate.put(application.Id, application);
            }
        }
    }

    @AuraEnabled
    public static List<String> updateDataDefinitions(String dataDefinitionsJSON, String applicationId) {

        String errorMessage = '';
        List<TB_Log__c> logs = new List<TB_Log__c>();
        try {
            Set<DataDefinitionWrapper> dataWrappers =
                (Set<DataDefinitionWrapper>) JSON.deserialize(dataDefinitionsJSON, Set<DataDefinitionWrapper>.class);

            for (DataDefinitionWrapper singleWrapper : dataWrappers) {
                if (singleWrapper.dd.TB_Target_Object__c == TB_Constants.TB_CONTACT_LABEL) {
                    targetFieldsWithPath.add(parentObjectToObjectPath.get(TB_Constants.TB_CONTACT_LABEL) + '.' + singleWrapper.dd.TB_Target_Object_Field__c);
                } else if (singleWrapper.dd.TB_Target_Object__c == TB_Constants.TB_APPLICATION_LABEL) {
                    targetFieldsWithPath.add(singleWrapper.dd.TB_Target_Object_Field__c);
                }
            }

            hed__Application__c application = getApplication('Target', applicationId);

            for (DataDefinitionWrapper singleWrapper : dataWrappers) {
                fillValues('Target', singleWrapper.dd, singleWrapper, application);
            }

            if (!objectsToUpdate.isEmpty()) {
                Database.SaveResult[] results = Database.update(
                    new List<SObject>(objectsToUpdate.values()),
                    false
                );
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()) {
                        for (Database.Error error : result.getErrors()) {
                            if (String.isNotBlank(error.getMessage())) {
                                if (error.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                                    String errorLine = error.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION, ').substringBefore(': [');
                                    errorMessage = errorLine;
                                } else {
                                    errorMessage = error.getMessage();
                                }
                                logs.add(TB_LogUtils.registerLog(error.getMessage(), TB_GenericComponentController.class));
                            } else {
                                errorMessage = System.Label.TB_Toast_Error_Message_Wrong;
                                logs.add(TB_LogUtils.registerLog(error.getMessage(), TB_GenericComponentController.class));
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            errorMessage = System.Label.TB_Toast_Error_Message_Wrong;
            logs.add(TB_LogUtils.registerLog(e));
        }

        insert logs;

        return new List<String>{errorMessage};
    }

    @AuraEnabled
    public static Boolean blockDuplicates (String type, String data, hed__Application__c app) {
        try {
            List<Contact> existingContacts = new List<Contact>();
            if (type == 'PERSONAL_INFORMATION.DT_PESEL__C.EXCEPTION' && app.hed__Applicant__r.DT_PESEL__c != data) {
                existingContacts = [
                    SELECT Id
                    FROM Contact
                    WHERE DT_PESEL__c = :data
                ];
            } else if (
                type == 'PERSONAL_INFORMATION.TB_X_Document_Search__C.EXCEPTION'
                    && app.hed__Applicant__r.TB_x_Document_Search__c != data
                ) {
                existingContacts = [
                    SELECT Id
                    FROM Contact
                    WHERE TB_x_Document_Search__c = :data
                ];
            }

            return !existingContacts.isEmpty();
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    public class DataDefinitionWrapper
    {
        @AuraEnabled public TB_Admissions_Data_Definition__c dd {get;set;}

        @AuraEnabled public hed__Application__c app {get;set;}
        @AuraEnabled public Boolean showTextInput {get;set;}
        @AuraEnabled public Boolean showLongTextInput {get;set;}
        @AuraEnabled public Boolean showCheckboxInput {get;set;}
        @AuraEnabled public Boolean showNumberInput {get;set;}
        @AuraEnabled public Boolean showDateInput {get;set;}
        @AuraEnabled public Boolean showPicklistInput {get;set;}

        @AuraEnabled public Boolean showCountryCallingCodesInput {get;set;}
        @AuraEnabled public Boolean showCitizenshipOtherThanPolandPicklistInput {get;set;}
        @AuraEnabled public Boolean showCitizenshipOtherThanPolandCheckboxInput {get;set;}
        @AuraEnabled public Boolean showCitizenshipOtherThanPolandTextInput {get;set;}
        @AuraEnabled public Boolean showIDPicklistInput {get;set;}
        @AuraEnabled public Boolean showIDTextInput {get;set;}
        @AuraEnabled public Boolean showPESELInput {get;set;}
        @AuraEnabled public Boolean showEmailTextInput {get;set;}
        @AuraEnabled public Boolean showAlternateEmailTextInput {get;set;}
        @AuraEnabled public Boolean showEmailPicklistInput {get;set;}
        @AuraEnabled public Boolean showMinorInput {get;set;}
        @AuraEnabled public Boolean showMinorHeader {get;set;}
        @AuraEnabled public Boolean showHeader {get;set;}
        @AuraEnabled public Boolean showNeedsAcceptanceLetterCheckboxInput {get;set;}
        @AuraEnabled public Boolean higherEducation {get;set;}
        @AuraEnabled public Boolean showMBATextInput {get;set;}
        @AuraEnabled public Boolean showMBALongTextInput {get;set;}
        @AuraEnabled public Boolean showMBACheckboxInput {get;set;}
        @AuraEnabled public Boolean showMBANumberInput {get;set;}
        @AuraEnabled public Boolean showMBADateInput {get;set;}
        @AuraEnabled public Boolean showMBAPicklistInput {get;set;}
        @AuraEnabled public Boolean showMBAHeader {get;set;}
        @AuraEnabled public Boolean showPhoneTextInput {get;set;}
        @AuraEnabled public Boolean showBirthdateDateInput {get;set;}

        @AuraEnabled public Boolean isWebExcluded {get;set;}
        @AuraEnabled public String clearName {get;set;}
        @AuraEnabled public String clearNamePl {get;set;}
        @AuraEnabled public String clearNameEn {get;set;}
        @AuraEnabled public Boolean isRequired {get;set;}
        @AuraEnabled public Boolean isReadOnly {get;set;}
        @AuraEnabled public Decimal charactersLeft {get;set;}
        @AuraEnabled public String textValue {get;set;}
        @AuraEnabled public String longTextValue {get;set;}
        @AuraEnabled public String picklistValue {get;set;}
        @AuraEnabled public Boolean checkboxValue {get;set;}
        @AuraEnabled public Boolean toUpdate {get;set;}
        @AuraEnabled public List<String> picklistChoicesValues { get; set; }
        @AuraEnabled public List<String> picklistChoicesLabels { get; set; }
        @AuraEnabled public List<String> countryCallingCodesValues { get; set; }
        @AuraEnabled public List<String> countryCallingCodesLabels { get; set; }
        @AuraEnabled public Boolean readOnly {get;set;}
        @AuraEnabled public String reasonWhyInvalid {get;set;}
        @AuraEnabled public String clearFieldLevelHelp {get;set;}
        @AuraEnabled public String clearFieldLevelHelpPl {get;set;}
        @AuraEnabled public String clearFieldLevelHelpEn {get;set;}

        public DataDefinitionWrapper(
            TB_Admissions_Data_Definition__c dataDefinition, hed__Application__c application
        )
        {
            this.dd = dataDefinition;
            this.app = application;
            this.showTextInput = dataDefinition.TB_Data_Type__c == 'Text' && dataDefinition.TB_Purpose__c != 'Data_Display' && String.isBlank(dataDefinition.TB_Data_Category__c);
            this.showLongTextInput = dataDefinition.TB_Data_Type__c == 'Text (Long)' && dataDefinition.TB_Purpose__c != 'Data_Display' && String.isBlank(dataDefinition.TB_Data_Category__c);
            this.showCheckboxInput = dataDefinition.TB_Data_Type__c == 'Checkbox' && dataDefinition.TB_Purpose__c != 'Data_Display' && String.isBlank(dataDefinition.TB_Data_Category__c);
            this.showNumberInput = dataDefinition.TB_Data_Type__c == 'Number' && dataDefinition.TB_Purpose__c != 'Data_Display' && String.isBlank(dataDefinition.TB_Data_Category__c);
            this.showDateInput = dataDefinition.TB_Data_Type__c == 'Date' && dataDefinition.TB_Purpose__c != 'Data_Display' && String.isBlank(dataDefinition.TB_Data_Category__c);
            this.showPicklistInput = dataDefinition.TB_Data_Type__c == 'Picklist' && dataDefinition.TB_Purpose__c != 'Data_Display' && String.isBlank(dataDefinition.TB_Data_Category__c);

            this.showCountryCallingCodesInput = dataDefinition.TB_Data_Category__c == 'Country Calling Code';
            this.showCitizenshipOtherThanPolandPicklistInput = dataDefinition.TB_Data_Type__c == 'Picklist' && dataDefinition.TB_Data_Category__c == 'Citizenship Other Than Polish';
            this.showCitizenshipOtherThanPolandCheckboxInput = dataDefinition.TB_Data_Type__c == 'Checkbox' && dataDefinition.TB_Data_Category__c == 'Citizenship Other Than Polish';
            this.showCitizenshipOtherThanPolandTextInput = dataDefinition.TB_Data_Type__c == 'Text' && dataDefinition.TB_Data_Category__c == 'Citizenship Other Than Polish';
            this.showIDPicklistInput = dataDefinition.TB_Data_Type__c == 'Picklist' && dataDefinition.TB_Data_Category__c == 'Personal Identification Document (ID)';
            this.showIDTextInput = dataDefinition.TB_Data_Type__c == 'Text' && dataDefinition.TB_Data_Category__c == 'Personal Identification Document (ID)';
            this.showPESELInput = dataDefinition.TB_Data_Type__c == 'Text' && dataDefinition.TB_Purpose__c != 'Data_Display' && dataDefinition.TB_Data_Category__c == 'PESEL';
            this.showEmailTextInput = dataDefinition.TB_Data_Type__c == 'Text' && dataDefinition.TB_Purpose__c != 'Data_Display' && dataDefinition.TB_Data_Category__c == 'Email';
            this.showAlternateEmailTextInput = false;
            this.showEmailPicklistInput = dataDefinition.TB_Data_Type__c == 'Picklist' && dataDefinition.TB_Purpose__c != 'Data_Display' && dataDefinition.TB_Data_Category__c == 'Email';
            this.showMinorInput = dataDefinition.TB_Data_Type__c == 'Text' && dataDefinition.TB_Purpose__c != 'Data_Display' && dataDefinition.TB_Data_Category__c == 'Minor';
            this.showMinorHeader = dataDefinition.TB_Purpose__c == 'Data_Display' && dataDefinition.TB_Data_Category__c == 'Minor';
            this.showHeader = dataDefinition.TB_Purpose__c == 'Data_Display' && String.isBlank(dataDefinition.TB_Data_Category__c);
            this.showNeedsAcceptanceLetterCheckboxInput = false;
            this.higherEducation = application.TB_Applying_To_Offered_Product__r.TB_Product_Group__c == 'Higher_Education';
            this.showMBATextInput = dataDefinition.TB_Data_Type__c == 'Text' && dataDefinition.TB_Data_Category__c == 'MBA';
            this.showMBALongTextInput = dataDefinition.TB_Data_Type__c == 'Text (Long)' && dataDefinition.TB_Data_Category__c == 'MBA';
            this.showMBACheckboxInput = dataDefinition.TB_Data_Type__c == 'Checkbox' && dataDefinition.TB_Data_Category__c == 'MBA';
            this.showMBANumberInput = dataDefinition.TB_Data_Type__c == 'Number' && dataDefinition.TB_Data_Category__c == 'MBA';
            this.showMBADateInput = dataDefinition.TB_Data_Type__c == 'Date' && dataDefinition.TB_Data_Category__c == 'MBA';
            this.showMBAPicklistInput = dataDefinition.TB_Data_Type__c == 'Picklist' && dataDefinition.TB_Data_Category__c == 'MBA';
            this.showMBAHeader = dataDefinition.TB_Purpose__c == 'Data_Display' && dataDefinition.TB_Data_Category__c == 'MBA';
            this.showPhoneTextInput = dataDefinition.TB_Data_Type__c == 'Text' && dataDefinition.TB_Purpose__c != 'Data_Display' && dataDefinition.TB_Data_Category__c == 'Phone';
            this.showBirthdateDateInput = dataDefinition.TB_Data_Type__c == 'Date' && dataDefinition.TB_Purpose__c != 'Data_Display' && dataDefinition.TB_Data_Category__c == 'Birthdate';

            this.isWebExcluded = !dataDefinition.TB_Visible_on_Portal__c;
            this.clearName = '';
            this.clearNamePl = '';
            this.clearNameEn = '';
            this.isRequired = dataDefinition.TB_Required__c;
            this.isReadOnly = false;
            this.charactersLeft = dataDefinition.TB_Characters__c;
            this.textValue = '';
            this.longTextValue = '';
            this.picklistValue = '';
            this.toUpdate = false;
            this.readOnly = dataDefinition.TB_Read_Only__c;
            this.reasonWhyInvalid = '';
            this.clearFieldLevelHelp = '';
            this.clearFieldLevelHelpPl = '';
            this.clearFieldLevelHelpEn = '';

            if (dataDefinition.TB_Data_Type__c == 'Picklist') {
                List<List<String>> valuesAndLabelsPrioritized = TB_StringUtils.getPolandOnTop(new List<List<String>>{
                    TB_StringUtils.getPicklistValuesOrLabelsSortedByLabel(labelToAPIName.get(dd.TB_Source_Object__c), dd.TB_Source_Object_Field__c, 'values'),
                    TB_StringUtils.getPicklistValuesOrLabelsSortedByLabel(labelToAPIName.get(dd.TB_Source_Object__c), dd.TB_Source_Object_Field__c, 'labels')
                });
                if (dataDefinition.TB_Data_Category__c != 'Country Calling Code') {
                    this.picklistChoicesValues = valuesAndLabelsPrioritized[0];
                    this.picklistChoicesLabels = valuesAndLabelsPrioritized[1];
                } else if (dataDefinition.TB_Data_Category__c == 'Country Calling Code') {
                    this.countryCallingCodesValues = valuesAndLabelsPrioritized[0];
                    this.countryCallingCodesLabels = valuesAndLabelsPrioritized[1];
                }
            }
        }

        public void setPicklistValue(TB_Admissions_Data_Definition__c dataDefinition)
        {
            if (dataDefinition.TB_Data_Type__c == 'Picklist') {
                if (dataDefinition.TB_Data_Category__c != 'Country Calling Code') {
                    for (Integer i = 0; i< this.picklistChoicesValues.size(); i++){
                        if (this.textValue == this.picklistChoicesValues[i]) {
                            this.picklistValue = this.picklistChoicesLabels[i];
                        }
                    }
                } else if (dataDefinition.TB_Data_Category__c == 'Country Calling Code') {
                    for (Integer i = 0; i< this.countryCallingCodesValues.size(); i++){
                        if (this.textValue == this.countryCallingCodesValues[i]) {
                            this.picklistValue = this.countryCallingCodesLabels[i];
                        }
                    }
                }
            }
        }
    }
}