global class TB_vu_DeleteUnusedFilesBatch implements Database.Batchable<sObject> {
    private List<String> profiles = new List<String>{'SWPS Employee Platform User', 'SWPS Student'};

    global Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN (SELECT Id FROM User WHERE Profile.Name IN: profiles)
        ]);
    }

    global void execute(Database.BatchableContext context, List<ContentDocumentLink> scope){
        Set<id> cdlIds = new Set<Id>();
        for(ContentDocumentLink cdl : scope){
            cdlIds.add(cdl.ContentDocumentId);
        }

        List<Id> contentDocumentIdsToDelete = new List<Id>();
        for(AggregateResult ar : [SELECT ContentDocumentId, COUNT(linkedEntityId)leIdAmount FROM ContentDocumentLink WHERE ContentDocumentId IN: cdlIds GROUP BY ContentDocumentId]){
            if(Integer.valueOf(ar.get('leIdAmount')) == 1){
                contentDocumentIdsToDelete.add(String.valueOf(ar.get('ContentDocumentId')));
            }
        }
        delete [SELECT Id FROM ContentDocument WHERE Id IN: contentDocumentIdsToDelete];
    }

    global void finish(Database.BatchableContext context) {}
}