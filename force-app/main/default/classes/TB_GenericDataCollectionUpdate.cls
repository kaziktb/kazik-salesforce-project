public with sharing class TB_GenericDataCollectionUpdate {

    public static void updateDataCollections (Map<Id, SObject> objectIdToSObject) {

        List<TB_Data_Collection__c> dataCollections = [
            SELECT Id, TB_Value_Text__c, TB_Source_Object_Id__c,
                TB_Source_Object_Field__c, TB_Data_Type__c, TB_Value_Long_Text__c
            FROM TB_Data_Collection__c
            WHERE TB_Source_Object_Id__c IN :objectIdToSObject.keySet()
        ];

        List<TB_Data_Collection__c> dataCollectionsToUpdate = new List<TB_Data_Collection__c>();
        for (TB_Data_Collection__c singleDataCollection : dataCollections) {
            SObject sObj = objectIdToSObject.get(singleDataCollection.TB_Source_Object_Id__c);
            String fieldValue = String.valueOf (
                sObj.get(singleDataCollection.TB_Source_Object_Field__c)
            );

            if ( singleDataCollection.TB_Data_Type__c == 'Text (Long)'
                && singleDataCollection.TB_Value_Long_Text__c != fieldValue
            ) {
                singleDataCollection.TB_Value_Long_Text__c = fieldValue;
                dataCollectionsToUpdate.add(singleDataCollection);
            } else if ( singleDataCollection.TB_Data_Type__c != 'Text (Long)'
                && singleDataCollection.TB_Value_Text__c != fieldValue
            ) {
                singleDataCollection.TB_Value_Text__c = fieldValue;
                dataCollectionsToUpdate.add(singleDataCollection);
            }
        }
        update dataCollectionsToUpdate;
    }
}