public without sharing class TB_FormsPortalDataRetrieverController {

    private static final String MESSAGE_CONTENT_TYPE = 'Message';
    private static final String RICH_TEXT_HTML_START_TAG = '<';
    private static final String PLAIN_TEXT_PATTERN = '<[^>]+>';

    @AuraEnabled
    public static  Map<String, PortalContentWrapper> getPortalContent(String portalName) {
        List<TB_JSON_Wrapper__c> jsonWrappers = new List<TB_JSON_Wrapper__c>();
        Map<String, PortalContentWrapper> recordCodeToWrappers = new Map<String, PortalContentWrapper>();
        try{

            jsonWrappers = [
            SELECT TB_Wrapper_Value__c
            FROM TB_JSON_Wrapper__c
            WHERE TB_Object_API_Name__c ='TB_Admissions_Content__c' 
            ];

            for(TB_JSON_Wrapper__c singleJsonWrapper : jsonWrappers) {
                TB_Admissions_Content__c singleContent = (TB_Admissions_Content__c) JSON.deserialize(singleJsonWrapper.TB_Wrapper_Value__c, TB_Admissions_Content__c.class);
                if(singleContent.TB_Portal__c == portalName){
                    PortalContentWrapper singleWrapper = new PortalContentWrapper(singleContent);
                    recordCodeToWrappers.put(singleWrapper.recordCode, singleWrapper);
                }
            }
                
        }catch(Exception e) {
            TB_LogUtils.registerLogFuture(
                e.getMessage(),
                TB_FormsPortalDataRetrieverController.class.getName()
            );
        }
        return recordCodeToWrappers;
        
    }

    @AuraEnabled
    public static Map<String, PortalContentWrapper> getAllPortalContent() {
        List<TB_JSON_Wrapper__c> jsonWrappers = new List<TB_JSON_Wrapper__c>();
        Map<String, PortalContentWrapper> recordCodeToWrappers = new Map<String, PortalContentWrapper>();
        try{

            jsonWrappers = [
            SELECT TB_Wrapper_Value__c
            FROM TB_JSON_Wrapper__c
            WHERE TB_Object_API_Name__c ='TB_Admissions_Content__c' 
            ];

            for(TB_JSON_Wrapper__c singleJsonWrapper : jsonWrappers) {
                TB_Admissions_Content__c singleContent = (TB_Admissions_Content__c) JSON.deserialize(singleJsonWrapper.TB_Wrapper_Value__c, TB_Admissions_Content__c.class);
                PortalContentWrapper singleWrapper = new PortalContentWrapper(singleContent);
                recordCodeToWrappers.put(singleWrapper.recordCode, singleWrapper);
            }

        }catch(Exception e){
            TB_LogUtils.registerLogFuture(
                e.getMessage(),
                TB_FormsPortalDataRetrieverController.class.getName()
            );
        }
        return recordCodeToWrappers;
        
    }

    public class PortalContentWrapper {
        @AuraEnabled public TB_Admissions_Content__c content {get;set;}
        @AuraEnabled public String contentValuePL {get;set;}
        @AuraEnabled public String contentValueEN {get;set;}
        @AuraEnabled public String contentSubType {get;set;}
        @AuraEnabled public String contentType {get;set;}
        @AuraEnabled public String displayMode {get;set;}
        @AuraEnabled public String recordCode {get;set;}
        @AuraEnabled public String header {get;set;}

        public PortalContentWrapper (TB_Admissions_Content__c portalContent) {
            this.content = portalContent;
            this.contentSubType = getContentType(portalContent.TB_Content_Sub_Type__c);
            this.contentType = portalContent.TB_Content_Type__c;
            this.header = getHeader(portalContent.TB_Content_Sub_Type__c);
            this.contentValuePL = getPlainTextValue(portalContent.TB_Content_PL__c,this.contentType);
            this.contentValueEN = getPlainTextValue(portalContent.TB_Content_EN__c,this.contentType);
            this.displayMode = portalContent.TB_Display_Mode__c;
            this.recordCode = portalContent.TB_Record_Code__c;
        }
    }

    private static String getPlainTextValue(String richTextValue, String contentTypeValue) {
        String toReturn = richTextValue;
        if(contentTypeValue != MESSAGE_CONTENT_TYPE){
            if (String.isNotBlank(richTextValue) && richTextValue.contains(RICH_TEXT_HTML_START_TAG)) {
                toReturn = richTextValue.replaceAll(PLAIN_TEXT_PATTERN, '');
                toReturn = toReturn.unescapeHtml4();
            }
        }
        return toReturn;
        
    }

    private static String getContentType(String contentSubType) {
        switch on contentSubType {
            when 'Information' {
                return 'success';
            }
            when 'Warning' {
                return 'warning';
            }
            when else {
                return 'error';
            }
        }
    }

    private static String getHeader(String contentSubType) {
        switch on contentSubType {
            when 'Information' {
                return 'MODAL.HEADER.INFO';
            }
            when 'Warning' {
                return 'MODAL.HEADER.WARNING';
            }
            when else {
                return 'MODAL.HEADER.ERROR';
            }
        }
    }
}