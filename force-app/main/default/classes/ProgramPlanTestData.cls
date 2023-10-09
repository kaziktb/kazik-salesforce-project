@IsTest
public with sharing class ProgramPlanTestData {

    public static final String DEFAULT_NAME = 'Test Account';
    public static final String DEFAULT_SPECIALTY_PL = 'Test Specialty PL';
    public static final String DEFAULT_SPECIALTY_EN = 'Test Specialty EN';
    public static final String DEFAULT_CAMPUS = 'Warszawa';
    public static final String DEFAULT_MODE_OF_STUDIES = Constants.PROGRAM_PLAN_MODE_OF_STUDIES_FULL_TIME_API_NAME;
    public static final String DEFAULT_LANGUAGE_OF_INSTRUCTION = Constants.PROGRAM_PLAN_LANGUAGE_OF_INSTRUCTION_POLISH_API_NAME;
    public static Integer count = 0;
    private final hed__Program_Plan__c record;

    public ProgramPlanTestData() {
        record = new hed__Program_Plan__c();
        count++;
        applyDefaults();
    }

    public ProgramPlanTestData(ProgramPlanTestData testData) {
        record = testData.record.clone(false, true, false, false);
        count++;
        applyDefaults();
    }

    public ProgramPlanTestData applyDefaults() {
        return withName(getDefaultName())
            .withSpecialtyPL(DEFAULT_SPECIALTY_PL)
            .withSpecialtyEN(DEFAULT_SPECIALTY_EN)
            .withModeOfStudies(DEFAULT_MODE_OF_STUDIES)
            .withCampus(DEFAULT_CAMPUS)
            .withLanguageOfInstruction(DEFAULT_LANGUAGE_OF_INSTRUCTION);
    }

    public ProgramPlanTestData copy() {
        return new ProgramPlanTestData(this);
    }

    public hed__Program_Plan__c get() {
        return record;
    }

    public ProgramPlanTestData save() {
        if (record.Id == null) {
            insert record;
        } else {
            update record;
        }
        return this;
    }

    public String getDefaultName() {
        return String.join(new List<String>{DEFAULT_NAME, String.valueOf(count)}, '');
    }

    public ProgramPlanTestData withName(String value) {
        record.Name = value;
        return this;
    }

    public ProgramPlanTestData withLanguageOfInstruction(String val) {
        record.DT_Language_of_Instruction__c = val;
        return this;
    }

    public ProgramPlanTestData withSpecialtyPL(String val) {
        record.DT_Specialty_PL__c = val;
        return this;
    }

    public ProgramPlanTestData withSpecialtyEN(String val) {
        record.DT_Specialty_EN__c = val;
        return this;
    }

    public ProgramPlanTestData withModeOfStudies(String val) {
        record.DT_Mode_of_Studies__c = val;
        return this;
    }

    public ProgramPlanTestData withCampus(String val) {
        record.DT_Campus__c = val;
        return this;
    }

    public ProgramPlanTestData withStatus(String val) {
        record.hed__Status__c = val;
        return this;
    }
}