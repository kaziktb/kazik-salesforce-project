public with sharing class TB_DocGenController {
    private static final String ENDPOINT_PARAMETER_TOKEN = '?token=';
    private static final String POST_METHOD_PHRASE = 'POST';
    private static final String CONTENT_TYPE_PHRASE = 'Content-Type';
    private static final String JSON_APP_PHRASE = 'application/json';
    @TestVisible private static final String JSON_GEN_DOC_REQ_TEMPLATE_URL_PHRASE = 'templateId';
    @TestVisible private static final String JSON_GEN_DOC_REQ_DOCUMENT_NAME_PHRASE = 'documentName';
    @TestVisible private static final String JSON_GEN_DOC_REQ_EXPORT_FORMAT_PHRASE = 'exportFormat';
    @TestVisible private static final String JSON_GEN_DOC_REQ_RELATED_SOBJECTS_PHRASE = 'relatedSObjects';
    @TestVisible private static final String JSON_GEN_DOC_REQ_RECORD_ID_PHRASE = 'recordId';
    @TestVisible private static final String JSON_GEN_DOC_REQ_APP_DOCUMENT_ID_PHRASE = 'applicationDocumentId';
    private static final String WEB_SERVICE_CREDENTIAL_DN_DOCUMENT_GENERATOR = 'TB_Document_Generator';

    @TestVisible private static List<TB_Doc_Gen_Fields_Setting__mdt> fieldsSettings;
    @TestVisible private static List<TB_Doc_Gen_SObjects_Mapping_Setting__mdt> mappingSettings;

    @AuraEnabled
    public static String generateDocument(String jsonString) {
        Wrapper result;
        try {
            DocInfoWrapper infoWrapper = new DocInfoWrapper(jsonString);
            TB_DocGenController.fieldsSettings = getDocGenFieldsSettings();
            TB_DocGenController.mappingSettings = getDocGenMappingSettings();
            Map<String, Map<String, Object>> data = generateSObjectsData(infoWrapper.recordId, infoWrapper.relatedSObjects);
            result = new DocRequestWrapper(infoWrapper.templateId, infoWrapper.documentName, infoWrapper.exportFormat, data);
            TB_Webservice_Credential__mdt credential = getDocumentGeneratorCredential();
            String endpoint = credential.TB_WSC_Endpoint__c + ENDPOINT_PARAMETER_TOKEN + credential.TB_WSC_Token__c;
            HttpResponse response = sendPostRequest(endpoint, result.wrap());
            return getPostResponse(response, infoWrapper).wrap();

        } catch (Exception ex) {
            result = new DocResponseWrapper(ex);
            insert TB_LogUtils.registerLog(ex);
            return result.wrap();
        }
    }

    @AuraEnabled
    public static String generateMultiDocuments(String[] applicationIds, String externalTemplateId) {
        //on hold: call external endpoint in batch
        return null;
    }

    private static TB_Webservice_Credential__mdt getDocumentGeneratorCredential() {
        if(Test.isRunningTest()) {
            return new TB_Webservice_Credential__mdt(
                    TB_WSC_Endpoint__c = 'TEST_ENDPOINT',
                    TB_WSC_Token__c = 'TEST_TOKEN'
            );
        }else {
            return TB_Webservice_Credential__mdt.getInstance(WEB_SERVICE_CREDENTIAL_DN_DOCUMENT_GENERATOR);
        }
    }

    private static Id addContentVersion(Blob blobResponse, DocInfoWrapper infoWrapper) {
        ContentVersion newContentVersion = new ContentVersion(
                VersionData = blobResponse,
                PathOnClient = infoWrapper.documentName + '.' + infoWrapper.exportFormat,
                Title = infoWrapper.documentName,
                TB_Application_Document__c = infoWrapper.applicationDocumentId
        );
        insert newContentVersion;
        return [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: newContentVersion.Id].ContentDocumentId;
    }

    public static HttpResponse sendPostRequest(String endPoint, String jsonBody) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod(POST_METHOD_PHRASE);
        request.setHeader(CONTENT_TYPE_PHRASE, JSON_APP_PHRASE);
        request.setBody(jsonBody);
        return new Http().send(request);
    }

    public static DocResponseWrapper getPostResponse(HttpResponse response, DocInfoWrapper infoWrapper) {
        DocResponseWrapper result;
        if(response.getStatusCode() != 200) {
            result = new DocResponseWrapper(response.getStatus(), false);
        }else {
            Id documentId = addContentVersion(response.getBodyAsBlob(), infoWrapper);
            result = new DocResponseWrapper(documentId);
        }
        return result;
    }

    public static ContentVersion prepareContentVersion(Blob blobResponse, DocRequestWrapper infoWrapper) {
        ContentVersion newContentVersion = new ContentVersion(
                VersionData = blobResponse,
                PathOnClient = infoWrapper.documentName + '.' + infoWrapper.exportFormat,
                Title = infoWrapper.documentName
                //on hold: how to connect it with application document
        );
        return newContentVersion;
    }


    @TestVisible
    private static Map<String, Map<String, Object>> generateSObjectsData(Id recordId, List<String> relatedSObjects) {
        Set<String> fieldsToGetSet = new Set<String>();
        String mainSObjectName = TB_SObjectUtils.getSObjectTypeFromId(recordId);
        Map<String, Set<String>> sObjectNameToFieldSet = new Map<String, Set<String>>();
        sObjectNameToFieldSet.put(mainSObjectName, new Set<String>());

        for (TB_Doc_Gen_Fields_Setting__mdt fieldsSetting : fieldsSettings) {
            if (fieldsSetting.TB_SObject_Name__c == mainSObjectName) {
                fieldsToGetSet.add(fieldsSetting.TB_SObject_Field__c);
                sObjectNameToFieldSet.get(mainSObjectName).add(fieldsSetting.TB_SObject_Field__c);
            }
        }
        for (String relatedSObjectName : relatedSObjects) {
            sObjectNameToFieldSet.put(relatedSObjectName, new Set<String>());
            String parentRelationName = TB_SObjectUtils.getSObjectRelationName(relatedSObjectName);
            for (TB_Doc_Gen_Fields_Setting__mdt fieldsSetting : fieldsSettings) {
                if (fieldsSetting.TB_SObject_Name__c == relatedSObjectName) {
                    fieldsToGetSet.add(parentRelationName + '.' + fieldsSetting.TB_SObject_Field__c);
                    sObjectNameToFieldSet.get(relatedSObjectName).add(fieldsSetting.TB_SObject_Field__c);
                }
            }
        }

        SObject record = TB_QueryBuilder.create()
                .selectId()
                .selectFields(fieldsToGetSet)
                .fromSObject(mainSObjectName)
                .andWhereIdIsEqual(recordId)
                .performSingle();

        return generateSObjectsDataFromRecord(record, sObjectNameToFieldSet, mainSObjectName);
    }

    private static Map<String, Map<String, Object>> generateSObjectsDataFromRecord(
            SObject record,
            Map<String, Set<String>> sObjectNameToFieldSet,
            String mainSObjectName
    ) {
        Map<String, Map<String, Object>> result = new Map<String, Map<String, Object>>();
        for (String sObjectName : sObjectNameToFieldSet.keySet()) {
            Map<String, String> sObjectNameMapping = getObjectNameMapping();
            String mappedKey = sObjectNameMapping.get(sObjectName);
            if(mappedKey != null) {
                result.put(mappedKey, new Map<String, Object>());
                for (String fieldName : sObjectNameToFieldSet.get(sObjectName)) {
                    Object value = sObjectName == mainSObjectName ?
                            record.get(fieldName) :
                            record.getSObject(TB_SObjectUtils.getSObjectRelationName(sObjectName)).get(fieldName);
                    result.get(mappedKey).put(fieldName, value);
                }
            }
        }
        return result;
    }

    private static List<TB_Doc_Gen_Fields_Setting__mdt> getDocGenFieldsSettings() {
        return (List<TB_Doc_Gen_Fields_Setting__mdt>) TB_QueryBuilder.create()
                .selectFields(new List<String>{'TB_SObject_Field__c', 'TB_SObject_Name__c'})
                .fromSObject('TB_Doc_Gen_Fields_Setting__mdt')
                .andWhereFieldIsEqual('TB_Active__c', true)
                .perform();
    }

    private static List<TB_Doc_Gen_SObjects_Mapping_Setting__mdt> getDocGenMappingSettings() {
        return (List<TB_Doc_Gen_SObjects_Mapping_Setting__mdt>) TB_QueryBuilder.create()
                .selectFields(new List<String>{'TB_Mapping_Phrase__c', 'TB_SObject_Name__c'})
                .fromSObject('TB_Doc_Gen_SObjects_Mapping_Setting__mdt')
                .andWhereFieldIsEqual('TB_Active__c', true)
                .perform();
    }

    private static Map<String, String> getObjectNameMapping() {
        Map<String, String> result = new Map<String, String>();
        for (TB_Doc_Gen_SObjects_Mapping_Setting__mdt mappingSetting : mappingSettings) {
            result.put(mappingSetting.TB_SObject_Name__c, mappingSetting.TB_Mapping_Phrase__c);
        }
        return result;
    }
    public abstract class Wrapper{
        public Boolean isCorrect;
        public String wrap() {
            return JSON.serialize(this);
        }
    }

    public class DocResponseWrapper extends Wrapper{
        public String message;
        public Id contentDocumentId;
        public DocResponseWrapper(Exception ex) {
            this.message = ex.getMessage();
            this.isCorrect = false;
        }

        public DocResponseWrapper(String message, Boolean isCorrect) {
            this.message = message;
            this.isCorrect = isCorrect;
        }

        public DocResponseWrapper(Id contentDocumentId) {
            this.contentDocumentId = contentDocumentId;
            this.isCorrect = true;
        }
    }

    public class DocInfoWrapper extends Wrapper{
        public Id recordId;
        public Id applicationDocumentId;
        public String templateId;
        public String documentName;
        public String exportFormat;
        public List<String> relatedSObjects;

        public DocInfoWrapper(String jsonString) {
            Map<String, Object> deserializedJsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            this.applicationDocumentId = (String) deserializedJsonMap.get(JSON_GEN_DOC_REQ_APP_DOCUMENT_ID_PHRASE);
            this.recordId = (String) deserializedJsonMap.get(JSON_GEN_DOC_REQ_RECORD_ID_PHRASE);
            this.templateId = (String) deserializedJsonMap.get(JSON_GEN_DOC_REQ_TEMPLATE_URL_PHRASE);
            this.documentName = (String) deserializedJsonMap.get(JSON_GEN_DOC_REQ_DOCUMENT_NAME_PHRASE);
            this.exportFormat = (String) deserializedJsonMap.get(JSON_GEN_DOC_REQ_EXPORT_FORMAT_PHRASE);
            this.relatedSObjects = new List<String>();
            for (Object relatedSObject : (List<Object>)deserializedJsonMap.get(JSON_GEN_DOC_REQ_RELATED_SOBJECTS_PHRASE)) {
                this.relatedSObjects.add(String.valueOf(relatedSObject));
            }
        }
    }

    public class DocRequestWrapper extends Wrapper{
        public String templateId;
        public String documentName;
        public String exportFormat;
        public Map<String, Map<String, Object>> data;

        public DocRequestWrapper(
                String templateId,
                String documentName,
                String exportFormat,
                Map<String, Map<String, Object>> data
        ) {
            this.templateId = templateId;
            this.documentName = documentName;
            this.exportFormat = exportFormat;
            this.data = data;
        }
    }

    @AuraEnabled
    public static SObject getApplicationDocument(String recordId) {
        String query = 'SELECT ' + objectFieldsToObjectApiName.get('TB_Application_Document__c')
                + ' FROM TB_Application_Document__c '
                + ' WHERE Id=:recordId';
        try {
            return Database.query(query);
        }catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    public final static Map<String, String> objectFieldsToObjectApiName = new Map<String,String> {
            'TB_Application_Document__c' => 'TB_Document_Template_External_Id__c, TB_Document_Name__c,' +
                    ' TB_Application__c, TB_Application__r.TB_x_Applicant_Full_Name__c, TB_Application__r.Name '
    };

    @AuraEnabled
    public static List<TB_Document_Template__c> getDocumentTemplates(String documentType) {
        return [
                SELECT Id, Name, TB_Document_Template_External_Id__c
                FROM TB_Document_Template__c
                WHERE TB_Document_Type__c =: documentType
                AND TB_Document_Template_External_Id__c != NULL
        ];
    }
}