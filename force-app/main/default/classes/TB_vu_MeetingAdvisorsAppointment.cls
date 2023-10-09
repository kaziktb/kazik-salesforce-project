public without sharing class TB_vu_MeetingAdvisorsAppointment {
    private static final String AVAILABLE_DATE_EVENT_TYPE = 'Available Date';
    private static final String ATTENDEE_APPOINTMENT_ATTENDEE_ROLE = 'Attendee';
    private static final String ORGANIZER_APPOINTMENT_ATTENDEE_ROLE = 'Organizer';
    private static final String ATTENDING_APPOINTMENT_ATTENDEE_STATUS = 'Attending';
    private static final String HOURS_AND_MINUTES_TIME_FORMAT = 'HH:mm';
    private static final Integer EVENT_OFFSET_IN_MINUTES = 30;

    public class AvailabilityWrapper {
        @AuraEnabled 
        public Id eventId;
        @AuraEnabled 
        public Date meetingDate;
        @AuraEnabled 
        public String meetingStartTime;
        @AuraEnabled 
        public String meetingEndTime;
        @AuraEnabled 
        public List<LocationWrapper> locations;

        public AvailabilityWrapper(
            Id eventId, 
            Date meetingDate, 
            String meetingStartTime,
            String meetingEndTime,
            List<LocationWrapper> locations
        ) {
            this.eventId = eventId;
            this.meetingDate = meetingDate;
            this.meetingStartTime = meetingStartTime;
            this.meetingEndTime = meetingEndTime;
            this.locations = locations;
        }
    }

    public class LocationWrapper {
        @AuraEnabled 
        public Id id;
        @AuraEnabled 
        public String name;

        public LocationWrapper(
            Id id, 
            String name
        ) {
            this.id = id;
            this.name = name;
        }
    }

    @AuraEnabled
    public static string getAdvisorName(Id advisorId){
        try {
            return [SELECT Id, TB_x_Contact_Name__c FROM Contact WHERE TB_User__c =: advisorId LIMIT 1].TB_x_Contact_Name__c;
        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_MeetingAdvisorsAppointment.class.getName(),e.getStackTraceString(), advisorId));
        }
    }

    @AuraEnabled
    public static List<AvailabilityWrapper> getAvailableDaysForAdvisor(Id advisorId){
        try {
            List<AvailabilityWrapper> toReturn = new List<AvailabilityWrapper>();
            Datetime nowWithOffset = Datetime.now().addMinutes(EVENT_OFFSET_IN_MINUTES);
            
            List<Id> whatIds = new List<Id>();
            List<Event> availableEvents = [
                SELECT 
                    Id, 
                    StartDateTime, 
                    EndDateTime,
                    WhatId 
                FROM Event 
                WHERE 
                    OwnerId =: advisorId AND 
                    RecordTypeId =: Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(TB_vu_Constants.ADVISING_TIME_EVENT_RECORD_TYPE_DEVELOPER_NAME).getRecordTypeId() AND
                    Type =: AVAILABLE_DATE_EVENT_TYPE AND
                    IsVisibleInSelfService = TRUE AND
                    StartDateTime >: nowWithOffset AND
                    IsRecurrence = FALSE
                ORDER BY StartDateTime];
            for(Event e : availableEvents){
                whatIds.add(e.WhatId);
            }
            Map<Id,List<LocationWrapper>> whatIdsAssignedToLocations = getAvailableLocationsForEvent(whatIds);
            for(Event e : availableEvents){
                toReturn.add(new AvailabilityWrapper(
                    e.Id,
                    e.StartDateTime.date(),
                    e.StartDateTime.format(HOURS_AND_MINUTES_TIME_FORMAT), 
                    e.EndDateTime.format(HOURS_AND_MINUTES_TIME_FORMAT),
                    whatIdsAssignedToLocations.get(e.WhatId)
                ));
            }
            
            return toReturn;
        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_MeetingAdvisorsAppointment.class.getName(),e.getStackTraceString(), advisorId));
        }
    }

    private static Map<Id,List<LocationWrapper>> getAvailableLocationsForEvent(List<Id> whatIds){
        Map<Id,List<LocationWrapper>> toReturn = new Map<Id,List<LocationWrapper>>();
        for(sfal__AvailabilityLocation__c al: [
            SELECT sfal__Location__c,
                sfal__Location__r.Name, 
                sfal__Availability__c 
            FROM sfal__AvailabilityLocation__c 
            WHERE sfal__Availability__c IN: whatIds]){
                if (toReturn.get(al.sfal__Availability__c) == null) {
                    toReturn.put(al.sfal__Availability__c, new List<LocationWrapper>{new LocationWrapper(
                        al.sfal__Location__c,
                        al.sfal__Location__r.Name
                    )});
                } else {
                    toReturn.get(al.sfal__Availability__c).add(new LocationWrapper(
                        al.sfal__Location__c,
                        al.sfal__Location__r.Name
                    ));
                }
            }
        return toReturn;
    }

    @AuraEnabled
    public static Boolean setMeetingWithAdvisor(Id caseId, Id eventId, Id locationId){
        try {
            if(eventStillAvailable(eventId)){    
                Event event = [
                    SELECT
                        Id,
                        StartDateTime,
                        IsVisibleInSelfService
                    FROM Event
                    WHERE Id =: eventId];
    
                event.IsVisibleInSelfService = false;
                update event;

                sfal__AppointmentLocation__c location = [
                    SELECT
                        Id,
                        Name
                    FROM sfal__AppointmentLocation__c 
                    WHERE Id =: locationId];

                Case meetingCase = [
                    SELECT
                        Status,
                        sfal__Location__c,
                        TB_Meeting_DateTime__c,
                        TB_Description_Rich_Text__c
                    FROM Case
                    WHERE Id =: caseId];
        
                meetingCase.Status = TB_vu_Constants.MEETING_BOOKED_CASE_STATUS;
                meetingCase.sfal__Location__c = location.Name;
                meetingCase.TB_Meeting_DateTime__c = event.startDatetime;
                update meetingCase;
    
                insertAppointmentRecords(caseId, eventId, locationId);

                return true;
            }
            else return false;

        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_MeetingAdvisorsAppointment.class.getName(),e.getStackTraceString(), caseId));
        }
    }
    
    @future
    private static void insertAppointmentRecords(Id caseId, Id eventId, Id locationId) {
        Case meetingCase = [
            SELECT
                Id,
                Description,
                Subject,
                Status,
                OwnerId,
                sfal__Topic__c,
                sfal__Topic__r.sfal__ParentTopic__c,
                sfal__Topic__r.sfal__ParentTopic__r.sfal__Label__c,
                sfal__Topic__r.sfal__Label__c,
                sfal__Subtopic__c,
                sfal__Subtopic__r.sfal__Label__c,
                Contact.TB_x_Contact_Name__c,
                Contact.TB_User__c
            FROM Case
            WHERE Id =: caseId];
    
        Event event = [
            SELECT
                Id,
                StartDateTime,
                EndDateTime,
                IsVisibleInSelfService
            FROM Event
            WHERE Id =: eventId];

        sfal__AppointmentLocation__c location = [
            SELECT
                Id,
                Name
            FROM sfal__AppointmentLocation__c 
            WHERE Id =: locationId];

        try {
            sfal__Appointment__c appointment = new sfal__Appointment__c(
                RecordTypeId = Schema.SObjectType.sfal__Appointment__c.getRecordTypeInfosByDeveloperName().get(TB_vu_Constants.ADVISING_EVENT_APPOINTMENT_RECORD_TYPE_DEVELOPER_NAME).getRecordTypeId(),
                Name = meetingCase.Subject,
                sfal__RelatedCase__c = meetingCase.Id,
                OwnerId = meetingCase.OwnerId,
                sfal__RelatedTopic__c = meetingCase.sfal__Topic__r.sfal__ParentTopic__c,
                sfal__RelatedSubtopic__c = meetingCase.sfal__Topic__c,
                sfal__Topic__c = meetingCase.sfal__Topic__r.sfal__ParentTopic__r.sfal__Label__c,
                sfal__Subtopic__c = meetingCase.sfal__Subtopic__r.sfal__Label__c,
                sfal__Description__c = meetingCase.Description,
                sfal__StartDateTime__c = event.StartDateTime,
                sfal__EndDateTime__c = event.EndDateTime,
                sfal__AppointmentLocation__c = location.Id,
                sfal__Location__c = location.Name
            );
            
            insert appointment;

            sfal__AppointmentAttendee__c appointmentForStudent = new sfal__AppointmentAttendee__c(
                sfal__Appointment__c = appointment.Id,
                sfal__Attendee__c = UserInfo.getUserId(),
                sfal__Role__c = ATTENDEE_APPOINTMENT_ATTENDEE_ROLE,
                sfal__Status__c = ATTENDING_APPOINTMENT_ATTENDEE_STATUS,
                sfal__AdviseeRecord__c = meetingCase.Id
            );
    
            sfal__AppointmentAttendee__c appointmentForOrganizer = new sfal__AppointmentAttendee__c(
                sfal__Appointment__c = appointment.Id,
                sfal__Attendee__c = meetingCase.OwnerId,
                sfal__Role__c = ORGANIZER_APPOINTMENT_ATTENDEE_ROLE,
                sfal__Status__c = ATTENDING_APPOINTMENT_ATTENDEE_STATUS,
                sfal__AdviseeRecord__c = meetingCase.Id
            );

            insert new List<sfal__AppointmentAttendee__c>{
                appointmentForStudent,
                appointmentForOrganizer
            };

            insert new Event(
                IsVisibleInSelfService = true,
                OwnerId = meetingCase.Contact.TB_User__c,
                Subject = meetingCase.Contact.TB_x_Contact_Name__c + ' (' + meetingCase.Subject + ')',
                WhatId = appointmentForOrganizer.Id,
                StartDateTime = event.StartDateTime,
                EndDateTime = event.EndDateTime,
                ShowAs = TB_vu_Constants.BUSY_EVENT_SHOW_AS,
                Type = TB_vu_Constants.MEETING_EVENT_TYPE,
                Description = meetingCase.Description,
                Location = location.Name,
                TB_Case__c = meetingCase.Id
            );
        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_MeetingAdvisorsAppointment.class.getName(),e.getStackTraceString(), caseId));
        }
    }

    private static Boolean eventStillAvailable(Id eventId){
        Datetime nowWithOffset = Datetime.now().addMinutes(EVENT_OFFSET_IN_MINUTES);
        
        Event eventToCheck = [
            SELECT 
                StartDateTime, 
                IsVisibleInSelfService
            FROM Event 
            WHERE Id =: eventId
            LIMIT 1];

        return eventToCheck.IsVisibleInSelfService && eventToCheck.StartDateTime > nowWithOffset;
    }
}