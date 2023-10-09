public with sharing class DT_InternshipApplicationHandler extends DT_TriggerHandler {
    private DT_InternshipApplicationHandler() {}

    public static DT_InternshipApplicationHandler instance {
        get {
            if (instance == null) {
                instance = new DT_InternshipApplicationHandler();
            }
            return instance;
        }
        private set;
    }

    public override void afterUpdate() {
        DT_InternshipApplicationHelper.recalculateInternshipVacancies(Trigger.new, (Map<Id, DT_Internship_Application__c>) Trigger.oldMap);
    }

    public override void afterDelete() {
        DT_InternshipApplicationHelper.recalculateInternshipVacancies(Trigger.old);
    }
}