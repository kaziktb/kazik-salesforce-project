public without sharing class MySwpsIndividualApplicationFormCtrl {

    @AuraEnabled(Cacheable=true)
    public static FormInitialDataWrapper fetchFormInitialData(String pageContextLanguage) {
        Id contactId = MySwpsUtils.fetchCustomerUserContactIdOrThrow(UserInfo.getUserId());

        FormInitialDataWrapper wrapper = new FormInitialDataWrapper();
        wrapper.studentContactId = contactId;

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
            internshipRequirements.addAll(history.Internship_Requirements__r);
            educationHistoryId2Wrapper.put(history.Id, educationHistoryWrapper);
        }

        for (Internship_Requirement__c requirement : internshipRequirements) {
            if (educationHistoryId2Wrapper.containsKey(requirement.Education_History__c)) {
                EducationHistoryWrapper educationHistoryWrapper = educationHistoryId2Wrapper.get(requirement.Education_History__c);
                RequirementWrapper requirementWrapper = new RequirementWrapper();
                requirementWrapper.value = requirement.Id;
                requirementWrapper.label = requirement.Name;
                requirementWrapper.details.add(new RequirementDetailWrapper(Label.MySWPS_Internship_Requirement_Selector_Study_Field, educationHistoryWrapper.label));

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

                educationHistoryWrapper.requirements.add(requirementWrapper);
            }
        }

        wrapper.companyAccountRecordTypeId = Utils.getRecordTypeIdByDevName(
            Account.getSObjectType(),
            Constants.ACCOUNT_RECORD_TYPE_BUSINESS_ORGANIZATION_API_NAME
        );

        wrapper.partnerContactRecordTypeId = Utils.getRecordTypeIdByDevName(
            Contact.getSObjectType(),
            Constants.CONTACT_PARTNER_RECORD_TYPE_DEV_NAME
        );

        wrapper.individualOfferRecordTypeId = Utils.getRecordTypeIdByDevName(
            Career_Services_Offer__c.getSObjectType(),
            Constants.CAREER_SERVICES_OFFER_RT_INDIVIDUAL_INTERNSHIP
        );

        wrapper.individualApplicationRecordTypeId = Utils.getRecordTypeIdByDevName(
            Career_Services_Application__c.getSObjectType(),
            Constants.CAREER_SERVICES_APPLICATION_RT_INDIVIDUAL_INTERNSHIP
        );

        wrapper.educationHistories = educationHistoryId2Wrapper.values();
        wrapper.hasAnyRequirement = !internshipRequirements.isEmpty();

        return wrapper;
    }

    @AuraEnabled
    public static StudentDataWrapper fetchStudentData(Id studentContactId, Id programEnrollmentId, String pageContextLanguage) {

        Contact userContact = [
            SELECT FirstName, LastName, (
                SELECT hed__Account__r.DT_Study_Field_PL__c,
                    hed__Account__r.DT_Study_Field_EN__c,
                    toLabel(hed__Program_Plan__r.DT_Language_of_Instruction__c),
                    DT_Album_Number__c,
                    hed__Program_Plan__r.DT_Specialty_PL__c,
                    hed__Program_Plan__r.DT_Specialty_EN__c,
                    hed__Account__r.DT_Department__r.Name,
                    toLabel(DT_Level_Of_Studies__c),
                    toLabel(DT_Mode_Of_Studies__c)
                FROM hed__Program_Enrollments__r
                WHERE Id = :programEnrollmentId
            )
            FROM Contact
            WHERE Id = :studentContactId
        ];

        StudentDataWrapper wrapper = new StudentDataWrapper();
        wrapper.firstName = userContact.FirstName;
        wrapper.lastName = userContact.LastName;

        if (userContact.hed__Program_Enrollments__r.isEmpty()) {
            return wrapper;
        }

        hed__Program_Enrollment__c programEnrollment = userContact.hed__Program_Enrollments__r[0];

        wrapper.studyField = pageContextLanguage == Constants.LANGUAGE_LOCALE_KEY_POLISH ? programEnrollment.hed__Account__r.DT_Study_Field_PL__c : programEnrollment.hed__Account__r.DT_Study_Field_EN__c;
        wrapper.languageOfInstruction = programEnrollment.hed__Program_Plan__r.DT_Language_of_Instruction__c;
        wrapper.albumNumber = programEnrollment.DT_Album_Number__c;
        wrapper.specialty = pageContextLanguage == Constants.LANGUAGE_LOCALE_KEY_POLISH ? programEnrollment.hed__Program_Plan__r.DT_Specialty_PL__c : programEnrollment.hed__Program_Plan__r.DT_Specialty_EN__c;
        wrapper.department = programEnrollment.hed__Account__r.DT_Department__r.Name;
        wrapper.studyLevel = programEnrollment.DT_Level_Of_Studies__c;
        wrapper.studyMode = programEnrollment.DT_Mode_Of_Studies__c;
        return wrapper;
    }

    @AuraEnabled
    public static Id submitApplication(
        Account company,
        Contact representative,
        Contact supervisor,
        Career_Services_Offer__c offer,
        InternshipApplicationConsentsWrapper consentsWrapper,
        Career_Services_Application__c application,
        List<Id> selectedRequirementIds,
        Id studentContactId,
        Id selectedProgramEnrollmentId
    ) {
        List<Account> existingAccounts = [
            SELECT Id
            FROM Account
            WHERE DT_Company_Tax_Id__c = :company.DT_Company_Tax_Id__c
        ];

        if (!existingAccounts.isEmpty()) {
            company.Id = existingAccounts[0].Id;
        }

        upsert company;

        Map<String, Contact> workEmail2FormContact = new Map<String, Contact>{
            representative.hed__WorkEmail__c => representative
        };

        if (String.isNotEmpty(supervisor.hed__WorkEmail__c)) {
            workEmail2FormContact.put(supervisor.hed__WorkEmail__c, supervisor);
        }

        MySwpsUtils.createFormContactsWithAccountRelation(workEmail2FormContact, company.Id);

        if (String.isNotEmpty(supervisor.hed__WorkEmail__c)) {
            offer.External_Supervisor__c = supervisor.Id;
        }

        MySwpsConsentCreator.createConsentsForContact(
            new Set<Id>(consentsWrapper.checkedConsentIds),
            consentsWrapper.userDetails,
            consentsWrapper.formUrl,
            studentContactId
        );

        offer.Organisation_Contact__c = representative.Id;
        offer.Company__c = company.Id;
        offer.Institution_Website__c = String.isNotBlank(company.Website) ? company.Website : '';

        insert offer;

        application.Career_Services_Offer__c = offer.Id;
        application.Status__c = Constants.CAREER_SERVICES_APPLICATION_STATUS_NEW_APPLICATION;
        application.Program_Enrollment__c = selectedProgramEnrollmentId;
        application.Student__c = studentContactId;

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

    public class StudentDataWrapper {
        @AuraEnabled
        public String firstName;
        @AuraEnabled
        public String lastName;
        @AuraEnabled
        public String studyField;
        @AuraEnabled
        public String languageOfInstruction;
        @AuraEnabled
        public String albumNumber;
        @AuraEnabled
        public String specialty;
        @AuraEnabled
        public String department;
        @AuraEnabled
        public String studyLevel;
        @AuraEnabled
        public String studyMode;
    }

    public class FormInitialDataWrapper {

        public FormInitialDataWrapper() {
            educationHistories = new List<EducationHistoryWrapper>();
        }

        @AuraEnabled
        public Id studentContactId;
        @AuraEnabled
        public Id companyAccountRecordTypeId;
        @AuraEnabled
        public Id partnerContactRecordTypeId;
        @AuraEnabled
        public Id individualOfferRecordTypeId;
        @AuraEnabled
        public Id individualApplicationRecordTypeId;
        @AuraEnabled
        public List<EducationHistoryWrapper> educationHistories;
        @AuraEnabled
        public Boolean hasAnyRequirement = false;
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