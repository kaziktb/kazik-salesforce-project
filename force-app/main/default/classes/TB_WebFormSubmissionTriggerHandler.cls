/**
 * Created by kacperjachowicz on 15/09/2021.
 */

public without sharing class TB_WebFormSubmissionTriggerHandler extends TB_TriggerHandler {
    private static final String MAUTIC_FORM_ON_SUBMIT = 'mautic.form_on_submit';
    private static final String PROCESSED = 'Processed';
    private static final String ERROR = 'Error';
    private static final String MAUTIC_FORM_NAME = 'mautic_form[name]';
    private static final String MAUTIC_FORM_URL = 'mautic_form[url]';
    private static final String MAUTIC_FORM_ID = 'mautic_form[id]';
    private static final String MAUTIC_FORM_PREFIX = 'mautic_';

    public override void afterInsert() {
        String newMapJson = JSON.serialize((Map<Id, TB_Web_Form_Submission__c>) Trigger.newMap);
        fillFieldsFuture(newMapJson);
    }

    @Future
    public static void fillFieldsFuture(String newMapJson) {
        Map<Id, TB_Web_Form_Submission__c> idToWebFormSubmission = (Map<Id, TB_Web_Form_Submission__c>) JSON.deserialize(newMapJson, Map<Id, TB_Web_Form_Submission__c>.class);
        fillFields(idToWebFormSubmission);
    }

    public static void fillFields(Map<Id, TB_Web_Form_Submission__c> idToWebFormSubmission) {
        try {
            Map<Id, TB_Web_Form_Submission__c> webFormSubmissionsJson = new Map<Id, TB_Web_Form_Submission__c>();
            Map<Id, TB_Web_Form_Submission__c> webFormSubmissionsRequestBody = new Map<Id, TB_Web_Form_Submission__c>();
            for (TB_Web_Form_Submission__c webFormSubmission : idToWebFormSubmission.values()) {
                if (String.isBlank(webFormSubmission.TB_JSON_Body__c)) {
                    webFormSubmissionsRequestBody.put(webFormSubmission.Id, webFormSubmission);
                } else {
                    webFormSubmissionsJson.put(webFormSubmission.Id, webFormSubmission);
                }
            }

            List <TB_Web_Form_Submission__c> webFormSubmissionsJsonToUpdate = new List<TB_Web_Form_Submission__c>();
            List<TB_Web_Form_Result__c> webFormJsonResults = new List<TB_Web_Form_Result__c>();
            for (Id webFormSubmissionId : webFormSubmissionsJson.keySet()) {
                List<Map<String, Object>> deserializedResponse = preparedDeserializedResponse(webFormSubmissionsJson);
                for (Map<String, Object> values : deserializedResponse) {
                    webFormSubmissionsJsonToUpdate = createWebFormSubmission(values, webFormSubmissionId);
                    webFormJsonResults = createWebFormResult(values, webFormSubmissionId);
                }
            }

            Map<Id, Map<String, String>> webFormIdToAttributeToValue = prepareDeserializedResponseFromRequestBody(webFormSubmissionsRequestBody);
            List<TB_Web_Form_Submission__c> webFormSubmissionsRequestToUpdate = new List<TB_Web_Form_Submission__c>();
            List<TB_Web_Form_Result__c> webFormRequestResults = new List<TB_Web_Form_Result__c>();
            for (Id webFormId : webFormIdToAttributeToValue.keySet()) {
                webFormSubmissionsRequestToUpdate.add(createWebFormSubmissionFromRequestBody(webFormIdToAttributeToValue.get(webFormId), webFormId));
                webFormRequestResults.addAll(createWebFormResultFromRequestBody(webFormIdToAttributeToValue.get(webFormId), webFormId));
            }

            List<TB_Web_Form_Submission__c> submissionsToUpdate = new List<TB_Web_Form_Submission__c>();
            submissionsToUpdate.addAll(webFormSubmissionsJsonToUpdate);
            submissionsToUpdate.addAll(webFormSubmissionsRequestToUpdate);

            List<TB_Web_Form_Result__c> resultsToInsert = new List<TB_Web_Form_Result__c>();
            resultsToInsert.addAll(webFormJsonResults);
            resultsToInsert.addAll(webFormRequestResults);

            update submissionsToUpdate;
            insert resultsToInsert;
        } catch (Exception e) {
            List<TB_Web_Form_Submission__c> webFormSubmissions = new List<TB_Web_Form_Submission__c>();
            for (TB_Web_Form_Submission__c webFormSubmission : idToWebFormSubmission.values()) {
                webFormSubmissions.add (
                    new TB_Web_Form_Submission__c(Id = webFormSubmission.Id,
                            TB_Status__c = ERROR,
                            TB_Error_Details__c = TB_LogUtils.composeErrorMessageFromException(e, webFormSubmission.Id, TB_WebFormSubmissionTriggerHandler.class))
                );
            }
            update webFormSubmissions;
        }
    }

    private static List<Map<String, Object>> preparedDeserializedResponse(Map<Id, TB_Web_Form_Submission__c> webFormSubmissionsJson) {
        List<Map<String, Object>> deserializedMaps = new List<Map<String, Object>>();
        for (Id webFormId : webFormSubmissionsJson.keySet()) {
            Map<String, Object> deserialized = (Map<String, Object>) JSON.deserializeUntyped(webFormSubmissionsJson.get(webFormId).TB_JSON_Body__c);
            deserializedMaps.add(deserialized);
        }
        List<Map<String, Object>> deserializedResponse = new List<Map<String, Object>>();
        for (Map<String, Object> stringToDeserializedObject : deserializedMaps) {
            for (Object obj : (List<Object>) stringToDeserializedObject.get(MAUTIC_FORM_ON_SUBMIT)) {
                deserializedResponse.add((Map<String, Object>) obj);
            }
        }
        return deserializedResponse;
    }

    private static Map<Id, Map<String, String>> prepareDeserializedResponseFromRequestBody(Map<Id, TB_Web_Form_Submission__c> webFormSubmissionsRequestBody) {
        Map<Id, Map<String, String>> webFormIdToAttributeToValue = new Map<Id, Map<String, String>>();
        for (Id webFormId : webFormSubmissionsRequestBody.keySet()) {
            Map<String, String> deserializedAttributeToValue = new Map<String, String>();
            String requestBody = webFormSubmissionsRequestBody.get(webFormId).TB_Request_Body__c;
            Map<String, Object> fieldToValueFromRequestBody = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            for (String field : fieldToValueFromRequestBody.keySet()) {
                String value = (String) fieldToValueFromRequestBody.get(field);
                deserializedAttributeToValue.put(field, value);
            }
            webFormIdToAttributeToValue.put(webFormId, deserializedAttributeToValue);
        }
        return webFormIdToAttributeToValue;
    }

    private static TB_Web_Form_Submission__c createWebFormSubmissionFromRequestBody(Map<String, String> attributeToValue, Id webFormSubmissionId) {
        return new TB_Web_Form_Submission__c (
            Id = webFormSubmissionId,
            TB_Form_Name__c = attributeToValue.get(MAUTIC_FORM_NAME),
            TB_Referer__c = attributeToValue.get(MAUTIC_FORM_URL),
            TB_Form_Id__c = attributeToValue.get(MAUTIC_FORM_ID),
            TB_Status__c = PROCESSED
        );
    }

    private static List<TB_Web_Form_Result__c> createWebFormResultFromRequestBody(Map<String, String> attributeToValue, Id webFormSubmissionId) {
        List<TB_Web_Form_Result__c> webFormResults = new List<TB_Web_Form_Result__c>();
        for (String attribute : attributeToValue.keySet()) {
            if (!attribute.toLowerCase().contains(MAUTIC_FORM_PREFIX)) {
                webFormResults.add (
                    new TB_Web_Form_Result__c (
                        TB_Web_Form_Submission__c = webFormSubmissionId,
                        TB_JSON_Attribute__c = attribute,
                        TB_JSON_Value__c = attributeToValue.get(attribute).left(253)
                    )
                );
            }
        }
        return webFormResults;
    }

    private static List<TB_Web_Form_Submission__c> createWebFormSubmission(Map<String, Object> values, Id webFormSubmissionId) {
        SubmissionWrapper submissionWrapper = (SubmissionWrapper) JSON.deserialize(JSON.serialize(values.get('submission')), SubmissionWrapper.class);
        List<TB_Web_Form_Submission__c> webFormSubmissionsToUpdate = new List<TB_Web_Form_Submission__c>();
        TB_Web_Form_Submission__c webFormSubmission = new TB_Web_Form_Submission__c(Id = webFormSubmissionId);
        webFormSubmission.TB_Form_Alias__c = submissionWrapper.form.alias;
        webFormSubmission.TB_Submission_Id__c = submissionWrapper.id;
        webFormSubmission.TB_Form_Category__c = submissionWrapper.form.category;
        webFormSubmission.TB_Form_Id__c = submissionWrapper.form.id;
        webFormSubmission.TB_Form_Name__c = submissionWrapper.form.name;
        webFormSubmission.TB_Submission_Date__c = submissionWrapper.dateSubmitted;
        webFormSubmission.TB_Referer__c = submissionWrapper.referer;
        webFormSubmission.TB_IP_Address__c = submissionWrapper.ipAddress.ipAddress;
        webFormSubmission.TB_Tracking_Id__c = submissionWrapper.trackingId;
        webFormSubmission.TB_Status__c = PROCESSED;
        webFormSubmissionsToUpdate.add(webFormSubmission);
        return webFormSubmissionsToUpdate;
    }

    private static List<TB_Web_Form_Result__c> createWebFormResult(Map<String, Object> values, Id webFormSubmissionId) {
        Map<String, Object> deserializedSubmissions = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(values.get('submission')));
        Map<String, Object> deserializedResults = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(deserializedSubmissions.get('results')));
        List<TB_Web_Form_Result__c> webFormResults = new List<TB_Web_Form_Result__c>();
        for (String deserializedResultsKey : deserializedResults.keySet()) {
            TB_Web_Form_Result__c webFormResult = new TB_Web_Form_Result__c();
            webFormResult.TB_Web_Form_Submission__c = webFormSubmissionId;
            webFormResult.TB_JSON_Attribute__c = deserializedResultsKey;
            webFormResult.TB_JSON_Value__c = ((String) deserializedResults.get(deserializedResultsKey)).left(253);
            webFormResults.add(webFormResult);
        }
        return webFormResults;
    }

    public class SubmissionWrapper {
        public String id;
        public Datetime dateSubmitted;
        public String referer;
        public String trackingId;
        public FormDetails form;
        public IpAddress ipAddress;
    }

    public class FormDetails {
        public String alias;
        public String category;
        public String id;
        public String name;
    }

    public class IpAddress {
        public String ipAddress;
    }
}