@IsTest
private class TB_CT_UtilsTest {
    @IsTest
    static void testGettingRecordTypeIdByDeveloperName() {
        // I cannot create mock record type of any SObject in test therefore
        // I query the first random record type from org.
        List<RecordType> recordType = [SELECT DeveloperName FROM RecordType LIMIT 1];

        if(!recordType.isEmpty()) {
            Test.startTest();
            Id recordTypeId = TB_CT_Utils.getRecordTypeIdByDeveloperName(recordType[0].DeveloperName);
            Test.stopTest();

            Assert.areEqual(recordType[0].Id, recordTypeId);
        }
    }
}