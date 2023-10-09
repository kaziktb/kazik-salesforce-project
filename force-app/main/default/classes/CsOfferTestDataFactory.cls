@IsTest
public class CsOfferTestDataFactory {
    public static Career_Services_Offer__c createOffer(Boolean withInsert) {
        return withInsert ? new CsOfferTestData().save().get() : new CsOfferTestData().get();
    }

    public static Career_Services_Offer__c createOfferWithRecordType(String recordType, Boolean withInsert) {

        CsOfferTestData testData = new CsOfferTestData()
            .withRecordType(Utils.getRecordTypeIdByDevName(Career_Services_Offer__c.getSObjectType(), recordType));

        return withInsert ? testData.save().get() : testData.get();
    }


    public static Career_Services_Offer__c createInstitutionalInternshipOffer(Boolean withInsert) {
        Id recordTypeId = Utils.getRecordTypeIdByDevName(Career_Services_Offer__c.getSObjectType(), Constants.CAREER_SERVICES_OFFER_RT_INSTITUTIONAL_INTERNSHIP);

        return withInsert
            ? new CsOfferTestData()
                .withRecordType(recordTypeId)
                .save()
                .get()
            : new CsOfferTestData()
                .withRecordType(recordTypeId)
                .get();
    }
}