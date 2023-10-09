/**
 * @description       : 
 * @author            : aleksandra.gonta-kacperska@devoteam.com
 * @group             :
 * @last modified on  : 09-06-2021
 * @last modified by  : aleksandra.gonta-kacperska@devoteam.com
 * Modifications Log 
 * Ver   Date         Author                                    Modification
 * 1.0   02-15-2021   aleksandra.gonta-kacperska@devoteam.com   Initial Version
**/
global class DT_EmailHandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env) {
        
        String incomingHTMLEmail = email.htmlBody;
        String cleanEmailBody = incomingHTMLEmail.stripHtmlTags();
        

        String identifier ='Id: ';

        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        String relatedRecordId;

        Pattern pId = Pattern.compile('[A-Za-z]{2}\\:\\ \\b[a-z0-9]\\w{4}0\\w{12}|[a-z0-9]\\w{4}0\\w{9}\\b');
        Matcher mId = pId.matcher(cleanEmailBody);

        Pattern pName = Pattern.compile('[0-9]{6}\\-[0-9]{5,6}');
        Matcher mName = pName.matcher(cleanEmailBody);

        Pattern pId2 = Pattern.compile('[A-Za-z]{2}\\:\\ \\b[a-z0-9]\\w{4}0\\w{12}|[a-z0-9]\\w{4}0\\w{9}\\b');
        Matcher mId2 = pId2.matcher(email.subject);

        if (mId.find()) {
            relatedRecordId = mId.group(0).remove(identifier);

        } else if (mName.find()) {
            String name = mName.group(0);
            DT_Job_Offers__c jobOffer = [SELECT Id, Name FROM DT_Job_Offers__c WHERE Name = :name LIMIT 1];
            relatedRecordId = jobOffer.Id;

        } else if (mId2.find()) {
            relatedRecordId = mId2.group(0).remove(identifier);
        }

        List<Contact> contacts = [SELECT Contact.Id FROM CONTACT where Email = :email.fromAddress limit 1];

        EmailMessage message = new EmailMessage(
                FromAddress = email.fromAddress,
                ToAddress = UserInfo.getUserId(),
                Subject = email.subject,
                toIds = contacts.isEmpty() ? null : new String[]{
                        contacts.get(0).Id
                },
                TextBody = cleanEmailBody,
                Status = '0',
                RelatedToId = relatedRecordId
        );

        insert message;

        if (contacts.size() > 0) {
            EmailMessageRelation emr = new EmailMessageRelation();
            emr.emailMessageId = message.Id;
            emr.relationId = message.toIds.get(0);
            System.debug(emr.relationId);
            emr.relationType = 'FromAddress';
            insert emr;
            System.debug(emr);
        }

        if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {

            List<ContentVersion> cvList = new List<ContentVersion>();

            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();

            for (Messaging.InboundEmail.BinaryAttachment binAttach : email.binaryAttachments) {
                ContentVersion testContentInsert = new ContentVersion();
                testContentInsert.Title = binAttach.fileName;
                testContentInsert.VersionData = binAttach.body;
                testContentInsert.PathOnClient = '/' + binAttach.fileName ;
                cvList.add(testContentInsert);

            }
            insert cvList;

            cvList = [select id, ContentDocumentId from ContentVersion WHERE Id in :cvList];

            for (ContentVersion cv : cvList) {
                ContentDocumentLink cl = new ContentDocumentLink();
                cl.ContentDocumentId = cv.ContentDocumentId;
                cl.LinkedEntityId = message.Id;
                cl.ShareType = 'V';
                cl.Visibility = 'AllUsers';
                cdlList.add(cl);

                ContentDocumentLink clparent = new ContentDocumentLink();
                clparent.ContentDocumentId = cv.ContentDocumentId;
                clparent.LinkedEntityId = relatedRecordId;
                clparent.ShareType = 'V';
                clparent.Visibility = 'AllUsers';
                cdlList.add(clparent);
            }
            insert cdlList;
        }
        result.success = true;
        return result;
    }
}