public with sharing class TB_GetContactIdController {
    @AuraEnabled
    public static String returnContactId(String userId){
        String toReturn;
        try{
             toReturn = [Select Id from Contact where TB_User__c = :userId].Id;
        }catch(Exception e){
            TB_LogUtils.registerLogFuture(
                e.getMessage(),
                TB_GetContactIdController.class.getName()
            );
        }
        return toReturn;
    }
}