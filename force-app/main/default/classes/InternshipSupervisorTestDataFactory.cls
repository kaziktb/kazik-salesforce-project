@IsTest
public class InternshipSupervisorTestDataFactory {
    public static Internship_Supervisor__c createInternshipSupervisor(Id contactId, Id userId, String type, String name, Boolean withInsert) {
        InternshipSupervisorTestData testData = new InternshipSupervisorTestData()
            .withContact(contactId)
            .withUser(userId)
            .withType(type)
            .withName(name);

        return withInsert ? testData.save().get() : testData.get();
    }
}