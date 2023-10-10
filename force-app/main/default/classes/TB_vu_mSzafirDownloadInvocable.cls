global with sharing class TB_vu_mSzafirDownloadInvocable
{
    @InvocableMethod(label='enqueueFileDownload')
    public static void enqueueFileDownload(List<Id> caseId)
    {
        ContentDocumentLink cdl;
        try
        {
            cdl = [SELECT Id, ContentDocument.LatestPublishedVersion.TB_mSzafir_Signing_ID__c FROM ContentDocumentLink WHERE LinkedEntityId = :caseId AND (ContentDocument.LatestPublishedVersion.TB_Category__c = 'Student_Certificate' OR ContentDocument.LatestPublishedVersion.TB_Category__c = 'Student_Notification')];
        }
        catch(Exception e)
        {
            throw new AuraHandledException('Couldn\'t find certificate or notification');
        }
        System.enqueueJob(new TB_vu_mSzafirService.SzafirTransactionFinalizer(cdl.ContentDocument.LatestPublishedVersion.TB_mSzafir_Signing_ID__c, caseId[0]));
    }
}