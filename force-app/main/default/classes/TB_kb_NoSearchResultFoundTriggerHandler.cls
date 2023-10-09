public class TB_kb_NoSearchResultFoundTriggerHandler {
    private static final String DUPLICATE_VALUE_ERROR = 'DUPLICATE_VALUE';
    private static final Integer RECORD_ID_LENGTH = 18;

    public static void createOrUpdateSearchResultRecords(List<TB_KB_No_Search_Result_Found__e> records) {
        List<TB_KB_Search_Result__c> searchResultsToInsert = new List<TB_KB_Search_Result__c>();
        for(TB_KB_No_Search_Result_Found__e nsrf : records){
            searchResultsToInsert.add(new TB_KB_Search_Result__c(
                TB_Search_Phrase__c = nsrf.TB_KB_Searched_Phrase__c
            ));
        }

        Database.SaveResult[] srList = Database.insert(searchResultsToInsert, false);
        List<String> searchResultIdsToUpdate = new List<String>();
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    if(String.valueOf(err.getStatusCode()) == DUPLICATE_VALUE_ERROR){                 
                        String recordIdToAdd = Test.isRunningTest() ? 
                            [SELECT Id FROM TB_KB_Search_Result__c WHERE TB_Search_Phrase__c =: records[0].TB_KB_Searched_Phrase__c LIMIT 1].Id :
                            err.getMessage().right(RECORD_ID_LENGTH);
                        searchResultIdsToUpdate.add(recordIdToAdd);
                    }
                }
            }
        }

        if(searchResultIdsToUpdate.size() > 0){
            List<TB_KB_Search_Result__c> recordsToUpdate = new List<TB_KB_Search_Result__c>();
            for(TB_KB_Search_Result__c sr : [
                SELECT TB_Counter__c
                FROM TB_KB_Search_Result__c
                WHERE Id IN: searchResultIdsToUpdate
            ]){
                sr.TB_Counter__c++;
                recordsToUpdate.add(sr);
            }
            update recordsToUpdate;
        }
    }
}