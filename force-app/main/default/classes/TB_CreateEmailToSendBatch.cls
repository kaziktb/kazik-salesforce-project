/**
 * Created by Aneta on 07/06/2021.
 */

public with sharing class TB_CreateEmailToSendBatch implements Database.Batchable<TB_CreateMailWrapper>, Database.Stateful {
    List<TB_CreateMailWrapper> emailMessages = new List<TB_CreateMailWrapper>();
    final Id emailTemplateId;

    public TB_CreateEmailToSendBatch (List<TB_CreateMailWrapper> messages, Id emailTemplateId){
        this.emailTemplateId = emailTemplateId;
        this.emailMessages = messages;
    }

    public Iterable<TB_CreateMailWrapper> start(Database.BatchableContext context) {
        return emailMessages;
    }
    
    public void execute(Database.BatchableContext context, List<TB_CreateMailWrapper> messages) {
        TB_CreateEmailToSendController.sendSingleEmailMessages(messages);
    }

    public void finish (Database.BatchableContext context) {
        TB_CreateEmailToSendController.deleteTemplateAfterSendMails(this.emailTemplateId);
    }
}