/**
 * Created by annaseveryna on 08/12/2021.
 */

public with sharing class TB_RequestController {
    private static final Date CURRENT_DATE = Test.isRunningTest() ? Date.newInstance(2021, 11, 20) : Date.today();
    static List<TB_Admissions_Dictionary__c> activeRequests = new List<TB_Admissions_Dictionary__c>();

    @AuraEnabled
    public static String createNewCase(String jsonRequestWrapper, Boolean askForFile) {
        String documentName = null;

        String caseRecordTypeId = Schema.SObjectType.Case
                .getRecordTypeInfosByDeveloperName().get('TB_Application_Request_Case').getRecordTypeId();
        RequestWrapper requestWrapper = (RequestWrapper) JSON.deserialize(jsonRequestWrapper, RequestWrapper.class);
        try {
            Case request = new Case(
                    RecordTypeId = caseRecordTypeId,
                    Subject = requestWrapper.subject,
                    TB_Message_Subject__c = requestWrapper.subjectId,
                    Type = 'Application Request',
                    hed__Category__c = 'Admissions',
                    ContactId = requestWrapper.contactId,
                    TB_Application__c = requestWrapper.applicationId,
                    Origin = 'Admissions_Portal',
                    Status = 'New',
                    Description = requestWrapper.contentValue
            );

            request.TB_x_Created_by_Partner__c = TB_RequestSubmittedControllerSharingSkip.userIdToIsPartnerUser(UserInfo.getUserId());

            if (askForFile) {
                TB_Application_Document__c document = createApplicationDocumentSlot(requestWrapper.applicationId, requestWrapper.contactId);
                insert document;
                request.TB_Document__c = document.Id;
                documentName = [
                    SELECT TB_Document_File_Name__c
                    FROM TB_Application_Document__c
                    WHERE Id =: document.Id
                ].TB_Document_File_Name__c;
            }
            insert request;

            return JSON.serialize(new CaseWrapper(request, documentName));
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return 'FAILED';
        }
    }

    public class CaseWrapper {
        @AuraEnabled public Case request { get; set; }
        @AuraEnabled public String documentName { get; set; }

        public CaseWrapper(Case request, String documentName) {
            this.request = request;
            this.documentName = documentName;
        }
    }

    private static TB_Application_Document__c createApplicationDocumentSlot(String applicationId, String contactId) {
        TB_Application_Document__c applicationDocument = new TB_Application_Document__c(
                TB_Application__c = applicationId,
                TB_Status__c = 'Empty',
                TB_Contact__c = contactId,
                TB_Document_Category__c = 'Application_Request',
                TB_Document_Type__c = 'Scan',
                TB_Output_Format__c = 'Original'
        );
        return applicationDocument;
    }

    public class RequestWrapper {
        @AuraEnabled public String subject { get; set; }
        @AuraEnabled public String subjectId { get; set; }
        @AuraEnabled public Contact contact { get; set; }
        @AuraEnabled public String contactId { get; set; }
        @AuraEnabled public hed__Application__c application { get; set; }
        @AuraEnabled public String applicationId { get; set; }
        @AuraEnabled public String contentValue { get; set; }
    }

    @AuraEnabled
    public static String getAllContactApplicationsWrapper(Id contactId) {
        List<hed__Application__c> allContactApplications = getAllContactApplications(contactId);
        activeRequests = getAvailableRequests();
        List<ApplicationWrapper> allApplicationWrapper = new List<ApplicationWrapper>();
        for (hed__Application__c singleApplication : allContactApplications) {
            ApplicationWrapper singleWrapper
                = new ApplicationWrapper(singleApplication, matchAvailableRequests(singleApplication, activeRequests));
            allApplicationWrapper.add(singleWrapper);
        }
        return JSON.serialize(allApplicationWrapper);
    }

    @AuraEnabled
    public static String connectFileWithCase(String caseRecordId, String documentId) {
        try {
            ContentDocument document = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :documentId LIMIT 1];
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
                    ContentDocumentId = document.Id,
                    LinkedEntityId = caseRecordId,
                    ShareType = 'I'
            );
            insert contentDocumentLink;
            return 'SUCCESS';
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e, TB_RequestController.class);
            return 'FAILED';
        }
    }

    public class ApplicationWrapper {
        @AuraEnabled public hed__Application__c application { get; set; }
        @AuraEnabled public String applicationHeader { get; set; }
        @AuraEnabled public List<TB_Admissions_Dictionary__c> availableRequests { get; set; }

        public ApplicationWrapper(hed__Application__c application, List<TB_Admissions_Dictionary__c> requests) {
            this.application = application;
            this.applicationHeader = TB_SObjectUtils.getApplicationHeader(application, application.TB_Communication_Language__c);
            this.availableRequests = requests;
        }
    }

    private static List<hed__Application__c> getAllContactApplications(Id contactId) {
        String allContactApplicationsQuery = 'SELECT Id, Name, TB_Status_For_Applicant_PL__c, TB_Status_For_Applicant_EN__c, ' +
            ' TB_Level_of_Study__c, toLabel(TB_Level_of_Study__c) TB_Level_of_Study_Label, ' +
            ' TB_Mode_of_Study__c, toLabel(TB_Mode_of_Study__c) TB_Mode_of_Study_Label, TB_Applying_To_Offered_Product__r.TB_Language_of_Study__c, ' +
            ' TB_Applicant_Citizenship__c, hed__Application_Status__c, TB_Agreement_Type__c, TB_x_Mode_of_Study_EN__c, TB_x_Mode_of_Study_PL__c, ' +
            ' TB_x_Faculty_EN__c, TB_x_Faculty_PL__c, TB_x_Campus_PL__c, TB_x_Campus_EN__c, TB_Product_Name__c, TB_Communication_Language__c ' +
            ' FROM hed__Application__c ' +
            ' WHERE hed__Applicant__c = :contactId ';

        if(!isTestContact(contactId)) {
            allContactApplicationsQuery += ' AND TB_Active__c = true AND TB_Archived__c = false AND TB_Anonymization_Status__c != \'Anonymized\'';
        }

        allContactApplicationsQuery += ' ORDER BY Name DESC';
        try {
            List<hed__Application__c> allContactApplications = Database.query(allContactApplicationsQuery);
            return allContactApplications;
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    private static Boolean isTestContact(String contactId) {
        Contact contact = [SELECT TB_Test__c FROM Contact WHERE Id = :contactId];
        return contact.TB_Test__c;
    }

    private static List<TB_Admissions_Dictionary__c> matchAvailableRequests(hed__Application__c application, List<TB_Admissions_Dictionary__c> activeRequests) {
        List<TB_Admissions_Dictionary__c> matchedRequests = new List<TB_Admissions_Dictionary__c>();
        for (TB_Admissions_Dictionary__c request : activeRequests) {
            if (matchLevelOfStudy(application, request)
                    && matchModeOfStudy(application, request)
                    && matchLanguageOfStudy(application, request)
                    && matchCitizenship(application, request)
                    && matchApplicationStatus(application, request)
                    && matchAgreementType(application, request)
                    ) {
                matchedRequests.add(request);
            }
        }
        return matchedRequests;
    }

    @AuraEnabled
    public static List<TB_Admissions_Dictionary__c> getAvailableRequests() {
        List<TB_JSON_Wrapper__c> jsonRequests = [
                SELECT TB_Wrapper_Value__c
                FROM TB_JSON_Wrapper__c
                WHERE TB_Object_API_Name__c = 'TB_Admissions_Dictionary__c'
                AND TB_Record_Type_Dev_Name__c = 'TB_Application_Request'
        ];
        List<TB_Admissions_Dictionary__c> availableRequests = new List<TB_Admissions_Dictionary__c>();
        for (TB_JSON_Wrapper__c serializedRequest : jsonRequests) {
            TB_Admissions_Dictionary__c request = (TB_Admissions_Dictionary__c) JSON.deserialize(serializedRequest.TB_Wrapper_Value__c, TB_Admissions_Dictionary__c.class);
            if (request.TB_Active__c && matchDates(request)) {
                availableRequests.add(request);
            }
        }
        return availableRequests;
    }

    private static Boolean matchDates(TB_Admissions_Dictionary__c activeRequest) {
        return activeRequest.TB_Valid_From__c <= CURRENT_DATE && activeRequest.TB_Valid_To__c >= CURRENT_DATE;
    }

    private static Boolean matchLevelOfStudy(hed__Application__c application, TB_Admissions_Dictionary__c activeRequest) {
        return (application.TB_Level_of_Study__c != null) && (activeRequest.TB_Level_of_Study__c == null
                || activeRequest.TB_Level_of_Study__c.contains(application.TB_Level_of_Study__c)
                || String.isBlank(activeRequest.TB_Level_of_Study__c)
        );
    }

    private static Boolean matchModeOfStudy(hed__Application__c application, TB_Admissions_Dictionary__c activeRequest) {
        return (application.TB_Mode_of_Study__c != null) && (activeRequest.TB_Mode_of_Study__c == null
                || activeRequest.TB_Mode_of_Study__c.contains(application.TB_Mode_of_Study__c)
                || String.isBlank(activeRequest.TB_Mode_of_Study__c)
        );
    }

    private static Boolean matchLanguageOfStudy(hed__Application__c application, TB_Admissions_Dictionary__c activeRequest) {
        return (application.TB_Applying_To_Offered_Product__r.TB_Language_of_Study__c != null) && (activeRequest.TB_Language_of_Study__c == null
                || activeRequest.TB_Language_of_Study__c == application.TB_Applying_To_Offered_Product__r.TB_Language_of_Study__c
                || String.isBlank(activeRequest.TB_Language_of_Study__c)
        );
    }

    private static Boolean matchCitizenship(hed__Application__c application, TB_Admissions_Dictionary__c activeRequest) {
        return (activeRequest.TB_Citizenships__c == null
                || activeRequest.TB_Citizenships__c == 'Everyone'
                || (activeRequest.TB_Citizenships__c == 'Polish_Citizens' && application.TB_Applicant_Citizenship__c == 'Poland')
                || (activeRequest.TB_Citizenships__c == 'Non_Polish_Citizens' && application.TB_Applicant_Citizenship__c != 'Poland'));
    }

    private static Boolean matchApplicationStatus(hed__Application__c application, TB_Admissions_Dictionary__c activeRequest) {
        return (application.hed__Application_Status__c != null) && (activeRequest.TB_Application_Status__c == null
                || activeRequest.TB_Application_Status__c.contains(application.hed__Application_Status__c)
                || String.isBlank(activeRequest.TB_Application_Status__c));
    }

    private static Boolean matchAgreementType(hed__Application__c application, TB_Admissions_Dictionary__c activeRequest) {
        return (application.TB_Agreement_Type__c != null) && (activeRequest.TB_Agreement_Type__c == null
                || activeRequest.TB_Agreement_Type__c.contains(application.TB_Agreement_Type__c)
                || String.isBlank(activeRequest.TB_Agreement_Type__c)
        );
    }
}