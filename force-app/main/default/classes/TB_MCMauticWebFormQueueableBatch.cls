/**
 * Created by Adam Czeczuk on 04/10/2021.
 */

public without sharing class TB_MCMauticWebFormQueueableBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    private Set<Id> recordIds = new Set<Id>();
    private String token;
    private Map<String, String> recordIdToEventIdMap = new Map<String, String>();
    private static String ClientId = TB_Marketing_Cloud_API__c.getOrgDefaults().TB_Client_Id__c;
    private static String secret = TB_Marketing_Cloud_API__c.getOrgDefaults().TB_Secret__c;
    private static String grantType = TB_Marketing_Cloud_API__c.getOrgDefaults().TB_Grant_Type__c;
    private static String authEndPoint = TB_Marketing_Cloud_API__c.getOrgDefaults().TB_Auth_End_Point__c;
    private static String postEndPoint = TB_Marketing_Cloud_API__c.getOrgDefaults().TB_POST_End_Point__c;
    private static Map<String, String> accessTokenJSON;

    public TB_MCMauticWebFormQueueableBatch(List<TB_MCClient.WrapperClass> wcList) {

        for (TB_MCClient.WrapperClass wc : wcList) {
            recordIds.add(wc.recordId);
            recordIdToEventIdMap.put(wc.recordId, wc.eventKey);
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
                SELECT Id,
                        TB_Contact__c,
                        TB_Contact__r.FirstName,
                        TB_Contact__r.LastName,
                        TB_Nick_Name__c,
                        TB_Contact__r.HasOptedOutOfEmail,
                        TB_Contact__r.et4ae5__HasOptedOutOfMobile__c,
                        TB_Contact__r.TB_Email_Consent__c,
                        TB_Contact__r.TB_Phone_Consent__c,
                        TB_Contact__r.TB_SMS_Consent__c,
                        TB_Contact__r.TB_Anonymization_Status__c,
                        TB_Email__c,
                        TB_Phone__c,
                        TB_Communication_Language__c,
                        TB_Form_Id__c,
                        TB_Form_Name__c,
                        TB_Form_Category__c,
                        TB_Referer__c,
                        TB_Submission_Id__c,
                        TB_Submission_Date__c,
                        TB_Tracking_Id__c,
                        TB_Tags__c,
                        TB_Keywords__c,
                        TB_Product_Code__c
                FROM TB_Web_Form_Submission__c
                WHERE Id IN :recordIds
        ]);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        token = getMCAccessToken();
        List<String> JSONBodyList = constructJSONBodyList(recordIdToEventIdMap, new Map<Id, TB_Web_Form_Submission__c>((List<TB_Web_Form_Submission__c>) scope));

        for (String body : JSONBodyList) {
            singleCallToMCDE(body, token);
        }
    }

    public void finish(Database.BatchableContext BC) {

    }

    private static List<String> constructJSONBodyList(Map<String, String> wcList, Map<Id, TB_Web_Form_Submission__c> recordsToSendMap) {
        List<String> MCEntriesToSend = new List<String>();

        for (String wc : wcList.keySet()) {
        
            TB_Web_Form_Submission__c record = recordsToSendMap.get(wc);
            MCEntry mcentry = new MCEntry();
            mcentry.ContactKey = record.TB_Contact__c;
            mcentry.EventDefinitionKey = wcList.get(wc);

            Data data = new Data();
            
            data.WebFormSubmissionId = record.Id;
            data.WebFormId = record.TB_Form_Id__c;
            data.WebFormName = record.TB_Form_Name__c;
            data.WebFormCategory = record.TB_Form_Category__c;
            data.Referer = record.TB_Referer__c;
            data.SubmissionId = record.TB_Submission_Id__c;
            data.SubmissionDate = record.TB_Submission_Date__c;
            data.TrackingId = record.TB_Tracking_Id__c;
            data.ContactId = record.TB_Contact__c;
            data.NickName = record.TB_Nick_Name__c;
            data.CommunicationLanguage = record.TB_Communication_Language__c;
            data.FirstName = record.TB_Contact__r.FirstName;
            data.LastName = record.TB_Contact__r.LastName;
            data.Email = record.TB_Email__c;
            data.HasOptedOutOfEmail = record.TB_Contact__r.HasOptedOutOfEmail;
            data.MobilePhone = record.TB_Phone__c;
            data.HasOptedOutOfMobile = record.TB_Contact__r.et4ae5__HasOptedOutOfMobile__c;
            data.AnonymizationStatus = record.TB_Contact__r.TB_Anonymization_Status__c;
            data.ReplyToEmail = TB_Marketing_Cloud_Defaults__c.getOrgDefaults().TB_Reply_To_Email__c;
            data.SenderEmail = TB_Marketing_Cloud_Defaults__c.getOrgDefaults().TB_Sender_Email__c;
            data.SenderName = TB_Marketing_Cloud_Defaults__c.getOrgDefaults().TB_Sender_Name__c;
            data.Stage = TB_Marketing_Cloud_Defaults__c.getOrgDefaults().TB_Stage__c;
            data.Keywords = record.TB_Keywords__c;
            data.ProductCode = record.TB_Product_Code__c;
            data.Tags = record.TB_Tags__c;
            data.EmailConsent = record.TB_Contact__r.TB_Email_Consent__c;
            data.PhoneConsent = record.TB_Contact__r.TB_Phone_Consent__c;
            data.SMSConsent = record.TB_Contact__r.TB_SMS_Consent__c;
            data.CreatedDate = datetime.now();

            mcentry.Data = data;

            MCEntriesToSend.add(JSON.serialize(mcentry));
        }

        return MCEntriesToSend;
    }

    private static void singleCallToMCDE(String JSONBody, String token) {

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(postEndPoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setBody(JSONBody);
        System.debug('JSONBody : ' + JSONBody );
        HttpResponse response = http.send(request);
        System.debug('response : ' + response.getBody() );
    }

    private static String getMCAccessToken() {
        accessTokenJSON = new Map<String, String>();
        accessTokenJSON.put('client_id', ClientId);
        accessTokenJSON.put('client_secret', secret);
        accessTokenJSON.put('grant_type', grantType);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(authEndPoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(accessTokenJSON));
        HttpResponse response = http.send(request);
        Token responseToken = (Token) JSON.deserialize(response.getBody(), Token.class);
        return responseToken.access_token;
    }

    private class MCEntry {
        private String ContactKey;
        private String EventDefinitionKey;
        private Data Data;
    }

    private class Data {
        private String WebFormSubmissionId;
        private String WebFormId;
        private String WebFormName;
        private String WebFormCategory;
        private String Referer;
        private String SubmissionId;
        private Datetime SubmissionDate;        
        private String TrackingId;
        private String ContactId;
        private String NickName;
        private String FirstName;
        private String LastName;
        private String AnonymizationStatus;
        private String Email;
        private Boolean HasOptedOutOfEmail;
        private String MobilePhone;
        private Boolean HasOptedOutOfMobile;
        private String Stage;        
        private String CommunicationLanguage;
        private String Keywords;
        private String ProductCode;
        private String Tags;
        private String ReplyToEmail;
        private String SenderEmail;
        private String SenderName;
        private Boolean EmailConsent;        
        private Boolean PhoneConsent;
        private Boolean SMSConsent;
        private Datetime CreatedDate;
    }

    private class Token {
        private String access_token;
        private String token_type;
        private String expires_in;
        private String scope;
        private String soap_instance_url;
        private String rest_instance_url;
    }
}