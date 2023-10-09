public without sharing class MySwpsInstitutionalApplicationDetailCtrl {
    @AuraEnabled(Cacheable=true)
    public static InstitutionalApplicationDetailsWrapper fetchInstitutionalApplicationDetails(Id recordId, String pageContextLanguage) {
        return new InstitutionalApplicationDetailsWrapper([
            SELECT
                Career_Services_Offer__r.Offer_Title__c,
                Career_Services_Offer__r.Company__r.Name,
                Career_Services_Offer__r.Internship_Period_From__c,
                Career_Services_Offer__r.Internship_Period_To__c,
                Career_Services_Offer__r.Workplace__c,
                toLabel(Career_Services_Offer__r.Workplace_Type__c),
                toLabel(Career_Services_Offer__r.Business_Categories__c),
                toLabel(Career_Services_Offer__r.Salary__c),
                Career_Services_Offer__r.Is_Polish_Required__c,
                toLabel(Career_Services_Offer__r.Required_Recruitment_Documents__c),
                Career_Services_Offer__r.GDPR_Clause__c,
                Career_Services_Offer__r.Company_Description__c,
                Career_Services_Offer__r.Description_Of_Completed_Tasks__c,
                Career_Services_Offer__r.Requirements__c,
                Career_Services_Offer__r.Offer_Expiration_Date__c,
                toLabel(Status__c),
                Is_Obligatory__c,
                Internal_Supervisor__r.Name, (
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

    public class InstitutionalApplicationDetailsWrapper {
        @AuraEnabled
        public Career_Services_Application__c internshipApplication { get; set; }
        @AuraEnabled
        public List<RequirementWrapper> requirements;

        public InstitutionalApplicationDetailsWrapper(Career_Services_Application__c application, String pageContextLanguage) {
            internshipApplication = application;
            requirements = new List<MySwpsInstitutionalApplicationDetailCtrl.RequirementWrapper>();

            if (internshipApplication.Internship_Settlements__r.isEmpty()) {
                return;
            }

            List<Internship_Requirement__c> internshipRequirements = new List<Internship_Requirement__c>();

            for (Internship_Settlement__c settlement : internshipApplication.Internship_Settlements__r) {
                internshipRequirements.add(settlement.Internship_Requirement__r);
            }

            //TODO: refactor in future to remove duplicated code with MySwpsIndividualApplicationDetailCtrl, probably data preparation logic should be moved to lwc component
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