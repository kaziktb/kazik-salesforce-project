@IsTest
public class CsOfferAssignmentTestDataFactory {
    public static Career_Services_Offer_Assignment__c createAssignment(Id accountId, Id offerId, Id supervisorId, Boolean withInsert) {
        CsOfferAssignmentTestData testData = new CsOfferAssignmentTestData()
            .withAccount(accountId)
            .withOffer(offerId)
            .withSupervisor(supervisorId);

        return withInsert ? testData.save().get() : testData.get();
    }
}