public with sharing class TB_CT_DeactivateUserScheduled implements Schedulable {
    private static final String EMPLOYEE_RECORD_TYPE_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('TB_Employee').getRecordTypeId();

    public void execute(SchedulableContext sc) {
        try {
        Id contractTeachersProfile = [SELECT Id FROM Profile WHERE Name = 'SWPS Employee Community User' LIMIT 1]?.Id;
        Map<Id, Boolean> usersSyncDataMap = new Map<Id, Boolean>();

        for (Contact c : [SELECT Id,
                          TB_User__c, 
                          TB_x_User_Synced__c 
                          FROM Contact 
                          WHERE TB_x_Disable_User__c = TRUE 
                          AND RecordTypeId = :EMPLOYEE_RECORD_TYPE_ID 
                          AND TB_User__r.isActive = TRUE 
                          AND TB_Active__c = TRUE]) {
            usersSyncDataMap.put(c.TB_User__c, c.TB_x_User_Synced__c);
        }
        
        Map<Id,Contact> contactsSynced = new Map<Id,Contact>([SELECT Id, 
            TB_x_User_Synced__c, 
            TB_Active__c,   
            TB_User__c,  
            AccountId  
            FROM Contact
            WHERE TB_x_Disable_User__c = TRUE
            AND TB_x_User_Synced__c = TRUE
            AND TB_User__r.isActive = TRUE]); 

            Map<Id,Contact> contactsNotSynced = new Map<Id,Contact>([SELECT Id, 
            TB_x_User_Synced__c, 
            TB_Active__c,   
            TB_User__c,  
            AccountId  
            FROM Contact
            WHERE TB_x_Disable_User__c = TRUE
            AND TB_x_User_Synced__c = FALSE
            AND TB_User__r.isActive = TRUE]);   

        
        Map<Id, User> usersNotSyncedMap = new  Map<Id, User>([SELECT Id FROM User WHERE ContactId IN :contactsNotSynced.keySet()]);
        List<Account> accountsToDeactivate = [SELECT Id FROM Account WHERE hed__Primary_Contact__c IN :contactsSynced.keySet()];
        List<Account> accountsToDelete =  [SELECT Id FROM Account WHERE hed__Primary_Contact__c IN :contactsNotSynced.keySet()];
        Set<Id> accToDelete = (new Map<Id, SObject>(accountsToDelete)).keySet();

        List<User> usersToDeactivate = [
            SELECT Id, 
            IsActive, 
            ProfileId, 
            IsPortalEnabled
            FROM User
            WHERE
            Id IN :usersSyncDataMap.keySet()
            AND IsActive = TRUE
            AND ProfileId = :contractTeachersProfile
        ];
        for (User u : usersToDeactivate) {
            u.IsActive = false;
            u.IsPortalEnabled = false;

            if (!usersSyncDataMap.get(u.Id)) {
            u.Email = TB_RandomDataUtils.generateRandomText(8) + '@' + TB_RandomDataUtils.generateRandomText(4) + '.com';
            u.Fax = null;
            u.FirstName = TB_RandomDataUtils.generateRandomText(8);
            u.LastName = TB_RandomDataUtils.generateRandomText(8);
            u.Alias = TB_RandomDataUtils.generateRandomText(8);
            u.City = null;
            u.CompanyName = null;
            u.Phone = null;
            u.PostalCode = null;
            u.State = null;
            u.Street = null;
            u.Title = null;
        }
    }

        update usersToDeactivate;
        if (!Test.isRunningTest()) {
            System.enqueueJob(new TB_CT_DeleteAssociatedRecords(contactsSynced.values(), contactsNotSynced.values(), usersNotSyncedMap.keySet(), accountsToDeactivate, accToDelete));
        }
        } catch (Exception ex) {
            insert TB_LogUtils.registerLog(ex, TB_CT_DeactivateUserScheduled.class);
        }
    }
}