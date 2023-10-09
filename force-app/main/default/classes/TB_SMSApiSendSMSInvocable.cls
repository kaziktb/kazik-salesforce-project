public with sharing class TB_SMSApiSendSMSInvocable {

    @InvocableMethod(label='sendSMS')
    public static void sendSMS(List<SendSMSWrapperClass> sendSMSWrapperClasses) {
        System.enqueueJob(new TB_SendSMSQueueable(sendSMSWrapperClasses));
    }

    public with sharing class TB_SendSMSQueueable implements Queueable, Database.AllowsCallouts{
        List<SendSMSWrapperClass> sendSMSWrapperClasses
                = new List<TB_SMSApiSendSMSInvocable.SendSMSWrapperClass>();

        public TB_SendSMSQueueable(List<SendSMSWrapperClass> sendSMSWrapperClasses){
            this.sendSMSWrapperClasses = sendSMSWrapperClasses;
        }

        public void execute(QueueableContext context) {
            List<TB_Log__c> logs = new List<TB_Log__c>();

            try{
                TB_SmsApiIntegrator smsApiIntegrator = new TB_SmsApiIntegrator();
                for(SendSMSWrapperClass sendSMSWrapperClass : sendSMSWrapperClasses){
                    smsApiIntegrator.sendSMS(
                            sendSMSWrapperClass.phoneNumbers,
                            sendSMSWrapperClass.textMessage,
                            sendSMSWrapperClass.sender
                    );
                }
            } catch (Exception e) { 
                logs.add(TB_LogUtils.registerLog(e, TB_SendSMSQueueable.class));
            }

            if (!logs.isEmpty()) {
                insert logs;
            }
        }

    }

    public class SendSMSWrapperClass {
        @InvocableVariable
        public String phoneNumbers;
        @InvocableVariable
        public String textMessage;
        @InvocableVariable
        public String sender;
    }

}