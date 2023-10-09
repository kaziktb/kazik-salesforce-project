/**
 * @description       : 
 * @author            : aleksandra.gonta-kacperska@devoteam.com
 * @group             : 
 * @last modified on  : 05-24-2021
 * @last modified by  : aleksandra.gonta-kacperska@devoteam.com
 * Modifications Log 
 * Ver   Date         Author                                    Modification
 * 1.0   05-24-2021   aleksandra.gonta-kacperska@devoteam.com   Initial Version
**/
@isTest
public with sharing class DT_FileUploadViewControllerTest {
    @isTest
    public static void DT_FileUploadViewControllerTest() {
        
        Account acct = new Account(Name='TEST_ACCT');
        insert acct;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = acct.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl; 
        
        
        DT_FileUploadViewController.getRelatedFiles(acct.id);
        
        
        DT_FileUploadViewController.deleteFiles(documents[0].Id);
        
        List<ContentVersion> cvs = [SELECT Id FROM ContentVersion WHERE Id = :contentVersion.Id];
        System.assert(cvs.isEmpty(), 'File not found');
       
        try{	
            DT_FileUploadViewController.deleteFiles('123654789741258');
            
        }catch(Exception e){
            
           
        }
        
    }
    
}