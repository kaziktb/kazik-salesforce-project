/**
 * Created by adriangawryszewski on 12/21/21.
 */

public with sharing class TB_CommunicationEventTriggerHandler extends TB_TriggerHandler {

    public override void afterInsert() {
        sendEvents(Trigger.new);
    }
    
    private void sendEvents(List<sObject> events) {
        System.enqueueJob(new TB_VDOExportQueueable(events));
    }
}