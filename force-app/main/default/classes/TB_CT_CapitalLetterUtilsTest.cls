@IsTest
private class TB_CT_CapitalLetterUtilsTest {

    @IsTest
    private static void capitalizeValueTest() {
        String lowerCaseName = 'test test-test';

        Test.startTest();
        String returnedName = new TB_CT_CapitalLetterUtils(lowerCaseName).capitalizeValue();
        Test.stopTest();

        System.assertEquals('Test Test-Test', returnedName);
    }

    @IsTest
    private static void capitalizeValuePrefixTest() {
        String lowerCaseName = 'test van der test-test';

        Test.startTest();
        String returnedName = new TB_CT_CapitalLetterUtils(lowerCaseName).capitalizeValue();
        Test.stopTest();

        System.assertEquals('Test van der Test-Test', returnedName);
    }
}