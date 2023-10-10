/**
 * Created by Kamil Pilarski on 20.12.2021.
 */

public with sharing class TB_AgreementConclusionController {
    public static final String userIp = !Test.isRunningTest() ? Auth.SessionManagement.getCurrentSession().get(TB_Constants.TB_SESSION_PROPERTY_SOURCE_IP) : '8.8.8.8';

    @AuraEnabled
    public static String getAgreementHtml(Id applicationId, String userAgent, String stepId, String stageId) {
        try {
            logAgreementView(applicationId, userAgent, stepId, stageId);
            TB_Application_Document__c agreementApplicationDocument = getTemplateAppDocument(applicationId);
            Id contentDocumentId = getTemplateContentDocument(agreementApplicationDocument.TB_Document_Template__c);

            ContentVersion cv = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId = :contentDocumentId];
            return TB_HtmlMergeFieldUtils.getApplicationBasedHtmlValue(applicationId, cv.VersionData.toString());
        } catch (TemplateNotFoundException templateNotFoundException) {
            try {
                insert TB_LogUtils.registerLog(templateNotFoundException);
                update new hed__Application__c(Id = applicationId, TB_Agreement_Status__c = 'Error');
                TB_Application_Step_History__c stepHistory = createHistory(applicationId, userAgent, TB_Constants.TB_APP_STEP_HISTORY_STATUS_ERROR, stepId, stageId);
                stepHistory.TB_Error_Details__c = 'No matching Application Documents for template found';
                stepHistory.TB_Step_Data__c = String.valueOf(templateNotFoundException) + templateNotFoundException.getStackTraceString();
                TB_AdmissionsStepHistoryController.insertHistory(stepHistory);
            } catch (Exception loggingException) {
                insert TB_LogUtils.registerLog(loggingException);
            }
        } catch (Exception unknownException) {
            try {
                logUnknownException(unknownException, applicationId, userAgent, stepId, stageId);
            } catch (Exception loggingException) {
                insert TB_LogUtils.registerLog(loggingException);
            }
        }
        return 'ERROR';
    }

    @AuraEnabled
    public static void logCheckboxTick(Id applicationId, String userAgent, String stepId, String stageId) {
        insertHistory(applicationId, userAgent, TB_Constants.TB_APP_STEP_HISTORY_STATUS_READ, stepId, stageId);
    }

    @AuraEnabled
    public static void logAgreementView(Id applicationId, String userAgent, String stepId, String stageId) {
        insertHistory(applicationId, userAgent, TB_Constants.TB_APP_STEP_HISTORY_STATUS_DISPLAYED, stepId, stageId);
    }

    private static void insertHistory(String appId, String browserInfo, String status, String stepId, String stageId) {
        if (checkIsCurrentUserApplicant()) {
            TB_AdmissionsStepHistoryController.insertHistory(createHistory(appId, browserInfo, status, stepId, stageId));
        }
    }

    private static TB_Application_Step_History__c createHistory(String appId, String browserInfo, String status, String stepId, String stageId) {
        return new TB_Application_Step_History__c(
                RecordTypeId = TB_Constants.TB_APP_STEP_HISTORY_AGREEMENT_RT_ID,
                TB_Status__c = status,
                TB_User_Name__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName(),
                TB_User_IP__c = userIp,
                TB_User_Browser__c = browserInfo,
                TB_Event_Date_Time__c = Datetime.now(),
                TB_Application__c = appId,
                TB_Admissions_Step__c = stepId,
                TB_Admissions_Stage__c = stageId
        );
    }

    @AuraEnabled
    public static void saveAcceptedAgreement(Id applicationId, String userAgent, String stepId, String stageId) {
        Savepoint savePoint = Database.setSavepoint();
        try {
            if (!checkIsCurrentUserApplicant()) {
                throw new AuraHandledException('Illegal operation: you cannot sign other user\'s agreement while using Log In As Community User');
            }
            TB_Application_Document__c templateAppDocument = getTemplateAppDocument(applicationId);
            Id templateContentDocument = getTemplateContentDocument(templateAppDocument.TB_Document_Template__c);
            Blob pdfBlob = getPdf(templateContentDocument, applicationId);
            TB_Application_Document__c concludedAgreementAppDocument = getConcludedAgreementAppDocument(applicationId);
            String filename = templateAppDocument.TB_Application__r.hed__Applicant__r.TB_Communication_Language__c == TB_Constants.TB_COMMUNICATION_LANGUAGE_ENGLISH
                    ? templateAppDocument.TB_Document_Name_EN__c
                    : templateAppDocument.TB_Document_Name_PL__c;
            insert new ContentVersion(
                    TB_Application_Document__c = concludedAgreementAppDocument.Id,
                    VersionData = pdfBlob,
                    PathOnClient = filename + '.pdf'
            );
            update new hed__Application__c(Id = applicationId, TB_Agreement_Status__c = TB_Constants.TB_APPLICATION_AGREEMENT_STATUS_CONCLUDED, TB_Agreement_Concluded_Date_Time__c = Datetime.now());
            insertHistory(applicationId, userAgent, TB_Constants.TB_APP_STEP_HISTORY_STATUS_CONCLUDED, stepId, stageId);
        } catch(AuraHandledException auraHandledException) {
            throw auraHandledException;
        } catch (Exception e) {
            try {
                Database.rollback(savePoint);
                logUnknownException(e, applicationId, userAgent, stepId, stageId);
            } catch (Exception loggingException) {
                insert TB_LogUtils.registerLog(loggingException);
            }
        }
    }

    @AuraEnabled(Cacheable=true)
    public static Boolean checkIsCurrentUserApplicant() {
        if (Test.isRunningTest()) {
            return true;
        }
        Map<String,String> currentSession = Auth.SessionManagement.getCurrentSession();
        return currentSession.get('SourceIp') != '::' && currentSession.get('UserType') != 'Standard' && currentSession.get('LoginType') != 'Unknown';
    }

    @AuraEnabled(Cacheable=true)
    public static String getAgreementPdfUrl(Id applicationId) {
        return getConcludedAgreementAppDocument(applicationId).TB_Download_URL__c;
    }

    private static TB_Application_Document__c getTemplateAppDocument(Id applicationId) {
        List<TB_Application_Document__c> templateAppDocuments = [
                SELECT TB_Document_Template__c, TB_Application__r.hed__Applicant__r.TB_Communication_Language__c,
                    TB_Document_Name_EN__c, TB_Document_Name_PL__c
                FROM TB_Application_Document__c
                WHERE TB_Application__c = :applicationId
                AND TB_Active__c = TRUE
                AND TB_Document_Category__c = :TB_Constants.TB_APP_DOCUMENT_CATEGORY_STUDY_AGREEMENT_ELECTRONIC
                AND TB_Document_Type__c = :TB_Constants.TB_APP_DOCUMENT_TYPE_ELECTRONIC_TEMPLATE
                ORDER BY LastModifiedDate DESC
                LIMIT 1
        ];

        if (templateAppDocuments.size() == 0) {
            throw new TemplateNotFoundException();
        }

        return templateAppDocuments[0];
    }

    private static Id getTemplateContentDocument(Id documentTemplateId) {
        return [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :documentTemplateId
                ORDER BY ContentDocument.LastModifiedDate DESC
                LIMIT 1
        ].ContentDocumentId;
    }

    public static TB_Application_Document__c getConcludedAgreementAppDocument(Id applicationId) {
        TB_Application_Document__c concludedAgreementAppDocument = [
                SELECT Id, TB_Download_URL__c, CreatedDate
                FROM TB_Application_Document__c
                WHERE TB_Application__c = :applicationId
                AND TB_Document_Category__c = :TB_Constants.TB_APP_DOCUMENT_CATEGORY_STUDY_AGREEMENT_ELECTRONIC
                AND TB_Document_Type__c = :TB_Constants.TB_APP_DOCUMENT_TYPE_ELECTRONIC
                ORDER BY CreatedDate DESC
                LIMIT 1
        ];
        return concludedAgreementAppDocument;
    }

    private static Blob getPdf(Id templateContentDocument, Id applicationId) {
        PageReference pdfVisualForce = Page.TB_PdfGenerator;
        pdfVisualForce.getParameters().put(TB_PdfGeneratorController.PARAM_CONTENT_DOCUMENT_ID, templateContentDocument);
        pdfVisualForce.getParameters().put(TB_PdfGeneratorController.PARAM_APP_ID, applicationId);
        Blob pdfBlob = !Test.isRunningTest() ? pdfVisualForce.getContentAsPDF() : Blob.valueOf('test');
        return pdfBlob;
    }

    @TestVisible
    private static void logUnknownException(Exception insertException, Id applicationId, String userAgent, String stepId, String StageId) {
        insert TB_LogUtils.registerLog(insertException);
        update new hed__Application__c(Id = applicationId, TB_Agreement_Status__c = 'Error');
        TB_Application_Step_History__c stepHistory = createHistory(applicationId, userAgent, TB_Constants.TB_APP_STEP_HISTORY_STATUS_ERROR, stepId, stageId);
        stepHistory.TB_Error_Details__c = 'Unknown exception happened while saving the agreement';
        stepHistory.TB_Step_Data__c = String.valueOf(insertException) + insertException.getStackTraceString();
        TB_AdmissionsStepHistoryController.insertHistory(stepHistory);
    }

    private class TemplateNotFoundException extends Exception {
    }
}