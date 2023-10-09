@IsTest
public class CsOfferTestData {
    public static Integer count = 0;
    private final Career_Services_Offer__c record;

    public CsOfferTestData() {
        record = new Career_Services_Offer__c();
        count++;
        applyDefaults();
    }

    public CsOfferTestData(CsOfferTestData testData) {
        record = testData.record.clone(false, true, false, false);
        count++;
        applyDefaults();
    }

    public CsOfferTestData applyDefaults() {
        return this;
    }

    public CsOfferTestData copy() {
        return new CsOfferTestData(this);
    }

    public Career_Services_Offer__c get() {
        return record;
    }

    public CsOfferTestData save() {
        if (record.Id == null) {
            insert record;
        } else {
            update record;
        }

        return this;
    }

    public CsOfferTestData withAdditionalSkills(String value) {
        record.Additional_Skills__c = value;
        return this;
    }

    public CsOfferTestData withAdditionalWaysOfCooperation(String value) {
        record.Additional_Skills__c = value;
        return this;
    }

    public CsOfferTestData withFlexibleWorkingHours() {
        record.Are_Working_Hours_Flexible__c = true;
        return this;
    }

    public CsOfferTestData withBusinessCategories(String value) {
        record.Business_Categories__c = value;
        return this;
    }

    public CsOfferTestData withCandidateStatuses(String value) {
        record.Candidate_Statuses__c = value;
        return this;
    }

    public CsOfferTestData withClauseOnPersonalDataProtection(String value) {
        record.GDPR_Clause__c = value;
        return this;
    }

    public CsOfferTestData withCompany(Id value) {
        record.Company__c = value;
        return this;
    }

    public CsOfferTestData withCompanyDescription(String value) {
        record.Company_Description__c = value;
        return this;
    }

    public CsOfferTestData withDescriptionOfCompletedTasks(String value) {
        record.Description_Of_Completed_Tasks__c = value;
        return this;
    }

    public CsOfferTestData withEmploymentType(String value) {
        record.Employment_Type__c = value;
        return this;
    }

    public CsOfferTestData withExternalSupervisor(Id value) {
        record.External_Supervisor__c = value;
        return this;
    }

    public CsOfferTestData withExternalSupervisorEducation(String value) {
        record.External_Supervisor_Education__c = value;
        return this;
    }

    public CsOfferTestData withInstitutionWebsite(String value) {
        record.Institution_Website__c = value;
        return this;
    }

    public CsOfferTestData withInternalSupervisor(Id value) {
        record.Internal_Supervisor__c = value;
        return this;
    }

    public CsOfferTestData withInternshipClockHours(Integer value) {
        record.Internship_Clock_Hours__c = value;
        return this;
    }

    public CsOfferTestData withInternshipPeriodFrom(Date value) {
        record.Internship_Period_From__c = value;
        return this;
    }

    public CsOfferTestData withInternshipPeriodTo(Date value) {
        record.Internship_Period_To__c = value;
        return this;
    }

    public CsOfferTestData withRequiredAgreementOrDeclaration() {
        record.Is_Agreement_Required__c = true;
        return this;
    }

    public CsOfferTestData withBilateralAgreementRequired() {
        record.Is_Bilateral_Agreement_Required__c = true;
        return this;
    }

    public CsOfferTestData withAccessibleBuilding() {
        record.Is_Building_Accessible__c = true;
        return this;
    }

    public CsOfferTestData withPaidInternship() {
        record.Is_Internship_Paid__c = true;
        return this;
    }

    public CsOfferTestData withPolishLanguageRequired() {
        record.Is_Polish_Required__c = true;
        return this;
    }

    public CsOfferTestData withLocationsOfSWPS(String value) {
        record.Locations_Of_SWPS__c = value;
        return this;
    }

    public CsOfferTestData withNumberOfApplications(Integer value) {
        record.Number_Of_Applications__c = value;
        return this;
    }

    public CsOfferTestData withOfferDescription(String value) {
        record.Offer_Description__c = value;
        return this;
    }

    public CsOfferTestData withOfferExpirationDate(Date value) {
        record.Offer_Expiration_Date__c = value;
        return this;
    }

    public CsOfferTestData withOfferOriginURL(String value) {
        record.Offer_Origin_URL__c = value;
        return this;
    }

    public CsOfferTestData withOfferTitle(String value) {
        record.Offer_Title__c = value;
        return this;
    }

    public CsOfferTestData withOrganisationContact(Id value) {
        record.Organisation_Contact__c = value;
        return this;
    }

    public CsOfferTestData withPositionLevel(String value) {
        record.Position_Level__c = value;
        return this;
    }

    public CsOfferTestData withRecordType(Id value) {
        record.RecordTypeId = value;
        return this;
    }

    public CsOfferTestData withRecruiter(Id value) {
        record.Recruiter__c = value;
        return this;
    }

    public CsOfferTestData withRequiredRecruitmentDocuments(String value) {
        record.Required_Recruitment_Documents__c = value;
        return this;
    }

    public CsOfferTestData withRequirements(String value) {
        record.Requirements__c = value;
        return this;
    }

    public CsOfferTestData withSalary(String value) {
        record.Salary__c = value;
        return this;
    }

    public CsOfferTestData withStatus(String value) {
        record.Status__c = value;
        return this;
    }

    public CsOfferTestData withVacancies(Integer value) {
        record.Vacancies__c = value;
        return this;
    }

    public CsOfferTestData withViews(Integer value) {
        record.Views__c = value;
        return this;
    }

    public CsOfferTestData withPositionOffer(String value) {
        record.Position_Offer__c = value;
        return this;
    }

    public CsOfferTestData withWeeklyWorkingHoursMaximum(Integer value) {
        record.Weekly_Working_Hours_Maximum__c = value;
        return this;
    }

    public CsOfferTestData withWeeklyWorkingHoursMinimum(Integer value) {
        record.Weekly_Working_Hours_Minimum__c = value;
        return this;
    }

    public CsOfferTestData withWorkplace(String value) {
        record.Workplace__c = value;
        return this;
    }

    public CsOfferTestData withWorkplaceType(String value) {
        record.Workplace_Type__c = value;
        return this;
    }

    public CsOfferTestData hasInternshipSupervisorAssistance() {
        record.Has_Internship_Supervisor_Assistance__c = true;
        return this;
    }

    public CsOfferTestData withSector(String value) {
        record.Sector__c = value;
        return this;
    }
}