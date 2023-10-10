public with sharing class TB_PdfGeneratorController {
    public static final String PARAM_CONTENT_DOCUMENT_ID = 'contentDocumentId';
    public static final String PARAM_APP_ID = 'applicationId';
    public static final String PARAM_EES_ID = 'evaluationStageId';
    public static final String PARAM_LANGUAGE = 'language';
    public static final String PARAM_EMPTY_STRING = '';
    public static final String PARAM_ERROR = 'ERROR';


    public ContentVersion version;
    public String currentRecordId {get;set;}
    public String applicationId {get;set;}
    public String evaluationStageId {get;set;}
    public String language { get; set; }

    public TB_PdfGeneratorController() {
        this.currentRecordId = ApexPages.currentPage().getParameters().get(PARAM_CONTENT_DOCUMENT_ID);
        this.applicationId = ApexPages.currentPage().getParameters().get(PARAM_APP_ID);
        this.evaluationStageId = ApexPages.currentPage().getParameters().get(PARAM_EES_ID);
        this.language =  ApexPages.currentPage().getParameters().get(PARAM_LANGUAGE);
    }

    public String getHtmlValue() {
        String returnValue;
        try {
            if (evaluationStageId == null) {
                String htmlValue = PARAM_EMPTY_STRING;
                ContentVersion version = [
                        SELECT VersionData
                        FROM ContentVersion
                        WHERE ContentDocumentId = :this.currentRecordId
                        AND IsLatest = TRUE
                        LIMIT 1
                ];

                htmlValue = version.VersionData.toString();
               returnValue = TB_HtmlMergeFieldUtils.getApplicationBasedHtmlValue(this.applicationId, htmlValue);
            } else {
                String eesName;
                String eeName;
                String htmlBody ='';
                for (TB_Data_Collection__c dc : [
                        SELECT
                                Name,
                                TB_Employee_Evaluation__c,
                                TB_Employee_Evaluation__r.Name,
                                TB_Employee_Evaluation_Stage__c,
                                TB_Employee_Evaluation_Stage__r.Name,
                                TB_Order__c,
                                TB_Value_Long_Text__c,
                                TB_Value_Text__c,
                                TB_Name_EN__c,
                                TB_Name_PL__c,
                                TB_Purpose__c,
                                TB_Data_Type__c
                        From TB_Data_Collection__c
                        WHERE
                        TB_Employee_Evaluation_Stage__c =: evaluationStageId
                        AND TB_Active__c = TRUE
                        ORDER BY TB_Order__c ASC
                ]) {
                    if (eesName == null) {
                        eeName = dc.TB_Employee_Evaluation__r.Name;
                    }
                    if (eesName == null) {
                        eesName = dc.TB_Employee_Evaluation_Stage__r.Name.replace('/', '_');
                    }
                    String value = language == TB_Constants.LANGUAGE_PL ? dc.TB_Name_PL__c : dc.TB_Name_EN__c;
                    if(value != null){
                        htmlBody += '<p><u>' + value + '</u></p>';
                    }
                    if (dc.TB_Purpose__c != 'Header') {
                        value = dc.TB_Value_Text__c != null ?
                                TB_DownloadFilesController.getCorrectLangValueField(language, dc.TB_Value_Text__c) :
                                TB_DownloadFilesController.getCorrectLangValueField(language, dc.TB_Value_Long_Text__c);
                        if (value == null) {
                            value = '&nbsp;';
                        }
                        htmlBody += '<p>' + value + '</p>';
                    }

                }
                returnValue = htmlBody;
            }
        } catch (Exception e) {
            returnValue = PARAM_ERROR;
            insert TB_LogUtils.registerLog(e, TB_PdfGeneratorController.class);
        }
        return returnValue;
    }
}