@IsTest
private class TB_vu_MeetingAdvisorsAppointmentTest {
    private static final String STUDENT_LAST_NAME = 'StudentLastName';
    private static final String ADVISOR_LAST_NAME = 'AdvisorLastName';
    private static final String SWPS_STUDENT_PROFILE = 'SWPS Student';
    private static final String ADMIN_PROFILE = 'System Administrator';
    private static final String ADMIN_ROLE = 'Admin';
    private static final String EXPRESSION_TEST = 'Test';
    private static final String SCHEDULED_TYPE = 'Scheduled';
    private static final String INVALID_PARAM = 'INVALID';
    private static final String AVAILABLE_DATE_EVENT_TYPE = 'Available Date';
    private static final String LABEL_SFAL_TOPIC = 'Application documents';

    @TestSetup
    static void testSetup(){
        User advisorUser = TB_DataFactory.createUser(ADMIN_PROFILE, ADMIN_ROLE, false);
        advisorUser.FirstName = EXPRESSION_TEST;
        advisorUser.LastName = ADVISOR_LAST_NAME;
        insert advisorUser;
        
        System.runAs(advisorUser)
        {
            Contact studentContact = new Contact(LastName = STUDENT_LAST_NAME);
            Contact advisorContact = new Contact(LastName = ADVISOR_LAST_NAME);
            insert new List<Contact>
            {
                    studentContact,
                    advisorContact
            };
    
            User studentUser = TB_DataFactory.createUser(SWPS_STUDENT_PROFILE, false);
            studentUser.FirstName = EXPRESSION_TEST;
            studentUser.LastName = STUDENT_LAST_NAME;
            studentUser.ContactId = studentContact.Id;
            insert studentUser;
    
            studentContact.TB_User__c = studentUser.Id;
            advisorContact.TB_User__c = advisorUser.Id;
            update new List<Contact>
            {
                    studentContact,
                    advisorContact
            };
    
            sfal__Availability__c availability = new sfal__Availability__c(
                    Name = EXPRESSION_TEST,
                    OwnerId = advisorUser.Id,
                    sfal__AppointmentType__c = SCHEDULED_TYPE
            );
            insert availability;
            sfal__AppointmentLocation__c location = new sfal__AppointmentLocation__c(Name = EXPRESSION_TEST);
            insert location;
            sfal__AvailabilityLocation__c availabilitylocation = new sfal__AvailabilityLocation__c(
                    sfal__Location__c = location.Id,
                    sfal__Availability__c = availability.Id
            );
            insert availabilitylocation;
    
            List<Event> events = TB_TestDataFactory.createEvents(
                    3,
                    advisorContact.Id,
                    availability.Id,
                    advisorUser.Id,
                    false
            );
    
            for(Event e : events)
            {
                e.RecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(TB_vu_Constants.ADVISING_TIME_EVENT_RECORD_TYPE_DEVELOPER_NAME).getRecordTypeId();
                e.Type = AVAILABLE_DATE_EVENT_TYPE;
            }
            insert events;
    
            sfal__Topic__c parentTopic = new sfal__Topic__c(
                    Name = EXPRESSION_TEST,
                    sfal__Label__c = LABEL_SFAL_TOPIC
            );
            insert parentTopic;
    
            sfal__Topic__c topic = new sfal__Topic__c(
                    Name = EXPRESSION_TEST,
                    sfal__Label__c = LABEL_SFAL_TOPIC,
                    sfal__ParentTopic__c = parentTopic.Id
            );
            sfal__Topic__c subtopic = new sfal__Topic__c(
                    Name = EXPRESSION_TEST,
                    sfal__Label__c = LABEL_SFAL_TOPIC
            );
            insert new List<sfal__Topic__c>
            {
                    topic,
                    subtopic
            };
    
            Case meetingCase = TB_TestDataFactory.createCases(
                    1,
                    EXPRESSION_TEST,
                    studentContact.Id,
                    false
            )[0];
            meetingCase.sfal__Topic__c = topic.Id;
            meetingCase.sfal__Subtopic__c = subtopic.Id;
            meetingCase.TB_Description_Rich_Text__c = EXPRESSION_TEST;
            meetingCase.OwnerId = advisorUser.Id;
            meetingCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(TB_vu_Constants.MEETING_CASE_RECORD_TYPE_DEVELOPER_NAME).getRecordTypeId();
            insert meetingCase;
        }
    }

    @isTest
    static void shouldReturnAdvisorName(){
        Id advisorId = [SELECT Id FROM User WHERE LastName =: ADVISOR_LAST_NAME].Id;
        String result;

        Test.startTest();
        result = TB_vu_MeetingAdvisorsAppointment.getAdvisorName(advisorId);
        Test.stopTest();

        Assert.areEqual(result, ADVISOR_LAST_NAME, 'Advisor name doesnt match with expected value');
    }

    @isTest
    static void throwAnError_whenInvalidIdPassedToGetAdvisorName(){
        Boolean isException = false;
        String result;

        Test.startTest();
        try {
            result = TB_vu_MeetingAdvisorsAppointment.getAdvisorName(INVALID_PARAM);
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        Assert.isTrue(isException);
    }
    
    @isTest
    static void shouldReturnAvailableDaysForAdvisor(){
        Id advisorId = [SELECT Id FROM User WHERE LastName =: ADVISOR_LAST_NAME].Id;
        List<TB_vu_MeetingAdvisorsAppointment.AvailabilityWrapper> result = new List<TB_vu_MeetingAdvisorsAppointment.AvailabilityWrapper>();

        Test.startTest();
        result = TB_vu_MeetingAdvisorsAppointment.getAvailableDaysForAdvisor(advisorId);
        Test.stopTest();

        Assert.isTrue(result.size() == 3);
    }

    @isTest
    static void throwAnError_whenInvalidIdPassedToGetAvailableDaysForAdvisor(){
        Boolean isException = false;
        List<TB_vu_MeetingAdvisorsAppointment.AvailabilityWrapper> result = new List<TB_vu_MeetingAdvisorsAppointment.AvailabilityWrapper>();

        Test.startTest();
        try {
            result = TB_vu_MeetingAdvisorsAppointment.getAvailableDaysForAdvisor(INVALID_PARAM);
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        Assert.isTrue(isException);
    }

    @isTest
    static void shouldSetMeetingAppointmentWithAdvisor(){
        Case meetingCase = [SELECT Id, OwnerId, Subject FROM Case WHERE Subject =: EXPRESSION_TEST+'0' LIMIT 1];
        Event meetingEvent = [SELECT Id FROM Event WHERE OwnerId =: meetingCase.OwnerId LIMIT 1];
        sfal__AppointmentLocation__c location = [SELECT Id FROM sfal__AppointmentLocation__c WHERE Name =: EXPRESSION_TEST LIMIT 1];
        User studentUser = [SELECT Id, LastName FROM User WHERE LastName =: STUDENT_LAST_NAME LIMIT 1];
        Boolean result;

        Test.startTest();
        System.runAs(studentUser) {
            result = TB_vu_MeetingAdvisorsAppointment.setMeetingWithAdvisor(meetingCase.Id, meetingEvent.Id, location.Id);
        }
        Test.stopTest();

        Assert.isTrue(result);
        Assert.isTrue([SELECT Id FROM sfal__Appointment__c WHERE Name =: meetingCase.Subject AND OwnerId =: meetingCase.OwnerId].size() == 1);
        Assert.isTrue([SELECT Id FROM sfal__AppointmentAttendee__c WHERE sfal__AdviseeRecord__c =: meetingCase.Id].size() == 2);
        Assert.isTrue([SELECT Id FROM Event WHERE OwnerId =: studentUser.Id AND IsVisibleInSelfService = TRUE AND ShowAs =: TB_vu_Constants.BUSY_EVENT_SHOW_AS AND Type =: TB_vu_Constants.MEETING_EVENT_TYPE].size() == 1);
    }

    @isTest
    static void shouldNotSetMeetingAppointmentWithAdvisorBecauseEventStartDateTimeIsLessThan30MiutesFromNow(){
        Case meetingCase = [SELECT Id, OwnerId, Subject FROM Case WHERE Subject =: EXPRESSION_TEST+'0' LIMIT 1];
        Event meetingEvent = [SELECT Id, StartDateTime FROM Event WHERE OwnerId =: meetingCase.OwnerId LIMIT 1];
        meetingEvent.StartDateTime = Datetime.now().addMinutes(15);
        update meetingEvent;
        sfal__AppointmentLocation__c location = [SELECT Id FROM sfal__AppointmentLocation__c WHERE Name =: EXPRESSION_TEST LIMIT 1];
        User studentUser = [SELECT Id, LastName FROM User WHERE LastName =: STUDENT_LAST_NAME LIMIT 1];
        Boolean result;

        Test.startTest();
        System.runAs(studentUser) {
            result = TB_vu_MeetingAdvisorsAppointment.setMeetingWithAdvisor(meetingCase.Id, meetingEvent.Id, location.Id);
        }
        Test.stopTest();

        Assert.isFalse(result);
    }

    @isTest
    static void shouldNotSetMeetingAppointmentWithAdvisorBecauseEventIsNoMoreAvailable(){
        Case meetingCase = [SELECT Id, OwnerId, Subject FROM Case WHERE Subject =: EXPRESSION_TEST+'0' LIMIT 1];
        Event meetingEvent = [SELECT Id, IsVisibleInSelfService FROM Event WHERE OwnerId =: meetingCase.OwnerId LIMIT 1];
        meetingEvent.IsVisibleInSelfService = false;
        update meetingEvent;
        sfal__AppointmentLocation__c location = [SELECT Id FROM sfal__AppointmentLocation__c WHERE Name =: EXPRESSION_TEST LIMIT 1];
        User studentUser = [SELECT Id, LastName FROM User WHERE LastName =: STUDENT_LAST_NAME LIMIT 1];
        Boolean result;

        Test.startTest();
        System.runAs(studentUser) {
            result = TB_vu_MeetingAdvisorsAppointment.setMeetingWithAdvisor(meetingCase.Id, meetingEvent.Id, location.Id);
        }
        Test.stopTest();

        Assert.isFalse(result);
    }

    @isTest
    static void throwAnError_whenInvalidIdsPassedToSetMeetingAppointmentWithAdvisor(){
        Boolean isException = false;
        Boolean result;

        Test.startTest();
        try {
            result = TB_vu_MeetingAdvisorsAppointment.setMeetingWithAdvisor(INVALID_PARAM,INVALID_PARAM,INVALID_PARAM);
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();

        Assert.isTrue(isException);
    }
}