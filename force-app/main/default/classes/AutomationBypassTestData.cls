public with sharing class AutomationBypassTestData {
    private AutomationBypass__c record;

    public AutomationBypassTestData(Id forUserId) {
        record = new AutomationBypass__c(SetupOwnerId = forUserId);
    }

    public AutomationBypass__c get() {
        return record;
    }

    public AutomationBypassTestData save() {
        if (record.Id == null) {
            insert record;
        } else {
            update record;
        }
        return this;
    }

    public AutomationBypassTestData withAllBypasses() {
        withAutomationsBypass();
        withValidationsBypass();
        return this;
    }

    public AutomationBypassTestData withAutomationsBypass() {
        record.Bypass_Automations__c = true;
        return this;
    }

    public AutomationBypassTestData withValidationsBypass() {
        record.Bypass_Validations__c = true;
        return this;
    }
}