public without sharing class TB_vu_OperationSharingService
{
    @TestVisible
    private static final String ROW_CAUSE_DECISION_MAKER = 'TB_Decision_Maker__c';
    private static final String UNABLE_TO_LOCK_ROW_MESSAGE = 'UNABLE_TO_LOCK_ROW';
    private static final Integer MAX_ACTIVATION_LOOPS = 5;
    
    @Future
    public static void shareOperationsByCaseIds(Set<Id> caseIds)
    {
        List<TB_Operation__c> operationsToShare = [SELECT Id, TB_Case__c, TB_Decision_Maker__r.TB_User__c FROM TB_Operation__c WHERE TB_Case__c IN :caseIds];
        System.enqueueJob(new OperationSharingQueueable(operationsToShare));
    }
    
    public static void shareOperationsByCaseIdsSync(Set<Id> caseIds)
    {
        List<TB_Operation__c> operationsToShare = [SELECT Id, TB_Case__c, TB_Decision_Maker__r.TB_User__c FROM TB_Operation__c WHERE TB_Case__c IN :caseIds];
        System.enqueueJob(new OperationSharingQueueable(operationsToShare));
    }
    
    @TestVisible
    private class OperationSharingQueueable implements Queueable
    {
        private Map<Id,List<Id>> operationIdsByCaseId = new Map<Id,List<Id>>();
        private Map<Id,List<Id>> dmUserIdsByCaseId = new Map<Id,List<Id>>();
        
        private Set<Id> userIdsToActivate = new Set<Id>();
        private Integer activationLoops = 0;
        
        @TestVisible
        private Boolean usersActivated = false;
        
        @TestVisible
        private OperationSharingQueueable(List<TB_Operation__c> operationsToShare)
        {
            for(TB_Operation__c operation : operationsToShare)
            {
                if(operationIdsByCaseId.containsKey(operation.TB_Case__c))
                {
                    operationIdsByCaseId.get(operation.TB_Case__c).add(operation.Id);
                }
                else
                {
                    operationIdsByCaseId.put(operation.TB_Case__c,new List<Id>{operation.Id});
                }
                if(operation.TB_Decision_Maker__r != null && operation.TB_Decision_Maker__r.TB_User__c != null)
                {
                    userIdsToActivate.add(operation.TB_Decision_Maker__r.TB_User__c);
                    if(dmUserIdsByCaseId.containsKey(operation.TB_Case__c))
                    {
                        dmUserIdsByCaseId.get(operation.TB_Case__c).add(operation.TB_Decision_Maker__r.TB_User__c);
                    }
                    else
                    {
                        dmUserIdsByCaseId.put(operation.TB_Case__c,new List<Id>{operation.TB_Decision_Maker__r.TB_User__c});
                    }
                }
            }
        }
    
        public void execute(QueueableContext context)
        {
            if(dmUserIdsByCaseId.isEmpty())
            {
                return;
            }
            if(!usersActivated)
            {
                userIdsToActivate = activateUsers(userIdsToActivate);
                if(userIdsToActivate.isEmpty() || ++activationLoops > MAX_ACTIVATION_LOOPS)
                {
                    usersActivated = true;
                }
                if(!Test.isRunningTest())
                {
                    System.enqueueJob(this);
                }
            }
            else
            {
                shareOperations();
            }
        }
        
        private void shareOperations()
        {
            delete [SELECT Id FROM TB_Operation__Share WHERE RowCause = :ROW_CAUSE_DECISION_MAKER AND Parent.TB_Case__c IN :dmUserIdsByCaseId.keySet()];
            List<TB_Operation__Share> sharesToInsert = new List<TB_Operation__Share>();
            for(Id caseId : dmUserIdsByCaseId.keySet())
            {
                for(Id dmUserId : dmUserIdsByCaseId.get(caseId))
                {
                    for(Id operationId : operationIdsByCaseId.get(caseId))
                    {
                        sharesToInsert.add(createOperationShare(operationId,dmUserId));
                    }
                }
            }
    
            Database.insert(sharesToInsert,false);
        }
    }
    
    private static TB_Operation__Share createOperationShare(Id operationId, Id userId)
    {
        return new TB_Operation__Share(
                AccessLevel = 'Read',
                ParentId = operationId,
                RowCause = ROW_CAUSE_DECISION_MAKER,
                UserOrGroupId = userId
        );
    }
    
    private static Set<Id> activateUsers(Set<Id> userIds)
    {
        List<User> usersToActivate = new List<User>();
        for(Id userId : userIds)
        {
            usersToActivate.add(new User(Id=userId,IsActive=true));
        }
        List<Database.SaveResult> saveResults = Database.update(usersToActivate,false);
        Set<Id> userIdsFailedToLock = new Set<Id>();
        for(Database.SaveResult sr : saveResults)
        {
            if(!sr.isSuccess())
            {
                for(Database.Error err : sr.getErrors())
                {
                    if(err.getMessage().contains(UNABLE_TO_LOCK_ROW_MESSAGE))
                    {
                        userIdsFailedToLock.add(sr.getId());
                    }
                }
            }
        }
        return userIdsFailedToLock;
    }
}