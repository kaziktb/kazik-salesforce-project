/**
 * Created by Aneta on 28/09/2021.
 */

public without sharing class TB_EducationHistoryController {

    @AuraEnabled
    public static Boolean getApplicationNoRequiredStatus(String applicationId) {
        return [
            SELECT TB_No_Required_Diploma__c
            FROM hed__Application__c
            WHERE Id = :applicationId
        ]?.TB_No_Required_Diploma__c;
    }


    @AuraEnabled
    public static String getApplication(String applicationId) {

        hed__Application__c application = [
            SELECT Name, hed__Applicant__c, TB_Product_Group__c, TB_Product_Name__c,
                TB_No_Diploma__c, TB_No_Diploma_Request_Sent__c, TB_Active__c,
                hed__Application_Status__c, TB_Communication_Language__c,
                TB_x_Campus_PL__c, TB_x_Campus_EN__c,
                TB_Mode_of_Study__c, toLabel(TB_Mode_of_Study__c) TB_Mode_of_Study_Label,
                TB_x_Level_of_Study_EN__c, TB_x_Level_of_Study_PL__c,
                TB_Level_of_Study__c, toLabel(TB_Level_of_Study__c) TB_Level_of_Study_Label,
                TB_No_Other_Education__c, TB_SPPB__c
            FROM hed__Application__c
            WHERE Id = :applicationId
        ];

        ApplicationWrapper applicationWrapper = new ApplicationWrapper(application);
        return JSON.serialize(applicationWrapper);
    }

    public class ApplicationWrapper {
        @AuraEnabled public hed__Application__c application {get;set;}

        public ApplicationWrapper(hed__Application__c application) {
            this.application = application;
        }
    }

    @AuraEnabled
    public static String updateApplicationCheckboxes(String applicationId, Boolean isNoOtherEducation, Boolean noDiploma) {
        return updateApplication(new hed__Application__c(
                Id = applicationId,
                TB_No_Other_Education__c = isNoOtherEducation,
                TB_No_Diploma__c = noDiploma
        ));
    }

    private static String updateApplication(hed__Application__c application) {
        try {
            update application;
            return 'SUCCESS';
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return 'FAILED';
        }
    }

    @AuraEnabled
    public static String getEducationHistories(String contactId) {
        Map<Id,Contact> idToContact = getContactsFromIndividual(contactId);
        List<hed__Education_History__c> educationHistories = [
            SELECT Id, hed__Educational_Institution_Name__c,
                DT_City__c, DT_Field_of_study__c, TB_SWPS_Education__c,
                TB_Mode_of_Study__c, toLabel(TB_Mode_of_Study__c) TB_Mode_of_Study_Label,
                TB_Level_of_Study__c, toLabel(TB_Level_of_Study__c) TB_Level_of_Study_Label,
                hed__Status__c
            FROM hed__Education_History__c
            WHERE (hed__Contact__c = :contactId OR hed__Contact__c IN :idToContact.keySet())
            AND TB_SWPS_Education__c = TRUE
            ORDER BY hed__Start_Date__c DESC
        ];

        List<EducationHistoryWrapper> historyWrappers = new List<EducationHistoryWrapper>();
        for(hed__Education_History__c singleHistory : educationHistories) {
            EducationHistoryWrapper singleWrapper = new EducationHistoryWrapper(singleHistory);
            historyWrappers.add(singleWrapper);
        }
        return JSON.serialize(historyWrappers);
    }

    public static Map<Id,Contact> getContactsFromIndividual(Id contactId) {
        Id individualId = [SELECT IndividualId FROM Contact WHERE Id = :contactId].IndividualId;
        if(individualId != null) {
            return new Map<Id, Contact>([
                    SELECT Id
                    FROM Contact
                    WHERE RecordTypeId = :TB_SObjectUtils.getRecordTypeIdByDevName('Contact', 'TB_Student')
                    AND IndividualId = :individualId
            ]);
        }else {
            return new Map<Id,Contact>();
        }
    }
    @AuraEnabled
    public static String deleteApplicationDocument(String appDocumentId) {
        TB_Application_Document__c document = new TB_Application_Document__c();
        document.Id = appDocumentId;
        document.TB_Status__c = 'Empty';
        document.TB_Content_Document_Id__c = '';
        try {
            update document;
            return JSON.serialize(document);
        }catch(Exception e) {
            return 'DELETE_APPLICATION_DOCUMENT.EXCEPTION';
        }
    }

    @AuraEnabled
    public static String getExperienceHistoryWithDocuments(String applicationId) {

        List<TB_Experience_History__c> experienceHistories = getExperienceHistories(applicationId);

        Set<Id> experienceIds = new Set<Id>();
        for(TB_Experience_History__c singleExperience : experienceHistories) {
            experienceIds.add(singleExperience.Id);
        }

        Map<Id,List<TB_Application_Document__c>> experienceDocumentsMap = getApplicationDocumentsForExperiences(experienceIds);

        List<ExperienceHistoryWrapper> historyWrappers = new List<ExperienceHistoryWrapper>();
        for(TB_Experience_History__c singleHistory : experienceHistories) {
            ExperienceHistoryWrapper singleWrapper = new ExperienceHistoryWrapper(singleHistory);
            List<TB_Application_Document__c> documentsForSingleWrapper = experienceDocumentsMap.get(singleWrapper.history.Id);
            if(documentsForSingleWrapper != null) {
                List<TB_FileUtils.FileWrapper> fileWrappersForSingleWrapper = TB_FileUtils.createFileWrapperForDocuments(documentsForSingleWrapper);
                singleWrapper.files = fileWrappersForSingleWrapper;
            }
            historyWrappers.add(singleWrapper);
        }
        return JSON.serialize(historyWrappers);
    }

    private static List<TB_Experience_History__c> getExperienceHistories(String applicationId) {
        String higherEducationRecordTypeId = Schema.SObjectType.TB_Experience_History__c.getRecordTypeInfosByDeveloperName().get('TB_Higher_Education').getRecordTypeId();
        return [ SELECT Id, Name, TB_Application__c, TB_Educational_Institution__c, TB_Course__c,
            TB_Educational_Institution_City__c, TB_Educational_Institution_Country__c, TB_Level_of_Study__c,
            TB_Speciality__c, TB_Document_Number__c, TB_Issue_Date__c, TB_Academic_Title__c, TB_Average_Score__c,
            TB_Not_Diploma__c, TB_Defense_of_Thesis_Date_Declared__c, TB_Application__r.TB_Product_Group__c
        FROM TB_Experience_History__c
        WHERE TB_Application__c = :applicationId AND RecordTypeId = :higherEducationRecordTypeId AND TB_Active__c = true
        ORDER BY CreatedDate ASC ];
    }

    private static List<TB_Application_Document__c> getApplicationDocuments(Set<Id> experienceIds) {
        return  [ SELECT Id, TB_Document_Name_PL__c, TB_Document_Name_EN__c,
            TB_Document_Category__c, toLabel(TB_Document_Category__c) TB_Document_Category_Label,
            TB_Experience__c, TB_Status__c, toLabel(TB_Status__c) TB_Status_Label ,TB_Comment__c,
            TB_Download_URL__c, TB_Content_Document_Id__c, TB_Document_File_Name__c
        FROM TB_Application_Document__c
        WHERE TB_Experience__c IN :experienceIds AND TB_Active__c = TRUE
        ];
    }

    private static Map<Id,List<TB_Application_Document__c>> getApplicationDocumentsForExperiences(Set<Id> experienceIds) {

        List<TB_Application_Document__c> applicationDocuments = getApplicationDocuments(experienceIds);

        Map<Id,List<TB_Application_Document__c>> experienceDocumentsMap = new Map<Id,List<TB_Application_Document__c>>();
        for(TB_Application_Document__c singleDocument : applicationDocuments) {
            List<TB_Application_Document__c> singleExperienceDocumentList
                = experienceDocumentsMap.get(singleDocument.TB_Experience__c);

            if(singleExperienceDocumentList == null) {
                List<TB_Application_Document__c> newExperienceDocumentList = new List<TB_Application_Document__c>();
                newExperienceDocumentList.add(singleDocument);
                experienceDocumentsMap.put(singleDocument.TB_Experience__c,newExperienceDocumentList);
            }else {
                singleExperienceDocumentList.add(singleDocument);
                experienceDocumentsMap.put(singleDocument.TB_Experience__c,singleExperienceDocumentList);
            }
        }
        return experienceDocumentsMap;
    }

    public class EducationHistoryWrapper {
        @AuraEnabled public hed__Education_History__c history {get;set;}
        @AuraEnabled public String borderStyle {get;set;}
        @AuraEnabled public Boolean editFlag {get;set;}

        public EducationHistoryWrapper(hed__Education_History__c educationHistory) {
            this.history = educationHistory;
            this.borderStyle = '';
            this.editFlag = false;
        }
    }

    public class ExperienceHistoryWrapper {
        @AuraEnabled public TB_Experience_History__c history {get;set;}
        @AuraEnabled public String borderStyle {get;set;}
        @AuraEnabled public Boolean editFlag {get;set;}
        @AuraEnabled public Boolean showFlag {get;set;}
        @AuraEnabled public Boolean isDiploma {get;set;}
        @AuraEnabled public List<TB_FileUtils.FileWrapper> files {get;set;}

        public ExperienceHistoryWrapper(TB_Experience_History__c educationHistory) {
            this.history = educationHistory;
            this.borderStyle = '';
            this.editFlag = true;
            this.showFlag = true;
            this.isDiploma = !(educationHistory.TB_Not_Diploma__c);
        }
    }

    @AuraEnabled
    public static String updateNewExperienceHistory(
        String experienceString, String productGroup,
        String contactId, String applicationId, Boolean isChangeGroup
    ) {
        TB_Experience_History__c experience;
        try {
            experience = (TB_Experience_History__c) JSON.deserialize(experienceString, TB_Experience_History__c.class);
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return 'UPSERT_NEW_EXPERIENCE_CONTROLLER.EXCEPTION';
        }
        Set<String> documentSlots;
        if(experience.Id == null) {
            String higherEducationRecordTypeId = Schema.SObjectType.TB_Experience_History__c
                .getRecordTypeInfosByDeveloperName().get('TB_Higher_Education').getRecordTypeId();
            experience.RecordTypeId = higherEducationRecordTypeId;
            experience.TB_Applicant__c = contactId;
            documentSlots = createApplicationDocumentForExperience(!experience.TB_Not_Diploma__c, experience.TB_Educational_Institution_Country__c, productGroup);
        } else {
            if(isChangeGroup == true) {
                List<TB_Application_Document__c> activeDocuments = [
                    SELECT Id
                    FROM TB_Application_Document__c
                    WHERE TB_Application__c = :applicationId
                    AND TB_Experience__c = :experience.Id
                ];
                for(TB_Application_Document__c singleActiveDocument : activeDocuments) {
                    singleActiveDocument.TB_Active__c = false;
                }
                try {
                    update activeDocuments;
                }catch(Exception e) {
                    insert TB_LogUtils.registerLog(e);
                }
                documentSlots = createApplicationDocumentForExperience(!experience.TB_Not_Diploma__c, experience.TB_Educational_Institution_Country__c, productGroup);
            }
        }

        try {
            upsert experience;
            if(documentSlots != null) {
                List<TB_Application_Document__c> documents = new List<TB_Application_Document__c>();
                for (String singleCategory : documentSlots) {
                    TB_Application_Document__c applicationDocument = new TB_Application_Document__c(
                        TB_Application__c = applicationId,
                        TB_Status__c = 'Empty',
                        TB_Experience__c = experience.Id,
                        TB_Contact__c = contactId,
                        TB_Document_Category__c = singleCategory,
                        TB_Document_Type__c = 'Scan',
                        TB_Output_Format__c = 'Original'
                    );
                    documents.add(applicationDocument);
                }
                insert documents;
            }
            ExperienceHistoryWrapper wrapper = new ExperienceHistoryWrapper(experience);
            return JSON.serialize(wrapper);
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return 'UPSERT_NEW_EXPERIENCE_CONTROLLER.EXCEPTION';
        }
    }

    private static Set<String> createApplicationDocumentForExperience(Boolean isDiploma, String educationalCountry, String productGroup) {
        Set<String> documentSlotsForExperience = new Set<String>();
        if(isDiploma){
            documentSlotsForExperience.add('Diploma');
            if(educationalCountry != 'PL' && String.isNotBlank(educationalCountry)) {
                documentSlotsForExperience.add('Diploma_Translation');
                if(productGroup != 'Postgraduate') {
                    documentSlotsForExperience.add('Supplement_Translation');
                }
            }
            if(productGroup != 'Postgraduate') {
                documentSlotsForExperience.add('Supplement');
            }
        }else {
            if(productGroup != 'Postgraduate'){
                documentSlotsForExperience.add('Study_Card');
                documentSlotsForExperience.add('Deans_Office_Statement');
            }
        }
        return documentSlotsForExperience;
    }

    @AuraEnabled
    public static String deleteExperienceHistory(String experienceWrapper) {
        try {
            ExperienceHistoryWrapper experienceHistory = (ExperienceHistoryWrapper) JSON.deserialize(experienceWrapper, ExperienceHistoryWrapper.class);
            delete experienceHistory.history;
            return 'DELETE_EXPERIENCE_HISTORY.SUCCESS';
        }catch(Exception e) {
            insert TB_LogUtils.registerLog(e);
            return 'DELETE_EXPERIENCE_HISTORY.EXCEPTION';
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,List<String>> getEarnedTitlePicklistPL() {
        Map<String,List<String>> earnedTitlesByLevelOfStudy = new Map<String,List<String>>();
        List<String> bachelorPL = new List<String>
        {
            'inżynier','inżynier architekt', 'inżynier architekt krajobrazu',
            'licencjat','licencjat pielęgniarstwa','licencjat położnictwa'
        };
        earnedTitlesByLevelOfStudy.put('Bachelor',bachelorPL);

        List<String> masterPL = new List<String> {
            'magister', 'magister inżynier', 'magister inżynier architekt','magister inżynier architekt krajobrazu',
            'magister inżynier pożarnictwa','magister pielęgniarstwa', 'magister położnictwa','magister sztuki',
            'lekarz', 'lekarz dentysta', 'lekarz weterynarii'
        };
        earnedTitlesByLevelOfStudy.put('Master',masterPL);
        earnedTitlesByLevelOfStudy.put('Integrated_Master',masterPL);
        return earnedTitlesByLevelOfStudy;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,List<String>> getEarnedTitlePicklistEN() {
        Map<String,List<String>> earnedTitlesByLevelOfStudy = new Map<String,List<String>>();
        List<String> bachelorPL = new List<String> {'bachelor'};
        earnedTitlesByLevelOfStudy.put('Bachelor',bachelorPL);

        List<String> masterPL = new List<String> { 'master' };
        earnedTitlesByLevelOfStudy.put('Master',masterPL);
        earnedTitlesByLevelOfStudy.put('Integrated_Master',masterPL);
        return earnedTitlesByLevelOfStudy;
    }

    @AuraEnabled
    public static String getPicklistByApiName(String objectApiName, String fieldApiName) {
        List<String> labels = TB_StringUtils.getPicklistValuesOrLabelsSortedByLabel(objectApiName, fieldApiName, 'labels');
        List<String> values = TB_StringUtils.getPicklistValuesOrLabelsSortedByLabel(objectApiName, fieldApiName, 'values');
        List<List<String>> valuesAndLabelsPrioritized = TB_StringUtils.getPolandOnTop(new List<List<String>>{values,labels});
        PicklistWrapper picklistWrapper = new PicklistWrapper(valuesAndLabelsPrioritized);
        return JSON.serialize(picklistWrapper);
    }

    public class PicklistWrapper {
        @AuraEnabled public List<String> choicesValues { get; set; }
        @AuraEnabled public List<String> choicesLabels { get; set; }

        public PicklistWrapper(List<List<String>> valuesAndLabelsPrioritized) {

            this.choicesValues = valuesAndLabelsPrioritized[0];
            this.choicesLabels = valuesAndLabelsPrioritized[1];
        }
    }
}