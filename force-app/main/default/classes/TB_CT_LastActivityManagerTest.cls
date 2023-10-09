@IsTest
private class TB_CT_LastActivityManagerTest {

    private static final Datetime EXPECTED_DATETIME = Datetime.newInstance(2022, 02, 02, 12, 0, 0);


    @IsTest
    private static void getCurrentDateTimePolandTest() {

        Test.startTest();
        Datetime result = new TB_CT_LastActivityManager().getCurrentDateTimePoland();
        Test.stopTest();

        System.assertEquals(EXPECTED_DATETIME, result);
    }
}