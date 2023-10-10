@IsTest
public with sharing class TB_GenericComponentControllerTest {
    public static String adultBirthDate = String.valueOf(System.today().addYears(-20)).substringBefore(' ');
    public static String minorBirthDate = String.valueOf(System.today()).substringBefore(' ');
    public static String peselType = 'PERSONAL_INFORMATION.DT_PESEL__C.EXCEPTION';
    public static String idType = 'PERSONAL_INFORMATION.TB_X_Document_Search__C.EXCEPTION';

    @TestSetup
    static void testSetup() {
        TB_Admissions_Process__c admissionsStep = new TB_Admissions_Process__c(
            RecordTypeId = TB_SObjectUtils.getRecordTypeIdByDevName('TB_Admissions_Process__c', 'TB_Admissions_Step'),
            Name = 'Test',
            TB_Display_Name_PL__c = 'Test',
            TB_Display_Name_EN__c = 'Test',
            TB_Active__c = true
        );
        insert admissionsStep;
        TB_JSON_Wrapper__c stepJsonWrapper = new TB_JSON_Wrapper__c(
            TB_Order__c = 0,
            TB_Wrapper_Value__c = '',
            TB_Object_API_Name__c = 'TB_Admissions_Process__c',
            TB_Object_Id__c = admissionsStep.Id
        );
        insert stepJsonWrapper;

        TB_Admissions_Data_Definition__c salutationDataDefinition = TB_DataFactory.createDataDefinition(true, 'Contact','Contact','Salutation','Salutation','Picklist');
        TB_Admissions_Data_Definition__c checkboxDataDefinition = TB_DataFactory.createDataDefinition(true, 'Application','Application','TB_Needs_Acceptance_Letter__c','TB_Needs_Acceptance_Letter__c','Checkbox');
        TB_Admissions_Data_Definition__c preferredEmailDataDefinition = TB_DataFactory.createDataDefinition(true, 'Contact','Contact','hed__Preferred_Email__c','hed__Preferred_Email__c','Picklist');
        TB_Admissions_Data_Definition__c longTextDataDefinition = TB_DataFactory.createDataDefinition(true, 'Contact','Contact','DT_Contact_Person__c','DT_Contact_Person__c','Text (Long)');
        TB_Admissions_Data_Definition__c documentTypeDataDefinition = TB_DataFactory.createDataDefinition(true, 'Contact','Contact','DT_Type_of_Identity_Document__c','DT_Type_of_Identity_Document__c','Picklist');
        TB_DataFactory.createStepData(true,salutationDataDefinition.Id,admissionsStep.Id);
        TB_DataFactory.createStepData(true,checkboxDataDefinition.Id,admissionsStep.Id);
        TB_DataFactory.createStepData(true,preferredEmailDataDefinition.Id,admissionsStep.Id);
        TB_DataFactory.createStepData(true,longTextDataDefinition.Id,admissionsStep.Id);
        TB_DataFactory.createStepData(true,documentTypeDataDefinition.Id,admissionsStep.Id);


        hed__Application__c application = TB_DataFactory.createApplicationWithRelatedObjects(false);
        Contact applicant = new Contact(
            LastName = 'Test',
            DT_PESEL__c = '123',
            hed__UniversityEmail__c = 'test@swps.pl',
            DT_Document_Issuing_Country__c = 'PL',
            DT_Document_Series_and_Number__c = '123'
        );
        insert applicant;
        application.hed__Applicant__c = applicant.Id;
        insert application;
        Contact duplicateApplicant = new Contact(
            LastName = 'DuplicateTest',
            DT_PESEL__c = '1234',
            hed__UniversityEmail__c = 'nowy@swps.pl',
            DT_Document_Issuing_Country__c = 'PL',
            DT_Document_Series_and_Number__c = '1234',
            Salutation = 'Mr',
            TB_Mautic__c = false
        );
        insert duplicateApplicant;
    }

    @IsTest
    static void getStepsDataPositive() {

        hed__Application__c application = [
            SELECT Id
            FROM hed__Application__c
            WHERE hed__Applicant__r.LastName = 'Test'
        ];
        TB_Admissions_Process__c step = [
            SELECT Id
            FROM TB_Admissions_Process__c
            WHERE Name = 'Test'
        ];

        System.assertNotEquals(null, TB_GenericComponentController.getStepsData(step.Id, application.Id));
        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void updateDataDefinitionsPositive() {
        String json = '[{"app":{"Id":"a0Q5r000002Ixs1EAC","TB_Applying_To_Offered_Product__c":"a1i5r000000DzIiAAK","hed__Applicant__c":"0035r00000FNztIAAT","TB_MBA__c":false,"TB_Needs_Acceptance_Letter__c":false,"TB_Applying_To_Offered_Product__r":{"TB_Product_Group__c":"Higher_Education","Id":"a1i5r000000DzIiAAK"},"hed__Applicant__r":{"Salutation":"Mr.","FirstName":"Steve","LastName":"Jobs","Email":"jowita.kozlak@thinkbeyond.cloud","hed__UniversityEmail__c":"jowita.kozlak@thinkbeyond.cloud","hed__AlternateEmail__c":"jowita.kozlak@thinkbeyond.cloud","hed__Preferred_Email__c":"Alternate","Birthdate":"1981-12-03","DT_Place_of_Birth__c":"Nibylandia","hed__Citizenship__c":"Afghanistan","DT_Country_of_Birth__c":"PL","TB_Pole_s_Card__c":false,"TB_Has_PESEL__c":true,"DT_PESEL__c":"81120397993","TB_Mother_s_Name__c":"a","TB_Mother_s_Surname__c":"b","TB_Father_s_Name__c":"b","TB_Father_s_Surname__c":"a","Id":"0035r00000FNztIAAT"}},"checkboxValue":true,"clearName":"I have a Pole\'s Card","clearNameEn":"I have a Pole\'s Card","clearNamePl":"Karta Polaka","dd":{"LastModifiedDate":"2021-10-12T12:27:44.000Z","TB_Visible_on_Portal__c":true,"TB_Target_Object__c":"Contact","TB_Label_PL__c":"Karta Polaka","TB_Field_Width_Formatted__c":"width:%;","Name":"Karta Polaka","CreatedById":"0055r000001TE7UAAW","OwnerId":"0055r000001TE7UAAW","TB_Label_EN__c":"I have a Pole\'s Card","TB_File__c":false,"TB_Required__c":false,"TB_File_Required__c":false,"IsDeleted":false,"TB_Purpose__c":"Data_Collection","TB_Field_Width__c":100,"TB_Data_Type__c":"Checkbox","TB_Active__c":true,"SystemModstamp":"2021-10-12T12:27:44.000Z","TB_Data_Category__c":"Citizenship Other Than Polish","CreatedDate":"2021-10-12T12:22:23.000Z","TB_Source_Object__c":"Contact","attributes":{"type":"TB_Admissions_Data_Definition__c","url":"/services/data/v53.0/sobjects/TB_Admissions_Data_Definition__c/a265r00000092zcAAA"},"Id":"a265r00000092zcAAA","LastModifiedById":"0055r000001TE7UAAW","TB_Target_Object_Field__c":"TB_Pole_s_Card__c","TB_Source_Object_Field__c":"TB_Pole_s_Card__c"},"higherEducation":true,"isReadOnly":false,"isRequired":false,"isWebExcluded":false,"longTextValue":"","picklistValue":"","readOnly":false,"showCheckboxInput":false,"showCitizenshipOtherThanPolandCheckboxInput":true,"showCitizenshipOtherThanPolandPicklistInput":false,"showCitizenshipOtherThanPolandTextInput":false,"showCountryCallingCodesInput":false,"showDateInput":false,"showEmailPicklistInput":false,"showEmailTextInput":false,"showHeader":false,"showIDPicklistInput":false,"showIDTextInput":false,"showLongTextInput":false,"showMBACheckboxInput":false,"showMBADateInput":false,"showMBAHeader":false,"showMBALongTextInput":false,"showMBANumberInput":false,"showMBAPicklistInput":false,"showMBATextInput":false,"showMinorHeader":false,"showMinorInput":false,"showNeedsAcceptanceLetterCheckboxInput":false,"showNumberInput":false,"showPESELInput":false,"showPicklistInput":false,"showTextInput":false,"textValue":"true","toUpdate":true},{"app":{"Id":"a0Q5r000002Ixs1EAC","TB_Applying_To_Offered_Product__c":"a1i5r000000DzIiAAK","hed__Applicant__c":"0035r00000FNztIAAT","TB_MBA__c":false,"TB_Needs_Acceptance_Letter__c":false,"TB_Applying_To_Offered_Product__r":{"TB_Product_Group__c":"Higher_Education","Id":"a1i5r000000DzIiAAK"},"hed__Applicant__r":{"Salutation":"Mr.","FirstName":"Steve","LastName":"Jobs","Email":"jowita.kozlak@thinkbeyond.cloud","hed__UniversityEmail__c":"jowita.kozlak@thinkbeyond.cloud","hed__AlternateEmail__c":"jowita.kozlak@thinkbeyond.cloud","hed__Preferred_Email__c":"Alternate","Birthdate":"1981-12-03","DT_Place_of_Birth__c":"Nibylandia","hed__Citizenship__c":"Afghanistan","DT_Country_of_Birth__c":"PL","TB_Pole_s_Card__c":false,"TB_Has_PESEL__c":true,"DT_PESEL__c":"81120397993","TB_Mother_s_Name__c":"a","TB_Mother_s_Surname__c":"b","TB_Father_s_Name__c":"b","TB_Father_s_Surname__c":"a","Id":"0035r00000FNztIAAT"}},"checkboxValue":true,"clearName":"I need acceptance letter","clearNameEn":"I need acceptance letter","clearNamePl":"Potrzebuję zaświadczenia o przyjęciu na studia","dd":{"LastModifiedDate":"2021-10-25T19:36:39.000Z","TB_Visible_on_Portal__c":true,"TB_Target_Object__c":"Application","TB_Label_PL__c":"Potrzebuję zaświadczenia o przyjęciu na studia","TB_Field_Width_Formatted__c":"width:%;","Name":"Potrzebuję zaświadczenia o przyjęciu na studia","CreatedById":"0057R00000BIqYkQAL","OwnerId":"0057R00000BIqYkQAL","TB_Label_EN__c":"I need acceptance letter","TB_File__c":false,"TB_Required__c":false,"TB_File_Required__c":false,"IsDeleted":false,"TB_Purpose__c":"Data_Collection","TB_Field_Width__c":100,"TB_Data_Type__c":"Checkbox","TB_Active__c":true,"SystemModstamp":"2021-10-25T19:36:39.000Z","TB_Data_Category__c":"Citizenship Other Than Polish","CreatedDate":"2021-10-25T19:36:39.000Z","TB_Source_Object__c":"Application","attributes":{"type":"TB_Admissions_Data_Definition__c","url":"/services/data/v53.0/sobjects/TB_Admissions_Data_Definition__c/a265r00000094A6AAI"},"Id":"a265r00000094A6AAI","LastModifiedById":"0057R00000BIqYkQAL","TB_Target_Object_Field__c":"TB_Needs_Acceptance_Letter__c","TB_Source_Object_Field__c":"TB_Needs_Acceptance_Letter__c"},"higherEducation":true,"isReadOnly":false,"isRequired":false,"isWebExcluded":false,"longTextValue":"","picklistValue":"","readOnly":false,"showCheckboxInput":false,"showCitizenshipOtherThanPolandCheckboxInput":false,"showCitizenshipOtherThanPolandPicklistInput":false,"showCitizenshipOtherThanPolandTextInput":false,"showCountryCallingCodesInput":false,"showDateInput":false,"showEmailPicklistInput":false,"showEmailTextInput":false,"showHeader":false,"showIDPicklistInput":false,"showIDTextInput":false,"showLongTextInput":false,"showMBACheckboxInput":false,"showMBADateInput":false,"showMBAHeader":false,"showMBALongTextInput":false,"showMBANumberInput":false,"showMBAPicklistInput":false,"showMBATextInput":false,"showMinorHeader":false,"showMinorInput":false,"showNeedsAcceptanceLetterCheckboxInput":true,"showNumberInput":false,"showPESELInput":false,"showPicklistInput":false,"showTextInput":false,"textValue":"true","toUpdate":true},{"app":{"Id":"a0Q5r000002Ixs1EAC","TB_Applying_To_Offered_Product__c":"a1i5r000000DzIiAAK","hed__Applicant__c":"0035r00000FNztIAAT","TB_MBA__c":false,"TB_Needs_Acceptance_Letter__c":false,"TB_Applying_To_Offered_Product__r":{"TB_Product_Group__c":"Higher_Education","Id":"a1i5r000000DzIiAAK"},"hed__Applicant__r":{"Salutation":"Mr.","FirstName":"Steve","LastName":"Jobs","Email":"jowita.kozlak@thinkbeyond.cloud","hed__UniversityEmail__c":"jowita.kozlak@thinkbeyond.cloud","hed__AlternateEmail__c":"jowita.kozlak@thinkbeyond.cloud","hed__Preferred_Email__c":"Alternate","Birthdate":"1981-12-03","DT_Place_of_Birth__c":"Nibylandia","hed__Citizenship__c":"Afghanistan","DT_Country_of_Birth__c":"PL","TB_Pole_s_Card__c":false,"TB_Has_PESEL__c":true,"DT_PESEL__c":"81120397993","TB_Mother_s_Name__c":"a","TB_Mother_s_Surname__c":"b","TB_Father_s_Name__c":"b","TB_Father_s_Surname__c":"a","Id":"0035r00000FNztIAAT"}},"clearName":"ID Document Type","clearNameEn":"ID Document Type","clearNamePl":"Typ dokumentu tożsamości","dd":{"LastModifiedDate":"2021-10-26T14:33:42.000Z","TB_Visible_on_Portal__c":true,"TB_Target_Object__c":"Contact","TB_Label_PL__c":"Typ dokumentu tożsamości","TB_Field_Width_Formatted__c":"width:%;","Name":"Dokument tożsamości - typ","CreatedById":"0055r000001RlcEAAS","OwnerId":"0055r000001RlcEAAS","TB_Label_EN__c":"ID Document Type","TB_File__c":false,"TB_Required__c":true,"TB_File_Required__c":false,"IsDeleted":false,"TB_Purpose__c":"Data_Collection","TB_Read_Only__c":false,"TB_Field_Width__c":100,"TB_Data_Type__c":"Picklist","TB_Active__c":true,"SystemModstamp":"2021-10-26T14:33:42.000Z","TB_Data_Category__c":"Personal Identification Document (ID)","CreatedDate":"2021-08-06T16:47:06.000Z","TB_Source_Object__c":"Contact","attributes":{"type":"TB_Admissions_Data_Definition__c","url":"/services/data/v53.0/sobjects/TB_Admissions_Data_Definition__c/a265r0000008r7hAAA"},"Id":"a265r0000008r7hAAA","LastModifiedById":"0055r000001TE7UAAW","TB_Target_Object_Field__c":"DT_Type_of_Identity_Document__c","TB_Source_Object_Field__c":"DT_Type_of_Identity_Document__c"},"higherEducation":true,"isReadOnly":false,"isRequired":true,"isWebExcluded":false,"longTextValue":"","picklistChoicesLabels":["Karta pobytu czasowego w Polsce","Karta pobytu rezydenta długoterminowego UE","Karta pobytu stałego w Polsce","Karta Polaka (nie jest dokumentem tożsamości)","Paszport","Polski dokument podróży dla cudzoziemca","Polski dokument tożsamości dla cudzoziemca","Polski dowód osobisty","Tymczasowy polski dokument podróży dla cudzoziemca","Wiza (nie jest dokumentem tożsamości)","Zagraniczny dowód osobisty"],"picklistChoicesValues":["KARTA_POBYTU_CZASOWEGO_PL","KARTA_POBYTU_REZYDENTA_EU","KARTA_POBYTU_STALEGO_PL","KARTA_POLAKA","PASZPORT","POLSKI_DOKUMENT_PODROZY","POLSKI_DOKUMENT_TOZSAMOSCI","POLSKI_DOWOD_OSOBISTY","TYMCZASOWY_POLSKI_DOKUMENT_PODROZY","WIZA","ZAGRANICZNY_DOWOD_OSOBISTY"],"picklistValue":"Karta pobytu czasowego w Polsce","readOnly":false,"showCheckboxInput":false,"showCitizenshipOtherThanPolandCheckboxInput":false,"showCitizenshipOtherThanPolandPicklistInput":false,"showCitizenshipOtherThanPolandTextInput":false,"showCountryCallingCodesInput":false,"showDateInput":false,"showEmailPicklistInput":false,"showEmailTextInput":false,"showHeader":false,"showIDPicklistInput":true,"showIDTextInput":false,"showLongTextInput":false,"showMBACheckboxInput":false,"showMBADateInput":false,"showMBAHeader":false,"showMBALongTextInput":false,"showMBANumberInput":false,"showMBAPicklistInput":false,"showMBATextInput":false,"showMinorHeader":false,"showMinorInput":false,"showNeedsAcceptanceLetterCheckboxInput":false,"showNumberInput":false,"showPESELInput":false,"showPicklistInput":false,"showTextInput":false,"toUpdate":true,"textValue":"KARTA_POBYTU_CZASOWEGO_PL"},{"app":{"Id":"a0Q5r000002Ixs1EAC","TB_Applying_To_Offered_Product__c":"a1i5r000000DzIiAAK","hed__Applicant__c":"0035r00000FNztIAAT","TB_MBA__c":false,"TB_Needs_Acceptance_Letter__c":false,"TB_Applying_To_Offered_Product__r":{"TB_Product_Group__c":"Higher_Education","Id":"a1i5r000000DzIiAAK"},"hed__Applicant__r":{"Salutation":"Mr.","FirstName":"Steve","LastName":"Jobs","Email":"jowita.kozlak@thinkbeyond.cloud","hed__UniversityEmail__c":"jowita.kozlak@thinkbeyond.cloud","hed__AlternateEmail__c":"jowita.kozlak@thinkbeyond.cloud","hed__Preferred_Email__c":"Alternate","Birthdate":"1981-12-03","DT_Place_of_Birth__c":"Nibylandia","hed__Citizenship__c":"Afghanistan","DT_Country_of_Birth__c":"PL","TB_Pole_s_Card__c":false,"TB_Has_PESEL__c":true,"DT_PESEL__c":"81120397993","TB_Mother_s_Name__c":"a","TB_Mother_s_Surname__c":"b","TB_Father_s_Name__c":"b","TB_Father_s_Surname__c":"a","Id":"0035r00000FNztIAAT"}},"charactersLeft":255,"clearName":"ID Document Number","clearNameEn":"ID Document Number","clearNamePl":"Numer dokumentu tożsamości","dd":{"LastModifiedDate":"2021-10-26T14:33:56.000Z","TB_Visible_on_Portal__c":true,"TB_Target_Object__c":"Contact","TB_Label_PL__c":"Numer dokumentu tożsamości","TB_Field_Width_Formatted__c":"width:%;","Name":"Dokument tożsamości - numer","TB_Characters__c":255,"CreatedById":"0055r000001RlcEAAS","OwnerId":"0055r000001RlcEAAS","TB_Label_EN__c":"ID Document Number","TB_File__c":false,"TB_Required__c":true,"TB_File_Required__c":false,"IsDeleted":false,"TB_Purpose__c":"Data_Collection","TB_Read_Only__c":false,"TB_Field_Width__c":100,"TB_Data_Type__c":"Text","TB_Active__c":true,"SystemModstamp":"2021-10-26T14:33:56.000Z","TB_Data_Category__c":"Personal Identification Document (ID)","CreatedDate":"2021-08-06T16:48:19.000Z","TB_Source_Object__c":"Contact","attributes":{"type":"TB_Admissions_Data_Definition__c","url":"/services/data/v53.0/sobjects/TB_Admissions_Data_Definition__c/a265r0000008r7mAAA"},"Id":"a265r0000008r7mAAA","LastModifiedById":"0055r000001TE7UAAW","TB_Target_Object_Field__c":"DT_Document_Series_and_Number__c","TB_Source_Object_Field__c":"DT_Document_Series_and_Number__c"},"higherEducation":true,"isReadOnly":false,"isRequired":true,"isWebExcluded":false,"longTextValue":"","picklistValue":"","readOnly":false,"showCheckboxInput":false,"showCitizenshipOtherThanPolandCheckboxInput":false,"showCitizenshipOtherThanPolandPicklistInput":false,"showCitizenshipOtherThanPolandTextInput":false,"showCountryCallingCodesInput":false,"showDateInput":false,"showEmailPicklistInput":false,"showEmailTextInput":false,"showHeader":false,"showIDPicklistInput":false,"showIDTextInput":true,"showLongTextInput":false,"showMBACheckboxInput":false,"showMBADateInput":false,"showMBAHeader":false,"showMBALongTextInput":false,"showMBANumberInput":false,"showMBAPicklistInput":false,"showMBATextInput":false,"showMinorHeader":false,"showMinorInput":false,"showNeedsAcceptanceLetterCheckboxInput":false,"showNumberInput":false,"showPESELInput":false,"showPicklistInput":false,"showTextInput":false,"toUpdate":true,"textValue":"1"},{"app":{"Id":"a0Q5r000002Ixs1EAC","TB_Applying_To_Offered_Product__c":"a1i5r000000DzIiAAK","hed__Applicant__c":"0035r00000FNztIAAT","TB_MBA__c":false,"TB_Needs_Acceptance_Letter__c":false,"TB_Applying_To_Offered_Product__r":{"TB_Product_Group__c":"Higher_Education","Id":"a1i5r000000DzIiAAK"},"hed__Applicant__r":{"Salutation":"Mr.","FirstName":"Steve","LastName":"Jobs","Email":"jowita.kozlak@thinkbeyond.cloud","hed__UniversityEmail__c":"jowita.kozlak@thinkbeyond.cloud","hed__AlternateEmail__c":"jowita.kozlak@thinkbeyond.cloud","hed__Preferred_Email__c":"Alternate","Birthdate":"1981-12-03","DT_Place_of_Birth__c":"Nibylandia","hed__Citizenship__c":"Afghanistan","DT_Country_of_Birth__c":"PL","TB_Pole_s_Card__c":false,"TB_Has_PESEL__c":true,"DT_PESEL__c":"81120397993","TB_Mother_s_Name__c":"a","TB_Mother_s_Surname__c":"b","TB_Father_s_Name__c":"b","TB_Father_s_Surname__c":"a","Id":"0035r00000FNztIAAT"}},"clearName":"ID Document Issued In Country","clearNameEn":"ID Document Issued In Country","clearNamePl":"Dokument tożsamości - kraj wydania","dd":{"LastModifiedDate":"2021-11-17T11:20:55.000Z","TB_Visible_on_Portal__c":true,"TB_Target_Object__c":"Contact","TB_Label_PL__c":"Dokument tożsamości - kraj wydania","TB_Field_Width_Formatted__c":"width:%;","Name":"Dokument tożsamości - kraj wydania","CreatedById":"0055r000001RlcEAAS","OwnerId":"0055r000001RlcEAAS","TB_Label_EN__c":"ID Document Issued In Country","TB_File__c":false,"TB_Required__c":true,"TB_File_Required__c":false,"IsDeleted":false,"TB_Purpose__c":"Data_Collection","TB_Read_Only__c":false,"TB_Field_Width__c":100,"TB_Data_Type__c":"Picklist","TB_Active__c":true,"SystemModstamp":"2021-11-17T11:20:55.000Z","TB_Data_Category__c":"Personal Identification Document (ID)","CreatedDate":"2021-08-06T16:49:56.000Z","TB_Source_Object__c":"Contact","attributes":{"type":"TB_Admissions_Data_Definition__c","url":"/services/data/v53.0/sobjects/TB_Admissions_Data_Definition__c/a265r0000008r7rAAA"},"Id":"a265r0000008r7rAAA","LastModifiedById":"0057R00000BIqYkQAL","TB_Target_Object_Field__c":"DT_Document_Issuing_Country__c","TB_Source_Object_Field__c":"DT_Document_Issuing_Country__c"},"higherEducation":true,"isReadOnly":false,"isRequired":true,"isWebExcluded":false,"longTextValue":"","picklistChoicesLabels":["Poland","Afghanistan","Aland Islands","Albania","Algeria","Andorra","Angola","Anguilla","Antarctica","Antigua and Barbuda","Argentina","Armenia","Aruba","Australia","Austria","Azerbaijan","Bahamas","Bahrain","Bangladesh","Barbados","Belarus","Belgium","Belize","Benin","Bermuda","Bhutan","Bolivia, Plurinational State of","Bonaire, Sint Eustatius and Saba","Bosnia and Herzegovina","Botswana","Bouvet Island","Brazil","British Indian Ocean Territory","Brunei Darussalam","Bulgaria","Burkina Faso","Burundi","Cambodia","Cameroon","Canada","Cape Verde","Cayman Islands","Central African Republic","Chad","Chile","China","Christmas Island","Cocos (Keeling) Islands","Colombia","Comoros","Congo","Congo, the Democratic Republic of the","Cook Islands","Costa Rica","Cote d’Ivoire","Croatia","Cuba","Curaçao","Cyprus","Czech Republic","Denmark","Djibouti","Dominica","Dominican Republic","Ecuador","Egypt","El Salvador","Equatorial Guinea","Eritrea","Estonia","Ethiopia","Falkland Islands (Malvinas)","Faroe Islands","Fiji","Finland","France","French Guiana","French Polynesia","French Southern Territories","Gabon","Gambia","Georgia","Germany","Ghana","Gibraltar","Greece","Greenland","Grenada","Guadeloupe","Guatemala","Guernsey","Guinea","Guinea-Bissau","Guyana","Haiti","Heard Island and McDonald Islands","Holy See (Vatican City State)","Honduras","Hungary","Iceland","India","Indonesia","Iran, Islamic Republic of","Iraq","Ireland","Isle of Man","Israel","Italy","Jamaica","Japan","Jersey","Jordan","Kazakhstan","Kenya","Kiribati","Korea, Democratic People’s Republic of","Korea, Republic of","Kuwait","Kyrgyzstan","Lao People’s Democratic Republic","Latvia","Lebanon","Lesotho","Liberia","Libya","Liechtenstein","Lithuania","Luxembourg","Macao","Macedonia, the former Yugoslav Republic of","Madagascar","Malawi","Malaysia","Maldives","Mali","Malta","Martinique","Mauritania","Mauritius","Mayotte","Mexico","Moldova, Republic of","Monaco","Mongolia","Montenegro","Montserrat","Morocco","Mozambique","Myanmar","Namibia","Nauru","Nepal","Netherlands","New Caledonia","New Zealand","Nicaragua","Niger","Nigeria","Niue","Norfolk Island","Norway","Oman","Pakistan","Palestine","Panama","Papua New Guinea","Paraguay","Peru","Philippines","Pitcairn","Portugal","Qatar","Reunion","Romania","Russian Federation","Rwanda","Saint Barthélemy","Saint Helena, Ascension and Tristan da Cunha","Saint Kitts and Nevis","Saint Lucia","Saint Martin (French part)","Saint Pierre and Miquelon","Saint Vincent and the Grenadines","Samoa","San Marino","Sao Tome and Principe","Saudi Arabia","Senegal","Serbia","Seychelles","Sierra Leone","Singapore","Sint Maarten (Dutch part)","Slovakia","Slovenia","Solomon Islands","Somalia","South Africa","South Georgia and the South Sandwich Islands","South Sudan","Spain","Sri Lanka","Sudan","Suriname","Svalbard and Jan Mayen","Swaziland","Sweden","Switzerland","Syrian Arab Republic","Taiwan","Tajikistan","Tanzania, United Republic of","Thailand","Timor-Leste","Togo","Tokelau","Tonga","Trinidad and Tobago","Tunisia","Turkey","Turkmenistan","Turks and Caicos Islands","Tuvalu","Uganda","Ukraine","United Arab Emirates","United Kingdom","United States","Uruguay","Uzbekistan","Vanuatu","Venezuela, Bolivarian Republic of","Vietnam","Virgin Islands, British","Wallis and Futuna","Western Sahara","Yemen","Zambia","Zimbabwe"],"picklistChoicesValues":["PL","AF","AX","AL","DZ","AD","AO","AI","AQ","AG","AR","AM","AW","AU","AT","AZ","BS","BH","BD","BB","BY","BE","BZ","BJ","BM","BT","BO","BQ","BA","BW","BV","BR","IO","BN","BG","BF","BI","KH","CM","CA","CV","KY","CF","TD","CL","CN","CX","CC","CO","KM","CG","CD","CK","CR","CI","HR","CU","CW","CY","CZ","DK","DJ","DM","DO","EC","EG","SV","GQ","ER","EE","ET","FK","FO","FJ","FI","FR","GF","PF","TF","GA","GM","GE","DE","GH","GI","GR","GL","GD","GP","GT","GG","GN","GW","GY","HT","HM","VA","HN","HU","IS","IN","ID","IR","IQ","IE","IM","IL","IT","JM","JP","JE","JO","KZ","KE","KI","KP","KR","KW","KG","LA","LV","LB","LS","LR","LY","LI","LT","LU","MO","MK","MG","MW","MY","MV","ML","MT","MQ","MR","MU","YT","MX","MD","MC","MN","ME","MS","MA","MZ","MM","NA","NR","NP","NL","NC","NZ","NI","NE","NG","NU","NF","NO","OM","PK","PS","PA","PG","PY","PE","PH","PN","PT","QA","RE","RO","RU","RW","BL","SH","KN","LC","MF","PM","VC","WS","SM","ST","SA","SN","RS","SC","SL","SG","SX","SK","SI","SB","SO","ZA","GS","SS","ES","LK","SD","SR","SJ","SZ","SE","CH","SY","TW","TJ","TZ","TH","TL","TG","TK","TO","TT","TN","TR","TM","TC","TV","UG","UA","AE","GB","US","UY","UZ","VU","VE","VN","VG","WF","EH","YE","ZM","ZW"],"picklistValue":"Poland","readOnly":false,"showCheckboxInput":false,"showCitizenshipOtherThanPolandCheckboxInput":false,"showCitizenshipOtherThanPolandPicklistInput":false,"showCitizenshipOtherThanPolandTextInput":false,"showCountryCallingCodesInput":false,"showDateInput":false,"showEmailPicklistInput":false,"showEmailTextInput":false,"showHeader":false,"showIDPicklistInput":true,"showIDTextInput":false,"showLongTextInput":false,"showMBACheckboxInput":false,"showMBADateInput":false,"showMBAHeader":false,"showMBALongTextInput":false,"showMBANumberInput":false,"showMBAPicklistInput":false,"showMBATextInput":false,"showMinorHeader":false,"showMinorInput":false,"showNeedsAcceptanceLetterCheckboxInput":false,"showNumberInput":false,"showPESELInput":false,"showPicklistInput":false,"showTextInput":false,"toUpdate":true,"textValue":"PL"}]';
        hed__Application__c application = [
            SELECT Id
            FROM hed__Application__c
            WHERE hed__Applicant__r.LastName = 'Test'
        ];

        System.assertEquals('', TB_GenericComponentController.updateDataDefinitions(json, application.Id)[0]);
        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
    }

    @IsTest
    static void isAnAdultPositive() {
        System.assertEquals(true, TB_GenericComponentController.isAnAdult(adultBirthDate));
    }

    @IsTest
    static void isAnAdultNegative() {
        System.assertEquals(false, TB_GenericComponentController.isAnAdult(minorBirthDate));
    }

    @IsTest
    static void isTooYoungPositive() {
        System.assertEquals(true, TB_GenericComponentController.isTooYoung(minorBirthDate));
    }

    @IsTest
    static void isTooYoungNegative() {
        System.assertEquals(false, TB_GenericComponentController.isTooYoung(adultBirthDate));
    }

    @IsTest
    static void blockDuplicatesPeselPositive() {
        hed__Application__c application = [
            SELECT Id, hed__Applicant__r.DT_PESEL__c, hed__Applicant__r.TB_x_Document_Search__c
            FROM hed__Application__c
            WHERE hed__Applicant__r.LastName = 'Test'
        ];
        System.assertEquals(true, TB_GenericComponentController.blockDuplicates(peselType,'1234',application));
    }

    @IsTest
    static void blockDuplicatesIdPositive() {
        hed__Application__c application = [
            SELECT Id, hed__Applicant__r.DT_PESEL__c, hed__Applicant__r.TB_x_Document_Search__c
            FROM hed__Application__c
            WHERE hed__Applicant__r.LastName = 'Test'
        ];
        System.assertEquals(true, TB_GenericComponentController.blockDuplicates(idType,'PL1234',application));
    }

    @IsTest
    static void blockDuplicatesNegative() {
        hed__Application__c application = [
            SELECT Id, hed__Applicant__r.DT_PESEL__c, hed__Applicant__r.TB_x_Document_Search__c
            FROM hed__Application__c
            WHERE hed__Applicant__r.LastName = 'Test'
        ];
        System.assertEquals(false, TB_GenericComponentController.blockDuplicates(peselType,'123',application));
    }
}