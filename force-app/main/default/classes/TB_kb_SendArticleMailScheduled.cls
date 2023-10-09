public with sharing class TB_kb_SendArticleMailScheduled implements Schedulable {
    private List<Knowledge__kav> getArticleOwnersInactiveFor180Days() {
        TB_Knowledge_Article_Inactivity_Days__c inactiveDaysCS = TB_Knowledge_Article_Inactivity_Days__c.getInstance();
        Integer daysOfInactivity = Integer.valueOf(inactiveDaysCS.TB_KB_Days_Of_Inactivity__c);
        return [SELECT Title, 
                              TB_Knowledge_Category__r.Name,
                              TB_Last_Activity_Date__c,
                              TB_Days_Of_Inactivity__c,
                              UrlName,
                              OwnerId
                              FROM Knowledge__kav 
                              WHERE PublishStatus = 'Online'
                              AND TB_Days_Of_Inactivity__c >=: daysOfInactivity];
     }
 
     public void execute(SchedulableContext sc) {
         try {
             List<Knowledge__kav> relatedArticles = getArticleOwnersInactiveFor180Days();
             Map<Id, List<Knowledge__kav>> ownerToArticlesMap = new Map<Id, List<Knowledge__kav>>();
             Set<Id> contactIds = new Set<Id>();
 
             for (Knowledge__kav article : relatedArticles) {
                 if (!ownerToArticlesMap.containsKey(article.OwnerId)) {
                     ownerToArticlesMap.put(article.OwnerId, new List<Knowledge__kav>());
                     contactIds.add(article.OwnerId);
                 }
                 ownerToArticlesMap.get(article.OwnerId).add(article);
             }
 
             Map<Id, Contact> contactMap = new Map<Id, Contact>();
             for (Contact con : [SELECT Id, 
                                        TB_User__c, 
                                        TB_x_Work_Email_Tech__c 
                                        FROM Contact WHERE 
                                        TB_User__c IN :contactIds]) {
                 contactMap.put(con.TB_User__c, con);
             }
 
             Map<Id,String> emailTemplatesMap = new Map<Id,String>();
             Map<String, Id> emailTemplateIdsMap = new Map<String, Id>();
 
             List<EmailTemplate> emailTemplates = [SELECT Id, Name, DeveloperName
                                                       FROM EmailTemplate 
                                                       WHERE DeveloperName = 'TB_Knowledge_Article_Is_Inactive_PL'
                                                       OR DeveloperName = 'TB_Knowledge_Article_Is_Inactive_EN'];
         
                 if(emailTemplates.isEmpty()) {
                     insert TB_LogUtils.registerLog('No EmailTemplate found. SHould be TB_Knowledge_Article_Is_Inactive_PL or TB_Knowledge_Article_Is_Inactive_EN', TB_kb_SendArticleMailScheduled.class);
                     return;
                 }
                 for (EmailTemplate template : emailTemplates) {
                         emailTemplateIdsMap.put(template.DeveloperName, template.Id);
                 }
         
                 Map<Id, Id> userToEmailTemplateIdMap = new Map<Id, Id>();
         
                 for (User usr : [SELECT Id, toLabel(LanguageLocaleKey) FROM User WHERE Id IN :contactIds]) {
                     String templateDeveloperName = usr.LanguageLocaleKey == 'Polish' 
                     || usr.LanguageLocaleKey == 'Polski' 
                     || usr.LanguageLocaleKey?.toLowerCase() == 'pl' 
                     ? 'TB_Knowledge_Article_Is_Inactive_PL' 
                     : 'TB_Knowledge_Article_Is_Inactive_EN';
         
                     emailTemplatesMap.put(usr.Id, templateDeveloperName);
                     Id emailTemplateId = emailTemplateIdsMap.get(templateDeveloperName);
                     userToEmailTemplateIdMap.put(usr.Id, emailTemplateId);
                 }
 
             List<TB_SendMultipleMailWrapper> mailWrappers = new List<TB_SendMultipleMailWrapper>();
 
             for (Id ownerId : ownerToArticlesMap.keySet()) {
                 List<Knowledge__kav> articles = ownerToArticlesMap.get(ownerId);
                 Contact articleOwnerContact = contactMap.get(ownerId);
 
                 if (articleOwnerContact != null && articleOwnerContact.TB_x_Work_Email_Tech__c != null) {
                     TB_SendMailWrapper sendMailWrapper = new TB_SendMailWrapper();
                     sendMailWrapper.recipientEmail = articleOwnerContact.TB_x_Work_Email_Tech__c;
                     sendMailWrapper.templateDeveloperName = emailTemplatesMap.get(ownerId);
                     sendMailWrapper.contactId = articleOwnerContact.Id;
                     sendMailWrapper.replyToEmail = 'noreply-student@swps.edu.pl';
                     sendMailWrapper.senderEmail = 'noreply-student@swps.edu.pl';
                     sendMailWrapper.templateId = userToEmailTemplateIdMap.get(ownerId);
 
                     TB_SendMultipleMailWrapper multipleMailWrapper = new TB_SendMultipleMailWrapper();
                     multipleMailWrapper.sendMailWrappers = new List<TB_SendMailWrapper>{sendMailWrapper};
 
                     mailWrappers.add(multipleMailWrapper);
                 }
             }
 
             TB_GenericSendMultipleMails.sendMultipleMails(mailWrappers);
 
         } catch (Exception e) {
             throw new AuraHandledException(
                 TB_vu_Utils.registerLog(e.getMessage(),
                 TB_kb_SendArticleMailScheduled.class.getName(), 
                 e.getStackTraceString(),
                 ''));
         }
     }
}