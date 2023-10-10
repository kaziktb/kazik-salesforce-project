public without sharing class TB_FormsDataRetrieverController {
    @AuraEnabled
    public static  Map<String, AdmissionsContentWrapper> getAdmissionsContent() {
        List<TB_JSON_Wrapper__c> jsonWrappers = [
            SELECT TB_Wrapper_Value__c
            FROM TB_JSON_Wrapper__c
            WHERE TB_Object_API_Name__c ='TB_Admissions_Content__c'
        ];

        Map<String, AdmissionsContentWrapper> recordCodeToWrappers = new Map<String, AdmissionsContentWrapper>();
        for(TB_JSON_Wrapper__c singleJsonWrapper : jsonWrappers) {
            TB_Admissions_Content__c singleContent = (TB_Admissions_Content__c) JSON.deserialize(singleJsonWrapper.TB_Wrapper_Value__c, TB_Admissions_Content__c.class);
            AdmissionsContentWrapper singleWrapper = new AdmissionsContentWrapper(singleContent);
            recordCodeToWrappers.put(singleWrapper.recordCode, singleWrapper);
        }

        return recordCodeToWrappers;
    }

    public class AdmissionsContentWrapper {
        @AuraEnabled public TB_Admissions_Content__c content {get;set;}
        @AuraEnabled public String contentValuePL {get;set;}
        @AuraEnabled public String contentValueEN {get;set;}
        @AuraEnabled public String contentType {get;set;}
        @AuraEnabled public String displayMode {get;set;}
        @AuraEnabled public String recordCode {get;set;}
        @AuraEnabled public String header {get;set;}

        public AdmissionsContentWrapper (TB_Admissions_Content__c admissionsContent) {
            this.content = admissionsContent;
            this.contentType = getContentType(admissionsContent.TB_Content_Sub_Type__c);
            this.header = getHeader(admissionsContent.TB_Content_Sub_Type__c);
            this.contentValuePL = getPlainTextValue(admissionsContent.TB_Content_PL__c);
            this.contentValueEN = getPlainTextValue(admissionsContent.TB_Content_EN__c);
            this.displayMode = admissionsContent.TB_Display_Mode__c;
            this.recordCode = admissionsContent.TB_Record_Code__c;
        }
    }

    private static String getPlainTextValue(String richTextValue) {
        if (richTextValue != null && richTextValue.contains('<')) {
            String plainText = richTextValue.replaceAll('<[^>]+>', ' ');
            plainText = plainText.unescapeHtml4();
            return plainText;
        }
        return null;
    }

    private static String getContentType(String contentType) {
        switch on contentType {
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

    private static String getHeader(String contentType) {
        switch on contentType {
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