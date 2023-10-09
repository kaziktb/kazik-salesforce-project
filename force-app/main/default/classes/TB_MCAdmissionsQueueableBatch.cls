/**
 * Created by Adam Czeczuk on 15/09/2021.
 */

public with sharing class TB_MCAdmissionsQueueableBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    private Set<Id> appIds = new Set<Id>();
    private String token;
    private Map<String, String> appIdToEventIdMap = new Map<String, String>();
    private static String ClientId = TB_Marketing_Cloud_API__c.getOrgDefaults().TB_Client_Id__c;
    private static String secret = TB_Marketing_Cloud_API__c.getOrgDefaults().TB_Secret__c;
    private static String grantType = TB_Marketing_Cloud_API__c.getOrgDefaults().TB_Grant_Type__c;
    @TestVisible
    private static String authEndPoint = TB_Marketing_Cloud_API__c.getOrgDefaults().TB_Auth_End_Point__c;
    @TestVisible
    private static String postEndPoint = TB_Marketing_Cloud_API__c.getOrgDefaults().TB_POST_End_Point__c;
    private static Map<String, String> accessTokenJSON;

    public TB_MCAdmissionsQueueableBatch(List<TB_MCClient.WrapperClass> wcList) {

        for (TB_MCClient.WrapperClass wc : wcList) {
            appIds.add(wc.recordId);
            appIdToEventIdMap.put(wc.recordId, wc.eventKey);
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
                SELECT Id,
                        TB_Test__c,
                        Name,
                        hed__Applicant__c,
                        hed__Applicant__r.FirstName,
                        hed__Applicant__r.LastName,
                        TB_Applicant_Citizenship__c,
                        TB_Applicant_Email__c,
                        hed__Applicant__r.HasOptedOutOfEmail,
                        TB_Applicant_Phone__c,
                        hed__Applicant__r.TB_Anonymization_Status__c,
                        TB_Applying_To_Offered_Product__c,
                        TB_Product_Group__c,
                        TB_Applying_To_Offered_Product__r.TB_Academic_Year__r.Name,
                        TB_Applying_To_Offered_Product__r.TB_Starting_Semester__r.Name,
                        TB_Campus__c,
                        TB_Campus__r.TB_Account_Name_PL__c,
                        TB_Campus__r.TB_Account_Name_EN__c,
                        TB_Faculty__c,
                        TB_Faculty__r.TB_Account_Name_PL__c,
                        TB_Faculty__r.TB_Account_Name_EN__c,
                        TB_Communication_Language__c,
                        TB_Applying_To_Offered_Product__r.TB_Product_Id__c,
                        TB_Applying_To_Offered_Product__r.TB_Product_Code__c,
                        TB_Applying_To_Offered_Product__r.TB_Product_Name_PL__c,
                        TB_Applying_To_Offered_Product__r.TB_Product_Name_EN__c,
                        TB_Applying_To_Offered_Product__r.TB_Product_URL__c,
                        TB_Agency__r.TB_Email__c,
                        TB_Agreement_Type__c,
                        hed__Application_Status__c,
                        TB_Application_Sub_Status__c,
                        TB_Agreement_Status__c,
                        TB_Documents_Status__c,
                        TB_Education_Status__c,
                        TB_Evaluation_Status__c,
                        TB_Experience_Status__c,
                        TB_Admissions_Fee_Status__c,
                        TB_Tuition_Fee_Status__c,
                        TB_Ranking_List_Status__c,
                        TB_Ranking_List_Mode__c,
                        TB_Scholarship_Status__c,
                        TB_PD_Status__c,
                        TB_PEU_Status__c,
                        TB_PD_Opt_In__c,
                        TB_Last_Status_Change_Date_Time__c,
                        TB_Last_Sub_Status_Change_Date_Time__c,
                        TB_Level_of_Study__c,
                        TB_Mode_of_Study__c,
                        TB_HS_Exam_Year__c,
                        TB_Foreigner__c,
                        TB_Ranking_List_Results_Published__c,
                        TB_Qualification_Status__c,
                        TB_Qualification_Type__c,
                        TB_Qualification_Location_Type__c,
                        TB_Qualification_Term__r.TB_Start_DST__c,
                        TB_x_Recipient_Email__c,
                        TB_x_Reply_To_Email__c,
                        TB_x_Sender_Email__c,
                        TB_x_Sender_Name__c,
                        TB_x_Email_Footer__c,
                        TB_Decision_Details__c,
                        TB_Send_Comments__c,
                        TB_MBA__c,
                        TB_SPPB__c,
                        TB_Documents_Not_Complete__c,
                        TB_Qualification_Dates_Available__c,
                        TB_Campaign_Transfer_Type__c

                FROM hed__Application__c
                WHERE Id IN :appIds
        ]);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        token = !Test.isRunningTest() ? getMCAccessToken() : 'Test123';
        List<String> JSONBodyList = constructJSONBodyList(appIdToEventIdMap, new Map<Id, hed__Application__c>((List<hed__Application__c>) scope));

        for (String body : JSONBodyList) {
            singleCallToMCDE(body, token);
        }
    }

    public void finish(Database.BatchableContext BC) {

    }

    private static List<String> constructJSONBodyList(Map<String, String> wcList, Map<Id, hed__Application__c> appsToSendMap) {
        List<String> MCEntriesToSend = new List<String>();

        for (String wc : wcList.keySet()) {

            hed__Application__c app = appsToSendMap.get(wc);
            MCEntry mcentry = new MCEntry();
            mcentry.ContactKey = app.hed__Applicant__c;
            mcentry.EventDefinitionKey = wcList.get(wc);

            Data data = new Data();

            data.ApplicationId = app.Id;
            data.Test = app.TB_Test__c;
            data.ApplicationNumber = app.Name;
            data.ApplicantId = app.hed__Applicant__c;
            data.FirstName = app.hed__Applicant__r.FirstName;
            data.LastName = app.hed__Applicant__r.LastName;
            data.Citizenship = app.TB_Applicant_Citizenship__c;
            data.Email = app.TB_Applicant_Email__c;
            data.HasOptedOutOfEmail = app.hed__Applicant__r.HasOptedOutOfEmail;
            data.MobilePhone = app.TB_Applicant_Phone__c;
            data.AnonymizationStatus = app.hed__Applicant__r.TB_Anonymization_Status__c;
            data.AcademicYear = app.TB_Applying_To_Offered_Product__r.TB_Academic_Year__r.Name;
            data.StartingSemester = app.TB_Applying_To_Offered_Product__r.TB_Starting_Semester__r.Name;
            data.AgencyEmail = app.TB_Agency__r.TB_Email__c;
            data.AgreementType = app.TB_Agreement_Type__c;
            data.AgreementStatus = app.TB_Agreement_Status__c;
            data.ApplicationStatus = app.hed__Application_Status__c;
            data.ApplicationSubStatus = app.TB_Application_Sub_Status__c;
            data.AdmissionsFeeStatus = app.TB_Admissions_Fee_Status__c;
            data.TuitionFeeStatus = app.TB_Tuition_Fee_Status__c;
            data.DocumentsStatus = app.TB_Documents_Status__c;
            data.EducationStatus = app.TB_Education_Status__c;
            data.EvaluationStatus = app.TB_Evaluation_Status__c;
            data.ExperienceStatus = app.TB_Experience_Status__c;
            data.ScholarshipStatus = app.TB_Scholarship_Status__c;
            data.PDStatus = app.TB_PD_Status__c;
            data.PEUStatus = app.TB_PEU_Status__c;
            data.RankingListStatus = app.TB_Ranking_List_Status__c;
            data.RankingListResultsPublished = app.TB_Ranking_List_Results_Published__c;
            data.CampusId = app.TB_Campus__c;
            data.CampusNamePL = app.TB_Campus__r.TB_Account_Name_PL__c;
            data.CampusNameEN = app.TB_Campus__r.TB_Account_Name_EN__c;
            data.FacultyId = app.TB_Faculty__c;
            data.FacultyNamePL = app.TB_Faculty__r.TB_Account_Name_PL__c;
            data.FacultyNameEN = app.TB_Faculty__r.TB_Account_Name_EN__c;
            data.CommunicationLanguage = app.TB_Communication_Language__c;
            data.LastStatusChange = app.TB_Last_Status_Change_Date_Time__c;
            data.LastSubStatusChange = app.TB_Last_Sub_Status_Change_Date_Time__c;
            data.ProductId = app.TB_Applying_To_Offered_Product__c;
            data.ProductCode = app.TB_Applying_To_Offered_Product__r.TB_Product_Id__c;
            data.ProductFullCode = app.TB_Applying_To_Offered_Product__r.TB_Product_Code__c;
            data.ProductGroup = app.TB_Product_Group__c;
            data.ProductNamePL = app.TB_Applying_To_Offered_Product__r.TB_Product_Name_PL__c;
            data.ProductNameEN = app.TB_Applying_To_Offered_Product__r.TB_Product_Name_EN__c;
            data.ProductURL = app.TB_Applying_To_Offered_Product__r.TB_Product_URL__c;
            data.ProductLevel = app.TB_Level_of_Study__c;
            data.ProductMode = app.TB_Mode_of_Study__c;
            data.RecipientEmail = app.TB_x_Recipient_Email__c;
            data.ReplyToEmail = app.TB_x_Reply_To_Email__c;
            data.SenderEmail = app.TB_x_Sender_Email__c;
            data.SenderName = app.TB_x_Sender_Name__c;
            data.DecisionDetails = app.TB_Decision_Details__c;
            data.HighSchoolExamYear = app.TB_HS_Exam_Year__c;
            data.Foreigner = app.TB_Foreigner__c;
            data.QualificationType = app.TB_Qualification_Type__c;
            data.QualificationLocationType = app.TB_Qualification_Location_Type__c;
            data.QualificationDate = app.TB_Qualification_Term__r.TB_Start_DST__c;
            data.QualificationStatus = app.TB_Qualification_Status__c;
            data.RankingListMode = app.TB_Ranking_List_Mode__c;
            data.EmailSignature = app.TB_x_Email_Footer__c;
            data.PDOptIn = app.TB_PD_Opt_In__c;
            data.MBA = app.TB_MBA__c;
            data.SPPB = app.TB_SPPB__c;
            data.DocumentsNotComplete = app.TB_Documents_Not_Complete__c;
            data.QualificationDatesAvailable = app.TB_Qualification_Dates_Available__c;
            data.CampaignTransferType = app.TB_Campaign_Transfer_Type__c;
            data.CreatedDate = datetime.now();

            mcentry.Data = data;

            MCEntriesToSend.add(JSON.serialize(mcentry));
        }

        return MCEntriesToSend;
    }

    private static void singleCallToMCDE(String JSONBody, String token) {

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        System.debug('postEndPoint: ' + TB_Marketing_Cloud_API__c.getOrgDefaults());
        request.setEndpoint(postEndPoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + token);
        System.debug('JSONBody : ' + JSONBody);
        request.setBody(JSONBody);
        HttpResponse response = http.send(request);
        System.debug('response : ' + response.getBody());
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
        private String ApplicationId;
        private Boolean Test;
        private String ApplicationNumber;
        private String ApplicantId;
        private String FirstName;
        private String LastName;
        private String Citizenship;
        private String Email;
        private Boolean HasOptedOutOfEmail;
        private String MobilePhone;
        private Boolean HasOptedOutOfMobile;
        private String AnonymizationStatus;
        private String AcademicYear;
        private String StartingSemester;
        private String AgencyEmail;
        private String AgreementType;
        private String AgreementStatus;
        private String ApplicationStatus;
        private String ApplicationSubStatus;
        private String AdmissionsFeeStatus;
        private String TuitionFeeStatus;
        private String DocumentsStatus;
        private String EducationStatus;
        private String EvaluationStatus;
        private String ExperienceStatus;
        private String ScholarshipStatus;
        private String PDStatus;
        private String PEUStatus;
        private String RankingListStatus;
        private Boolean RankingListResultsPublished;
        private String CampusId;
        private String CampusNamePL;
        private String CampusNameEN;
        private String FacultyId;
        private String FacultyNamePL;
        private String FacultyNameEN;
        private String CommunicationLanguage;
        private Datetime LastStatusChange;
        private Datetime LastSubStatusChange;
        private String ProductId;
        private String ProductCode;
        private String ProductFullCode;
        private String ProductGroup;
        private String ProductNamePL;
        private String ProductNameEN;
        private String ProductURL;
        private String ProductLevel;
        private String ProductMode;
        private String RecipientEmail;
        private String ReplyToEmail;
        private String SenderEmail;
        private String SenderName;
        private String DecisionDetails;
        private String HighSchoolExamYear;
        private Boolean Foreigner;
        private String QualificationType;
        private String QualificationLocationType;
        private DateTime QualificationDate;
        private String QualificationDetails;
        private String QualificationStatus;
        private Boolean RankingListMode;
        private String EmailSignature;
        private Boolean PDOptIn;
        private Boolean MBA;
        private Boolean SPPB;
        private Boolean DocumentsNotComplete;
        private Boolean QualificationDatesAvailable;
        private String CampaignTransferType;
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