public with sharing class TB_CT_SendContactToImButtonController {
    
    @AuraEnabled
    public static string sendtoim(String id,String language){
        String output;
        try {
            output = TB_CT_IMIntegration.createOrUpdatePerson(id,language,false);
            return output;
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e);
            throw new AuraHandledException(e.getMessage());
        }
    }
}
