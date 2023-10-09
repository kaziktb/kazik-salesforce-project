/**
 * Created by jowitakozlak on 22/06/2021.
 */
public with sharing class TB_GenericSendMultipleMailsBatch implements Database.Batchable<TB_AuraGenericSendMail.WrapperClass>, Database.Stateful {
    List<TB_AuraGenericSendMail.WrapperClass> allWrapperClasses = new List<TB_AuraGenericSendMail.WrapperClass>();

    public TB_GenericSendMultipleMailsBatch(List<TB_AuraGenericSendMail.WrapperClass> allWrapperClasses){
        this.allWrapperClasses = allWrapperClasses;
    }

    public List<TB_AuraGenericSendMail.WrapperClass> start(Database.BatchableContext context) {
        return allWrapperClasses;
    }

    public void execute(Database.BatchableContext context, List<TB_AuraGenericSendMail.WrapperClass> wrapperClasses) {
        TB_AuraGenericSendMail.sendMail(wrapperClasses);
    }

    public void finish (Database.BatchableContext param1){
    }

}