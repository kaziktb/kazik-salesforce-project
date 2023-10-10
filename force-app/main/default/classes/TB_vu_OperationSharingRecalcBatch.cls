global without sharing class TB_vu_OperationSharingRecalcBatch implements Database.Batchable<SObject>
{
    private static final String APPLICATION_RT_DEVNAME = 'TB_Student_Application_HE';
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator([SELECT Id FROM Case WHERE RecordType.DeveloperName = :APPLICATION_RT_DEVNAME]);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope)
    {
        Set<Id> caseIds = new Set<Id>();
        for(Case singleCase : (List<Case>)scope)
        {
            caseIds.add(singleCase.Id);
        }
        TB_vu_OperationSharingService.shareOperationsByCaseIdsSync(caseIds);
    }
    
    global void finish(Database.BatchableContext param1)
    {
    }
}