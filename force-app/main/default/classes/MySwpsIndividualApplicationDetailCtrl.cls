public without sharing class MySwpsIndividualApplicationDetailCtrl {

    @AuraEnabled(Cacheable=true)
    public static IndividualApplicationDetailsWrapper fetchIndividualApplicationDetails(Id recordId, String pageContextLanguage) {
        return new IndividualApplicationDetailsWrapper([
            SELECT
                Career_Services_Offer__r.Company_Description__c,
                Career_Services_Offer__r.Company__r.BillingCity,
                Career_Services_Offer__r.Company__r.BillingCountry,
                Career_Services_Offer__r.Company__r.BillingPostalCode,
                Career_Services_Offer__r.Company__r.BillingStreet,
                Career_Services_Offer__r.Company__r.DT_Company_Tax_Id__c,
                Career_Services_Offer__r.Company__r.DT_KRS__c,
                Career_Services_Offer__r.Company__r.Name,
                Career_Services_Offer__r.Company__r.Website,
                Career_Services_Offer__r.Description_Of_Completed_Tasks__c,
                Career_Services_Offer__r.External_Supervisor_Education__c,
                Career_Services_Offer__r.External_Supervisor__r.FirstName,
                Career_Services_Offer__r.External_Supervisor__r.LastName,
                Career_Services_Offer__r.External_Supervisor__r.hed__WorkEmail__c,
                Career_Services_Offer__r.External_Supervisor__r.hed__WorkPhone__c,
                Career_Services_Offer__r.Internship_Clock_Hours__c,
                Career_Services_Offer__r.Internship_Didactive_Hours__c,
                Career_Services_Offer__r.Offer_Title__c,
                Career_Services_Offer__r.Organisation_Contact_Position__c,
                Career_Services_Offer__r.Organisation_Contact__r.FirstName,
                Career_Services_Offer__r.Organisation_Contact__r.LastName,
                Career_Services_Offer__r.Organisation_Contact__r.hed__WorkEmail__c,
                Career_Services_Offer__r.Organisation_Contact__r.hed__WorkPhone__c,
                Internal_Supervisor__r.Name,
                Internship_Commencement_Date__c,
                Internship_Completion_Date__c,
                Is_Obligatory__c,
                Is_Practice_At_Workplace__c,
                Status__c,
                CreatedDate,
                toLabel(Status__c) statusLabel, (
                    SELECT
                        Internship_Requirement__r.Name,
                        Internship_Requirement__r.Education_History__r.DT_Field_of_study__c,
                        Internship_Requirement__r.Internship_Group__r.Specialty__r.DT_Specialty_PL__c,
                        Internship_Requirement__r.Internship_Group__r.Specialty__r.DT_Specialty_EN__c,
                        Internship_Requirement__r.Internship_Group__r.Pathway__r.Name,
                        Internship_Requirement__r.Internship_Group__r.Internship_Issuance__r.Required_Hours__c,
                        Internship_Requirement__r.Education_History__r.hed__Start_Date__c
                    FROM Internship_Settlements__r
                )
            FROM Career_Services_Application__c
            WHERE Id = :recordId
        ], pageContextLanguage);
    }

    @AuraEnabled
    public static String changeStatusToReverification(Id applicationId) {
        String newStatus = Constants.CAREER_SERVICES_APPLICATION_STATUS_REVERIFICATION;

        update new Career_Services_Application__c(
            Id = applicationId,
            Status__c = newStatus
        );

        return [SELECT toLabel(Status__c) FROM Career_Services_Application__c WHERE Id = :applicationId].Status__c;
    }

    public class IndividualApplicationDetailsWrapper {

        @AuraEnabled
        public Boolean canEdit { get; set; }
        @AuraEnabled
        public Career_Services_Application__c internshipApplication { get; set; }
        @AuraEnabled
        public Date minCommencementDate { get; set; }
        @AuraEnabled
        public List<RequirementWrapper> requirements { get; set; }
        @AuraEnabled
        public String supervisorEducation { get; set; }

        public IndividualApplicationDetailsWrapper(Career_Services_Application__c application, String pageContextLanguage) {
            requirements = new List<MySwpsIndividualApplicationDetailCtrl.RequirementWrapper>();
            canEdit = application.Status__c == Constants.CAREER_SERVICES_APPLICATION_STATUS_CORRECTION_NEEDED;
            internshipApplication = application;
            minCommencementDate = application.CreatedDate.date();
            supervisorEducation = [SELECT toLabel(External_Supervisor_Education__c) FROM Career_Services_Offer__c WHERE Id = :application.Career_Services_Offer__c].External_Supervisor_Education__c;

            if (!internshipApplication.Is_Practice_At_Workplace__c || internshipApplication.Internship_Settlements__r.isEmpty()) {
                return;
            }

            minCommencementDate = internshipApplication.Internship_Settlements__r[0].Internship_Requirement__r.Education_History__r.hed__Start_Date__c;

            List<Internship_Requirement__c> internshipRequirements = new List<Internship_Requirement__c>();

            for (Internship_Settlement__c settlement : internshipApplication.Internship_Settlements__r) {
                internshipRequirements.add(settlement.Internship_Requirement__r);
            }

            for (Internship_Requirement__c requirement : internshipRequirements) {
                    RequirementWrapper requirementWrapper = new RequirementWrapper();
                    requirementWrapper.label = requirement.Name;
                    requirementWrapper.details.add(new RequirementDetailWrapper(Label.MySWPS_Internship_Requirement_Selector_Study_Field, requirement.Education_History__r.DT_Field_of_study__c));

                    String specialty = pageContextLanguage == Constants.LANGUAGE_LOCALE_KEY_POLISH
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

                    requirements.add(requirementWrapper);
            }
        }
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