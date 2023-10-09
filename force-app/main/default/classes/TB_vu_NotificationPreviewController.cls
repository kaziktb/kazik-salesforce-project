global class TB_vu_NotificationPreviewController {
    
    @InvocableMethod(callout=true label='Generate Notification PDF')
    public static void generateNotificationPDF(List<Id> recordId)
    {
        Case notification = [
                SELECT
                    Id, CaseNumber, TB_x_Contact_Name__c, TB_Document_Template_Name__c, TB_Document_Additional_Comment__c,
                    TB_Qualified_Signer__r.TB_x_Contact_Name__c
                FROM Case
                WHERE Id = :recordId[0]
                LIMIT 1
        ];
        TB_vu_PDFGeneratorController.PDFQueueableParams params = new TB_vu_PDFGeneratorController.PDFQueueableParams();
        params.templateId = TB_vu_PDFGeneratorController.getTemplateDocumentId(notification.TB_Document_Template_Name__c);
        if(params.templateId == null)
        {
            throw new AuraHandledException(TB_vu_Utils.registerLog('No Notification Template named: "' + notification.TB_Document_Template_Name__c + '" found',TB_vu_NotificationPreviewController.class.getName(),null,recordId[0])
            );
        }
        params.networkId = Network.getNetworkId();
        params.objects = new List<TB_vu_PDFGeneratorController.PDFObjectWrapper>();
        TB_vu_PDFGeneratorController.PDFObjectWrapper wrapper = new TB_vu_PDFGeneratorController.PDFObjectWrapper();
        wrapper.recordId = notification.Id;
        wrapper.relatedRecordIds.add(notification.Id);
        wrapper.linkToIds.add(notification.Id);
        wrapper.category = TB_vu_Constants.STUDENT_NOTIFICATION_CONTENT_VERSION_CATEGORY;
        wrapper.fileName = notification.CaseNumber + ' - ' + notification.TB_x_Contact_Name__c;
        wrapper.replacements = new Map<String,String>();
        wrapper.replacements.put('Signer',String.isBlank(notification.TB_Qualified_Signer__r.TB_x_Contact_Name__c) ? '.............................' : notification.TB_Qualified_Signer__r.TB_x_Contact_Name__c);
        params.objects.add(wrapper);
        new TB_vu_PDFGeneratorController.PDFQueueable(params).executeSync();
    }
}