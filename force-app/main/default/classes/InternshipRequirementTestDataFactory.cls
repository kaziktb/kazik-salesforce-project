@IsTest
public class InternshipRequirementTestDataFactory {

    public static List<Internship_Requirement__c> create(Id educationHistoryId, Id internshipGroupId, Integer quantity, Boolean withInsert) {
        List<Internship_Requirement__c> internshipRequirements = new List<Internship_Requirement__c>();

        for (Integer i = 0; i < quantity; i++) {
            internshipRequirements.add(
                new InternshipRequirementTestData()
                    .withEducationHistory(educationHistoryId)
                    .withInternshipGroup(internshipGroupId)
                    .withSemester(1)
                    .withYear(1)
                    .get()
            );
        }

        if (withInsert) {
            insert internshipRequirements;
        }

        return internshipRequirements;

    }

}