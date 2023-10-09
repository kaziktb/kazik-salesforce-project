public with sharing class DT_EmailService {
    private static final String JOB_PLACEMENT_ACCEPTANCE_EMAIL_DEV_NAME_EN = 'JobPlacementAcceptanceEN';
    private static final String JOB_PLACEMENT_ACCEPTANCE_EMAIL_DEV_NAME_PL = 'JobPlacementAcceptancePL';

    private static final Set<String> JOB_PLACEMENT_ACCEPTANCE_EMAIL_TEMPLATES = new Set<String>{
        JOB_PLACEMENT_ACCEPTANCE_EMAIL_DEV_NAME_EN,
        JOB_PLACEMENT_ACCEPTANCE_EMAIL_DEV_NAME_PL
    };

    public static Messaging.SingleEmailMessage createSingleEmailMessage(String recipientEmail, Boolean saveAsActivity,
    EmailTemplate template, Id whatId) {
    Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(template.Id, null, whatId);
    email.templateId = template.Id;
    email.subject = template.Subject;
    email.toAddresses = new List<String> {recipientEmail};
    email.setSaveAsActivity(saveAsActivity);
    return email;
}

    public static Messaging.SingleEmailMessage createSingleEmailMessage(String recipientEmail, Boolean saveAsActivity,
        EmailTemplate template, Id whatId, Id orgWideEmailAddressId
    ) {
        Messaging.SingleEmailMessage email = createSingleEmailMessage(recipientEmail, saveAsActivity, template, whatId);
        email.setOrgWideEmailAddressId(orgWideEmailAddressId);
        return email;
    }

    public static Messaging.SingleEmailMessage createSingleEmailMessage(String recipientEmail, Boolean saveAsActivity,
        EmailTemplate template, Id whatId, Id orgWideEmailAddressId, List<ContentVersion> contentVersions
    ) {
        Messaging.SingleEmailMessage email = createSingleEmailMessage(
            recipientEmail, saveAsActivity, template, whatId, orgWideEmailAddressId
        );
        List<Messaging.EmailFileAttachment> attachments = createFileAttachments(contentVersions);
        email.setFileAttachments(attachments);
        return email;
    }

    public static List<Messaging.EmailFileAttachment> createFileAttachments(List<ContentVersion> contentVersions) {
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        for (ContentVersion contentVersion : contentVersions) {
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName(contentVersion.Title);
            attachment.setBody(contentVersion.VersionData);
            attachments.add(attachment);
        }
        return attachments;
    }

    public static Id fetchOrgWideEmailAddressIdByDisplayName(String displayName) {
        return [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = :displayName LIMIT 1].Id;
    }

    public static Map<String, EmailTemplate> fetchJobOfferLanguage2JobPlacementSummaryEmailTemplate() {
        Map<String, EmailTemplate> language2EmailTemplate = new Map<String, EmailTemplate>();

        for (EmailTemplate template : [
            SELECT Id, DeveloperName, Name, Subject, HtmlValue
            FROM EmailTemplate
            WHERE DeveloperName IN :JOB_PLACEMENT_ACCEPTANCE_EMAIL_TEMPLATES
        ]) {
            if (template.DeveloperName == JOB_PLACEMENT_ACCEPTANCE_EMAIL_DEV_NAME_EN) {
                language2EmailTemplate.put(DT_Utils.JOB_OFFER_PREFFERED_LANGUAGE_ENGLISH, template);
            } else if (template.DeveloperName == JOB_PLACEMENT_ACCEPTANCE_EMAIL_DEV_NAME_PL) {
                language2EmailTemplate.put(DT_Utils.JOB_OFFER_PREFFERED_LANGUAGE_POLISH, template);
            }
        }

            return language2EmailTemplate;
    }
}