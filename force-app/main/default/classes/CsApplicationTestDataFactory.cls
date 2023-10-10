@IsTest
public class CsApplicationTestDataFactory {
    public static Career_Services_Application__c createApplicationWithRecordType(String recordType, Boolean withInsert) {
        CsApplicationTestData testData = new CsApplicationTestData()
            .withRecordType(Utils.getRecordTypeIdByDevName(Career_Services_Application__c.getSObjectType(), recordType));

        return withInsert ? testData.save().get() : testData.get();
    }

    public static Career_Services_Application__c createApplicationWithRecordTypeAndOffer(String recordType, Id offerId, Boolean withInsert) {
        CsApplicationTestData testData = new CsApplicationTestData()
            .withRecordType(Utils.getRecordTypeIdByDevName(Career_Services_Application__c.getSObjectType(), recordType))
            .withOffer(offerId);

        return withInsert ? testData.save().get() : testData.get();
    }
    
}