public without sharing class MySwpsInstitutionalApplicationFormCtrl {
    @AuraEnabled(Cacheable=true)
    public static FormInitialDataWrapper fetchFormInitialData(String pageContextLanguage, Id internshipOfferId) {

        Id contactId = MySwpsUtils.fetchCustomerUserContactIdOrThrow(UserInfo.getUserId());

        FormInitialDataWrapper wrapper = new FormInitialDataWrapper();
        wrapper.studentContactId = contactId;

        Set<Id> offerAssignmentAccountIds = new Set<Id>();

        Career_Services_Offer__c internshipOffer = [
            SELECT
                Id, toLabel(Required_Recruitment_Documents__c),(
                SELECT Id, Account__c, Is_Obligatory__c FROM Career_Services_Offer_Assignments__r
                WHERE Is_Accepted__c = TRUE
            )
            FROM Career_Services_Offer__c
            WHERE Id =: internshipOfferId
        ];
        List<Career_Services_Application__c> applications = [
            SELECT Id, Status__c, CreatedDate
            FROM Career_Services_Application__c
            WHERE Career_Services_Offer__c = :internshipOfferId
                AND Student__c = :contactId
                ORDER BY CreatedDate DESC
        ];

        if (!applications.isEmpty()) {
            wrapper.lastApplicationId = applications.get(0).Id;
        }

        for (Career_Services_Offer_Assignment__c assignment : internshipOffer.Career_Services_Offer_Assignments__r) {
            offerAssignmentAccountIds.add(assignment.Account__c);
            if (!assignment.Is_Obligatory__c) {
                wrapper.hasOfferNonObligatoryAssignment = true;
            }
        }

        wrapper.hasOfferRequiredDocuments = internshipOffer.Required_Recruitment_Documents__c != null;
        if (internshipOffer.Required_Recruitment_Documents__c != null) {
            wrapper.hasOfferRequiredDocuments = true;
            wrapper.offerRequiredDocumentTypes = internshipOffer.Required_Recruitment_Documents__c.replace(';', ', ');
        }

        List<hed__Education_History__c> educationHistories = [
            SELECT Id, Name, DT_Field_of_study__c, hed__Start_Date__c, (
                SELECT Id FROM hed__Program_Enrollments__r ORDER BY hed__Start_Date__c DESC LIMIT 1
            ), (
                SELECT Id, Name, Education_History__c,
                    Internship_Group__r.Academic_Program__r.DT_Specialty_PL__c,
                    Internship_Group__r.Academic_Program__r.DT_Specialty_EN__c,
                    Internship_Group__r.Specialty__r.DT_Specialty_PL__c,
                    Internship_Group__r.Specialty__r.DT_Specialty_EN__c,
                    Internship_Group__r.Internship_Issuance__r.Required_Hours__c,
                    Internship_Group__r.Pathway__r.Name
                FROM Internship_Requirements__r
                WHERE Is_Completed__c = FALSE
                AND (
                    Internship_Group__r.Academic_Program__c IN : offerAssignmentAccountIds
                    OR Internship_Group__r.Specialty__c IN : offerAssignmentAccountIds
                    OR Internship_Group__r.Pathway__c IN : offerAssignmentAccountIds
                )
            )
            FROM hed__Education_History__c
            WHERE hed__Contact__c = :contactId
            AND hed__Status__c = :Constants.EDUCATION_HISTORY_STATUS_STUDYING
        ];

        List<Internship_Requirement__c> internshipRequirements = new List<Internship_Requirement__c>();
        Map<Id, EducationHistoryWrapper> educationHistoryId2Wrapper = new Map<Id, EducationHistoryWrapper>();

        for (hed__Education_History__c history : educationHistories) {
            EducationHistoryWrapper educationHistoryWrapper = new EducationHistoryWrapper();
            educationHistoryWrapper.value = history.Id;
            educationHistoryWrapper.label = history.DT_Field_of_study__c;
            educationHistoryWrapper.studyStartDate = history.hed__Start_Date__c;
            if (!history.hed__Program_Enrollments__r.isEmpty()) {
                educationHistoryWrapper.newestProgramEnrollmentId = history.hed__Program_Enrollments__r[0].Id;
            }

            List<RequirementWrapper> requirementWrappers;
            if (!history.Internship_Requirements__r.isEmpty()) {
                internshipRequirements.addAll(history.Internship_Requirements__r);

                requirementWrappers = createRequirementWrappers(
                    history.Internship_Requirements__r, educationHistoryWrapper, offerAssignmentAccountIds, pageContextLanguage
                );

                if (requirementWrappers.isEmpty() && !wrapper.hasOfferNonObligatoryAssignment) {
                    continue;
                }
                wrapper.hasMatchingRequirementToAssignments = true;
                educationHistoryWrapper.requirements.addAll(requirementWrappers);
            }

            educationHistoryId2Wrapper.put(history.Id, educationHistoryWrapper);
        }

        wrapper.institutionalApplicationRecordTypeId = Utils.getRecordTypeIdByDevName(
            Career_Services_Application__c.getSObjectType(),
            Constants.CAREER_SERVICES_APPLICATION_RT_INSTITUTIONAL_INTERNSHIP
        );

        wrapper.educationHistories = educationHistoryId2Wrapper.values();
        wrapper.hasAnyRequirement = !internshipRequirements.isEmpty();

        return wrapper;
    }

    public static List<RequirementWrapper> createRequirementWrappers(
        List<Internship_Requirement__c> internshipRequirements, EducationHistoryWrapper educationHistoryWrapper, Set<Id> offerAssignmentAccountIds, String pageContextLanguage
    ){
        List<RequirementWrapper> requirementWrappersMatchToOfferAssignments = new List<RequirementWrapper>();
        for (Internship_Requirement__c requirement : internshipRequirements) {
                Id availableForAccountId;
                if (requirement.Internship_Group__r.Pathway__c != null) {
                    availableForAccountId = requirement.Internship_Group__r.Pathway__c;
                } else if (requirement.Internship_Group__r.Specialty__c != null) {
                    availableForAccountId = requirement.Internship_Group__r.Specialty__c;
                } else {
                    availableForAccountId = requirement.Internship_Group__r.Academic_Program__c;
                }

                if (!offerAssignmentAccountIds.contains(availableForAccountId)) {
                    continue;
                }

                RequirementWrapper requirementWrapper = new RequirementWrapper();
                requirementWrapper.value = requirement.Id;
                requirementWrapper.label = requirement.Name;
                requirementWrapper.details.add(new RequirementDetailWrapper(Label.MySWPS_Internship_Requirement_Selector_Study_Field, educationHistoryWrapper.label));

                String specialty = pageContextLanguage == Constants.COMMUNITY_LANG_PL
                    ? requirement.Internship_Group__r.Specialty__r.DT_Specialty_PL__c
                    : requirement.Internship_Group__r.Specialty__r.DT_Specialty_EN__c;

                if (String.isNotBlank(specialty)) {
                    requirementWrapper.details.add(new RequirementDetailWrapper(
                        Label.MySWPS_Internship_Requirement_Selector_Specialty_Label,
                        specialty
                    ));
                }

                if (String.isNotBlank(requirement.Internship_Group__r.Pathway__r.Name)) {
                    requirementWrapper.details.add(new RequirementDetailWrapper(
                        Label.MySWPS_Internship_Requirement_Selector_Pathway_Label,
                        requirement.Internship_Group__r.Pathway__r.Name
                    ));
                }

                requirementWrapper.details.add(new RequirementDetailWrapper(
                    Label.MySWPS_Internship_Requirement_Selector_Required_Hours_Label,
                    String.valueOf(requirement.Internship_Group__r.Internship_Issuance__r.Required_Hours__c)
                ));

            requirementWrappersMatchToOfferAssignments.add(requirementWrapper);
        }
        return requirementWrappersMatchToOfferAssignments;
    }

    @AuraEnabled
    public static Id submitApplication(
        Id internshipOfferId,
        InternshipApplicationConsentsWrapper consentsWrapper,
        List<Id> selectedRequirementIds,
        Id studentContactId,
        Id selectedProgramEnrollmentId,
        Boolean isObligatory
    ) {

        MySwpsConsentCreator.createConsentsForContact(
            new Set<Id>(consentsWrapper.checkedConsentIds),
            consentsWrapper.userDetails,
            consentsWrapper.formUrl,
            studentContactId
        );

        Id institutionalApplicationRecordTypeId = Utils.getRecordTypeIdByDevName(
            Career_Services_Application__c.getSObjectType(),
            Constants.CAREER_SERVICES_APPLICATION_RT_INSTITUTIONAL_INTERNSHIP
        );

        Career_Services_Application__c application = new Career_Services_Application__c(
            Career_Services_Offer__c = internshipOfferId,
            Status__c = Constants.CAREER_SERVICES_APPLICATION_STATUS_NEW_APPLICATION,
            Program_Enrollment__c = selectedProgramEnrollmentId,
            Student__c = studentContactId,
            Is_Obligatory__c = isObligatory,
            RecordTypeId = institutionalApplicationRecordTypeId
        );

        insert application;

        if (!application.Is_Obligatory__c) {
            return application.Id;
        }

        List<Internship_Settlement__c> settlements = new List<Internship_Settlement__c>();

        for (Id requirementId : selectedRequirementIds) {
            settlements.add(new Internship_Settlement__c(Internship_Requirement__c = requirementId, Career_Services_Application__c = application.Id));
        }

        insert settlements;

        return application.Id;
    }

    public class InternshipApplicationConsentsWrapper {
        @AuraEnabled
        public List<Id> checkedConsentIds { get; set; }
        @AuraEnabled
        public String formUrl { get; set; }
        @AuraEnabled
        public String userDetails { get; set; }
    }


    public class FormInitialDataWrapper {

        public FormInitialDataWrapper() {
            educationHistories = new List<EducationHistoryWrapper>();
        }

        @AuraEnabled
        public Id studentContactId;
        @AuraEnabled
        public Id institutionalApplicationRecordTypeId;
        @AuraEnabled
        public List<EducationHistoryWrapper> educationHistories;
        @AuraEnabled
        public Boolean hasAnyRequirement = false;
        @AuraEnabled
        public Boolean hasOfferRequiredDocuments = false;
        @AuraEnabled
        public String offerRequiredDocumentTypes;
        @AuraEnabled
        public Boolean hasOfferNonObligatoryAssignment = false;
        @AuraEnabled
        public Boolean hasMatchingRequirementToAssignments = false;
        @AuraEnabled
        public Id lastApplicationId;
    }

    public class EducationHistoryWrapper {

        public EducationHistoryWrapper() {
            requirements = new List<RequirementWrapper>();
        }

        @AuraEnabled
        public String value;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public Id newestProgramEnrollmentId;
        @AuraEnabled
        public List<RequirementWrapper> requirements;
        @AuraEnabled
        public Date studyStartDate;
    }

    public class RequirementWrapper {

        public RequirementWrapper() {
            details = new List<RequirementDetailWrapper>();
        }

        @AuraEnabled
        public Id value;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public List<RequirementDetailWrapper> details;
    }

    public class RequirementDetailWrapper {
        public RequirementDetailWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String label;
    }
}