public with sharing class DT_JobOfferTriggerHelper {
    public static void sendSummaryEmailAfterJobPlacementAcceptance(List<DT_Job_Offers__c> newOffers, Map<Id, DT_Job_Offers__c> id2OldOffer) {
        Set<Id> jobOffersIdToProcess = new Set<Id>();
        
        Id jobPlacementRecordTypeId = DT_Utils.getRecTypeIdByDevName(
            DT_Utils.JOB_OFFER_RECORD_TYPE_DEVELOPER_NAME_JOB_PLACEMENT, 
            DT_Job_Offers__c.getSObjectType().getDescribe().getName()
        );

        for (DT_Job_Offers__c jobOffer : newOffers) {
            if (jobOffer.RecordTypeId == jobPlacementRecordTypeId
                && jobOffer.DT_Confirmed_By_The_Employer__c == DT_Utils.JOB_OFFER_CONFIRMED_BY_THE_EMPLOYER_ACCEPTED_VALUE
                && jobOffer.DT_Confirmed_By_The_Career_Office__c
                && DT_Utils.isFieldChanged(jobOffer, id2OldOffer.get(jobOffer.Id), DT_Job_Offers__c.DT_Confirmed_By_The_Employer__c.getDescribe().getName())
            ) {
                jobOffersIdToProcess.add(jobOffer.Id);
            }
        }

        if (jobOffersIdToProcess.isEmpty()) {
            return;
        }

        sendSummaryEmailAfterJobPlacementAcceptanceFuture(jobOffersIdToProcess);
    }

    @future(callout=true)
    public static void sendSummaryEmailAfterJobPlacementAcceptanceFuture(Set<Id> jobPlacementIds) {
        List<DT_Job_Offers__c> jobOffersToProcess = [
            SELECT DT_Email__c, DT_Offer_Preffered_Language__c, Name
            FROM DT_Job_Offers__c
            WHERE Id IN :jobPlacementIds 
        ];

        Map<Id, ContentVersion> jobOfferId2ContentVersion = new Map<Id, ContentVersion>();

        for (DT_Job_Offers__c jobOffer : jobOffersToProcess) {
            DT_JobPlacementSummaryGenerator.SummaryType summaryType;
            

            if (jobOffer.DT_Offer_Preffered_Language__c == DT_Utils.JOB_OFFER_PREFFERED_LANGUAGE_ENGLISH) {
                summaryType = DT_JobPlacementSummaryGenerator.SummaryType.English;
            } else if (jobOffer.DT_Offer_Preffered_Language__c == DT_Utils.JOB_OFFER_PREFFERED_LANGUAGE_POLISH) {
                summaryType = DT_JobPlacementSummaryGenerator.SummaryType.Polish;
            }

            Blob createdDocumentBlob = DT_JobPlacementSummaryGenerator.fetchSummaryPDFByIdAndType(jobOffer.Id, summaryType);

            if (createdDocumentBlob == null) {
                continue;
            }

            ContentVersion contentVersion = DT_Utils.createContentVersionFromBlob(
                jobOffer.Name + DT_Utils.CONTENT_FILE_EXTENSION_PDF, createdDocumentBlob, DT_Utils.CONTENT_LOCATION_SALESFORCE
            );
            
            jobOfferId2ContentVersion.put(jobOffer.Id, contentVersion);
        }

        if (jobOfferId2ContentVersion.isEmpty()) {
            return;
        }

        insert jobOfferId2ContentVersion.values();

        Map<Id, ContentVersion> id2ContentVersion = new Map<Id, ContentVersion>([
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id IN :jobOfferId2ContentVersion.values()
        ]);

        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();

        for (DT_Job_Offers__c jobOffer : jobOffersToProcess) {
            if (!jobOfferId2ContentVersion.containsKey(jobOffer.Id)) {
                continue;
            }

            Id contentVersionId = jobOfferId2ContentVersion.get(jobOffer.Id).Id;

            ContentDocumentLink contentDocumentLink = DT_Utils.createContentDocumentLink(
                jobOffer.Id,
                id2ContentVersion.get(contentVersionId).ContentDocumentId,
                DT_Utils.CONTENT_SHARE_TYPE_VIEWER,
                DT_Utils.CONTENT_VISIBILITY_ALL_USERS
            );

            contentDocumentLinks.add(contentDocumentLink);
        }

        insert contentDocumentLinks;

        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        Map<String, EmailTemplate> language2EmailTemplate = DT_EmailService.fetchJobOfferLanguage2JobPlacementSummaryEmailTemplate();
        Id careerOfficeOrgWideEmailId = DT_EmailService.fetchOrgWideEmailAddressIdByDisplayName(DT_Utils.EMAIL_ORGANIZATION_WIDE_ADDRESS_CAREER_OFFICE_DISPLAY_NAME);

        for (DT_Job_Offers__c jobOffer : jobOffersToProcess) {
            if (!jobOfferId2ContentVersion.containsKey(jobOffer.Id)) {
                continue;
            }

            String emailAddress = jobOffer.DT_Email__c;
            String language = jobOffer.DT_Offer_Preffered_Language__c;
            ContentVersion summaryDocument = jobOfferId2ContentVersion.get(jobOffer.Id);

            EmailTemplate emailTemplate = language2EmailTemplate.get(language);
            Messaging.SingleEmailMessage emailMessage = DT_EmailService.createSingleEmailMessage(
                emailAddress,
                false,
                emailTemplate,
                jobOffer.Id,
                careerOfficeOrgWideEmailId,
                new List<ContentVersion>{summaryDocument}
            );
            emailsToSend.add(emailMessage);
        }

        Messaging.sendEmail(emailsToSend);
    }
}