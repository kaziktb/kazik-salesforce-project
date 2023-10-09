public with sharing class TB_PhotoComponentController {

    @AuraEnabled
    public static String getApplicationDocument(hed__Application__c application) {
        try {
            return [
                SELECT Id, TB_Download_URL__c
                FROM TB_Application_Document__c
                WHERE TB_Application__c = :application.Id
                AND TB_Document_Name__c = 'Zdjęcie do legitymacji'
                ORDER BY CreatedDate DESC
                LIMIT 1
            ].TB_Download_URL__c;
        } catch(Exception e) {
//            insert TB_LogUtils.registerLog(e);
            return null;
        }
    }

    @AuraEnabled
    public static void deleteLastApplicationDocument(hed__Application__c application) {
        TB_Application_Document__c applicationDocument = [
            SELECT Id
            FROM TB_Application_Document__c
            WHERE TB_Application__c = :application.Id
            AND TB_Document_Name__c = 'Zdjęcie do legitymacji'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        if (applicationDocument != null) {
            ContentDocumentLink cdl = [
                SELECT Id, ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :applicationDocument.Id
            ];
            ContentDocument cd = [
                SELECT Id
                FROM ContentDocument
                WHERE Id = :cdl.ContentDocumentId
            ];
            try {
                delete cd;
                delete applicationDocument;
            } catch (Exception e) {
                insert TB_LogUtils.registerLog(e);
            }
        }
    }

    //todo: nieużywana do usunięcia ???
    @AuraEnabled
    public static String createContentDocument(String file, String fileName, hed__Application__c application) {
        ContentVersion contentVersion = new ContentVersion(
            Title = fileName,
            VersionData = Blob.valueOf(file),
            PathOnClient = fileName
        );
        insert contentVersion;
        ContentDocumentInfo info = new ContentDocumentInfo();
        info.documentId = contentVersion.ContentDocumentId;
        info.contentVersionId = contentVersion.Id;
        info.name = fileName;
        return createApplicationDocument(application, new List<Object>{info});
    }

    @AuraEnabled
    public static String createApplicationDocument(hed__Application__c application, List<Object> contentDocuments) {
        TB_Application_Document__c document = new TB_Application_Document__c(
            TB_Document_Name__c = 'Zdjęcie do legitymacji',
            TB_Document_Category__c = 'Photo',
            TB_Document_Type__c = 'Scan',
            TB_Output_Format__c = 'Original',
            TB_Application__c = application.Id,
            TB_Contact__c = application.hed__Applicant__c,
            TB_Status__c = 'To_Verify',
            TB_Order__c = 0
        );
        insert document;
        return createLinksForUploadedFiles(document.Id, contentDocuments);
    }

    public static String createLinksForUploadedFiles(String applicationDocumentId, List<Object> contentDocuments) {
        List<ContentDocumentLink> cntDocumentLinks = new List<ContentDocumentLink>();
        List<ContentDocumentInfo> documentsInfo = (List<ContentDocumentInfo>) JSON.deserialize(JSON.serialize(contentDocuments), List<ContentDocumentInfo>.class);
        for(ContentDocumentInfo singleDocumentInfo : documentsInfo) {
            ContentDocumentLink contentDocumentLink = prepareContentDocumentLink(singleDocumentInfo.documentId, applicationDocumentId);
            cntDocumentLinks.add(contentDocumentLink);
        }

        List<Database.SaveResult> res = Database.insert(cntDocumentLinks, false);
        Boolean resultFlag = true;
        for (Database.SaveResult saveResult : res) {
            if(!saveResult.isSuccess()) {
                resultFlag = false;
                insert TB_LogUtils.errorMailMessage(String.valueOf(saveResult), TB_EducationHistoryController.class);
            }
        }

        if(resultFlag) {
            TB_Application_Document__c applicationDocument = new TB_Application_Document__c();
            applicationDocument.Id = applicationDocumentId;
            applicationDocument.TB_Status__c = 'To_Verify';
            applicationDocument.TB_Document_File_Date_Time__c = System.today();
            //todo: wgrywamy 1 plik
            applicationDocument.TB_Content_Version_Id__c =  documentsInfo[0].contentVersionId;
            try {
                update applicationDocument;
                TB_Application_Document__c actuallyApplicationDocument = [
                    SELECT Id, TB_Document_Name_PL__c, TB_Document_Name_EN__c,
                        TB_Document_Category__c, toLabel(TB_Document_Category__c) TB_Document_Category_Label,
                        TB_Experience__c, TB_Status__c, toLabel(TB_Status__c) TB_Status_Label, TB_Comment__c,
                        TB_Download_URL__c, TB_Content_Document_Id__c
                    FROM TB_Application_Document__c
                    WHERE Id = :applicationDocumentId
                ];
                return JSON.serialize(actuallyApplicationDocument);
            }catch(Exception e) {
                resultFlag = false;
                return 'UPDATE_ERROR';
            }
        }else {
            insert TB_LogUtils.errorMailMessage('Error on insert ContentLinks', TB_EducationHistoryController.class);
            return 'CREATE_ERROR';
        }
    }

    private static ContentDocumentLink prepareContentDocumentLink(Id documentId, Id applicationDocumentId){
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink (
            ContentDocumentId = documentId,
            LinkedEntityId = applicationDocumentId,
            ShareType = 'I',
            Visibility = 'AllUsers'
        );
        return contentDocumentLink;
    }

    private class ContentDocumentInfo {
        public String documentId;
        public String contentVersionId;
        public String name;
    }
}