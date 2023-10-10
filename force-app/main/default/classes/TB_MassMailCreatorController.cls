/**
 * Created by Aneta on 29/11/2022.
 */

public with sharing class TB_MassMailCreatorController {

    public static String SENDER_EMAIL = 'xdocSenderEmail';
    public static String USER_ADDRESS_EMAIL = 'userAddressEmail';
    public static List<String> listOfObjects = new List<String>{'Contact', 'hed__Application__c'};
    public static String OBJECT_END_POINT = '/services/data/v53.0/sobjects/';
    public static Map<Boolean,String> sourceForEmailFields = new Map<Boolean, String>{
        true => 'Custom_Metadata',
        false => 'API_NAME'
    };

    @AuraEnabled
    public static String getMassMailLimits() {
        try {
            return JSON.serialize(TB_Mass_Mail_Creator_Setting__mdt.getInstance('TB_Limit_Setting'));
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    @AuraEnabled
    public static String getDataForCreator(Boolean fromCustomMeta) {
        try {
            if(fromCustomMeta == null) {
                insert TB_LogUtils.registerLog('Undefined flag for getAddresses from CustomMetadata', TB_MassMailCreatorController.class);
                fromCustomMeta = false;
            }
            return JSON.serialize(
                new MassMailCreatorWrapper(
                    getEmailTemplates(),
                    getEmailFieldsForObjects(listOfObjects, sourceForEmailFields.get(fromCustomMeta)),
                    TB_CreateEmailToSendController.getAllOrgWideAddresses(),
                    getEnhancedLetterheads()
                )
            );
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    @AuraEnabled(Cacheable=true)
    public static List<SObject> getEmailTemplates() {
        return [
            SELECT Id, Name, Subject
            FROM EmailTemplate
            WHERE IsActive =: TRUE
            AND (NOT DeveloperName LIKE 'MASS_MAIL_CREATOR_%')
            ORDER BY Name ASC
        ];
    }

    @AuraEnabled
    public static EmailTemplate getEmailTemplatesHtmlValue(Id templateId) {
        try {
            return [
                    SELECT HtmlValue, Subject
                    FROM EmailTemplate
                    WHERE Id =: templateId
            ];
        }catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    private static Map<String,List<String>> getEmailFieldsForObjects(List<String> listOfObjects, String source) {
        Map<String, List<String>> emailsFieldsForObject = new Map<String, List<String>>();
        if(source == sourceForEmailFields.get(false)) {
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            for (String apiName : listOfObjects) {
                for (Schema.SObjectField field : gd.get(apiName).getDescribe().fields.getMap().values()) {
                    if (Schema.DisplayType.EMAIL == field.getDescribe().getType()
                        || (
                        field.getDescribe().getName().toLowerCase().contains('email')
                            && Schema.DisplayType.STRING == field.getDescribe().getType()
                    )) {
                        List<String> newFieldsList = emailsFieldsForObject.containsKey(apiName)
                            ? emailsFieldsForObject.get(apiName) : new List<String>();
                        newFieldsList.add(field.getDescribe().getName());
                        emailsFieldsForObject.put(apiName, newFieldsList);
                    }
                }
            }
            return emailsFieldsForObject;
        }else {
            for(TB_Email_Field_for_Create_and_Send_Email__mdt singleMetaRecord : TB_Email_Field_for_Create_and_Send_Email__mdt.getAll().values()) {
                List<String> newFieldsList = emailsFieldsForObject.containsKey(singleMetaRecord.TB_Object_Type__c)
                    ? emailsFieldsForObject.get(singleMetaRecord.TB_Object_Type__c) : new List<String>();
                newFieldsList.add(singleMetaRecord.TB_Email_Field_Api_Name__c);
                emailsFieldsForObject.put(singleMetaRecord.TB_Object_Type__c, newFieldsList);
            }
            return emailsFieldsForObject;
        }
    }

    private static List<EnhancedLetterhead> getEnhancedLetterheads() {
        return [SELECT Id, Name FROM EnhancedLetterhead];
    }

    @AuraEnabled
    public static String getFooter(Id footerId) {
        return [SELECT LetterheadFooter FROM EnhancedLetterhead WHERE Id =: footerId].LetterheadFooter;
    }

    @AuraEnabled
    public static List<ListView> getListViews(String objectApiName) {
        try {
            if(listOfObjects.contains(objectApiName)) {
                List<ListView> listViews = [
                    SELECT Id, Name, DeveloperName, NamespacePrefix,
                        SobjectType, IsSoqlCompatible
                    FROM ListView
                    WHERE SobjectType = :objectApiName
                    ORDER BY Name
                ];
                return listViews;
            }else {
                return null;
            }
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    @AuraEnabled
    public static String getRecipients(String listViewId, List<String> apiNameList, String objectApiName, String senderEmailType) {
        List<TB_CreateMailWrapper> objectWrappers = prepareRecipients(listViewId, apiNameList, objectApiName, senderEmailType);
        if(objectWrappers == null) {
            return 'EXCEPTION';
        }else {
            return JSON.serialize(objectWrappers);
        }
    }

    @AuraEnabled
    public static String getListViewQuery(String listViewId, String objectApiName) {
        try {
            return getFiltersFromQuery(getQueryFromListViewsId(listViewId, objectApiName));
        }catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    private static Map<String,Id> prepareOrgWideAddressesMap() {
        Map<String,Id> orgWideAddressesMap = new Map<String,Id>();
        for(OrgWideEmailAddress singleOrgWideEmail : TB_CreateEmailToSendController.getAllOrgWideAddresses()) {
            orgWideAddressesMap.put(singleOrgWideEmail.Address, singleOrgWideEmail.Id);
        }
        return orgWideAddressesMap;
    }

    private static List<TB_CreateMailWrapper> prepareRecipients(
            String listViewId, List<String> apiNameList,
            String objectApiName, String senderEmailType
    ) {
        String url = URL.getSalesforceBaseUrl().toExternalForm();
        Map<String,Id> orgWideAddressesMap = prepareOrgWideAddressesMap();

        try {
            String filterQuery = getFiltersFromQuery(getQueryFromListViewsId(listViewId, objectApiName));
            if(filterQuery != null) {
                List<TB_CreateMailWrapper> mailWrappers = new List<TB_CreateMailWrapper>();
                for(SObject singleObject : Database.query(prepareRecipientsQuery(filterQuery, apiNameList, objectApiName))) {
                    TB_CreateMailWrapper singleWrapper = new TB_CreateMailWrapper();

                    singleWrapper.record = singleObject;
                    singleWrapper.link = url + '/lightning/r/' + objectApiName +'/' + singleObject.Id + '/view';
                    String emailAddresses = '';
                    for (String emailApiName : apiNameList) {
                        emailApiName = emailApiName.trim();
                        if (singleObject.get(emailApiName) != null) emailAddresses += (String.valueOf(singleObject.get(emailApiName))) + ',';
                    }

                    if(emailAddresses.length() < 1) {
                        singleWrapper.sendMailFlag = false;
                        singleWrapper.validEmailAddresses = 'EMPTY ALL EMAIL FIELDS';
                    }else {
                        singleWrapper.sendMailFlag = true;

                        String contactId = '';
                        if(objectApiName == 'Contact'){
                            contactId = singleObject.Id;
                        }else if(objectApiName == 'hed__Application__c') {
                            contactId = String.valueOf(singleObject.get('hed__Applicant__c'));
                        }

                        singleWrapper.contactId = contactId;
                        if(senderEmailType == SENDER_EMAIL) {
                            singleWrapper.orgWideAddressEmailId = orgWideAddressesMap.get(String.valueOf(singleObject.get('TB_x_Sender_Email__c')));
                        }else if(senderEmailType != USER_ADDRESS_EMAIL) {
                            singleWrapper.orgWideAddressEmailId = senderEmailType;
                            singleWrapper.relatesTo = singleObject.Id;
                        }
                    }
                    mailWrappers.add(singleWrapper);
                }
                return mailWrappers;
            }else {
                return null;
            }
        }catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    public static String prepareRecipientsQuery(String filterQuery, List<String> apiNameList, String objectType) {
        String query = 'SELECT Id, Name, ';
        if(objectType=='hed__Application__c') {
            query+=' hed__Applicant__c, TB_x_Sender_Email__c, ';
        }

        for(String singleApiName : apiNameList) {
            query += singleApiName + ', ';
        }
        query = removeLastChars(query, 2);
        query += ' FROM ' + filterQuery + ' LIMIT 4800';
        return query;
    }

    public static String getQueryFromListViewsId(String recordId, String objectApiName) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + OBJECT_END_POINT + objectApiName +'/listviews/' + recordId + '/describe');
        req.setMethod('GET');
        req.setHeader('Authorization',  'Bearer ' + fetchUserSessionId());
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String query = (String) TB_WebserviceUtils.fetchFieldValueFromJSON(
            'query', res.getBody()
        );
        return query;
    }

    @AuraEnabled
    public static Integer getActualMassEmailLimit() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v56.0/limits');
        req.setMethod('GET');
        req.setHeader('Authorization',  'Bearer ' + fetchUserSessionId());

        Http http = new Http();
        HTTPResponse res = http.send(req);
        Integer remaining = (Integer) TB_WebserviceUtils.fetchFieldValueFromJSON(
            'SingleEmail.Remaining', res.getBody()
        );
        return remaining;
    }

    private static String getFiltersFromQuery(String query) {
        if(query != null) {
            return query.split('FROM')[1];
        }else {
            return null;
        }
    }

    private static String removeLastChars(String s, Integer counter) {
        return (s == null || s.length() == 0) ? null : (s.substring(0, s.length() - counter));
    }

    private static String fetchUserSessionId(){
        PageReference visualForcePage = new PageReference(
            '/apex/TB_MassMailCreatorPage'
        );
        String content = Test.isRunningTest() ? 'Mass_Mail_Creator_StartSESSION_IDMass_Mail_Creator_End' : visualforcePage.getContent().toString();
        Integer s = content.indexOf('Mass_Mail_Creator_Start') + 'Mass_Mail_Creator_Start'.length(),
            e = content.indexOf('Mass_Mail_Creator_End');
        return content.substring(s, e);
    }

    public class MassMailCreatorWrapper {
        public List<SObject> templates {get;set;}
        public Map<String, List<String>> emailsFieldsForObjectApiNames {get;set;}
        public List<OrgWideEmailAddress> orgWideEmailAddresses {get;set;}
        public List<EnhancedLetterhead> footers {get;set;}

        public MassMailCreatorWrapper(
                List<SObject> templates,
                Map<String, List<String>> emailsFieldsForObjectApiNames,
                List<OrgWideEmailAddress> orgWideEmailAddresses,
                List<EnhancedLetterhead> footers
        ) {
            this.templates = templates;
            this.emailsFieldsForObjectApiNames = emailsFieldsForObjectApiNames;
            this.orgWideEmailAddresses = orgWideEmailAddresses;
            this.footers = footers;
        }
    }
}