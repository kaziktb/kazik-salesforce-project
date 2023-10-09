@IsTest
public class CsOfferContractTestDataFactory {
    public static Career_Services_Offer_Contract__c createPublishedOfferContract(Id contractId, Id offerId, Boolean withInsert) {
        return withInsert
            ? new CsOfferContractTestData()
                .withContract(contractId)
                .withCareerServicesOffer(offerId)
                .withStatus(Constants.CAREER_SERVICES_OFFER_CONTRACT_STATUS_PUBLISHED_API_NAME)
                .save()
                .get()
            : new CsOfferContractTestData()
                .withContract(contractId)
                .withCareerServicesOffer(offerId)
                .withStatus(Constants.CAREER_SERVICES_OFFER_CONTRACT_STATUS_PUBLISHED_API_NAME)
                .get();
    }

    public static Career_Services_Offer_Contract__c createDraftOfferContractStartingToday(Id contractId, Id offerId, Boolean withInsert) {

        CsOfferContractTestData offerContractTestData = new CsOfferContractTestData()
            .withContract(contractId)
            .withCareerServicesOffer(offerId)
            .withStatus(Constants.CAREER_SERVICES_OFFER_CONTRACT_STATUS_DRAFT_API_NAME)
            .withStartDate(Date.today())
            .withEndDate(Date.today().addDays(90))
            .withCandidatesAccepted(0)
            .withCandidatesToSubmit(5);

        return withInsert ? offerContractTestData.save().get() : offerContractTestData.get();
    }

    public static Career_Services_Offer_Contract__c createPublishedOfferContractToBeExpired(Id contractId, Id offerId, Boolean withInsert) {
        CsOfferContractTestData offerContractTestData = new CsOfferContractTestData()
            .withContract(contractId)
            .withCareerServicesOffer(offerId)
            .withStatus(Constants.CAREER_SERVICES_OFFER_CONTRACT_STATUS_PUBLISHED_API_NAME)
            .withStartDate(Date.today().addDays(-89))
            .withEndDate(Date.today().addDays(-1))
            .withCandidatesToSubmit(5)
            .withCandidatesAccepted(4);

        return withInsert ? offerContractTestData.save().get() : offerContractTestData.get();
    }

    public static Career_Services_Offer_Contract__c createPublishedOfferContractToBeCompleted(Id contractId, Id offerId, Boolean withInsert) {
        CsOfferContractTestData offerContractTestData = new CsOfferContractTestData()
            .withContract(contractId)
            .withCareerServicesOffer(offerId)
            .withStatus(Constants.CAREER_SERVICES_OFFER_CONTRACT_STATUS_PUBLISHED_API_NAME)
            .withStartDate(Date.today().addDays(-45))
            .withEndDate(Date.today().addDays(45))
            .withCandidatesToSubmit(5)
            .withCandidatesAccepted(5);

        return withInsert ? offerContractTestData.save().get() : offerContractTestData.get();
    }

    public static Career_Services_Offer_Contract__c createPublishedOfferContractWithRecordType(Id contractId, Id offerId, String recordType, Boolean withInsert) {

        CsOfferContractTestData testData = new CsOfferContractTestData()
            .withContract(contractId)
            .withCareerServicesOffer(offerId)
            .withStatus(Constants.CAREER_SERVICES_OFFER_CONTRACT_STATUS_PUBLISHED_API_NAME)
            .withStartDate(Date.today()-45)
            .withEndDate(Date.today().addDays(45))
            .withRecordType(Utils.getRecordTypeIdByDevName(Career_Services_Offer_Contract__c.getSObjectType(), recordType));

        return withInsert ? testData.save().get() : testData.get();
    }

}