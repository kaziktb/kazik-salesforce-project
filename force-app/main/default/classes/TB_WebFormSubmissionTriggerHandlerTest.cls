/**
 * Created by kacperjachowicz on 16/09/2021.
 */
@IsTest
public with sharing class TB_WebFormSubmissionTriggerHandlerTest {

    private static final String TEST_REQUEST_BODY = '{"mautic_form[name]":"testaliasy","mautic_form[url]":"https://test.mauticswps.pl/s/forms/preview/8","email_agree":"yes","mautic_contact[id]":"10","mautic_contact[email]":"adam.czeczuk@gmail.com","mautic_contact[last_active]":"2021-11-09 10:33:37","mautic_contact[points]":"0","tags":"spsyche, warszawa","mautic_contact[phone]":"+48510024739","mautic_form[id]":"8","phone":"+48510024739","mautic_contact[firstname]":"Al Bundy","nickname":"Al Bundy"}';
    private static final String TEST_JSON_BODY = '{"mautic.form_on_submit":[{"submission":{"id":27,"ipAddress":{"ipAddress":"185.246.208.50","id":3,"ipDetails":{"city":"","region":"","zipcode":"","country":"","latitude":"","longitude":"","isp":"","organization":"","timezone":"","extra":""}},"form":{"id":9,"name":"humantech","alias":"humantech","category":null},"lead":{"id":6,"points":0,"color":null,"fields":{"core":{"title":{"id":1,"group":"core","label":"Title","alias":"title","type":"lookup","properties":{"list":["Mr","Mrs","Miss"]},"value":null,"normalizedValue":null},"firstname":{"id":2,"group":"core","label":"First Name","alias":"firstname","type":"text","properties":[],"value":"Adam","normalizedValue":"Adam"},"lastname":{"id":3,"group":"core","label":"Last Name","alias":"lastname","type":"text","properties":[],"value":null,"normalizedValue":null},"company":{"id":4,"group":"core","label":"Primary company","alias":"company","type":"text","properties":[],"value":null,"normalizedValue":null},"position":{"id":5,"group":"core","label":"Position","alias":"position","type":"text","properties":[],"value":null,"normalizedValue":null},"email":{"id":6,"group":"core","label":"Email","alias":"email","type":"email","properties":[],"value":"adam.czeczuk@thinkbeyond.cloud","normalizedValue":"adam.czeczuk@thinkbeyond.cloud"},"mobile":{"id":7,"group":"core","label":"Mobile","alias":"mobile","type":"tel","properties":[],"value":null,"normalizedValue":null},"phone":{"id":8,"group":"core","label":"Phone","alias":"phone","type":"tel","properties":[],"value":"555666777","normalizedValue":"555666777"},"points":{"id":9,"group":"core","label":"Points","alias":"points","type":"number","properties":[],"value":null,"normalizedValue":null},"fax":{"id":10,"group":"core","label":"Fax","alias":"fax","type":"tel","properties":[],"value":null,"normalizedValue":null},"address1":{"id":11,"group":"core","label":"Address Line 1","alias":"address1","type":"text","properties":[],"value":null,"normalizedValue":null},"address2":{"id":12,"group":"core","label":"Address Line 2","alias":"address2","type":"text","properties":[],"value":null,"normalizedValue":null},"city":{"id":13,"group":"core","label":"City","alias":"city","type":"text","properties":[],"value":null,"normalizedValue":null},"state":{"id":14,"group":"core","label":"State","alias":"state","type":"region","properties":[],"value":null,"normalizedValue":null},"zipcode":{"id":15,"group":"core","label":"Zip Code","alias":"zipcode","type":"text","properties":[],"value":null,"normalizedValue":null},"country":{"id":16,"group":"core","label":"Country","alias":"country","type":"country","properties":[],"value":null,"normalizedValue":null},"preferred_locale":{"id":17,"group":"core","label":"Preferred Locale","alias":"preferred_locale","type":"locale","properties":[],"value":null,"normalizedValue":null},"timezone":{"id":18,"group":"core","label":"Preferred Timezone","alias":"timezone","type":"timezone","properties":[],"value":null,"normalizedValue":null},"last_active":{"id":19,"group":"core","label":"Date Last Active","alias":"last_active","type":"datetime","properties":[],"value":null,"normalizedValue":null},"attribution_date":{"id":20,"group":"core","label":"Attribution Date","alias":"attribution_date","type":"datetime","properties":[],"value":null,"normalizedValue":null},"attribution":{"id":21,"group":"core","label":"Attribution","alias":"attribution","type":"number","properties":{"roundmode":4,"scale":2},"value":null,"normalizedValue":null},"website":{"id":22,"group":"core","label":"Website","alias":"website","type":"url","properties":[],"value":null,"normalizedValue":null}},"social":{"facebook":{"id":23,"group":"social","label":"Facebook","alias":"facebook","type":"text","properties":[],"value":null,"normalizedValue":null},"foursquare":{"id":24,"group":"social","label":"Foursquare","alias":"foursquare","type":"text","properties":[],"value":null,"normalizedValue":null},"instagram":{"id":25,"group":"social","label":"Instagram","alias":"instagram","type":"text","properties":[],"value":null,"normalizedValue":null},"linkedin":{"id":26,"group":"social","label":"LinkedIn","alias":"linkedin","type":"text","properties":[],"value":null,"normalizedValue":null},"skype":{"id":27,"group":"social","label":"Skype","alias":"skype","type":"text","properties":[],"value":null,"normalizedValue":null},"twitter":{"id":28,"group":"social","label":"Twitter","alias":"twitter","type":"text","properties":[],"value":null,"normalizedValue":null}},"personal":[],"professional":[]}},"trackingId":null,"dateSubmitted":"2021-09-14T22:50:05+00:00","referer":"https:\\/\\/test.mauticswps.pl\\/s\\/forms\\/preview\\/6","page":null,"results":{"tags":"psychologia, zarz\\u0105dzanie","imie_i_nazwisko":"Adam","adres_email":"adam.czeczuk@thinkbeyond.cloud","nr_telefonu":"555666777","preferowany_jezyk_komunik":"polski","all_marketing_agree":"","email_marketing_agree":"yes","sms_marketing_agree":"Yes","phone_marketing_agree":""}},"timestamp":"2021-09-14T22:50:07+00:00"}]}';

    @IsTest
    static void fillFieldsPositiveTest(){
        TB_Web_Form_Submission__c webFormSubmission = new TB_Web_Form_Submission__c();
        webFormSubmission.TB_JSON_Body__c = TEST_JSON_BODY;
        System.assert(webFormSubmission.TB_Status__c == null);

        Test.startTest();
        insert webFormSubmission;
        Test.stopTest();

        TB_Web_Form_Submission__c webFormSubmissionAfterInsert = [SELECT TB_Status__c,TB_Submission_Id__c FROM TB_Web_Form_Submission__c];
        System.assertEquals('Processed', webFormSubmissionAfterInsert.TB_Status__c);
        System.assertEquals('27', webFormSubmissionAfterInsert.TB_Submission_Id__c);
    }

    @IsTest
    static void fillFieldsNegativeTest(){
        TB_Web_Form_Submission__c webFormSubmission = new TB_Web_Form_Submission__c();
        webFormSubmission.TB_JSON_Body__c = 'fakeResponse';
        System.assert(webFormSubmission.TB_Status__c == null);

        Test.startTest();
        insert webFormSubmission;
        Test.stopTest();

        TB_Web_Form_Submission__c webFormSubmissionAfterInsert = [SELECT TB_Status__c, TB_Submission_Id__c FROM TB_Web_Form_Submission__c];
        System.assertEquals('Error', webFormSubmissionAfterInsert.TB_Status__c);
    }

    @IsTest
    static void fillFieldsFromRequestBodyPositiveTest() {
        TB_Web_Form_Submission__c webFormSubmission = new TB_Web_Form_Submission__c();
        webFormSubmission.TB_Request_Body__c = TEST_REQUEST_BODY;

        Test.startTest();
        insert webFormSubmission;
        Test.stopTest();

        TB_Web_Form_Submission__c webFormSubmissionAfterInsert = [SELECT TB_Form_Name__c, TB_Referer__c, TB_Form_Id__c, TB_Status__c FROM TB_Web_Form_Submission__c];
        List<TB_Web_Form_Result__c> webFormResults = [SELECT TB_Web_Form_Submission__c, TB_JSON_Attribute__c, TB_JSON_Value__c FROM TB_Web_Form_Result__c];
        System.assertEquals('testaliasy', webFormSubmissionAfterInsert.TB_Form_Name__c);
        System.assertEquals('https://test.mauticswps.pl/s/forms/preview/8', webFormSubmissionAfterInsert.TB_Referer__c);
        System.assertEquals('8', webFormSubmissionAfterInsert.TB_Form_Id__c);
        System.assertEquals('Processed', webFormSubmissionAfterInsert.TB_Status__c);
        System.assertEquals(webFormSubmissionAfterInsert.Id, webFormResults[0].TB_Web_Form_Submission__c);
        System.assertEquals(4, webFormResults.size());
    }

    @IsTest
    static void fillFieldsFromRequestBodyNegativeTest() {
        TB_Web_Form_Submission__c webFormSubmission = new TB_Web_Form_Submission__c();
        webFormSubmission.TB_Request_Body__c = 'fakeResponse';

        Test.startTest();
        insert webFormSubmission;
        Test.stopTest();

        TB_Web_Form_Submission__c webFormSubmissionAfterInsert = [SELECT TB_Form_Name__c, TB_Referer__c, TB_Form_Id__c, TB_Status__c FROM TB_Web_Form_Submission__c];
        List<TB_Web_Form_Result__c> webFormResults = [SELECT TB_Web_Form_Submission__c FROM TB_Web_Form_Result__c];
        System.assertEquals('Error', webFormSubmissionAfterInsert.TB_Status__c);
        System.assertEquals(0, webFormResults.size());
    }

    @IsTest
    static void fillFieldsFromJsonAndRequestBodyPositiveTest() {
        List<TB_Web_Form_Submission__c> webFormSubmissions = new List<TB_Web_Form_Submission__c>();
        TB_Web_Form_Submission__c webFormSubmissionJson = new TB_Web_Form_Submission__c();
        webFormSubmissionJson.TB_JSON_Body__c = TEST_JSON_BODY;
        TB_Web_Form_Submission__c webFormSubmissionRequest = new TB_Web_Form_Submission__c();
        webFormSubmissionRequest.TB_Request_Body__c = TEST_REQUEST_BODY;
        webFormSubmissions.add(webFormSubmissionJson);
        webFormSubmissions.add(webFormSubmissionRequest);

        Test.startTest();
        insert webFormSubmissions;
        Test.stopTest();

        List<TB_Web_Form_Submission__c> webFormSubmissionsAfterInsert = [SELECT TB_Form_Name__c, TB_Referer__c, TB_Form_Id__c, TB_Status__c, TB_Submission_Id__c, TB_JSON_Body__c, (SELECT TB_Web_Form_Submission__c FROM TB_Web_Form_Results__r) FROM TB_Web_Form_Submission__c];
        for (TB_Web_Form_Submission__c submission : webFormSubmissionsAfterInsert) {
            if (submission.TB_JSON_Body__c == null) {
                System.assertEquals('testaliasy', submission.TB_Form_Name__c);
                System.assertEquals('https://test.mauticswps.pl/s/forms/preview/8', submission.TB_Referer__c);
                System.assertEquals('8', submission.TB_Form_Id__c);
                System.assertEquals('Processed', submission.TB_Status__c);
                System.assertEquals(4, submission.TB_Web_Form_Results__r.size());
            } else {
                System.assertEquals('Processed', submission.TB_Status__c);
                System.assertEquals('27', submission.TB_Submission_Id__c);
            }
        }
    }

    @IsTest
    static void fillFieldsPositiveBulkRequestTest(){
        List<TB_Web_Form_Submission__c> submissions = new List<TB_Web_Form_Submission__c>();
        TB_Web_Form_Submission__c webFormSubmission1 = new TB_Web_Form_Submission__c();
        TB_Web_Form_Submission__c webFormSubmission2 = new TB_Web_Form_Submission__c();
        webFormSubmission1.TB_Request_Body__c = TEST_REQUEST_BODY;
        webFormSubmission2.TB_Request_Body__c = TEST_REQUEST_BODY;
        submissions.add(webFormSubmission1);
        submissions.add(webFormSubmission2);

        Test.startTest();
        insert submissions;
        Test.stopTest();

        List<TB_Web_Form_Submission__c> webFormSubmissionsAfterInsert = [SELECT TB_Form_Name__c, TB_Referer__c, TB_Form_Id__c, TB_Status__c, (SELECT Id FROM TB_Web_Form_Results__r) FROM TB_Web_Form_Submission__c];
        for (TB_Web_Form_Submission__c submission : webFormSubmissionsAfterInsert) {
            System.assertEquals('testaliasy', submission.TB_Form_Name__c);
            System.assertEquals('https://test.mauticswps.pl/s/forms/preview/8', submission.TB_Referer__c);
            System.assertEquals('8', submission.TB_Form_Id__c);
            System.assertEquals('Processed', submission.TB_Status__c);
            System.assertEquals(4, submission.TB_Web_Form_Results__r.size());
        }
    }
}