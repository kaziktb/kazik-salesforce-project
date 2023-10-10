public without sharing class TB_vu_CasesController {
    private static final String MEDIUM_PRIORITY = 'Medium';
    private static final String LANG_PL = 'PL';
    private static final String NEW_STATUS = 'New';
    private static final String VIRTUAL_UNIVERSITY_ORIGIN = 'Virtual_University';

    @AuraEnabled
    public static String getRecordTypeId(String developerName){
        try {
            return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(developerName).getRecordTypeId();
        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_CasesController.class.getName(),e.getStackTraceString(),''));
        }
    }

    @AuraEnabled
    public static List<String> sendCase(CaseParameters caseParameters){
        try {
            List<String> toReturn = new List<String>();

            Id accountIdLinkedWithContact = 
                [SELECT 
                    Id, 
                    AccountId
                FROM 
                    Contact 
                WHERE 
                    Id =: caseParameters.contactId].AccountId;

            String languageToCase = caseParameters.Language != LANG_PL ? 'EN_US' : LANG_PL;

            Case newCase = new Case(
                TB_Category__c = caseParameters.category,
                TB_Subcategory__c = caseParameters.subcategory,
                TB_Program_Enrollment__c = caseParameters.studyNameId,
                Subject = caseParameters.subject,
                TB_Description_Rich_Text__c =  caseParameters.description,
                Language = languageToCase,
                ContactId = caseParameters.contactId,
                AccountId = accountIdLinkedWithContact,
                Priority = MEDIUM_PRIORITY,
                Status = NEW_STATUS,
                Origin = VIRTUAL_UNIVERSITY_ORIGIN,
                RecordTypeId = caseParameters.recordTypeId
            );

            insert newCase;

            toReturn.add(newCase.Id);
            
            List<hed__Program_Enrollment__c> relatedProgramEnrollment = [
                SELECT 
                    Id, 
                    TB_Study_Name_With_Attributes_PL__c, 
                    TB_Study_Name_With_Attributes_EN__c,
                    hed__Program_Plan__r.DT_Study_Field_PL__c,
                    hed__Program_Plan__r.DT_Study_Field_EN__c,
                    hed__Program_Plan__r.DT_Pathway_PL__c,
                    hed__Program_Plan__r.DT_Pathway_EN__c,
                    hed__Program_Plan__r.TB_x_Mode_of_Study_PL__c,
                    hed__Program_Plan__r.TB_x_Mode_of_Study_EN__c,
                    hed__Program_Plan__r.TB_x_Level_of_Study_PL__c,
                    hed__Program_Plan__r.TB_x_Level_of_Study_EN__c,
                    TB_Semester__c
                FROM hed__Program_Enrollment__c 
                WHERE Id = :caseParameters.studyNameId
            ];

            Case newCaseWithFormulaFieldsFilled = [
                SELECT
                    Id,
                    TB_Faculty__c,
                    TB_Album_Number__c
                FROM Case
                WHERE Id =: newCase.Id
                LIMIT 1
            ];

            TB_Operation__c newOperation = new TB_Operation__c(
                TB_Author__c = 'Student',
                TB_Case__c = newCase.Id,
                TB_Description_Rich_Text__c = caseParameters.description,
                TB_Contact__c = caseParameters.contactId,
                TB_Publish__c = true,
                RecordTypeId = Schema.SObjectType.TB_Operation__c.getRecordTypeInfosByDeveloperName().get('TB_Conversation').getRecordTypeId(),
                TB_Type__c = 'External_Comment',
                TB_Initial__c = true,
                TB_Case_Study_Name_With_Attributes_PL__c = relatedProgramEnrollment.isEmpty() ? null : relatedProgramEnrollment[0].TB_Study_Name_With_Attributes_PL__c,
                TB_Case_Study_Name_With_Attributes_EN__c = relatedProgramEnrollment.isEmpty() ? null : relatedProgramEnrollment[0].TB_Study_Name_With_Attributes_EN__c,
                TB_Case_Study_Field_PL__c = relatedProgramEnrollment.isEmpty() ? null : relatedProgramEnrollment[0].hed__Program_Plan__r.DT_Study_Field_PL__c,
                TB_Case_Study_Field_EN__c = relatedProgramEnrollment.isEmpty() ? null : relatedProgramEnrollment[0].hed__Program_Plan__r.DT_Study_Field_EN__c,
                TB_Case_Pathway_PL__c = relatedProgramEnrollment.isEmpty() ? null : relatedProgramEnrollment[0].hed__Program_Plan__r.DT_Pathway_PL__c,
                TB_Case_Pathway_EN__c = relatedProgramEnrollment.isEmpty() ? null : relatedProgramEnrollment[0].hed__Program_Plan__r.DT_Pathway_EN__c,
                TB_Case_Mode_Of_Study_PL__c = relatedProgramEnrollment.isEmpty() ? null : relatedProgramEnrollment[0].hed__Program_Plan__r.TB_x_Mode_of_Study_PL__c,
                TB_Case_Mode_Of_Study_EN__c = relatedProgramEnrollment.isEmpty() ? null : relatedProgramEnrollment[0].hed__Program_Plan__r.TB_x_Mode_of_Study_EN__c,
                TB_Case_Level_Of_Study_PL__c = relatedProgramEnrollment.isEmpty() ? null : relatedProgramEnrollment[0].hed__Program_Plan__r.TB_x_Level_of_Study_PL__c,
                TB_Case_Level_Of_Study_EN__c = relatedProgramEnrollment.isEmpty() ? null : relatedProgramEnrollment[0].hed__Program_Plan__r.TB_x_Level_of_Study_EN__c,
                TB_Case_Semester__c = relatedProgramEnrollment.isEmpty() ? null : relatedProgramEnrollment[0].TB_Semester__c,
                TB_Case_Faculty__c = newCaseWithFormulaFieldsFilled.TB_Faculty__c,
                TB_Album_Number__c = newCaseWithFormulaFieldsFilled.TB_Album_Number__c
            );

            insert newOperation;

            toReturn.add(newOperation.Id);

            return toReturn;
            
        }  catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_CasesController.class.getName(),e.getStackTraceString(),''));
        }
    }

    @AuraEnabled
    public static List<StudyNameWrapper> getStudyNames(String language, String contactId){
        try {
            Integer daysBeforeEnrollmentStartDay = (Integer)TB_SS_Program_Enrollment_Setting__c.getOrgDefaults().TB_Days_Before_Enrollment_Start_Day__c;
            List<StudyNameWrapper> toReturn = new List<StudyNameWrapper>();
            Map<String, hed__Program_Enrollment__c> withoutRoundNumberDuplicates = new Map<String, hed__Program_Enrollment__c>();
            for(hed__Program_Enrollment__c pe : [
                SELECT 
                    Id,
                    TB_Study_Name_With_Attributes_EN__c, 
                    TB_Study_Name_With_Attributes_PL__c,
                    hed__Start_Date__c,
                    hed__End_Date__c,
                    DT_VDO_Round_ID__c
                FROM hed__Program_Enrollment__c 
                WHERE hed__Contact__c =: contactId
                AND DT_Level_Of_Studies__c IN: TB_vu_Constants.PROGRAM_ENROLMENT_LEVEL_OF_STUDIES
                AND hed__Start_Date__c <=: Date.today() + daysBeforeEnrollmentStartDay]){
                    if(pe.hed__End_Date__c == null || pe.hed__Start_Date__c <= pe.hed__End_Date__c){
                        if(withoutRoundNumberDuplicates.get(pe.DT_VDO_Round_ID__c) == null){
                            withoutRoundNumberDuplicates.put(pe.DT_VDO_Round_ID__c, pe);
                        }
                        else if(withoutRoundNumberDuplicates.get(pe.DT_VDO_Round_ID__c).hed__Start_Date__c < pe.hed__Start_Date__c){
                            withoutRoundNumberDuplicates.put(pe.DT_VDO_Round_ID__c, pe);
                        }
                    }
            }

            for(hed__Program_Enrollment__c pe : withoutRoundNumberDuplicates.values()){
                String facultyToAdd = language == LANG_PL ? pe.TB_Study_Name_With_Attributes_PL__c : pe.TB_Study_Name_With_Attributes_EN__c;
                toReturn.add(new StudyNameWrapper(
                    pe.Id,
                    facultyToAdd
                ));
            }

            return toReturn;

        } catch (Exception e) {
            throw new AuraHandledException(TB_vu_Utils.registerLog(e.getMessage(),TB_vu_CasesController.class.getName(),e.getStackTraceString(),''));
        }
        
    }

    public class StudyNameWrapper{
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public String studyName { get; set; }

        public StudyNameWrapper(String id, String studyName) {
            this.id = id;
            this.studyName = studyName;
        }
    }

    public class CaseParameters{
        @AuraEnabled
        public String category { get; set; }
        @AuraEnabled
        public String subcategory { get; set; }
        @AuraEnabled
        public String studyNameId { get; set; }
        @AuraEnabled
        public String subject { get; set; }
        @AuraEnabled
        public String description { get; set; }
        @AuraEnabled
        public String language { get; set; }
        @AuraEnabled
        public String recordTypeId { get; set; }
        @AuraEnabled
        public String contactId { get; set; }
    }

}