public with sharing class TB_vu_CertificatePreviewController
{
    private static final String STUDENT_CERTIFICATE_CONTENT_VERSION_CATEGORY = 'Student_Certificate';
    private static final String STUDENT_NOTIFICATION_CONTENT_VERSION_CATEGORY = 'Student_Notification';
    
    @AuraEnabled
    public static CertInfo getCertInfo(Id recordId, String documentTemplateName)
    {
        return new CertInfo(recordId, documentTemplateName);
    }
    
    @AuraEnabled
    public static void savePDF(Id recordId, String documentTemplateName)
    {
        Case cert = [
                SELECT
                        Id, CaseNumber, TB_x_Contact_Name__c, TB_Document_Template_Name__c, TB_Document_Additional_Comment__c,
                        TB_Qualified_Signer__r.TB_x_Contact_Name__c, TB_Signature_Status__c, TB_Signature_Status_Date_Time__c,
                        RecordType.DeveloperName
                FROM Case
                WHERE Id = :recordId
        ];
        TB_vu_PDFGeneratorController.PDFQueueableParams params = new TB_vu_PDFGeneratorController.PDFQueueableParams();
        String templateName = String.isBlank(cert.TB_Document_Template_Name__c) && String.isNotBlank(documentTemplateName) ? documentTemplateName : cert.TB_Document_Template_Name__c;
        params.templateId = TB_vu_PDFGeneratorController.getTemplateDocumentId(templateName);
        if(params.templateId == null)
        {
            throw new AuraHandledException(
                    TB_vu_Utils.registerLog(
                            'No Certificate Template named: "' + templateName + '" found',
                            TB_vu_CertificatePreviewController.class.getName(),
                            null,
                            recordId
                    )
            );
        }
        params.networkId = Network.getNetworkId();
        params.objects = new List<TB_vu_PDFGeneratorController.PDFObjectWrapper>();
        TB_vu_PDFGeneratorController.PDFObjectWrapper wrapper = new TB_vu_PDFGeneratorController.PDFObjectWrapper();
        wrapper.recordId = cert.Id;
        wrapper.relatedRecordIds.add(cert.Id);
        wrapper.linkToIds.add(cert.Id);
        wrapper.category = cert.RecordType.DeveloperName == TB_vu_Constants.CERTIFICATE_CASE_RECORD_TYPE_DEVELOPER_NAME ? STUDENT_CERTIFICATE_CONTENT_VERSION_CATEGORY : STUDENT_NOTIFICATION_CONTENT_VERSION_CATEGORY;
        wrapper.fileName = (cert.RecordType.DeveloperName == TB_vu_Constants.CERTIFICATE_CASE_RECORD_TYPE_DEVELOPER_NAME ? Label.TB_Certificate_PDF_Name : Label.TB_Notification_PDF_Name) + ' ' + cert.CaseNumber + ' - ' + cert.TB_x_Contact_Name__c;
        wrapper.replacements = new Map<String,String>();
        wrapper.replacements.put('CreationDate',Date.today().format());
        wrapper.replacements.put('AdditionalComment',String.isBlank(cert.TB_Document_Additional_Comment__c) ? '' : cert.TB_Document_Additional_Comment__c);
        wrapper.replacements.put('Signer',String.isBlank(cert.TB_Qualified_Signer__r.TB_x_Contact_Name__c) ? '.............................' : cert.TB_Qualified_Signer__r.TB_x_Contact_Name__c);
        
        List<ContentDocumentLink> cdls = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :cert.Id AND ContentDocument.LatestPublishedVersion.TB_Category__c = :wrapper.category];
        if(!cdls.isEmpty())
        {
            wrapper.isUpdate = true;
            wrapper.existingContentDocumentId = cdls[0].ContentDocumentId;
        }
        
        params.objects.add(wrapper);
        Id pdfId = new TB_vu_PDFGeneratorController.PDFQueueable(params).executeSync();
        if(pdfId == null)
        {
            throw new AuraHandledException('Error generating pdf');
        }
        cert.TB_Signature_Status__c = 'New';
        cert.TB_Signature_Status_Date_Time__c = Datetime.now();
        update cert;
    }
    
    public class CertInfo
    {
        @AuraEnabled public List<Id> recordIds;
        @AuraEnabled public String replacementsJSON;
        @auraEnabled public String documentTemplateName;
        private Case certificate;
        
        CertInfo(Id caseId, String documentTemplateName)
        {
            this.documentTemplateName = documentTemplateName;
            this.recordIds = new List<Id>{caseId};
            this.certificate = [
                    SELECT
                            Id, TB_Document_Template_Name__c, TB_Document_Additional_Comment__c,
                            TB_Qualified_Signer__r.TB_x_Contact_Name__c
                    FROM Case
                    WHERE Id = :caseId
            ];
            addTemplateId();
            parseReplacementsJSON();
        }
        
        private void addTemplateId()
        {
            String templateName = String.isBlank(certificate.TB_Document_Template_Name__c) && String.isNotBlank(this.documentTemplateName) ? this.documentTemplateName : certificate.TB_Document_Template_Name__c;
            Id templateId = TB_vu_PDFGeneratorController.getTemplateDocumentId(templateName);
            if(templateId != null)
            {
                this.recordIds.add(templateId);
            }
        }
        
        private void parseReplacementsJSON()
        {
            Map<String,String> replacementsMap = new Map<String,String>();
            replacementsMap.put('CreationDate',Date.today().format());
            replacementsMap.put('AdditionalComment',String.isBlank(certificate.TB_Document_Additional_Comment__c) ? '' : certificate.TB_Document_Additional_Comment__c);
            replacementsMap.put('Signer', certificate.TB_Qualified_Signer__r == null || String.isBlank(certificate.TB_Qualified_Signer__r.TB_x_Contact_Name__c) ? '.............................' : certificate.TB_Qualified_Signer__r.TB_x_Contact_Name__c);
            this.replacementsJSON = JSON.serialize(replacementsMap);
        }
    }
}