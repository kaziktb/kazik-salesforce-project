/**
 * Created by Aneta on 09/11/2021.
 */

public with sharing class TB_LanguageCertificatesController {

    @AuraEnabled
    public static String getLanguageCertificateMetricsForApplication(String applicationId) {
        List<ExperienceWrapper> experienceWrappers = new List<ExperienceWrapper>();
        List<TB_Experience_History__c> experienceHistoryMetrics = [
            SELECT Id, TB_Language_Certificate__c, TB_Language_of_Certificate__c,
                TB_Authority__c, TB_Issue_Date__c
            FROM TB_Experience_History__c
            WHERE TB_Application__c = :applicationId
            AND RecordType.DeveloperName = :TB_Constants.TB_EDUCATION_EXP_LANGUAGE_CERTIFICATE_RT_DN
            AND TB_Active__c = TRUE
            ORDER BY CreatedDate
        ];

        Map<Id,List<TB_Application_Document__c>> documentsForMetrics = prepareMapOfApplicationDocuments(experienceHistoryMetrics);
        for(TB_Experience_History__c singleMetric : experienceHistoryMetrics) {
            ExperienceWrapper singleWrapper = new ExperienceWrapper(singleMetric);
            List<TB_Application_Document__c> documentsForSingleWrapper = documentsForMetrics.get(singleMetric.Id);
            if(documentsForSingleWrapper != null) {
                List<TB_FileUtils.FileWrapper> fileWrappersForSingleWrapper = TB_FileUtils.createFileWrapperForDocuments(documentsForSingleWrapper);
                singleWrapper.files = fileWrappersForSingleWrapper;
            }
            experienceWrappers.add(singleWrapper);
        }
        return JSON.serialize(experienceWrappers);
    }

    private static Map<Id,List<TB_Application_Document__c>> prepareMapOfApplicationDocuments(List<TB_Experience_History__c> metrics) {
        List<Id> metricIds = new List<Id>();
        for(TB_Experience_History__c singleMetric : metrics) {
            metricIds.add(singleMetric.Id);
        }
        Map<Id,List<TB_Application_Document__c>> documentsMap = TB_FileUtils.getApplicationDocuments(metricIds,'TB_Experience__c');
        return documentsMap;
    }

    public class ExperienceWrapper {
        @AuraEnabled public TB_Experience_History__c experience { get; set; }
        @AuraEnabled public List<TB_FileUtils.FileWrapper> files { get; set; }

        public ExperienceWrapper(TB_Experience_History__c experienceHistory) {
            this.experience = experienceHistory;
        }
    }

    @AuraEnabled
    public static String getAdmissionsDictionaryWrappers(String applicationId) {

        hed__Application__c application = [
            SELECT Id, TB_Applicant_Citizenship__c,
                TB_Applying_To_Offered_Product__c,
                TB_No_Language_Certificate__c
            FROM hed__Application__c
            WHERE Id = :applicationId
        ];

        List<TB_Qualification_Requirement__c> certificatesRequirements
            = getLanguageCertificateQualificationsRequirements(application.TB_Applying_To_Offered_Product__c);

        List<Id> languageCertificatesIds = getCertificatesIdsAvailableForApplication(application, certificatesRequirements);

        List<TB_Admissions_Dictionary__c> sortedAdmissionsDictionary = getAdmissionsDictionariesLanguageCertificates(languageCertificatesIds);

        AdmissionsDictionaryWrapper wrapper = new AdmissionsDictionaryWrapper(sortedAdmissionsDictionary, application);
        return JSON.serialize(wrapper);
    }

    private static List<TB_Qualification_Requirement__c> getLanguageCertificateQualificationsRequirements(String applyingToOfferedProduct) {
        List<TB_Qualification_Requirement__c> certificatesRequirements = new List<TB_Qualification_Requirement__c>();

        List<TB_JSON_Wrapper__c> requirementWrappers = [
            SELECT Id, TB_Wrapper_Value__c, TB_Object_API_Name__c, TB_Record_Type_Dev_Name__c
            FROM TB_JSON_Wrapper__c
            WHERE TB_Object_API_Name__c = :TB_Constants.TB_OBJECT_API_NAME_QUALIFICATION_REQUIREMENT
            AND TB_Record_Type_Dev_Name__c = :TB_Constants.ADMISSIONS_DICTIONARY_RT_LANGUAGE_CERTIFICATE_DEVNAME
            ORDER BY TB_Order__c
        ];

        for(TB_JSON_Wrapper__c singleWrapper : requirementWrappers) {
            TB_Qualification_Requirement__c singleRequirement
                = (TB_Qualification_Requirement__c) JSON.deserialize(singleWrapper.TB_Wrapper_Value__c, TB_Qualification_Requirement__c.class);
            if(singleRequirement.TB_Active__c && singleRequirement.TB_Offered_Product__c == applyingToOfferedProduct) {
                certificatesRequirements.add(singleRequirement);
            }
        }
        return certificatesRequirements;
    }

    private static List<Id> getCertificatesIdsAvailableForApplication
        (
            hed__Application__c application, List<TB_Qualification_Requirement__c> certificatesRequirements
        ) {
        List<Id> admissionsDictionaryIds = new List<Id>();
        for (TB_Qualification_Requirement__c singleRequirement : certificatesRequirements) {
            if(application.TB_Applicant_Citizenship__c == TB_Constants.TB_APPLICANT_CITIZENSHIP_POLAND
                && singleRequirement.TB_Citizenship_Dependency__c == TB_Constants.TB_CITIZENSHIP_DEPENDENCY_POLISH_CITIZENS
                ) {
                admissionsDictionaryIds.add(singleRequirement.TB_Language_Certificate__c);
            }else if(application.TB_Applicant_Citizenship__c != TB_Constants.TB_APPLICANT_CITIZENSHIP_POLAND
                && singleRequirement.TB_Citizenship_Dependency__c == TB_Constants.TB_CITIZENSHIP_DEPENDENCY_NON_POLISH_CITIZENS
                ) {
                admissionsDictionaryIds.add(singleRequirement.TB_Language_Certificate__c);
            }else if(singleRequirement.TB_Citizenship_Dependency__c == TB_Constants.TB_CITIZENSHIP_DEPENDENCY_EVERYONE) {
                admissionsDictionaryIds.add(singleRequirement.TB_Language_Certificate__c);
            }
        }
        return admissionsDictionaryIds;
    }

    private static List<TB_Admissions_Dictionary__c> getAdmissionsDictionariesLanguageCertificates(List<Id> languageCertificatesIds) {
        Map<String, TB_Admissions_Dictionary__c> admissionsDictionariesByOrder = new Map<String, TB_Admissions_Dictionary__c>();

        List<TB_JSON_Wrapper__c> wrappers = [
            SELECT Id, TB_Wrapper_Value__c, TB_Object_API_Name__c, TB_Record_Type_Dev_Name__c
            FROM TB_JSON_Wrapper__c
            WHERE TB_Object_API_Name__c = :TB_Constants.TB_OBJECT_API_NAME_ADMISSIONS_DICTIONARY
            AND TB_Record_Type_Dev_Name__c = :TB_Constants.TB_EDUCATION_EXP_LANGUAGE_CERTIFICATE_RT_DN
            ORDER BY TB_Order__c
        ];

        for(TB_JSON_Wrapper__c singleWrapper : wrappers) {
            TB_Admissions_Dictionary__c singleDictionary
                = (TB_Admissions_Dictionary__c) JSON.deserialize(singleWrapper.TB_Wrapper_Value__c, TB_Admissions_Dictionary__c.class);
            if(languageCertificatesIds.contains(singleDictionary.Id)) {
                admissionsDictionariesByOrder.put(singleDictionary.Id,singleDictionary);
            }
        }

        List<TB_Admissions_Dictionary__c> sortedAdmissionsDictionary = new List<TB_Admissions_Dictionary__c>();
        for(String singleId : languageCertificatesIds) {
            if(admissionsDictionariesByOrder.containsKey(singleId)) {
                sortedAdmissionsDictionary.add(admissionsDictionariesByOrder.get(singleId));
            }
        }
        return sortedAdmissionsDictionary;
    }

    public class AdmissionsDictionaryWrapper {
        hed__Application__c application {get;set;}
        List<TB_Admissions_Dictionary__c> admissionsCertificates {get;set;}
        List<PicklistWrapper> languagePicklistWrapper {get;set;}

        public AdmissionsDictionaryWrapper(List<TB_Admissions_Dictionary__c> admissionsDictionaries, hed__Application__c application) {
            this.application = application;
            this.admissionsCertificates = admissionsDictionaries;
            this.languagePicklistWrapper = preparePicklistWrapper(this.admissionsCertificates);
        }
    }

    private static List<PicklistWrapper> preparePicklistWrapper(List<TB_Admissions_Dictionary__c> certificates) {

        Set<String> certificatesLanguages = new Set<String>();
        for(TB_Admissions_Dictionary__c singleCertificate : certificates) {
            certificatesLanguages.add(singleCertificate.TB_Language_of_Certificate__c);
        }

        Map<String,String> valuesMap = TB_StringUtils.getMapFromPicklist('TB_Admissions_Dictionary__c','TB_Language_of_Certificate__c');
        List<PicklistWrapper> picklistWrappers = new List<PicklistWrapper>();
        for(String singleKey : valuesMap.keySet()) {
            if(certificatesLanguages.contains(singleKey)) {
                PicklistWrapper singleWrapper = new PicklistWrapper(singleKey, valuesMap.get(singleKey));
                picklistWrappers.add(singleWrapper);
            }
        }
        return picklistWrappers;
    }

    public class PicklistWrapper {
        @AuraEnabled public String choiceValue { get; set; }
        @AuraEnabled public String choiceLabel { get; set; }

        public PicklistWrapper(String picklistValue, String picklistLabel) {
            this.choiceValue = picklistValue;
            this.choiceLabel =picklistLabel;
        }
    }

    @AuraEnabled
    public static String deleteLanguageCertificateMetric(String certificateMetricId) {
        try {
            TB_Experience_History__c experienceHistory = new TB_Experience_History__c(
                Id = certificateMetricId
            );
            delete experienceHistory;
            return 'SUCCESS_DELETE';
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return 'FAILED_deleteLanguageCertificateMetric';
        }
    }

    @AuraEnabled
    public static String saveLanguageCertificateMetric(String certificateMetric, String stepId, String stageId) {

        TB_Experience_History__c experienceHistory = (TB_Experience_History__c) JSON.deserialize(certificateMetric, TB_Experience_History__c.class);
        try {
            if (experienceHistory.Id == null) {
                experienceHistory.RecordTypeId = Schema.SObjectType.TB_Experience_History__c.getRecordTypeInfosByDeveloperName().get('TB_Language_Certificate').getRecordTypeId();
                insert experienceHistory;
                createDocumentSlotForCertificate(experienceHistory, stepId, stageId);

                ExperienceWrapper experienceWrapper = new ExperienceWrapper(experienceHistory);
                experienceWrapper.files = new List<TB_FileUtils.FileWrapper>{TB_FileUtils.createFileWrapperForDocument(getNewApplicationDocument(experienceHistory.Id))};
                return JSON.serialize(experienceWrapper);
            } else {
                update experienceHistory;
                return JSON.serialize(experienceHistory);
            }
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return 'FAILED';
        }
    }

    private static TB_Application_Document__c createDocumentSlotForCertificate(TB_Experience_History__c experience, String stepId, String stageId) {
        TB_Application_Document__c applicationDocument 
            = TB_FileUtils.prepareApplicationDocumentSlot(experience, 'Language_Certificate', stepId, stageId);
        insert applicationDocument;
        return applicationDocument;
    }

    private static TB_Application_Document__c getNewApplicationDocument(String experienceId) {
        return [ SELECT Id, TB_Document_Name_PL__c, TB_Document_Name_EN__c,
                TB_Document_Category__c, toLabel(TB_Document_Category__c) TB_Document_Category_Label,
                TB_Experience__c, TB_Status__c, toLabel(TB_Status__c) TB_Status_Label ,TB_Comment__c,
                TB_Download_URL__c, TB_Content_Document_Id__c, TB_Step_Id__c, TB_Stage_Id__c, TB_Document_File_Name__c
            FROM TB_Application_Document__c
            WHERE TB_Experience__c = :experienceId
            AND TB_Active__c = true
            ORDER BY LastModifiedDate
            LIMIT 1
        ];
    }

    @AuraEnabled
    public static String updateApplication(String applicationId, Boolean noLanguageValue) {
        try {
            hed__Application__c application = new hed__Application__c(
                Id = applicationId,
                TB_No_Language_Certificate__c = noLanguageValue
            );
            update application;
            return 'SUCCESS';
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return 'FAILED';
        }
    }

    @AuraEnabled
    public static String getEmptyCertificateMetric() {
        TB_Experience_History__c singleMetric = new TB_Experience_History__c();
        return JSON.serialize(singleMetric);
    }

}