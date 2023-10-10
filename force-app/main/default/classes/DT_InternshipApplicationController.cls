public without sharing class DT_InternshipApplicationController {

    public static String USER_LANGUAGE_CONTEXT;

    @AuraEnabled(cacheable=true)
    public static String fetchProgramEnrollmentOptions(Id contactId, String pageLanguageContext) {
        USER_LANGUAGE_CONTEXT = pageLanguageContext;
        FetchOptionsResultWrapper result;
        List<OptionWrapper> programEnrollmentOptions = new List<OptionWrapper>();
        Map<Id, ProgramEnrollmentWrapper> programEnrollmentId2ProgramEnrollmentWrapper = new Map<Id, ProgramEnrollmentWrapper>();

        for (hed__Program_Enrollment__c programEnrollment : fetchRelatedProgramEnrollments(contactId)) {
            programEnrollmentId2ProgramEnrollmentWrapper.put(
                programEnrollment.Id, new ProgramEnrollmentWrapper(programEnrollment)
            );
            programEnrollmentOptions.add(
                createProgramEnrollmentOption(programEnrollment)
            );
        }
        result = new FetchOptionsResultWrapper(programEnrollmentOptions, programEnrollmentId2ProgramEnrollmentWrapper);

        return JSON.serialize(result);
    }

    public static OptionWrapper createProgramEnrollmentOption(hed__Program_Enrollment__c programEnrollment) {
        String label = USER_LANGUAGE_CONTEXT == DT_Utils.EXPERIENCE_CLOUD_LANGUAGE_POLISH ?
            programEnrollment.hed__Account__r.DT_Study_Field_PL__c : programEnrollment.hed__Account__r.DT_Study_Field_EN__c;

        return new OptionWrapper(label, null, programEnrollment.Id);
    }

    public static List <hed__Program_Enrollment__c> fetchRelatedProgramEnrollments(Id contactId) {
        List<hed__Program_Enrollment__c> programEnrollments = [
            SELECT Id, Name, hed__Account__r.DT_Study_Field_EN__c, hed__Account__r.DT_Study_Field_PL__c, (
                SELECT Id, DT_Internship_Name__c, DT_Internship_Completed__c, DT_Internship_Hours__c,
                    DT_ScopeOfCompletedHours__c, DT_Semester__c
                FROM Internship_Requirements__r
                WHERE DT_Internship_Completed__c = false
                ORDER BY DT_Internship_Name__c ASC
            )
            FROM hed__Program_Enrollment__c
            WHERE hed__Contact__c = :contactId
                AND DT_Status_by_VDO__c = :DT_Utils.PROGRAM_ENROLLMENT_STATUS_BY_VDO_ACTIVE
        ];

        return programEnrollments;
    }

    @AuraEnabled
    public static Id saveInternshipApplication(DT_Internship_Application__c internshipApplication) {
        insert internshipApplication;
        return internshipApplication.Id;
    }

    @AuraEnabled
    public static DT_Internship_Application__c updateInternshipApplication(DT_Internship_Application__c internshipApplication) {
        update internshipApplication;
        return internshipApplication;
    }

    @AuraEnabled
    public static Id getRelatedInternshipApplicationId(Id contactId, Id internshipId) {
        List<DT_Internship_Application__c> internshipApplications = [
            SELECT Id
            FROM DT_Internship_Application__c
            WHERE DT_Student__c = :contactId
                AND DT_Internship__c = :internshipId
                AND DT_Status__c != :DT_Utils.INTERNSHIP_APPLICATION_STATUS_DRAFT
            ORDER BY CreatedDate DESC
        ];

        if (internshipApplications != null && internshipApplications.size() > 0) {
            return internshipApplications.get(0).Id;
        }
        return null;
    }

    class ProgramEnrollmentWrapper {
        public hed__Program_Enrollment__c programEnrollment;
        public Account academicProgram;
        public List<OptionWrapper> internshipRequirementOptions;
        public List<DT_Internship_Requirement__c> internshipRequirements {
            get {
                return internshipRequirements;
            }
            set {
                internshipRequirements = value;
                internshipRequirementOptions = createInternshipRequirementOptions(internshipRequirements);
            }
        }

        public ProgramEnrollmentWrapper(hed__Program_Enrollment__c programEnrollment) {
            this.programEnrollment = programEnrollment;
            this.academicProgram = programEnrollment.hed__Account__r;
            this.internshipRequirements = programEnrollment.Internship_Requirements__r;
        }

        private List<OptionWrapper> createInternshipRequirementOptions(List<DT_Internship_Requirement__c> internshipRequirements) {
            List<OptionWrapper> options = new List<OptionWrapper>();
            String descriptionLabel = System.Label.InternshipRequirementOptionDescTemplate;

            for (DT_Internship_Requirement__c internshipRequirement : internshipRequirements) {
                String description = fillInLabelTemplate(internshipRequirement, descriptionLabel);
                options.add(
                    new OptionWrapper(
                        internshipRequirement.DT_Internship_Name__c,
                        description,
                        internshipRequirement.Id
                    )
                );
            }
            return options;
        }

        private String fillInLabelTemplate(DT_Internship_Requirement__c internshipRequirement, String descriptionLabel) {
            String filledLabel = descriptionLabel;
            List<String> fieldValues = new List<String>();
            Decimal completedHoursDifference = internshipRequirement.DT_Internship_Hours__c == null
                ? 0
                : internshipRequirement.DT_Internship_Hours__c - internshipRequirement.DT_ScopeOfCompletedHours__c;
            completedHoursDifference = completedHoursDifference > 0 ? completedHoursDifference : 0;

            fieldValues.add(String.valueOf(internshipRequirement.get(DT_Utils.INTERNSHIP_REQUIREMENT_SEMESTER_API_NAME)));
            fieldValues.add(String.valueOf(internshipRequirement.get(DT_Utils.INTERNSHIP_REQUIREMENT_INTERNSHIP_HOURS_API_NAME)));
            fieldValues.add(String.valueOf(String.valueOf(completedHoursDifference)));

            for (Integer i = 0 ; i < fieldValues.size(); i++){
                String element = '{' + i + '}';
                filledLabel = filledLabel.replace(element, fieldValues.get(i) == null ? '' : fieldValues.get(i));
            }

            return filledLabel;
        }
    }

    class OptionWrapper {
        public String label;
        public String description;
        public String value;
        public OptionWrapper(String label, String description, String value) {
            this.label = label;
            this.description = description;
            this.value = value;
        }
    }

    class FetchOptionsResultWrapper {
        public List<OptionWrapper> programEnrollmentOptions;
        public Map<Id, ProgramEnrollmentWrapper> programEnrollmentId2ProgramEnrollmentWrapper;

        public FetchOptionsResultWrapper(
            List<OptionWrapper> programEnrollmentOptions, Map<Id, ProgramEnrollmentWrapper> programEnrollmentId2ProgramEnrollmentWrapper
        ) {
            this.programEnrollmentOptions = programEnrollmentOptions;
            this.programEnrollmentId2ProgramEnrollmentWrapper = programEnrollmentId2ProgramEnrollmentWrapper;
        }
    }

}