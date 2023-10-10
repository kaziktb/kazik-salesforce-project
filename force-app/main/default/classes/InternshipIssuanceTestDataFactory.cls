@IsTest
public class InternshipIssuanceTestDataFactory {

    public static List<Internship_Issuance__c> create(Decimal requiredHours, Integer quantity, Boolean withInsert) {
        List<Internship_Issuance__c> internshipIssuances = new List<Internship_Issuance__c>();

        for (Integer i = 0; i < quantity; i++) {
            internshipIssuances.add(
                new InternshipIssuanceTestData()
                    .withRequiredHours(requiredHours)
                    .get()
            );
        }

        if (withInsert) {
            insert internshipIssuances;
        }

        return internshipIssuances;
    }
}