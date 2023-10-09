/**
 * Created by adriangawryszewski on 3/10/22.
 */
@RestResource(urlMapping='/TB_ExportResults')
global with sharing class TB_RESTAPI_ExportResults {

    global static final String TB_HIGHER_EDUCATION_STUDY_LEVEL_BACHELOR = 'Bachelor';
    global static final String TB_HIGHER_EDUCATION_STUDY_LEVEL_MASTER = 'Master';
    global static final String TB_POSTGRAD_EDUCATION_STUDY_LEVEL = 'Postgraduate';
    global static final String TB_PHD_EDUCATION_STUDY_LEVEL = 'PhD';
    global static final String TB_COURSE_EDUCATION_STUDY_LEVEL = 'Course';
    global static final String TB_INTEGRATED_MASTER_EDUCATION_STUDY_LEVEL = 'Integrated_Master';
    global static final String TB_SHORT_COURSE_EDUCATION_STUDY_LEVEL = 'Short_Course';


    @HttpPost
    global static void assignExportData() {
        RestResponse res;
        RestRequest req;
        try {
            req = RestContext.request;
            res = RestContext.response;
            Set<String> communicationEventKeys = new Set<String>();
            Map<String, String> eventKeyToAppIdMap = new Map<String, String>();
            List<TB_RequestBody> exportResults = (List<TB_RequestBody>) JSON.deserialize(req.requestBody.toString(), List<TB_RequestBody>.class);

            for (TB_RequestBody trb : exportResults) {
                communicationEventKeys.add(trb.eventKey);
            }

            for (TB_Communication_Event__c comm : [
                    SELECT
                            Id, TB_Record_Id__c, TB_Event_Key__c
                    FROM TB_Communication_Event__c
                    WHERE TB_Event_Key__c IN :communicationEventKeys
            ]) {
                eventKeyToAppIdMap.put(comm.TB_Event_Key__c, comm.TB_Record_Id__c);
            }

            List<hed__Application__c> applications = new List<hed__Application__c>();
            List<Contact> contacts = new List<Contact>();

            List<TB_Communication_Event__c> exportEvents = new List<TB_Communication_Event__c>();

            for (TB_RequestBody trb : exportResults) {
                
                Contact ct = new Contact(
                	Id = trb.candidateId,
                    DT_VDO_ID__c = trb.VDOId
                );
                contacts.add(ct);
                
                hed__Application__c app = new hed__Application__c(
                        Id = eventKeyToAppIdMap.get(trb.eventKey)
                );
                
                if (trb.studyLevel == TB_HIGHER_EDUCATION_STUDY_LEVEL_BACHELOR ||
                        trb.studyLevel == TB_HIGHER_EDUCATION_STUDY_LEVEL_MASTER ||
                        trb.studyLevel == TB_INTEGRATED_MASTER_EDUCATION_STUDY_LEVEL) {
                    app.TB_Album_Number_HE__c = trb.Album;
                }
                if (trb.studyLevel == TB_POSTGRAD_EDUCATION_STUDY_LEVEL ||
                        trb.studyLevel == TB_COURSE_EDUCATION_STUDY_LEVEL ||
                        trb.studyLevel == TB_SHORT_COURSE_EDUCATION_STUDY_LEVEL) {
                    app.TB_Album_Number_PG__c = trb.Album;
                }

                applications.add(app);

                TB_Communication_Event__c exportMessage = new TB_Communication_Event__c(
                        TB_Event_Key__c = trb.eventKey,
                        TB_Response_Body__c = trb.toString(),
                        TB_Response_Code__c = trb.status
                );
                exportEvents.add(exportMessage);

            }

            if (contacts != null && contacts.size() > 0) {
                upsert contacts;
            }

            if (applications != null && applications.size() > 0) {
                upsert applications;
            }

            if (exportEvents != null && exportEvents.size() > 0) {
                upsert exportEvents TB_Event_Key__c;
            }

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(new TB_Response('OK', null)));

        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(new TB_Response('ERROR', new TB_ErrorResponse(e.getMessage()))));
        }
    }

    global class TB_RequestBody {
        global String candidateId;
        global String eventKey;
        global String IMId;
        global String VDOId;
        global String error;
        global String Album;
        global String studyLevel;
        global String status;
    }


    global class TB_ErrorResponse implements TB_ResponseInterface {
        String Message;

        global TB_ErrorResponse(String message) {
            this.Message = message;
        }
    }

    public class TB_Response {
        String Status;
        TB_ResponseInterface Data;

        public TB_Response(String status, TB_ResponseInterface data) {
            this.Status = status;
            this.Data = data;
        }
    }
}
