public with sharing class TB_AgentWorkTriggerHandler extends TB_TriggerHandler
{
    private static final List<String> SS_RECORD_TYPES = new List<String>{'TB_Student_Question_HE','TB_Student_Application_HE','TB_Student_Certificate_HE','TB_Student_Meeting_HE','TB_Student_Notification_HE'};
    
    private List<AgentWork> toProcess = (List<AgentWork>)Trigger.new;
    
    public override void afterInsert()
    {
        updateCaseOwnerNameOnAccept();
    }
    
    private void updateCaseOwnerNameOnAccept()
    {
        Set<Id> caseIds = new Set<Id>();
        for(AgentWork aw : toProcess)
        {
            if(Schema.SObjectType.Case.getSObjectType() == aw.WorkItemId.getSobjectType())
            {
                caseIds.add(aw.WorkItemId);
            }
        }
        setCaseOwnerName(caseIds);
    }
    
    @TestVisible
    @Future
    private static void setCaseOwnerName(Set<Id> caseIds)
    {
        List<Case> cases = [SELECT Id, OwnerId, TB_Case_Owner_Name__c FROM Case WHERE Id IN :caseIds AND RecordType.DeveloperName IN :SS_RECORD_TYPES];
        Set<Id> ownerIds = new Set<Id>();
        for(Case singleCase : cases)
        {
            ownerIds.add(singleCase.OwnerId);
        }
        List<Group> groups = [SELECT Id, Name FROM Group WHERE Id IN :ownerIds];
        List<User> users = [SELECT Id, FirstName, LastName FROM User WHERE Id IN :ownerIds];
        Map<Id,String> namesByOwnerId = new Map<Id,String>();
        for(Group singleGroup : groups)
        {
            namesByOwnerId.put(singleGroup.Id,singleGroup.Name);
        }
        for(User singleUser : users)
        {
            namesByOwnerId.put(singleUser.Id,singleUser.FirstName + ' ' + singleUser.LastName);
        }
        for(Case singleCase : cases)
        {
            singleCase.TB_Case_Owner_Name__c = namesByOwnerId.get(singleCase.OwnerId);
        }
        TB_TriggerHandler.bypassAllTriggers = true;
        Database.update(cases,false);
    }
}