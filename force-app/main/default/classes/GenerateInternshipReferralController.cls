public without sharing class GenerateInternshipReferralController {
    @AuraEnabled
    public static Boolean isInternshipApplicationReadyToProceed(Id internshipApplicationId) {
        DT_Internship_Application__c internshipApplication = [
            SELECT DT_Status__c
            FROM DT_Internship_Application__c
            WHERE Id = :internshipApplicationId
        ];

        return internshipApplication.DT_Status__c == DT_Utils.INTERNSHIP_APPLICATION_STATUS_READY_TO_PROCEED;
    }

    @AuraEnabled
    public static String generateReferral(Id internshipApplicationId, String language) {
        if (internshipApplicationId == null || language == null) {
            return null;
        }

        DT_Internship_Application__c internshipApplication = [
            SELECT Application_Number__c
            FROM DT_Internship_Application__c
            WHERE Id = :internshipApplicationId
        ];

        Blob referralBlob;

        if (language == Label.Language_English) {
            referralBlob = InternshipReferralGenerator.fetchReferralByRecordIdAndType(internshipApplicationId, InternshipReferralGenerator.ReferralType.English);
        } else if (language == Label.Language_Polish) {
            referralBlob = InternshipReferralGenerator.fetchReferralByRecordIdAndType(internshipApplicationId, InternshipReferralGenerator.ReferralType.Polish);
        }

        String fileName = internshipApplication.Application_Number__c + DT_Utils.CONTENT_FILE_EXTENSION_PDF;

        List<ContentDocumentLink> existingContentDocumentLinks = [
            SELECT ContentDocument.Id
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :internshipApplicationId
                AND ContentDocument.Title = :fileName
        ];

        if (!existingContentDocumentLinks.isEmpty()) {
            delete existingContentDocumentLinks[0].ContentDocument;
        }

        ContentVersion contentVersion = DT_Utils.createContentVersionFromBlob(
            fileName,
            referralBlob,
            DT_Utils.CONTENT_LOCATION_SALESFORCE
        );

        insert contentVersion;

        contentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];

        ContentDocumentLink contentDocumentLink = DT_Utils.createContentDocumentLink(
            internshipApplicationId,
            contentVersion.ContentDocumentId,
            DT_Utils.CONTENT_SHARE_TYPE_VIEWER,
            DT_Utils.CONTENT_VISIBILITY_ALL_USERS
        );

        insert contentDocumentLink;

        return Url.getSalesforceBaseUrl().toExternalForm()
            + DT_Utils.SERVLET_DOCUMENT_DOWNLOAD_URL
            + contentVersion.ContentDocumentId
            + DT_Utils.SERVLET_DOCUMENT_DOWNLOAD_OPERATION_CONTEXT_PARAM;
    }

    @AuraEnabled
    public static void generateApplicationNumber(Id applicationId) {
        DT_Internship_Application__c application = [
            SELECT Application_Number__c
            FROM DT_Internship_Application__c
            WHERE Id = :applicationId
        ];

        Integer thisYearApplicationsCount = [
            SELECT COUNT()
            FROM DT_Internship_Application__c
            WHERE CreatedDate = THIS_YEAR
                AND Application_Number__c != NULL
        ];

        thisYearApplicationsCount = thisYearApplicationsCount == 0 ? 1 : ++thisYearApplicationsCount;

        List<Object> numberFormatParameters = new List<Object>{
            String.valueOf(thisYearApplicationsCount).leftPad(5, '0'),
            Date.today().year()
        };

        application.Application_Number__c = String.format(
            DT_Utils.INTERNSHIP_APPLICATION_NUMBER_FORMAT,
            numberFormatParameters
        );

        update application;
    }
}