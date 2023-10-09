/**
 * Created by jowitakozlak on 09/12/2021.
 */

public with sharing class TB_GoogleIntegratorRetrieverInvocable {

    @InvocableMethod(label='googleIntegratorRetriever')
    public static void googleIntegratorRetriever(List<MeetingWrapperClass> meetingWrapperClasses){
        for(MeetingWrapperClass meeting : meetingWrapperClasses){

            try {
                SObject recordObject = findRecord(meeting);

                if (String.valueOf(recordObject.get(meeting.Meeting_Status)) == 'create') {
                    System.enqueueJob(new TB_GoogleIntegratorAsync.InsertEventQueueable(recordObject, meeting));
                } else if (String.valueOf(recordObject.get(meeting.Meeting_Status)) == 'cancel') {
                    if (String.valueOf(recordObject.get(meeting.Meeting_URL)) != '') {
                        System.enqueueJob(new TB_GoogleIntegratorAsync.DeleteEventQueueable(recordObject, meeting));
                    }
                }
            } catch (Exception e) {
                insert TB_LogUtils.registerLog(e,TB_GoogleIntegratorRetrieverInvocable.class);
            }
        }
    }

    public static SObject findRecord(MeetingWrapperClass meeting) {
        String objectType = String.valueOf(meeting.Record_Id.getSobjectType());
        Id recordId = meeting.Record_Id;

        List<String> attributes = new List<String>{
            meeting.Meeting_URL, meeting.Event_Id, meeting.Meeting_Attendees,
            meeting.Meeting_Start, meeting.Meeting_End, meeting.Name,
            meeting.Meeting_Description, meeting.Meeting_Status, meeting.Meeting_Organizer
        };

        String fields = '';
        for(String attribute: attributes){
            fields += attribute + ', ';
        }
        fields = fields.substring(0, fields.length()-2);
        String query = 'SELECT Id, ' + fields + ' FROM ' + objectType
            + ' WHERE Id =: recordId';
        SObject recordObject = Database.query(query);

        return recordObject;
    }

    public class MeetingWrapperClass {
        @InvocableVariable
        public Id Record_Id;
        @InvocableVariable
        public String Meeting_URL;
        @InvocableVariable
        public String Meeting_Attendees;
        @InvocableVariable
        public String Meeting_Start;
        @InvocableVariable
        public String Meeting_End;
        @InvocableVariable
        public String Name;
        @InvocableVariable
        public String Meeting_Description;
        @InvocableVariable
        public String Meeting_Status;
        @InvocableVariable
        public String Event_Id;
        @InvocableVariable
        public String Meeting_Organizer;
    }
}