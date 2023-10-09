public class TB_CT_DeactivateUser implements Queueable {
    public Set<Id> contactsToDel;
    public Set<Id> accountsToDel;
    public Set<Id> usersToDeactivate;
    public Boolean isSynced;

    public TB_CT_DeactivateUser( Set<Id> contactsToDel, Set<Id> accountsToDel, Set<Id> usersToDeactivate,Boolean isSynced) {
        this.accountsToDel = accountsToDel;
        this.contactsToDel = contactsToDel;
        this.usersToDeactivate = usersToDeactivate;
        this.isSynced = isSynced;
    }

    public void execute(QueueableContext context) {
        updateUser(this.contactsToDel,this.accountsToDel,this.usersToDeactivate,this.isSynced);
    }

    private static void updateUser( Set<Id> contactsToDel, Set<Id> accountsToDel, Set<Id> usersToDeactivate,Boolean isSynced ){
        try{
            List<Contact> contactsToUpdate = [SELECT Id FROM Contact WHERE Id IN : contactsToDel];

            for (Contact con: contactsToUpdate) {
                con.TB_x_Disable_User__c = true;
                con.TB_x_User_Synced__c = isSynced;
            }
            update contactsToUpdate;
        } 
        catch(Exception e) {
            addErrorLog(e.getMessage());
        }
    }

    @Future @TestVisible 
    private static void addErrorLog(String message){
        insert TB_LogUtils.registerLog(message, TB_CT_DeactivateUser.class);
    }
}