@IsTest
public with sharing class ProgramEnrollmentTestDataFactory {
    public static List<hed__Program_Enrollment__c> create(Id contactId, Id academicProgramId, Id educationHistoryId, Integer quantity, Boolean withInsert) {
        List<hed__Program_Enrollment__c> programEnrollments = new List<hed__Program_Enrollment__c>();

        for (Integer i = 0; i < quantity; i++) {
            programEnrollments.add(
                new ProgramEnrollmentTestData()
                    .withContact(contactId)
                    .withAcademicProgram(academicProgramId)
                    .withEducationHistory(educationHistoryId)
                    .get()
            );
        }

        if (withInsert) {
            insert programEnrollments;
        }

        return programEnrollments;
    }

    public static List<hed__Program_Enrollment__c> createWithProgramPlan(Id contactId, Id academicProgramId, Id educationHistoryId, Id programPlanId, Integer quantity, Boolean withInsert) {
        List<hed__Program_Enrollment__c> programEnrollments = new List<hed__Program_Enrollment__c>();

        for (Integer i = 0; i < quantity; i++) {
            programEnrollments.add(
                new ProgramEnrollmentTestData()
                    .withContact(contactId)
                    .withAcademicProgram(academicProgramId)
                    .withEducationHistory(educationHistoryId)
                    .withProgramPlan(programPlanId)
                    .get()
            );
        }

        if (withInsert) {
            insert programEnrollments;
        }

        return programEnrollments;
    }

}