@IsTest
public with sharing class ProgramEnrollmentTestData {
    public static final String DEFAULT_ALBUM_NUMBER = '12345';
    public static Integer count = 0;
    private final hed__Program_Enrollment__c record;

    public ProgramEnrollmentTestData() {
        record = new hed__Program_Enrollment__c();
        count++;
        applyDefaults();
    }

    public ProgramEnrollmentTestData(ProgramEnrollmentTestData testData) {
        record = testData.record.clone(false, true, false, false);
        count++;
        applyDefaults();
    }

    public ProgramEnrollmentTestData applyDefaults() {
        return withAlbumNumber(DEFAULT_ALBUM_NUMBER)
            .withStudyLevel(Constants.PROGRAM_ENROLLMENT_LEVEL_OF_STUDIES_BACHELOR_API_NAME)
            .withStudyMode(Constants.PROGRAM_ENROLLMENT_MODE_OF_STUDIES_FULL_TIME_API_NAME);
    }

    public ProgramEnrollmentTestData copy() {
        return new ProgramEnrollmentTestData(this);
    }

    public hed__Program_Enrollment__c get() {
        return record;
    }

    public ProgramEnrollmentTestData save() {
        if (record.Id == null) {
            insert record;
        } else {
            update record;
        }
        return this;
    }

    public ProgramEnrollmentTestData withContact(Id value) {
        record.hed__Contact__c = value;
        return this;
    }

    public ProgramEnrollmentTestData withAcademicProgram(Id value) {
        record.hed__Account__c = value;
        return this;
    }

    public ProgramEnrollmentTestData withEducationHistory(Id value) {
        record.hed__Education_History__c = value;
        return this;
    }

    public ProgramEnrollmentTestData withProgramPlan(Id value) {
        record.hed__Program_Plan__c = value;
        return this;
    }

    public ProgramEnrollmentTestData withAlbumNumber(String value) {
        record.DT_Album_Number__c = value;
        return this;
    }

    public ProgramEnrollmentTestData withStudyLevel(String value) {
        record.DT_Level_Of_Studies__c = value;
        return this;
    }

    public ProgramEnrollmentTestData withStudyMode(String value) {
        record.DT_Mode_Of_Studies__c = value;
        return this;
    }
}