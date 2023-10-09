public with sharing class TB_PdfControllerLwc {
    @AuraEnabled
    public static String generatePdfDocumentsForGivenTemplate(ID documentTemplateId, String applicationsIdsString){
        List<ID> applicationsIds = applicationsIdsString.replace('[', '').replace(']', '').replace(' ', '').split(',');
        List<hed__Application__c> applications = [SELECT Name, hed__Applicant__r.FirstName, hed__Applicant__r.LastName, hed__Applicant__r.TB_Communication_Language__c FROM hed__Application__c WHERE ID IN :applicationsIds];
        TB_Document_Template__c documentTemplate;
        ID contentDocumentId;
        Zippex documentsZip = new Zippex();

        try{
            documentTemplate = [
                SELECT TB_Output_Format__c, TB_Display_Name_EN__c, TB_Display_Name_PL__c
                FROM TB_Document_Template__c
                WHERE ID = :documentTemplateId
                LIMIT 1
            ];
    
            contentDocumentId = [
                    SELECT ContentDocumentId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId = :documentTemplateId
                    AND ContentDocument.FileExtension = :TB_Constants.TB_PARAM_HTML
                    ORDER BY ContentDocument.CreatedDate DESC
                    LIMIT 1
            ].ContentDocumentId;
        } catch(QueryException qe){
            return 'There is problem with Document Template, you should check it.';
        }

        PageReference rawDocument;
        String outputFormat = documentTemplate.TB_Output_Format__c;
        String zipFileName = 'Wygenerowane_dokumenty_dla_wybranych_aplikacji';
        String fileName = 'fileError';

        try{
            for(hed__Application__c application : applications){
                fileName = application.Name + '_' + application.hed__Applicant__r.FirstName + '_' + application.hed__Applicant__r.LastName + '_';
                if(application.hed__Applicant__r.TB_Communication_Language__c == TB_Constants.TB_COMMUNICATION_LANGUAGE_ENGLISH){
                    switch on outputFormat {
                        when 'PDF' {
                            fileName += documentTemplate.TB_Display_Name_EN__c + TB_Constants.TB_PARAM_PDF_EXTENSION;
                            rawDocument = Page.TB_PdfGenerator;//tutaj wykonuje się getHtmlValue()
                        }
                        when else {
                            fileName += documentTemplate.TB_Display_Name_EN__c + TB_Constants.TB_PARAM_HTML_EXTENSION;
                            rawDocument = Page.TB_HtmlGenerator;
                        }
                    }
                } else {
                    switch on outputFormat {
                        when 'PDF' {
                            fileName += documentTemplate.TB_Display_Name_PL__c + TB_Constants.TB_PARAM_PDF_EXTENSION;
                            rawDocument = Page.TB_PdfGenerator;
                        }
                        when else {
                            fileName += documentTemplate.TB_Display_Name_PL__c + TB_Constants.TB_PARAM_HTML_EXTENSION;
                            rawDocument = Page.TB_HtmlGenerator;
                        }
                    }
                }
        
                rawDocument.getParameters().put(TB_Constants.TB_CONTENT_DOCUMENT_ID_LABEL, contentDocumentId);
                rawDocument.getParameters().put(TB_Constants.TB_APP_ID_LABEL, application.ID);
                
                documentsZip.addFile(fileName, rawDocument.getContent(), null);
            }
        } catch (VisualforceException e) {
            documentsZip.addFile(fileName, Blob.valueOf(TB_Constants.TB_PARAM_UNEXPECTED_ERROR), null);
        } catch(Exception e){
            return e.getMessage() + ' ' + e.getLineNumber();
        }

        ID zipVersionFileId;

        try{
            ContentVersion zipVersionFile = new ContentVersion(
                Title = zipFileName,
                PathOnClient = zipFileName + '.zip',
                VersionData = documentsZip.getZipArchive()
            );
            Database.insert(zipVersionFile);
            zipVersionFileId = zipVersionFile.ID;
        } catch(Exception e){
            return e.getMessage() + ' ' + e.getLineNumber();
        }
        
        return zipVersionFileId;
    }

    @AuraEnabled
    public static String createPdfFile(String recordId) {
        TB_Application_Document__c applicationDocument;
        TB_Document_Template__c documentTemplate;
        ContentDocumentLink link;

        try{
            applicationDocument = [
                SELECT TB_Application__c, TB_Document_Template__c, TB_Application__r.hed__Applicant__r.TB_Communication_Language__c, TB_Document_Name_EN__c, TB_Document_Name_PL__c
                FROM TB_Application_Document__c
                WHERE ID = :recordId
                LIMIT 1
            ];
            ID documentTemplateId = applicationDocument.TB_Document_Template__c;
            documentTemplate = [
                SELECT TB_Output_Format__c
                FROM TB_Document_Template__c
                WHERE ID = :documentTemplateId
                LIMIT 1
            ];
            link = [
                    SELECT ContentDocumentId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId = :documentTemplateId
                    AND ContentDocument.FileExtension = :TB_Constants.TB_PARAM_HTML
                    ORDER BY ContentDocument.CreatedDate DESC
                    LIMIT 1
            ];
        } catch(Exception e){
            insert TB_LogUtils.registerLog(e, TB_PdfControllerLwc.class);
            return null;
        }
        

        PageReference rawDocument;
        String outputFormat = documentTemplate.TB_Output_Format__c;
        String fileName = TB_Constants.PARAM_EMPTY_STRING;
        if(applicationDocument.TB_Application__r.hed__Applicant__r.TB_Communication_Language__c == TB_Constants.TB_COMMUNICATION_LANGUAGE_ENGLISH){
            switch on outputFormat {
                when 'PDF' {
                    fileName = applicationDocument.TB_Document_Name_EN__c + TB_Constants.TB_PARAM_PDF_EXTENSION;
                    rawDocument = Page.TB_PdfGenerator;//tutaj wykonuje się getHtmlValue()
                }
                when else {
                    fileName = applicationDocument.TB_Document_Name_EN__c + TB_Constants.TB_PARAM_HTML_EXTENSION;
                    rawDocument = Page.TB_HtmlGenerator;
                }
            }
        } else {
            switch on outputFormat {
                when 'PDF' {
                    fileName = applicationDocument.TB_Document_Name_PL__c + TB_Constants.TB_PARAM_PDF_EXTENSION;
                    rawDocument = Page.TB_PdfGenerator;
                }
                when else {
                    fileName = applicationDocument.TB_Document_Name_PL__c + TB_Constants.TB_PARAM_HTML_EXTENSION;
                    rawDocument = Page.TB_HtmlGenerator;
                }
            }
        }

        ContentVersion contVerFile = new ContentVersion();
        
        rawDocument.getParameters().put(TB_Constants.TB_CONTENT_DOCUMENT_ID_LABEL, link.ContentDocumentId);
        rawDocument.getParameters().put(TB_Constants.TB_APP_ID_LABEL, applicationDocument.TB_Application__c);
        
        try {
            contVerFile.VersionData = rawDocument.getContent();
        } catch (VisualforceException e) {
            contVerFile.VersionData = Blob.valueOf(TB_Constants.TB_PARAM_UNEXPECTED_ERROR);
        }
        contVerFile.Title = fileName;
        contVerFile.PathOnClient = fileName;
        contVerFile.TB_Application_Document__c = recordId;
        Database.insert(contVerFile);

        return [SELECT TB_Download_URL__c FROM TB_Application_Document__c WHERE Id = :recordId].TB_Download_URL__c;
    }
}