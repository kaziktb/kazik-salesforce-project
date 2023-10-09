@IsTest
public with sharing class InternshipRequirementTestData {
    public static Integer count = 0;
    private final Internship_Requirement__c record;

    public InternshipRequirementTestData() {
        record = new Internship_Requirement__c();
        count++;
        applyDefaults();
    }

    public InternshipRequirementTestData(InternshipRequirementTestData testData) {
        record = testData.record.clone(false, true, false, false);
        count++;
        applyDefaults();
    }

    public InternshipRequirementTestData applyDefaults() {
        return this;
    }

    public InternshipRequirementTestData copy() {
        return new InternshipRequirementTestData(this);
    }

    public Internship_Requirement__c get() {
        return record;
    }

    public InternshipRequirementTestData save() {
        if (record.Id == null) {
            insert record;
        } else {
            update record;
        }
        return this;
    }

    public InternshipRequirementTestData withInternshipGroup(Id value) {
        record.Internship_Group__c = value;
        return this;
    }

    public InternshipRequirementTestData withEducationHistory(Id value) {
        record.Education_History__c = value;
        return this;
    }

    public InternshipRequirementTestData withProgramEnrollment(Id value) {
        record.Program_Enrollment__c = value;
        return this;
    }

    public InternshipRequirementTestData withIsCompleted(Boolean value) {
        record.Is_Completed__c = value;
        return this;
    }

    public InternshipRequirementTestData withSemester(Integer value) {
        record.Semester__c = value;
        return this;
    }

    public InternshipRequirementTestData withYear(Integer value) {
        record.Year__c = value;
        return this;
    }
}