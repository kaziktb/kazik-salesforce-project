public with sharing class TB_DownloadFilesController {

    @AuraEnabled
    public static String prepareZip(String language, String eeId) {
        String returnValue;
        try {
            List<TB_Employee_Evaluation_Stage__c> eeIdToListEESId = new List<TB_Employee_Evaluation_Stage__c>();
            for (TB_Employee_Evaluation_Stage__c ees : [
                    SELECT
                            Id,
                            Name,
                            TB_Employee_Evaluation__c,
                            TB_Employee_Evaluation__r.Name
                    FROM TB_Employee_Evaluation_Stage__c
                    WHERE TB_Employee_Evaluation__c = :eeId
            ]) {
                eeIdToListEESId.add(ees);
            }
            String docName = UserInfo.getName() + '_EE_Report.zip';
            Zippex zip = new Zippex();
            String eeName;
            for (TB_Employee_Evaluation_Stage__c ees : eeIdToListEESId) {
                String eesName;
                if (eesName == null) {
                    eeName = ees.TB_Employee_Evaluation__r.Name;
                }
                if (eesName == null) {
                    eesName = ees.Name.replace('/', '_');
                }
                PageReference pdfVisualForce = Page.TB_PdfGenerator;
                pdfVisualForce.getParameters().put(TB_PdfGeneratorController.PARAM_EES_ID, ees.Id);
                pdfVisualForce.getParameters().put(TB_PdfGeneratorController.PARAM_LANGUAGE, language);
                Blob pdfBlob = !Test.isRunningTest() ? pdfVisualForce.getContentAsPDF() : Blob.valueOf('test');
                if (eesName != null && eeName != null) {
                    String dic = 'Oceny/' + String.valueOf(eeName + '/' + eesName).remove(' ').replace('-', '_').split('-').get(0) + '.pdf';
                    zip.addFile(dic, pdfBlob, null);
                }
            }
            ContentVersion contentVersion = new ContentVersion(
                    Title = docName,
                    VersionData = zip.getZipArchive(),
                    PathOnClient = 'user.zip',
                    Origin = 'H'
            );
            insert contentVersion;
            ContentVersion resultContentVersion = [
                    SELECT Id, Title, ContentDocumentId
                    FROM ContentVersion
                    WHERE Id = :contentVersion.Id
                    LIMIT 1
            ];
            returnValue = resultContentVersion.ContentDocumentId;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return returnValue;
    }

    @AuraEnabled
    public static List<TB_DownloadFilesController.EvaluationWrapper> chainEERecords() {
        List<TB_DownloadFilesController.EvaluationWrapper> evaluationWrappers = new List<TB_DownloadFilesController.EvaluationWrapper>();
        try {
            for (TB_Employee_Evaluation__c ee : [SELECT Id,Name, TB_Evaluated__r.Name, TB_Process_Type__c From TB_Employee_Evaluation__c ORDER BY TB_Evaluated__r.Name, TB_Process_Type__c DESC]) {
                EvaluationWrapper evaluationWrapper = new EvaluationWrapper();
                evaluationWrapper.Name = ee.TB_Evaluated__r.Name + ' - ' + ee.TB_Process_Type__c;
                evaluationWrapper.Id = ee.Id;
                evaluationWrappers.add(evaluationWrapper);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return evaluationWrappers;
    }

    @AuraEnabled
    public static String getAttachments(String eeId){
        try{
            String result = '';
            Set<Id> eestId = new Map<Id, TB_Employee_Evaluation_Stage_Document__c>([SELECT id FROM TB_Employee_Evaluation_Stage_Document__c WHERE TB_Employee_Evaluation__c =: eeId]).keySet();
            if (!eestId.isEmpty()) {
                for (ContentDocumentLink cdl : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN : eestId]){
                    result = result + cdl.ContentDocumentId + '/';
                }
            }
            return result.contains('/') ? result.removeEnd('/') : null;
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static String getCorrectLangValueField(String language, String field) {
        String returnValue = field;
        if (languageToValueMap?.get(language).containsKey(field)) {
            returnValue = languageToValueMap.get(language).get(field);
        }
        return returnValue;
    }
    private static Map<String, Map <String, String>> languageToValueMap = new Map<String, Map<String, String>>{
            TB_Constants.LANGUAGE_PL => new Map<String, String>{
                    'true' => 'Tak',
                    'false' => 'Nie',
                    'Yes' => 'Tak',
                    'No' => 'Nie',
                    'Without changes' => 'Bez zmian',
                    'Scientist and Didactic' => 'Badawczo-dydaktycznych',
                    'Scientist' => 'Badawczych',
                    'Passed With Distinction' => 'Pozytywna z wyróżnieniem',
                    'Passed' => 'Pozytywna',
                    'Not Passed' => 'Negatywna',
                    'Not_applicable' => 'Nie dotyczy',
                    'Institute Director' => 'Dyrektor Instytutu',
                    'Head of Institute' => 'Dyrektor Instytutu',
                    'Didactic' => 'Dydaktycznych',
                    'Dean' => 'Dziekan'
            },
            TB_Constants.LANGUAGE_EN => new Map<String, String>{
                    'true' => 'True',
                    'false' => 'False'
            }
    };


    public class EvaluationWrapper {
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public Integer index;
    }
}