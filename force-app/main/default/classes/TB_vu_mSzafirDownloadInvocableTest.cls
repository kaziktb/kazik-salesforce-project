/**
 * Created by adampeczkowski on 27/06/2023.
 */

@IsTest
private class TB_vu_mSzafirDownloadInvocableTest
{
    @IsTest
    static void testEnqueueFileDownload()
    {
        ContentVersion cv = new ContentVersion(Title='Document To Sign',VersionData=Blob.valueOf('testVersion'),PathOnClient='doc.pdf',TB_Category__c = 'Student_Certificate');
        insert cv;
        Case certCase = new Case();
        certCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TB_Student_Certificate_HE').getRecordTypeId();
        insert certCase;
        ContentVersion cvInserted = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId = cvInserted.ContentDocumentId, LinkedEntityId = certCase.Id, ShareType = 'I', Visibility = 'AllUsers');
        insert cdl;
        
        Test.startTest();
        Integer queueableJobs = Limits.getQueueableJobs();
        Boolean exceptionThrown = false;
        try
        {
            TB_vu_mSzafirDownloadInvocable.enqueueFileDownload(new List<Id> {certCase.Id});
        }
        catch(Exception e)
        {
            exceptionThrown = true;
        }
        queueableJobs = Limits.getQueueableJobs() - queueableJobs;
        Test.stopTest();
        
        Assert.areEqual(1,queueableJobs);
        Assert.isFalse(exceptionThrown);
    }
    
    @IsTest
    static void testEnqueueFileDownloadNoFile()
    {
        Case certCase = new Case();
        certCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TB_Student_Certificate_HE').getRecordTypeId();
        insert certCase;
        
        Test.startTest();
        Integer queueableJobs = Limits.getQueueableJobs();
        Boolean exceptionThrown = false;
        try
        {
            TB_vu_mSzafirDownloadInvocable.enqueueFileDownload(new List<Id> {certCase.Id});
        }
        catch(Exception e)
        {
            exceptionThrown = true;
        }
        queueableJobs = Limits.getQueueableJobs() - queueableJobs;
        Test.stopTest();
        
        Assert.areEqual(0,queueableJobs);
        Assert.isTrue(exceptionThrown);
    }
}