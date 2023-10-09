/**
 * Created by jowitakozlak on 09.12.2021.
 */

public with sharing class TB_GoogleIntegratorAsync {

    public class InsertEventQueueable implements Queueable, Database.AllowsCallouts{
        SObject recordObject; 
        TB_GoogleIntegratorRetrieverInvocable.MeetingWrapperClass meeting;

        public InsertEventQueueable(SObject recordObject, TB_GoogleIntegratorRetrieverInvocable.MeetingWrapperClass meeting){
            this.recordObject = recordObject;
            this.meeting = meeting;
        }

        public void execute(QueueableContext context) {
            try {
                TB_GoogleIntegrator googleIntegrator = new TB_GoogleIntegrator();
                String responseBody = googleIntegrator.insertEvent(
                    String.valueOf(recordObject.get(meeting.Meeting_Organizer)),
                    String.valueOf(recordObject.get(meeting.Meeting_Attendees)),
                    Datetime.valueOf(recordObject.get(meeting.Meeting_Start)),
                    Datetime.valueOf(recordObject.get(meeting.Meeting_End)),
                    String.valueOf(meeting.Record_Id),
                    String.valueOf(recordObject.get(meeting.Name)),
                    String.valueOf(recordObject.get(meeting.Meeting_Description))
                ).getBody();

                recordObject.put(meeting.Meeting_URL, googleIntegrator.retrieveURL(responseBody));
                recordObject.put(meeting.Event_Id, googleIntegrator.retrieveEventID(responseBody));

                update recordObject;
            } catch (Exception e) {
                insert TB_LogUtils.registerLog(e, recordObject.Id, recordObject.getSObjectType());
            }

        }

    }

    public class DeleteEventQueueable implements Queueable, Database.AllowsCallouts{
        SObject recordObject;
        TB_GoogleIntegratorRetrieverInvocable.MeetingWrapperClass meeting;

        public DeleteEventQueueable(SObject recordObject, TB_GoogleIntegratorRetrieverInvocable.MeetingWrapperClass meeting){
            this.recordObject = recordObject;
            this.meeting = meeting;
        }

        public void execute(QueueableContext context) {
            try{
                TB_GoogleIntegrator googleIntegrator = new TB_GoogleIntegrator();
                googleIntegrator.deleteEvent(
                    String.valueOf(recordObject.get(meeting.Event_Id)),
                    String.valueOf(recordObject.get(meeting.Meeting_Organizer))
                );

                recordObject.put(meeting.Meeting_URL, '');

                update recordObject;
            } catch (Exception e) {
                insert TB_LogUtils.registerLog(e, recordObject.Id, recordObject.getSObjectType());
            }

        }

    }

}