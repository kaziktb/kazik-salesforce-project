/**
 * Created by Adam Czeczuk on 16/07/2022.
 */

public without sharing class TB_MCCommerceOrderItemQueueableBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    private Set<Id> recordIds = new Set<Id>();
    private String token;
    private Map<String, String> recordIdToEventIdMap = new Map<String, String>();
    private static String ClientId = TB_Marketing_Cloud_API__c.getOrgDefaults().TB_Client_Id__c;
    private static String secret = TB_Marketing_Cloud_API__c.getOrgDefaults().TB_Secret__c;
    private static String grantType = TB_Marketing_Cloud_API__c.getOrgDefaults().TB_Grant_Type__c;
    private static String authEndPoint = TB_Marketing_Cloud_API__c.getOrgDefaults().TB_Auth_End_Point__c;
    private static String postEndPoint = TB_Marketing_Cloud_API__c.getOrgDefaults().TB_POST_End_Point__c;
    private static Map<String, String> accessTokenJSON;

    public TB_MCCommerceOrderItemQueueableBatch(List<TB_MCClient.WrapperClass> wcList) {

        for (TB_MCClient.WrapperClass wc : wcList) {
            recordIds.add(wc.recordId);
            recordIdToEventIdMap.put(wc.recordId, wc.eventKey);
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
                SELECT Id,
                        TB_Commerce_Order__c,
                        TB_Commerce_Order__r.Name,
                        TB_Customer__c,
                        TB_Customer_Id__c,
                        TB_Participant_Salutation__c,
                        TB_Participant_First_Name__c,
                        TB_Participant_Last_Name__c,
                        TB_Participant_Email__c,
                        TB_Participant_Phone__c,
                        TB_Offered_Product__c,
                        TB_Offered_Product_Edition__c,
                        TB_Product_Name_PL__c,
                        TB_Product_Sub_Name_PL__c,
                        TB_Start_Date__c,
                        TB_End_Date__c,
                        TB_Price_Gross_Final__c,
                        TB_Price_Gross_Final_Currency__c,
                        TB_Promotion__c,
                        TB_Promoted__c,
                        TB_Item_Status__c,
                        TB_Item_Status_Date__c,
                        TB_Order_Status__c,
                        TB_Order_Last_Visited_Date__c,
                        TB_Order_Last_Edited_Date__c,
                        TB_Available_to_Rate__c,
                        TB_Product_Group__c,
                        TB_Product_Profile__c,
                        TB_Product_Location__c,
                        TB_Product_Location_Details__c,
                        TB_Online_Platform__c,
                        TB_Online_Location_URL__c,
                        TB_Reply_To_Email__c,
                        TB_Sender_Email__c,
                        TB_Sender_Name__c,
                        TB_Customer__r.TB_Email_Consent__c,
                        TB_Customer__r.TB_Phone_Consent__c,
                        TB_Customer__r.TB_SMS_Consent__c,
                        TB_Product_Code__c,
                        TB_Offered_Product_Edition__r.TB_Schedule_PL__c,
                        TB_Offered_Product_Edition__r.TB_Commerce_Full_URL_PL__c,
                        TB_Test__c,
                        TB_Order_Record_Version_Id__c
                FROM TB_Commerce_Order_Item__c
                WHERE Id IN :recordIds
        ]);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        token = getMCAccessToken();
        List<String> JSONBodyList = constructJSONBodyList(recordIdToEventIdMap, new Map<Id, TB_Commerce_Order_Item__c>((List<TB_Commerce_Order_Item__c>) scope));

        for (String body : JSONBodyList) {
            singleCallToMCDE(body, token);
        }
    }

    public void finish(Database.BatchableContext BC) {

    }

    private static List<String> constructJSONBodyList(Map<String, String> wcList, Map<Id, TB_Commerce_Order_Item__c> recordsToSendMap) {
        List<String> MCEntriesToSend = new List<String>();

        for (String wc : wcList.keySet()) {
        
            TB_Commerce_Order_Item__c record = recordsToSendMap.get(wc);
            MCEntry mcentry = new MCEntry();
            mcentry.ContactKey = record.TB_Customer__c;
            mcentry.EventDefinitionKey = wcList.get(wc);

            Data data = new Data();
            
            data.OrderItemId = record.Id;
            data.OrderId = record.TB_Commerce_Order__c;
            data.OrderNumber = record.TB_Commerce_Order__r.Name;
            data.ContactId = record.TB_Customer__c;
            data.CustomerId = record.TB_Customer_Id__c;
            data.Salutation = record.TB_Participant_Salutation__c;
            data.FirstName = record.TB_Participant_First_Name__c;
            data.LastName = record.TB_Participant_Last_Name__c;
            data.Email = record.TB_Participant_Email__c;
            data.Phone = record.TB_Participant_Phone__c;
            data.ProductId = record.TB_Offered_Product__c;
            data.EditionId = record.TB_Offered_Product_Edition__c;
            data.ProductName = record.TB_Product_Name_PL__c;
            data.ProductSubName = record.TB_Product_Sub_Name_PL__c;
            data.StartDate = record.TB_Start_Date__c;
            data.EndDate = record.TB_End_Date__c;
            data.Price = record.TB_Price_Gross_Final__c;
            data.CurrencyCode = record.TB_Price_Gross_Final_Currency__c;
            data.Promotion = record.TB_Promotion__c;
            data.Promoted = record.TB_Promoted__c;
            data.OrderItemStatus = record.TB_Item_Status__c;
            data.OrderItemStatusDate = record.TB_Item_Status_Date__c;
            data.OrderStatus = record.TB_Order_Status__c;
            data.OrderLastVisitedDate = record.TB_Order_Last_Visited_Date__c;
            data.OrderLastEditedDate = record.TB_Order_Last_Edited_Date__c;
            data.AvailableToRate = record.TB_Available_to_Rate__c;
            data.ProductGroup = record.TB_Product_Group__c;
            data.ProductProfile = record.TB_Product_Profile__c;
            data.ProductLocation = record.TB_Product_Location__c;
            data.ProductLocationDetails = record.TB_Product_Location_Details__c;
            data.OnlinePlatform = record.TB_Online_Platform__c;
            data.OnlineLocationUrl = record.TB_Online_Location_URL__c;
            data.ReplyToEmail = record.TB_Reply_To_Email__c;
            data.SenderEmail = record.TB_Sender_Email__c;
            data.SenderName = record.TB_Sender_Name__c;
            data.EmailConsent = record.TB_Customer__r.TB_Email_Consent__c;
            data.PhoneConsent = record.TB_Customer__r.TB_Phone_Consent__c;
            data.SMSConsent = record.TB_Customer__r.TB_SMS_Consent__c;
            data.ProductCode = record.TB_Product_Code__c;
            data.ProductSchedule = record.TB_Offered_Product_Edition__r.TB_Schedule_PL__c;
            data.ProductDetailsUrl = record.TB_Offered_Product_Edition__r.TB_Commerce_Full_URL_PL__c;
            data.Test = record.TB_Test__c;            
            data.OrderRecordVersionId = record.TB_Order_Record_Version_Id__c;
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
        private String OrderItemId;
        private String OrderId;
        private String OrderNumber;
        private String ContactId;
        private String CustomerId;
        private String Salutation;
        private String FirstName;
        private String LastName;    
        private String Email;
        private String Phone;    
        private String ProductId;
        private String EditionId;
        private String ProductName;
        private String ProductSubName;
        private Datetime StartDate;
        private Datetime EndDate;
        private Decimal Price;
        private String CurrencyCode;
        private Boolean Promotion;
        private Boolean Promoted;
        private String OrderItemStatus;        
        private Datetime OrderItemStatusDate;
        private String OrderStatus;
        private Datetime OrderLastVisitedDate;
        private Datetime OrderLastEditedDate;
        private Boolean AvailableToRate;
        private String ProductGroup;
        private String ProductProfile;
        private String ProductLocation;
        private String ProductLocationDetails;
        private String OnlinePlatform;
        private String OnlineLocationUrl;
        private String ReplyToEmail;
        private String SenderEmail;
        private String SenderName;
        private Boolean EmailConsent;
        private Boolean PhoneConsent;
        private Boolean SMSConsent;
        private Datetime CreatedDate;
        private String ProductCode;
        private String ProductDetailsUrl;
        private String ProductSchedule;
        private Boolean Test;
        private String OrderRecordVersionId;
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