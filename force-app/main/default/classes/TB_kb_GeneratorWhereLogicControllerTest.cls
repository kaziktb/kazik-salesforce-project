@isTest
private class TB_kb_GeneratorWhereLogicControllerTest {
    private static final String QUERY_EXAMPLE = 'SELECT Id FROM Contact WHERE FirstName = \'Test\'';
    private static final String INVALID_EXPRESSION = 'INVALID';
    
    @TestSetup
    static void testSetup(){
        TB_Public_Group_Assignment__c pga = new TB_Public_Group_Assignment__c(
            Name='Test',
            TB_Public_Group__c='TB_KB_doktoranci'
        );
        insert pga;
    }

    @isTest
    static void shouldReturnQuery() {
        String jsonData = '[{"itemId":1,"field":"FirstName","operator":"=","value":"Test"}]';
        String logic = '1';
        String objectApi = 'Contact';
        String result;

        Test.startTest();
        result = TB_kb_GeneratorWhereLogicController.getQueryResults(jsonData, logic, objectApi);
        Test.stopTest();

        Assert.isTrue(result == QUERY_EXAMPLE);
    }

    @IsTest
    static void shouldModifyGroupAssignmentLogicField() {
        TB_Public_Group_Assignment__c pga = [SELECT Id, Name, TB_Group_Assignment_Logic__c FROM TB_Public_Group_Assignment__c WHERE Name =: 'Test' LIMIT 1];

        Test.startTest();
        TB_kb_GeneratorWhereLogicController.modifyGroupAssignmentLogic(pga.Id, QUERY_EXAMPLE);
        Test.stopTest();

        Assert.isTrue([SELECT Id, Name, TB_Group_Assignment_Logic__c FROM TB_Public_Group_Assignment__c WHERE Name =: 'Test' AND TB_Group_Assignment_Logic__c =: QUERY_EXAMPLE LIMIT 1].size() == 1);
    }

    @isTest
    static void throwAnError_whenInvalidParametersPassedToGetQueryResults(){
        Boolean errorOccurred = false;
        String result;

        Test.startTest();
        try {
            result = TB_kb_GeneratorWhereLogicController.getQueryResults(INVALID_EXPRESSION, INVALID_EXPRESSION, INVALID_EXPRESSION);
        } catch (Exception e) {
            errorOccurred = true;
        }
        Test.stopTest();

        Assert.isTrue(errorOccurred);
    }

    @isTest
    static void throwAnError_whenInvalidParametersPassedToModifyGroupAssignmentLogic(){
        Boolean errorOccurred = false;

        Test.startTest();
        try {
            TB_kb_GeneratorWhereLogicController.modifyGroupAssignmentLogic(INVALID_EXPRESSION, INVALID_EXPRESSION);
        } catch (Exception e) {
            errorOccurred = true;
        }
        Test.stopTest();

        Assert.isTrue(errorOccurred);
    }
}