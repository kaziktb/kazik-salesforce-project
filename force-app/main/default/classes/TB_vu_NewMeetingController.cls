public without sharing class TB_vu_NewMeetingController {
    private static final String LANG_PL = 'PL';
    private static final String LANG_EN = 'EN';
    private static final String NEW_STATUS = 'New';
    private static final String MEETING_BOOKED_STATUS = 'Meeting_Booked';
    private static final List<String> AVAILABILITY_SOURCES_LIMIT_1_QUERY = new List<String>{
        'Salesforce_CSS', 'Salesforce_CWiA'
    };

    @AuraEnabled
    public static String getRecordTypeId(String developerName){
        try {
            return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(developerName).getRecordTypeId();
        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_CasesController.class.getName(),e.getStackTraceString(),''));
        }
    }

    @AuraEnabled
    public static List<String> sendCase(CaseParameters caseParameters){
        if(caseParameters == null){
            AuraHandledException e = new AuraHandledException('Expected caseParameters, got null value');
            e.setMessage('Expected caseParameters, got null value');
            throw e;
        }
        if(String.isBlank(caseParameters.topicId) || !(caseParameters.topicId instanceof Id) || ((Id)caseParameters.topicId).getSobjectType() != sfal__Topic__c.getSObjectType()){
            AuraHandledException e = new AuraHandledException('Expected topicId (Id), got an empty String or invalid type of Id');
            e.setMessage('Expected topicId (Id), got an empty String or invalid type of Id');
            throw e;
        }
        if(String.isBlank(caseParameters.studyNameId) || !(caseParameters.studyNameId instanceof Id) || ((Id)caseParameters.studyNameId).getSobjectType() != hed__Program_Enrollment__c.getSObjectType()){
            AuraHandledException e = new AuraHandledException('Expected studyNameId (Id), got an empty String or invalid type of Id');
            e.setMessage('Expected studyNameId (Id), got an empty String or invalid type of Id');
            throw e;
        }
        if(String.isBlank(caseParameters.subject) || (caseParameters.subject).length() > 255){
            AuraHandledException e = new AuraHandledException('Expected subject, got null value or subject length is greater than 255');
            e.setMessage('Expected subject, got null value or subject length is greater than 255');
            throw e;
        }
        if(String.isBlank(caseParameters.description) || (caseParameters.description).length() > 10000){
            AuraHandledException e = new AuraHandledException('Expected description, got null value or description length is greater than 10000');
            e.setMessage('Expected description, got null value or description length is greater than 10000');
            throw e;
        }
        if(String.isBlank(caseParameters.language) || !(caseParameters.language == LANG_PL || caseParameters.language == LANG_EN)){
            AuraHandledException e = new AuraHandledException('Expected language, got an empty String or invalid language code');
            e.setMessage('Expected language, got an empty String or invalid language code');
            throw e;
        }
        if(String.isBlank(caseParameters.contactId) || !(caseParameters.contactId instanceof Id) || ((Id)caseParameters.contactId).getSobjectType() != Contact.getSObjectType()){
            AuraHandledException e = new AuraHandledException('Expected contactId (Id), got an empty String or invalid type of Id');
            e.setMessage('Expected contactId (Id), got an empty String or invalid type of Id');
            throw e;
        }
        try {
            List<String> toReturn = new List<String>();

            Id accountIdLinkedWithContact =
                    [SELECT
                            Id,
                            AccountId
                    FROM
                            Contact
                    WHERE
                            Id =: caseParameters.contactId].AccountId;

            String languageToCase = caseParameters.language != LANG_PL ? 'EN_US' : LANG_PL;

            Case newCase = new Case(
                    TB_Program_Enrollment__c = caseParameters.studyNameId,
                    sfal__Topic__c = caseParameters.topicId,
                    Subject = caseParameters.subject,
                    TB_Description_Rich_Text__c =  caseParameters.description,
                    ContactId = caseParameters.contactId,
                    TB_Category__c = 'Meeting_With_Advisor',
                    Language = languageToCase,
                    AccountId = accountIdLinkedWithContact,
                    Status = NEW_STATUS,
                    Origin = TB_vu_Constants.VIRTUAL_UNIVERSITY_CASE_ORIGIN,
                    RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(TB_vu_Constants.MEETING_CASE_RECORD_TYPE_DEVELOPER_NAME).getRecordTypeId()
            );

            insert newCase;

            toReturn.add(newCase.Id);

            List<hed__Program_Enrollment__c> relatedProgramEnrollment = [SELECT Id, TB_Study_Name_With_Attributes_PL__c, TB_Study_Name_With_Attributes_EN__c FROM hed__Program_Enrollment__c WHERE Id = :caseParameters.studyNameId];

            TB_Operation__c newOperation = new TB_Operation__c(
                    TB_Case__c = newCase.Id,
                    RecordTypeId = Schema.SObjectType.TB_Operation__c.getRecordTypeInfosByDeveloperName().get(TB_vu_Constants.CONVERSATION_OPERATION_RECORD_TYPE_DEVELOPER_NAME).getRecordTypeId(),
                    TB_Type__c = TB_vu_Constants.EXTERNAL_COMMENT_OPERATION_TYPE,
                    TB_Author__c = TB_vu_Constants.STUDENT_OPERATION_AUTHOR,
                    TB_Publish__c = true,
                    TB_Initial__c = true,
                    TB_Description_Rich_Text__c = caseParameters.description,
                    TB_Contact__c = caseParameters.contactId,
                    TB_Case_Study_Name_With_Attributes_PL__c = relatedProgramEnrollment.isEmpty() ? null : relatedProgramEnrollment[0].TB_Study_Name_With_Attributes_PL__c,
                    TB_Case_Study_Name_With_Attributes_EN__c = relatedProgramEnrollment.isEmpty() ? null : relatedProgramEnrollment[0].TB_Study_Name_With_Attributes_EN__c
            );

            insert newOperation;

            toReturn.add(newOperation.Id);

            return toReturn;

        }  catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_NewMeetingController.class.getName(),e.getStackTraceString(),''));
        }
    }

    @AuraEnabled
    public static List<String> saveQMSMeeting(QmsMeetingParameters meetingParameters){
        if(meetingParameters == null){
            AuraHandledException e = new AuraHandledException('Expected meetingParameters, got null');
            e.setMessage('Expected meetingParameters, got null');
            throw e;
        }
        if(String.isBlank(meetingParameters.reservationId)){
            AuraHandledException e = new AuraHandledException('Expected reservationId, got null');
            e.setMessage('Expected reservationId, got null');
            throw e;
        }
        if(String.isBlank(meetingParameters.contactId) || !(meetingParameters.contactId instanceof Id) || ((Id)meetingParameters.contactId).getSobjectType() != Contact.getSObjectType()){
            AuraHandledException e = new AuraHandledException('Expected contactId (Id), got an empty String or invalid type of Id');
            e.setMessage('Expected contactId (Id), got an empty String or invalid type of Id');
            throw e;
        }
        if(String.isBlank(meetingParameters.programEnrollmentId) || !(meetingParameters.programEnrollmentId instanceof Id) || ((Id)meetingParameters.programEnrollmentId).getSobjectType() != hed__Program_Enrollment__c.getSObjectType()){
            AuraHandledException e = new AuraHandledException('Expected programEnrollmentId (Id), got an empty String or invalid type of Id');
            e.setMessage('Expected programEnrollmentId (Id), got an empty String or invalid type of Id');
            throw e;
        }
        if(String.isBlank(meetingParameters.topicId) || !(meetingParameters.topicId instanceof Id) || ((Id)meetingParameters.topicId).getSobjectType() != sfal__Topic__c.getSObjectType()){
            AuraHandledException e = new AuraHandledException('Expected topicId (Id), got an empty String or invalid type of Id');
            e.setMessage('Expected topicId (Id), got an empty String or invalid type of Id');
            throw e;
        }
        if(String.isBlank(meetingParameters.description) || (meetingParameters.description).length() > 10000){
            AuraHandledException e = new AuraHandledException('Expected description, got null value or description length is greater than 10000');
            e.setMessage('Expected description, got null value or description length is greater than 10000');
            throw e;
        }
        Datetime startDatetime = meetingParameters.startTime;
        Datetime endDatetime = startDatetime.addMinutes(15);
        try {
            List<String> toReturn = new List<String>();
            
            sfal__Topic__c topic;
            Contact studentContact;
            hed__Program_Enrollment__c programEnrollment;
            sfal__AppointmentLocation__c appointmentLocation;
            Calendar ownerCalendar;
            try
            {
                topic = [SELECT Id, sfal__ParentTopic__c, toLabel(sfal__Label__c), toLabel(sfal__ParentTopic__r.sfal__Label__c) FROM sfal__Topic__c WHERE Id = :meetingParameters.topicId];
            }
            catch(Exception ex)
            {
                AuraHandledException e = new AuraHandledException('Couldn\'t find topic for topicId: ' + meetingParameters.topicId);
                e.setMessage('Couldn\'t find topic for topicId: ' + meetingParameters.topicId);
                throw e;
            }
            try
            {
                studentContact = [SELECT Id, TB_x_Contact_Name__c FROM Contact WHERE Id = :meetingParameters.contactId];
            }
            catch(Exception ex)
            {
                AuraHandledException e = new AuraHandledException('Couldn\'t find contact for contactId: ' + meetingParameters.contactId);
                e.setMessage('Couldn\'t find contact for contactId: ' + meetingParameters.contactId);
                throw e;
            }
            try
            {
                programEnrollment = [SELECT Id, hed__Account__r.Parent.BillingCity, hed__Account__r.ParentId FROM hed__Program_Enrollment__c WHERE Id = :meetingParameters.programEnrollmentId];
            }
            catch(Exception ex)
            {
                AuraHandledException e = new AuraHandledException('Couldn\'t find program enrollment for programEnrollmentId: ' + meetingParameters.programEnrollmentId);
                e.setMessage('Couldn\'t find contact for programEnrollmentId: ' + meetingParameters.programEnrollmentId);
                throw e;
            }
            try
            {
                String nameLike = '%Biuro '+meetingParameters.location+'%';
                appointmentLocation = [SELECT Id, Name FROM sfal__AppointmentLocation__c WHERE sfal__Type__c = 'In Person' AND sfal__Campus__c LIKE :programEnrollment.hed__Account__r.Parent.BillingCity AND Name LIKE :nameLike LIMIT 1];
            }
            catch(Exception ex)
            {
                AuraHandledException e = new AuraHandledException('Couldn\'t find appointment location for City: ' + programEnrollment.hed__Account__r.Parent.BillingCity);
                e.setMessage('Couldn\'t find appointment location for City: ' + programEnrollment.hed__Account__r.Parent.BillingCity);
                throw e;
            }
            try
            {
                ownerCalendar = [SELECT Id FROM Calendar WHERE Name LIKE :('%' + programEnrollment.hed__Account__r.Parent.BillingCity + '%') LIMIT 1];
            }
            catch(Exception ex)
            {
                AuraHandledException e = new AuraHandledException('Couldn\'t find calendar for City: ' + programEnrollment.hed__Account__r.Parent.BillingCity);
                e.setMessage('Couldn\'t find calendar for City: ' + programEnrollment.hed__Account__r.Parent.BillingCity);
                throw e;
            }
    
            Case newCase = new Case(
                    RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(TB_vu_Constants.MEETING_CASE_RECORD_TYPE_DEVELOPER_NAME).getRecordTypeId(),
                    OwnerId = TB_vu_QMS__c.getInstance().TB_Default_Meeting_Owner__c,
                    Status = MEETING_BOOKED_STATUS,
                    ContactId = meetingParameters.contactId,
                    TB_Program_Enrollment__c = meetingParameters.programEnrollmentId,
                    sfal__Topic__c = meetingParameters.topicId,
                    Origin = TB_vu_Constants.VIRTUAL_UNIVERSITY_CASE_ORIGIN,
                    TB_Category__c = 'Meeting_CSS_Office',
                    Subject = topic.sfal__Label__c,
                    TB_Description_Rich_Text__c = meetingParameters.description,
                    TB_QMS_Reservation__c = meetingParameters.reservationId,
                    TB_Meeting_DateTime__c = startDatetime,
                    sfal__Location__c = appointmentLocation.Name
            );
            insert newCase;
            toReturn.add(newCase.Id);

            TB_Operation__c newOperation = new TB_Operation__c(
                    TB_Case__c = newCase.Id,
                    RecordTypeId = Schema.SObjectType.TB_Operation__c.getRecordTypeInfosByDeveloperName().get(TB_vu_Constants.CONVERSATION_OPERATION_RECORD_TYPE_DEVELOPER_NAME).getRecordTypeId(),
                    TB_Type__c = TB_vu_Constants.EXTERNAL_COMMENT_OPERATION_TYPE,
                    TB_Author__c = TB_vu_Constants.STUDENT_OPERATION_AUTHOR,
                    TB_Publish__c = true,
                    TB_Initial__c = true,
                    TB_Description_Rich_Text__c = meetingParameters.description,
                    TB_Contact__c = meetingParameters.contactId
            );
            insert newOperation;
            toReturn.add(newOperation.Id);
            
            sfal__Appointment__c newAppointment = new sfal__Appointment__c(
                    RecordTypeId = Schema.SObjectType.sfal__Appointment__c.getRecordTypeInfosByDeveloperName().get(TB_vu_Constants.ADVISING_EVENT_APPOINTMENT_RECORD_TYPE_DEVELOPER_NAME).getRecordTypeId(),
                    Name = studentContact.TB_x_Contact_Name__c + ' ' + topic.sfal__Label__c,
                    sfal__RelatedCase__c = newCase.Id,
                    OwnerId = newCase.OwnerId,
                    sfal__RelatedTopic__c = topic.sfal__ParentTopic__c,
                    sfal__RelatedSubtopic__c = topic.Id,
                    sfal__Topic__c = topic.sfal__ParentTopic__r.sfal__Label__c,
                    sfal__Subtopic__c = topic.sfal__Label__c,
                    sfal__Description__c = meetingParameters.description,
                    sfal__StartDateTime__c = startDatetime,
                    sfal__EndDateTime__c = endDatetime,
                    sfal__AppointmentLocation__c = appointmentLocation.Id,
                    sfal__Location__c = appointmentLocation.Name
            );
            insert newAppointment;
            toReturn.add(newAppointment.Id);
            
            sfal__AppointmentAttendee__c newAttendee = new sfal__AppointmentAttendee__c(
                    sfal__Appointment__c = newAppointment.Id,
                    sfal__Attendee__c = UserInfo.getUserId(),
                    sfal__Role__c = 'Attendee',
                    sfal__Status__c = 'Attending',
                    sfal__AdviseeRecord__c = newCase.Id
            );
            
            sfal__AppointmentAttendee__c organizerAttendee = new sfal__AppointmentAttendee__c(
                    sfal__Appointment__c = newAppointment.Id,
                    sfal__Attendee__c = newCase.OwnerId,
                    sfal__Role__c = 'Organizer',
                    sfal__Status__c = 'Attending',
                    sfal__AdviseeRecord__c = newCase.Id
            );
            insert new List<sfal__AppointmentAttendee__c>{newAttendee,organizerAttendee};
            toReturn.add(newAttendee.Id);
            
            Event newEvent = new Event(
                    IsVisibleInSelfService = true,
                    OwnerId = ownerCalendar.Id,
                    Subject = studentContact.TB_x_Contact_Name__c + ' ' + topic.sfal__Label__c,
                    WhatId = newAttendee.Id,
                    StartDateTime = startDatetime,
                    EndDateTime = endDatetime,
                    Location = appointmentLocation.Name,
                    ShowAs = TB_vu_Constants.BUSY_EVENT_SHOW_AS,
                    Description = meetingParameters.description,
                    Type = TB_vu_Constants.MEETING_EVENT_TYPE,
                    TB_Case__c = newCase.Id
            );
            insert newEvent;
            toReturn.add(newEvent.Id);

            return toReturn;

        }  catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_NewMeetingController.class.getName(),e.getStackTraceString(),''));
        }
    }
    @AuraEnabled
    public static List<StudyNameWrapper> getStudyNames(String language, String contactId) {
        if(String.isBlank(contactId) || !(contactId instanceof Id) || ((Id)contactId).getSobjectType() != Contact.getSObjectType()) {
            AuraHandledException e = new AuraHandledException('Expected contactId (Id), got an empty String or invalid type of Id');
            e.setMessage('Expected contactId (Id), got an empty String or invalid type of Id');
            throw e;
        }
        if(String.isBlank(language) || !(language == LANG_PL || language == LANG_EN)){
            AuraHandledException e = new AuraHandledException('Expected language, got an empty String or invalid language code');
            e.setMessage('Expected language, got an empty String or invalid language code');
            throw e;
        }
        try {
            Integer daysBeforeEnrollmentStartDay = (Integer)TB_SS_Program_Enrollment_Setting__c.getOrgDefaults().TB_Days_Before_Enrollment_Start_Day__c;
            List<StudyNameWrapper> toReturn = new List<StudyNameWrapper>();
            Map<String, hed__Program_Enrollment__c> withoutRoundNumberDuplicates = new Map<String, hed__Program_Enrollment__c>();
            for (hed__Program_Enrollment__c pe : [
                    SELECT
                            Id,
                            TB_Study_Name_With_Attributes_EN__c,
                            TB_Study_Name_With_Attributes_PL__c,
                            DT_Campus__c,
                            hed__Start_Date__c,
                            hed__End_Date__c,
                            DT_VDO_Round_ID__c
                    FROM hed__Program_Enrollment__c
                    WHERE hed__Contact__c = :contactId 
                    AND hed__Account__r.Parent.BillingCity = :TB_vu_Constants.CAMPUS_BILLING_CITY_WARSAW
                    AND DT_Level_Of_Studies__c IN: TB_vu_Constants.PROGRAM_ENROLMENT_LEVEL_OF_STUDIES
                    AND hed__Start_Date__c <=: Date.today() + daysBeforeEnrollmentStartDay
            ]) {
                if(pe.hed__End_Date__c == null || pe.hed__Start_Date__c <= pe.hed__End_Date__c){
                    if(withoutRoundNumberDuplicates.get(pe.DT_VDO_Round_ID__c) == null){
                        withoutRoundNumberDuplicates.put(pe.DT_VDO_Round_ID__c, pe);
                    }
                    else if(withoutRoundNumberDuplicates.get(pe.DT_VDO_Round_ID__c).hed__Start_Date__c < pe.hed__Start_Date__c){
                        withoutRoundNumberDuplicates.put(pe.DT_VDO_Round_ID__c, pe);
                    }
                }
            }
            for(hed__Program_Enrollment__c pe : withoutRoundNumberDuplicates.values()){
                String facultyToAdd = language == LANG_PL ? pe.TB_Study_Name_With_Attributes_PL__c : pe.TB_Study_Name_With_Attributes_EN__c;
                toReturn.add(new StudyNameWrapper(
                        pe.Id,
                        pe.DT_Campus__c,
                        facultyToAdd
                ));
            }
            return toReturn;

        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(), TB_vu_CasesController.class.getName(), e.getStackTraceString(), ''));
        }
    }

    @AuraEnabled(Cacheable=true)
    public static List<TopicWrapper> getTopics(String campus, String availabilitySource){
        if(String.isBlank(campus)){
            AuraHandledException e = new AuraHandledException('Expected campus, got an empty String');
            e.setMessage('Expected campus, got an empty String');
            throw e;
        }
        if(String.isBlank(availabilitySource)){
            AuraHandledException e = new AuraHandledException('Expected availabilitySource, got an empty String');
            e.setMessage('Expected availabilitySource, got an empty String');
            throw e;
        }
        List<TopicWrapper> toReturn = new List<TopicWrapper>();
        try {
            String query = 
            'SELECT Id, TB_Topic_PL__c, TB_Topic_EN__c FROM sfal__Topic__c ' +
            'WHERE TB_Availability_Source__c = :availabilitySource ' +
            'AND (TB_Campus__c INCLUDES (:campus) OR TB_Available_In_All_Campuses__c = TRUE) ' +
            'AND TB_Active__c = TRUE ' +
            'ORDER BY sfal__SortOrder__c ASC';
            if(AVAILABILITY_SOURCES_LIMIT_1_QUERY.contains(availabilitySource)){
                query += ' LIMIT 1';
            }
            
            List<sfal__Topic__c> topics = Database.query(query);
            if(topics.size() > 0){
                for(sfal__Topic__c topic : topics){
                    toReturn.add(new TopicWrapper(
                        UserInfo.getLanguage() == 'pl' ? topic.TB_Topic_PL__c : topic.TB_Topic_EN__c,
                        topic.TB_Topic_PL__c,
                        topic.Id
                    ));
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_NewMeetingController.class.getName(),e.getStackTraceString(),UserInfo.getUserId()));
        }
        return toReturn;
    }

    public class StudyNameWrapper{
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public String campus { get; set; }
        @AuraEnabled
        public String studyName { get; set; }

        public StudyNameWrapper(String id, String campus, String studyName) {
            this.id = id;
            this.campus = campus;
            this.studyName = studyName;
        }
    }

    public class TopicWrapper{
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String plLabel { get; set; }
        @AuraEnabled
        public String value { get; set; }

        public TopicWrapper(String label, String plLabel, String value) {
            this.label = label;
            this.plLabel = plLabel;
            this.value = value;
        }
    }

    public class CaseParameters{
        @AuraEnabled
        public String topicId { get; set; }
        @AuraEnabled
        public String studyNameId { get; set; }
        @AuraEnabled
        public String subject { get; set; }
        @AuraEnabled
        public String description { get; set; }
        @AuraEnabled
        public String language { get; set; }
        @AuraEnabled
        public String contactId { get; set; }
    }
    
    public class QmsMeetingParameters
    {
        @AuraEnabled
        public String reservationId {get; set;}
        @AuraEnabled
        public String contactId {get; set;}
        @AuraEnabled
        public String programEnrollmentId {get; set;}
        @AuraEnabled
        public String topicId {get; set;}
        @AuraEnabled
        public String description {get; set;}
        @AuraEnabled
        public Datetime startTime {get; set;}
        @AuraEnabled
        public String location {get; set;}
    }
}