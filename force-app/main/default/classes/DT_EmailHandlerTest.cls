/**
 * @description       : 
 * @author            : aleksandra.gonta-kacperska@devoteam.com
 * @group             : 
 * @last modified on  : 09-06-2021
 * @last modified by  : aleksandra.gonta-kacperska@devoteam.com
**/
@isTest
public class DT_EmailHandlerTest {
    Public Static Final String EMAIL_ADDRESS = 'user@test.pl';
    Public Static Final String LAST_NAME= 'test contact';
    
    @testSetup static void dataInit(){
        DT_DataFactory.createJobOffers(
            1, true, new DT_Job_Offers__c()
        );
        DT_DataFactory.createContacts(
            1, true, new Contact (
                LastName = LAST_NAME,
                Email = EMAIL_ADDRESS
            )
        );
    } 

    @isTest
    public static void testIdInBody(){
        
        // Create a new email, envelope object and an Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.BinaryAttachment inboundAttachment = new Messaging.InboundEmail.BinaryAttachment();
        
        DT_Job_Offers__c jobOffer = [SELECT Id FROM DT_Job_Offers__c LIMIT 1];
        email.subject = 'test';
        email.htmlBody= 'Id: '+jobOffer.Id;
        email.fromAddress = EMAIL_ADDRESS;
        env.fromAddress = EMAIL_ADDRESS;
        
        // set the body of the attachment
        inboundAttachment.body = blob.valueOf('test');
        inboundAttachment.fileName = 'Email_Attachment.txt';
        inboundAttachment.mimeTypeSubType = 'text/plain';
        
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { inboundAttachment }; 
            
        DT_EmailHandler eh = new  DT_EmailHandler();
        eh.handleInboundEmail(email, env );
        
        List <EmailMessage> messages = [
            SELECT Id,RelatedToId 
            FROM EmailMessage 
            WHERE RelatedToId=:jobOffer.Id
        ];
        System.assert(messages.size()>0);
    }
    
    @isTest
    public static  void testIdInSubject(){
        
        // Create a new email, envelope object and an Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.BinaryAttachment inboundAttachment = new Messaging.InboundEmail.BinaryAttachment();
        
        DT_Job_Offers__c jobOffer = [SELECT Id FROM DT_Job_Offers__c LIMIT 1];
        email.subject = 'Id: '+jobOffer.Id;
        email.htmlBody='test';
        email.fromAddress = EMAIL_ADDRESS;
        env.fromAddress = EMAIL_ADDRESS;
        
        // set the body of the attachment
        inboundAttachment.body = blob.valueOf('test');
        inboundAttachment.fileName = 'Email_Attachment.txt';
        inboundAttachment.mimeTypeSubType = 'text/plain';
        
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { inboundAttachment }; 
            
        DT_EmailHandler eh = new  DT_EmailHandler();
        eh.handleInboundEmail(email, env );
        
        List <EmailMessage> messages = [
            SELECT Id,RelatedToId 
            FROM EmailMessage 
            WHERE RelatedToId=:jobOffer.Id
        ];
        System.assert(messages.size()>0);
    }
    
    @isTest
    public static void testJobNameInBody(){
         
        // Create a new email, envelope object and an Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.BinaryAttachment inboundAttachment = new Messaging.InboundEmail.BinaryAttachment();
         
        DT_Job_Offers__c jobOffer = [SELECT Id FROM DT_Job_Offers__c LIMIT 1];
        DT_Job_Offers__c jobName =[SELECT Name FROM DT_Job_Offers__c WHERE Id=:jobOffer.Id LIMIT 1];
        email.subject = 'test';
        email.htmlBody = jobName.Name;
        email.fromAddress = EMAIL_ADDRESS;
        env.fromAddress = EMAIL_ADDRESS;
        
        // set the body of the attachment
        inboundAttachment.body = blob.valueOf('test');
        inboundAttachment.fileName = 'Email_Attachment.txt';
        inboundAttachment.mimeTypeSubType = 'text/plain';
        
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { inboundAttachment }; 
        
        DT_EmailHandler eh = new  DT_EmailHandler();
        eh.handleInboundEmail(email, env );
        
        List <EmailMessage> messages = [SELECT Id,RelatedToId FROM EmailMessage WHERE RelatedToId=:jobOffer.Id];
        System.assert(messages.size()>0);           
    }
}