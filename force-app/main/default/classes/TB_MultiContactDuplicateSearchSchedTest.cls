@IsTest
private class TB_MultiContactDuplicateSearchSchedTest {
    private static List<TB_Multi_Contact_Matching_Rule__mdt> generateMtds(Integer numberOfMtds) {
        List<TB_Multi_Contact_Matching_Rule__mdt> result = new List<TB_Multi_Contact_Matching_Rule__mdt>();
        for (Integer i = 0; i < numberOfMtds; i++) {
            TB_Multi_Contact_Matching_Rule__mdt metaData = new TB_Multi_Contact_Matching_Rule__mdt(
                TB_Matching_Field_API_Name__c = 'Contact field ' + i, 
                TB_Object_Matching_Field_API_Name__c = 'Object field ' + i, 
                TB_Object_Contact_Field_API_Name__c = 'Object contact field ' + i, 
                TB_Object_API_Name__c = 'Object name ' + math.mod(i, 3),
                TB_Active__c = true
            );
            result.add(metaData);
        }
        return result;
    }
    @IsTest
	private static void getObjectMatchersTest() {
        final Integer MTDS_SIZE = 10;
        Integer expectedMatchersNumber = MTDS_SIZE / 3;
        List<TB_Multi_Contact_Matching_Rule__mdt> matchingRules = generateMtds(MTDS_SIZE);
		Test.startTest();
            List<TB_MultiContactDuplicateSearchScheduler.ObjectMatcher> result = TB_MultiContactDuplicateSearchScheduler.getObjectMatchers(matchingRules);
		Test.stopTest();

        System.assertEquals(expectedMatchersNumber, result.size(), 'Matcher list size has to be equal to ' + expectedMatchersNumber);
	}

    @IsTest
	private static void executeTest() {
        final Integer MTDS_SIZE = 4;
        List<TB_Multi_Contact_Matching_Rule__mdt> matchingRules = generateMtds(MTDS_SIZE);
        TB_MultiContactDuplicateSearchScheduler scheduler = new TB_MultiContactDuplicateSearchScheduler();
        scheduler.doNotRunBatches = true;
		Test.startTest();
            scheduler.execute(null, matchingRules);
		Test.stopTest();
	}

    @IsTest
    private static void executeTest_NoMtds() {
        TB_MultiContactDuplicateSearchScheduler scheduler = new TB_MultiContactDuplicateSearchScheduler();
        scheduler.doNotRunBatches = true;
		Test.startTest();
            scheduler.execute();
		Test.stopTest();
	}
}