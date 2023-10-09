@IsTest
public class InternshipGroupTestDataFactory {

    public static List<Internship_Group__c> create(Id academicProgramId, Id internshipIssuanceId, Integer quantity, Boolean withInsert) {
        List<Internship_Group__c> internshipGroups = new List<Internship_Group__c>();

        for (Integer i = 0; i < quantity; i++) {
            internshipGroups.add(
                new InternshipGroupTestData()
                    .withAcademicProgram(academicProgramId)
                    .withInternshipIssuance(internshipIssuanceId)
                    .get()
            );
        }

        if (withInsert) {
            insert internshipGroups;
        }

        return internshipGroups;
    }
}