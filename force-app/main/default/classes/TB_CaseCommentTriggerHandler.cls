/**
 * Created by annaseveryna on 13/10/2022.
 */

public with sharing class TB_CaseCommentTriggerHandler extends TB_TriggerHandler{

    public override void beforeInsert() {
        handleCasesUpdate((List<CaseComment>)Trigger.new);
    }

    public override void beforeUpdate() {
        handleCasesUpdate((List<CaseComment>)Trigger.new);
    }

    public override void  beforeDelete() {
        handleCasesUpdate((List<CaseComment>)Trigger.old);
    }

    public override void afterUndelete() {
        handleCasesUpdate((List<CaseComment>)Trigger.new);
    }

    private static void handleCasesUpdate(List<CaseComment> comments) {
        List<Id> caseIds = new List<Id>();
        for (CaseComment comment : comments) {
            caseIds.add(comment.ParentId);
        }
        for (Case c : [
                SELECT Id
                FROM Case
                WHERE Id
                        IN :caseIds
        ]) {
            fillCaseLastActivityDate(c);
        }
    }

    private static void fillCaseLastActivityDate(Case c) {
        c.TB_Last_Activity_Date__c = new TB_CT_LastActivityManager().getCurrentDateTimePoland();
    }
}