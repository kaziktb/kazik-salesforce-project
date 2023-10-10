/**
 * Created by jowitakozlak on 09/12/2021.
 */

@IsTest
public with sharing class TB_GoogleIntegratorRetrieverTest {
    
    static String Record_Id = '';
    static final String Meeting_URL = 'TB_Meeting_URL__c';
    static final String Meeting_Attendees = 'TB_Meeting_Attendees_Emails__c';
    static final String Meeting_Start = 'TB_Start_DST__c';
    static final String Meeting_End = 'TB_End_DST__c';
    static final String Name = 'Name';
    static final String Meeting_Description = 'TB_Meeting_Description__c';
    static final String Meeting_Status = 'TB_Meeting_Status__c';
    static final String Event_Id = 'TB_Event_Id__c';
    static final String Meeting_Organizer ='TB_Meeting_Organizer_Email__c';

    @TestSetup
    static void testSetup() {
        TB_Admissions_Campaign__c campaign = TB_TestDataFactory.createAdmissionsCampaign(false);
        insert campaign;
        TB_Admissions_Committee__c committee = TB_TestDataFactory.createAdmissionsCommittee(false);
        insert committee;
        TB_Qualification_Requirement_Item__c item = TB_TestDataFactory.createQualificationRequirementItem(false, committee.Id);
        item.TB_Info_EN__c = 'INFO_EN';
        item.TB_Status__c = 'Published';
        insert item;

        TB_Qualification_Requirement_Item_Term__c recordObject = new TB_Qualification_Requirement_Item_Term__c();
        recordObject.Name = 'Spotkanie';
        recordObject.TB_Meeting_URL__c = '';
        recordObject.TB_Meeting_Status__c = 'create';
        recordObject.TB_Start__c = System.now();
        recordObject.TB_End__c = System.now().addDays(1);
        recordObject.TB_Meeting_Attendees_Emails__c = 'attendee@mail.com';
        recordObject.TB_Meeting_Organizer_Email__c = 'organizer@mail.com';
        recordObject.TB_Meeting_Description__c = 'description';
        recordObject.TB_Location__c = 'Online';
        recordObject.TB_Qualification_Requirement_Item__c = item.Id;
        insert recordObject;

        TB_Qualification_Requirement_Item_Term__c recordObjectToDelete = new TB_Qualification_Requirement_Item_Term__c();
        recordObjectToDelete.Name = 'Spotkanie 2';
        recordObjectToDelete.TB_Meeting_URL__c = 'url.com/x';
        recordObjectToDelete.TB_Event_Id__c = '456';
        recordObjectToDelete.TB_Meeting_Status__c = 'cancel';
        recordObjectToDelete.TB_Start__c = System.now();
        recordObjectToDelete.TB_End__c = System.now().addDays(1);
        recordObjectToDelete.TB_Meeting_Attendees_Emails__c = 'attendee@mail.com';
        recordObjectToDelete.TB_Meeting_Organizer_Email__c = 'organizer@mail.com';
        recordObjectToDelete.TB_Meeting_Description__c = 'description';
        recordObjectToDelete.TB_Location__c = 'Online';
        recordObjectToDelete.TB_Qualification_Requirement_Item__c = item.Id;
        insert recordObjectToDelete;
    }

//    @IsTest
//    static void insertEventPositive() {
//        Test.setMock(HttpCalloutMock.class,
//            new TB_GoogleIntegratorRetrieverMock('insertEventPositive'));
//
//        TB_Qualification_Requirement_Item_Term__c createdMeeting = new TB_Qualification_Requirement_Item_Term__c();
//        createdMeeting = [
//            SELECT Id, Name, TB_Meeting_Status__c, TB_Meeting_URL__c, TB_Meeting_Organizer_Email__c,
//                TB_Event_Id__c, TB_Meeting_Attendees_Emails__c, TB_Meeting_Description__c, TB_End__c,
//                TB_Start__c
//            FROM TB_Qualification_Requirement_Item_Term__c
//            WHERE TB_Meeting_Status__c = :'create'
//            LIMIT 1
//        ];
//
//        List<TB_GoogleIntegratorRetrieverInvocable.MeetingWrapperClass> meetingWrapperClasses
//            = new List<TB_GoogleIntegratorRetrieverInvocable.MeetingWrapperClass>();
//        meetingWrapperClasses = getObject(createdMeeting);
//
//        Test.startTest();
//        TB_GoogleIntegratorRetrieverInvocable.googleIntegratorRetriever(meetingWrapperClasses);
//        Test.stopTest();
//
//        TB_Qualification_Requirement_Item_Term__c updatedMeeting = new TB_Qualification_Requirement_Item_Term__c();
//        updatedMeeting = [
//            SELECT Id, Name, TB_Meeting_URL__c, TB_Event_Id__c
//            FROM TB_Qualification_Requirement_Item_Term__c
//            WHERE TB_Meeting_Status__c = :'create'
//            LIMIT 1
//        ];
//
//        System.assertEquals('meet.google.com/x', updatedMeeting.TB_Meeting_URL__c);
//        System.assertEquals('123', updatedMeeting.TB_Event_Id__c);
//    }

//    @IsTest
//    static void deleteEventPositive() {
//        Test.setMock(HttpCalloutMock.class,
//            new TB_GoogleIntegratorRetrieverMock('deleteEventPositive'));
//
//        TB_Qualification_Requirement_Item_Term__c createdMeeting = new TB_Qualification_Requirement_Item_Term__c();
//        createdMeeting = [
//            SELECT Id, Name, TB_Meeting_Status__c, TB_Meeting_URL__c, TB_Meeting_Organizer_Email__c,
//                TB_Event_Id__c, TB_Meeting_Attendees_Emails__c, TB_Meeting_Description__c, TB_End__c,
//                TB_Start__c
//            FROM TB_Qualification_Requirement_Item_Term__c
//            WHERE TB_Meeting_Status__c = :'cancel'
//            LIMIT 1
//        ];
//
//        List<TB_GoogleIntegratorRetrieverInvocable.MeetingWrapperClass> meetingWrapperClasses
//            = new List<TB_GoogleIntegratorRetrieverInvocable.MeetingWrapperClass>();
//        meetingWrapperClasses = getObject(createdMeeting);
//
//        Test.startTest();
//        TB_GoogleIntegratorRetrieverInvocable.googleIntegratorRetriever(meetingWrapperClasses);
//        Test.stopTest();
//
//        TB_Qualification_Requirement_Item_Term__c updatedMeeting = new TB_Qualification_Requirement_Item_Term__c();
//        updatedMeeting = [
//            SELECT Id, Name, TB_Meeting_URL__c, TB_Event_Id__c
//            FROM TB_Qualification_Requirement_Item_Term__c
//            WHERE TB_Meeting_Status__c = :'cancel'
//            LIMIT 1
//        ];
//
//        System.assertEquals(null, updatedMeeting.TB_Meeting_URL__c);
//        System.assertEquals('456', updatedMeeting.TB_Event_Id__c);
//    }

    @IsTest
    static void authorizationPositive() {
        Test.setMock(HttpCalloutMock.class,
            new TB_GoogleIntegratorRetrieverMock('authorizationPositive'));

        String authorizationToken;
        Integer authorizationExpiresIn = 0;
        TB_GoogleIntegrator googleIntegrator = new TB_GoogleIntegrator();

        Test.startTest();
        HttpResponse authorizationResponse = new HttpResponse();
        try{
            authorizationResponse = googleIntegrator.authorization();
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
        }
        Test.stopTest();

        authorizationToken = (String) TB_WebserviceUtils.fetchFieldValueFromJSON(
            'access_token', authorizationResponse.getBody()
        );
        authorizationExpiresIn = (Integer) TB_WebserviceUtils.fetchFieldValueFromJSON(
            'expires_in', authorizationResponse.getBody()
        );

        System.assertEquals(0,[SELECT Id FROM TB_Log__c].size());
        System.assertEquals('token',authorizationToken);
        System.assertEquals(10000,authorizationExpiresIn);

    }

    @IsTest
    static void authorizationNegative() {
        Test.setMock(HttpCalloutMock.class,
            new TB_GoogleIntegratorRetrieverMock('authorizationNegative'));

        TB_GoogleIntegrator paypalIntegrator = new TB_GoogleIntegrator();

        Test.startTest();
        HttpResponse authorizationResponse = new HttpResponse();
        try{
            authorizationResponse = paypalIntegrator.authorization();
        } catch (Exception e) {
            System.debug(e);
            insert TB_LogUtils.registerLog(e);
        }
        Test.stopTest();

        System.assertEquals(1,[SELECT Id FROM TB_Log__c].size());
    }

    public static List<TB_GoogleIntegratorRetrieverInvocable.MeetingWrapperClass> getObject(TB_Qualification_Requirement_Item_Term__c createdMeeting){
        List<TB_GoogleIntegratorRetrieverInvocable.MeetingWrapperClass> meetingWrapperClasses
            = new List<TB_GoogleIntegratorRetrieverInvocable.MeetingWrapperClass>();
        TB_GoogleIntegratorRetrieverInvocable.MeetingWrapperClass meeting
            = new TB_GoogleIntegratorRetrieverInvocable.MeetingWrapperClass();
        Record_Id = createdMeeting.Id;
        meeting.Record_Id = (Id)Record_Id;
        meeting.Meeting_URL = Meeting_URL;
        meeting.Meeting_Attendees = Meeting_Attendees;
        meeting.Meeting_Start = Meeting_Start;
        meeting.Meeting_End = Meeting_End;
        meeting.Name = Name;
        meeting.Meeting_Description = Meeting_Description;
        meeting.Meeting_Status = Meeting_Status;
        meeting.Event_Id = Event_Id;
        meeting.Meeting_Organizer = Meeting_Organizer;
        meetingWrapperClasses.add(meeting);
        return meetingWrapperClasses;
    }
}