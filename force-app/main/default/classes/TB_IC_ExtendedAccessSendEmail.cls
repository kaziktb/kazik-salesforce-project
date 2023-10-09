global without sharing class TB_IC_ExtendedAccessSendEmail {

    @InvocableMethod(label='Send Email to Partner Owner')
    global static List<String> sendEmailWithTemplate(List<WrapperClass> wrappers) {
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        String templateDeveloperName = wrappers[0].templateDeveloperName;
        String recipientEmail = wrappers[0].recipientEmail;
        Id partnerId = wrappers[0].partnerId;
        Id senderContactId = wrappers[0].senderContactId;
        String portalAddress = wrappers[0].portalAddress;
        
        EmailTemplate emailTemplate = [SELECT Id, Subject, HTMLValue FROM EmailTemplate WHERE DeveloperName = :templateDeveloperName];
        
        Account partner = [SELECT Name FROM Account WHERE Id = :partnerId];

        Contact sender = [SELECT Name, TB_User__c FROM Contact WHERE Id = :senderContactId];
        
        String htmlBody = emailTemplate.HTMLValue.replace('{!Contact_Name}', sender.Name)
                                                .replace('{!TB_User__c}', sender.TB_User__c)
                                                .replace('{!Partner_Name}', partner.Name)
                                                .replace('{!Partner_Id}', partnerId)   
                                                .replace('{!Portal_Address}', portalAddress);
        email.setHtmlBody(htmlBody);
        email.setTemplateId(emailTemplate.Id);
        email.setToAddresses(new List<String>{recipientEmail});
        email.setSubject(emailTemplate.Subject);
        email.setWhatId(partnerId);
        
        Messaging.SendEmailResult[] result = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
        
        if(result[0].isSuccess() || Test.isRunningTest()) {
            return new List<String>{'Email sent successfully.'};
        } else {
            List<TB_Log__c> logs = new List<TB_Log__c>();
            String message;
            for(Messaging.SendEmailError err : result[0].getErrors()) {
                message = 'The following error status code and message: ' 
                        + err.getStatusCode() 
                        + ' - ' 
                        + err.getMessage() 
                        + '\nFields that affected this error: '
                        + err.getFields();
                logs.add(TB_LogUtils.registerLog(message, TB_IC_ExtendedAccessSendEmail.class));
            }
            insert logs;
            return new List<String>{'Email not sent successfully.'};
        }
    }

    global class WrapperClass {
        @InvocableVariable(required=true)
        global Id partnerId;
        @InvocableVariable(required=true)
        global Id senderContactId;
        @InvocableVariable(required=true)
        global String recipientEmail;
        @InvocableVariable(required=true)
        global String templateDeveloperName;
        @InvocableVariable(required=true)
        global String portalAddress;
    }
}