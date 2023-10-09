/**
 * Created by Kamil Pilarski on 20.12.2021.
 */

public with sharing class TB_HtmlMergeFieldUtils {
    public static final String PARAM_PHOTO = 'Photo';
    public static final String PARAM_HEIGHT = 'height';
    public static final String PARAM_WIDTH = 'width';
    public static final String PARAM_WRONG_TAG = '{...}';
    public static final String PARAM_EMPTY_FIELD = '-';

    public static String getApplicationBasedHtmlValue(Id applicationId, String htmlValue) {
        try {
            hed__Application__c application = TB_ApplicationRetriever.retrieveAllApplicationFields(applicationId);

            htmlValue = clearHtmlValue(htmlValue);

            Integer timesOccur = htmlValue.countMatches('${');

            for (Integer i = 0; i < timesOccur; i++) {
                String initFieldName = htmlValue.substringBetween('${', '}');

                if(initFieldName == null){
                    break;
                }

                String fieldValue;
                if(initFieldName.contains(PARAM_PHOTO) && initFieldName.contains(PARAM_HEIGHT) && initFieldName.contains(PARAM_WIDTH)){
                    try {

                        ID photoVersionId = TB_DocumentsDataController.getApplicantPhoto(applicationId);

                        List<String> parameters = new List<String>();
                        parameters = initFieldName.split(',');

                        List<String> heightParameter = parameters[1].split(':');
                        List<String> widthParameter = parameters[2].split(':');
                        String height = heightParameter[heightParameter.size() - 1];
                        String width = widthParameter[widthParameter.size() - 1];

                        htmlValue = htmlValue.replace('${' + initFieldName + '}', '<img src = "/sfc/servlet.shepherd/version/download/'
                            + photoVersionId + '" style="height:' + height + '%; width:' + width + '%;"/>');
                    } catch(Exception e) {
                        htmlValue = htmlValue.replace('${' + initFieldName + '}', PARAM_WRONG_TAG);
                    }
                } else {
                    try {
                        String objectName = initFieldName.substringBefore('.');
                        String fieldName;
                        String relationshipName = TB_Constants.TB_DOCUMENT_GENERATOR_DICTIONARY.get(objectName);
                        fieldName = initFieldName.replace(objectName, relationshipName);
                        fieldName = fieldName.removeStart('.');

                        if (fieldName.contains('.')) {
                            SObject sObj = application.getSObject(fieldName.substringBefore('.'));
                            fieldValue = String.valueOf(sObj.get(fieldName.substringAfter('.')));
                        } else {
                            fieldValue = String.valueOf(application.get(fieldName));
                        }
                        if(fieldValue != null){
                            fieldValue = fieldValue.escapeHtml4();
                            htmlValue = htmlValue.replace('${' + initFieldName + '}', fieldValue);
                        } else {
                            htmlValue = htmlValue.replace('${' + initFieldName + '}', PARAM_EMPTY_FIELD);
                        }
                    } catch(Exception e) {
                        htmlValue = htmlValue.replace('${' + initFieldName + '}', PARAM_WRONG_TAG);
                    }
                }
            }
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
        }
        return htmlValue;
    }

    public static String clearHtmlValue(String htmlValue) {
        if(htmlValue.contains('<body') && htmlValue.contains('</body>')){
            htmlValue = htmlValue.substringBetween('<body', '</body>');
            for(Integer i = 0; i < htmlValue.length(); i++){
                if(htmlValue.substring(i, i+1) == '>'){
                    htmlValue = htmlValue.substring(i + 1, htmlValue.length());
                    break;
                }
            }
        }

        htmlValue = htmlValue.replaceAll('<div align="center">', '<div align="left">');
        //htmlValue = htmlValue.replaceAll('style="border-collapse:collapse;border:none"', 'style="width:100.0%;border-collapse:collapse;border:none"');

        htmlValue = htmlValue.replaceAll('border="0"', 'border="1"');
        //
        htmlValue = htmlValue.replaceAll('class="MsoNormal"', '');
        htmlValue = htmlValue.replaceAll('<span style="text-decoration:none">&nbsp;</span>', '');
        htmlValue = htmlValue.replaceAll('<p >', '<div>');
        htmlValue = htmlValue.replaceAll('<span lang="PL" style="font-size:8.0pt;font-family:&quot;Myriad Pro Light&quot;,sans-serif">', '<span>');
        htmlValue = htmlValue.replaceAll('<p  align="right" style="text-align:right">', '<div align="right" style="text-align:right">');
        htmlValue = htmlValue.replaceAll('<p  align="center" style="text-align:center">', '<div align="center" style="text-align:center">');
        htmlValue = htmlValue.replaceAll('<p  style="line-height:115%">', '<div>');
        htmlValue = htmlValue.replaceAll('<p  align="right" style="text-align:right;line-height:115%">', '<div align="right" style="text-align:right;">');
        htmlValue = htmlValue.replaceAll('</p>', '</div>');
        //htmlValue = htmlValue.replaceAll('<b>', '<strong>');
        //htmlValue = htmlValue.replaceAll('</b>', '</strong>');
        htmlValue = htmlValue.replaceAll('font-family:"Myriad Pro Light",sans-serif', '');
        htmlValue = htmlValue.replaceAll('font-family:"Myriad Pro Light",sans-serif;', '');
        htmlValue = htmlValue.replaceAll('font-family:"Arial",sans-serif;', '');
        htmlValue = htmlValue.replaceAll('font-family:"Arial",sans-serif', '');
        htmlValue = htmlValue.replaceAll('font-family:"Times New Roman",serif;', '');
        htmlValue = htmlValue.replaceAll('font-family:"Times New Roman",serif', '');
        htmlValue = htmlValue.replaceAll('font-family:"Calibri",sans-serif;', '');
        htmlValue = htmlValue.replaceAll('font-family:"Calibri",sans-serif', '');
        htmlValue = htmlValue.replaceAll('font-family:', '');
        htmlValue = htmlValue.replaceAll(',sans-serif', '');
        htmlValue = htmlValue.replaceAll(',sans-serif;', '');
        htmlValue = htmlValue.replaceAll(',sans-serif,', '');
        htmlValue = htmlValue.replaceAll(',serif;', '');
        htmlValue = htmlValue.replaceAll(',serif,', '');
        htmlValue = htmlValue.replaceAll(',serif', '');
        htmlValue = htmlValue.replaceAll('"Calibri"', '');
        htmlValue = htmlValue.replaceAll('"Arial"', '');
        htmlValue = htmlValue.replaceAll('"Times New Roman"', '');
        htmlValue = htmlValue.replaceAll('class=MsoNormal', '');
        htmlValue = htmlValue.replaceAll('class=MsoTableGrid', '');
        htmlValue = htmlValue.replaceAll('lang=PL', '');
        htmlValue = htmlValue.replaceAll('lang=EN-US', '');
        htmlValue = htmlValue.replaceAll('background:white', '');

        return htmlValue;
    }
}