public without sharing class TB_ObjectSharingBatch implements Database.Batchable<User>, Database.Stateful{

    private List<User> users;
    private List<SObject> sharesToCreate;


    public TB_ObjectSharingBatch(List<User> users, List<SObject> sharesToCreate) {
        this.users = users;
        this.sharesToCreate = sharesToCreate;
    }

    public List<User> start(Database.BatchableContext context) {
        return users;
    }

    public void execute(Database.BatchableContext context, List<User> users) {
        update users;
    }

    public void finish (Database.BatchableContext context) {
        System.enqueueJob(new TB_ObjectSharingQueueable(sharesToCreate));
    }

}