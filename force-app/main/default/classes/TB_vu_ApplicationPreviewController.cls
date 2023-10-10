public with sharing class TB_vu_ApplicationPreviewController
{
    private static final String CASE_STATUS_CLOSED = 'Closed';
    @TestVisible
    private static final String APPLICATION_PDF_CATEGORY = 'Student_Application';
    private static final String DECISION_PDF_CATEGORY = 'Student_Application_Decision';
    
    @AuraEnabled(Cacheable=true)
    public static Case getCase(String recordId)
    {
        if(String.isNotBlank(recordId) && recordId instanceof Id && ((Id)recordId).getSobjectType() == Case.getSObjectType())
        {
            return [SELECT Id, ContactId, TB_Program_Enrollment__c FROM Case WHERE Id = :recordId];
        }
        else
        {
            throw new AuraHandledException(TB_vu_Utils.registerLog('Invalid Case ID: ' + recordId,TB_vu_ApplicationPreviewController.class.getName(), null, recordId));
        }
    }
    
    public static void enqueuePDFGeneration(List<Case> cases)
    {
        if(cases == null || cases.isEmpty())
        {
            return;
        }
        List<Id> caseIds = new List<Id>();
        for(Case singleCase : cases)
        {
            caseIds.add(singleCase.Id);
        }
        List<TB_Operation__c> initialOperations = [SELECT Id, TB_Case__c FROM TB_Operation__c WHERE TB_Case__c IN :caseIds AND TB_Initial__c = TRUE];
        Map<Id,TB_Operation__c> initialOperationsByCaseId = new Map<Id,TB_Operation__c>();
        for(TB_Operation__c op : initialOperations)
        {
            initialOperationsByCaseId.put(op.TB_Case__c,op);
        }
        enqueuePDFGeneration(cases,initialOperationsByCaseId);
    }
    
    public static void enqueuePDFGeneration(List<TB_Operation__c> operations)
    {
        if(operations == null || operations.isEmpty())
        {
            return;
        }
        List<Id> caseIds = new List<Id>();
        for(TB_Operation__c singleOperation : operations)
        {
            caseIds.add(singleOperation.TB_Case__c);
        }
        Map<Id,TB_Operation__c> initialOperationsByCaseId = new Map<Id,TB_Operation__c>();
        for(TB_Operation__c op : operations)
        {
            initialOperationsByCaseId.put(op.TB_Case__c,op);
        }
        List<Case> cases = [SELECT Id, ContactId, TB_Program_Enrollment__c, Status, CaseNumber, TB_x_Contact_Name__c FROM Case WHERE Id IN :caseIds AND RecordType.DeveloperName = 'TB_Student_Application_HE'];
        if(cases.isEmpty())
        {
            return;
        }
        enqueuePDFGeneration(cases,initialOperationsByCaseId);
    }
    
    private static void enqueuePDFGeneration(List<Case> cases, Map<Id,TB_Operation__c> initialOperationsByCaseId)
    {
        TB_vu_PDFGeneratorController.PDFQueueableParams params = new TB_vu_PDFGeneratorController.PDFQueueableParams();
        params.templateId = TB_vu_PDFGeneratorController.getTemplateDocumentId('%Application_Template%');
        params.networkId = Network.getNetworkId();
        params.objects = new List<TB_vu_PDFGeneratorController.PDFObjectWrapper>();
        for(Case singleCase : cases)
        {
            TB_vu_PDFGeneratorController.PDFObjectWrapper wrapper = new TB_vu_PDFGeneratorController.PDFObjectWrapper();
            wrapper.recordId = singleCase.Id;
            wrapper.relatedRecordIds.add(singleCase.Id);
            wrapper.relatedRecordIds.add(singleCase.ContactId);
            wrapper.relatedRecordIds.add(singleCase.TB_Program_Enrollment__c);
            wrapper.linkToIds.add(singleCase.Id);
            if(initialOperationsByCaseId.get(singleCase.Id) != null)
            {
                wrapper.linkToIds.add(initialOperationsByCaseId.get(singleCase.Id).Id);
            }
            if(singleCase.Status == CASE_STATUS_CLOSED)
            {
                wrapper.category = DECISION_PDF_CATEGORY;
                wrapper.fileName = Label.TB_Decision_PDF_Name + ' ' + singleCase.CaseNumber + ' - ' + singleCase.TB_x_Contact_Name__c;
            }
            else
            {
                wrapper.category = APPLICATION_PDF_CATEGORY;
                wrapper.fileName = Label.TB_Application_PDF_Name + ' ' + singleCase.CaseNumber + ' - ' + singleCase.TB_x_Contact_Name__c;
            }
            params.objects.add(wrapper);
        }
        System.enqueueJob(new TB_vu_PDFGeneratorController.PDFQueueable(params));
    }
}