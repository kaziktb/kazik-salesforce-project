public without sharing class TB_ContactIdController {
    @AuraEnabled
    public static Contact getContact(String userId){
        List<Contact> contacts = [
                SELECT Id, RecordType.DeveloperName, hed__UniversityEmail__c, hed__WorkEmail__c, hed__AlternateEmail__c
                FROM Contact
                WHERE TB_User__c = :userId
        ];
        if(contacts.isEmpty())
        {
            throw new AuraHandledException(TB_vu_Utils.registerLog('VU.GLOBAL.INITIAL_HANDLER.ERRORMSG.NO_CONTACT',TB_ContactIdController.class.getName(),null,userId));
        }
        if(contacts.size() > 1)
        {
            throw new AuraHandledException(TB_vu_Utils.registerLog('VU.GLOBAL.INITIAL_HANDLER.ERRORMSG.MORE_THAN_ONE_CONTACT',TB_ContactIdController.class.getName(),null,userId));
        }
        return contacts[0];
    }
}