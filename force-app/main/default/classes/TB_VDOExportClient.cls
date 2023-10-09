/**
 * Created by adriangawryszewski on 2/1/22.
 */

public with sharing class TB_VDOExportClient {
    private List<sObject> events;


    public TB_VDOExportClient(List<sObject> events) {
        this.events = events;
    }

    public void sendCommunicationEventsToVDOExport() {

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setEndpoint('callout:VDO_Export_Proxy');
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');

        List<String> body = TB_SObjectUtils.getListStringsFromObjectList(
                this.events, TB_Communication_Event__c.TB_Body__c);

        req.setBody(
                JSON.serialize(body)
        );
        try {
            res = http.send(req);
            
            upsert enrichEventsWithOutboundInfo((List<TB_VDOExportClient.ResponseItem>) JSON.deserialize(res.getBody(), List<TB_VDOExportClient.ResponseItem>.class), 'VDO_Export_Proxy') TB_Event_Key__c;
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e, TB_VDOExportClient.class);
        }
    }

    private List<TB_Communication_Event__c> enrichEventsWithOutboundInfo(List<ResponseItem> responseItems, String endpoint) {
        List<TB_Communication_Event__c> newEvents = new List<TB_Communication_Event__c>();
        for (ResponseItem respItem : responseItems) {
            TB_Communication_Event__c newEvent = new TB_Communication_Event__c(
                    TB_Event_Key__c = respItem.eventId
            );
            newEvent = TB_CommunicationEventUtils.addEndpointToEvent(newEvent, endpoint);
            newEvent = TB_CommunicationEventUtils.addResponseBody(newEvent, JSON.serialize(respItem.errors));
            newEvent = TB_CommunicationEventUtils.addResponseCode(newEvent, respItem.status);
            newEvents.add(newEvent);

        }
        return newEvents;
    }

    private class ResponseItem {
        String status;
        String statusSaveDB;
        String eventId;
        String candidateId;
        String applicationId;
        List<String> errors;
    }
}