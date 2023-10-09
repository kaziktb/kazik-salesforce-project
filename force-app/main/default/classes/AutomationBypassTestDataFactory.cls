public with sharing class AutomationBypassTestDataFactory {

    public static AutomationBypass__c createAutomationBypassConfigForUser(Boolean withInsert, Id userId) {
        return withInsert ?
            new AutomationBypassTestData(userId).withAutomationsBypass().save().get() :
            new AutomationBypassTestData(userId).withAutomationsBypass().get();
    }
}