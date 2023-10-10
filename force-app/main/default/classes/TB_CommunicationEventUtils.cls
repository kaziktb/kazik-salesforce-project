/**
 * Created by adriangawryszewski on 12/16/21.
 */

public with sharing class TB_CommunicationEventUtils {

    private static final String TB_OUTBOUND_COMMUNICATION_EVENT = TB_SObjectUtils.getRecordTypeIdByDevName('TB_Communication_Event__c', 'TB_Outbound');

    public static TB_Communication_Event__c registerOutboundCommunicationEvent(
            String systemReceiving,
            String recordId,
            String objectType,
            String endpoint,
            String requestHeaders,
            String requestBody,
            String responseBody,
            String responseCode,
            String eventKey

    ) {
        TB_Communication_Event__c comEvent = new TB_Communication_Event__c(
                RecordTypeId = TB_OUTBOUND_COMMUNICATION_EVENT,
                TB_Receiving_System__c = systemReceiving,
                TB_Record_Id__c = recordId,
                TB_Object_Type__c = objectType,
                TB_Endpoint_URL__c = endpoint,
                TB_Headers__c = requestHeaders,
                TB_Body__c = requestBody,
                TB_Response_Code__c = responseCode,
                TB_Response_Body__c = responseBody,
                TB_Event_Key__c = eventKey

        );
        return comEvent;
    }


    public static TB_Communication_Event__c addEndpointToEvent(TB_Communication_Event__c event, String endpoint) {
        event.TB_Endpoint_URL__c = endpoint;
        return event;
    }

    public static TB_Communication_Event__c addResponseBody(TB_Communication_Event__c event, String body) {
        event.TB_Response_Body__c = body;
        return event;
    }

    public static TB_Communication_Event__c addResponseCode(TB_Communication_Event__c event, String responseCode) {
        event.TB_Response_Code__c = responseCode;
        return event;
    }

}