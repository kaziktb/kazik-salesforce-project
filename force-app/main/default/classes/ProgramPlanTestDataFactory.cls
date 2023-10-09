@IsTest
public with sharing class ProgramPlanTestDataFactory {

    public static List<hed__Program_Plan__c> createCurrent(Integer quantity, Boolean withInsert) {
        List<hed__Program_Plan__c> educationHistories = new List<hed__Program_Plan__c>();

        for (Integer i = 0; i < quantity; i++) {
            educationHistories.add(new ProgramPlanTestData().withStatus(Constants.PROGRAM_PLAN_STATUS_CURRENT).get());
        }

        if (withInsert) {
            insert educationHistories;
        }

        return educationHistories;
    }
}