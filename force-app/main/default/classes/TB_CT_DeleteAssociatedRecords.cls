public class TB_CT_DeleteAssociatedRecords implements Queueable {
    private List<Contact> contactsSynced;
    private List<Contact> contactsNotSynced;
    private Set<Id> usersNotSynced;
    private List<Account> accountsToDeactivate;
    private Set<Id> accountsToDelete;

    public TB_CT_DeleteAssociatedRecords(
        List<Contact> contactsSynced,
        List<Contact> contactsNotSynced,
        Set<Id> usersNotSynced,
        List<Account> accountsToDeactivate,
        Set<Id> accountsToDelete
    ) {
        this.contactsSynced = contactsSynced;
        this.contactsNotSynced = contactsNotSynced;
        this.usersNotSynced = usersNotSynced;
        this.accountsToDeactivate = accountsToDeactivate;
        this.accountsToDelete = accountsToDelete;
    }

    public void execute(QueueableContext context) {
        deleteAssociated(
        this.contactsSynced,
        this.contactsNotSynced,
        this.usersNotSynced,
        this.accountsToDeactivate,
        this.accountsToDelete
        );
    }

    private static void deleteAssociated(
        List<Contact> contactsSynced,
        List<Contact> contactsNotSynced,
        Set<Id> usersNotSynced,
        List<Account> accountsToDeactivate,
        Set<Id> accountsToDelete
    ) {
        try {
        Set<Id> contactsToDeactivateIds = contactsSynced != null ? (new Map<Id, SObject>(contactsSynced)).keySet() : new Set<Id>();
        Set<Id> contactsToDeleteIds = contactsNotSynced != null ? (new Map<Id, SObject>(contactsNotSynced)).keySet() : new Set<Id>();
        List<hed__Affiliation__c> affToDeactivate = [
            SELECT Id
            FROM hed__Affiliation__c
            WHERE hed__Contact__c IN :contactsToDeactivateIds
        ];

        if (contactsSynced != null && !contactsSynced.isEmpty()) {
            for (Account acc : accountsToDeactivate) {
            acc.TB_Active__c = false;
            }
            for (Contact con : contactsSynced) {
            con.TB_Active__c = false;

            if (!Test.isRunningTest()) {
                sendToIMDeactivateDate(con.Id);
            }
            }

            for (hed__Affiliation__c aff : affToDeactivate) {
            aff.hed__EndDate__c = Date.today();
            aff.hed__Status__c = 'Former';
            }
            update accountsToDeactivate;
            update affToDeactivate;
            update contactsSynced;
        }
        if (contactsNotSynced != null && !contactsNotSynced.isEmpty()) {
            delete [SELECT Id FROM Case WHERE OwnerId IN :usersNotSynced OR ContactId IN :contactsToDeleteIds];
            delete [ SELECT Id FROM hed__Affiliation__c WHERE hed__Contact__c IN :contactsToDeleteIds];
            delete contactsNotSynced;
            delete [SELECT Id FROM Account WHERE Id IN :accountsToDelete];
            
        }
        } catch (Exception e) {
            insert TB_LogUtils.registerLog(e.getMessage(),TB_CT_DeleteAssociatedRecords.class);
        }
    }

    @Future(callout=true)
    @TestVisible
    private static void sendToIMDeactivateDate(Id contactId) {
        TB_CT_IMIntegration.createOrUpdatePerson(contactId, 'EN', true);
    }
}
