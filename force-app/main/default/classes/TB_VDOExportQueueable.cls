/**
 * Created by adriangawryszewski on 12/21/21.
 */

public with sharing class TB_VDOExportQueueable implements Queueable, Database.AllowsCallouts {

    private List<sObject> events;

    public TB_VDOExportQueueable(List<sObject> events) {
        this.events = events;
    }
    public void execute(QueueableContext context) {
        TB_VDOExportClient exportClient =
                new TB_VDOExportClient(
                        this.events);
        exportClient.sendCommunicationEventsToVDOExport();

    }
}