/**
 * Created by adriangawryszewski on 2/15/22.
 */
@isTest
public with sharing class TB_VDOExportTest {


    @TestSetup
    static void dataFactory() {

        Id Applicant_RT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('TB_Applicant').getRecordTypeId();


        TB_Offered_Product__c offeredProduct = TB_TestDataFactory.createOfferedProduct(false);
        offeredProduct.TB_VDO_Id__c = '123';
        offeredProduct.TB_VDO_Study_Id__c = '123';
        insert offeredProduct;

        TB_Admissions_Dictionary__c discount = new TB_Admissions_Dictionary__c();
        discount.RecordTypeId = TB_Constants.ADMISSIONS_DICTIONARY_RT_DISCOUNT;
        discount.Name = 'Test discount';
        discount.TB_Discount_Type__c = 'Tuition_Amount';
        discount.TB_Discount_Calculation_Method__c = 'Each_Instalment';
        discount.TB_Discount_Direction__c = 'Reduction';
        discount.TB_Tuition_Fee_Discount_Amount__c = 123;
        insert discount;

        Contact applicant = TB_TestDataFactory.createContact(false);
        applicant.TB_IM_Id__c = '';
        applicant.DT_VDO_ID__c = '';
        applicant.MiddleName = 'John';
        applicant.Birthdate = Date.newInstance(1987, 12, 17);
        applicant.DT_Place_of_Birth__c = 'Warszawa';
        applicant.hed__Country_of_Origin__c = 'Poland';
        applicant.TB_Family_Name__c = 'Familijny';
        applicant.DT_PESEL__c = '88030312323';
        applicant.hed__AlternateEmail__c = 'test@test.com';
        applicant.hed__UniversityEmail__c = 'testStudent@test.com';
        applicant.hed__WorkEmail__c = 'testEmployee@test.com';
        applicant.TB_ICE_Contact_Person__c = 'My Mom ICE';
        applicant.TB_ICE_Contact_Phone__c = '+48787787787';
        applicant.DT_Document_Issue_Date__c = Date.newInstance(2021, 12, 17);
        applicant.DT_Document_Issuing_Country__c = 'PL';
        applicant.DT_Document_Series_and_Number__c = 'AWE123123';
        applicant.DT_Document_Issuing_Authority__c = 'Prezydent Miasta';
        applicant.DT_Document_Validity_Date__c = Date.newInstance(2041, 12, 17);
        applicant.DT_Type_of_Identity_Document__c = 'POLSKI_DOWOD_OSOBISTY';
        applicant.MailingCity = 'Warszawa';
        applicant.MailingState = 'mazowieckie';
        applicant.MailingCountry = 'Poland';
        applicant.MailingPostalCode = '00-012';
        applicant.MailingStreet = 'Test 123';
        applicant.OtherCity = 'Krakow';
        applicant.OtherState = 'mazowieckie';
        applicant.OtherCountry = 'Poland';
        applicant.OtherPostalCode = '50-001';
        applicant.OtherStreet = 'krakowska 12';
        applicant.TB_Pole_s_Card__c = true;
        applicant.hed__Preferred_Email__c = 'Alternate';
        applicant.TB_Tuition_Bank_Account_EUR__c = '12345678901234567890123456';
        applicant.TB_Tuition_Bank_Account_PLN__c = '12345678901234567890123456';
        applicant.RecordTypeId = Applicant_RT;
        insert applicant;


        hed__Application__c acc = new hed__Application__c();
        acc.TB_Active__c = true;
        acc.TB_Test__c = false;
        acc.hed__Applicant__c = applicant.Id;
        acc.TB_Applying_To_Offered_Product__c = offeredProduct.Id;
        acc.TB_Applicant_Citizenship__c = 'Poland';
        acc.TB_Tuition_Instalment__c = '2';
        acc.TB_Tuition_Fee_Currency__c = 'PLN';
        acc.hed__Application_Status__c = TB_Constants.TB_APPLICATION_STATUS_CONDITIONALLY_ACCEPTED;
        acc.TB_Conditional_Admission_2nd_Guest__c = true;
        acc.TB_Discount_Type__c = discount.Id;
        insert acc;

        TB_Experience_History__c highSchool = new TB_Experience_History__c();
        highSchool.TB_Application__c = acc.Id;
        highSchool.RecordTypeId = TB_Constants.TB_EDUCATION_EXP_HS_EXAM_METRIC_RT_ID;
        highSchool.TB_Educational_Institution__c = 'XXX Liceum';
        highSchool.TB_Issue_Date__c = Date.newInstance(2019, 12, 17);
        highSchool.TB_Document_Issue_City__c = 'Warsaw';
        highSchool.TB_Document_Number__c = 'M/0001112/06';
        highSchool.TB_Educational_Institution_City__c = 'Warsaw';
        highSchool.TB_Educational_Institution_Country__c = 'PL';
        insert highSchool;

        TB_Experience_History__c univeristy = new TB_Experience_History__c();
        univeristy.TB_Application__c = acc.Id;
        univeristy.RecordTypeId = TB_Constants.TB_EDUCATION_EXP_HIGHER_EDUCATION_RT_ID;
        univeristy.TB_Educational_Institution__c = 'University';
        univeristy.TB_Educational_Institution_City__c = 'Warsaw';
        univeristy.TB_Course__c = 'Uni Course';
        univeristy.TB_Document_Number__c = 'mn/1233123/2323';
        univeristy.TB_Issue_Date__c = Date.newInstance(2019, 12, 17);
        univeristy.TB_Defense_of_Thesis_Date_Declared__c = Date.newInstance(2018, 12, 17);
        univeristy.TB_Academic_Title__c = 'mgr';
        univeristy.TB_Educational_Institution_Country__c = 'PL';
        insert univeristy;

        TB_Experience_History__c univeristy2 = new TB_Experience_History__c();
        univeristy2.TB_Application__c = acc.Id;
        univeristy2.RecordTypeId = TB_Constants.TB_EDUCATION_EXP_POSTGRAD_EDUCATION_RT_ID;
        univeristy2.TB_Educational_Institution__c = 'University 2';
        univeristy2.TB_Educational_Institution_City__c = 'Warsaw';
        univeristy2.TB_Course__c = 'Uni Course 2';
        univeristy2.TB_Document_Number__c = 'mn/1233123/mm';
        univeristy2.TB_Issue_Date__c = Date.newInstance(2009, 12, 17);
        univeristy2.TB_Defense_of_Thesis_Date_Declared__c = Date.newInstance(2008, 12, 17);
        univeristy2.TB_Academic_Title__c = 'postgrad';
        univeristy2.TB_Educational_Institution_Country__c = 'PL';
        insert univeristy2;

        TB_Experience_History__c programDiff = new TB_Experience_History__c();
        programDiff.TB_Application__c = acc.Id;
        programDiff.RecordTypeId = TB_Constants.TB_PD_DIFFERENCES_EXP_RT_ID;
        programDiff.TB_PD_Subject__c = 'Subject 1';
        programDiff.TB_PD_Module_Name_PL__c = 'Subject 1';
        programDiff.TB_Hours__c = 123;
        programDiff.TB_ECTS__c = 123;
        programDiff.TB_Score__c = 123;
        programDiff.TB_Educational_Institution__c = 'Uni';
        insert programDiff;

        TB_Experience_History__c programDiff2 = new TB_Experience_History__c();
        programDiff2.TB_Application__c = acc.Id;
        programDiff2.RecordTypeId = TB_Constants.TB_PD_DIFFERENCES_EXP_RT_ID;
        programDiff2.TB_PD_Subject__c = 'Subject 2';
        programDiff2.TB_PD_Module_Name_PL__c = 'Subject 2';
        programDiff2.TB_Hours__c = 123;
        programDiff2.TB_ECTS__c = 123;
        programDiff2.TB_Score__c = 123;
        programDiff2.TB_Educational_Institution__c = 'Uni';
        insert programDiff2;

        TB_Consent__c consent = new TB_Consent__c();
        consent.TB_Application__c = acc.Id;
        consent.TB_Contact__c = applicant.Id;
        consent.TB_Source_Type__c = 'WWW';
        consent.TB_Status__c = 'Signed';
        consent.Name = 'Consent 1';
        consent.TB_Effective_From__c = Date.newInstance(2021, 12, 17);
        consent.TB_Consent_Text_PL__c = 'Consent PL';
        consent.TB_Consent_Text_EN__c = 'Consent EN';
        insert consent;

        TB_Consent__c consent2 = new TB_Consent__c();
        consent2.TB_Application__c = acc.Id;
        consent2.TB_Contact__c = applicant.Id;
        consent2.TB_Source_Type__c = 'WWW';
        consent2.TB_Status__c = 'Seen';
        consent2.Name = 'Consent 2';
        consent2.TB_Effective_From__c = Date.newInstance(2021, 12, 17);
        consent2.TB_Consent_Text_PL__c = 'Consent PL 2';
        consent2.TB_Consent_Text_EN__c = 'Consent EN 2';
        insert consent2;

    }
    @IsTest
    static void testExportSuccess() {
        Test.setMock(HttpCalloutMock.class, new TB_VDOExportMock('success'));
        hed__Application__c appToExport = [SELECT Id, hed__Application_Status__c FROM hed__Application__c LIMIT 1];
        appToExport.hed__Application_Status__c = 'Conditionally_Accepted';
        appToExport.TB_Application_Sub_Status__c = 'Ready_To_Export';
        System.assertEquals(0, [SELECT count() from TB_Communication_Event__c]);

        Test.startTest();
            update appToExport;
        Test.stopTest();
        List<TB_Communication_Event__c> logs = [SELECT Id, TB_Response_Code__c FROM TB_Communication_Event__c];
        System.assertEquals(1, logs.size());




    }

    @IsTest
    static void testExportFailed() {
        Test.setMock(HttpCalloutMock.class, new TB_VDOExportMock('fail'));
        hed__Application__c appToExport = [SELECT Id, hed__Application_Status__c FROM hed__Application__c LIMIT 1];
        appToExport.hed__Application_Status__c = 'Conditionally_Accepted';
        appToExport.TB_Application_Sub_Status__c = 'Ready_To_Export';
        System.assertEquals(0, [SELECT count() from TB_Communication_Event__c]);

        Test.startTest();
        update appToExport;
        Test.stopTest();
        List<TB_Communication_Event__c> logs = [SELECT Id, TB_Response_Code__c FROM TB_Communication_Event__c];
        System.assertEquals(1, logs.size());

    }
}